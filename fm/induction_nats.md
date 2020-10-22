# Induction on Naturals

We used OCaml's `int` type as a representation of the naturals.  Of course,
that type is somewhat of a mismatch:  negative `int` values don't represent
naturals, and there is an upper bound to what natural numbers we can represent
with `int`.

Let's fix those problems by defining our own variant to represent natural
numbers:
```
type nat = 
  | Z
  | S of nat
```

The constructor `Z` represents zero; and the constructor `S` represents the
successor of another natural number.  So, 

- 0 is represented by `Z`,
- 1 by `S Z`,
- 2 by `S (S Z)`,
- 3 by `S (S (S Z))`, 

and so forth.  This variant is thus a *unary* (as opposed to binary
or decimal) representation of the natural numbers:  the number of times `S`
occurs in a value `n : nat` is the natural number that `n` represents.

We can define addition on natural numbers with the following function:
```
let rec plus a b = 
  match a with
  | Z -> b
  | S k -> S (plus k b)
```

Immediately we can prove the following rather trivial claim:

```
Claim:  plus Z n = n

Proof:

  plus Z n
=   { evaluation }
  n

QED
```

But suppose we want to prove this also trivial-seeming claim:

```
Claim:  plus n Z = n

Proof:

  plus n Z
= 
  ???
```

We can't just evaluate `plus n Z`, because `plus` matches against its first
argument, not second.  One possibility would be to do a case analysis:
what if `n` is `Z`, vs. `S k` for some `k`?  Let's attempt that.

```
Proof:

By case analysis on n, which must be either Z or S k.

Case:  n = Z

  plus Z Z
=   { evaluation }
  Z

Case:  n = S k

  plus (S k) Z
=   { evaluation }
  S (plus k Z)
=
  ???
```

We are again stuck, and for the same reason:  once more `plus` can't be
evaluated any further.

When you find yourself needing to solve the same subproblem in programming,
you use recursion.  When it happens in a proof, you use induction!  

## The Induction Principle for Naturals

We need to do induction on values of type `nat`.  We'll need an induction
principle.  Here it is:
```
forall properties P,
  if P(Z),
  and if forall k, P(k) implies P(S k),
  then forall n, P(n)
```

Compare that to the induction principle we used for natural numbers before,
when we were using `int` in place of natural numbers:
```
forall properties P,
  if P(0),
  and if forall k, P(k) implies P(k + 1),
  then forall n, P(n)
```

There's no essential difference between the two: we just use `Z` in place of
`0`, and `S k` in place of `k + 1`.

Using that induction principle, we can carry out the proof:

```
Claim:  plus n Z = n

Proof: by induction on n.
P(n) = plus n Z = n

Base case: n = Z
Show: plus Z Z = Z

  plus Z Z
=   { evaluation }
  Z

Inductive case: n = S k
IH: plus k Z = k
Show: plus (S k) Z = S k

  plus (S k) Z
=   { evaluation }
  S (plus k Z)
=   { IH }
  S k

QED
```
