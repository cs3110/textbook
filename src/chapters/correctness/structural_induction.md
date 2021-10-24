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

# Structural Induction

So far we've proved the correctness of recursive functions on natural numbers.
We can do correctness proofs about recursive functions on variant types, too.
That requires us to figure out how induction works on variants. We'll do that,
next, starting with a variant type for representing natural numbers, then
generalizing to lists, trees, and other variants. This inductive proof technique
is sometimes known as *structural induction* instead of *mathematical
induction*. But that's just a piece of vocabulary; don't get hung up on it. The
core idea is completely the same.

## Induction on Naturals

{{ video_embed | replace("%%VID%%", "Lkb-eTUrHTs")}}

We used OCaml's `int` type as a representation of the naturals. Of course, that
type is somewhat of a mismatch: negative `int` values don't represent naturals,
and there is an upper bound to what natural numbers we can represent with `int`.

Let's fix those problems by defining our own variant to represent natural
numbers:

```{code-cell} ocaml
type nat = Z | S of nat
```

The constructor `Z` represents zero; and the constructor `S` represents the
successor of another natural number. So,

- 0 is represented by `Z`,
- 1 by `S Z`,
- 2 by `S (S Z)`,
- 3 by `S (S (S Z))`,

and so forth. This variant is thus a *unary* (as opposed to binary or decimal)
representation of the natural numbers: the number of times `S` occurs in a value
`n : nat` is the natural number that `n` represents.

We can define addition on natural numbers with the following function:

```{code-cell} ocaml
let rec plus a b =
  match a with
  | Z -> b
  | S k -> S (plus k b)
```

Immediately we can prove the following rather trivial claim:

```text
Claim:  plus Z n = n

Proof:

  plus Z n
=   { evaluation }
  n

QED
```

But suppose we want to prove this also trivial-seeming claim:

```text
Claim:  plus n Z = n

Proof:

  plus n Z
=
  ???
```

We can't just evaluate `plus n Z`, because `plus` matches against its first
argument, not second. One possibility would be to do a case analysis: what if
`n` is `Z`, vs. `S k` for some `k`? Let's attempt that.

```text
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

We are again stuck, and for the same reason: once more `plus` can't be evaluated
any further.

When you find yourself needing to solve the same subproblem in programming, you
use recursion. When it happens in a proof, you use induction!

We'll need an induction principle for `nat`. Here it is:

```text
forall properties P,
  if P(Z),
  and if forall k, P(k) implies P(S k),
  then forall n, P(n)
```

Compare that to the induction principle we used for natural numbers before,
when we were using `int` in place of natural numbers:

```text
forall properties P,
  if P(0),
  and if forall k, P(k) implies P(k + 1),
  then forall n, P(n)
```

There's no essential difference between the two: we just use `Z` in place of
`0`, and `S k` in place of `k + 1`.

Using that induction principle, we can carry out the proof:

```text
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

## Induction on Lists

{{ video_embed | replace("%%VID%%", "Xo3rW_dTqEg")}}

It turns out that natural numbers and lists are quite similar, when viewed
as data types.  Here are the definitions of both, aligned for comparison:

```ocaml
type    nat  = Z  | S      of nat
type 'a list = [] | ( :: ) of 'a * 'a list
```

Both types have a constructor representing a concept of "nothing". Both types
also have a constructor representing "one more" than another value of the type:
`S n` is one more than `n`, and `h :: t` is a list with one more element than
`t`.

The induction principle for lists is likewise quite similar to the induction
principle for natural numbers. Here is the principle for lists:

```text
forall properties P,
  if P([]),
  and if forall h t, P(t) implies P(h :: t),
  then forall lst, P(lst)
```

An inductive proof for lists therefore has the following structure:

```text
Proof: by induction on lst.
P(lst) = ...

Base case: lst = []
Show: P([])

Inductive case: lst = h :: t
IH: P(t)
Show: P(h :: t)
```

