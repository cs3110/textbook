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

# Red-Black Trees

{{ video_embed | replace("%%VID%%", "uOKHuYloCsI")}}

As we've now seen, hash tables are an efficient data structure for implementing
a map ADT. They offer amortized, expected constant-time performance&mdash;which
is a subtle guarantee because of those "amortized" and "expected" qualifiers we
have to add. Hash tables also require mutability to implement.  As functional
programmers, we prefer to avoid mutability when possible.

So, let's investigate how to implement functional maps. One of the best data
structures for that is the *red-black tree*, which is a kind of balanced binary
search tree that offers worst-case logarithmic performance. So on one hand the
performance is somewhat worse than hash tables (logarithmic vs. constant), but
on the other hand we don't have to qualify the performance with words like
"amortized" and "expected". Logarithmic is actually still plenty efficient for
even very large workloads. And, we get to avoid mutability!

## Binary Search Trees

{{ video_embed | replace("%%VID%%", "Xx9V5vrkjJA")}}

A **binary search tree** (BST) is a binary tree with the following
representation invariant:

> For any node *n*, every node in the left subtree of *n* has a value less than
> *n*'s value, and every node in the right subtree of *n* has a value greater
> than *n*'s value.

We call that the *BST invariant*.

Here is code that implements a couple of operations on a BST:

```{code-cell} ocaml
type 'a tree = Node of 'a * 'a tree * 'a tree | Leaf

(** [mem x t] is [true] iff [x] is a member of [t]. *)
let rec mem x = function
  | Leaf -> false
  | Node (y, l, r) ->
    if x < y then mem x l
    else if x > y then mem x r
    else true

(** [insert x t] is [t] . *)
let rec insert x = function
  | Leaf -> Node (x, Leaf, Leaf)
  | Node (y, l, r) as t ->
    if x < y then Node (y, insert x l, r)
    else if x > y then Node (y, l, insert x r)
    else t
```

What is the running time of those operations? Since `insert` is just a `mem`
with an extra constant-time node creation, we focus on the `mem` operation.

{{ video_embed | replace("%%VID%%", "pFUJgaYUH6o")}}

The running time of `mem` is $O(h)$, where $h$ is the height of the tree,
because every recursive call descends one level in the tree. What's the
worst-case height of a tree? It occurs with a tree of $n$ nodes all in a single
long branch&mdash;imagine adding the numbers 1,2,3,4,5,6,7 in order into the
tree. So the worst-case running time of `mem` is still $O(n)$, where $n$ is the
number of nodes in the tree.

What is a good shape for a tree that would allow for fast lookup? A *perfect
binary tree* has the largest number of nodes $n$ for a given height $h$, which
is $n = 2^{h+1} - 1$. Therefore $h = \log(n+1) - 1$, which is $O(\log n)$.

If a tree with $n$ nodes is kept balanced, its height is $O(\log n)$, which
leads to a lookup operation running in time $O(\log n)$.

{{ video_embed | replace("%%VID%%", "BGkipOJdH3U")}}

How can we keep a tree balanced? It can become unbalanced during element
insertion or deletion. Most balanced tree schemes involve adding or deleting an
element just like in a normal binary search tree, followed by some kind of *tree
surgery* to rebalance the tree. Some examples of balanced binary search tree
data structures include:

