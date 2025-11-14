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

# Two-Three Trees

A *two-three tree*, or *2-3 tree*, is another balanced tree data structure that can be used to implement sets and maps.
Like red-black trees, the 2-3 tree achieves logarithmic time performance while avoiding mutability.
John Hopcroft is credited with the invention of 2-3 trees by Cormen et al. in *Introduction to Algorithms*, 1990, p. 280.

## Representation Type

The 2-3 tree generalizes the binary tree, in that every node in a 2-3 tree either has two children or three children.
Those are called *2-nodes* and *3-nodes*, respectively.
A 2-node contains one value, and a 3-node contains two values:

```{code-cell} ocaml
type 'a t =
  | Leaf
  | Two of {
      lt : 'a t; (* left subtree *)
      v : 'a;    (* value *)
      rt : 'a t  (* right subtree *)
    }
  | Three of {
      lt : 'a t; (* left subtree *)
      vl : 'a;   (* left value *)
      mt : 'a t; (* middle subtree *)
      vr : 'a;   (* right value *)
      rt : 'a t  (* right subtree *)
    }

let empty = Leaf
```

When used to represent a set, the abstraction function is that the elements in the set are values (of type `'a`) stored in the nodes.

The representation invariant for a 2-3 tree has two pieces.
The first piece is the *ordering invariant*, which generalizes the BST invariant.
The ordering invariant says:

- For any two-node `{lt; v; rt}`, the values are ordered `lt < v < rt`, where by `lt < v` we mean that all the values in `lt` are less than `v`, and symmetrically for `v < rt`.

- For any three-node `{lt; vl; mt; vr; rt}`, the values are ordered `lt < vl < mt < vr < rt`.

The second piece of the representation invariant is the *balance invariant*, which can be stated in three equivalent ways:

1. Every leaf in the tree is at the same depth.
2. Every sibling in the tree is at the same height.
3. Every full path (that is, from the root to a leaf) in the tree has the same length.

The latter is perhaps the most useful way to state the balance invariant if we want to compare to red-black trees.
Recall that red-black trees permitted path lengths to differ by up to a factor of two.
Thus, 2-3 trees are more strict about balance than red-black trees.

The length of every full path in a 2-3 tree is logarithmic in the number of nodes in the tree, which will yield logarithmic time operations.

## Membership

To check for membership in a 2-3 tree, we use a generalization of the algorithm for BST membership.
The ordering invariant tells us, at each branch, which direction to go to look for an element.

```{code-cell} ocaml
let rec mem x = function
 | Leaf -> false
 | Two { lt; v; rt } ->
     if x < v then mem x lt else if x > v then mem x rt else true
 | Three { lt; vl; mt; vr; rt } ->
     if x < vl then mem x lt
     else if x > vr then mem x rt
     else if x > vl && x < vr then mem x mt
     else true
```

## Insertion: Appel's Algorithm

To insert an element, as usual we use the same search procedure as in `mem` to find where the element ought to be.
If the element is already in the tree, no change is made.
If the element is not already in the tree, the search ends at a leaf.
But how can we insert the new element at that leaf while maintaining the balance invariant?
The following algorithm for accomplishing that task may be folklore; if any readers know a solid citation for it, please let us know.
But for now, since Michael Clarkson learned it from Andrew Appel, we will for now call it Appel's algorithm.

With Appel's algorithm, we transform the leaf at which the search ends into a new 2-node with no children that contains the inserted value.
That maintains the ordering invariant, but in general violates the balance invariant, because the new 2-node causes the length of the search path to grow by one.
Another way to put that is: the height of the tree grows by one.

So, we recurse back up the tree to restore the balance invariant and ensure that all paths have the same length.
The goal is to find a place to *absorb* the change in height, if possible.
Since we just created a new 2-node, as we recurse up, there are two cases to consider:
the parent of the new node is a 2-node, in which case we perform a *merge* operation; or it is a 3-node, in which case we perform a *split* operation.
Those operations work as described below.

### Merge

The problem we're trying to solve, again, is that a 2-node may have become too tall &mdash; its height might be one greater than its siblings.
Let's call such a 2-node a *tall* node.
If a tall 2-node has a 2-node parent, then the parent can absorb the change in height, as shown in the diagram below:

