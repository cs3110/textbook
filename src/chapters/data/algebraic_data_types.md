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

# Algebraic Data Types

Thus far, we have seen variants simply as enumerating a set of constant values,
such as:
```ocaml
type day = Sun | Mon | Tue | Wed | Thu | Fri | Sat

type ptype = TNormal | TFire | TWater

type peff = ENormal | ENotVery | Esuper
```
But variants are far more powerful than this.

## Variants that Carry Data

{{ video_embed | replace("%%VID%%", "u6P5XdRta04")}}

As a running example, here is a variant type `shape` that does more than just
enumerate values:
```{code-cell} ocaml
type point = float * float
type shape =
  | Point of point
  | Circle of point * float (* center and radius *)
  | Rect of point * point (* lower-left and upper-right corners *)
```
This type, `shape`, represents a shape that is either a point, a circle, or a
rectangle. A point is represented by a constructor `Point` that *carries* some
additional data, which is a value of type `point`. A circle is represented by a
constructor `Circle` that carries two pieces of data: one of type `point` and
the other of type `float`. Those data represent the center of the circle and its
radius. A rectangle is represented by a constructor `Rect` that carries two more
points.

{{ video_embed | replace("%%VID%%", "K_eA-8LhlVY")}}
{{ video_embed | replace("%%VID%%", "SpuQfO_597E")}}

Here are a couple functions that use the `shape` type:
```{code-cell} ocaml
let area = function
  | Point _ -> 0.0
  | Circle (_, r) -> Float.pi *. (r ** 2.0)
  | Rect ((x1, y1), (x2, y2)) ->
      let w = x2 -. x1 in
      let h = y2 -. y1 in
      w *. h

let center = function
  | Point p -> p
  | Circle (p, _) -> p
  | Rect ((x1, y1), (x2, y2)) -> ((x2 +. x1) /. 2.0, (y2 +. y1) /. 2.0)
```

The `shape` variant type is the same as those we've seen before in that it is
defined in terms of a collection of constructors. What's different than before
is that those constructors carry additional data along with them. Every value of
type `shape` is formed from exactly one of those constructors. Sometimes we call
the constructor a *tag*, because it tags the data it carries as being from that
particular constructor.

Variant types are sometimes called *tagged unions*. Every value of the type is
from the set of values that is the union of all values from the underlying types
that the constructor carries. For example, with the `shape` type, every value is
tagged with either `Point` or `Circle` or `Rect` and carries a value from:

- the set of all `point` values, unioned with 
- the set of all `point * float` values, unioned with
- the set of all `point * point` values.

Another name for these variant types is an *algebraic data type*. "Algebra" here
refers to the fact that variant types contain both sum and product types, as
defined in the previous lecture. The sum types come from the fact that a value
of a variant is formed by *one of* the constructors. The product types come from
that fact that a constructor can carry tuples or records, whose values have a
sub-value from *each of* their component types.

Using variants, we can express a type that represents the union of several other
types, but in a type-safe way. Here, for example, is a type that represents
either a `string` or an `int`:
```{code-cell} ocaml
type string_or_int =
  | String of string
  | Int of int
```
If we wanted to, we could use this type to code up lists (e.g.) that contain
either strings or ints:
```{code-cell} ocaml
type string_or_int_list = string_or_int list

let rec sum : string_or_int list -> int = function
  | [] -> 0
  | String s :: t -> int_of_string s + sum t
  | Int i :: t -> i + sum t

let lst_sum = sum [String "1"; Int 2]
```
Variants thus provide a type-safe way of doing something that might before have
seemed impossible.

Variants also make it possible to discriminate which tag a value was constructed
with, even if multiple constructors carry the same type. For example:
```{code-cell} ocaml
type t = Left of int | Right of int
let x = Left 1
let double_right = function
  | Left i -> i
  | Right i -> 2 * i
```

## Syntax and Semantics

{{ video_embed | replace("%%VID%%", "3A_PNz5njt0")}}

**Syntax.**

To define a variant type:
```ocaml
type t = C1 [of t1] | ... | Cn [of tn]
```
The square brackets above denote that `of ti` is optional. Every constructor may
individually either carry no data or carry data. We call constructors that carry
no data *constant*; and those that carry data, *non-constant*.

To write an expression that is a variant:
```ocaml
C e
```
Or:
```ocaml
C
```
depending on whether the constructor name `C` is non-constant or constant.

**Dynamic semantics.**

* If `e==>v` then `C e ==> C v`, assuming `C` is non-constant.
* `C` is already a value, assuming `C` is constant.

**Static semantics.**

