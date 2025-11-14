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
But for now, since Michael Clarkson learned it from Andrew Appel, we will call it Appel's algorithm.

With Appel's algorithm, we transform the leaf at which the search ends into a new 2-node with no children that contains the inserted value.
That maintains the ordering invariant, but in general violates the balance invariant, because the new 2-node causes the length of the search path to grow by one.
Another way to put that is: the height of the tree grows by one.

So, we recurse back up the tree to restore the balance invariant and ensure that all paths have the same length.
The goal is to find a place to *absorb* the change in height, if possible.
Since we just created a new 2-node, as we recurse up, there are two cases to consider:
the parent of the new node is a 2-node, in which case we perform a *merge* operation; or it is a 3-node, in which case we perform a *split* operation.
Those operations work as follows.

### Merge

Coming soon!

### Split

Coming soon!

### Finishing Insertion

Coming soon!