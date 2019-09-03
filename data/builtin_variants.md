# Built-in Variants

## Lists
OCaml's built-in list data type is really a recursive, parameterized
variant.  It is defined as follows:
```
type 'a list = [] | :: of 'a * 'a list
```
So `list` is really just a type constructor, with (value) constructors
`[]` (which we pronounce "nil") and `::` (which we pronounce "cons").
The only reason you can't write that definition yourself in your own
code is that the compiler restricts you to constructor names that begin
with initial capital letters and that don't contain any punctuation
(other than `_` and `'`).

## Options
OCaml's built-in option data type is really a parameterized
variant.  It's defined as follows:
```
type 'a option = None | Some of 'a 
```
So `option` is really just a type constructor, with (value) constructors
`None` and `Some`.
You can see both `list` and `option` defined in the [core OCaml library][core].

[core]: http://caml.inria.fr/pub/docs/manual-ocaml/core.html