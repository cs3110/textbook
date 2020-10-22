# Recursion vs. Iteration

We added an accumulator as an extra argument to make the factorial function
be tail recursive.  That's a trick we've seen before.  Let's abstract and
see how to do it in general.

Suppose we have a recursive function over integers:
```
let rec f_r n =
  if n = 0 then i else op n (f_r (n - 1))
```
Here, the `r` in `f_r` is meant to suggest that `f_r` is a recursive function.
The `i` and `op` are pieces of the function that are meant to be replaced
by some concrete value `i` and operator `op`.  For example, with the factorial
function, we have:
```
f_r = fact
i = 1
op = ( * )
```

Such a function can be made tail recursive by rewriting it as follows:
```
let f_i acc n =
  if n = 0 then acc
  else f_i (op acc n) (n - 1)

let f_tr = f_i i
```
Here, the `i` in `fi` is meant to suggest that `fi` is an iterative function,
and `i` and `op` are the same as in the recursive version of the function.
For example, with factorial we have:
```
f_i = fact_i
i = 1
op = ( * )
f_tr = fact_tr
```

We can prove that `f_r` and `f_tr` compute the same function.  During the
proof, next, we will discover certain conditions that must hold of `i`
and `op` to make the transformation to tail recursion be correct.

```
Theorem: f_r = f_tr

Proof:  By extensionality, it suffices to show that forall n, f_r n = f_tr n.

As in the previous proof for fact, we will need a strengthed induction
hypothesis.  So we first prove this lemma, which quantifies over all
accumulators that could be input to f_i, rather than only i:

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
  =
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

The first and third say that `i` is an *identity* of `op`:  using it on the left
or right side leaves the other argument `x` unchanged. The second says that `op`
is *associative*.  Both those assumptions held for the values we used in the
factorial functions:

- `op` is multiplication, which is associative.
- `i` is `1`, which is an identity of multiplication: multiplication by
  1 leaves the other argument unchanged.

So our transformation from a recursive to a tail-recursive function is valid as
long as the operator applied in the recursive call is associative, and the value
returned in the base case is an identity of that operator.

Returning to the `sumto` function, we can apply the theorem we just proved
to immediately get a tail-recursive version:

```
let rec sumto_r n =
  if n = 0 then 0 else n + sumto_r (n - 1)
```

Here, the operator is addition, which is associative; and the base case
is zero, which is an identity of addition.  Therefore our theorem applies,
and we can use it to produce the tail-recursive version without even
having to think about it:
```
let rec sumto_i acc n =
  if n = 0 then acc else sumto_i (acc + n) (n - 1)

let sumto_tr = sumto_i 0
```

We already know that `sumto_tr` is correct, thanks to our theorem.
