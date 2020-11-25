# Type Constraints

Let's build up to the HM type inference algorithm by starting with
this little language:
```
e ::= x | i | b | e1 bop e2                
    | if e1 then e2 else e3
    | fun x -> e
    | e1 e2

bop ::= + | * | <=

t ::= int | bool | t1 -> t2
```
That language is SimPL combined with the lambda calculus, but without `let`
expressions. It turns out `let` expressions add a extra layer of complication,
so we'll come back to them later.

Since anonymous functions in this language do not have type annotations,
we have to infer the type of the argument `x`. For example,

- In `fun x -> x + 1`, argument `x` must have type `int` hence the function has
  type `int -> int`.

- In `fun x -> if x then 1 else 0`, argument `x` must have type `bool` hence the
  function has type `bool -> int`.

- Function `fun x -> if x then x else 0` is untypeable, because it would require
  `x` to have both type `int` and `bool`, which isn't allowed.

## A syntactic simplification

We can treat `e1 bop e2` as syntactic sugar for `( bop ) e1 e2`. That is, we
treat infix binary operators as prefix function application. Let's introduce a
new syntactic class `n` for *names*, which generalize identifiers and operators.
That changes the syntax to:

```
e ::= n | i | b
    | if e1 then e2 else e3
    | fun x -> e
    | e1 e2

n ::= x | bop

bop ::= ( + ) | ( * ) | ( <= )

t ::= int | bool | t1 -> t2
```

We already know the types of those built-in operators:
```
( + ) : int -> int -> int
( * ) : int -> int -> int
( <= ) : int -> int -> bool
```
Those types are given; we don't have to infer them. They are part of the initial
static environment. In OCaml those operator names could later be shadowed by
values with different types, but here we don't have to worry about that because
we don't yet have `let`.

## Constraint-based inference

How would *you* mentally infer the type of `fun x -> 1 + x`, or rather,
`fun x -> ( + ) 1 x`? It's automatic by now, but we could break it down into
pieces:

- Start with `x` having some unknown type `t`.
- Note that `( + )` is known to have type `int -> (int -> int)`.
- So its first argument must have type `int`.  Which `1` does.
- And its second argument must have type `int`, too. So `t = int`. That is a
  _constraint_ on `t`.
- Finally the body of the function must also have type `int`, since that's the
  return type of `( + )`.
- Therefore the type of the entire function must be `t -> int`.
- Since `t = int`, that type is `int -> int`.

The type inference algorithm follows the same idea of generating unknown types,
collecting constraints on them, and using the constraints to solve for the type
of the expression.

## Inference relation

Let's introduce a new 4-ary relation `env |- e : t -| C`, which should be read
as follows: "in environment `env`, expression `e` is inferred to have type `t`
and generates constraint set `C`." A constraint is an equation of the form
`t1 = t2` for any types `t1` and `t2`.

If we think of the relation as a type-inference function, the colon in the
middle separates the input from the output. The inputs are `env` and `e`: we
want to know what the type of `e` is in environment `env`. The function returns
as output a type `t` and constraints `C`.

The `e : t` in the middle of the relation is approximately what you see in the
toplevel: you enter an expression, and it tells you the type. But around that is
an environment and constraint set `env |- ... -| C` that is invisible to you.
So, the turnstiles around the outside show the parts of type inference that the
toplevel does not.

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

To infer the type of an `if`, we infer the types `t1`, `t2`, and `t3` of each of
its subexpressions, along with any constraints on them. We have no control over
what those types might be; it depends on what the programmer wrote. But we do
know that the type of the guard must be `bool`. So we generate a constraint that
`t1 = bool`.

Furthermore, we know that both branches must have the same type&mdash;though, we
don't know in advance what that type might be. So, we invent a _fresh_ type
variable `'t` to stand for that type. A type variable is fresh if it has never
been used elsewhere during type inference. So, picking a fresh type variable
just means picking a new name that can't possibly be confused with any other
names in the program. We return `'t` as the type of the `if`, and we record two
constraints `'t = t2` and `'t = t3` to say that both branches must have that
type.

We therefore need to add type variables to the syntax of types:
```
t ::= 'x | int | bool | t1 -> t2
```
Some example type variables include `'a`, `'foobar`, and `'t`. In the last, `t`
is an identifier, not a meta-variable.

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

**Anonymous functions.** Since there is no type annotation on `x`, its type must
be inferred:
```
env |- fun x -> e : 't1 -> t2 -| C
  if fresh 't1
  and env, x : 't1 |- e : t2 -| C
```
We introduce a fresh type variable `'t1` to stand for the type of `x`, and
infer the type of body `e` under the environment in which `x : 't1`. Wherever
`x` is used in `e`, that can cause constraints to be generated involving `'t1`.
Those constraints will become part of `C`.

**Example.** Here's a function where we can immediately see that `x : bool`, but
let's work through the inference:
```
{} |- fun x -> if x then 1 else 0 : 't1 -> 't -| 't1 = bool, 't = int
  {}, x : 't1 |- if x then 1 else 0 : 't -| 't1 = bool, 't = int
    {}, x : 't1 |- x : 't1 -| {}
    {}, x : 't1 |- 1 : int -| {}
    {}, x : 't1 |- 0 : int -| {}
```
The inferred type of the function is `'t1 -> 't`, with constraints `'t1 = bool`
and `'t = int`. Simplifying that, the function's type is `bool -> int`.

**Function application.** The type of the entire application must be inferred,
because we don't yet know anything about the types of either subexpression:
```
env |- e1 e2 : 't -| C1, C2, t1 = t2 -> 't
  if fresh 't
  and env |- e1 : t1 -| C1
  and env |- e2 : t2 -| C2
```
We introduce a fresh type variable `'t` for the type of the application
expression. We use inference to determine the types of the subexpressions and
any constraints they happen to generate. We add one new constraint,
`t1 = t2 -> 't`, which expresses that the type of the left-hand side `e1` must
be a function that takes in an argument of type `t2` and returns a value of type
`'t`.

**Example.** Let `I` be the _initial environment_ that binds the boolean
operators. Let's infer the type of a partial application of `( + )`:
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
Stripping the `int ->` off the left-hand side of each of those function types,
we are left with
```
int -> int
=
't
```
Hence the type of `( + ) 1` is `int -> int`.

## Solving constraint sets

We've now given an algorithm for generating types and constraint sets. But we've
been waving our hands about how to solve the constraint set. The small examples
we've seen so far have been easy to solve in our heads. For a large program,
that won't be true. So let's turn our attention to that problem, next.
