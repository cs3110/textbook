# Example: Trees

Trees are a very useful data structure.  Unlike lists, they are
not built into OCaml. A *binary tree*, as you'll recall from CS 2110, is
a node containing a value and two children that are trees. A binary tree
can also be an empty tree, which we also use to represent the absence of
a child node. 

## Representation with Tuples

Here is a definition for a binary tree data type:
```
type 'a tree = 
| Leaf 
| Node of 'a * 'a tree * 'a tree
```

A node carries a data item of type `'a` and has a left and right subtree.  A leaf
is empty.  Compare this definition to the definition of a list and notice how
similar their structure is:

```
type 'a tree =                        type 'a mylist =
| Leaf                                | Nil
| Node of 'a * 'a tree * 'a tree      | Cons of 'a * 'a mylist
```

The only essential difference is that `Cons` carries one sublist, whereas
`Node` carries two subtrees.

Here is code that constructs a small tree:
```
(* the code below constructs this tree:
         4
       /   \
      2     5
     / \   / \
    1   3 6   7 
*)
let t = 
  Node(4,
    Node(2,
      Node(1,Leaf,Leaf),
      Node(3,Leaf,Leaf)
    ),
    Node(5,
      Node(6,Leaf,Leaf),
      Node(7,Leaf,Leaf)
    )
  )
```

The *size* of a tree is the number of nodes in it (that is, `Node`s, not `Leaf`s).
For example, the size of tree `t` above is 7.  Here is a function
function `size : 'a tree -> int` that returns the number of nodes in
a tree:
```
let rec size = function
  | Leaf -> 0
  | Node (_,l,r) -> 1 + size l + size r
```

## Representation with Records

Next, let's revise our tree type to use use a record type to represent
a tree node. In OCaml we have to define two mutually recursive types,
one to represent a tree node, and one to represent a (possibly empty)
tree:

```
type 'a tree = 
  | Leaf 
  | Node of 'a node

and 'a node = { 
  value: 'a; 
  left:  'a tree; 
  right: 'a tree
}
```

The rules on when mutually recursive type declarations are legal are a
little tricky. Essentially, any cycle of recursive types must include at
least one record or variant type. Since the cycle between `'a tree` and
`'a node` includes both kinds of types, it's legal.

Here's an example tree:
```
(* represents
      2
     / \ 
    1   3  *)
let t =
  Node {
    value = 2; 
    left  = Node {value=1; left=Leaf; right=Leaf};
    right = Node {value=3; left=Leaf; right=Leaf}  
  }
```

We can use pattern matching to write the usual algorithms for
recursively traversing trees. For example, here is a recursive search
over the tree:

```
(* [mem x t] returns [true] if and only if [x] is a value at some
 * node in tree [t]. 
 *)
let rec mem x = function
  | Leaf -> false
  | Node {value; left; right} -> value = x || mem x left || mem x right
```
The function name `mem` is short for "member"; the standard library 
often uses a function of this name to implement a search through a 
collection data structure to determine whether some element is a member of that 
collection.

Here's a function that computes the *preorder* traversal of a tree, in 
which each node is visited before any of its children, by constructing
a list in which the values occur in the order in which they would
be visited:
```
let rec preorder = function
  | Leaf -> []
  | Node {value; left; right} -> [value] @ preorder left @ preorder right
```
Although the algorithm is beautifully clear from the code above, it takes
quadratic time on unbalanced trees because of the `@` operator.  That
problem can be solved by introducing an extra argument `acc` to accumulate
the values at each node, though at the expense of making the code less clear:
```
let preorder_lin t = 
  let rec pre_acc acc = function
    | Leaf -> acc
    | Node {value; left; right} -> value :: (pre_acc (pre_acc acc right) left)
  in pre_acc [] t
```
The version above uses exactly one `::` operation per `Node` in the tree,
making it linear time.