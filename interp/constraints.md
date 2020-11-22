# Type Constraints

SimPL, without `let`, with lambda calculus.  We'll add `let` back in later after
we solve other problems.

```
e ::= x | i | b | e1 bop e2                
    | if e1 then e2 else e3
    | fun x -> e
    | e1 e2

bop ::= + | * | <=

t ::= int | bool | t1 -> t2
```

Anonymous functions without type annotations `fun x -> e` mean we have to infer
the type of `x` to infer the type of the function. For example,

- `fun x -> x + 1` means `x` has type `int` hence the function has type
  `int -> int`.

- `fun x -> if x then 1 else 0` means `x` has type `bool` hence the function has
  type `bool -> int`.

- `fun x -> if x then x else 0` is untypeable, because it would require `x`
  to have type `int` and `bool`, which isn't allowed.

## A syntactic simplification

Since we've added functions to SimPL in this little language, we can treat
`e1 bop e2` as syntactic sugar for `( bop ) e1 e2`. That is, treat infix binary
operators as prefix function application. Introduce new syntactic class `n`
for name. Cuts down syntax to:

```
e ::= n | i | b
    | if e1 then e2 else e3
    | fun x -> e
    | e1 e2

n ::= x | bop

bop ::= ( + ) | ( * ) | ( <= )

t ::= int | bool | t1 -> t2
```

We know the types of those built-in operators:

```
( + ) : int -> int -> int
( * ) : int -> int -> int
( <= ) : int -> int -> bool
```

Those types are part of the initial static environment when type checking an
expresssion. In OCaml they could even be shadowed by values with different
types, but here we don't have to worry about that because we don't yet have
`let`.

## Constraint-based inference

How do you mentally infer the type of `fun x -> 1 + x`, or rather,
`fun x -> ( + ) 1 x`? It's automatic by now, but we could break it down into
pieces:

- Start with `x` having some unknown type `t`.
- Note that `( + )` is known to have type `int -> (int -> int)`.
- So its first argument must have type `int`.  Which `1` does.
- And its second argument must have type `int`, too. So `t` must be `int`. That
  is a _constraint_ on `t`.
- Finally the body of the function must also have type `int`, since that's the
  return type of `( + )`.
- Therefore the type of the entire function must be `t -> int`.
- Since `t = int`, that type is `int -> int`.

The type inference algorithm follows the same idea of generating unknown types,
collecting constraints on them, and using the constraints to solve for the type
of the expression.

New 4-ary relation `env |- e : t -| C` means that in environment `env`,
expression `e` is inferred to have type `t` and generates constraint set `C`. A
constraint is an equation of the form `t1 = t2` for any types `t1` and `t2`.

The colon in the middle separates input from output when thought of as
a type-inference function.  That function takes as input `env` and `e`:
we want to know what the type of `e` is in environment `env`.  The function
returns as output a type `t` and constraints `C`.

The turnstiles around the outside show the parts of type inference that utop
does not. The `e : t` in the middle is approximately what you see in the
toplevel: you enter an expression, it tells you the type. But around that is an
environment and contraint set `env |- ... -| C` that is invisible to you.

## Inference of constants and names

The easiest parts of inference are constants:
```
env |- i : int -| {}

env |- b : bool -| {}
```
Any integer constant `i`, such as `42`, is known to have type `int`, and there
are no contraints generated.  Likewise for Boolean constants.

Inferring the type of a name requires looking it up in the environment:
```
env |- n : t -| {}
  if env(n) = t
```
If the name is not bound in the environment, the expression cannot be typed.
It's an unbound name error.  No constraints are generated.

## Inference of if expressions

The remaining rules are at their core the same as the type-checking rules we saw
previously, but they each generate a _type variable_ and possibly some
constraints on that type variable.

Here's the `if` rule.  We'll explain it below.
```
env |- if e1 then e2 else e3 : 't -| C1, C2, C3, t1 = bool, 't = t2, 't = t3
  if fresh 't
  and env |- e1 : t1 -| C1
  and env |- e2 : t2 -| C2
  and env |- e3 : t3 -| C3
```

Let's look at the first premiss:  "fresh `'t`".

When we encounter an `if`, we know that the type of the guard must be `bool`,
but we don't what the type of the branches will be. That must be inferred. So,
we invent a type variable `'t` to stand for that type.

