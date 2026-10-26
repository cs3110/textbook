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

When a callback is registered with a pending promise using `bind`, the promise
must remember what to do after it resolves. In Lwt, the *resolution loop* runs
callbacks as promises are fulfilled. There is no guarantee about the execution
order of independent callbacks on a promise. If the order matters, the programmer
needs to use composition operators such as `bind` to express that dependency.
If the promise is rejected, its `bind` callbacks do not run; instead, the
rejection propagates to the promises returned by `bind`.

```{note}
Lwt also supports registering functions that are run after a promise is rejected.
`Lwt.catch` and `try%lwt` are used for this purpose. They are counterparts
to `Lwt.bind` and `let%lwt`.
```

Once again, it's important to keep track of where the concurrency comes from:
the OS can carry out asynchronous I/O while the OCaml program does other work.
The callbacks themselves run sequentially. The resolution loop does not
interrupt a running callback, so a callback that goes into an infinite loop
prevents other callbacks from running. That makes Lwt a cooperative concurrency
mechanism.

To understand how callbacks work, let's extend our `Promise` module with `bind`.
We will use two new ideas:

* A *handler* remembers work to do when a promise resolves. It runs the callback
  or propagates a rejection.
* A *proxy* lets two promises share an outcome. It connects the promise returned
  by a callback to the promise already returned by `bind`.

Our implementation runs handlers directly when a promise is resolved. It does
not implement an I/O system or a main loop. As before, the promise data structure
itself provides no concurrency.

## Remembering Work with Handlers

The only new operation in our signature is `bind`:

```ocaml
module type PROMISE = sig
  ...

  (** [bind p f] registers callback [f] with promise [p].
      When the promise is fulfilled, the callback will be run
      on the promise's contents. If the promise is never
      fulfilled, the callback will never run. *)
  val bind : 'a promise -> ('a -> 'b promise) -> 'b promise
end
```

The public state type stays the same:

```ocaml
type 'a state = Pending | Fulfilled of 'a | Rejected of exn
```

A callback receives a fulfilled value and returns a promise. A handler has a
different job: it receives a resolved *outcome* and performs the work needed to
resolve or link another promise. We represent an outcome with the standard
`result` type:

```ocaml
type 'a handler = ('a, exn) result -> unit
```

`Ok v` means fulfillment with value `v`, and `Error e` means rejection with
exception `e`. There is no constructor for a pending outcome, so the type itself
prevents us from passing one to a handler.

To store handlers, we first replace our reference with a record whose mutable
contents can hold a list:

```ocaml
type 'a contents =
  | Pending of 'a handler list
  | Fulfilled of 'a
  | Rejected of exn

type 'a promise = { mutable contents : 'a contents }
type 'a resolver = 'a promise
```

Only `Pending` has a handler list. Once the contents become `Fulfilled` or
`Rejected`, there is no place to store waiting handlers. Again, the type enforces
part of our representation invariant. Internally, a resolver is still the same
record as its promise; the signature keeps those roles distinct for clients.

## Bind and Its Handler

There are three promises to keep track of in `let p3 = bind p1 f`, assuming that `p1` is pending:

* `p1` is the input promise. Its fulfilled value will be the argument to `f`.
* `p2` is the promise that `f` eventually returns. It might already exist before
  `f` runs, and it might still be pending when `f` returns it.
* `p3` is the new pending promise that `bind` returns immediately. Its eventual
  outcome must be the same as `p2`'s.

The pending case of `bind` creates `p3` and its resolver, makes a handler that
captures both `f` and that resolver, and stores the handler on `p1`:

```ocaml
| Pending ->
    let p3, p3_resolver = make () in
    let h = make_handler f p3_resolver in
    enqueue h p1;
    p3
```

The handler will run when `p1` resolves. It does not run merely because `bind`
registered it, and `bind` does not wait for it before returning `p3`.

Here is the helper that makes that handler. For now, assume that `link p2 r`
arranges for the promise associated with `r` to share `p2`'s outcome. We will
implement `link` below.

```ocaml
let make_handler (f : 'a -> 'b promise) (r : 'b resolver)
    : 'a handler = function
  | Error exc -> reject r exc
  | Ok v1 ->
      let p2 = try f v1 with e -> fail e in
      link p2 r
```

