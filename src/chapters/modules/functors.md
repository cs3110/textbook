---
jupytext:
  cell_metadata_filter: -all
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.10.3
kernelspec:
  display_name: OCaml
  language: OCaml
  name: ocaml-jupyter
---

# Functors

{{ video_embed | replace("%%VID%%", "CLi5RmgQ9Mg")}}

The problem we were having in the previous section was that we wanted to add
code to two different modules, but that code needed to be parameterized on the
details of the module to which it was being added. It's that kind of
parameterization that is enabled by an OCaml language feature called *functors*.

```{note}
**Why the name "functor"?** In [category theory][intellectualterrorism], a
*category* contains *morphisms*, which are a generalization of functions as we
known them, and a *functor* is map between categories. Likewise, OCaml modules
contain functions, and OCaml functors map from modules to modules.
```

[intellectualterrorism]: https://en.wikipedia.org/wiki/Category_theory

The name is unfortunately intimidating, but **a functor is simply a "function"
from modules to modules.** The word "function" is in quotation marks in that
sentence only because it's a kind of function that's not interchangeable with
the rest of the functions we've already seen. OCaml's type system is
*stratified*: module values are distinct from other values, so functions from
modules to modules cannot be written or used in the same way as functions from
values to values. But conceptually, functors really are just functions.

Here's a tiny example of a functor:

```{code-cell} ocaml
module type X = sig
  val x : int
end

module IncX (M : X) = struct
  let x = M.x + 1
end
```

The functor's name is `IncX`. It's essentially a function from modules to
modules. As a function, it takes an input and produces an output. Its input is
named `M`, and the type of its input is `X`. Its output is the structure that
appears on the right-hand side of the equals sign: `struct let x = M.x + 1`.

Another way to think about `IncX` is that it's a *parameterized structure*. The
parameter that it takes is named `M` and has type `X`. The structure itself has
a single value named `x` in it. The value that `x` has will depend on the
parameter `M`.

Since functors are essentially functions, we *apply* them. Here's an example of
applying `IncX`:
```{code-cell} ocaml
module A = struct let x = 0 end
```

```{code-cell} ocaml
A.x
```

```{code-cell} ocaml
module B = IncX (A)
```

```{code-cell} ocaml
B.x
```

```{code-cell} ocaml
module C = IncX (B)
```

```{code-cell} ocaml
C.x
```

Each time, we pass `IncX` a module. When we pass it the module bound to the name
`A`, the input to `IncX` is `struct let x = 0 end`. Functor `IncX` takes that
input and produces an output `struct let x = A.x + 1 end`. Since `A.x` is `0`,
the result is `struct let x = 1 end`. So `B` is bound to `struct let x = 1 end`.
Similarly, `C` ends up being bound to `struct let x = 2 end`.

Although the functor `IncX` returns a module that is quite similar to its input
module, that need not be the case. In fact, a functor can return any module it
likes, perhaps something very different than its input structure:

```{code-cell} ocaml
module AddX (M : X) = struct
  let add y = M.x + y
end
```

Let's apply that functor to a module.  The module doesn't even have to
be bound to a name; we can just write an anonymous structure:

```{code-cell} ocaml
module Add42 = AddX (struct let x = 42 end)
```

```{code-cell} ocaml
Add42.add 1
```

Note that the input module to `AddX` contains a value named `x`, but the output
module from `AddX` does not:

```{code-cell} ocaml
:tags: ["raises-exception"]
Add42.x
```

```{warning}
It's tempting to think that a functor is the same as `extends` in Java, and that
the functor therefore extends the input module with new definitions while
keeping the old definitions around too. The example above shows that is not the
case. A functor is essentially just a function, and that function can return
whatever the programmer wants. In fact the output of the functor could be
arbitrarily different than the input.
```

## Functor Syntax and Semantics

In the functor syntax we've been using:

```ocaml
module F (M : S) = ...
end
```

the type annotation `: S` and the parentheses around it, `(M : S)` are required.
The reason why is that OCaml needs the type information about `S` to be provided
in order to do a good job with type inference for `F` itself.

Much like functions, functors can be written anonymously. The following two
syntaxes for functors are equivalent:

```ocaml
module F (M : S) = ...

module F = functor (M : S) -> ...
```

The second form uses the `functor` keyword to create an anonymous functor, like
how the `fun` keyword creates an anonymous function.

And functors can be parameterized on multiple structures:

```ocaml
module F (M1 : S1) ... (Mn : Sn) = ...
```

Of course, that's just syntactic sugar for a *higher-order functor* that takes
a structure as input and returns an anonymous functor:

