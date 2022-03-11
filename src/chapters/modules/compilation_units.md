# Compilation Units

{{ video_embed | replace("%%VID%%", "hjZ8FvMUw2k")}}

A *compilation unit* is a pair of OCaml source files in the same
directory. They share the same base name, call it `x`, but their
extensions differ: one file is `x.ml`, the other is `x.mli`. The file
`x.ml` is called the *implementation*, and `x.mli` is called the
*interface*.

For example, suppose that `foo.mli` contains exactly the following:

```ocaml
val x : int
val f : int -> int
```

and `foo.ml`, in the same directory, contains exactly the following:

```ocaml
let x = 0
let y = 12
let f x = x + y
```

Then compiling `foo.ml` will have the same effect as defining the module
`Foo` as follows:

```ocaml
module Foo : sig
  val x : int
  val f : int -> int
end = struct
  let x = 0
  let y = 12
  let f x = x + y
end
```

In general, when the compiler encounters a compilation unit, it treats it as
defining a module and a signature like this:

```ocaml
module Foo
  : sig (* insert contents of foo.mli here *) end
= struct
  (* insert contents of foo.ml here *)
end
```

The *unit name* `Foo` is derived from the base name `foo` by just capitalizing
the first letter. Notice that there is no named module type being defined; the
signature of `Foo` is actually anonymous.

The standard library uses compilation units to implement most of the modules we
have been using so far, like `List` and `String`. You can see that in the
[standard library source code][stdlibsrc].

[stdlibsrc]: https://github.com/ocaml/ocaml/tree/trunk/stdlib

## Documentation Comments

Some documentation comments belong in the interface file, whereas others belong
in the implementation file:

- Clients of an abstraction can be expected to read interface files, or rather
  the HTML documentation generated from them. So the comments in an interface
  file should be written with that audience in mind. These comments should
  describe how to use the abstraction, the preconditions for calling its
  functions, what exceptions they might raise, and perhaps some notes on what
  algorithms are used to implement operations. The standard library's `List`
  module contains many examples of these kinds of comments.

- Clients should not be expected to read implementation files. Those files will
  be read by creators and maintainers of the implementation. The documentation
  in the implementation file should provide information that explains the
  internal details of the abstraction, such as how the representation type is
  used, how the code works, important internal invariants it maintains, and so
  forth.  Maintainers can also be expected to read the specifications in the
  interface files.

Documentation should **not** be duplicated between the files. In particular, the
client-facing specification comments in the interface file should not be
duplicated in the implementation file. One reason is that duplication inevitably
leads to errors. Another reason is that OCamldoc has the ability to
automatically inject the comments from the interface file into the generated
HTML from the implementation file.

OCamldoc comments can be placed either before or after an element of the
interface. For example, both of these placements are possible:

```ocaml
(** The mathematical constant 3.14... *)
val pi : float
```

```ocaml
val pi : float
(** The mathematical constant 3.14... *)
```

```{tip}
The standard library developers apparently prefer the post-placement of the
comment, and OCamlFormat seems to work better with that, too.
```

## An Example with Stacks

Put this code in `mystack.mli`, noting that there is no `sig..end` around it or
any `module type`:

```ocaml
type 'a t
exception Empty
val empty : 'a t
val is_empty : 'a t -> bool
val push : 'a -> 'a t -> 'a t
val peek : 'a t -> 'a
val pop : 'a t -> 'a t
```

We're using the name "mystack" because the standard library already has a
`Stack` module. Re-using that name could lead to error messages that are
somewhat hard to understand.

Also put this code in `mystack.ml`, nothing that there is no `struct..end`
around it or any `module`:

```ocaml
type 'a t = 'a list
exception Empty
let empty = []
let is_empty = function [] -> true | _ -> false
let push = List.cons
let peek = function [] -> raise Empty | x :: _ -> x
let pop = function [] -> raise Empty | _ :: s -> s
```

Create a dune file:

```text
(library
 (name mystack))
```

Compile the code and launch utop:

```console
$ dune utop
```

Your compilation unit is ready for use:

```ocaml
# Mystack.empty;;
- : 'a Mystack.t = <abstr>
```

## Incomplete Compilation Units

What if either the interface or implementation file is missing for a compilation
unit?

