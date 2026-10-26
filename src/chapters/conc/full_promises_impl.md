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

# The Full Promises Implementation

Here is the complete implementation from the previous section, with the
helpers in dependency order. The public interface exposes three states, whereas
proxy links and handler lists remain private to the module.

```{code-cell} ocaml
(** A signature for Lwt-style promises, with better names. *)
module type PROMISE = sig
  type 'a state =
    | Pending
    | Fulfilled of 'a
    | Rejected of exn

  type 'a promise
  type 'a resolver

  val make : unit -> 'a promise * 'a resolver
  (** [make ()] is a new promise and resolver. The promise
      is pending. *)

  val state : 'a promise -> 'a state
  (** [state p] is the state of the promise *)

  val fulfill : 'a resolver -> 'a -> unit
  (** [fulfill r x] resolves the promise [p] associated with
      [r] with value [x], meaning that [state p] will become
      [Fulfilled x]. Requires: [p] is pending. *)

  val reject : 'a resolver -> exn -> unit
  (** [reject r x] rejects the promise [p] associated with
      [r] with exception [x], meaning that [state p] will
      become [Rejected x]. Requires: [p] is pending. *)

  val return : 'a -> 'a promise
  (** [return x] is a new promise that is already fulfilled
      with value [x]. *)

  val bind : 'a promise -> ('a -> 'b promise) -> 'b promise
  (** [bind p f] registers callback [f] with promise [p].
      When the promise is fulfilled, the callback will be
      run on the promise's contents. If the promise is never
      fulfilled, the callback will never run. *)
end

module Promise : PROMISE = struct
  type 'a state =
    | Pending
    | Fulfilled of 'a
    | Rejected of exn

  type 'a handler = ('a, exn) result -> unit
  (** Handlers receive the resolved outcome: [Ok v] for
      fulfillment or [Error e] for rejection. The type
      excludes a pending state. *)

  type 'a promise = { mutable contents : 'a contents }
  (** AF: follow any [Proxy] links to find the promise's
      observable state. A proxy and its target represent the
      same outcome.

      RI: proxy links contain no cycles. Only pending
      promises can store handlers; the type enforces that. *)

  and 'a contents =
    | Pending of 'a handler list
    | Fulfilled of 'a
    | Rejected of exn
    | Proxy of 'a promise

  type 'a resolver = 'a promise

  (** [underlying p] follows proxy links to the promise that
      owns the state. *)
  let rec underlying (p : 'a promise) : 'a promise =
    match p.contents with
    | Proxy p' -> underlying p'
    | Pending _ | Fulfilled _ | Rejected _ -> p

  (** Requires: the underlying promise is pending. *)
  let enqueue (h : 'a handler) (p : 'a promise) : unit =
    let p = underlying p in
    match p.contents with
    | Pending hs -> p.contents <- Pending (h :: hs)
    | Fulfilled _ | Rejected _ ->
        invalid_arg "Cannot enqueue on a resolved promise"
    | Proxy _ -> assert false

  let make () =
    let p = { contents = Pending [] } in
    (p, p)

  let state (p : 'a promise) : 'a state =
    match (underlying p).contents with
    | Pending _ -> Pending
    | Fulfilled v -> Fulfilled v
    | Rejected e -> Rejected e
    | Proxy _ -> assert false

  (** [resolve r outcome] resolves the underlying promise
      with [outcome], then passes that outcome to its
      handlers. Raises: [Invalid_arg] if the underlying
      promise is already resolved. *)
  let resolve (r : 'a resolver) (outcome : ('a, exn) result)
      =
    (* A resolver created before its promise became a proxy
       still works: it follows the link to the new owner. *)
    let r = underlying r in
    let contents : 'a contents =
      match outcome with
      | Ok v -> Fulfilled v
      | Error e -> Rejected e
    in
    match r.contents with
    | Pending hs ->
        (* Replacing Pending also removes the stored
           handlers, so save them locally as [hs]. Set the
           state first so every handler sees the same
           resolved outcome through every proxy. *)
        r.contents <- contents;
        List.iter (fun h -> h outcome) (List.rev hs)
    | Fulfilled _ | Rejected _ ->
        invalid_arg "Already resolved"
    | Proxy _ -> assert false

  let reject r x = resolve r (Error x)
  let fulfill r x = resolve r (Ok x)
  let return x = { contents = Fulfilled x }

  (** [fail exc] is a new promise already rejected with
      exception [exc]. *)
  let fail exc = { contents = Rejected exc }

  (** [link p2 p3] makes [p3] share [p2]'s outcome.
      Requires: the underlying promise of [p3] is pending.
      If [p2] is pending too, make it a proxy for [p3].
      Otherwise, immediately resolve [p3]. *)
  let link (p2 : 'a promise) (p3 : 'a promise) : unit =
    let p2 = underlying p2 in
    let p3 = underlying p3 in
    (* Compare record identity, not structural equality.
       Linking an underlying promise to itself would create
       a cycle. If they already share an owner, do
       nothing. *)
    if p2 == p3 then ()
    else
      match (p2.contents, p3.contents) with
      | Pending hs2, Pending hs3 ->
          (* Preserve handlers registered on either promise.
             Each list retains its own registration order;
             the interface promises no order between lists.
             Replacing p2's contents removes its old
             list. *)
          p3.contents <- Pending (hs2 @ hs3);
          p2.contents <- Proxy p3
      | Fulfilled v, Pending _ -> fulfill p3 v
      | Rejected e, Pending _ -> reject p3 e
      | _, (Fulfilled _ | Rejected _) ->
          invalid_arg "Cannot link into a resolved promise"
      | Proxy _, _ | _, Proxy _ -> assert false

  (** [make_handler] creates a handler that helps to
      implement [bind]. Suppose that [bind p1 f] is called
      and returns [p3], and that [r] is the resolver
      associated with [p3]. Then [make_handler f r] is the
      handler that will be enqueued on [p1] and therefore
      will run after [p1] is resolved. That handler's job is
      to then resolve or link [p3] based on what happened
      with [p1]. *)
  let make_handler (f : 'a -> 'b promise) (r : 'b resolver)
      : 'a handler = function
    | Error exc ->
        (* If [p1] was rejected, then reject [p3] with the
           same exception.*)
        reject r exc
    | Ok v1 ->
        (* Catch exceptions from f itself, then link outside
           the try. A pending p2 becomes a proxy for p3. *)
        let p2 = try f v1 with e -> fail e in
        link p2 r

  let bind (p1 : 'a promise) (f : 'a -> 'b promise) :
      'b promise =
    (* The public accessor follows proxy links. If p1 is
       already fulfilled, run f immediately. Otherwise,
       either propagate rejection or register a handler. *)
    match state p1 with
    | Fulfilled v1 ->
        (* If [p1] is already fulfilled, immediately run the
           callback. *)
        begin try
          (* If [f v1] returns a promise, then return the
             same promise from [bind]. *)
          f v1
        with exc ->
          (* But if [f v1] raised an exception, immediately
             return a new rejected promise with that
             exception. *)
          fail exc
        end
    | Rejected exc ->
        (* If [p1] is already rejected, immediately return a
           rejected promise with the same exception. *)
        fail exc
    | Pending ->
        (* If [p1] is not resolved, then [bind] needs to
           immediately return a new promise [p3]. That is
           what we saw in the slides. Create that promise
           and its resolver. *)
        let p3, p3_resolver = make () in

        (* Create a handler to run after [p1] is resolved.
           The handler will use callback [f] to determine
           how to resolve [p3]. *)
        let h = make_handler f p3_resolver in

        (* Enqueue the handler on [p1]. This is what the
           slides meant by "schedule callback [f] to run on
           [p1] and put the result in [p3]." *)
        enqueue h p1;

        (* Return pending promise [p3]. *)
        p3
end
```