```ocaml
module F = functor (M1 : S1) -> ... -> functor (Mn : Sn) -> ...
```

If you want to specify the output type of a functor, the syntax is again
similar to functions:

```ocaml
module F (M : Si) : So = ...
```

As usual, it's also possible to write the output type annotation on the module
expression:

```ocaml
module F (M : Si) = (... : So)
```

To evaluate an application `module_expression1 (module_expression2)`, the first
module expression is evaluated and must produce a functor `F`. The second module
expression is then evaluated to a module `M`. The functor is then applied to the
module. The functor will be producing a new module `N` as part of that
application. That new module is evaluated as always, in order of definition from
top to bottom, with the definitions of `M` available for use.

## Functor Type Syntax and Semantics

The simplest syntax for functor types is actually the same as for functions:

```ocaml
module_type -> module_type
```

For example, `X -> Add` below is a functor type, and it works for the `AddX`
module we defined earlier in this section:

```{code-cell} ocaml
module type Add = sig val add : int -> int end
module CheckAddX : X -> Add = AddX
```

Functor type syntax becomes more complicated if the output module type is
dependent upon the input module type. For example, suppose we wanted to create a
functor that pairs up a value from one module with another value:

```{code-cell} ocaml
module type T = sig
  type t
  val x : t
end

module Pair1 (M : T) = struct
  let p = (M.x, 1)
end
```

The type of `Pair1` turns out to be:

```ocaml
functor (M : T) -> sig val p : M.t * int end
```

So we could also write:

```{code-cell} ocaml
module type P1 = functor (M : T) -> sig val p : M.t * int end

module Pair1 : P1 = functor (M : T) -> struct
  let p = (M.x, 1)
end
```

Module type `P1` is the type of a functor that takes an input module named `M`
of module type `T`, and returns an output module whose module type is given by
the signature `sig..end`. Inside the signature, the name `M` is in scope. That's
why we can write `M.t` in it, thereby ensuring that the type of the first
component of pair `p` is the type from the *specific* module `M` that is passed
into `Pair1`, not any *other* module. For example, here are two different
instantiations:

```{code-cell} ocaml
module P0 = Pair1 (struct type t = int let x = 0 end)
module PA = Pair1 (struct type t = char let x = 'a' end)
```

Note the difference between `int` and `char` in the resulting module types. It's
important that the output module type of `Pair1` can distinguish those. And
that's why `M` has to be nameable on the right-hand side of the arrow in `P1`.

```{note}
Functor types are an example of an advanced programming language feature called
*dependent types*, with which the **type** of an output is determined by the
**value** of an input. That's different than the normal case of a function,
where it's the output **value** that's determined by the input value, and the
output **type** is independent of the input value.

Dependent types enable type systems to express much more about the correctness
of a program, but type checking and inference for dependent types is much more
challenging. Practical dependent type systems are an active area of research.
Perhaps someday they will become popular in mainstream languages.
```

The module type of a functor's actual argument need not be identical to the
formal declared module type of the argument; it's fine to be a subtype. For
example, it's fine to apply `F` below to either `X` or `Z`. The extra item in
`Z` won't cause any difficulty.

```{code-cell} ocaml
module F (M : sig val x : int end) = struct let y = M.x end
module X = struct let x = 0 end
module Z = struct let x = 0;; let z = 0 end
module FX = F (X)
module FZ = F (Z)
```

## The `Map` Module

{{ video_embed | replace("%%VID%%", "sCbUwQvNYJA")}}

The standard library's Map module implements a map (a binding from keys to
values) using balanced binary trees. It uses functors in an important way. In
this section, we study how to use it. You can see the
[implementation of that module on GitHub][mapimplsrc] as well as its
[interface][mapintsrc].

[mapintsrc]: https://github.com/ocaml/ocaml/blob/trunk/stdlib/map.mli
[mapimplsrc]: https://github.com/ocaml/ocaml/blob/trunk/stdlib/map.ml

The Map module defines a functor `Make` that creates a structure implementing a
map over a particular type of keys. That type is the input structure to `Make`.
The type of that input structure is `Map.OrderedType`, which are types that
support a `compare` operation:

```{code-cell} ocaml
module type OrderedType = sig
  type t
  val compare : t -> t -> int
end
```

The Map module needs ordering, because balanced binary trees need to be able to
compare keys to determine whether one is greater than another. The `compare`
function's specification is the same as that for the comparison argument to
`List.sort_uniq`, which we previously discussed:

- The comparison should return `0` if two keys are equal.
- The comparison should return a strictly negative number if the first key is
  lesser than the second.
