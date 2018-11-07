# Evaluating the Lambda Calculus in the Environment Model

Recall that the lambda calculus is the fragment of a functional
language involving functions and application:
```
e ::= x | e1 e2 | fun x -> e

v ::= fun x -> e
```

Let's explore how to define a big-step evaluation relation
for the lambda calculus in the environment model.

## A First Attempt

The rule for variables just says to look up the variable name
in the environment:
```
<env, x> ==> env(x)
```

This rule for functions says that an anonymous function evaluates
just to itself.  After all, functions are values: 
```
<env, fun x -> e> ==> fun x -> e
```

Finally, this rule for application says to evaluate the left-hand
side `e1` to a function `fun x -> e`, the right-hand side to a value `v2`,
then to evaluate the body `e` of the function in an extended environment
that maps the function's argument `x` to `v2`:
```
<env, e1 e2> ==> v
  if <env, e1> ==> fun x -> e
  and <env, e2> ==> v2
  and <env[x -> v2], e> ==> v
```

Seems reasonable, right?  The problem is, **it's wrong.** At least,
it's wrong if you want evaluation to behave the same as OCaml.
Or, to be honest, nearly any other modern language.

It will be easier to explain why it's wrong if we add two more
language feature: let expressions and integer constants. 
Integer constants would evaluate to themselves:
```
<env, i> ==> i
```
As for let expressions, recall that we don't actually *need* them,
because `let x = e1 in e2` can be rewritten as `(fun x -> e2) e1`. 
Nonetheless, their semantics would be:
```
<env, let x = e1 in e2> ==> v
  if <env, e1> ==> v1
  and <env[x -> v1], e2> ==> v
```
Which is a rule that really just follows from the other rules above,
using that rewriting.

Now, what would this expression evaluate to?
```
let x = 1 in
let f = fun y -> x in
let x = 2 in
f 0
```

According to our semantics thus far, it would evaluate as follows:

* `let x = 1` would produce the environment `{x:1}`.
* `let f = fun y -> x` would produce the environment
  `{x:1, f:(fun y -> x)}`.
* `let x = 2` would produce the environment
  `{x:2, f:(fun y -> x)}`.  Note how the binding of `x` to `1` is
  shadowed by the new binding.
* Now we would evaluate `<{x:2, f:(fun y -> x)}, f 0>`:
  ```
  <{x:2, f:(fun y -> x)}, f 0> ==> 2
	because <{x:2, f:(fun y -> x)}, f> ==> fun y -> x
	and <{x:2, f:(fun y -> x)}, 0> ==> 0
	and <{x:2, f:(fun y -> x)}[y -> 0], x> ==> 2`
	  because <{x:2, f:(fun y -> x), y:0}, x> ==> 2`
  ```
* The result is therefore `2`.

But according to utop (and the substitution model), 
it evalutes as follows:
```
# let x = 1 in
  let f = fun y -> x in
  let x = 2 in
  f 0;;
- : int = 1
```
And the result is therefore `1`.  Obviously, `1` and `2` are
different answers!

What went wrong??  It has to do with scope.

## Dynamic vs. Static Scope

There are two different ways to understand the scope of a variable:
variables can be *dynamically* scoped or *lexically* scoped.  
It all comes down to the environment that is used when a function body
is being evaluated:

* With the **rule of dynamic scope**, the body of a function is 
  evaluated in the current dynamic environment at the time the 
  function is applied, not the old dynamic environment that existed 
  at the time the function was defined.
  
* With the **rule of lexical scope**, the body of a function is
  evaluated in the old dynamic environment that existed at the time the 
  function was defined, not the current environment when the function 
  is applied.

The rule of dynamic scope is what our semantics, above, implemented.
Let's look back at the semantics of function application:
```
<env, e1 e2> ==> v
  if <env, e1> ==> fun x -> e
  and <env, e2> ==> v2
  and <env[x -> v2], e> ==> v
```
Note how the body `e` is being evaluated in the same environment `env`
as when the function is applied.  In the example program
```
let x = 1 in
let f = fun y -> x in
let x = 2 in
f 0
```
that means that `f` is evaluated in an environment in which `x`
is bound to `2`, because that's the most recent binding of `x`.

But OCaml implements the rule of lexical scope, which coincides
with the substitution model.  With that rule, `x` is bound to `1`
in the body of `f` when `f` is defined, and the later binding
of `x` to `2` doesn't change that fact.

The consensus after decades of experience with programming language 
design is that lexical scope is the right choice.  Perhaps the main
reason for that is that lexical scope supports the Principle of Name 
Irrelevance.  Recall, that principle says that the name of a variable 
shouldn't matter to the meaning of program, as long as the name is
used consistently. 

Nonetheless, dynamic scope is useful in some situations.
Some languages use it as the norm (e.g., Emacs LISP, LaTeX),
and some languages have special ways to do it (e.g., Perl, Racket).
But these days, most languages just don’t have it.

There is one language feature that modern languages *do* have
that resembles dynamic scope, and that is exceptions.
Exception handling resembles dynamic scope, in that
raising an exception transfers control to the "most recent"
exception handler, just like how dynamic scope uses 
the "most recent" binding of variable.

## A Second Attempt

The question then becomes, how do we implement lexical scope?
It seems to require time travel, because function bodies
need to be evaluated in old dynamic environment that have long
since disappeared.

The answer is that the language implementation must arrange
to keep old environments around.  And that is indeed what
OCaml and other languages must do.  They use a data
structure called a *closure* for this purpose.  

A closure has two parts:

* a *code* part, which contains a function `fun x -> e`, and
* an *environment* part, which contains the environment `env` at the
  time that function was defined.
  
You can think of a closure as being like a pair, except that
there's no way to directly write a closure in OCaml source code,
and there's no way to destruct the pair into its components
in OCaml source code.  The pair is entirely hidden from you
by the language implementation.

Let's notate a closure as `(| fun x -> e, env |)`.  The delimiters
`(| ... |)` are meant to evoke an OCaml pair, but of course they
are not legal OCaml syntax.

Using that notation, we can re-define the evaluation relation as follows:

The rule for functions now says that an anonymous function evaluates
to a closure:
```
<env, fun x -> e> ==> (| fun x -> e, env |)
```
That rule saves the defining environment as part of the closure,
so that it can be used at some future point.

The rule for application says to use that closure:
```
<env, e1 e2> ==> v
  if <env, e1> ==> (| fun x -> e, defenv |)
  and <env, e2> ==> v2
  and <defenv[x -> v2], e> ==> v
```
That rule uses the closure's environment `defenv` (whose name 
is meant to suggest the "defining environment") to evaluate
the function body `e`.

The derived rule for let expressions remains unchanged:
```
<env, let x = e1 in e2> ==> v
  if <env, e1> ==> v1
  and <env[x -> v1], e2> ==> v
```
That's because the defining environment for the body `e2`
is the same as the current environment `env` when the let
expression is being evaluated.
  
## An Implementation

You can [download](lambda-env.zip) a complete implementation
of the two semantics above.  In the [main.ml](lambda-env/main.ml)
file, there is a definition named `scope` that you can use to switch 
between lexical and dynamic scope.
