# Promises

In Lwt, a *promise* is a write-once reference: a value that is permitted
to mutate at most once.  When created, it is like an empty box that
contains nothing.  We say that the promise is *pending*. Eventually the
promise can be *resolved*, which is like putting something inside the
box.  Instead of being resolved, the promise can instead be *rejected*,
in which case the box is filled with an exception. Regardless of whether
the promise is resolved or rejected, once the box is filled, its
contents may never change.

For now, we will mostly forget about concurrency.  Later we'll come back
and add incorporate it.  But there is one part of the design for
concurrency that we need to address now.  When we later start
using functions for OS-provided concurrency, such as concurrent
reads and writes from files, there will need to be a division
of responsibilities:

* The client code that wants to make use of concurrency will need
  to *access** promises: query whether they are resolved or pending,
  and make use of the resolved values.

* The library and OS code that implements concurrency will need
  to *mutate** the promise&mdash;that is, to actually resolve or reject it.
  Client code does not need that ability.
  
We therefore will introduce one additional abstraction called
a *resolver*.  There will be a one-to-one association between promises
and resolvers.  The resolver for a promise will be used internally
by the concurrency library but not revealed to clients.  The clients
will only get access to the promise.

For example, suppose the concurrency library supported a operation
to concurrently read a string from the network.  The library would 
implement that operation as follows:

* Create a new promise and its associated resolver.  The promise is
  pending.
  
* Call an OS function that will concurrently read the string then
  invoke the resolver on that string.
  
* Return the promise (but not resolver) to the client.  The OS
  meanwhile continues to work on reading the string.
  
You might think of the resolver as being a "private and writeable" value
used primarily by the library and the promise as being a "public and
read-only" value used primarily by the client.

## Making Our Own Promises

Here is an interface for our own Lwt-style promises.  The names have
been changed to make the interface clearer.
```
(** A signature for Lwt-style promises, with better names *)
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

end
```

To implement that interface, we can make the representation type of
of `'a promise` be a reference to a state:
```
type 'a promise = 'a state ref
```
That way it's possible to mutate the contents of the promise.

For the representation type of the resolver, we'll do something
a little clever.  It will simply be the same as a promise.
```
type 'a resolver = 'a promise
```
So internally, the two types are exactly the same.  But externally
no client of the `Promise` module will be able to distinguish them.
In other words, we're using the type system to control whether
it's possible to apply certain functions (e.g., `state` vs `resolve`)
to a promise.

To help implement the rest of the functions, let's start by
writing a helper function `update : 'a promise -> 'a state -> unit`
to update the reference.  This function will implement changing
the state of the promise from pending to either resolved or rejected,
and once the state has changed, it will not allow it to be changed
again.  In other words, `update` enforces the "write once" invariant.
```
(** [write_once p s] changes the state of [p] to be [s].  If [p] and [s]
    are both pending, that has no effect.
    Raises: [Invalid_arg] if the state of [p] is not pending. *)
let write_once p s = 
  if !p = Pending
  then p := s
  else invalid_arg "cannot write twice"
```

Using that helper, we can implement the `make` function:
```
let make () = 
  let p = ref Pending in
  p, p
```

The remaining functions in the interface are trivial to implement:
```
let return x = ref (Resolved x)
let state p = !p
let resolve r x = write_once r (Resolved x)
let reject r x = write_once r (Rejected x)  
```

## Lwt Promises

The types and names used in Lwt are a bit more obscure than those we
used above.  Lwt uses analogical terminology that comes from
threads&mdash;but since Lwt does not actually implement threads, that
terminology is not necessarily helpful. (We don't mean to demean Lwt!
It is a library that has been developing and changing over time.)

The Lwt interface includes the following declarations, which
we have annotated with comments to compare them to the interface
we implemented above:
```
module type Lwt = sig
  (* [Sleep] means pending.  [Return] means resolved.
     [Fail] means rejected. *)
  type 'a state = Sleep | Return of 'a | Fail of exn
  
  (* a [t] is a promise *)
  type 'a t
  
  (* a [u] is a resolver *)
  type 'a u

  val state : 'a t -> 'a state
  
  (* [wakeup] means [resolve] *)
  val wakeup : 'a u -> 'a -> unit
  
  (* [wakeup_exn] means [reject] *)
  val wakeup_exn : 'a u -> exn -> unit
  
  (* [wait] means [make] *)
  val wait : unit -> 'a t * 'a u
  
  val return : 'a -> 'a t
end
```

Lwt's implementation of that interface is much more complex
than our own implementation above, because Lwt actually supports
many more operations on promises.  Nonetheless, the core ideas
that we developed above provide sound intuition for what Lwt
implements.

Here is some example Lwt code that you can try out in utop:
```
# #require "lwt";;
# let p, r = Lwt.wait();;
val p : '_weak1 Lwt.t = <abstr>
val r : '_weak1 Lwt.u = <abstr>
```

The types you see there are *weakly polymorphic types*, as mentioned at
the end of [this section](ex_mutable_stack.html). We won't go into why
such types are necessary.  To avoid them, we can provide a further
hint to OCaml as to what type we want to eventually put into the promise.
For example, if we wanted to have a promise that will eventually contain
an `int`, we could write this code:
```
let (p : int Lwt.t), r = Lwt.wait ();;
val p : int Lwt.t = <abstr>
val r : int Lwt.u = <abstr>
```

Now we can resolve the promise:
```
# Lwt.state p;;
- : int Lwt.state = Lwt.Sleep

# Lwt.wakeup r 42;;
- : unit = ()

# Lwt.state p;;
- : int Lwt.state = Lwt.Return 42

# Lwt.wakeup r 42;;
Exception: Invalid_argument "Lwt.wakeup".
```

That last exception was raised because we attempted to resolve
the promise a second time, which is not permitted.

To reject a promise, we can write similar code:
```
# let (p : int Lwt.t), r = Lwt.wait ();;
val p : int Lwt.t = <abstr>
val r : int Lwt.u = <abstr>

# Lwt.wakeup_exn r (Failure "nope");;
- : unit = ()

# Lwt.state p;;
- : int Lwt.state = Lwt.Fail (Failure "nope")
```

Note that nothing we have implemented so far does anything concurrently.
The promise abstraction by itself is not inherently concurrent.  It's
just a data structure that can be written at most once, and that provides
a means to control who can write to it (through the resolver).
