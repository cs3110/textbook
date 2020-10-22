# Induction on Natural Numbers

The following function sums the non-negative integers up to `n`:
```
let rec sumto n =
  if n = 0 then 0
  else n + sumto (n - 1)
```

You might recall that the same summation can be expressed in closed
form as `n * (n + 1) / 2`.  To prove that 
  `forall n >= 0, sumto n = n * (n + 1) / 2`,
we will need mathematical induction.

Recall that induction on the natural numbers (i.e., the non-negative integers)
is formulated as follows:
```
forall properties P,
  if P(0),
  and if forall k, P(k) implies P(k + 1),
  then forall n, P(n)
```
That is called the *induction principle* for natural numbers. The *base case* is
to prove `P(0)`, and the *inductive case* is to prove that `P(k + 1)` holds
under the assumption of the *inductive hypothesis* `P(k)`.

Let's use induction to prove the correctness of `sumto`.
```
Claim: sumto n = n * (n + 1) / 2

Proof: by induction on n.
P(n) = sumto n = n * (n + 1) / 2

Base case: n = 0
Show: sumto 0 = 0 * (n + 1) / 2

  sumto 0
=   { evaluation }
  0
=   { algebra }
  0 * (n + 1) / 2

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

Suppose we now define
```
let sumto_closed n = n * (n + 1) / 2
```

Then a corollary to our previous claim, by extension we can conclude
```
sumto_closed = sumto
```
Technically that equality holds only inputs that are natural numbers.  But since
all our examples henceforth will be for naturals, not integers per se, we will
elide stating any preconditions or restrictions regarding natural numbers.