* If `t = ... | C | ...` then `C : t`.
* If `t = ... | C of t' | ...` and if `e : t'` then `C e : t`.

**Pattern matching.**

We add the following new pattern form to the list of legal patterns:

* `C p`

And we extend the definition of when a pattern matches a value and produces
a binding as follows:

* If `p` matches `v` and produces bindings $b$, then `C p` matches `C v` and
  produces bindings $b$.

## Catch-all Cases

One thing to beware of when pattern matching against variants is what *Real
World OCaml* calls "catch-all cases". Here's a simple example of what can go
wrong. Let's suppose you write this variant and function:
```{code-cell} ocaml
type color = Blue | Red

(* a thousand lines of code in between *)

let string_of_color = function
  | Blue -> "blue"
  | _ -> "red"
```
Seems fine, right?  But then one day you realize there are more colors
in the world.  You need to represent green.  So you go back and add green
to your variant:
```{code-cell} ocaml
type color = Blue | Red | Green

(* a thousand lines of code in between *)

let string_of_color = function
  | Blue -> "blue"
  | _ -> "red"
```
But because of the thousand lines of code in between, you forget that
`string_of_color` needs updating.  And now, all the sudden, you are
red-green color blind:
```{code-cell} ocaml
string_of_color Green
```
The problem is the *catch-all* case in the pattern match inside
`string_of_color`: the final case that uses the wildcard pattern to match
anything. Such code is not robust against future changes to the variant type.

If, instead, you had originally coded the function as follows, life would be
better:
```{code-cell} ocaml
let string_of_color = function
  | Blue -> "blue"
  | Red  -> "red"
```
The OCaml type checker now alerts you that you haven't yet updated
`string_of_color` to account for the new constructor.

The moral of the story is: catch-all cases lead to buggy code. Avoid using them.

## Recursive Variants

{{ video_embed | replace("%%VID%%", "gDh217oAfnY")}}

Variant types may mention their own name inside their own body. For example,
here is a variant type that could be used to represent something similar to
`int list`:
```{code-cell} ocaml
type intlist = Nil | Cons of int * intlist

let lst3 = Cons (3, Nil)  (* similar to 3 :: [] or [3]*)
let lst123 = Cons(1, Cons(2, lst3)) (* similar to [1; 2; 3] *)

let rec sum (l : intlist) : int=
  match l with
  | Nil -> 0
  | Cons (h, t) -> h + sum t

let rec length : intlist -> int = function
  | Nil -> 0
  | Cons (_, t) -> 1 + length t

let empty : intlist -> bool = function
  | Nil -> true
  | Cons _ -> false
```
Notice that in the definition of `intlist`, we define the `Cons` constructor to
carry a value that contains an `intlist`. This makes the type `intlist` be
*recursive*: it is defined in terms of itself.

Types may be mutually recursive if you use the `and` keyword:
```{code-cell} ocaml
type node = {value : int; next : mylist}
and mylist = Nil | Node of node
```

Any such mutual recursion must involve at least one variant or record type
that the recursion "goes through".  For example, the following is not allowed:
```{code-cell} ocaml
:tags: ["raises-exception"]
type t = u and u = t
```
But this is:
```{code-cell} ocaml
type t = U of u and u = T of t
```

Record types may also be recursive:
```{code-cell} ocaml
type node = {value : int; next : node}
```
But plain old type synonyms may not be:
```{code-cell} ocaml
:tags: ["raises-exception"]
type t = t * t
```

Although `node` is a legal type definition, there is no way to construct a value
of that type because of the circularity involved: to construct the very first
`node` value in existence, you would already need a value of type `node` to
exist. Later, when we cover imperative features, we'll see a similar idea used
(but successfully) for mutable linked lists.

## Parameterized Variants

Variant types may be *parameterized* on other types.  For example,
the `intlist` type above could be generalized to provide lists (coded
up ourselves) over any type:
```{code-cell} ocaml
type 'a mylist = Nil | Cons of 'a * 'a mylist

let lst3 = Cons (3, Nil)  (* similar to [3] *)
let lst_hi = Cons ("hi", Nil)  (* similar to ["hi"] *)
```
Here, `mylist` is a *type constructor* but not a type: there is no way to write
a value of type `mylist`. But we can write value of type `int mylist` (e.g.,
`lst3`) and `string mylist` (e.g., `lst_hi`). Think of a type constructor as
being like a function, but one that maps types to types, rather than values to
value.

