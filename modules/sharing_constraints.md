# Sharing Constraints

Sometimes you actually want to expose the type in an implementation of a
module.  You might like to say "the module `Ints` implements `Arith` and the
type `t` is `int`," and allow external users of the `Ints` module to use the
fact that `Ints.t` is `int`.

OCaml lets you write *sharing constraints* that refine a signature by specifying
equations that must hold on the abstract types in that signature.  If `T` is a module type containing an
abstract type `t`, then `T with type t = int` is a new module type that is the
same as `T`, except that `t` is known to be `int`.  For example, we could write:
```
module Ints : (Arith with type t = int) = struct
  (* all of Ints as before *)
end
```
Now both `Ints.(one + one)` and `Ints.(1 + 1)` are legal.

We don't have to specify the sharing constraint in the original definition of the
module.  We can create a structure, bind it to a module name, then bind it
to another module name with its types being either abstract or exposed:

```
module Ints = struct
  type t    = int
  let zero  = 0
  let one   = 1
  let (+)   = Stdlib.(+)
  let ( * ) = Stdlib.( * )
  let (~-)  = Stdlib.(~-)
end

module IntsAbstracted : Arith = Ints
(* IntsAbstracted.(1 + 1) is illegal *)

module IntsExposed : (Arith with type t = int) = Ints
(* IntsExposed.(1 + 1) is legal *)
```

This can be a useful technique for testing purposes: provide one name for a module
that clients use in which the types are abstract, and provide another name
that implementers use for testing in which the types are exposed.
