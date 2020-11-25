# Let Polymorphism

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

## TODO

- The value restriction
- Exercises