**Missing Interface Files.** Actually this is exactly how we've normally been
working up until this point. For example, you might have done some homework in a
file named `lab1.ml` but never needed to worry about `lab1.mli`. There is no
requirement that every `.ml` file have a corresponding `.mli` file, or in other
words, that every compilation unit be complete.

If the `.mli` file is missing there is still a module that is created, as we saw
back when we learned about `#load` and modules. It just doesn't have an
automatically imposed signature. For example, the situation with `lab1` above
would lead to the following module being created during compilation:

```ocaml
module Lab1 = struct
  (* insert contents of lab1.ml here *)
end
```

**Missing Implementation Files.** This case is much rarer, and not one you are
likely to encounter in everyday development. But be aware that there is a
**misuse** case that Java or C++ programmers sometimes accidentally fall into.
Suppose you have an interface for which there will be a few implementation.
Thinking back to stacks earlier in this chapter, perhaps you have a module type
`Stack` and two modules that implement it, `ListStack` and `CustomStack`:

```ocaml
module type Stack = sig
  type 'a t
  val empty : 'a t
  val push : 'a -> 'a t -> 'a t
  (* etc. *)
end

module type ListStack : Stack = struct
  type 'a t = 'a list
  let empty = []
  let push = List.cons
  (* etc. *)
end

module type CustomStack : Stack = struct
  (* omitted *)
end
```

It's tempting to divide that code up into files as follows:

```ocaml
(********************************)
(* stack.mli *)
type 'a t
val empty : 'a t
val push : 'a -> 'a t -> 'a t
(* etc. *)

(********************************)
(* listStack.ml *)
type 'a t = 'a list
let empty = []
let push = List.cons
(* etc. *)

(********************************)
(* customStack.ml *)
(* omitted *)
```

The reason it's tempting is that in Java you might put the `Stack` interface
into a `Stack.java` file, the `ListStack` class in a `ListStack.java` file, and
so forth. In C++ something similar might be done with `.hpp` and `.cpp` files.

But the OCaml file organization shown above just won't work. To be a compilation
unit, the interface for `listStack.ml` **must** be in `listStack.mli`. It can't
be in a file with any other name.  So there's no way with that code division
to stipulate that `ListStack : Stack`.

Instead, the code could be divided like this:

```ocaml
(********************************)
(* stack.ml *)
module type S = sig
  type 'a t
  val empty : 'a t
  val push : 'a -> 'a t -> 'a t
  (* etc. *)
end

(********************************)
(* listStack.ml *)
module M : Stack.S = struct
  type 'a t = 'a list
  let empty = []
  let push = List.cons
  (* etc. *)
end

(********************************)
(* customStack.ml *)
module M : Stack.S = struct
  (* omitted *)
end
```

Note the following about that division:

- The module type goes in a `.ml` file not a `.mli`, because we're not
  trying to create a compilation unit.

- We give short names to the modules and module types in the files, because they
  will already be inside a module based on their filename. It would be rather
  verbose, for example, to name `S` something longer like `Stack`. If we did,
  we'd have to write `Stack.Stack` in the module type annotations instead of
  `Stack.S`.

Another possibility for code division would be to put all the code in a single
file `stack.ml`. That works if all the code is part of the same library, but not
if (e.g.) `ListStack` and `CustomStack` are developed by separate organizations.
If it is in a single file, then we could turn it into a compilation unit:

```ocaml
(********************************)
(* stack.mli *)
module type S = sig
  type 'a t
  val empty : 'a t
  val push : 'a -> 'a t -> 'a t
  (* etc. *)
end

module ListStack : S

module CustomStack : S

(********************************)
(* stack.ml *)
module type S = sig
  type 'a t
  val empty : 'a t
  val push : 'a -> 'a t -> 'a t
  (* etc. *)
end

module ListStack : S = struct
  type 'a t = 'a list
  let empty = []
  let push = List.cons
  (* etc. *)
end

module CustomStack : S = struct
  (* omitted *)
end
```

Unfortunately that does mean we've duplicated `Stack.S` in both the interface
and implementation files. There's no way to automatically "import" an already
declared module type from a `.mli` file into the corresponding `.ml` file.

Code duplication naturally makes us unhappy. Later, with functors, we'll see
how to eliminate it.
