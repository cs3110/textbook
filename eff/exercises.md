# Exercises

## Trees

##### Exercise: functorized BST [&#10029;&#10029;&#10029;]

Our implementation of BSTs in lecture assumed that it was okay
to compare values using the built-in comparison operators `<`, `=`, 
and `>`.  But what if the client of the `Set` abstraction wanted to
use their own comparison operators?  (e.g., to ignore case in strings,
or to have sets of records where only a single field of the record
was used for ordering.)  Reimplement the `BstSet` abstraction as a
functor parameterized on a structure that enables client-provided
comparison operator(s), much like the [standard library `Set`][stdlib-set]. 

[stdlib-set]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Set.html

&square;

##### Exercise: efficient traversal [&#10029;&#10029;&#10029;]

Suppose you wanted to convert a tree to a list.  You'd have to 
put the values stored in the tree in some order.  Here are three
ways of doing that:

* *preorder*: each node's value appears in the list before the values of its
  left then right subtrees.
  
* *inorder*: the values of the left subtree appear, then the value at the node,
  then the values of the right subtree.
  
* *postorder*:  the values of a node's left then right subtrees appear, followed by
  the value at the node.

Here is code that implements those *traversals*, along with 
some example applications:

```
type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree

let rec preorder = function
  | Leaf -> []
  | Node (l,v,r) -> [v] @ preorder l @ preorder r

let rec inorder = function
  | Leaf -> []
  | Node (l,v,r) ->  inorder l @ [v] @ inorder r

let rec postorder = function
  | Leaf -> []
  | Node (l,v,r) ->  postorder l @ postorder r @ [v]

let t =
  Node(Node(Node(Leaf, 1, Leaf), 2, Node(Leaf, 3, Leaf)),
       4,
       Node(Node(Leaf, 5, Leaf), 6, Node(Leaf, 7, Leaf)))
       
(* 
  t is
        4
      /   \
     2     6
    / \   / \
   1   3 5   7
*)

let () = assert (preorder t  = [4;2;1;3;6;5;7])
let () = assert (inorder t   = [1;2;3;4;5;6;7])
let () = assert (postorder t = [1;3;2;5;7;6;4])
```

On unbalanced trees, the traversal functions above require quadratic
worst-case time (in the number of nodes), because of the `@` operator.
Re-implement the functions without `@`, and instead using `::`, such
that they perform exactly one cons per `Node` in the tree. Thus the
worst-case execution time will be linear. You will need to add an
additional accumulator argument to each function, much like with tail
recursion.  (But your implementations won't actually be tail recursive.)

&square;

##### Exercise: RB draw complete [&#10029;&#10029;]

Draw the perfect binary tree on the values 1, 2, ..., 15.
Color the nodes in three different ways such that (i) each
way is a red-black tree (i.e., satisfies the red-black invariants),
and (ii) the three ways create trees with black heights of
2, 3, and 4, respectively.  The *black height* of a tree
is the maximum number of black nodes along any path from its
root to a leaf.

&square;

##### Exercise: RB draw insert [&#10029;&#10029;]

Draw the red-black tree that results from inserting 
the characters D A T A S T R U C T U R E into an empty tree.
Carry out the insertion algorithm yourself by hand, then check
your work with the implementation provided in lecture.

&square;

##### Exercise: standard library set [&#10029;&#10029;, optional]

Read the [source code][stdlib-set-ml] of the standard library `Set` module.
Find the representation invariant for the balanced trees that it uses.
Which kind of tree does it most resemble:  2-3, AVL, or red-black?

[stdlib-set-ml]: https://github.com/ocaml/ocaml/blob/trunk/stdlib/set.ml

&square;
