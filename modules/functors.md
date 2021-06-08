# Functors

The problem we were having in the previous section was that we wanted
to add code to two different modules, but that code needed to 
be parameterized on the details of the module to which it was being 
added.  It's that kind of parameterization that is enabled by
an OCaml language feature called *functors*.

The name is perhaps a bit intimidating, but **a functor is simply a
"function" from structures to structures.**  The word "function" is in
quotation marks in that sentence only because it's a kind of function
that's not interchangeable with the rest of the functions we've already
seen.  OCaml is *stratified*:  structures are distinct from values, so
functions from structures to structures cannot be written or used in the
same way as functions from values to values. But conceptually, functors
really are just functions.

As an example, let's first write a simple signature; there's nothing new here:
```
module type X = sig
  val x : int
end
```

Now, using that signature, here's a tiny example of a functor:
```
module IncX (M: X) = struct
  let x = M.x + 1
end
```
The functor's name is `IncX`.  It's a function from structures to structures.
As a function, it takes an input and produces an output.  Its input
is named `M`, and the type of its input is `X`.  Its output
is the structure that appears on the right-hand side of the equals sign:
`struct let x = M.x + 1`.

Another way to think about `IncX` is that it's a *parameterized structure*.
The parameter that it takes is named `M` and has type `X`.  The structure itself
has a single value named `x` in it.  The value that `x` has will depend
on the parameter `M`.

Since functors are functions, we *apply* them.  Here's an example of applying
`IncX`:
```
# module A = struct let x = 0 end
# A.x
- : int = 0

# module B = IncX(A)
# B.x
- : int = 1

# module C = IncX(B)
# C.x
- : int = 2
```
Each time, we pass `IncX` a structure.  When we pass it the structure bound
to the name `A`, the input to `IncX` is `struct let x = 0 end`.  `IncX`
takes that input and produces an output `struct let x = A.x + 1 end`.
Since `A.x` is `0`, the result is `struct let x = 1 end`.  So `B`
is bound to `struct let x = 1 end`.  Similarly, `C` ends up being
bound to `struct let x = 2 end`.

Although the functor `IncX` returns a structure that is quite similar to
its input structure, that need not be the case.  In fact, a functor can
return any structure it likes, perhaps something very different than its
input structure:
```
module MakeY (M:X) = struct
  let y = 42
end
```
The structure returned by `MakeY` has a value named `y` but does not
have any value named `x`.  In fact, `MakeY` completely ignores its
input structure.

**Why "functor"?** In [category theory][intellectualterrorism], a *category*
contains *morphisms*, which are a generalization of functions as we 
known them, and a *functor* is map between categories.  Likewise, OCaml
structures contain functions, and OCaml functors map from structures
to structures.  For more information about category theory,
take CS 6117.

[intellectualterrorism]: https://en.wikipedia.org/wiki/Category_theory