- The comparison should return a strictly positive number if the first key is
  greater than the second.

````{note}
Does that specification seem a little strange? Does it seem hard to remember
when to return a negative vs. positive number? Why not define a variant instead?
```ocaml
type order = LT | EQ | GT
val compare : t -> t -> order
```
Alas, historically many languages have used comparison functions with similar
specifications, such as the C standard library's [`strcmp` function][strcmp].
When comparing two integers, it does make the comparison easy: just perform a
subtraction. It's not necessarily so easy for other data types.

[strcmp]: http://www.gnu.org/software/libc/manual/html_node/String_002fArray-Comparison.html
````

The output of `Map.Make` supports all the usual operations we would expect from
a dictionary:

```ocaml
module type S = sig
  type key
  type 'a t
  val empty: 'a t
  val mem: key -> 'a t -> bool
  val add: key -> 'a -> 'a t -> 'a t
  val find: key -> 'a t -> 'a
  ...
end
```

The type variable `'a` is the type of values in the map.  So any particular
map module created by `Map.Make` can handle only one type of key, but is not
restricted to any particular type of value.

### An Example Map

Here's an example of using the `Map.Make` functor:

```{code-cell} ocaml
:tags: ["hide-output"]
module IntMap = Map.Make(Int)
```

If you show that output, you'll see the long module type of `IntMap`. The `Int`
module is part of the standard library. Conveniently, it already defines the two
items required by `OrderedType`, which are `t` and `compare`, with appropriate
behaviors. The standard library also already defines modules for the other
primitive types (`String`, etc.) that make it convenient to use any primitive
type as a key.

Now let's try out that map by mapping an `int` to a `string`:

```{code-cell} ocaml
open IntMap;;
let m1 = add 1 "one" empty
```
```{code-cell} ocaml
find 1 m1
```
```{code-cell} ocaml
mem 42 m1
```
```{code-cell} ocaml
:tags: ["raises-exception"]
find 42 m1
```
```{code-cell} ocaml
bindings m1
```

The same `IntMap` module allows us to map an `int` to a `float`:

```{code-cell} ocaml
let m2 = add 1 1. empty
```
```{code-cell} ocaml
bindings m2
```

But the keys must be `int`, not any other type:

```{code-cell} ocaml
:tags: ["raises-exception"]
let m3 = add true "one" empty
```

That's because the `IntMap` module was specifically created for keys that are
integers and ordered accordingly. Again, order is crucial, because the
underlying data structure is a binary search tree, which requires key
comparisons to figure out where in the tree to store a key. You can even see
that in the [standard library source code (v4.12)][mapv412], of which the
following is a lightly-edited extract:

[mapv412]: https://github.com/ocaml/ocaml/blob/4.12/stdlib/map.ml

```ocaml
module Make (Ord : OrderedType) = struct
  type key = Ord.t

  type 'a t =
    | Empty
    | Node of {l : 'a t; v : key; d : 'a; r : 'a t; h : int}
      (** left subtree, key, value/data, right subtree, height of node *)

  let empty = Empty

  let rec mem x = function
    | Empty -> false
    | Node {l, v, r} ->
        let c = Ord.compare x v in
        c = 0 || mem x (if c < 0 then l else r)
  ...
end
```

The `key` type is defined to be a synonym for the type `t` inside `Ord`, so
`key` values are comparable using `Ord.compare`.  The `mem` function uses
that to compare keys and decide whether to recurse on the left subtree or right
subtree.

Note how the implementor of `Map` had a tricky problem to solve: balanced binary
search trees require a way to compare keys, but the implementor can't know in
advance all the different types of keys that a client of the data structure will
want to use. And each type of key might need its own comparison function.
Although `Stdlib.compare` *can* be used to compare any two values of the same
type, the result it returns isn't necessarily what a client will want. For
example, it's not guaranteed to sort names in the way we wanted above.

So the implementor of `Map` used a functor to solve their problem. They
parameterized on a module that bundles together the type of keys with a function
that can be used to compare them. It's the client's responsibility to implement
that module.

The Java Collections Framework solves a similar problem in the TreeMap class,
which has a [constructor that takes a Comparator][treemapcomparator]. There, the
client has the responsibility of implementing a class for comparisons, rather
than a structure. Though the language features are different, the idea is the
same.

[treemapcomparator]: https://docs.oracle.com/javase/8/docs/api/java/util/TreeMap.html#TreeMap-java.util.Comparator-

### Maps with Custom Key Types

