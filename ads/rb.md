# Red-Black Trees

Red-black trees are relatively simple balanced binary tree data
structure. The idea is to strengthen the representation invariant so a
tree has height logarithmic in the number of nodes \\(n\\). To help
enforce the invariant, we color each node of the tree either *red* or
*black*. Where it matters, we consider the color of an empty tree to be
black.

```
type color = Red | Black
type 'a rbtree =
  Node of color * 'a * 'a rbtree * 'a rbtree | Leaf
```

Here are the new conditions we add to the binary search tree
representation invariant:

1.  There are no two adjacent red nodes along any path.
2.  Every path from the root to a leaf has the same number of black
    nodes. This number is called the *black height* (BH) of the tree.

If a tree satisfies these two conditions, it must also be the case that
every subtree of the tree also satisfies the conditions. If a subtree
violated either of the conditions, the whole tree would also.

Additionally, we require that the root of the tree be colored black.
This can always be enforced by simply setting its color to black; doing
this does not cause any other invariants to be violated.

With these invariants, the longest possible path from the root to an
empty node would alternately contain red and black nodes; therefore it
is at most twice as long as the shortest possible path, which only
contains black nodes. The longest path cannot have a length greater than
twice the length of the paths in a perfect binary tree, which is
\\(O(\log n\\). Therefore, the tree has height \\(O(\log n\\) and the
operations are all asymptotically logarithmic in the number of nodes.

How do we check for membership in red-black trees? Exactly the same way
as for general binary trees.

```
let rec mem x = function
  | Leaf -> false
  | Node (_, y, left, right) ->
	  x = y || (x < y && mem x left) || (x > y && mem x right)
```

More interesting is the `insert` operation. As with standard binary
trees, we add a node by replacing the leaf found by the search
procedure. We also color the new node red to ensure that invariant 2 is
preserved. However, this may destroy invariant 1 by producing two
adjacent red nodes. In order to restore the invariant, we consider not
only the new red node and its red parent, but also its (black)
grandparent. The next figure shows the four possible cases that can
arise.

```
           1             2             3             4

           Bz            Bz            Bx            Bx
          / \           / \           / \           / \
         Ry  d         Rx  d         a   Rz        a   Ry
        /  \          / \               /  \          /  \
      Rx   c         a   Ry            Ry   d        b    Rz
     /  \               /  \          / \                /  \
    a    b             b    c        b   c              c    d
```

Notice that in each of these trees, the values of the nodes in `a`, `b`, `c`,
and `d` must have the same relative ordering with respect to `x`, `y`, and `z`: 
`a < x < b < y < c < z < d`.
Therefore, we can transform the tree to restore the invariant locally by
replacing any of the above four cases with:

```
         Ry
        /  \
      Bx    Bz
     / \   / \
    a   b c   d
```

This balance function can be written simply and concisely using pattern
matching, where each of the four input cases is mapped to the same
output case. In addition, there is the case where the tree is left
unchanged locally.

```
let balance = function
  | Black, z, Node (Red, y, Node (Red, x, a, b), c), d
  | Black, z, Node (Red, x, a, Node (Red, y, b, c)), d
  | Black, x, a, Node (Red, z, Node (Red, y, b, c), d)
  | Black, x, a, Node (Red, y, b, Node (Red, z, c, d)) ->
	  Node (Red, y, Node (Black, x, a, b), Node (Black, z, c, d))
  | a, b, c, d -> Node (a, b, c, d)
```

This balancing transformation possibly breaks invariant 1 one level up
in the tree, but it can be restored again at that level in the same way,
and so on up the tree. In the worst case, the process cascades all the
way up to the root, resulting in two adjacent red nodes, one of them the
root. But if this happens, we can just recolor the root black, which
increases the BH by one. The amount of work is \\(O(\log n)\\). The
`insert` code using `balance` is as follows:

```
let insert x s =
  let rec ins = function
    | Leaf -> Node (Red, x, Leaf, Leaf)
    | Node (color, y, a, b) as s ->
	  if x < y then balance (color, y, ins a, b)
	  else if x > y then balance (color, y, a, ins b)
	  else s in
  match ins s with
	| Node (_, y, a, b) -> Node (Black, y, a, b)
	| Leaf -> (* guaranteed to be nonempty *)
		failwith "RBT insert failed with ins returning leaf"
```

Removing an element from a red-black tree works analogously. We start
with BST element removal and then do rebalancing. When an interior
(nonleaf) node is removed, we simply splice it out if it has fewer than
two nonleaf children; if it has two nonleaf children, we find the next
value in the tree, which must be found inside its right child.

Balancing the trees during removal from red-black tree requires
considering more cases. Deleting a black element from the tree creates
the possibility that some path in the tree has too few black nodes,
breaking the black-height invariant 2. The solution is to consider that
path to contain a "doubly-black" node. A series of tree rotations can
then eliminate the doubly-black node by propagating the "blackness" up
until a red node can be converted to a black node, or until the root is
reached and it can be changed from doubly-black to black without
breaking the invariant.
