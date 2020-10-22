# Induction on Trees

Lists and binary trees are similar when viewed as data types.  Here are the
definitions of both, side-by-side for comparison:
```
type 'a bintree =                           type 'a list =
  | Leaf                                      | []
  | Node of 'a bintree * 'a * 'a bintree      | ( :: ) of 'a * 'a list
```
Both have a constructor that represents "empty", and both have a constructor
that combines a value of type `'a` together with another instance of the
data type.  The only real difference is that `( :: )` takes just *one* list,
whereas `Node` takes *two* trees.

The induction principle for binary trees is therefore very similar to the
induction principle for lists, except that with binary trees we get
*two* inductive hypotheses, one for each subtree:
```
forall properties P,
  if P(Leaf),
  and if forall l v r, (P(l) and P(r)) implies P(Node (l, v, r)),
  then forall t, P(t)
```

An inductive proof for binary trees therefore has the following structure:
```
Proof: by induction on t.
P(t) = ...

Base case: t = Leaf
Show: P(Leaf)

Inductive case: t = Node (l, v, r)
IH1: P(l)
IH2: P(r)
Show: P(Node (l, v, r))
```

Let's try an example of this kind of proof.  Here is a function that
creates the mirror image of a tree, swapping its left and right subtrees
at all levels:
```
let rec reflect = function
  | Leaf -> Leaf
  | Node (l, v, r) -> Node (reflect r, v, reflect l)
```

For example, these two trees are reflections of each other:
```
     1               1
   /   \           /   \
  2     3         3     2
 / \   / \       / \   / \
4   5 6   7     7   6 5   4
```

If you take the mirror image of a mirror image, you should get the original
back.  That means reflection is an *involution*, which is any function `f`
such that `f (f x) = x`.  Another example of an involution is multiplication
by negative one on the integers.

Let's prove that `reflect` is an involution.

```
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

Induction on trees is really no more difficult than induction on lists
or natural numbers.  Just keep track of the inductive hypotheses, using
our stylized proof notation, and it isn't hard at all.
