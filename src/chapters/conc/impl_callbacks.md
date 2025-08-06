---
jupytext:
  cell_metadata_filter: -all
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.10.3
kernelspec:
  display_name: OCaml
  language: OCaml
  name: ocaml-jupyter
---

# Implementing Callbacks

When a callback is registered with `bind` or one of the other syntaxes, it is
added to a list of callbacks that is stored with the promise. Eventually, when
the promise has been fulfilled, the Lwt *resolution loop* runs the callbacks
registered for the promise. There is no guarantee about the execution order of
callbacks for a promise. In other words, the execution order is
nondeterministic. If the order matters, the programmer needs to use the
composition operators (such as `bind` and `join`) to enforce an ordering. If the
promise never becomes fulfilled (or is rejected), none of its callbacks will ever
be run.

```{note}
Lwt also supports registering functions that are run after a promise is rejected.
`Lwt.catch` and `try%lwt` are used for this purpose. They are counterparts
to `Lwt.bind` and `let%lwt`.
```

Once again, it's important to keep track of where the concurrency really comes
from: the OS. There might be many asynchronous I/O operations occurring at the
OS level. But at the OCaml level, the resolution loop is sequential, meaning
that only one callback can ever be running at a time.

Finally, the resolution loop never attempts to interrupt a callback. So if the
callback goes into an infinite loop, no other callback will ever get to run.
That makes Lwt a cooperative concurrency mechanism, rather than preemptive.

To better understand callback resolution, let's implement it ourselves. We'll
use the `Promise` data structure we developed earlier. To start, we add a bind
operator to the `Promise` signature:

```ocaml
module type PROMISE = sig
  ...

  (** [p >>= c] registers callback [c] with promise [p].
      When the promise is fulfilled, the callback will be run
      on the promises's contents.  If the promise is never
      fulfilled, the callback will never run. *)
  val ( >>= ) : 'a promise -> ('a -> 'b promise) -> 'b promise
end
```

Next, let's re-develop the entire `Promise` structure.  We start
off just like before:

```ocaml
module Promise : PROMISE = struct
  type 'a state = Pending | Fulfilled of 'a | Rejected of exn
  ...
```

But now to implement the representation type of promises, we use a record with
mutable fields. The first field is the state of the promise, and it corresponds
to the `ref` we used before. The second field is more interesting and is
discussed below.

```ocaml
  (** RI: the input may not be [Pending]. *)
  type 'a handler = 'a state -> unit

  (** RI: if [state <> Pending] then [handlers = []]. *)
  type 'a promise = {
    mutable state : 'a state;
    mutable handlers : 'a handler list
  }
```

A *handler* is a new abstraction: a function that takes a non-pending state. It
will be used to fulfill and reject promises when their state is
ready to switch away from pending. The primary use for a handler will be to run
callbacks. As a representation invariant, we require that only pending promises
may have handlers waiting in their list. Once the state becomes non-pending,
i.e., either fulfilled or rejected, the handlers will all be processed and
removed from the list.

This helper function that enqueues a handler on a promise's handler list will be
helpful later:

```ocaml
  let enqueue
      (handler : 'a state -> unit)
      (promise : 'a promise) : unit
    =
    promise.handlers <- handler :: promise.handlers
```

We continue to pun resolvers and promises internally:

```ocaml
  type 'a resolver = 'a promise
```

Because we changed the representation type from a `ref` to a record,
we have to update a few of the functions in trivial ways:

```ocaml
  (** [write_once p s] changes the state of [p] to be [s].  If [p] and [s]
      are both pending, that has no effect.
      Raises: [Invalid_arg] if the state of [p] is not pending. *)
  let write_once p s =
    if p.state = Pending
    then p.state <- s
    else invalid_arg "cannot write twice"

  let make () =
    let p = {state = Pending; handlers = []} in
    p, p

  let return x =
    {state = Fulfilled x; handlers = []}

  let state p = p.state
```

