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

When a callback is registered with a promise using `bind` or one of the other syntaxes, it is
added to a list of callbacks that is stored with the promise. Eventually, if
the promise is fulfilled, the Lwt *resolution loop* runs all the callbacks
registered with the promise. There is no guarantee about the execution order of
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

Finally, the resolution loop never attempts to interrupt a callback. So if one
callback goes into an infinite loop, no other callback will ever get to run.
That makes Lwt a cooperative concurrency mechanism, rather than a preemptive one.

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

A *handler* is a new abstraction: a function that takes a state.
The primary use for a handler will be to run callbacks.
It will be used to fulfill and reject promises when their state is
ready to switch away from pending. This is why we ask, via a representation
invariant, that the input state to a handler may not be pending.

We require that only pending promises may have handlers waiting in their list.
Once the state becomes non-pending, i.e., either fulfilled or rejected,
the handlers associated with the promise will all be processed and
removed from the list.
This is why we say, as a representation invariant, that if the state is not pending,
then the handlers list must be empty.

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
    (p, p)

  let return x =
    {state = Fulfilled x; handlers = []}

  let state p = p.state
```

Now we get to the trickier parts of the implementation.

The steps needed to reject a promise (with an exception) or fulfill a promise
(with a value) are quite similar, so we implement a helper function `resolve`.
This helper takes a resolver and a state, and it changes the state of the associated promise to
the given state.
We require that the state `st` that we are moving over to may not be the pending state.
We mutate the handlers list to be empty to ensure that the RI holds,
but we save the handlers in a local variable.
Then we call `write_once` on the resolver to change its state.
Finally, we process all the handlers that were waiting on
this promise. Each of those handlers requires a state for an input, and
we pass them the new state that the promise has just been set to.

```ocaml
  (** Requires: [st] may not be [Pending]. *)
  let resolve (r : 'a resolver) (st : 'a state) =
    assert (st <> Pending);
    let handlers = r.handlers in
    r.handlers <- [];
    write_once r st;
    List.iter (fun f -> f st) handlers

  let reject r e =
    resolve r (Rejected e)

  let fulfill r v =
    resolve r (Fulfilled v)
```

Finally, the implementation of `>>=` is the trickiest part.
Recall that the `bind` function needs to immediately return a new promise.
First, if the input promise is already fulfilled, let's go ahead and immediately
run the callback on it. The callback will yield a new promise, which we immediately
return:

```ocaml
  let ( >>= )
      (input_promise : 'a promise)
      (callback : 'a -> 'b promise) : 'b promise
    =
    match input_promise.state with
    | Fulfilled x -> callback x
```

Second, if the promise is already rejected with some exception, we craft a trivial new promise
that is also rejected with the same exception.
We return that new promise to the user immediately:
```ocaml
    | Rejected exc -> {state = Rejected exc; handlers = []}
```

Third, if the input promise is pending, we need to do more work.
Our task is delicate: we need to immediately return a new promise
(which we will call the output promise) to the user, but we also need that
output promise to become fulfilled when (or if) the input promise becomes
fulfilled and the callback completes running, sometime in the future.
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

All that's left is to implement that helper function to create handlers out of
callbacks. Recall that a handler's type is itself a *function type*,
`'a state -> unit`. This is why our helper function's output is actally an
anonymous function. That anonymous function takes a state as its input:

```ocaml
  let handler_of_callback
      (callback : 'a -> 'b promise)
      (resolver : 'b resolver) : 'a handler =
      fun (state : 'a state) ->
```

We proceed by taking cases on that input state.
The first two cases, below, are simple. It would violate the RI to
call a handler on a pending state. And if the state is rejected, then the
handler should propagate that rejection to the resolver, which causes the
promise returned by bind to also be rejected.

```ocaml
  let handler_of_callback
      (callback : 'a -> 'b promise)
      (resolver : 'b resolver) : 'a handler =
      fun (state : 'a state) ->
      match state with
      | Pending -> failwith "handler RI violated"
      | Rejected exc -> reject resolver exc
```

But if the state is fulfiled, then the callback registered with the promise
can&mdash;at last!&mdash;be run on the contents of the fulfilled promise. If the callback executes successfully it produces a new promise, but recall that the callback
may itself raise an exception.

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
        | Pending -> enqueue (copying_handler resolver) promise
```

where `copying_handler` is a new helper function that creates a very simple handler
to do that propagation:

```ocaml
  let copying_handler (resolver : 'a resolver) : 'a handler
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
          | Pending -> enqueue (copying_handler resolver) promise
        with exc -> reject resolver exc
```

The Lwt implementation of `bind` follows essentially the same algorithm as we
just implemented. Note that there is no concurrency in `bind`: as we said above,
it's the OS that provides the concurrency.
