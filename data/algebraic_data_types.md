# Algebraic Data Types

Thus far, we have seen variants simply as enumerating a set of constant values,
such as:
```
type day = Sun | Mon | Tue | Wed
         | Thu | Fri | Sat 

type ptype = TNormal | TFire | TWater

type peff = ENormal | ENotVery | Esuper
```
But variants are far more powerful that this.

As a running example, here is a variant type that does more than just
enumerate values:
```
type shape =
  | Point  of point
  | Circle of point * float (* center and radius *)
  | Rect   of point * point (* lower-left and 
                               upper-right corners *)
```
This type, `shape`, represents a shape that is either a point, a circle,
or a rectangle.  A point is represented by a constructor `Point` that
*carries* some additional data, which is a value of type `point`.
A circle is represented by a constructor `Circle` that carries
a pair of type `point * float`, which according to the comment
represents the center of the circle and its radius.  A rectangle
is represented by a constructor `Rect` that carries a pair of type
`point*point`.  

Here are a couple functions that use the `shape` type:
```
let area = function
  | Point _ -> 0.0
  | Circle (_,r) -> pi *. (r ** 2.0)
  | Rect ((x1,y1),(x2,y2)) ->
      let w = x2 -. x1 in
      let h = y2 -. y1 in
        w *. h

let center = function
  | Point p -> p
  | Circle (p,_) -> p
  | Rect ((x1,y1),(x2,y2)) ->
      ((x2 +. x1) /. 2.0,
       (y2 +. y1) /. 2.0)
```

The `shape` variant type is the same as those we've seen before in that
it is defined in terms of a collection of constructors.  What's different
than before is that those constructors carry additional data along with them.
Every value of type `shape` is formed from exactly one of those constructors.
Sometimes we call the constructor a *tag*, because it tags the data it carries
as being from that particular constructor.

Variant types are sometimes called *tagged unions*.  Every value of the type
is from the set of values that is the union of all values from the underlying
types that the constructor carries.  For the `shape` type, every value
is tagged with either `Point` or `Circle` or `Rect` and carries a value
from the set of all `point` valued unioned with the set of all `point*float`
values unioned with the set of all `point*point` values.

Another name for these variant types is an *algebraic data type*.  "Algebra"
here refers to the fact that variant types contain both sum and product types,
as defined in the previous lecture.  The sum types come from the fact that
a value of a variant is formed by *one of* the constructors.  The product
types come from that fact that a constructor can carry tuples or records,
whose values have a sub-value from *each of* their component types.

Using variants, we can express a type that represents the union of several
other types, but in a type-safe way.  Here, for example, is a type that
represents either a `string` or an `int`:
```
type string_or_int =
| String of string
| Int of int
```
If we wanted to, we could use this type to code up lists (e.g.) that
contain either strings or ints:
```
type string_or_int_list = string_or_int list

let rec sum : string_or_int list -> int = function
  | [] -> 0
  | (String s)::t -> int_of_string s + sum t
  | (Int i)::t -> i + sum t
  
let three = sum [String "1"; Int 2]
```
Variants thus provide a type-safe way of doing something that might
before have seemed impossible.

Variants also make it possible to discriminate which tag a value was
constructed with, even if multiple constructors carry the same type.
For example:
```
type t = Left of int | Right of int
let x = Left 1
let double_right = function
  | Left i -> i
  | Right i -> 2*i
```

**Syntax.**

To define a variant type:
```
type t = C1 [of t1] | ... | Cn [of tn]
```
The square brackets above denote the type `of ti` is optional.  Every
constructor may individually either carry no data or carry data.
We call constructors that carry no data *constant*; and those that
carry data, *non-constant*.

To write an expression that is a variant:
```
C e
---or---
C
```
depending on whether the constructor name `C` is non-constant or constant.

**Dynamic semantics.**

* if `e==>v` then `C e ==> C v`, assuming `C` is non-constant.
* `C` is already a value, assuming `C` is constant.

**Static semantics.**

* if `t = ... | C | ...` then `C : t`.
* if `t = ... | C of t' | ...` and if `e : t'` then `C e : t`.

**Pattern matching.**

We add the following new pattern form to the list of legal patterns:

* `C p`

And we extend the definition of when a pattern matches a value and produces
a binding as follows:

* If `p` matches `v` and produces bindings $$b$$, then 
  `C p` matches `C v` and produces bindings $$b$$.
