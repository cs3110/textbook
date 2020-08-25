# Example:  Arithmetic

Here is a module type that represents values that support the usual operations from 
arithmetic, or more precisely, a *[field][]*:

[field]: https://en.wikipedia.org/wiki/Field_(mathematics)

```
module type Arith = sig
  type t
  val zero  : t
  val one   : t
  val (+)   : t -> t -> t
  val ( * ) : t -> t -> t
  val (~-)  : t -> t
end
```
There are a couple syntactic curiosities here.  We have to write `( * )` instead
of `(*)` because the latter would be parsed as beginning a comment.  And
we write the `~` in `(~-)` to indicate a *unary* negation operator.

Here is a module that implements that module type:
```
module Ints : Arith = struct
  type t    = int
  let zero  = 0
  let one   = 1
  let (+)   = Stdlib.(+)
  let ( * ) = Stdlib.( * )
  let (~-)  = Stdlib.(~-)
end
```

Outside of the module `Ints`, the expression `Ints.(one + one)` is perfectly fine,
but `Ints.(1 + 1)` is not, because `t` is abstract:  outside the module no one
is permitted to know that `t = int`.  In fact, the toplevel can't even give us
good output about what the sum of one and one is!
```
# Ints.(one + one);;
- : Ints.t = <abstr>
```

The reason why is that the type `Ints.t` is abstract: the module type doesn't
tell use that `Ints.t` is `int`.  This is actually a good thing in many cases:
code outside of `Ints` can't rely on the internal implementation details of
`Ints`, and so we are free to change it. 
Since the `Arith` interface only has functions that return `t`, so once you
have a value of type `t`, all you can do is create other values of type `t`.

When designing an interface with an abstract type, you will almost certainly
want at least one function that returns something other than that type.
For example, it's often useful to provide a `to_string` function.  We could 
add that to the `Arith` module type:
```
module type Arith = sig
  (* everything else as before, and... *)
  val to_string : t -> string
end
```
And now we would need to implement it as part of `Ints`:
```
module Ints : Arith = struct
  (* everything else as before, and... *)
  let to_string = string_of_int
end
```
Now we can write:
```
# Ints.(to_string (one + one));;
- : string = "2"
```