When the type of a key becomes complicated, we might want to write our own
custom comparison function. For example, suppose we want a map in which keys are
records representing names, and in which names are sorted alphabetically by last
name then by first name. In the code below, we provide a module `Name` that can
compare records that way:

```{code-cell} ocaml
type name = {first : string; last : string}

module Name = struct
  type t = name
  let compare { first = first1; last = last1 } { first = first2; last = last2 }
      =
    match String.compare last1 last2 with
    | 0 -> String.compare first1 first2
    | c -> c
end
```

The `Name` module can be used as input to `Map.Make` because it satisfies the
`Map.OrderedType` signature:

```{code-cell} ocaml
:tags: ["hide-output"]
module NameMap = Map.Make (Name)
```

Now we could use that map to associate names with birth years:

```{code-cell} ocaml
let k1 = {last = "Kardashian"; first = "Kourtney"}
let k2 = {last = "Kardashian"; first = "Kimberly"}
let k3 = {last = "Kardashian"; first = "Khloe"}
let k4 = {last = "West"; first = "Kanye"}

let nm =
  NameMap.(empty |> add k1 1979 |> add k2 1980 |> add k3 1984 |> add k4 1977)

let lst = NameMap.bindings nm
```

Note how the order of keys in that list is not the same as the order in which we
added them. The list is sorted according to the `Name.compare` function we
wrote. Several of the other functions in the `Map.S` signature will also process
map bindings in that sorted order&mdash;for example, `map`, `fold`, and `iter`.

### How `Map` Uses Module Type Constraints

In the standard library's `map.mli` interface, the specification for
`Map.Make` is:

```ocaml
module Make (Ord : OrderedType) : S with type key = Ord.t
```

The `with` constraint there is crucial. Recall that type constraints specialize
a module type. Here, `S with type key = Ord.t` specializes `S` to expose the
equality of `S.key` and `Ord.t`. In other words, the type of keys is the ordered
type.

You can see the effect of that sharing constraint by looking at the module type
of our `IntMap` example from before. The sharing constraint is what caused the
`= Int.t` to be present:

```ocaml
module IntMap : sig
  type key = Int.t
  ...
end
```

And the `Int` module contains this line:

```ocaml
type t = int
```

So `IntMap.key = Int.t = int`, which is exactly why we're allowed to pass
an `int` to the `add` and `mem` functions of `IntMap`.

Without the type constraint, type `key` would have remained abstract. We can
simulate that by adding a module type annotation of `Map.S`, thereby
resealing the module at that type without exposing the equality:

```{code-cell} ocaml
module UnusableMap = (IntMap : Map.S);;
```

Now it's impossible to add a binding to the map:

```{code-cell} ocaml
:tags: ["raises-exception"]
let m = UnusableMap.(empty |> add 0 "zero")
```

This kind of use case is why module type constraints are quite important in
effective programming with the OCaml module system. Often it is necessary to
specialize the output type of a functor to show a relationship between a type in
it and a type in one of the functor's inputs. Thinking through exactly what
constraint is necessary can challenging, though!

## Using Functors

With `Map` we saw one use case for functors: producing a data structure that was
parameterized on a client-provided ordering. Here are two more use cases.

### Test Suites

Here are two implementations of a stack:

```{code-cell} ocaml
:tags: ["hide-output"]
exception Empty

module type Stack = sig
  type 'a t
  val empty : 'a t
  val push : 'a -> 'a t -> 'a t
  val peek : 'a t -> 'a
  val pop : 'a t -> 'a t
end

module ListStack = struct
  type 'a t = 'a list
  let empty = []
  let push = List.cons
  let peek = function [] -> raise Empty | x :: _ -> x
  let pop = function [] -> raise Empty | _ :: s -> s
end

module VariantStack = struct
  type 'a t = E | S of 'a * 'a t
  let empty = E
  let push x s = S (x, s)
  let peek = function E -> raise Empty | S (x, _) -> x
  let pop = function E -> raise Empty | S (_, s) -> s
end
```

Suppose we wanted to write an OUnit test for `ListStack`:

```{code-cell} ocaml
:tags: ["remove-cell"]
#require "ounit2";;
open OUnit2;;
```

```{code-cell} ocaml
:tags: ["remove-output"]
let test = "peek (push x empty) = x" >:: fun _ ->
  assert_equal 1 ListStack.(empty |> push 1 |> peek)
```

Unfortunately, to test a `VariantStack`, we'd have to duplicate that code:

```{code-cell} ocaml
:tags: ["remove-output"]
let test' = "peek (push x empty) = x" >:: fun _ ->
  assert_equal 1 VariantStack.(empty |> push 1 |> peek)
```