Here are some functions over `'a mylist`:
```{code-cell} ocaml
let rec length : 'a mylist -> int = function
  | Nil -> 0
  | Cons (_, t) -> 1 + length t

let empty : 'a mylist -> bool = function
  | Nil -> true
  | Cons _ -> false
```
Notice that the body of each function is unchanged from its previous definition
for `intlist`. All that we changed was the type annotation. And that could even
be omitted safely:
```{code-cell} ocaml
let rec length = function
  | Nil -> 0
  | Cons (_, t) -> 1 + length t

let empty = function
  | Nil -> true
  | Cons _ -> false
```

The functions we just wrote are an example of a language feature called
**parametric polymorphism**. The functions don't care what the `'a` is in
`'a mylist`, hence they are perfectly happy to work on `int mylist` or
`string mylist` or any other `(whatever) mylist`. The word "polymorphism" is
based on the Greek roots "poly" (many) and "morph" (form). A value of type
`'a mylist` could have many forms, depending on the actual type `'a`.

As soon, though, as you place a constraint on what the type `'a` might be, you
give up some polymorphism. For example,
```{code-cell} ocaml
let rec sum = function
  | Nil -> 0
  | Cons (h, t) -> h + sum t
```
The fact that we use the `( + )` operator with the head of the list constrains
that head element to be an `int`, hence all elements must be `int`. That means
`sum` must take in an `int mylist`, not any other kind of `'a mylist`.

It is also possible to have multiple type parameters for a parameterized type,
in which case parentheses are needed:
```{code-cell} ocaml
type ('a, 'b) pair = {first : 'a; second : 'b}
let x = {first = 2; second = "hello"}
```

## Polymorphic Variants

Thus far, whenever you've wanted to define a variant type, you have had to give
it a name, such as `day`, `shape`, or `'a mylist`:

```{code-cell} ocaml
type day = Sun | Mon | Tue | Wed | Thu | Fri | Sat

type shape =
  | Point of point
  | Circle of point * float
  | Rect of point * point

type 'a mylist = Nil | Cons of 'a * 'a mylist
```

Occasionally, you might need a variant type only for the return value of a
single function. For example, here's a function `f` that can either return an
`int` or $\infty$; you are forced to define a variant type to represent that
result:
```{code-cell} ocaml
type fin_or_inf = Finite of int | Infinity

let f = function
  | 0 -> Infinity
  | 1 -> Finite 1
  | n -> Finite (-n)
```
The downside of this definition is that you were forced to define
`fin_or_inf` even though it won't be used throughout much of your program.

There's another kind of variant in OCaml that supports this kind of programming:
*polymorphic variants*. Polymorphic variants are just like variants, except:

1. You don't have to declare their type or constructors before using them.

2. There is no name for a polymorphic variant type. (So another name for this
   feature could have been "anonymous variants".)

3. The constructors of a polymorphic variant start with a backquote character.

Using polymorphic variants, we can rewrite `f`:
```{code-cell} ocaml
let f = function
  | 0 -> `Infinity
  | 1 -> `Finite 1
  | n -> `Finite (-n)
```

This type says that `f` either returns `` `Finite n`` for some `n : int` or
`` `Infinity``. The square brackets do not denote a list, but rather a set of
possible constructors. The `>` sign means that any code that pattern matches
against a value of that type must *at least* handle the constructors
`` `Finite`` and `` `Infinity``, and possibly more. For example, we could write:
```{code-cell} ocaml
match f 3 with
  | `NegInfinity -> "negative infinity"
  | `Finite n -> "finite"
  | `Infinity -> "infinite"
```
It's perfectly fine for the pattern match to include constructors other than
`` `Finite`` or `` `Infinity``, because `f` is guaranteed never to return any
constructors other than those.

There are other, more compelling uses for polymorphic variants that we'll see
later in the course. They are particularly useful in libraries. For now, we
generally will steer you away from extensive use of polymorphic variants,
because their types can become difficult to manage.

## Built-in Variants

OCaml's built-in list data type is really a recursive, parameterized variant. It
is defined as follows:
```{code-cell} ocaml
:tags: ["remove-output"]
type 'a list = [] | ( :: ) of 'a * 'a list
```
So `list` is really just a type constructor, with (value) constructors
`[]` (which we pronounce "nil") and `::` (which we pronounce "cons").

OCaml's built-in option data type is also really a parameterized variant. It's
defined as follows:
```{code-cell} ocaml
:tags: ["remove-output"]
type 'a option = None | Some of 'a
```
So `option` is really just a type constructor, with (value) constructors
`None` and `Some`.

You can see both `list` and `option` defined in the [core OCaml library][core].

[core]: https://ocaml.org/manual/core.html