If `p1` was rejected, the handler rejects `p3` with the same exception without
running `f`. If `p1` was fulfilled, the handler runs `f` on its value. If `f`
raises an exception, `fail` creates an already-rejected promise, so linking
propagates that rejection too:

```ocaml
let fail exc = { contents = Rejected exc }
```

Notice the scope of the `try`: it covers only `f v1`. The call to `link` is
outside it. An exception raised by the callback becomes a rejected promise;
an error in the promises implementation itself must not be mistaken for an
exception from that callback.

## Running Handlers

To resolve a pending promise, we need to save its handlers, replace its contents
with the resolved outcome, and then run the saved handlers with that outcome.
Changing the contents first ensures that handlers observe a resolved promise,
and also removes the stored list before any handler runs.

Here is `resolve` in its final form. The helper `underlying`, defined below,
follows any proxy links to the record that owns the contents. Until we introduce
proxies, you can read `underlying r` as just `r`.

```ocaml
let resolve (r : 'a resolver) (outcome : ('a, exn) result) =
  let r = underlying r in
  let contents : 'a contents =
    match outcome with
    | Ok v -> Fulfilled v
    | Error e -> Rejected e
  in
  match r.contents with
  | Pending hs ->
      r.contents <- contents;
      List.iter (fun h -> h outcome) (List.rev hs)
  | Fulfilled _ | Rejected _ ->
      invalid_arg "Already resolved"
  | Proxy _ -> assert false

let reject r x = resolve r (Error x)
let fulfill r x = resolve r (Ok x)
let return x = { contents = Fulfilled x }
```

`resolve` takes over the job of the earlier `write_once` helper: it rejects a
second attempt to resolve a promise. The final case is impossible because
`underlying` never returns a proxy.

We will prepend handlers when registering them, so reversing the list before
running it preserves registration order within that list. Linking will combine
lists from two promises. Our interface makes no guarantee about the relative
order of handlers from those lists; programs must express required sequencing dependencies explicitly with `bind`.

## Sharing Outcomes with Proxies

Suppose `p1` is fulfilled and its handler calls `f`, which returns `p2`. We must
now make `p3` share `p2`'s outcome. If `p2` is already resolved, we can immediately
resolve `p3` with that outcome. But if `p2` is pending, we cannot yet do that.
Moreover, clients might already have registered handlers on either promise, and
the resolver for `p2` might already be held elsewhere in the program.

We solve this by making `p2` a *proxy* for `p3`: operations on `p2` follow a
reference to `p3`. We move `p2`'s handlers to `p3` so that a single underlying
promise owns both the outcome and the waiting work. The direction matters:
`p2` becomes the proxy, and `p3` becomes the owner.

Here is the final representation:

```ocaml
type 'a promise = { mutable contents : 'a contents }

and 'a contents =
  | Pending of 'a handler list
  | Fulfilled of 'a
  | Rejected of exn
  | Proxy of 'a promise

type 'a resolver = 'a promise
```

The types are mutually recursive: a promise contains contents, and proxy contents
refer to another promise. The abstraction function follows proxy links to find
the observable state. A proxy and its target represent the same outcome. The
representation invariant requires proxy links to be acyclic. Only pending
promises can store handlers, which the type already guarantees.

`Proxy` is an internal representation, not a fourth public state. Clients
still see only `Pending`, `Fulfilled`, or `Rejected`.

We find the owner by following links:

```ocaml
let rec underlying (p : 'a promise) : 'a promise =
  match p.contents with
  | Proxy p' -> underlying p'
  | Pending _ | Fulfilled _ | Rejected _ -> p
```

For example, if `p` is a proxy for `q`, and `q` is a proxy for `r`, then
`underlying p` returns `r`.

Creating a promise still creates one record shared by the promise and resolver:

```ocaml
let make () =
  let p = { contents = Pending [] } in
  (p, p)
```

Observing a state and registering a handler both follow proxy links:

```ocaml
let state (p : 'a promise) : 'a state =
  match (underlying p).contents with
  | Pending _ -> Pending
  | Fulfilled v -> Fulfilled v
  | Rejected e -> Rejected e
  | Proxy _ -> assert false

let enqueue (h : 'a handler) (p : 'a promise) : unit =
  let p = underlying p in
  match p.contents with
  | Pending hs -> p.contents <- Pending (h :: hs)
  | Fulfilled _ | Rejected _ ->
      invalid_arg "Cannot enqueue on a resolved promise"
  | Proxy _ -> assert false
```

