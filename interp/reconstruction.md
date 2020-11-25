# Finishing Type Inference

Let's recap what we did in the last two sections.  We started with
this language:
```
e ::= n | i | b
    | if e1 then e2 else e3
    | fun x -> e
    | e1 e2

n ::= x | bop

bop ::= ( + ) | ( * ) | ( <= )

t ::= int | bool | t1 -> t2
```

We then introduced an algorithm for inferring a type of an expression. That
type came along with a set of constraints.  The algorithm was expressed
in the form of a relation `env |- e : t -| C`.

Next, we introduced the unification algorithm for solving constraint sets. That
algorithm produces as output a sequence `S` of substitutions, or it fails. If it
fails, then `e` is not typeable. The type inferencer then needs to construct an
error message based on the set of constraints. Creating a good, understandable,
helpful error message isn't easy! The order in which constraints and
subexpressions were processed can make messages unnecessarily hard to
understand. We won't delve deeper here.

To finish type inference and reconstruct the type of `e`, we just compute `t S`.
That is, we apply the solution to the contraints to the type `t` produced
by constraint generation.

Let `tp` be that type. That is, `tp = t S`. It's possible to prove `tp` is the
*principal* type for the expression, meaning that if `e` also has type `t` for
any other `t`, then there exists a substitution `S` such that `t = tp S`. 

For example, the principal type of the identity function `fun x -> x` would be
`'a -> 'a`. But you could also give that function the less helpful type
`int -> int`. What we're saying is that HM will produce `'a -> 'a`, not
`int -> int`. So in a sense, HM actually infers the most "lenient" type that is
possible for an expression.

## A worked example

Let's infer the type of the following expression:
```
fun f -> fun x -> f (( + ) x 1)
```
It's not much code, but this will get quite involved!

**Constraint generation.** We start in the initial environment `I` that, among
other things, maps `( + )` to `int -> int -> int`.
```
I |- fun f -> fun x -> f (( + ) x 1)
```
For now we leave off the `: t -| C`, because that's the output of constraint
generation. We haven't figure out the output yet! Since we have a function, we
use the function rule for inference to proceed by introducing a fresh type
variable for the argument:
```
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1)  <-- Here
```
Again we have a function, hence a fresh type variable:
```
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1) 
    I, f : 'a, x : 'b |- f (( + ) x 1)  <-- Here
```
Now we have an application application.  Before dealing with it, we need
to descend into its subexpressions.  The first one is easy.  It's just a
variable.  So we finally can finish a judgment with the variable's type
from the environment, and an empty contraint set.
```
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1) 
    I, f : 'a, x : 'b |- f (( + ) x 1)
      I, f : 'a, x : 'b |- f : 'a -| {}  <-- Here
```
Next is the second subexpression.
```
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1) 
    I, f : 'a, x : 'b |- f (( + ) x 1)
      I, f : 'a, x : 'b |- f : 'a -| {}
      I, f : 'a, x : 'b |- ( + ) x 1  <-- Here
```
That is another application, so we need to handle its subexpressions.
Recall that `( + ) x 1` is parsed as `(( + ) x) 1`. So the first
subexpression is the complicated one to handle.
```
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1) 
    I, f : 'a, x : 'b |- f (( + ) x 1)
      I, f : 'a, x : 'b |- f : 'a -| {}
      I, f : 'a, x : 'b |- ( + ) x 1
        I, f : 'a, x : 'b |- ( + ) x  <-- Here
```
Yet another application.
```
I |- fun f -> fun x -> f (( + ) x 1)
  I, f : 'a |- fun x -> f (( + ) x 1) 
    I, f : 'a, x : 'b |- f (( + ) x 1)
      I, f : 'a, x : 'b |- f : 'a -| {}
      I, f : 'a, x : 'b |- ( + ) x 1
        I, f : 'a, x : 'b |- ( + ) x
          I, f : 'a, x : 'b |- ( + ) : int -> int -> int -| {}  <-- Here
```
That one was easy, because we just had to look up the name `( + )` in the
environment.  The next is also easy, because we just look up `x`.
```
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
```
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
```
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
```
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
```
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
```
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
```
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

As a result of constraint generation, we know that the type of the expression
is `'a -> 'b -> 'e`, where 
```
'a = 'd -> 'e
'c = int -> 'd
int -> int -> int = 'b -> 'c
```

**Unification.** To solve that system of equations, we use the unification
algorithm:
```
unify('a = 'd -> 'e, 'c = int -> 'd, int -> int -> int = 'b -> 'c)
```
The first constraint yields a substitution `{('d -> 'e) / 'a}`, which we
record as part of the solution, and also apply it to the remaining constraints:
```
...
=
{('d -> 'e) / 'a}; unify(('c = int -> 'd, int -> int -> int = 'b -> 'c) {('d -> 'e) / 'a}
=
{('d -> 'e) / 'a}; unify('c = int -> 'd, int -> int -> int = 'b -> 'c)
```
The second constraint behaves similarly to the first:
```
...
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; unify((int -> int -> int = 'b -> 'c) {(int -> 'd) / 'c})
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; unify(int -> int -> int = 'b -> int -> 'd)
```
The function constraint breaks down into two smaller constraints:
```
...
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; unify(int = 'b, int -> int = int -> 'd)
```
We get another substitution:
```
...
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; {int / 'b}; unify((int -> int = int -> 'd) {int / 'b})
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; {int / 'b}; unify(int -> int = int -> 'd)
```
Then we get to break down another function constraint:
```
...
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; {int / 'b}; unify(int = int, int = 'd)
```
The first of the resulting new constraints is trivial and just gets dropped:
```
...
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; {int / 'b}; unify(int = 'd)
```
The very last constraint gives us one more substitution:
```
=
{('d -> 'e) / 'a}; {(int -> 'd) / 'c}; {int / 'b}; {int / 'd}
```

**Reconstructing the type.** To finish, we apply the substitution
output by unification to the type inferred by constraint generation:
```
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
```
# fun f -> fun x -> f (( + ) x 1);;
- : (int -> 'a) -> int -> 'a = <fun>
```
Except that OCaml uses a different type variable identifier. OCaml is nice to us
and "lowers" the type variables down to smaller letters of the alphabet. We
could do that too with a little extra work.