Let's try an example of this kind of proof. Recall the definition of the append
operator:

```{code-cell} ocaml
let rec append lst1 lst2 =
  match lst1 with
  | [] -> lst2
  | h :: t -> h :: append t lst2

let ( @ ) = append
```

We'll prove that append is associative.

```text
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

{{ video_embed | replace("%%VID%%", "4B2jF2zHSCs")}}


## A Theorem about Folding

When we studied `List.fold_left` and `List.fold_right`, we discussed how they
sometimes compute the same function, but in general do not. For example,

```
  List.fold_left ( + ) 0 [1; 2; 3]
= (((0 + 1) + 2) + 3
= 6
= 1 + (2 + (3 + 0))
= List.fold_right ( + ) lst [1; 2; 3]
```

but

```
  List.fold_left ( - ) 0 [1; 2; 3]
= (((0 - 1) - 2) - 3
= -6
<> 2
= 1 - (2 - (3 - 0))
= List.fold_right ( - ) lst [1; 2; 3]
```

Based on the equations above, it looks like the fact that `+` is commutative and
associative, whereas `-` is not, explains this difference between when the two
fold functions get the same answer. Let's prove it!

First, recall the definitions of the fold functions:

```{code-cell} ocaml
let rec fold_left f acc lst =
  match lst with
  | [] -> acc
  | h :: t -> fold_left f (f acc h) t

let rec fold_right f lst acc =
  match lst with
  | [] -> acc
  | h :: t -> f h (fold_right f t acc)
```

Second, recall what it means for a function `f : 'a -> 'a` to be commutative and
associative:

```text
Commutative:  forall x y, f x y = f y x
Associative:  forall x y z, f x (f y z) = f (f x y) z
```

Those might look a little different than the normal formulations of those
properties, because we are using `f` as a prefix operator. If we were to write
`f` instead as an infix operator `op`, they would look more familiar:

```text
Commutative:  forall x y, x op y = y op x
Associative:  forall x y z, x op (y op z) = (x op y) op z
```

When `f` is both commutative and associative we have this little interchange
lemma that lets us swap two arguments around:

```
Lemma (interchange): f x (f y z) = f y (f x z)

Proof:

  f x (f y z)
=   { associativity }
  f (f x y) z
=   { commutativity }
  f (f y x) z
=   { associativity }
  f y (f z x)

QED
```

Now we're ready to state and prove the theorem.

```text
Theorem: If f is commutative and associative, then
  forall lst acc,
    fold_left f acc lst = fold_right f lst acc.

Proof: by induction on lst.
P(lst) = forall acc,
  fold_left f acc lst = fold_right f lst acc

Base case: lst = []
Show: forall acc,
  fold_left f acc [] = fold_right f [] acc

  fold_left f acc []
=   { evaluation }
  acc
=   { evaluation }
  fold_right f [] acc

Inductive case: lst = h :: t
IH: forall acc,
  fold_left f acc t = fold_right f t acc
Show: forall acc,
  fold_left f acc (h :: t) = fold_right f (h :: t) acc

  fold_left f acc (h :: t)
=   { evaluation }
  fold_left f (f acc h) t
=   { IH with acc := f acc h }
  fold_right f t (f acc h)

  fold_right f (h :: t) acc
=   { evaluation }
  f h (fold_right f t acc)
```

Now, it might seem as though we are stuck: the left and right sides of the
equality we want to show have failed to "meet in the middle." But we're actually
in a similar situation to when we proved the correctness of `facti` earlier:
there's something (applying `f` to `h` and another argument) that we want to
push into the accumulator of that last line (so that we have `f acc h`).

Let's try proving that with its own lemma:

```text
Lemma: forall lst acc x,
  f x (fold_right f lst acc) = fold_right f lst (f acc x)

Proof: by induction on lst.
P(lst) = forall acc x,
  f x (fold_right f lst acc) = fold_right f lst (f acc x)

Base case: lst = []
Show: forall acc x,
  f x (fold_right f [] acc) = fold_right f [] (f acc x)

  f x (fold_right f [] acc)
=   { evaluation }
  f x acc

  fold_right f [] (f acc x)
=   { evaluation }
  f acc x
=   { commutativity of f }
  f x acc

Inductive case: lst = h :: t
IH: forall acc x,
  f x (fold_right f t acc) = fold_right f t (f acc x)
Show: forall acc x,
  f x (fold_right f (h :: t) acc) = fold_right f (h :: t) (f acc x)

  f x (fold_right f (h :: t) acc)
=  { evaluation }
  f x (f h (fold_right f t acc))
=  { interchange lemma }
  f h (f x (fold_right f t acc))
=  { IH }
  f h (fold_right f t (f acc x))

  fold_right f (h :: t) (f acc x)
=   { evaluation }
  f h (fold_right f t (f acc x))

QED
```

Now that the lemma is completed, we can resume the proof of the theorem. We'll
restart at the beginning of the inductive case:

```text
Inductive case: lst = h :: t
IH: forall acc,
  fold_left f acc t = fold_right f t acc
Show: forall acc,
  fold_left f acc (h :: t) = fold_right f (h :: t) acc

  fold_left f acc (h :: t)
=   { evaluation }
  fold_left f (f acc h) t
=   { IH with acc := f acc h }
  fold_right f t (f acc h)

  fold_right f (h :: t) acc
=   { evaluation }
  f h (fold_right f t acc)
=   { lemma with x := h and lst := t }
  fold_right f t (f acc h)

QED
```

It took two inductions to prove the theorem, but we succeeded! Now we know that
the behavior we observed with `+` wasn't a fluke: any commutative and
associative operator causes `fold_left` and `fold_right` to get the same answer.

## Induction on Trees

{{ video_embed | replace("%%VID%%", "UJyE8ylHFA0")}}

Lists and binary trees are similar when viewed as data types.  Here are the
definitions of both, aligned for comparison:

```{code-cell} ocaml
type 'a list = []   | ( :: ) of           'a * 'a list
type 'a tree = Leaf | Node   of 'a tree * 'a * 'a tree
```

Both have a constructor that represents "empty", and both have a constructor
that combines a value of type `'a` together with another instance of the
data type.  The only real difference is that `( :: )` takes just *one* list,
whereas `Node` takes *two* trees.

The induction principle for binary trees is therefore very similar to the
induction principle for lists, except that with binary trees we get
*two* inductive hypotheses, one for each subtree:

```text
forall properties P,
  if P(Leaf),
  and if forall l v r, (P(l) and P(r)) implies P(Node (l, v, r)),
  then forall t, P(t)
```

An inductive proof for binary trees therefore has the following structure:

```text
Proof: by induction on t.
P(t) = ...

Base case: t = Leaf
Show: P(Leaf)

Inductive case: t = Node (l, v, r)
IH1: P(l)
IH2: P(r)
Show: P(Node (l, v, r))
```

Let's try an example of this kind of proof. Here is a function that creates the
mirror image of a tree, swapping its left and right subtrees at all levels:

```{code-cell} ocaml
let rec reflect = function
  | Leaf -> Leaf
  | Node (l, v, r) -> Node (reflect r, v, reflect l)
```

For example, these two trees are reflections of each other:

```text
     1               1
   /   \           /   \
  2     3         3     2
 / \   / \       / \   / \
4   5 6   7     7   6 5   4
```

If you take the mirror image of a mirror image, you should get the original
back. That means reflection is an *involution*, which is any function `f` such
that `f (f x) = x`. Another example of an involution is multiplication by
negative one on the integers.

Let's prove that `reflect` is an involution.

```text
Claim: forall t, reflect (reflect t) = t

Proof: by induction on t.
P(t) = reflect (reflect t) = t

Base case: t = Leaf
Show: reflect (reflect Leaf) = Leaf

  reflect (reflect Leaf)
=   { evaluation }
  reflect Leaf
=   { evaluation }
  Leaf

Inductive case: t = Node (l, v, r)
IH1: reflect (reflect l) = l
IH2: reflect (reflect r) = r
Show: reflect (reflect (Node (l, v, r))) = Node (l, v, r)

  reflect (reflect (Node (l, v, r)))
=   { evaluation }
  reflect (Node (reflect r, v, reflect l))
=   { evaluation }
  Node (reflect (reflect l), v, reflect (reflect r))
=   { IH1 }
  Node (l, v, reflect (reflect r))
=   { IH2 }
  Node (l, v, r)

QED
```

Induction on trees is really no more difficult than induction on lists or
natural numbers. Just keep track of the inductive hypotheses, using our stylized
proof notation, and it isn't hard at all.

{{ video_embed | replace("%%VID%%", "aiJDQeWL2G0")}}

## Induction Principles for All Variants

We've now seen induction principles for `nat`, `list`, and `tree`. Generalizing
from what we've seen, each constructor of a variant either generates a base case
for the inductive proof, or an inductive case. And, if a constructor itself
carries values of that data type, each of those values generates in inductive
hypothesis. For example:

- `Z`, `[]`, and `Leaf` all generated base cases.

- `S`, `::`, and `Node` all generated inductive cases.

- `S` and `::` each generated one IH, because each carries one value of the
  data type.

- `Node` generated two IHs, because it carries two values of the data type.

As an example of an induction principle for a more complicated type, let's
consider a type that represents the syntax of a mathematical expression. You
might recall from an earlier data structures course that trees can be used for
that purpose.

Suppose we have the following `expr` type, which is a kind of tree, to represent
expressions with integers, Booleans, unary operators, and binary operators:

```{code-cell} ocaml
:tags: ["hide-output"]
type uop =
  | UMinus

type bop =
  | BPlus
  | BMinus
  | BLeq

type expr =
  | Int of int
  | Bool of bool
  | Unop of uop * expr
  | Binop of expr * bop * expr
```

For example, the expression `5 < 6` would be represented as
`Binop (BLeq, Int 5, Int 6)`. We'll see more examples of this kind of
representation later in the book when we study interpreters.

The induction principle for `expr` is:

```text
forall properties P,
  if forall i, P(Int i)
  and forall b, P(Bool b)
  and forall u e, P(e) implies P(Unop (u, e))
  and forall b e1 e2, (P(e1) and P(e2)) implies P(Binop (e1, b, e2))
  then forall e, P(e)
```

There are two base cases, corresponding to the two constructors that don't carry
an `expr`. There are two inductive cases, corresponding to the two constructors
that do carry `expr`s. `Unop` gets one IH, whereas `Binop` gets two IHs, because
of the number of `expr`s that each carries.

## Induction and Recursion

{{ video_embed | replace("%%VID%%", "J-x9hcNqRhY")}}

Inductive proofs and recursive programs bear a striking similarity. In a sense,
an inductive proof *is* a recursive program that shows how to construct evidence
for a theorem involving an algebraic data type (ADT). The **structure** of an ADT determines the structure of proofs and programs:

- The **constructors** of an ADT are the organizational principle of both proofs
  and programs. In a proof, we have a base or inductive case for each
  constructor. In a program, we have a pattern-matching case for each
  constructor.

- The use of **recursive types** in an ADT determine where recursion occurs in
  both proofs and programs. By "recursive type", we mean the occurrence of the
  type in its own definition, such as the second `'a list` in
  `type 'a list = [] | ( :: ) 'a * 'a list`. Such occurrences lead to "smaller"
  values of a type occurring inside larger values. In a proof, we apply the
  inductive hypothesis upon reaching such a smaller value. In a program, we
  recurse on the smaller value.
