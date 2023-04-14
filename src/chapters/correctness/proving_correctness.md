---
jupytext:
  cell_metadata_filter: -all
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.10.3
kernelspec:
  display_name: OCaml
  language: OCaml
  name: ocaml-jupyter
---

# Proving Correctness

{{ video_embed | replace("%%VID%%", "48GBq4koKPs")}}

Testing provides evidence of correctness, but not full assurance. Even after
extensive black-box and glass-box testing, maybe there's still some test case
the programmer failed to invent, and that test case would reveal a fault in the
program.

```{epigraph}
Program testing can be used to show the presence of bugs, but never to show their absence.

-- Edsger W. Dijkstra
```

The point is not that testing is useless! It can be quite effective. But it is a
kind of *inductive reasoning*, in which evidence (i.e., passing tests)
accumulates in support of a conclusion (i.e., correctness of the program)
without absolutely guaranteeing the validity of that conclusion. (Note that the
word "inductive" here is being used in a different sense than the proof
technique known as induction.) To get that guarantee, we turn to *deductive
reasoning*, in which we proceed from premises and rules about logic to a valid
conclusion. In other words, we prove the correctness of the program. Our goal,
next, is to learn some techniques for such correctness proofs. These techniques
are known as *formal methods* because of their use of logical formalism.

*Correctness* here means that the program produces the right output
according to a *specification*. Specifications are usually provided in the
documentation of a function (hence the name "specification comment"): they
describe the program's precondition and postcondition. Postconditions, as we
have been writing them, have the form `[f x] is "...a description of the output
in terms of the input [x]..."`. For example, the specification of a factorial
function could be:

```ocaml
(** [fact n] is [n!]. Requires: [n >= 0]. *)
let rec fact n = ...
```

The postcondition is asserting an equality between the output of the function
and some English description of a computation on the input. *Formal
verification* is the task for proving that the implementation of the function
satisfies its specification.

Equalities are one of the fundamental ways we think about correctness of
functional programs. The absence of mutable state makes it possible to reason
straightforwardly about whether two expressions are equal. It's difficult to do
that in an imperative language, because those expressions might have side
effects that change the state.

## Equality

{{ video_embed | replace("%%VID%%", "zjDUrMdVC5U")}}

When are two expressions equal?  Two possible answers are:

- When they are syntactically identical.

- When they are semantically equivalent: they produce the same value.

For example, are `42` and `41+1` equal? The syntactic answer would say they are
not, because they involve different tokens. The semantic answer would say they
are: they both produce the value `42`.

What about functions: are `fun x -> x` and `fun y -> y` equal? Syntactically
they are different. But semantically, they both produce a value that is the
identity function: when they are applied to an input, they will both produce the
same output. That is, `(fun x -> x) z = z`, and `(fun y -> y) z = z`. If it is
the case that for all inputs two functions produce the same output, we will
consider the functions to be equal:

```text
if (forall x, f x = g x), then f = g.
```

That definition of equality for functions is known as the *Axiom of
Extensionality* in some branches of mathematics; henceforth we'll refer to it
simply as "extensionality".

Here we will adopt the semantic approach. If `e1` and `e2` evaluate to the same
value `v`, then we write `e1 = e2`. We are using `=` here in a mathematical
sense of equality, not as the OCaml polymorphic equality operator. For example,
we allow `(fun x -> x) = (fun y -> y)`, even though OCaml's operator would raise
an exception and refuse to compare functions.

We're also going to restrict ourselves to expressions that are well typed, pure
(meaning they have no side effects), and total (meaning they don't have
exceptions or infinite loops).

## Equational Reasoning

{{ video_embed | replace("%%VID%%", "MjpZJA1jIqU")}}

Consider these functions:

```{code-cell} ocaml
let twice f x = f (f x)
let compose f g x = f (g x)
```