```text
    y              x,y              x
   / \           /  |  \           / \
 *x*  c   ==>   a   b   c  <==    a  *y*
 / \                                 / \
a   b                               b   c
```

In that diagram, `a`, `b`, and `c` represent subtrees.
There are two cases: merging a tall node `*x*` from the left, and merging a tall node `*y*` from the right.
In either case, the tall node's value is merged into its parent, which transforms the parent from a 2-node into a 3-node.
The extra height is absorbed, thus restoring the balance invariant.

After a merge occurs, we're done with the insertion operation and can recurse all the way back up to the root without making further changes.

### Split

What if a tall 2-node has a 3-node parent?
Then we can't merge, because that would create a 4-node.

```{Note}
There are such things as *2-3-4 trees*, and perhaps surprisingly they are closely related to red-black trees.
But here we will stick with 2-3 trees.
```

Instead, we *split* the 3-node parent into two 2-nodes.
Together with the already existing tall 2-node, that changes a tree with two 2-nodes and one 3-node into a tree with three 2-nodes, as shown below:

```text
    y,z             *y*              x,y
   / | \           /   \            / | \
 *x* c  d  ==>    x     z    <==   a  b *z*
 / \             / \   / \              / \
a   b           a   b c   d            c   d

                     ⇑

                    x,z
                   / | \
                  a *y* d
                    / \
                   b   c
```

There are three cases to consider: splitting to accomodate a tall node from the left (`*x*`), the middle (`*y*`), or the right (`*z*`).
After the split, the new root `*y*` has become tall, but its children all have the same height.
So balance has been restored within the subtree rooted at `*y*`.
Unless that is actually the root of the entire tree, we need to continue recursing back up to the ultimate root to continue restoring balance.

### Finishing Insertion

To review, we decided to create a tall 2-node any time we inserted a new value.
We saw that a tall 2-node could be merged into a 2-node parent, thus restoring balance; or, a 3-node parent could be split, thus creating a new tall 2-node whose height we continue to try to absorb higher in the tree.
Note that we have never produced a tall 3-node as a result of any of these insert, merge, or split operations.
Therefore, we do not have to consider any cases for merging or splitting with a tall 3-node.
That means we've finished designing the algorithm.

We can implement insertion as shown below.
Each helper function returns a pair of a tree and a boolean, where the boolean indicates whether the tree has grown or not &mdash; that is, whether the root of the returned tree is tall.
(Another way to implement that would be to introduce a custom variant type to track whether the tree grows.)

The code is considerably longer than red-black tree insertion.
In part that's because of all the comments we've added to explain it.
But also, having two different node shapes (2-node vs. 3-node) inherently makes the code more complicated, and using records instead of tuples for the data carried by the nodes makes the code more verbose.
Considerably more succinct implementations would be possible.