We should therefore add type variables to the syntax of types:
```
t ::= 'x | int | bool | t -> t
```
Example type variables: `'a`, `'foobar`, `'t`. In the last, `t` is an
identifier, not a meta-variable.

A type variable is _fresh_ if it has never been used elsewhere during type
inference. So, picking a fresh type variable just means picking a new name that
can't possibly be confused with any other names in the program.

So when we say "fresh `'t`" in the `if` rule, we mean that we are picking a
brand new type variable that hasn't been used before.

The remaining premisses are exactly the same as in type checking an `if`,
except that they might generate their own constraint sets `C1`, `C2`, and `C3`.

The conclusion of the rule is that the `if` expression has type `'t`.  Which
is of course what it must have, since the type of an `if` is the type
of its branches.

The constraints generated by this inference are all the constraints from
the presmisses, and along with those, two new constraints: `'t = t2` and
`'t = t3`.  That is, whatever type `t2` is inferred for `e2` must be
equal to `'t`.  And the same for `t3` and `e3`.

**Example.**

```
{} |- if true then 1 else 0 : 't -| 't = int
  {} |- true : bool -| {}
  {} |- 1 : int -| {}
  {} |- 0 : int -| {}
```

The full constraint set generated is `{}, {}, {}, 't = int, 't = int`, but of
course that simplifies to just `'t = int`. From that constraint set we can see
that the type of `if true then 1 else 0` must be `int`.

## Inference of functions and applications

Like `if` expressions, type inference for anonymous functions and function
application are essentially the same as type checking, but with the added step
of generating a fresh type variable for the unknown type involved.

**Anonymous functions.**
The unknown type is the type of the parameter `x`:
```
env |- fun x -> e : 't1 -> t2 -| C
  if fresh 't1
  and env, x : 't1 |- e : t2 -| C
```
So we introduce a fresh type variable `'t1` to stand for the type of `x`, and
infer the type of body `e` under the environment in which `x : 't1`. Wherever
`x` is used in `e`, that can cause constraints to be generated involving `'t1`.
Those constraints will become part of `C`.

**Example.**

Here's a function where we can immediately see that `x : bool`, but let's work
through the inference:
```
{} |- fun x -> if x then 1 else 0 : 't1 -> 't -| 't1 = bool, 't = int
  {}, x : 't1 |- if x then 1 else 0 : 't -| 't1 = bool, 't = int
    {}, x : 't1 |- x : 't1 -| {}
    {}, x : 't1 |- 1 : int -| {}
    {}, x : 't1 |- 0 : int -| {}
```
The inferred type of the function is `'t1 -> 't`, where `'t1 = bool` and
`'t = int`. Simplifying that, the function's type is `bool -> int`.

**Function application.**
The unknown type is the type of the entire application, because we don't 
yet know anything about the types of either subexpression:
```
env |- e1 e2 : 't -| C1, C2, t1 = t2 -> 't
  if fresh 't
  and env |- e1 : t1 -| C1
  and env |- e2 : t2 -| C2
```
So we introduce a fresh type variable `'t` for the type of the application. We
use inference to determine the types of the subexpressions and any constraints
they happen to generate. We add one new constraint, `t1 = t2 -> 't`, which
expresses that the type of the left-hand side `e1` must be a function that takes
in an argument of type `t2` and returns a value of type `'t`.

**Example.**
Let `I` be the _initial environment_ that binds the boolean operators.
Let's infer the type of a partial application of `( + )`:
```
I |- ( + ) 1 : 't -| int -> int -> int = int -> 't
  I |- ( + ) : int -> int -> int -| {}
  I |- 1 : int -| {}
```
From the resulting constraint, we see that
```
int -> int -> int
=
int -> 't
```
Hence `'t = int -> int`, which is the correct type for a partial application
of `( + )`.

## Solving constraint sets

We've now given an algorithm for generating types and constraint sets in the
form of the inductive relation `env |- e : t -| C`. But we've been waving our
hands about how to solve the constraint set. The examples we've seen so far have
been easy to eyeball because they were small. For a large program, that won't be
true. So let's turn our attention to that problem, next.