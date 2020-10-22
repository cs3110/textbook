# Induction on Lists

It turns out that natural numbers and lists are quite similar, when viewed
as data types.  Here are the definitions of both, side-by-side for comparison:
```
type 'a list =                  type nat =
  | []                            | Z
  | (::) of 'a * 'a list          | S of nat
```

Both types have a constructor representing a concept of "nothing".  Both types
also have a constructor representing "one more" than another value of the type:
`S n` is one more than `n`, and `h :: t` is a list with one more element than
`t`.

The induction principle for lists is likewise quite similar to the induction
principle for natural numbers.  Here is the principle for lists:
```
forall properties P,
  if P([]),
  and if forall h t, P(t) implies P(h :: t),
  then forall lst, P(lst)
```

An inductive proof for lists therefore has the following structure:
```
Proof: by induction on lst.
P(lst) = ...

Base case: lst = []
Show: P([])

Inductive case: lst = h :: t
IH: P(t)
Show: P(h :: t)
```

Let's try an example of this kind of proof.  Recall the definition of the
append operator:

```
let rec append lst1 lst2 =
  match lst1 with
  | [] -> lst2
  | h :: t -> h :: append t lst2

let (@) = append
```
We'll prove that append is associative.

```
Theorem: forall xs ys zs, xs @ (ys @ zs) = (xs @ ys) @ zs

Proof: by induction on xs.
P(xs) = forall ys zs, xs @ (ys @ zs) = (xs @ ys) @ zs

Base case: xs = []
Show: forall ys zs, [] @ (ys @ zs) = ([] @ ys) @ zs

  [] @ (ys @ zs)
=   { evaluation }
  ys @ zs
=   { evaluation }
  ([] @ ys) @ zs

Inductive case: xs = h :: t
IH: forall ys zs, t @ (ys @ zs) = (t @ ys) @ zs
Show: forall ys zs, (h :: t) @ (ys @ zs) = ((h :: t) @ ys) @ zs

  (h :: t) @ (ys @ zs) 
=   { evaluation }
  h :: (t @ (ys @ zs))
=   { IH }
  h :: ((t @ ys) @ zs)

  ((h :: t) @ ys) @ zs
=   { evaluation of inner @ }
  (h :: (t @ ys)) @ zs
=   { evaluation of outer @ }  
  h :: ((t @ ys) @ zs)

QED
```
