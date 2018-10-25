module type Promise = sig

  type 'a state = Pending | Resolved of 'a | Rejected of exn
  type 'a promise
  type 'a resolver

  (** [make ()] is a new promise and resolver. The promise is pending. *)
  val make : unit -> 'a promise * 'a resolver

  (** [return x] is a new promise that is already resolved with value [x]. *)
  val return : 'a -> 'a promise

  (** [state p] is the state of the promise *)
  val state : 'a promise -> 'a state

  (** [resolve r x] resolves the promise [p] associated with [r]
      with value [x], meaning that [state p] will become 
      [Resolved x].
      Requires:  [p] is pending. *)
  val resolve : 'a resolver -> 'a -> unit

  (** [reject r x] rejects the promise [p] associated with [r]
      with exception [x], meaning that [state p] will become
      [Rejected x].
      Requires:  [p] is pending. *)
  val reject : 'a resolver -> exn -> unit

  (** [p >>= c] registers callback [c] with promise [p]. 
      When the promise is resolved, the callback will be run
      on the promises's contents.  If the promise is never
      resolved, the callback will never run. *)
  val (>>=) : 'a promise -> ('a -> 'b promise) -> 'b promise
end

module Promise : Promise = struct
  type 'a state = Pending | Resolved of 'a | Rejected of exn

  (* RI: if [state <> Pending] then [callbacks = []]. *)
  type 'a promise = {
    mutable state : 'a state;
    mutable callbacks : ('a -> unit) list
  }

  type 'a resolver = 'a promise

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

  let reject r x = 
    write_once r (Rejected x);
    r.callbacks <- []

  let run_callbacks callbacks x = 
    List.iter (fun f -> f x) callbacks

  let resolve r x =  
    write_once r (Resolved x);
    let callbacks = r.callbacks in
    r.callbacks <- [];
    run_callbacks callbacks x

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
end