## Trying the Implementation

The first demo, below, registers a callback on a pending promise. Fulfilling
that promise runs the callback before `fulfill` returns. The callback returns
an already fulfilled promise, so the promise returned by `bind` is fulfilled
immediately too.

The second demo returns a *pending* promise from the callback. It registers
handlers on both that promise and the promise returned by `bind`, then links
them. Resolving through the original resolver runs both sets of handlers and
makes both promises report the same value.

```{code-cell} ocaml
module Demo = struct
  open Promise

  let printf = Printf.printf

  let demo () =
    let p1, r1 = make () in
    printf "p1 created\n";
    let p2 =
      bind p1 (fun x ->
          printf "Callback running with %d\n" x;
          return (x + 1))
    in
    printf "Callback on p1 was bound\n";
    printf "About to fulfill p1\n";
    fulfill r1 42;
    printf "p1 fulfilled\n";
    match state p2 with
    | Fulfilled v -> printf "p2 fulfilled with %d\n" v
    | _ -> printf "p2 not fulfilled\n"

  (** Unlike [demo], this example returns a pending promise
      from the callback, so it exercises proxy linking. *)
  let proxy_demo () =
    let p1, r1 = make () in
    let p2, r2 = make () in
    let p3 = bind p1 (fun () -> p2) in

    (* Both promises can have handlers before linking. *)
    let _ =
      bind p2 (fun x ->
          printf "Handler registered on p2 sees %d\n" x;
          return ())
    in
    let _ =
      bind p3 (fun x ->
          printf "Handler registered on p3 sees %d\n" x;
          return ())
    in

    (* Running p1's callback makes p2 a proxy for p3 and
       transfers p2's handlers to p3. Both remain
       pending. *)
    fulfill r1 ();
    printf "p2 and p3 are linked and still pending\n";

    (* The original resolver follows p2's proxy link. It
       resolves p3 and runs both sets of handlers. *)
    fulfill r2 42;
    match (state p2, state p3) with
    | Fulfilled x, Fulfilled y ->
        printf "p2 has %d; p3 has %d\n" x y
    | _ -> assert false
end
```

```{code-cell} ocaml
Demo.demo ();
flush stdout
```

```{code-cell} ocaml
Demo.proxy_demo ();
flush stdout
```