We know from the rules of OCaml evaluation that `twice h x = h (h x)`, and
likewise, `compose h h x = h (h x)`. Thus we have:

```ocaml
twice h x = h (h x) = compose h h x
```

Therefore, we can conclude that `twice h x = compose h h x`. And by
extensionality we can simplify that equality: Since `twice h x = compose h h x`
holds for all `x`, we can conclude `twice h = compose h h`.

As another example, suppose we define an infix operator for function
composition:

```ocaml
let ( << ) = compose
```

Then we can prove that composition is associative, using equational reasoning:

```text
Theorem: (f << g) << h  =  f << (g << h)

Proof: By extensionality, we need to show
  ((f << g) << h) x  =  (f << (g << h)) x
for an arbitrary x.

  ((f << g) << h) x
= (f << g) (h x)
= f (g (h x))

and

  (f << (g << h)) x
= f ((g << h) x)
= f (g (h x))

So ((f << g) << h) x = f (g (h x)) = (f << (g << h)) x.

QED
```

All of the steps in the equational proof above follow from evaluation.
Another format for writing the proof would provide hints as to why
each step is valid:

```text
  ((f << g) << h) x
=   { evaluation of << }
  (f << g) (h x)
=   { evaluation of << }
  f (g (h x))

and

  (f << (g << h)) x
=   { evaluation of << }
  f ((g << h) x)
=   { evaluation of << }
  f (g (h x))
```

## Induction on Natural Numbers

{{ video_embed | replace("%%VID%%", "By4VSmpzuHw")}}

The following function sums the non-negative integers up to `n`:

```{code-cell} ocaml
let rec sumto n =
  if n = 0 then 0 else n + sumto (n - 1)
```

You might recall that the same summation can be expressed in closed form as
`n * (n + 1) / 2`. To prove that `forall n >= 0, sumto n = n * (n + 1) / 2`, we
will need *mathematical induction*.

Recall that induction on the natural numbers (i.e., the non-negative integers)
is formulated as follows:

```text
forall properties P,
  if P(0),
  and if forall k, P(k) implies P(k + 1),
  then forall n, P(n)
```

That is called the *induction principle* for natural numbers. The *base case* is
to prove `P(0)`, and the *inductive case* is to prove that `P(k + 1)` holds
under the assumption of the *inductive hypothesis* `P(k)`.

{{ video_embed | replace("%%VID%%", "JRNxlQYOLyw")}}

Let's use induction to prove the correctness of `sumto`.

```text
Claim: sumto n = n * (n + 1) / 2

Proof: by induction on n.
P(n) = sumto n = n * (n + 1) / 2

Base case: n = 0
Show: sumto 0 = 0 * (0 + 1) / 2

  sumto 0
=   { evaluation }
  0
=   { algebra }
  0 * (0 + 1) / 2

Inductive case: n = k + 1
Show: sumto (k + 1) = (k + 1) * ((k + 1) + 1) / 2
IH: sumto k = k * (k + 1) / 2

  sumto (k + 1)
=   { evaluation }
  k + 1 + sumto k
=   { IH }
  k + 1 + k * (k + 1) / 2
=   { algebra }
  (k + 1) * (k + 2) / 2

QED
```

Note that we have been careful in each of the cases to write out what we need to
show, as well as to write down the inductive hypothesis. It is important to show
all this work.

Suppose we now define:

```{code-cell} ocaml
let sumto_closed n = n * (n + 1) / 2
```

Then as a corollary to our previous claim, by extensionality we can conclude

```text
sumto_closed = sumto
```

Technically that equality holds only inputs that are natural numbers. But since
all our examples henceforth will be for naturals, not integers per se, we will
elide stating any preconditions or restrictions regarding natural numbers.

## Programs as Specifications

We have just proved the correctness of an efficient implementation relative to
an inefficient implementation. The inefficient implementation, `sumto`, serves
as a specification for the efficient implementation, `sumto_closed`.

