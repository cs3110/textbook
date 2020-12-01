# Let Polymorphism

Now we'll add `let` expressions to our little language:
```
e ::= x | i | b | e1 bop e2
    | if e1 then e2 else e3
    | fun x -> e
    | e1 e2
    | let x = e1 in e2   (* new *)
```
It turns out type inference for them is considerably trickier than might be
expected.

## An overly restrictive rule for let

The naive approach would be to add this constraint generation rule:
```
env |- let x = e1 in e2 : t2 -| C1, C2
  if env |- e1 : t1 -| C1
  and env, x : t1 |- e2 : t2 -| C2
```
From the type checking perspective, that's the same rule we've always used.
And for many `let` expressions it works perfectly fine. For example:
```
{} |- let x = 42 in x : int -| {}
  {} |- 42 : int -| {}
  x : int |- x : int -| {}
```

The problem is that when the value being bound is a polymorphic function, that
rule generates constraints that are too restrictive. For example, consider the
identity function:
```
let id = fun x -> x in
let a = id 0 in
id true
```
OCaml has no trouble inferring the type of `id` as `'a -> 'a` and permitting
it to be applied both to an `int` and a `bool`.  But the rule above isn't so
permissive about application to both types.  When we use it, we generate
the following types and constraints:

```
{} |- let id = fun x -> x in (let a = id 0 in id true) : 'c -| 'a -> 'a = int -> 'b, 'a -> 'a = bool -> 'c
  {} |- fun x -> x : 'a -| {}
    x : 'a |- x : 'a -| {}
  id : 'a -> 'a |- let a = id 0 in id true : 'c -| 'a -> 'a = int -> 'b, 'a -> 'a = bool -> 'c   <--- POINT 1
    id : 'a -> 'a |- id 0 : 'b -| 'a -> 'a = int -> 'b
      id : 'a -> 'a |- id : 'a -> 'a -| {}
      id : 'a -> 'a |- 0 : int -| {}
    id : 'a -> 'a, a : 'b |- id true : 'c -| 'a -> 'a = bool -> 'c   <--- POINT 2
      id : 'a -> 'a, a : 'b |- id : 'a -> 'a -| {}
      id : 'a -> 'a, a : 'b |- true : bool -| {}
```

Notice that we do infer a type `'a -> 'a` for `id`, which you can see in the
environment in later lines of the example. But, at Point 1, we infer a
constraint `'a -> 'a = int -> 'b`, and at Point 2, we infer
`'a -> 'a = bool -> 'c`. When the unification algorithm encounters those
constraints, it will break them down into `'a = int`, '`a = 'b`, `'a = bool`,
and `'a = 'c`. The first and third of those are contradictory, because we can't
have `'a = int` and `'a = bool`. One or the other will be substituted away
during unification, leaving an unsatisfiable constraint `int = bool`. At that
point unification will fail, declaring the program to be ill typed.

The problem is that the `'a` type variable in the inferred type of `id` stands
for an unknown but **fixed** type. At each application of `id`, we want to let
`'a` become a **different** type, instead of forcing it to always be the same
type.

## Type schemes

The solution to the problem of polymorphism for `let` expressions is not simple.
It requires us to introduce a new kind of type: a *type scheme*. Type schemes
resemble *universal quantification* from mathematical logic. For example, in
logic you might write, "for all natural numbers $$x$$, it holds that $$0 \cdot x
= 0$$". The "for all" is the universal quantification: it abstracts away from a
particular $$x$$ and states a property that is true of all natural numbers.

A type scheme is written `'a . t`, where `'a` is a type variable and `t` is a
type in which `'a` may appear. For example, `'a . 'a -> 'a` is a type scheme. It
is the type of a function that takes in a value of type `'a` and returns a value
of type `'a`, for all `'a`. Thus, it is the type of the polymorphic identity
function.

We can also have many type variables to the left of the dot in a type scheme.
For example, `'a 'b . 'a -> 'b -> 'a` is the type of a function that takes
in two arguments and returns the first.  In OCaml, we could write that
as `fun x y -> x`.  Note that utop infers the type of it as we would expect:
```
# let f = fun x y -> x;;
val f : 'a -> 'b -> 'a = <fun>
```

But we could actually manually write down an annotation with a type scheme:
```
# let f : 'a 'b . 'a -> 'b -> 'a = fun x y -> x;;
val f : 'a -> 'b -> 'a = <fun>
```
Note that OCaml accepts our manual type annotation but doesn't include the
`'a 'b .` part of it in its output. **But it's implicitly there and always has
been.** In general, anytime OCaml has inferred a type `t` and that type has had
type variables in it, in reality it's a type scheme. For example, the type of
`List.length` is really a type scheme:
```
# let mylen : 'a . 'a list -> int = List.length;;
val mylen : 'a list -> int = <fun>
```

OCaml just doesn't bother outputting the list of type variables that are to the
left of the dot in the type scheme. Really they'd just clutter the output, and
many programmers never need to know about them. But now that you're learning
type inference, it's time for you to know.

## A better rule for let

