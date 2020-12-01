# Solving Constraints

What does it mean to solve a set of constraints? Since constraints are equations
on types, it's much like solving a system of equations in algebra. We want to
solve for the values of the variables appearing in those equations.  By
substituting those values for the variables, we should get equations that
are identical on both sides.  For example, in algebra we might have:
```
5x + 2y =  9
 x -  y = -1
```
Solving that system, we'd get that `x = 1` and `y = 2`.  If we substitute
`1` for `x` and `2` for `y`, we get:
```
5(1) + 2(2) =  9
  1  -   2  = -1
```
which reduces to
```
 9 =  9
-1 = -1
```
In programming languages terminology (though perhaps not high-school algebra),
we say that the substitutions `{1 / x}` and `{2 / y}` together *unify* that set
of equations, because they make each equation "unite" such that its left side is
identical to its right side.

Solving systems of equations on types is similar.  Just as we found numbers
to substitute for variables above, we now want to find types to substitute
for type variables, and thereby unify the set of equations.

## Type substitutions

Much like the substitutions we defined before for the substitution model of
evaluation, we'll write `{t / 'x}` for the *type substitution* that maps type
variable `'x` to type `t`. For example, `{t2/'x} t1` means type `t1` with
`t2` substituted for `'x`.

We can define substitution on types as follows:
```
int {t / 'x} = int
bool {t / 'x} = bool
'x {t / 'x} = t
'y {t / 'x} = 'y
(t1 -> t2) {t / 'x} =  (t1 {t / 'x} ) -> (t2 {t / 'x} )
```

Given two substitutions `S1` and `S2`, we write `S1; S2` to mean the
substitution that is their *sequential composition*, which is defined as
follows:
```
t (S1; S2) = (t S1) S2
```
The order matters. For example, `'x ({('y -> 'y) / 'x}; {bool / 'y}) ` is
`bool -> bool`, not `'y -> 'y`. We can build up bigger and bigger substitutions
this way.

A substitution `S` can be applied to a constraint `t = t'`. The result
`(t = t') S` is defined to be `t S = t' S`. So we just apply the
substitution on both sides of the constraint.

Finally a substitution can be applied to a set `C` of constraints; the result
`C S` is the result of applying `S` to each of the individual constraints in
`C`.

## Unification

A substitution *unifies* a constraint `t_1 = t_2` if `S t_1` results in the same
type as `S t_2`. For example, substitution `S = {int -> int / 'y}; {int / 'x}`
unifies constraint `'x -> ('x -> int) = int -> 'y`, because
```
('x -> ('x -> int)) S
=
int -> (int -> int)
```
and
```
(int -> 'y) S
=
int -> (int -> int)
```

A substitution `S` unifies a set `C` of constraints if `S` unifies every
constraint in `C`.

## The unification algorithm

At last we can precisely say what it means to solve a set of constraints:
we must find a substitution that unifies the set.  That is, we need to find
a sequence of maps from type variables to types, such that the sequence causes
each equation in the constraint set to "unite", meaning that its left-hand
side and right-hand side become the same.

To find a substitution that unifies constraint set `C`, we use an algorithm
`unify`, which is defined as follows:

- If `C` is the empty set, then `unify(C)` is the empty substitution.

- If `C` contains at least one constraint `t1 = t2` and possibly some other
  constraints `C'`, then `unify(C)` is defined as follows:

    - If `t1` and `t2` are both the same type variable, e.g. `'x`, 
      then return `unify(C')`.  *In this case, the constraint contained
      no useful information, so we're tossing it out and continuing.*

    - If `t1` is a type variable `'x` and `'x` does not occur in `t2`, 
      then let `S = {t2 / 'x}`, and return `S; unify(C' S)`.  *In this case,
      we are eliminating the variable `'x` from the system of equations, much
      like Gaussian elimination in solving algebraic equations.*

    - If `t2` is a type variable `'x` and `'x` does not occur in `t1`, 
      then let `S = {t1 / 'x}`, and return `S'; unify(C' S)`. *This is an
      elimination like the previous case.*

    - If `t1 = i1 -> o1` and `t2 = i2 -> o2`, where `i1`, `i2`, `o1`, and `o2`
      are types, then `unify(i1 = i2, o1 = o2, C')`.  *In this case, we
      break one constraint down into two smaller constraints and add those
      constraints back in to be further unified.*

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
that it produces a result if and only a unifier actually exists&mdash;that is,
if and only if the set of constraints has a solution. Moreover, the solution the
algorithm produces is the *most general unifier*, in the sense that if
`S = unify(C)` and `S'` also unifies `C`, then there must exist some `S''` such
that `S' = S; S''`. Such an `S'` is less general than `S` because it contains
the additional substitutions of `S''`.

