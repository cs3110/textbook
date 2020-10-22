# Programs as Specifications

We have just proved the correctness of an efficient implementation relative to
an inefficient implementation.  The inefficient implementation, `sumto`, serves
as a specification for the efficient implementation, `sumto_closed`.

That technique is common in verifying functional programs:  write an obviously
correct implementation that is lacking in some desired property, such as
efficiency, then prove that a better implementation is equal to the original.

Let's do another example of this kind of verification.  This time, well use the
factorial function.

The simple, obviously correct implementation of factorial would be:
```
let rec fact n =
  if n = 0 then 1
  else n * fact (n - 1)
```

A tail-recursive implementation would be more efficient about stack space:
```
let rec facti acc n =
  if n = 0 then acc
  else facti (acc * n) (n - 1) 

let fact_tr n = facti 1 n
```

The `i` in the name `facti` stands for *iterative*.  We call this an
iterative implementation because it strongly resembles how the same
computation would be expressed using a loop (that is, an iteration
construct) in an imperative language.  For example, in Java we might write:
```
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

Let's try to prove that `fact_tr` correctly implements the same computation
as `fact`.

```
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
value.  But the IH allows us only to use `1` as the second argument to `facti`,
instead of a bigger argument like `k + 1`.  So our proof went astray the moment
we used the IH.  We need a stronger inductive hypothesis!

So let's strengthen the claim we are making.  Instead of showing
that `fact n = facti 1 n`, we'll try to show 
  `forall p, p * fact n = facti p n`.  
That generalizes the `k + 1` we were stuck on to an arbitrary quantity `p`.

```
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
equivalent to the simple, recursive function `fact`.  In essence, we have proved
the correctness of `fact_tr` using `fact` as its specification.