Now we get to the trickier parts of the implementation. To fulfill or reject a
promise, the first thing we need to do is to call `write_once` on it, as we did
before. Now we also need to process the handlers. Before doing so, we mutate the
handlers list to be empty to ensure that the RI holds.

```ocaml
  (** Requires: [st] may not be [Pending]. *)
  let fulfill_or_reject (r : 'a resolver) (st : 'a state) =
    assert (st <> Pending);
    let handlers = r.handlers in
    r.handlers <- [];
    write_once r st;
    List.iter (fun f -> f st) handlers

  let reject r x =
    fulfill_or_reject r (Rejected x)

  let fulfill r x =
    fulfill_or_reject r (Fulfilled x)
```

Finally, the implementation of `>>=` is the trickiest part. First, if the
promise is already fulfilled, let's go ahead and immediately run the callback on
it:

```ocaml
  let ( >>= )
      (input_promise : 'a promise)
      (callback : 'a -> 'b promise) : 'b promise
    =
    match input_promise.state with
    | Fulfilled x -> callback x
```

Second, if the promise is already rejected, then we return a promise
that is rejected with the same exception:

```ocaml
    | Rejected exc -> {state = Rejected exc; handlers = []}
```

Third, if the promise is pending, we need to do more work.
The `bind` function needs to return a new promise. That promise will become
fulfilled when (or if) the callback completes running, sometime in the future.
Its contents will be whatever contents are contained within the promise that the
callback itself returns.

So, we create a new promise and resolver
called `output_promise` and `output_resolver`. That promise is what `bind`
returns. Before returning it, we use a helper function `handler_of_callback`
(described below) to transform the callback into a handler, and enqueue that
handler on the promise. That ensures the handler will be run when the promise
later becomes resolved:

```ocaml
    | Pending ->
      let output_promise, output_resolver = make () in
      enqueue (handler_of_callback callback output_resolver) input_promise;
      output_promise
```

All that's left is to implement that helper function to create handlers from
callbacks. The first two cases, below, are simple. It would violate the RI to
call a handler on a pending state. And if the state is rejected, then the
handler should propagate that rejection to the resolver, which causes the
promise returned by bind to also be rejected.

```ocaml
  let handler_of_callback
      (callback : 'a -> 'b promise)
      (resolver : 'b resolver) : 'a handler
    = function
      | Pending -> failwith "handler RI violated"
      | Rejected exc -> reject resolver exc
```

But if the state is fulfiled, then the callback provided by the user to bind
can&mdash;at last!&mdash;be run on the contents of the fulfilled promise. If the callback executes successfully it produces a new promise, but the callback may itself raise an exception.

First, consider the optimistic case in which the callback executes successfully and produces a promise. That promise might already be rejected or fulfilled,
in which case that state again propagates.

```ocaml
      | Fulfilled x ->
        let promise = callback x in
        match promise.state with
        | Fulfilled y -> resolve resolver y
        | Rejected exc -> reject resolver exc
```

But the promise might still be pending.  In that case, we need to enqueue
a new handler whose purpose is to do the propagation once the result is
available:

```ocaml
        | Pending -> enqueue (handler resolver) promise
```

where `handler` is a new helper function that creates a very simple handler
to do that propagation:

```ocaml
  let handler (resolver : 'a resolver) : 'a handler
    = function
      | Pending -> failwith "handler RI violated"
      | Rejected exc -> reject resolver exc
      | Fulfilled x -> resolve resolver x
```

Second, consider the case in which the callback function itself raises some exception `exc`. In that case, we need to reject the promise with that exception. We do this by wrapping the execution of the callback in a `try` block:

```ocaml
      | Fulfilled x ->
        try
          let promise = callback x in
          match promise.state with
          | Fulfilled y -> resolve resolver y
          | Rejected exc -> reject resolver exc
          | Pending -> enqueue (handler resolver) promise
        with exc -> reject resolver exc
```

The Lwt implementation of `bind` follows essentially the same algorithm as we
just implemented. Note that there is no concurrency in `bind`: as we said above,
it's the OS that provides the concurrency.
