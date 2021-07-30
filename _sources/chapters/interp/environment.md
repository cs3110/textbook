# Environment Model

So far we've been using the substitution model to evaluate programs. It's a
great mental model for evaluation, and it's commonly used in programming
languages theory.

But when it comes to implementation, the substitution model is not the best
choice. It's too *eager*: it substitutes for every occurrence of a variable,
even if that occurrence will never be needed. For example, `let x = 42 in e`
will require crawling over all of `e`, which might be a very large expression,
even if `x` never occurs in `e`, or even if `x` occurs only inside a branch of
an if expression that never ends up being evaluated.

For sake of efficiency, it would be better to substitute *lazily*: only when the
value of a variable is needed should the interpreter have to do the
substitution. That's the key idea behind the *environment model*. In this model,
there is a data structure called the *dynamic environment*, or just
"environment" for short, that is a dictionary mapping variable names to values.
Whenever the value of a variable is needed, it's looked up in that dictionary.

To account for the environment, the evaluation relation needs to change. Instead
of `e --> e'` or `e ==> v`, both of which are binary relations, we now need a
ternary relation, which is either

* `<env, e> --> e`, or

* `<env, e> ==> v`,

where `env` denotes the environment, and `<env, e>` is called a *machine
configuration*. That configuration represents the state of the computer as it
evaluates a program: `env` represents a part of the computer's memory (the
binding of variables to values), and `e` represents the program.

As notation, let:

* `{}` represent the empty environment,

* `{x1:v1, x2:v2, ...}` represent the environment that binds `x1` to `v1`, etc.,

* `env[x -> v]` represent the environment `env` with the variable `x`
  additionally bound to the value `v`, and

* `env(x)` represent the binding of `x` in `env`.

We'll concentrate in the rest of this chapter on the big-step version of the
environment model. It would of course be possible to define a small-step
version, too.

## Evaluating the Lambda Calculus in the Environment Model

Recall that the lambda calculus is the fragment of a functional language
involving functions and application:

```text
e ::= x | e1 e2 | fun x -> e

v ::= fun x -> e
```

Let's explore how to define a big-step evaluation relation for the lambda
calculus in the environment model. The rule for variables just says to look up
the variable name in the environment:

```text
<env, x> ==> env(x)
```

This rule for functions says that an anonymous function evaluates
just to itself.  After all, functions are values:

```text
<env, fun x -> e> ==> fun x -> e
```

Finally, this rule for application says to evaluate the left-hand side `e1` to a
function `fun x -> e`, the right-hand side to a value `v2`, then to evaluate the
body `e` of the function in an extended environment that maps the function's
argument `x` to `v2`:

```text
<env, e1 e2> ==> v
  if <env, e1> ==> fun x -> e
  and <env, e2> ==> v2
  and <env[x -> v2], e> ==> v
```

Seems reasonable, right? The problem is, **it's wrong.** At least, it's wrong if
you want evaluation to behave the same as OCaml. Or, to be honest, nearly any
other modern language.

It will be easier to explain why it's wrong if we add two more language feature:
let expressions and integer constants. Integer constants would evaluate to
themselves:

```text
<env, i> ==> i
```

As for let expressions, recall that we don't actually *need* them,
because `let x = e1 in e2` can be rewritten as `(fun x -> e2) e1`.
Nonetheless, their semantics would be:

```text
<env, let x = e1 in e2> ==> v
  if <env, e1> ==> v1
  and <env[x -> v1], e2> ==> v
```

Which is a rule that really just follows from the other rules above, using that
rewriting.

What would this expression evaluate to?

```text
let x = 1 in
let f = fun y -> x in
let x = 2 in
f 0
```

According to our semantics thus far, it would evaluate as follows:

* `let x = 1` would produce the environment `{x:1}`.
* `let f = fun y -> x` would produce the environment `{x:1, f:(fun y -> x)}`.
* `let x = 2` would produce the environment `{x:2, f:(fun y -> x)}`. Note how
  the binding of `x` to `1` is shadowed by the new binding.
* Now we would evaluate `<{x:2, f:(fun y -> x)}, f 0>`:
  ```
  <{x:2, f:(fun y -> x)}, f 0> ==> 2
	because <{x:2, f:(fun y -> x)}, f> ==> fun y -> x
	and <{x:2, f:(fun y -> x)}, 0> ==> 0
	and <{x:2, f:(fun y -> x)}[y -> 0], x> ==> 2`
	  because <{x:2, f:(fun y -> x), y:0}, x> ==> 2`
  ```
* The result is therefore `2`.

But according to utop (and the substitution model), it evaluates as follows:

```ocaml
# let x = 1 in
  let f = fun y -> x in
  let x = 2 in
  f 0;;
- : int = 1
```

And the result is therefore `1`. Obviously, `1` and `2` are different answers!

What went wrong??  It has to do with scope.

## Dynamic vs. Static Scope

There are two different ways to understand the scope of a variable: variables
can be *dynamically* scoped or *lexically* scoped. It all comes down to the
environment that is used when a function body is being evaluated:

* With the **rule of dynamic scope**, the body of a function is evaluated in the
  current dynamic environment at the time the function is applied, not the old
  dynamic environment that existed at the time the function was defined.

* With the **rule of lexical scope**, the body of a function is evaluated in the
  old dynamic environment that existed at the time the function was defined, not
  the current environment when the function is applied.

The rule of dynamic scope is what our semantics, above, implemented. Let's look
back at the semantics of function application:

```text
<env, e1 e2> ==> v
  if <env, e1> ==> fun x -> e
  and <env, e2> ==> v2
  and <env[x -> v2], e> ==> v
```

Note how the body `e` is being evaluated in the same environment `env`
as when the function is applied.  In the example program