And if we had other stack implementations, we'd have to duplicate the test for
them, too. That's not so horrible to contemplate if it's just one test case for
a couple implementations, but if it's hundreds of tests for even a couple
implementations, that's just too much duplication to be good software
engineering.

Functors offer a better solution. We can write a functor that is parameterized
on the stack implementation, and produces the test for that implementation:

```{code-cell} ocaml
:tags: ["remove-output"]
module StackTester (S : Stack) = struct
  let tests = [
    "peek (push x empty) = x" >:: fun _ ->
      assert_equal 1 S.(empty |> push 1 |> peek)
  ]
end

module ListStackTester = StackTester (ListStack)
module VariantStackTester = StackTester (VariantStack)

let all_tests = List.flatten [
  ListStackTester.tests;
  VariantStackTester.tests
]
```

Now whenever we invent a new test we add it to `StackTester`, and it
automatically gets run on both stack implementations. Nice!

There is still some objectionable code duplication, though, in that we
have to write two lines of code per implementation.  We can eliminate
that duplication through the use of first-class modules:

```{code-cell} ocaml
:tags: ["remove-output"]
let stacks = [ (module ListStack : Stack); (module VariantStack) ]

let all_tests =
  let tests m =
    let module S = (val m : Stack) in
    let module T = StackTester (S) in
    T.tests
  in
  let open List in
  stacks |> map tests |> flatten
```

Now it suffices just to add the newest stack implementation to the `stacks`
list. Nicer!

### Extending Multiple Modules

Earlier, we tried to add a function `of_list` to both `ListSet` and
`UniqListSet` without having any duplicated code, but we didn't totally succeed.
Now let's really do it right.

The problem we had earlier was that we needed to parameterize the implementation
of `of_list` on the `add` function and `empty` value in the set module. We can
accomplish that parameterization with a functor:

```{code-cell} ocaml
:tags: ["remove-output"]
module type Set = sig
  type 'a t
  val empty : 'a t
  val mem : 'a -> 'a t -> bool
  val add : 'a -> 'a t -> 'a t
  val elements : 'a t -> 'a list
end

module SetOfList (S : Set) = struct
  let of_list lst = List.fold_right S.add lst S.empty
end
```

Notice how the functor, in its body, uses `S.add`. It takes the implementation
of `add` from `S` and uses it to implement `of_list` (and the same for `empty`),
thus solving the exact problem we had before when we tried to use includes.

When we apply `SetOfList` to our set implementations, we get modules
containing an `of_list` function for each implementation:

```{code-cell} ocaml
:tags: ["remove-output"]
module ListSet : Set = struct
  type 'a t = 'a list
  let empty = []
  let mem = List.mem
  let add = List.cons
  let elements s = List.sort_uniq Stdlib.compare s
end

module UniqListSet : Set = struct
  (** All values in the list must be unique. *)
  type 'a t = 'a list
  let empty = []
  let mem = List.mem
  let add x s = if mem x s then s else x :: s
  let elements = Fun.id
end
```

```{code-cell} ocaml
module OfList = SetOfList (ListSet)
module UniqOfList = SetOfList (UniqListSet)
```

The functor has enabled the code reuse we couldn't get before: we now can
implement a single `of_list` function and from it derive implementations for two
different sets.

But that's the **only** function those two modules contain. Really what we want
is a full set implementation that also contains the `of_list` function. We can
get that by combining includes with functors:

```{code-cell} ocaml
module SetWithOfList (S : Set) = struct
  include S
  let of_list lst = List.fold_right S.add lst S.empty
end
```

That functor takes a set as input, and produces a module that contains
everything from that set (because of the `include`) as well as a new function
`of_list`.

When we apply the functor, we get a very nice set module:

```{code-cell} ocaml
module SetL = SetWithOfList (ListSet)
module UniqSetL = SetWithOfList (UniqListSet)
```

Notice how the output structure records the fact that its type `t` is the same
type as the type `t` in its input structure. They share it because of the
`include`.

Stepping back, what we just did bears more than a passing resemblance to class
extension in Java. We created a base module and extended its functionality with
new code while preserving its old functionality. But whereas class extension
necessitates that the newly extended class is a subtype of the old, and that it
still has all the old functionality, OCaml functors are more fine-grained in
what they can accomplish. We can choose whether they include the old
functionality. And no subtyping relationships are necessarily involved.
Moreover, the functor we wrote can be used to extend **any** set implementation
with `of_list`, whereas class extension applies to just a **single** base class.
There are ways of achieving something similar in Java with *mixins*, which were
added in Java 1.5.
