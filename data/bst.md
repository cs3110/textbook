# Binary Search Trees

Recall that an *association list* is a list of pairs that implements a
*dictionary*, and that insertion in an association list is constant
time, but lookup is linear time. 

A more efficient dictionary implementation can be achieved with *binary
search trees* (BSTs). Each node of the tree will be a pair of a key and value,
just like in an association list. Furthermore, the tree obeys
the **binary search tree invariant**: for any node n, all of
the values in the left subtree of n have keys that are less than n's
key, and all of the values in the right subtree of n have keys that are
greater than n's key.  (We do not allow duplicate keys.)

For example, here is a binary search tree representing a dictionary
that maps the integers 1..3 to English words.
```
let d = 
  Node((2,"two"), 
    Node((1,"one"),Leaf,Leaf),
    Node((3,"three"),Leaf,Leaf)
  )
```

If a binary search tree is *balanced*, meaning that the depths of various
paths through the tree are all about the same, then lookup can be
a logarithmic time operation.  One famous balanced tree
data structure is the [2-3 tree][23tree], invented by Cornell's own 
Prof. John Hopcroft in 1970.  But for now, we won't worry about balancing.

[23tree]: https://en.wikipedia.org/wiki/2%E2%80%933_tree

To lookup a mapping in the tree, we use the BST invariant to
guide the search down either the left or right child of a node.
```
(* returns: [Some v] if [v] is the value associated with [key] in [tree],
 * or [None] if no such [v] exists.
 *)
let rec lookup key = function
  | Leaf -> None
  | Node ((k, v), l, r) ->
    if key = k then Some v
    else if key < k then lookup key l
    else lookup key r
```

Likewise, to insert a mapping in the tree, we use the BST invariant
to find the right place to perform the insertion.
```
(* returns: [insert key value tree] contains the same mappings
 *  as [tree], as well as [key] mapped to [value].  If [key] was
 *  already mapped in [tree], then the previous binding is replaced
 *  by the new bindings to [value].
 *)
let rec insert key value = function
  | Leaf -> Node ((key, value), Leaf, Leaf)
  | Node ((k, v), l, r) ->
    if key = k then Node ((key, value), l, r)
    else if key < k then Node ((k, v), insert key value l, r)
    else Node ((k, v), l, insert key value r)

```

The two functions above can be rewritten using `when` to make
their structure more parallel:

```
let rec lookup key = function
  | Leaf -> None
  | Node ((k, v), _, _) when key = k -> Some v
  | Node ((k, _), l, _) when key < k -> lookup key l
  | Node ((k, _), _, r) when key > k -> lookup key r
  | _ -> failwith "impossible" (* k must be =, <, or > key *)
  
let rec insert key value = function
  | Leaf -> Node ((key, value), Leaf, Leaf)
  | Node ((k, _), l, r) when key = k -> Node ((key, value), l, r)
  | Node ((k, v), l, r) when key < k -> Node ((k, v), insert key value l, r)
  | Node ((k, v), l, r) when key > k -> Node ((k, v), l, insert key value r)
  | _ -> failwith "impossible" (* k must be =, <, or > key *)
```
  
Without the final catch-all cases above, the compiler will give a warning
about a potentially inexhaustive pattern match.  In fact the match
is exhaustive, but it's beyond the compiler's ability to figure that out.