```text
let x = 1 in
let f = fun y -> x in
let x = 2 in
f 0
```

that means that `f` is evaluated in an environment in which `x` is bound to `2`,
because that's the most recent binding of `x`.

But OCaml implements the rule of lexical scope, which coincides with the
substitution model. With that rule, `x` is bound to `1` in the body of `f` when
`f` is defined, and the later binding of `x` to `2` doesn't change that fact.

The consensus after decades of experience with programming language design is
that lexical scope is the right choice. Perhaps the main reason for that is that
lexical scope supports the Principle of Name Irrelevance. Recall, that principle
says that the name of a variable shouldn't matter to the meaning of program, as
long as the name is used consistently.

Nonetheless, dynamic scope is useful in some situations. Some languages use it
as the norm (e.g., Emacs LISP, LaTeX), and some languages have special ways to
do it (e.g., Perl, Racket). But these days, most languages just don’t have it.

There is one language feature that modern languages *do* have that resembles
dynamic scope, and that is exceptions. Exception handling resembles dynamic
scope, in that raising an exception transfers control to the "most recent"
exception handler, just like how dynamic scope uses the "most recent" binding of
variable.

## A Second Attempt at Evaluating the Lambda Calculus in the Environment Model

The question then becomes, how do we implement lexical scope? It seems to
require time travel, because function bodies need to be evaluated in old dynamic
environment that have long since disappeared.

The answer is that the language implementation must arrange to keep old
environments around. And that is indeed what OCaml and other languages must do.
They use a data structure called a *closure* for this purpose.

A closure has two parts:

* a *code* part, which contains a function `fun x -> e`, and

* an *environment* part, which contains the environment `env` at the time that
  function was defined.

You can think of a closure as being like a pair, except that there's no way to
directly write a closure in OCaml source code, and there's no way to destruct
the pair into its components in OCaml source code. The pair is entirely hidden
from you by the language implementation.

Let's notate a closure as `(| fun x -> e, env |)`. The delimiters `(| ... |)`
are meant to evoke an OCaml pair, but of course they are not legal OCaml syntax.

Using that notation, we can re-define the evaluation relation as follows:

The rule for functions now says that an anonymous function evaluates to a
closure:

```text
<env, fun x -> e> ==> (| fun x -> e, env |)
```

That rule saves the defining environment as part of the closure, so that it can
be used at some future point.

The rule for application says to use that closure:

```text
<env, e1 e2> ==> v
  if <env, e1> ==> (| fun x -> e, defenv |)
  and <env, e2> ==> v2
  and <defenv[x -> v2], e> ==> v
```

That rule uses the closure's environment `defenv` (whose name is meant to
suggest the "defining environment") to evaluate the function body `e`.

The derived rule for let expressions remains unchanged:

```text
<env, let x = e1 in e2> ==> v
  if <env, e1> ==> v1
  and <env[x -> v1], e2> ==> v
```

That's because the defining environment for the body `e2` is the same as the
current environment `env` when the let expression is being evaluated.

## An Implementation of SimPL in the Environment Model

You can download a complete implementation of the two semantics above: {{
code_link | replace("%%NAME%%", "lambda-env.zip") }} In `main.ml`, there is a
definition named `scope` that you can use to switch between lexical and dynamic
scope.

## Evaluating Core OCaml in the Environment Model

There isn't anything new in the (big step) environment model semantics of Core
OCaml, now that we know about closures, but for sake of completeness let's state
it anyway.

**Syntax.**

```text
e ::= x | e1 e2 | fun x -> e
    | i | b | e1 + e2
    | (e1,e2) | fst e1 | snd e2
    | Left e | Right e
    | match e with Left x1 -> e1 | Right x2 -> e2
    | if e1 then e2 else e3
    | let x = e1 in e2
```

**Semantics.**

We've already seen the semantics of the lambda calculus fragment of Core OCaml:

```text
<env, x> ==> v
  if env(x) = v

<env, e1 e2> ==> v
  if  <env, e1> ==> (| fun x -> e, defenv |)
  and <env, e2> ==> v2
  and <defenv[x -> v2], e> ==> v

<env, fun x -> e> ==> (|fun x -> e, env|)
```

Evaluation of constants ignores the environment:

```text
<env, i> ==> i

<env, b> ==> b
```

Evaluation of most other language features just uses the environment without
changing it:

```text
<env, e1 + e2> ==> n
  if  <env,e1> ==> n1
  and <env,e2> ==> n2
  and n is the result of applying the primitive operation + to n1 and n2

<env, (e1, e2)> ==> (v1, v2)
  if  <env, e1> ==> v1
  and <env, e2> ==> v2

<env, fst e> ==> v1
  if <env, e> ==> (v1, v2)

<env, snd e> ==> v2
  if <env, e> ==> (v1, v2)

<env, Left e> ==> Left v
  if <env, e> ==> v

<env, Right e> ==> Right v
  if <env, e> ==> v

<env, if e1 then e2 else e3> ==> v2
  if <env, e1> ==> true
  and <env, e2> ==> v2

<env, if e1 then e2 else e3> ==> v3
  if <env, e1> ==> false
  and <env, e3> ==> v3
```

Finally, evaluation of binding constructs (i.e., match
and let expression) extends the environment with a new binding:

```text
<env, match e with Left x1 -> e1 | Right x2 -> e2> ==> v1
  if  <env, e> ==> Left v
  and <env[x1 -> v], e1> ==> v1

<env, match e with Left x1 -> e1 | Right x2 -> e2> ==> v2
  if  <env, e> ==> Right v
  and <env[x2 -> v], e2> ==> v2

<env, let x = e1 in e2> ==> v2
  if  <env, e1> ==> v1
  and <env[x -> v1], e2> ==> v2
```
