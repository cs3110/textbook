# Example: The Lwt Monad

By now, it's probably obvious that the Lwt promises library that we discussed 
is also a monad.  The type `'a Lwt.t` of promises has a `return` and `bind`
operation of the right types to be a monad:
```
module type Lwt : Monad
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
```
And `Lwt.Infix.( >>= )` is a synonym for `Lwt.bind`, so the library
does provide an infix bind operator.

Now we start to see some of the great power of the monad design pattern.
The implementation of `'a t` and `return` that we saw before involves
creating references, but those references are completely hidden
behind the monadic interface.  Moreover, we know that `bind` involves
registering callbacks, but that functionality (which as you might imagine
involves maintaining collections of callbacks) is entirely encapsulated.

Metaphorically, as we discussed before, the box involved here is one
that starts out empty but eventually will be filled with a value of type `'a`.
The "something more" in these computations is that values are being
produced asynchronously, rather than immediately.