Now we'll have static environments map names to type schemes. We can think of
types as being special cases of type schemes in which the list of type variables
is empty. With type schemes, the `let` rule changes in only one way from the
naive rule above, which is the `generalize` on the last line:
```
env |- let x = e1 in e2 : t2 -| C1, C2
  if env |- e1 : t1 -| C1
  and generalize(C1, env, x : t1) |- e2 : t2 -| C2
```

The job of `generalize` is to take a type like `'a -> 'a` and _generalize_ it
into a type scheme like `'a . 'a -> 'a` in an environment `env` against
constraints `C1`. Let's come back to how it works in a minute. Before that,
there's one other rule that needs to change, which is the name rule:
```
env |- n : instantiate(env(t)) -| {}
```
The only thing that changes there is that use of `instantiate`. Its job is to
take a type scheme like `'a . 'a -> 'a` and _instantiate_ it into a new type
(and here we strictly mean a type, not a type scheme) with fresh type variables.
For example, `'a . 'a -> 'a` could be instantiated as `'b -> 'b`, if '`b` isn't
yet in use anywhere else as a type variable.

Here's how those two revised rules work together to get our earlier example
with the identify function right:
```
{} |- let id = fun x -> x in (let a = id 0 in id true)
  {} |- fun x -> x : 'a -| {}
    x : 'a |- x : 'a -| {}
  id : 'a . 'a -> 'a |- let a = id 0 in id true   <--- POINT 1
```
Let's pause there at Point 1. When `id` is put into the environment by the `let`
rule, its type is generalized from `'a -> 'a` to `'a . 'a -> 'a`; that is, from
a type to a type scheme. That records the fact that each application of `id`
should get to use its own value for `'a`.  Going on:
```
{} |- let id = fun x -> x in (let a = id 0 in id true)
  {} |- fun x -> x : 'a -| {}
    x : 'a |- x : 'a -| {}
  id : 'a . 'a -> 'a |- let a = id 0 in id true   <--- POINT 1
    id : 'a . 'a -> 'a |- id 0
      id : 'a . 'a -> 'a |- id : 'b -> 'b -| {}   <--- POINT 3
```
Pausing here at Point 3, when `id` is applied to `0`, we instantiate
its type variable `'a` with a fresh type variable `'b`.  Let's finish:
```
{} |- let id = fun x -> x in (let a = id 0 in id true) : 'e -| 'b -> 'b = int -> 'c, 'd -> 'd = bool -> 'e
  {} |- fun x -> x : 'a -| {}
    x : 'a |- x : 'a -| {}
  id : 'a . 'a -> 'a |- let a = id 0 in id true : 'e -| 'b -> 'b = int -> 'c, 'd -> 'd = bool -> 'e   <--- POINT 1
    id : 'a . 'a -> 'a |- id 0 : 'c -| 'b -> 'b = int -> 'c
      id : 'a . 'a -> 'a |- id : 'b -> 'b -| {}   <--- POINT 3
      id : 'a . 'a -> 'a |- 0 : int -| {}
    id : 'a . 'a -> 'a, a : 'b |- id true : 'e -| 'd -> 'd = bool -> 'e   <--- POINT 2
      id : 'a . 'a -> 'a, a : 'b |- id : 'd -> 'd -| {}   <--- POINT 4
      id : 'a . 'a -> 'a, a : 'b |- true : bool -| {}
```
At Point 4, when `id` is applied to `true`, we again instantiate its type
variable `'a` with a fresh type variable, this time `'d`. So the contraints
collected at Points 1 and 2 are no longer contradictory, because they are
talking about different type variables.  Those contraints are:

```
'b -> 'b = int -> 'c
'd -> 'd = bool -> 'e
```
The unification algorithm will therefore conclude:
```
'b = int
'c = int
'd = bool
'e = bool
```
So the entire expression is successfully inferred to have type `bool`.

## Instantiation and generalization

We used two new functions, `instantiate` and `generalize`, to define type
inference for `let` expressions.  Now we need to define those functions.

The easy one is `instantiate`.  Given a type scheme `'a1 'a2 ... 'an . t`,
we instatiate it by:

- choosing `n` fresh type variables, and
- substituting each of those for `'a1` through `'an` in `t`.

Substitution is uncomplicated here, compared to how it was for evaluation in
thee substitution model, because there is nothing in a type that can bind
variable names.

But `generalize` requires more work.  Here's the `let` rule again:
```
env |- let x = e1 in e2 : t2 -| C1, C2
  if env |- e1 : t1 -| C1
  and generalize (C1, env, x : t1) |- e2 : t2 -| C2
```

To generalize `t1`, we do the following.

First, we pretend like `e1` is all that matters, and that the rest of the `let`
expression doesn't exist. If `e1` were the entire program, how would we finish
type inference? We'd run the unification algorithm on `C1`, get a substitution
`S`, and return `t1 S` as the inferred type of `e1`. So, do that now. Let's call
that inferred type `u1`. Let's also apply `S` to `env` to get a new environment
`env1`, which now reflects all the type information we've gleaned from `e1`.