```{code-cell} ocaml
let impossible () = failwith "impossible: grow returns Two"

(** [ins x t] inserts [x] into [t] using Appel's algorithm. Returns:
    [new_t, grew], where [new_t] is the new tree (including [x]) and [grew] is
    whether the tree height grew. *)
let rec ins (x : 'a) (t : 'a t) : 'a t * bool =
  match t with
  | Leaf ->
      (* Insertion into a leaf creates a new 2-node, which grows the
          height. *)
      (Two { lt = Leaf; v = x; rt = Leaf }, true)
  | Two { lt; v; rt } ->
      if x = v then
        (* If [x] is already in the tree, no change is needed. *)
        (t, false)
      else
        (* Otherwise, insert [x] into the left or right subtree, and
            incorporate the current 2-node into the result *)
        ins_sub2 x lt v rt
  | Three { lt; vl; mt; vr; rt } ->
      if x = vl || x = vr then
        (* If [x] is already in the tree, no change is needed. *)
        (t, false)
      else
        (* Otherwise, insert [x] into the left, middle, or right subtree, and
            incorporate the current 3-node into the result*)
        ins_sub3 x lt vl mt vr rt

(** [ins_sub2 x lt v rt] inserts [x] into one of the subtrees of a 2-node,
    where that two-node is [Two {lt; v; rt}]. Returns [new_t, grew], where
    [new_t] is the new tree (including [lt], [v], and [rt]) and [grew] is
    whether the tree height grew as a result of the insert. Requires:
    [x <> v]. *)
and ins_sub2 (x : 'a) (lt : 'a t) (v : 'a) (rt : 'a t) : 'a t * bool =
  if x < v then
    (* [x] belongs in [lt]. *)
    ins_sub2_left x lt v rt
  else if x > v then (* [x] belongs in [rt]. *)
    ins_sub2_right x lt v rt
  else
    (* [x] belongs in neither [lt] nor [rt], but then we should never have
        called [ins_sub2] on it. *)
    failwith "precondition violated"

(** [ins_sub2_left x lt v rt] inserts [x] into the left subtree of a 2-node,
    where that two-node is [Two {lt; v; rt}]. Returns [new_t, grew], where
    [new_t] is the new tree (including [lt], [v], and [rt]) and [grew] is
    whether the tree height grew as a result of the insert. *)
and ins_sub2_left (x : 'a) (lt : 'a t) (v : 'a) (rt : 'a t) : 'a t * bool =
  match ins x lt with
  | new_lt, false ->
      (* [x] was inserted into [lt] without growing the height, so we can
          safely reattach the resulting subtree without doing any more work to
          rebalance. *)
      (Two { lt = new_lt; v; rt }, false)
  | Two { lt = child_lt; v = child_v; rt = child_rt }, true ->
      (* [x] was inserted into [lt], and that caused [lt] to grow in height
          and have a 2-node at its root. We can merge that 2-node into the
          current 2-node to form a 3-node, which absorbs the change in
          height. *)
      (Three { lt = child_lt; vl = child_v; mt = child_rt; vr = v; rt }, false)
  | _, true ->
      (* Growth must produce a 2-node at the root, which would have been
          handled by the previous branch. *)
      impossible ()

(** [ins_sub2_right x lt v rt] inserts [x] into the right subtree of a 2-node,
    where that two-node is [Two {lt; v; rt}]. Returns [new_t, grew], where
    [new_t] is the new tree (including [lt], [v], and [rt]) and [grew] is
    whether the tree height grew as a result of the insert. *)
and ins_sub2_right (x : 'a) (lt : 'a t) (v : 'a) (rt : 'a t) : 'a t * bool =
  match ins x rt with
  | new_rt, false ->
      (* [x] was inserted into [rt] without growing the height, so we can
          safely reattach the resulting subtree without doing any more work to
          rebalance. *)
      (Two { lt; v; rt = new_rt }, false)
  | Two { lt = child_lt; v = child_v; rt = child_rt }, true ->
      (* [x] was inserted into [rt], and that caused [rt] to grow in height
          and have a 2-node at its root. We can merge that 2-node into the
          current 2-node to form a 3-node, which absorbs the change in
          height. *)
      (Three { lt; vl = v; mt = child_lt; vr = child_v; rt = child_rt }, false)
  | _, true -> impossible ()

(** [ins_sub3 x lt vl mt vr rt] inserts [x] into one of the subtrees of a
    3-node, where that 3-node is [Three {lt; vl; mt; vr; rt}]. Returns
    [new_t, grew], where [new_t] is the new tree (including [lt], [vl], [mt],
    [vr], and [rt]) and [grew] is whether the tree height grew as a result of
    the insert. Requires: [x <> vl && x <> vr]. *)
and ins_sub3 (x : 'a) (lt : 'a t) (vl : 'a) (mt : 'a t) (vr : 'a) (rt : 'a t)
    : 'a t * bool =
  if x < vl then
    (* [x] belongs in [lt]. *)
    ins_sub3_left x lt vl mt vr rt
  else if x > vr then
    (* [x] belongs in [rt]. *)
    ins_sub3_right x lt vl mt vr rt
  else if x > vl && x < vr then
    (* [x] belongs in [mt]. *)
    ins_sub3_middle x lt vl mt vr rt
  else
    (* [x] belongs in neither [lt] nor [mt] nor [rt], but then we should never
        have called [ins_sub3] on it. *)
    failwith "precondition violated"

(** [ins_sub3_left x lt vl mt vr rt] inserts [x] into the left subtree of a
    3-node, where that 3-node is [Three {lt; vl; mt; vr; rt}]. Returns
    [new_t, grew], where [new_t] is the new tree (including [lt], [vl], [mt],
    [vr], and [rt]) and [grew] is whether the tree height grew as a result of
    the insert. *)
and ins_sub3_left
    (x : 'a)
    (lt : 'a t)
    (vl : 'a)
    (mt : 'a t)
    (vr : 'a)
    (rt : 'a t) : 'a t * bool =
  match ins x lt with
  | new_lt, false ->
      (* [x] was inserted into [lt] without growing the height, so we can
          safely reattach the resulting subtree without doing any more work to
          rebalance. *)
      (Three { lt = new_lt; vl; mt; vr; rt }, false)
  | Two { lt = child_lt; v = child_v; rt = child_rt }, true ->
      (* [x] was inserted into [lt], and that caused [lt] to grow in height
          and have a 2-node at its root. We cannot merge that 2-node into the
          current 3-node. Instead, we split the 3-node into 2-nodes, which
          causes the growth to continue upward in the tree. *)
      ( Two
          {
            lt = Two { lt = child_lt; v = child_v; rt = child_rt };
            v = vl;
            rt = Two { lt = mt; v = vr; rt };
          },
        true )
  | _, true ->
      (* Growth must produce a 2-node at the root, which would have been
          handled by the previous branch. *)
      impossible ()

(** [ins_sub3_right x lt vl mt vr rt] inserts [x] into the right subtree of a
    3-node, where that 3-node is [Three {lt; vl; mt; vr; rt}]. Returns
    [new_t, grew], where [new_t] is the new tree (including [lt], [vl], [mt],
    [vr], and [rt]) and [grew] is whether the tree height grew as a result of
    the insert. *)
and ins_sub3_right
    (x : 'a)
    (lt : 'a t)
    (vl : 'a)
    (mt : 'a t)
    (vr : 'a)
    (rt : 'a t) : 'a t * bool =
  match ins x rt with
  | new_rt, false ->
      (* [x] was inserted into [rt] without growing the height, so we can
          safely reattach the resulting subtree without doing any more work to
          rebalance. *)
      (Three { lt; vl; mt; vr; rt = new_rt }, false)
  | Two { lt = child_lt; v = child_v; rt = child_rt }, true ->
      (* [x] was inserted into [rt], and that caused [rt] to grow in height
          and have a 2-node at its root. We cannot merge that 2-node into the
          current 3-node. Instead, we split the 3-node into 2-nodes, which
          causes the growth to continue upward in the tree. *)
      ( Two
          {
            lt = Two { lt; v = vl; rt = mt };
            v = vr;
            rt = Two { lt = child_lt; v = child_v; rt = child_rt };
          },
        true )
  | _, true ->
      (* Growth must produce a 2-node at the root, which would have been
          handled by the previous branch. *)
      impossible ()

(** [ins_sub3_middle x lt vl mt vr rt] inserts [x] into the middle subtree of
    a 3-node, where that 3-node is [Three {lt; vl; mt; vr; rt}]. Returns
    [new_t, grew], where [new_t] is the new tree (including [lt], [vl], [mt],
    [vr], and [rt]) and [grew] is whether the tree height grew as a result of
    the insert. *)
and ins_sub3_middle
    (x : 'a)
    (lt : 'a t)
    (vl : 'a)
    (mt : 'a t)
    (vr : 'a)
    (rt : 'a t) : 'a t * bool =
  match ins x mt with
  | new_mt, false ->
      (* [x] was inserted into [mt] without growing the height, so we can
          safely reattach the resulting subtree without doing any more work to
          rebalance. *)
      (Three { lt; vl; mt = new_mt; vr; rt }, false)
  | Two { lt = child_lt; v = child_v; rt = child_rt }, true ->
      (* [x] was inserted into [mt], and that caused [mt] to grow in height
          and have a 2-node at its root. We cannot merge that 2-node into the
          current 3-node. Instead, we split the 3-node into 2-nodes, which
          causes the growth to continue upward in the tree. *)
      ( Two
          {
            lt = Two { lt; v = vl; rt = child_lt };
            v = child_v;
            rt = Two { lt = child_rt; v = vr; rt };
          },
        true )
  | _, true ->
      (* Growth must produce a 2-node at the root, which would have been
          handled by the previous branch. *)
      impossible ()

let insert x s =
  let new_tree, _grew = ins x s in
  new_tree
```