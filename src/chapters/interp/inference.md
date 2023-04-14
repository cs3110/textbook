# Type Inference

OCaml and Java are *statically typed* languages, meaning every binding has a
type that is determined at *compile time*&mdash;that is, before any part of the
program is executed. The type-checker is a compile-time procedure that either
accepts or rejects a program. By contrast, JavaScript and Ruby are
dynamically-typed languages; the type of a binding is not determined ahead of
time. Computations like binding 42 to `x` and then treating `x` as a string
therefore either result in run-time errors, or run-time conversion between
types.

Unlike Java, OCaml is *implicitly typed*, meaning programmers rarely need to
write down the types of bindings. This is often convenient, especially with
higher-order functions. (Although some people disagree as to whether it makes
code easier or harder to read). But implicit typing in no way changes the fact
that OCaml is statically typed. Rather, the type-checker has to be more
sophisticated because it must infer what the *type annotations* "would have
been" had the programmers written all of them. In principle, type inference and
type checking could be separate procedures (the inferencer could figure out the
types then the checker could determine whether the program is well-typed), but
in practice they are often merged into a single procedure called *type
reconstruction*.

## OCaml Type Reconstruction

{{ video_embed | replace("%%VID%%", "_yDo9Q9EOHY")}}

At a very high level, OCaml's type reconstruction algorithm works as follows:

- Determine the types of definitions in order, using the types of earlier
  definitions to infer the types of later ones. (Which is one reason you may not
  use a name before it is bound in an OCaml program.)

- For each `let` definition, analyze the definition to determine *constraints*
  about its type. For example, if the inferencer sees `x + 1`, it concludes that
  `x` must have type `int`. It gathers similar constraints for function
  applications, pattern matches, etc. Think of these constraints as a system of
  equations like you might have in algebra.

- Use that system of equations to solve for the type of the name being defined.

The OCaml type reconstruction algorithm attempts to never reject a program that
could type check, if the programmer had written down types. It also attempts
never to accept a program that cannot possibly type check. Some more obscure
parts of the language can sometimes make type annotations either necessary or at
least helpful (see *Real World OCaml* chapter 22, "Type inference", for
examples). But for most code you write, type annotations really are completely
optional.

Since it would be verbose to keep writing "the type reconstruction algorithm
used by OCaml and other functional languages," we'll call the algorithm HM. That
name is used throughout the programming languages literature, because the
algorithm was independently invented by Roger <u>H</u>indley and Robin
<u>M</u>ilner.

HM has been rediscovered many times by many people. Curry used it informally in
the 1950s (perhaps even the 1930s). He wrote it up formally in 1967 (published
1969). Hindley discovered it independently in 1969; Morris in 1968; and Milner
in 1978. In the realm of logic, similar ideas go back perhaps as far as Tarski
in the 1920s. Commenting on this history, Hindley wrote,

> There must be a moral to this story of continual re-discovery; perhaps someone
> along the line should have learned to read. Or someone else learn to write.

Although we haven't seen the HM algorithm yet, you probably won't be surprised
to learn that it's usually very efficient&mdash;you've probably never had to
wait for the toplevel to print the inferred types of your programs. In practice,
it runs in approximately linear time. But in theory, there are some very strange
programs that can cause its running-time to blow up. (Technically, it's
exponential time.) For fun, try typing the following code in utop:

```ocaml
# let b = true;;
# let f0 = fun x -> x + 1;;
# let f = fun x -> if b then f0 else fun y -> x y;;
# let f = fun x -> if b then f else fun y -> x y;;
# let f = fun x -> if b then f else fun y -> x y;;
(* keep repeating that last line *)
```

You'll see the types get longer and longer, and eventually (around 20
repetitions or so) type inference will cause a significant delay.

## Constraint-Based Inference

Let's build up to the HM type inference algorithm by starting with this little
language:

```text
e ::= x | i | b | e1 bop e2
    | if e1 then e2 else e3
    | fun x -> e
    | e1 e2

bop ::= + | * | <=

t ::= int | bool | t1 -> t2
```

That language is SimPL, plus the lambda calculus, minus `let` expressions. It
turns out `let` expressions add an extra layer of complication, so we'll come
back to them later.

Since anonymous functions in this language do not have type annotations, we have
to infer the type of the argument `x`. For example,

- In `fun x -> x + 1`, argument `x` must have type `int` hence the function has
  type `int -> int`.

- In `fun x -> if x then 1 else 0`, argument `x` must have type `bool` hence the
  function has type `bool -> int`.

- The function `fun x -> if x then x else 0` is untypeable, because it would
  require `x` to have both type `int` and `bool`, which isn't allowed.

