# The Environment Model

So far we've been using the substitution model to evaluate
programs.  It's a great mental model for evaluation,
and it's commonly used in programming languages theory.

But when it comes to implementation, the substitution model
is not the best choice.  It's too *eager*: it substitutes
for every occurrence of a variable, even if that occurrence
will never be needed.  For example, `let x = 42 in e`
will require crawling over all of `e`, which might be
a very large expression, even if `x` never occurs in `e`,
or even if `x` occurs only inside a branch of an if expression
that never ends up being evaluated.

For sake of efficiency, it would be better to substitute
*lazily*: only when the value of a variable is needed should
the interpreter have to do the substitution.  That's the key
idea behind the *environment model*.  In this model, there
is a data structure called the *dynamic environment*, or just
"environment" for short, that is a dictionary mapping variable
names to values.  Whenever the value of a variable is needed,
it's looked up in that dictionary.

To account for the environment, the evaluation relation needs
to change.  Instead of `e --> e'` or `e ==> v`, both of which
are binary relations, we now need a ternary relation, which
is either

* `<env, e> --> e`, or

* `<env, e> ==> v`,

where `env` denotes the environment, and `<env, e>` is called
a *machine configuration*.  That configuration represents the state
of the computer as it evaluates a program:  `env` represents
a part of the computer's memory (the binding of variables to values),
and `e` represents the program.

As notation, let:

* `{}` represent the empty environment,

* `{x1:v1, x2:v2, ...}` represent the environment that
  binds `x1` to `v1`, etc.,

* `env[x -> v]` represent the environment `env` with the variable
  `x` additionally bound to the value `v`, and
  
* `env(x)` represent the binding of `x` in `env`.

We'll concentrate in the rest of this chapter on the big-step version
of the environment model.  It would of course be possible to define
a small-step version, too.