That technique is common in verifying functional programs: write an obviously
correct implementation that is lacking in some desired property, such as
efficiency, then prove that a better implementation is equal to the original.

Let's do another example of this kind of verification. This time, well use the
factorial function.

{{ video_embed | replace("%%VID%%", "htMNllWnLzg")}}

The simple, obviously correct implementation of factorial would be:

```{code-cell} ocaml
let rec fact n =
  if n = 0 then 1 else n * fact (n - 1)
```

A tail-recursive implementation would be more efficient about stack space:

```{code-cell} ocaml
let rec facti acc n =
  if n = 0 then acc else facti (acc * n) (n - 1)

let fact_tr n = facti 1 n
```

The `i` in the name `facti` stands for *iterative*. We call this an iterative
implementation because it strongly resembles how the same computation would be
expressed using a loop (that is, an iteration construct) in an imperative
language. For example, in Java we might write:

```java
int facti (int n) {
  int acc = 1;
  while (n != 0) {
    acc *= n;
    n--;
  }
  return acc;
}
```

Both the OCaml and Java implementation of `facti` share these features:

- they start `acc` at `1`
- they check whether `n` is `0`
- they multiply `acc` by `n`
- they decrement `n`
- they return the accumulator, `acc`

Let's try to prove that `fact_tr` correctly implements the same computation as
`fact`.

```text
Claim: forall n, fact n = fact_tr n

Since fact_tr n = facti 1 n, it suffices to show fact n = facti 1 n.

Proof: by induction on n.
P(n) = fact n = facti 1 n

Base case: n = 0
Show: fact 0 = facti 1 0

  fact 0
=   { evaluation }
  1
=   { evaluation }
  facti 1 0

Inductive case: n = k + 1
Show: fact (k + 1) = facti 1 (k + 1)
IH: fact k = facti 1 k

  fact (k + 1)
=   { evaluation }
  (k + 1) * fact k
=   { IH }
  (k + 1) * facti 1 k

  facti 1 (k + 1)
=   { evaluation }
  facti (1 * (k + 1)) k
=   { evaluation }
  facti (k + 1) k

Unfortunately, we're stuck.  Neither side of what we want to show
can be manipulated any further.

ABORT
```

We know that `facti (k + 1) k` and `(k + 1) * facti 1 k` should yield the same
value. But the IH allows us only to use `1` as the second argument to `facti`,
instead of a bigger argument like `k + 1`. So our proof went astray the moment
we used the IH. We need a stronger inductive hypothesis!

So let's strengthen the claim we are making. Instead of showing that
`fact n = facti 1 n`, we'll try to show `forall p, p * fact n = facti p n`. That
generalizes the `k + 1` we were stuck on to an arbitrary quantity `p`.

```text
Claim: forall n, forall p . p * fact n = facti p n

Proof: by induction on n.
P(n) = forall p, p * fact n = facti p n

Base case:  n = 0
Show: forall p,  p * fact 0 = facti p 0

  p * fact 0
=   { evaluation and algebra }
  p
=   { evaluation }
  facti p 0

Inductive case: n = k + 1
Show: forall p,  p * fact (k + 1) = facti p (k + 1)
IH: forall p,  p * fact k = facti p k

  p * fact (k + 1)
=   { evaluation }
  p * (k + 1) * fact k
=   { IH, instantiating its p as p * (k + 1) }
  facti (p * (k + 1)) k

  facti p (k + 1)
=   { evaluation }
  facti (p * (k + 1)) k

QED

Claim: forall n, fact n = fact_tr n

Proof:

  fact n
=   { algebra }
  1 * fact n
=   { previous claim }
  facti 1 n
=   { evaluation }
  fact_tr n

QED
```

That finishes our proof that the efficient, tail-recursive function `fact_tr` is
equivalent to the simple, recursive function `fact`. In essence, we have proved
the correctness of `fact_tr` using `fact` as its specification.