**A Syntactic Simplification.** We can treat `e1 bop e2` as syntactic sugar for
`( bop ) e1 e2`. That is, we treat infix binary operators as prefix function
application. Let's introduce a new syntactic class `n` for *names*, which
generalize identifiers and operators. That changes the syntax to:

```text
e ::= n | i | b
    | if e1 then e2 else e3
    | fun x -> e
    | e1 e2

n ::= x | bop

bop ::= ( + ) | ( * ) | ( <= )

t ::= int | bool | t1 -> t2
```

We already know the types of those built-in operators:

```text
( + ) : int -> int -> int
( * ) : int -> int -> int
( <= ) : int -> int -> bool
```

Those types are given; we don't have to infer them. They are part of the initial
static environment. In OCaml those operator names could later be shadowed by
values with different types, but here we don't have to worry about that because
we don't yet have `let`.

How would *you* mentally infer the type of `fun x -> 1 + x`, or rather,
`fun x -> ( + ) 1 x`? It's automatic by now, but we could break it down into
pieces:

- Start with `x` having some unknown type `t`.
- Note that `( + )` is known to have type `int -> (int -> int)`.
- So its first argument must have type `int`.  Which `1` does.
- And its second argument must have type `int`, too. So `t = int`. That is a
  _constraint_ on `t`.
- Finally, the body of the function must also have type `int`, since that's the
  return type of `( + )`.
- Therefore, the type of the entire function must be `t -> int`.
- Since `t = int`, that type is `int -> int`.

The type inference algorithm follows the same idea of generating unknown types,
collecting constraints on them, and using the constraints to solve for the type
of the expression.

{{ video_embed | replace("%%VID%%", "hrl9Q68dIfQ")}}

Let's introduce a new quaternary relation `env |- e : t -| C`, which should be
read as follows: "in environment `env`, expression `e` is inferred to have type
`t` and generates constraint set `C`." A constraint is an equation of the form
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

{{ video_embed | replace("%%VID%%", "NkAt9eApGSw")}}

The easiest parts of inference are constants:

```text
env |- i : int -| {}

env |- b : bool -| {}
```

Any integer constant `i`, such as `42`, is known to have type `int`, and there
are no constraints generated.  Likewise for Boolean constants.

Inferring the type of a name requires looking it up in the environment:

```text
env |- n : env(n) -| {}
```

No constraints are generated.

If the name is not bound in the environment, the expression cannot be typed.
It's an unbound name error.

The remaining rules are at their core the same as the type-checking rules we saw
previously, but they each generate a _type variable_ and possibly some
constraints on that type variable.

**If.**

{{ video_embed | replace("%%VID%%", "0EHUTbWnYWw")}}

Here's the rule for `if` expressions:

```text
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

```text
t ::= 'x | int | bool | t1 -> t2
```

Some example type variables include `'a`, `'foobar`, and `'t`. In the last, `t`
is an identifier, not a meta-variable.

Here's an example:

```text
{} |- if true then 1 else 0 : 't -| bool = bool, 't = int
  {} |- true : bool -| {}
  {} |- 1 : int -| {}
  {} |- 0 : int -| {}
```

The full constraint set generated is
`{}, {}, {}, bool = bool, 't = int, 't = int`, but of course that simplifies to
just `bool = bool, 't = int`. From that constraint set we can see that the type
of `if true then 1 else 0` must be `int`.

**Anonymous functions.**

{{ video_embed | replace("%%VID%%", "y2Y2aRnxncE")}}

Since there is no type annotation on `x`, its type must be inferred:

```text
env |- fun x -> e : 't1 -> t2 -| C
  if fresh 't1
  and env, x : 't1 |- e : t2 -| C
```

We introduce a fresh type variable `'t1` to stand for the type of `x`, and infer
the type of body `e` under the environment in which `x : 't1`. Wherever `x` is
used in `e`, that can cause constraints to be generated involving `'t1`. Those
constraints will become part of `C`.

Here's a function where we can immediately see that `x : bool`, but let's work
through the inference:

```text
{} |- fun x -> if x then 1 else 0 : 't1 -> 't -| 't1 = bool, 't = int
  {}, x : 't1 |- if x then 1 else 0 : 't -| 't1 = bool, 't = int
    {}, x : 't1 |- x : 't1 -| {}
    {}, x : 't1 |- 1 : int -| {}
    {}, x : 't1 |- 0 : int -| {}
```

The inferred type of the function is `'t1 -> 't`, with constraints `'t1 = bool`
and `'t = int`. Simplifying that, the function's type is `bool -> int`.

**Function application.**

{{ video_embed | replace("%%VID%%", "2HRcvmQBWIM")}}