Second, we figure out which type variables in `u1` should be generalized. Why
not all of them? Because some type variables could have been introduced by code
that surrounds the `let` expression, e.g.,
```
fun x ->
  (let y = e1 in e2) (let z = e3 in e4)
```
The type variable for `x` should not be generalized in inferring the type of
either `y` or `z`, because `x` has to have the same type in all four
subexpressions, `e1` through `e4`. Generalizing could mistakenly allow `x` to
have one type in `e1` and `e2`, but a different type in `e3` and `e4`.

So instead we generalize only variables that **are** in `u1` but are **not** in
`env1`. That way we generalize only the type variables from `e1`, not variables
that were already in the environment when we started inferring the `let`
expression's type. Suppose those variables are `'a1 ... 'an`. The type scheme we
give to `x` is then `'a1 ... 'an . u1`.

Putting all that together, we end up with:
```
generalize(C1, env, x : t1) =
  env1, x : 'a1 ... 'an . u1
```

Returning to our example with the identify function from above, we had
`generalize({}, {}, x : 'a -> 'a)`. In that rather simple case, `unify`
discovers no new equalities from the environment, so `u1 = 'a -> 'a` and
`env1 = {}`. The only type variable in `u1` is `'a`, and it doesn't appear in
`env1`. So `'a` is generalized, yielding `'a . 'a -> 'a` as the type scheme for
`id`.

## Mutability rears its ugly head again

There is yet one more complication to type inference for `let` expressions. It
appears when we add mutable references to the language. Consider this example
code, which does not type check in OCaml:
```
let succ = fun x -> ( + ) 1 x;;
let id = fun x -> x;;
let r = ref id;;
r := succ;;
!r true;;  (* error *)
```
It's clear we should infer `succ : int -> int` and `id : 'a . 'a -> 'a`. But
what should the type of `r` be? It's tempting to say we should infer
`r : 'a . ('a -> 'a) ref`. That would let us instantiate the type of `r` to be
`(int -> int) ref` on line 4 and store `succ` in `r`. But it also would let us
instantiate the type of `r` to be `(bool -> bool) ref` on line 5. That's a
disaster: it causes the application of `succ` to `true`, which is not type safe.

The solution adopted by OCaml and related languages is called the *value
restriction:* the type system is designed to prevent a polymorphic mutable value
from ever holding more than one type. Let's redo some of that example again,
pausing to look at the toplevel output:

```
# let id = fun x -> x;;
val id : 'a -> 'a = <fun>   (* as expected *)

# let r = ref id;;
val r : ('_weak1 -> '_weak1) ref = { ... }   (* what is _weak? *)

# r;;
- : ('_weak1 -> '_weak1) ref = { ... }   (* it's consistent at least *)

# r := succ;;
- : unit = ()

# r;;
- : (int -> int) ref = { ... }   (* did r just change type ?! *)
```

When the type of `r` is inferred, OCaml gives it a type involving a _weak_ type
variable. All such variables have a name starting with `'_weak`. A weak type
variable is one that has not been generalized hence cannot be instantiated on
multiple types. Rather, it indicates a single type that is not yet known. Think
of it as type inference for that variable is not yet finished: OCaml is waiting
for more information to pin down precisely what it is. When `r := succ` is
executed, that information finally becomes available. OCaml infers that
`'_weak1 = int` from the type of `succ`. Then OCaml replaces `'_weak1` with
`int` everywhere.  That's what yields an error on the final line:
```
# !r true;;
Error: This expression has type bool but an expression was expected of type int
```
Since `r : (int -> int) ref`, we cannot apply `!r` to a `bool`.

We won't cover implementation of weak type variables here.

## Polymorphism and mutability

Let's not leave this topic of the interaction between polymorphic types and
mutability yet. You might be tempted to think that it's a phenomenon that
affects only OCaml. But indeed, even Java suffers.

Consider the following class hierarchy:
```
class Animal { }
class Elephant extends Animal { }
class Rabbit extends Animal { }
```

Now suppose we create an array of animals:
```
Animal[] a= new Rabbit[2]
```
Here we are using *subtype polymorphism* to assign an array of `Rabbit` objects
to an `Animal[]` reference. That's not the same as *parametric polymorphism* as
we've been using in OCaml, but it's nonetheless polymorphism.

What if we try this?
```
a[0]= new Elephant()
```
Since `a` is typed as an `Animal` array, it stands to reason that we could
assign an elephant object into it, just as we could assign a rabbit object. And
indeed that code is fine according to the Java compiler. But Java gives us a
runtime error if we run that code!
```
Exception java.lang.ArrayStoreException
```

The problem is that mutating the first array element to be a rabbit would leave
us with a `Rabbit` array in which one element is a `Elephant`. (Ouch! An
elephant would sit on a rabbit. Poor bun bun.) But in Java, the type of every
object of an array is supposed to be a property of the array as a whole. Every
element of the array created by `new Rabbit[2]` therefore must be a `Rabbit`. So
Java prevents the assignment above by detecting the error at run time and
raising an exception.

This is really the value restriction in another guise! The type of a value
stored in a mutable location may not change, according to the value restriction.
With arrays, Java implements that with a run-time check, instead of rejecting
the program at compile time. This strikes a balance between soundness
(preventing errors from happening) and expressivity (allowing more error-free
programs to type check).