Recall that `resolve` also calls `underlying`. That is what makes a resolver
created *before* it became a proxy continue to work. Resolving through one 
alias therefore changes the state observed through all aliases.

## Linking Promises

The operation `link p2 p3` makes `p3` share `p2`'s outcome. It requires the
underlying promise of `p3` to be pending. First, it follows links from both
promises. If the two owners are already the same, it does nothing. Otherwise,
it either merges two pending promises or propagates an already-resolved
outcome:

```ocaml
let link (p2 : 'a promise) (p3 : 'a promise) : unit =
  let p2 = underlying p2 in
  let p3 = underlying p3 in
  if p2 == p3 then ()
  else
    match (p2.contents, p3.contents) with
    | Pending hs2, Pending hs3 ->
        p3.contents <- Pending (hs2 @ hs3);
        p2.contents <- Proxy p3
    | Fulfilled v, Pending _ -> fulfill p3 v
    | Rejected e, Pending _ -> reject p3 e
    | _, (Fulfilled _ | Rejected _) ->
        invalid_arg "Cannot link into a resolved promise"
    | Proxy _, _ | _, Proxy _ -> assert false
```

The identity test uses physical equality, `==`, because we want to know whether
these are the *same record*. Structural equality, `=`, would try to compare
contents, which can include functions. Making an owner a proxy for itself would
create a cycle; the identity test prevents that, including when distinct proxy
records already lead to the same owner.

When both promises are pending, we preserve both lists of handlers in `p3`
before replacing `p2`'s contents with a proxy. The list concatenation preserves
order within each original list. Because `resolve` reverses the combined list,
this particular implementation runs the old `p3` handlers before the old `p2`
handlers.

Here is a trace using only the public interface:

```ocaml
let p1, r1 = make ()
let p2, r2 = make ()
let p3 = bind p1 (fun () -> p2)
```

Initially, all three promises are pending, and `p1` stores the handler that
captures the callback and `p3`'s resolver. Calling `fulfill r1 ()` runs that
handler. The callback returns the still-pending `p2`, so `link` makes `p2` a
proxy for `p3`. Both `state p2` and `state p3` still report `Pending`.

Next, calling `fulfill r2 42` follows the proxy from `p2` to `p3`, stores
`Fulfilled 42` there, and runs the handlers from both promises. Now both
`state p2` and `state p3` report `Fulfilled 42`. Calling `fulfill r2` again
would raise `Invalid_argument`, because the underlying promise is already
resolved. Rejection follows the same path, with an exception instead of a value.

## Completing Bind

Now we can put the three cases of `bind` together:

```ocaml
let bind (p1 : 'a promise) (f : 'a -> 'b promise) : 'b promise =
  match state p1 with
  | Fulfilled v1 -> (try f v1 with exc -> fail exc)
  | Rejected exc -> fail exc
  | Pending ->
      let p3, p3_resolver = make () in
      let h = make_handler f p3_resolver in
      enqueue h p1;
      p3
```

Using `state p1` ensures that `bind` also works when its input is a proxy. If the
input is already fulfilled, `bind` runs `f` immediately and returns the promise
that `f` returns. If `f` raises, `bind` returns a new rejected promise. If the
input is already rejected, `bind` propagates that rejection without running `f`.
Only the pending case needs a new pending promise and a stored handler.

We have developed a small promise implementation with handlers to remember work
and proxies to share outcomes. It illustrates the data structures behind
callback sequencing, while leaving out the scheduler, cancellation, and other
facilities of a production library. The next section collects the complete code
and demonstrates both immediate callback results and pending results that need
proxy linking.

```{warning}
Lwt makes a different choice than we did here when the input promise is already fulfilled and the callback raises an exception. In that case, Lwt has `bind` raise the exception itself, instead of returning a rejected promise that contains the exception. This is [known][lwt-bind-bug] to violate the specification of `bind` but is not going to be fixed for backward compatibility reasons.
```

[lwt-bind-bug]: https://discuss.ocaml.org/t/lwt-3-2-0-released-we-plan-to-change-lwt-bind/1337/13