## Recursion vs. Iteration

We added an accumulator as an extra argument to make the factorial function be
tail recursive. That's a trick we've seen before. Let's abstract and see how to
do it in general.

Suppose we have a recursive function over integers:

```ocaml
let rec f_r n =
  if n = 0 then i else op n (f_r (n - 1))
```

Here, the `r` in `f_r` is meant to suggest that `f_r` is a recursive function.
The `i` and `op` are pieces of the function that are meant to be replaced by
some concrete value `i` and operator `op`. For example, with the factorial
function, we have:

```ocaml
f_r = fact
i = 1
op = ( * )
```

Such a function can be made tail recursive by rewriting it as follows:

```ocaml
let rec f_i acc n =
  if n = 0 then acc
  else f_i (op acc n) (n - 1)

let f_tr = f_i i
```

Here, the `i` in `f_i` is meant to suggest that `f_i` is an iterative function,
and `i` and `op` are the same as in the recursive version of the function. For
example, with factorial we have:

```ocaml
f_i = fact_i
i = 1
op = ( * )
f_tr = fact_tr
```

We can prove that `f_r` and `f_tr` compute the same function. During the proof,
next, we will discover certain conditions that must hold of `i` and `op` to make
the transformation to tail recursion be correct.

```text
Theorem: f_r = f_tr

Proof:  By extensionality, it suffices to show that forall n, f_r n = f_tr n.

As in the previous proof for fact, we will need a strengthened induction
hypothesis. So we first prove this lemma, which quantifies over all accumulators
that could be input to f_i, rather than only i:

  Lemma: forall n, forall acc, op acc (f_r n) = f_i acc n

  Proof of Lemma: by induction on n.
  P(n) = forall acc, op acc (f_r n) = f_i acc n

  Base: n = 0
  Show: forall acc, op acc (f_r 0) = f_i acc 0

    op acc (f_r 0)
  =   { evaluation }
    op acc i
  =   { if we assume forall x, op x i = x }
    acc

    f_i acc 0
  =   { evaluation }
    acc

  Inductive case: n = k + 1
  Show: forall acc, op acc (f_r (k + 1)) = f_i acc (k + 1)
  IH: forall acc, op acc (f_r k) = f_i acc k

    op acc (f_r (k + 1))
  =   { evaluation }
    op acc (op (k + 1) (f_r k))
  =   { if we assume forall x y z, op x (op y z) = op (op x y) z }
    op (op acc (k + 1)) (f_r k)

    f_i acc (k + 1)
  =   { evaluation }
    f_i (op acc (k + 1)) k
  =   { IH, instantiating acc as op acc (k + 1)}
    op (op acc (k + 1)) (f_r k)

  QED

The proof then follows almost immediately from the lemma:

  f_r n
=   { if we assume forall x, op i x = x }
  op i (f_r n)
=   { lemma, instantiating acc as i }
  f_i i n
=   { evaluation }
  f_tr n

QED
```

Along the way we made three assumptions about i and op:

1. `forall x, op x i = x`
2. `op x (op y z) = op (op x y) z`
3. `forall x, op i x = x`

The first and third say that `i` is an *identity* of `op`: using it on the left
or right side leaves the other argument `x` unchanged. The second says that `op`
is *associative*. Both those assumptions held for the values we used in the
factorial functions:

- `op` is multiplication, which is associative.
- `i` is `1`, which is an identity of multiplication: multiplication by 1 leaves
  the other argument unchanged.

So our transformation from a recursive to a tail-recursive function is valid as
long as the operator applied in the recursive call is associative, and the value
returned in the base case is an identity of that operator.

Returning to the `sumto` function, we can apply the theorem we just proved to
immediately get a tail-recursive version:

```{code-cell} ocaml
let rec sumto_r n =
  if n = 0 then 0 else n + sumto_r (n - 1)
```

