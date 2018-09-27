# Binary Search Trees

A **binary search tree** (BST) is a binary tree with the following
representation invariant:

> For any node *n*, every node in the left subtree of *n* has a value
> less than *n*'s value, and every node in the right subtree of *n* has
> a value greater than *n*'s value.

We call that the *BST invariant*.

Here is code that implements a couple operations on a BST:

```
type 'a tree = Node of 'a * 'a tree * 'a tree | Leaf

(** [mem x t] is [true] iff [x] is a member of [t]. *)
let rec mem x = function
  | Leaf -> false
  | Node (y, l, r) ->
    x = y || (x < y && mem x l) || mem x r
    
(** [insert x t] is [t] . *)    
let rec insert x = function
  | Leaf -> Node (x, Leaf, Leaf) 
  | Node (y, l, r) as t -> 
	  if x = y then t
	  else if x < y then Node (y, insert x l, r)
	  else Node (y, l, insert x r)
```

What is the running time of those operations? Since `insert` is just a
`mem` with an extra constant-time node creation, we focus on the
`mem` operation. 

The running time of `mem` is \\(O(h)\\), where \\(h\\)
is the height of the tree, because every recursive call descends
one level in the tree.  What's the worst-case height of a
tree? It occurs with a tree of \\(n\\) nodes all in a single long
branch&mdash;imagine adding the numbers 1,2,3,4,5,6,7 in order into 
the tree. So the worst-case running time of `mem` is still
\\O(n)\\), where \\(n\\) is the number of nodes in the tree.

What is a good shape for a tree that would allow for fast lookup? A
*perfect binary tree* has the largest number of nodes \\(n\\) for a given
height \\(h\\), which is 
\\(n = 2^{h+1}−1\\). Therefore \\(h = \log(n+1)−1\\), which is \\(O(\log n)\\).

              ^                   50
              |               /        \
              |           25              75
     height=3 |         /    \          /    \
      n=15    |       10     30        60     90
              |      /  \   /  \      /  \   /  \
              V     4   12 27  40    55  65 80  99

If a tree with \\(n\\) nodes is kept balanced, its height is
\\(O(\log n)\\), which leads to a lookup operation running in time
\\(O(\log n)\\).

How can we keep a tree balanced? It can become unbalanced during element
insertion or deletion. Most balanced tree schemes involve adding or
deleting an element just like in a normal binary search tree, followed
by some kind of *tree surgery* to rebalance the tree. Some examples of
balanced binary search tree data structures include

-   AVL trees (1962)
-   2-3 trees (1970's)
-   Red-black trees (1970's)

Each of these ensures \\(O(\log n)\\) running time by
enforcing a stronger invariant on the data structure than just the
binary search tree invariant.
