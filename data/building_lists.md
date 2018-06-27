# Building Lists

**Syntax.**  There are three syntactic forms for building lists:
```
[]
e1::e2
[e1; e2; ...; en]
```
The empty list is written `[]` and is pronounced "nil", a
name that comes from Lisp. Given a list `lst` and element `elt`, we can
prepend `elt` to `lst` by writing `elt::lst`.  The double-colon operator
is pronounced "cons", a name that comes from an operator in Lisp that
<u>cons</u>tructs objects in memory.  "Cons" can also be used as a verb,
as in "I will cons an element onto the list."  The first element of a list
is usually called its *head* and the rest of the elements (if any) are
called its *tail*.  

The square bracket syntax is convenient but unnecessary.  Any list
`[e1; e2; ...; en]` could instead be written with the more primitive
nil and cons syntax:  `e1::e2::...::en::[]`.  When a pleasant syntax
can be defined in terms of a more primitive syntax within the language,
we call the pleasant syntax *syntactic sugar*:  it makes the language
"sweeter".  Transforming the sweet syntax into the more primitive
syntax is called *desugaring*.  

Because the elements of the list can be arbitrary expressions, lists
can be nested as deeply as we like, e.g., `[ [[]]; [[1;2;3]]]`

**Dynamic semantics.**

* `[]` is already a value.
* if `e1` evaluates to `v1`, and if `e2` evaluates to `v2`, 
  then `e1::e2` evaluates to `v1::v2`.
  
As a consequence of those rules and how to desugar the square-bracket
notation for lists, we have the following derived rule:

* if `ei` evaluates to `vi` for all `i` in `1..n`, 
  then `[e1; ...; en]` evaluates to `[v1; ...; vn]`.
  
It's starting to get tedious to write "evaluates to" in all our
evaluation rules.  So let's introduce a shorter notation for it.
We'll write `e ==> v` to mean that `e` evaluates to `v`.  Note that
`==>` is not a piece of OCaml syntax.  Rather, it's a notation
we use in our description of the language, kind of like metavariables.
Using that notation, we can rewrite the latter two rules above:

* if `e1 ==> v1`, and if `e2 ==> v2`, 
  then `e1::e2 ==> v1::v2`.
* if `ei ==> vi` for all `i` in `1..n`, 
  then `[e1; ...; en] ==> [v1; ...; vn]`. 

**Static semantics.**

All the elements of a list must have the same type.   If that
element type is `t`, then the type of the list is `t list`. 
You should read such types from right to left:  `t list` is a
list of `t`'s, `t list list` is a list of list of `t`'s, etc.
The word `list` itself here is not a type:  there is no way
to build an OCaml value that has type simply `list`.
Rather, `list` is a *type constructor*:  given a type, it produces
a new type.  For example, given `int`, it produces the type `int list`.
You could think of type constructors as being like functions that
operate on types, instead of functions that operate on values.

The type-checking rules:

* `[] : 'a list`
* if `e1 : t` and `e2 : t list` then `e1::e2 : t list`.

In the rule for `[]`, recall that `'a` is a type variable:  it stands
for an unknown type.  So the empty list is a list whose elements have an
unknown type.  If we cons an `int` onto it, say `2::[]`, then the
compiler infers that for that particular list, `'a` must be `int`. But
if in another place we cons a `bool` onto it, say `true::[]`, then the
compiler infers that for that particular list, `'a` must be `bool`.