Here, the operator is addition, which is associative; and the base case is zero,
which is an identity of addition. Therefore our theorem applies, and we can use
it to produce the tail-recursive version without even having to think about it:

```{code-cell} ocaml
let rec sumto_i acc n =
  if n = 0 then acc else sumto_i (acc + n) (n - 1)

let sumto_tr = sumto_i 0
```

We already know that `sumto_tr` is correct, thanks to our theorem.

## Termination

{{ video_embed | replace("%%VID%%", "Xy7GTfEfIK4")}}

Sometimes correctness of programs is further divided into:

- **partial correctness**: meaning that *if* a program terminates, then its
  output is correct; and

- **total correctness**: meaning that a program *does* terminate, *and* its
  output is correct.

Total correctness is therefore the conjunction of partial correctness and
termination. Thus far, we have been proving partial correctness.

To prove that a program terminates is difficult. Indeed, it is impossible in
general for an algorithm to do so: a computer can't precisely decide whether a
program will terminate. (Look up the "halting problem" for more details.) But, a
smart human sometimes can do so.

There is a simple heuristic that can be used to show that a recursive function
terminates:

- All recursive calls are on a "smaller" input, and
- all base cases are terminating.

For example, consider the factorial function:

```{code-cell} ocaml
let rec fact n =
  if n = 0 then 1
  else n * fact (n - 1)
```

The base case, `1`, obviously terminates. The recursive call is on `n - 1`,
which is a smaller input than the original `n`. So `fact` always terminates (as
long as its input is a natural number).

The same reasoning applies to all the other functions we've discussed above.

To make this more precise, we need a notion of what it means to be smaller.
Suppose we have a binary relation `<` on inputs. Despite the notation, this
relation need not be the less-than relation on integers---although that will
work for `fact`. Also suppose that it is never possible to create an infinite
sequence `x0 > x1 > x2 > x3 ...` of elements using this relation. (Where of
course `a > b` iff `b < a`.) That is, there are no infinite descending chains of
elements: once you pick a starting element `x0`, there can be only a finite
number of "descents" according to the `<` relation before you bottom out and hit
a base case. This property of `<` makes it a *well-founded relation*.

So, a recursive function terminates if all its recursive calls are on elements
that are smaller according to `<`. Why? Because there can be only a finite
number of calls before a base case is reached, and base cases must terminate.

The usual `<` relation is well-founded on the natural numbers, because
eventually any chain must reach the base case of 0. But it is not well-founded
on the integers, which can get just keep getting smaller: `-1 > -2 > -3 > ...`.

Here's an interesting function for which the usual `<` relation doesn't suffice
to prove termination:

```{code-cell} ocaml
let rec ack = function
  | (0, n) -> n + 1
  | (m, 0) -> ack (m - 1, 1)
  | (m, n) -> ack (m - 1, ack (m, n - 1))
```

This is known as *Ackermann's function*. It grows faster than any exponential
function. Try running `ack (1, 1)`, `ack (2, 1)`, `ack (3, 1)`, then `ack (4,
1)` to get a sense of that. It also is a famous example of a function that can
be implemented with `while` loops but not with `for` loops. Nonetheless, it does
terminate.

To show that, the base case is easy: when the input is `(0, _)`, the function
terminates. But in other cases, it makes a recursive call, and we need to define
an appropriate `<` relation. It turns out *lexicographic ordering* on pairs
works. Define `(a, b) < (c, d)` if:

- `a < c`, or
- `a = c` and `b < d`.

The `<` order in those two cases is the usual `<` on natural numbers.

In the first recursive call, `(m - 1, 1) < (m, 0)` by the first case of the
definition of `<`, because `m - 1 < m`. In the nested recursive call
`ack (m - 1, ack (m, n - 1))`, both cases are needed:

- `(m, n - 1) < (m, n)` because `m = m` and `n - 1 < n`
- `(m - 1, _) < (m, n)` because `m - 1 < m`.
