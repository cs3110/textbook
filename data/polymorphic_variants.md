# Polymorphic Variants

Thus far, whenever you've wanted to define a variant type, you have had to give
it a name, such as `day`, `shape`, or `'a mylist`:

```
type day = Sun | Mon | Tue | Wed | Thu | Fri | Sat

type shape =
  | Point  of point
  | Circle of point * float 
  | Rect   of point * point 

type 'a mylist = Nil | Cons of 'a * 'a mylist
```

Occasionally, you might need a variant type only for the return value of a single
function.  For example, here's a function `f` that can either return 
an `int` or $$\infty$$; you are forced to define a variant type to represent
that result:
```
type fin_or_inf = Finite of int | Infinity

let f = function
  | 0 -> Infinity
  | 1 -> Finite 1
  | n -> Finite (-n)
```
The downside of this definition is that you were forced to defined
`fin_or_inf` even though it won't be used throughout much of your program.

There's another kind of variant in OCaml that supports this kind of programming:
*polymorphic variants*. Polymorphic variants are just like variants, except:

1. You don't have declare their type or constructors before using them.
2. There is no name for a polymorphic variant type. (So another name 
   for this feature could have been "anonymous variants".)
3. The constructors of a polymorphic variant
   start with ` ` ` (this the "grave accent", also called
   backquote, back tick, and reverse single quote; it is typically found on the
   same key as the `~` character, near the escape key).

Using polymorphic variants, we can rewrite `f`:
```
(* note: no type definition *)

let f = function
  | 0 -> `Infinity
  | 1 -> `Finite 1
  | n -> `Finite (-n)
```

With this definition, the type of `f` is
```
val f : int -> [> `Finite of int | `Infinity ]
```
This type says that `f` either returns `` `Finite n`` for some `n:int`
or `` `Infinity``. The square brackets do not denote a list, but rather
a set of possible constructors.  The `>` sign means that any code that
pattern matches against a value of that type must *at least* handle the
constructors `` `Finite`` and `` `Infinity``, and possibly more. For
example, we could write:
```
match f 3 with
  | `NegInfinity -> "negative infinity"
  | `Finite n    -> "finite"
  | `Infinity    -> "infinite"
```
It's perfectly fine for the pattern match to include constructors other
than `` `Finite`` or `` `Infinity``, because `f` is guaranteed never to
return any constructors other than those.

There are other, more compelling uses for polymorphic variants that we'll 
see later in the course.  They are particularly useful in libraries.
For now, we generally will steer you away from extensive use of polymorphic
variants, because their types can become difficult to manage.