The type of the entire application must be inferred, because we don't yet know
anything about the types of either subexpression:

```text
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

Let `I` be the _initial environment_ that binds the boolean operators. Let's
infer the type of a partial application of `( + )`:

```text
I |- ( + ) 1 : 't -| int -> int -> int = int -> 't
  I |- ( + ) : int -> int -> int -| {}
  I |- 1 : int -| {}
```

From the resulting constraint, we see that

```text
int -> int -> int
=
int -> 't
```

Stripping the `int ->` off the left-hand side of each of those function types,
we are left with

```text
int -> int
=
't
```

Hence, the type of `( + ) 1` is `int -> int`.

## Solving Constraints

{{ video_embed | replace("%%VID%%", "o1wT8FC9hpE")}}

What does it mean to solve a set of constraints? Since constraints are equations
on types, it's much like solving a system of equations in algebra. We want to
solve for the values of the variables appearing in those equations. By
substituting those values for the variables, we should get equations that are
identical on both sides. For example, in algebra we might have:

```text
5x + 2y =  9
 x -  y = -1
```

Solving that system, we'd get that `x = 1` and `y = 2`.  If we substitute
`1` for `x` and `2` for `y`, we get:

```text
5(1) + 2(2) =  9
  1  -   2  = -1
```

which reduces to

```text
 9 =  9
