# Unification

What does it mean to solve a set of constraints? To answer this
question, we define *type substitutions*. A type substitution is a map
from a type variable to a type. We'll write `{t/X}` for the
substitution that maps type variable `X` to type `t`. The way a
substitution `S` operates on a type can be defined recursively:

```
S(X)        = if S = {t/X} then t else X
S(t1 -> t2) = S(t1) -> S(t2)
```

A substitution `S` can be applied to a constraint `t = t'`; the result
`S(t = t')` is defined to be `S(t) = S(t')`. And a substitution can be
applied to a set `C` of constraints; the result `S(C)` is the result of
applying `S` to each of the individual constraints in `C`.

Given two substitutions `S` and `S'`, we write `S;S'` for their
composition: `(S;S')(t) = S'(S(t))`.

A substitution *unifies* a constraint `t_1 = t_2` if `S(t_1) = S(t_2)`.
A substitution `S` unifies a set `C` of constraints if `S` unifies every
constraint in `C`. For example, substitution
`S = {int->int/Y};{int/X}` unifies constraint `X -> (X -> int) = int -> Y`.

To solve a set of constraints `C`, we need to find a substitution that
unifies `C`. If there are no substitutions that unify `C`, where `C`
is the constraints generated from expression `e`, then `e` is not
typeable.

To find a substitution that unifies `C`, we use an algorithm
appropriately called the *unification* algorithm. It is defined as
follows:

- if `C` is the empty set, then `unify(C)` is the empty substitution.

- if `C` is the union of a constraint `t = t'` with other constraints `C'`, then
  `unify(C)` is defined as follows, based on that constraint:

    - if `t` and `t'` are both the same type variable, e.g. `X`, 
      then return `unify(C')`.

    - if `t = X` for some type variable `X`, and `X` does not occur in `t'`, 
      then let `S = {t'/X}`, and return `unify(S(C'));S`.

    - if `t' = X` for some type variable `X`, and `X` does not occur in `t`, 
      then let `S = {t/X}`, and return `unify(S(C'));S`.

    - if `t = t0 -> t1` and `t' = t'0 -> t'1`,
      then let `C''` be the union of `C'` with the constraints
      `t0 = t'0` and `t1 = t'1`, and return `unify(C'')`.
      
    - if `t = t0 * t1` and `t' = t'0 * t'1`,
      then let `C''` be the union of `C'` with the constraints
      `t0 = t'0` and `t1 = t'1`, and return `unify(C'')`.
      
    - if `t = (t0, ..., tn) tc` and `t' = (t'0, ..., t'n) tc` for some 
      type constructor `tc`,
      then let `C''` be the union of `C'` with the constraints
      `ti = t'i`, and return `unify(C'')`.

    - otherwise, fail. There is no possible unifier.

In the second and third subcases, the check that `X` should
not occur in `t` ensures that the algorithm doesn't produce a cyclic
substitution&mdash;for example, `{(X -> X) / X}`.

It's possible to prove that the unification algorithm always terminates,
and that it produces a result if and only a unifier actually exists&mdash;that
is, if and only if the set of constraints has a solution. Moreover, the
solution the algorithm produces is the *most general unifier*, in the
sense that if `S = unify(C)` and `S'` unifies `C`, then there
must exist some `S''` such that `S' = S;S''`.

If `R` is the type variable assigned to represent the type of the entire
expression `e`, and if `S` is the substitution produced by the
algorithm, then `S(R)` is the type inferred for `e` by HM type
inference. Call that type `t`. It's possible to prove `t` is the
*principal* type for the expression, meaning that if `e` also has type
`t'` for any other `t'`, then there exists a substitution `S` such that
`t' = S(t)`. So HM actually infers the most lenient type that is possible 
for any expression.

## Let expressions

Consider the following code:

```
let double f z = f (f z) in
(double (fun x -> x+1) 1, double (fun x -> not x) false)
```

The inferred type for `f` in `double` would be `X -> X`. In the
algorithm we've described so far, the use of `double` in the first
component of the pair would produce the constraint `X = int`, and the
use of `double` in the definition of `b` would produce the constraint `X
= bool`. Those constraints would be contradictory, causing unification
to fail! 

There is a very nice solution to this called *let-polymorphism*, which
is what OCaml actually uses. Let-polymorphism enables a polymorphic
function bound by a `let` expression behave as though it has multiple
types. The essential idea is to allow each usage of a polymorphic
function to have its own instantiation of the type variables, so that
contradictions like the one above can't happen.  We won't cover
let-polymorphism here.