- AVL trees (1962)
- 2-3 trees (1970's)
- Red-black trees (1970's)

Each of these ensures $O(\log n)$ running time by enforcing a stronger invariant
on the data structure than just the binary search tree invariant.

## Red-Black Trees

{{ video_embed | replace("%%VID%%", "JzhG0jDxGqg")}}

Red-black trees are relatively simple balanced binary tree data structure. The
idea is to strengthen the representation invariant so a tree has height
logarithmic in the number of nodes $n$. To help enforce the invariant, we color
each node of the tree either *red* or *black*. Where it matters, we consider the
color of an empty tree to be black.

```{code-cell} ocaml
type color = Red | Black
type 'a rbtree = Leaf | Node of color * 'a * 'a rbtree * 'a rbtree
```

Here are the new conditions we add to the binary search tree representation
invariant:

1. **Local Invariant:** There are no two adjacent red nodes along any path.

2. **Global Invariant:** Every path from the root to a leaf has the same number
   of black nodes. This number is called the *black height* (BH) of the tree.

If a tree satisfies these two conditions, it must also be the case that every
subtree of the tree also satisfies the conditions. If a subtree violated either
of the conditions, the whole tree would also.

Additionally, by convention the root of the tree is colored black. This does not
violate the invariants, but it also is not required by them.

With these invariants, the longest possible path from the root to an empty node
would alternately contain red and black nodes; therefore it is at most twice as
long as the shortest possible path, which only contains black nodes. The longest
path cannot have a length greater than twice the length of the paths in a
perfect binary tree, which is $O(\log n)$. Therefore, the tree has height
$O(\log n)$ and the operations are all asymptotically logarithmic in the number
of nodes.

{{ video_embed | replace("%%VID%%", "gDTCRj2-bCU")}}

How do we check for membership in red-black trees? Exactly the same way as for
general binary trees.

```{code-cell} ocaml
let rec mem x = function
  | Leaf -> false
  | Node (_, y, l, r) ->
    if x < y then mem x l
    else if x > y then mem x r
    else true
```

{{ video_embed | replace("%%VID%%", "dCBAhbIEoYM")}}

**Okasaki's Algorithm.** More interesting is the `insert` operation. As with
standard binary trees, we add a node by replacing the leaf found by the search
procedure. But what can we color that node?

- Coloring it black could increase the black height of that path, violating the
  Global Invariant.

- Coloring it red could make it adjacent to another red node, violating the
  Local Invariant.

So neither choice is safe in general. Chris Okasaki (*Purely Functional Data
Structures*, 1999) gives an elegant algorithm that solves the problem by opting
to violate the Local Invariant, then walk up the tree to repair the violation.
Here's how it works.

{{ video_embed | replace("%%VID%%", "dCBAhbIEoYM")}}

We always color the new node red to ensure that the Global Invariant is
preserved. However, this may destroy the Local Invariant by producing two
adjacent red nodes. In order to restore the invariant, we consider not only the
new red node and its red parent, but also its (black) grandparent.

{{ video_embed | replace("%%VID%%", "igUOhpGICgA")}}

The next figure shows the four possible cases that can arise. In it, `a`-`d` are
possibly empty subtrees, and `x`-`z` are values stored at a node. The nodes
colors are indicated with `R` and `B`.

```text
           1             2             3             4

           Bz            Bz            Bx            Bx
          / \           / \           / \           / \
         Ry  d         Rx  d         a   Rz        a   Ry
        /  \          / \               /  \          /  \
      Rx   c         a   Ry            Ry   d        b    Rz
     /  \               /  \          / \                /  \
    a    b             b    c        b   c              c    d
```

Notice that in each of these trees, we've carefully labeled the values and nodes
such that the binary search tree invariant ensures the following ordering:

```
all nodes in a
 <
  x
   <
    all nodes in b
     <
      y
       <
        all nodes in c
         <
          z
           <
            all nodes in d
```

Therefore, we can transform the tree to restore the invariant locally by
replacing any of the above four cases with:

```text
         Ry
        /  \
      Bx    Bz
     / \   / \
    a   b c   d
```

```{tip}
To really understand Okasaki's algorithm, ensure that the last three diagrams
make sense. The choice of which labels are placed where in the first diagram is
crucial. That's what guarantees the ordering holds, hence that the final tree is
the same in all four cases.
```

{{ video_embed | replace("%%VID%%", "D4FJMJUIMSw")}}

This balance function can be written simply and concisely using pattern
matching, where each of the four input cases is mapped to the same output case.
In addition, there is the case where the tree is left unchanged locally.

```{code-cell} ocaml
let balance = function
  | Black, z, Node (Red, y, Node (Red, x, a, b), c), d
  | Black, z, Node (Red, x, a, Node (Red, y, b, c)), d
  | Black, x, a, Node (Red, z, Node (Red, y, b, c), d)
  | Black, x, a, Node (Red, y, b, Node (Red, z, c, d)) ->
    Node (Red, y, Node (Black, x, a, b), Node (Black, z, c, d))
  | a, b, c, d -> Node (a, b, c, d)
```

This balancing transformation possibly breaks the Local Invariant one level up
in the tree, but it can be restored again at that level in the same way, and so
on up the tree. In the worst case, the process cascades all the way up to the
root, resulting in two adjacent red nodes, one of them the root. But if this
happens, we can just recolor the root black, which increases the black height by
one. The amount of work is $O(\log n)$. The `insert` code using `balance` is as
follows:

```{code-cell} ocaml
let insert x s =
  let rec ins = function
    | Leaf -> Node (Red, x, Leaf, Leaf)
    | Node (color, y, a, b) as s ->
      if x < y then balance (color, y, ins a, b)
      else if x > y then balance (color, y, a, ins b)
      else s
  in
  match ins s with
  | Node (_, y, a, b) -> Node (Black, y, a, b)
  | Leaf -> (* guaranteed to be nonempty *)
    failwith "RBT insert failed with ins returning leaf"
```

{{ video_embed | replace("%%VID%%", "giSzhfuTMMA")}}

**The remove operation.** Removing an element from a red-black tree works
analogously. We start with a BST element removal and then do rebalancing. When
an interior (nonleaf) node is removed, we simply splice it out if it has fewer
than two nonleaf children; if it has two nonleaf children, we find the next
value in the tree, which must be found inside its right child.

But, balancing the trees during removal from red-black tree requires considering
more cases. Deleting a black element from the tree creates the possibility that
some path in the tree has too few black nodes, breaking the Global Invariant.

Germane and Might invented an elegant algorithm to handle that rebalancing Their
solution is to create "doubly-black" nodes that count twice in determining the
black height. For more, read their paper: [*Deletion: The Curse of the Red-Black
Tree* *Journal of Functional Programming*], volume 24, issue 4, July 2014.

[gm]: https://doi.org/10.1017/S0956796814000227

## Maps and Sets from BSTs

{{ video_embed | replace("%%VID%%", "B_e8Qr4nl4A")}}

It's easy to use a BST to implement either a map or a set ADT:

- For a map, just store a binding at each node. The nodes are ordered by the
  keys. The values are irrelevant to the ordering.

- For a set, just store an element at each node. The nodes are ordered by the
  elements.

The OCaml standard library does this for the `Map` and `Set` modules. It uses a
balanced BST that is a variant of an AVL tree. AVL trees are balanced BSTs in
which the height of paths is allowed to vary by at most 1. The OCaml standard
library modifies that to allow the height to vary by at most 2. Like red-black
trees, they achieve worst-case logarithmic performance.

Now that we have a functional map data structure, how does it compare to our
imperative version, the hash table?

- **Persistence:** Our red-black trees are persistent, but hash tables are
  ephemeral.

- **Performance:** We get guaranteed worst-case logarithmic performance with
  red-black trees, but amortized, expected constant-time with hash tables.
  That's somewhat hard to compare given all the modifiers involved. It's also an
  example of a general phenomenon that persistent data structures often have to
  pay an extra logarithmic cost over the equivalent ephemeral data structures.

- **Convenience:** We have to provide an ordering function for balanced binary
  trees, and a hash function for hash tables. Most libraries provide a default
  hash function for convenience. But the performance of the hash table does
  depend on that hash function truly distributing keys randomly over buckets. If
  it doesn't, the "expected" part of the performance guarantee for hash tables
  is violated. So the convenience is a double-edged sword.

There isn't a clear winner here. Since the OCaml library provides both `Map` and
`Hashtbl`, you get to choose.