-1 = -1
```

In programming languages terminology (though perhaps not high-school algebra),
we say that the substitutions `{1 / x}` and `{2 / y}` together *unify* that set
of equations, because they make each equation "unite" such that its left side is
identical to its right side.

{{ video_embed | replace("%%VID%%", "cNqPY5MSutM")}}

Solving systems of equations on types is similar. Just as we found numbers to
substitute for variables above, we now want to find types to substitute for type
variables, and thereby unify the set of equations.

Much like the substitutions we defined before for the substitution model of
evaluation, we'll write `{t / 'x}` for the *type substitution* that maps type
variable `'x` to type `t`. For example, `{t2/'x} t1` means type `t1` with `t2`
substituted for `'x`.

We can define substitution on types as follows:

```text
int {t / 'x} = int
bool {t / 'x} = bool
'x {t / 'x} = t
'y {t / 'x} = 'y
(t1 -> t2) {t / 'x} =  (t1 {t / 'x} ) -> (t2 {t / 'x} )
```

Given two substitutions `S1` and `S2`, we write `S1; S2` to mean the
substitution that is their *sequential composition*, which is defined as
follows:

```text
t (S1; S2) = (t S1) S2
```

The order matters. For example, `'x ({('y -> 'y) / 'x}; {bool / 'y}) ` is
`bool -> bool`, not `'y -> 'y`. We can build up bigger and bigger substitutions
this way.

A substitution `S` can be applied to a constraint `t = t'`. The result
`(t = t') S` is defined to be `t S = t' S`. So we just apply the substitution on
both sides of the constraint.

Finally, a substitution can be applied to a set `C` of constraints; the result
`C S` is the result of applying `S` to each of the individual constraints in
`C`.

A substitution *unifies* a constraint `t_1 = t_2` if `t_1 S` results in the same
type as `t_2 S`. For example, substitution `S = {int -> int / 'y}; {int / 'x}`
unifies constraint `'x -> ('x -> int) = int -> 'y`, because

```text
('x -> ('x -> int)) S
=
int -> (int -> int)
```

and

```text
(int -> 'y) S
=
int -> (int -> int)
```

A substitution `S` unifies a set `C` of constraints if `S` unifies every
constraint in `C`.

At last, we can precisely say what it means to solve a set of constraints: we
must find a substitution that unifies the set. That is, we need to find a
sequence of maps from type variables to types, such that the sequence causes
each equation in the constraint set to "unite", meaning that its left-hand side
and right-hand side become the same.

To find a substitution that unifies constraint set `C`, we use an algorithm
`unify`, which is defined as follows:

- If `C` is the empty set, then `unify(C)` is the empty substitution.

- If `C` contains at least one constraint `t1 = t2` and possibly some other
  constraints `C'`, then `unify(C)` is defined as follows:

    - If `t1` and `t2` are both the same simple type&mdash;i.e., both the same
      type variable `'x`, or both `int` or both `bool`&mdash; then return
      `unify(C')`. *In this case, the constraint contained no useful
      information, so we're tossing it out and continuing.*

    - If `t1` is a type variable `'x` and `'x` does not occur in `t2`, then let
      `S = {t2 / 'x}`, and return `S; unify(C' S)`. *In this case, we are
      eliminating the variable `'x` from the system of equations, much like
      Gaussian elimination in solving algebraic equations.*

    - If `t2` is a type variable `'x` and `'x` does not occur in `t1`, then let
      `S = {t1 / 'x}`, and return `S; unify(C' S)`. *This is an elimination
      like the previous case.*

    - If `t1 = i1 -> o1` and `t2 = i2 -> o2`, where `i1`, `i2`, `o1`, and `o2`
      are types, then `unify(i1 = i2, o1 = o2, C')`. *In this case, we break one
      constraint down into two smaller constraints and add those constraints
      back in to be further unified.*

    - Otherwise, fail. There is no possible unifier.

<!--
    - if `t = t0 * t1` and `t' = t'0 * t'1`,
      then let `C''` be the union of `C'` with the constraints
      `t0 = t'0` and `t1 = t'1`, and return `unify(C'')`.

    - if `t = (t0, ..., tn) tc` and `t' = (t'0, ..., t'n) tc` for some
      type constructor `tc`,
      then let `C''` be the union of `C'` with the constraints
      `ti = t'i`, and return `unify(C'')`.
-->

In the second and third subcases, the check that `'x` should not occur in the
type ensures that the algorithm is actually eliminating the variable. Otherwise,
the algorithm could end up re-introducing the variable instead of eliminating
it.

It's possible to prove that the unification algorithm always terminates, and
that it produces a result if and only if a unifier actually exists&mdash;that is,
if and only if the set of constraints has a solution. Moreover, the solution the
algorithm produces is the *most general unifier*, in the sense that if
`S = unify(C)` and `S'` also unifies `C`, then there must exist some `S''` such
that `S' = S; S''`. Such an `S'` is less general than `S` because it contains
the additional substitutions of `S''`.

## Finishing Type Inference

Let's review what we've done so far. We started with this language:

```text
e ::= n | i | b
    | if e1 then e2 else e3
    | fun x -> e
    | e1 e2

n ::= x | bop

bop ::= ( + ) | ( * ) | ( <= )

t ::= int | bool | t1 -> t2
```

We then introduced an algorithm for inferring a type of an expression. That type
came along with a set of constraints. The algorithm was expressed in the form of
a relation `env |- e : t -| C`.

Next, we introduced the unification algorithm for solving constraint sets. That
algorithm produces as output a sequence `S` of substitutions, or it fails. If it
fails, then `e` is not typeable.

To finish type inference and reconstruct the type of `e`, we just compute `t S`.
That is, we apply the solution to the constraints to the type `t` produced by
constraint generation.

Let `p` be that type. That is, `p = t S`. It's possible to prove `p` is the
*principal* type for the expression, meaning that if `e` also has type `t` for
any other `t`, then there exists a substitution `S` such that `t = p S`.

For example, the principal type of the identity function `fun x -> x` would be
`'a -> 'a`. But you could also give that function the less helpful type
`int -> int`. What we're saying is that HM will produce `'a -> 'a`, not
`int -> int`. So in a sense, HM actually infers the most "lenient" type that is
possible for an expression.

**A Worked Example.** Let's infer the type of the following expression:

```ocaml
fun f -> fun x -> f (( + ) x 1)
```

It's not much code, but this will get quite involved!

{{ video_embed | replace("%%VID%%", "trmq3wYcUxU")}}

We start in the initial environment `I` that, among other things, maps `( + )`
to `int -> int -> int`.

```text
I |- fun f -> fun x -> f (( + ) x 1)
```

For now we leave off the `: t -| C`, because that's the output of constraint
generation. We haven't figured out the output yet! Since we have a function, we
use the function rule for inference to proceed by introducing a fresh type
variable for the argument:

```text
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1)  <-- Here
```

Again we have a function, hence a fresh type variable:
```text
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1)
    I, f : 'a, x : 'b |- f (( + ) x 1)  <-- Here
```

Now we have an application expression. Before dealing with it, we need to
descend into its subexpressions. The first one is easy. It's just a variable. So
we finally can finish a judgment with the variable's type from the environment,
and an empty constraint set.

```text
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1)
    I, f : 'a, x : 'b |- f (( + ) x 1)
      I, f : 'a, x : 'b |- f : 'a -| {}  <-- Here
```

Next is the second subexpression.

```text
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1)
    I, f : 'a, x : 'b |- f (( + ) x 1)
      I, f : 'a, x : 'b |- f : 'a -| {}
      I, f : 'a, x : 'b |- ( + ) x 1  <-- Here
```

That is another application, so we need to handle its subexpressions. Recall
that `( + ) x 1` is parsed as `(( + ) x) 1`. So the first subexpression is the
complicated one to handle.

```text
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1)
    I, f : 'a, x : 'b |- f (( + ) x 1)
      I, f : 'a, x : 'b |- f : 'a -| {}
      I, f : 'a, x : 'b |- ( + ) x 1
        I, f : 'a, x : 'b |- ( + ) x  <-- Here
```

Yet another application.

```text
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1)
    I, f : 'a, x : 'b |- f (( + ) x 1)
      I, f : 'a, x : 'b |- f : 'a -| {}
      I, f : 'a, x : 'b |- ( + ) x 1
        I, f : 'a, x : 'b |- ( + ) x
          I, f : 'a, x : 'b |- ( + ) : int -> int -> int -| {}  <-- Here
```

That one was easy, because we just had to look up the name `( + )` in the
environment. The next is also easy, because we just look up `x`.

```text
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1)
    I, f : 'a, x : 'b |- f (( + ) x 1)
      I, f : 'a, x : 'b |- f : 'a -| {}
      I, f : 'a, x : 'b |- ( + ) x 1
        I, f : 'a, x : 'b |- ( + ) x
          I, f : 'a, x : 'b |- ( + ) : int -> int -> int -| {}
          I, f : 'a, x : 'b |- x : 'b -| {}  <-- Here
```

At last, we're ready to resolve a function application! We introduce a fresh
type variable and add a constraint. The constraint is that the inferred type
`int -> int -> int` of the left-hand subexpression must equal the inferred type
`'b` of the right-hand subexpression arrow the fresh type variable `'c`, that
is, `'b -> 'c`.

```text
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1)
    I, f : 'a, x : 'b |- f (( + ) x 1)
      I, f : 'a, x : 'b |- f : 'a -| {}
      I, f : 'a, x : 'b |- ( + ) x 1
        I, f : 'a, x : 'b |- ( + ) x : 'c -| int -> int -> int = 'b -> 'c  <-- Here
          I, f : 'a, x : 'b |- ( + ) : int -> int -> int -| {}
          I, f : 'a, x : 'b |- x : 'b -| {}
```

Now we're ready for the argument being passed to that function.
```text
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1)
    I, f : 'a, x : 'b |- f (( + ) x 1)
      I, f : 'a, x : 'b |- f : 'a -| {}
      I, f : 'a, x : 'b |- ( + ) x 1
        I, f : 'a, x : 'b |- ( + ) x : 'c -| int -> int -> int = 'b -> 'c
          I, f : 'a, x : 'b |- ( + ) : int -> int -> int -| {}
          I, f : 'a, x : 'b |- x : 'b -| {}
        I, f : 'a, x : 'b |- 1 : int -| {}  <-- Here
```

Again we can resolve a function application with a new type variable
and constraint.

```text
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1)
    I, f : 'a, x : 'b |- f (( + ) x 1)
      I, f : 'a, x : 'b |- f : 'a -| {}
      I, f : 'a, x : 'b |- ( + ) x 1 : 'd -| 'c = int -> 'd, int -> int -> int = 'b -> 'c  <-- Here
        I, f : 'a, x : 'b |- ( + ) x : 'c -| int -> int -> int = 'b -> 'c
          I, f : 'a, x : 'b |- ( + ) : int -> int -> int -| {}
          I, f : 'a, x : 'b |- x : 'b -| {}
        I, f : 'a, x : 'b |- 1 : int -| {}
```

And once more, a function application, so a new type variable and a new
constraint.

```text
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1)
    I, f : 'a, x : 'b |- f (( + ) x 1) : 'e -| 'a = 'd -> 'e, 'c = int -> 'd, int -> int -> int = 'b -> 'c   <-- Here
      I, f : 'a, x : 'b |- f : 'a -| {}
      I, f : 'a, x : 'b |- ( + ) x 1 : 'd -| 'c = int -> 'd, int -> int -> int = 'b -> 'c
        I, f : 'a, x : 'b |- ( + ) x : 'c -| int -> int -> int = 'b -> 'c
          I, f : 'a, x : 'b |- ( + ) : int -> int -> int -| {}
          I, f : 'a, x : 'b |- x : 'b -| {}
        I, f : 'a, x : 'b |- 1 : int -| {}
```

Now we finally get to finish off an anonymous function.  Its inferred type
is the fresh type variable `'b` of its parameter `x`, arrow the inferred
type `e` of its body.

```text
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1) : 'b -> 'e -| 'a = 'd -> 'e, 'c = int -> 'd, int -> int -> int = 'b -> 'c   <-- Here
    I, f : 'a, x : 'b |- f (( + ) x 1) : 'e -| 'a = 'd -> 'e, 'c = int -> 'd, int -> int -> int = 'b -> 'c
      I, f : 'a, x : 'b |- f : 'a -| {}
      I, f : 'a, x : 'b |- ( + ) x 1 : 'd -| 'c = int -> 'd, int -> int -> int = 'b -> 'c
        I, f : 'a, x : 'b |- ( + ) x : 'c -| int -> int -> int = 'b -> 'c
          I, f : 'a, x : 'b |- ( + ) : int -> int -> int -| {}
          I, f : 'a, x : 'b |- x : 'b -| {}
        I, f : 'a, x : 'b |- 1 : int -| {}
```

And the last anonymous function can now be complete in the same way:

```text
I |- fun f -> fun x -> f (( + ) x 1) : 'a -> 'b -> 'e -| 'a = 'd -> 'e, 'c = int -> 'd, int -> int -> int = 'b -> 'c  <-- Here
  I, f : 'a |- fun x -> f (( + ) x 1) : 'b -> 'e -| 'a = 'd -> 'e, 'c = int -> 'd, int -> int -> int = 'b -> 'c
    I, f : 'a, x : 'b |- f (( + ) x 1) : 'e -| 'a = 'd -> 'e, 'c = int -> 'd, int -> int -> int = 'b -> 'c
       I, f : 'a, x : 'b |- f : 'a -| {}
       I, f : 'a, x : 'b |- ( + ) x 1 : 'd -| 'c = int -> 'd, int -> int -> int = 'b -> 'c
         I, f : 'a, x : 'b |- ( + ) x : 'c -| int -> int -> int = 'b -> 'c
           I, f : 'a, x : 'b |- ( + ) : int -> int -> int -| {}
           I, f : 'a, x : 'b |- x : 'b -| {}
         I, f : 'a, x : 'b |- 1 : int -| {}
```

As a result of constraint generation, we know that the type of the expression is
`'a -> 'b -> 'e`, where

```text
'a = 'd -> 'e
'c = int -> 'd
int -> int -> int = 'b -> 'c
```

To solve that system of equations, we use the unification algorithm:

```text
unify('a = 'd -> 'e, 'c = int -> 'd, int -> int -> int = 'b -> 'c)
```

The first constraint yields a substitution `{('d -> 'e) / 'a}`, which we record
as part of the solution, and also apply it to the remaining constraints:

```text
...
=
{('d -> 'e) / 'a}; unify(('c = int -> 'd, int -> int -> int = 'b -> 'c) {('d -> 'e) / 'a})
=
{('d -> 'e) / 'a}; unify('c = int -> 'd, int -> int -> int = 'b -> 'c)
```

The second constraint behaves similarly to the first:

```text
...
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; unify((int -> int -> int = 'b -> 'c) {(int -> 'd) / 'c})
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; unify(int -> int -> int = 'b -> int -> 'd)
```

The function constraint breaks down into two smaller constraints:

```text
...
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; unify(int = 'b, int -> int = int -> 'd)
```

We get another substitution:

```text
...
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; {int / 'b}; unify((int -> int = int -> 'd) {int / 'b})
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; {int / 'b}; unify(int -> int = int -> 'd)
```

Then we get to break down another function constraint:

```text
...
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; {int / 'b}; unify(int = int, int = 'd)
```

The first of the resulting new constraints is trivial and just gets dropped:

```text
...
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; {int / 'b}; unify(int = 'd)
```

The very last constraint gives us one more substitution:

```text
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; {int / 'b}; {int / 'd}
```

To finish, we apply the substitution output by unification to the type inferred
by constraint generation:

```text
('a -> 'b -> 'e) {('d -> 'e) / 'a}; {(int -> 'd) / 'c}; {int / 'b}; {int / 'd}
=
(('d -> 'e) -> 'b -> 'e) {(int -> 'd) / 'c}; {int / 'b}; {int / 'd}
=
(('d -> 'e) -> 'b -> 'e) {int / 'b}; {int / 'd}
=
(('d -> 'e) -> int -> 'e) {int / 'd}
=
(int -> 'e) -> int -> 'e
```

And indeed that is the same type that OCaml would infer for the original
expression:

```ocaml
# fun f -> fun x -> f (( + ) x 1);;
- : (int -> 'a) -> int -> 'a = <fun>
```

Except that OCaml uses a different type variable identifier. OCaml is nice to us
and "lowers" the type variables down to smaller letters of the alphabet. We
could do that too with a little extra work.

**Type Errors.** In reality there is yet another piece to type inference. If
unification fails, the compiler or interpreter needs to produce a helpful error
message. That's an important engineering challenge that we won't address here.
It requires keeping track of more than just constraints: we need to know why a
constraint was introduced, and the ramification of its violation. We also need
to track the constraint back to the lexical piece of code that produced it, so
that programmers can see where the problem occurs. And since it's possible that
constraints can be processed in many different orders, there are many possible
error messages that could be produced. Figuring out which one will lead the
programmer to the root cause of an error, instead of some downstream consequence
of it, is an area of ongoing research.

{{ video_embed | replace("%%VID%%", "1jjGyPA9o1g")}}

## Let Polymorphism

Now we'll add `let` expressions to our little language:

```text
e ::= x | i | b | e1 bop e2
    | if e1 then e2 else e3
    | fun x -> e
    | e1 e2
    | let x = e1 in e2   (* new *)
```

{{ video_embed | replace("%%VID%%", "tB8sDHFT54I")}}

It turns out type inference for them is considerably trickier than might be
expected. The naive approach would be to add this constraint generation rule:

```text
env |- let x = e1 in e2 : t2 -| C1, C2
  if env |- e1 : t1 -| C1
  and env, x : t1 |- e2 : t2 -| C2
```

From the type-checking perspective, that's the same rule we've always used.
And for many `let` expressions it works perfectly fine. For example:

```text
{} |- let x = 42 in x : int -| {}
  {} |- 42 : int -| {}
  x : int |- x : int -| {}
```

The problem is that when the value being bound is a polymorphic function, that
rule generates constraints that are too restrictive. For example, consider the
identity function:

```ocaml
let id = fun x -> x in
let a = id 0 in
id true
```

OCaml has no trouble inferring the type of `id` as `'a -> 'a` and permitting it
to be applied both to an `int` and a `bool`. But the rule above isn't so
permissive about application to both types. When we use it, we generate the
following types and constraints:

```text
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

{{ video_embed | replace("%%VID%%", "me-Ll7mjNh8")}}

The solution to the problem of polymorphism for `let` expressions is not simple.
It requires us to introduce a new kind of type: a *type scheme*. Type schemes
resemble *universal quantification* from mathematical logic. For example, in
logic you might write, "for all natural numbers $x$, it holds that $0 \cdot x
= 0$". The "for all" is the universal quantification: it abstracts away from a
particular $x$ and states a property that is true of all natural numbers.

A type scheme is written `'a . t`, where `'a` is a type variable and `t` is a
type in which `'a` may appear. For example, `'a . 'a -> 'a` is a type scheme. It
is the type of a function that takes in a value of type `'a` and returns a value
of type `'a`, for all `'a`. Thus, it is the type of the polymorphic identity
function.

We can also have many type variables to the left of the dot in a type scheme.
For example, `'a 'b . 'a -> 'b -> 'a` is the type of a function that takes in
two arguments and returns the first. In OCaml, we could write that as
`fun x y -> x`. Note that utop infers the type of it as we would expect:

```ocaml
# let f = fun x y -> x;;
val f : 'a -> 'b -> 'a = <fun>
```

But we could actually manually write down an annotation with a type scheme:

```ocaml
# let f : 'a 'b . 'a -> 'b -> 'a = fun x y -> x;;
val f : 'a -> 'b -> 'a = <fun>
```

Note that OCaml accepts our manual type annotation but doesn't include the
`'a 'b .` part of it in its output. **But it's implicitly there and always has
been.** In general, anytime OCaml has inferred a type `t` and that type has had
type variables in it, in reality it's a type scheme. For example, the type of
`List.length` is really a type scheme:

```ocaml
# let mylen : 'a . 'a list -> int = List.length;;
val mylen : 'a list -> int = <fun>
```

OCaml just doesn't bother outputting the list of type variables that are to the
left of the dot in the type scheme. Really they'd just clutter the output, and
many programmers never need to know about them. But now that you're learning
type inference, it's time for you to know.

Now that we have type schemes, we'll have static environments that map names to
type schemes. We can think of types as being special cases of type schemes in
which the list of type variables is empty. With type schemes, the `let` rule
changes in only one way from the naive rule above, which is the `generalize` on
the last line:

```text
env |- let x = e1 in e2 : t2 -| C1, C2
  if env |- e1 : t1 -| C1
  and generalize(C1, env, x : t1) |- e2 : t2 -| C2
```

The job of `generalize` is to take a type like `'a -> 'a` and _generalize_ it
into a type scheme like `'a . 'a -> 'a` in an environment `env` against
constraints `C1`. Let's come back to how it works in a minute. Before that,
there's one other rule that needs to change, which is the name rule:

```text
env |- n : instantiate(env(n)) -| {}
```

The only thing that changes there is that use of `instantiate`. Its job is to
take a type scheme like `'a . 'a -> 'a` and _instantiate_ it into a new type
(and here we strictly mean a type, not a type scheme) with fresh type variables.
For example, `'a . 'a -> 'a` could be instantiated as `'b -> 'b`, if `'b` isn't
yet in use anywhere else as a type variable.

Here's how those two revised rules work together to get our earlier example with
the identify function right:

```text
{} |- let id = fun x -> x in (let a = id 0 in id true)
  {} |- fun x -> x : 'a -> 'a -| {}
    x : 'a |- x : 'a -| {}
  id : 'a . 'a -> 'a |- let a = id 0 in id true   <--- POINT 1
```

Let's pause there at Point 1. When `id` is put into the environment by the `let`
rule, its type is generalized from `'a -> 'a` to `'a . 'a -> 'a`; that is, from
a type to a type scheme. That records the fact that each application of `id`
should get to use its own value for `'a`. Going on:

```text
{} |- let id = fun x -> x in (let a = id 0 in id true)
  {} |- fun x -> x : 'a -> 'a -| {}
    x : 'a |- x : 'a -| {}
  id : 'a . 'a -> 'a |- let a = id 0 in id true   <--- POINT 1
    id : 'a . 'a -> 'a |- id 0
      id : 'a . 'a -> 'a |- id : 'b -> 'b -| {}   <--- POINT 3
```

Pausing here at Point 3, when `id` is applied to `0`, we instantiate its type
variable `'a` with a fresh type variable `'b`. Let's finish:

```text
{} |- let id = fun x -> x in (let a = id 0 in id true) : 'e -| 'b -> 'b = int -> 'c, 'd -> 'd = bool -> 'e
  {} |- fun x -> x : 'a -> 'a -| {}
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
variable `'a` with a fresh type variable, this time `'d`. So the constraints
collected at Points 1 and 2 are no longer contradictory, because they are
talking about different type variables. Those constraints are:

```text
'b -> 'b = int -> 'c
'd -> 'd = bool -> 'e
```

The unification algorithm will therefore conclude:

```text
'b = int
'c = int
'd = bool
'e = bool
```

So the entire expression is successfully inferred to have type `bool`.

**Instantiation and Generalization.** We used two new functions, `instantiate`
and `generalize`, to define type inference for `let` expressions. We need to
define those functions.

The easy one is `instantiate`.  Given a type scheme `'a1 'a2 ... 'an . t`,
we instantiate it by:

- choosing `n` fresh type variables, and
- substituting each of those for `'a1` through `'an` in `t`.

Substitution is uncomplicated here, compared to how it was for evaluation in
the substitution model, because there is nothing in a type that can bind
variable names.

But `generalize` requires more work.  Here's the `let` rule again:

```text
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

```ocaml
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

```text
generalize(C1, env, x : t1) =
  env1, x : 'a1 ... 'an . u1
```

Returning to our example with the identify function from above, we had
`generalize({}, {}, x : 'a -> 'a)`. In that rather simple case, `unify`
discovers no new equalities from the environment, so `u1 = 'a -> 'a` and
`env1 = {}`. The only type variable in `u1` is `'a`, and it doesn't appear in
`env1`. So `'a` is generalized, yielding `'a . 'a -> 'a` as the type scheme for
`id`.

## Polymorphism and Mutability

{{ video_embed | replace("%%VID%%", "6tj9WrRqPeU")}}

There is yet one more complication to type inference for `let` expressions. It
appears when we add mutable references to the language. Consider this example
code, which does not type check in OCaml:

```ocaml
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

```ocaml
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
`int` everywhere. That's what yields an error on the final line:

```text
# !r true;;
Error: This expression has type bool but an expression was expected of type int
```

Since `r : (int -> int) ref`, we cannot apply `!r` to a `bool`.

We won't cover the implementation of weak type variables here.

But, let's not leave this topic of the interaction between polymorphic types and
mutability yet. You might be tempted to think that it's a phenomenon that
affects only OCaml. But indeed, even Java suffers.

Consider the following class hierarchy:

```java
class Animal { }
class Elephant extends Animal { }
class Rabbit extends Animal { }
```

Now suppose we create an array of animals:

```java
Animal[] a= new Rabbit[2]
```

Here we are using *subtype polymorphism* to assign an array of `Rabbit` objects
to an `Animal[]` reference. That's not the same as *parametric polymorphism* as
we've been using in OCaml, but it's nonetheless polymorphism.

What if we try this?

```java
a[0]= new Elephant()
```

Since `a` is typed as an `Animal` array, it stands to reason that we could
assign an elephant object into it, just as we could assign a rabbit object. And
indeed that code is fine according to the Java compiler. But Java gives us a
runtime error if we run that code!

```java
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
