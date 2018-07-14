# Compilation Units

A *compilation unit* is a pair of OCaml source files in the same
directory. They share the same base name, call it `x`, but their
extensions differ: one file is `x.ml`, the other is `x.mli`. The file
`x.ml` is called the *implementation*, and `x.mli` is called the
*interface*.

For example, suppose that `foo.mli` contains exactly the following:
```
val x : int
val f : int -> int -> int
```
and `foo.ml`, in the same directory, contains exactly the following:
```
let x = 0
let y = 12
let f x y = x + y
```
Then compiling `foo.ml` will have the same effect as defining the module
`Foo` as follows:

```
module Foo : sig
  val x : int
  val f : int -> int -> int
end = struct
  let x = 0
  let y = 12
  let f x y = x + y
end
```

In general, when the compiler encounters a compilation unit, it treats
them as defining a module and a signature like this:
```
module Foo : sig (* insert contents of foo.mli here *) end = struct
  (* insert contents of foo.ml here *)
end
```
The *unit name* `Foo` is derived from the base name `foo` by just capitalizing
the first letter.  Notice that there is no named module type being defined;
the signature of `Foo` is actually anonymous.

The standard library uses compilation units to implement
most of the modules you have been using so far, like `List` and
`String`.  You can see that in the [standard library source
code][stdlibsrc].

[stdlibsrc]: https://github.com/ocaml/ocaml/tree/trunk/stdlib

## Comments

The comments that go in an interface file vs. an implementation
file are different.  Interface files will be read by clients of an abstraction,
so the comments that go there are for them.  These will generally be specification
comments describing how to use the abstraction, the preconditions for 
calling its functions, what exceptions they might raise, and perhaps some
notes on what algorithms are used to implement operations.  The standard library's
List module contains many examples of these kinds of comments.

Implementation files will be read by programmers and maintainers of an
abstraction, so the comments that go there are for them.  These will be
comments about how the representation type is used, how the code works,
important internal invariants it maintains, and so forth.  

## An Example with Stacks

You could put this code in `mystack.mli` (notice that there is no
`sig..end` around it or any `module type`):
```
type 'a t
val empty : 'a t
val is_empty : 'a t -> bool
val push : 'a -> 'a t -> 'a t
val peek : 'a t -> 'a
val pop : 'a t -> 'a t
```
and this code in `mystack.ml` (notice that there is no `struct..end`
around it or any `module`):
```
type 'a t = 'a list

let empty = []
let is_empty s = (s = [])

let push x s = x :: s

let peek = function
  | [] -> failwith "Empty"
  | x::_ -> x

let pop = function
  | [] -> failwith "Empty"
  | _::xs -> xs
```
then from the command-line compile that source code (note that all we
need is the `.cmo` file so we request it to be built instead of the `.byte` file):
```
$ ocamlbuild mystack.cmo
```
and launch utop and load your compilation unit for use:
```
# #directory "_build";;
# #load "mystack.cmo";;
# Mystack.empty;;
- : 'a Mystack.t = <abstr>
```

Note that we called this "mystack" because the standard library already
has a `Stack` module, so re-using that name could lead to error messages
that are somewhat hard to understand.
