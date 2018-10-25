# Implementing Callbacks

When a callback is registered with `bind` or one of the other syntaxes,
it is added to a list of callbacks that is stored with the promise.
Eventually, when the promise has been resolved, the Lwt *resolution
loop* runs the callbacks registered for the promise.  There is no
guarantee about the execution order of callbacks for a promise.  In
other words, the execution order is nondeterministic. If the order
matters, the programmer needs to use the composition operators (such as
`bind` and `join`) to enforce an ordering.  If the promise never becomes
resolved (or is rejected), none of its callbacks will ever be run.

Once again, it's important to keep track of where the concurrency really
comes from: the OS.  There might be many asynchronous I/O operations
occurring at the OS level.  But at the OCaml level, the resolution loop
is sequential, meaning that only one callback can ever be running
at a time.  

Finally, the resolution loop never attempts to interrupt a callback.
So if the callback goes into an infinite loop, no other callback will
ever get to run.  That makes Lwt a cooperative concurrency mechanism,
rather than preemptive.

## Our Own Callbacks

To better understand callback resolution, let's implement it ourselves.
We'll use the `Promise` data structure we developed earlier.
To start, we add a bind operator to the `Promise` signature:

```
module type Promise = sig 
  ...
  
  (** [p >>= c] registers callback [c] with promise [p]. 
      When the promise is resolved, the callback will be run
      on the promises's contents.  If the promise is never
      resolved, the callback will never run. *)
  val (>>=) : 'a promise -> ('a -> 'b promise) -> 'b promise
end
```

Next, let's re-develop the entire `Promise` structure.  We start
off just like before:

```
module Promise : Promise = struct
  type 'a state = Pending | Resolved of 'a | Rejected of exn
  ...
```

But now to implement the representation type of promises, we use
a record with mutable fields.  The first field is that state
of the promise, and it corresponds to the `ref` we used before.
The second field is a list of callbacks that have been
registered for the promise.  As a representation invariant,
we require that only pending promises may have callbacks waiting
in their list.  Once the state becomes non-pending, i.e., either
resolved or rejected, the callbacks will all be processed and 
removed from the list.
```
  (* RI: if [state <> Pending] then [callbacks = []]. *)
  type 'a promise = {
    mutable state : 'a state;
    mutable callbacks : ('a -> unit) list
  }

  type 'a resolver = 'a promise
```

Because we changed the representation type from a `ref` to a record,
we have to update a few of the functions in trivial ways:
```
  (** [write_once p s] changes the state of [p] to be [s].  If [p] and [s]
      are both pending, that has no effect.
      Raises: [Invalid_arg] if the state of [p] is not pending. *)
  let write_once p s = 
    if p.state = Pending
    then p.state <- s
    else invalid_arg "cannot write twice"

  let make () = 
    let p = {state = Pending; callbacks = []} in
    p, p

  let return x = 
    {state = Resolved x; callbacks = []}

  let state p = p.state
```

Now we get to the trickier parts of the implementation.  To resolve
or reject a promise, the first thing we need to do is to call
`write_once` on it, as we did before.  Now we also need
to process the callbacks.  If the promise is being rejected,
then none of the callbacks are called, so we can simply
mutate the callback list to be empty:
```
  let reject r x = 
    write_once r (Rejected x);
    r.callbacks <- []
```

But if the promise is being resolved, we need to mutate the list 
to be empty, then invoke each of the callbacks on the newly
resolved contents of the promise:
```
  let run_callbacks callbacks x = 
    List.iter (fun f -> f x) callbacks
      
  let resolve r x =  
    write_once r (Resolved x);
    let callbacks = r.callbacks in
    r.callbacks <- [];
    run_callbacks callbacks x
```

Finally, the implementation of `>>=` is the trickiest part.
First, if the promise is already resolved, let's go ahead
and immediately run the callback on it:
```
  let (>>=) (p : 'a promise) (c : 'a -> 'b promise) : 'b promise = 
    match p.state with
    | Resolved x -> c x
```
Second, if the promise is already rejected, then we return a promise
that is rejected with the same exception:
```
    | Rejected x -> {state = Rejected x; callbacks = []}
```
Third, if the promise is pending, we need to do more work.
We create a new promise and resolver called `bind_promise` and
`bind_resolver`.  That promise is what `bind` will return.
```
    | Pending -> 
      let bind_promise, bind_resolver = make () in
```
Next we create a function `f` that `Promise.resolve` will later call
to run the callback `c`.  Function `f` will receive the resolved or rejected
contents of `p` as input, then run the appropriate runction on `bind_resolver`
to handle those contents.  We add `f` to the list of callbacks associated
with `p`:
```
      let f (x : 'a) : unit = 
        let callback_promise = c x in
        match callback_promise.state with
        | Resolved x -> resolve bind_resolver x
        | Rejected x -> reject bind_resolver x
        | Pending -> failwith "impossible"
      in
      p.callbacks <- f :: p.callbacks;
```
Finally, we return the promise that we created earlier:
```
      bind_promise
end
```

The complete implementation of `>>=` is thus
```
  let (>>=) (p : 'a promise) (c : 'a -> 'b promise) : 'b promise = 
    match p.state with
    | Resolved x -> c x
    | Rejected x -> {state = Rejected x; callbacks = []}
    | Pending -> 
      let bind_promise, bind_resolver = make () in
      let f x : unit = 
        let callback_promise = c x in
        match callback_promise.state with
        | Resolved x -> resolve bind_resolver x
        | Rejected x -> reject bind_resolver x
        | Pending -> failwith "impossible"
      in
      p.callbacks <- f :: p.callbacks;
      bind_promise
```

The Lwt implementation of `bind` follows essentially the same algorithm as 
we just implemented.  Note that there is no concurrency in `bind`: as
we said above, everything in Lwt is sequential; it's the OS that provides
the concurrency.
