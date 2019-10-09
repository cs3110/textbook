# Exercises

## Hashing

##### Exercise: hash insert  [&#10029;&#10029;] 

Suppose we have a hash table on integer keys. The table currently has 7
empty buckets, and the hash function is simply `let hash k = k mod 7`.
Draw the hash table that results from inserting the keys 4, 8, 15, 16,
23, and 42 (with whatever values you like).

&square;

##### Exercise: relax bucket RI  [&#10029;&#10029;] 

In lecture, we required that hash table buckets must not contain
duplicates.  What would happen if we relaxed this RI to allow
duplicates?  Would the efficiency of any operations (insert, find, or
remove) change?

&square;

##### Exercise: strengthen bucket RI  [&#10029;&#10029;] 

What would happen if we strengthened the bucket RI to require
each bucket to be sorted by the key? Would the efficiency of 
any operations (insert, find, or remove) change?

&square;

##### Exercise: hash values [&#10029;&#10029;] 

`Hashtbl.hash : 'a -> int` is a hash function provided by
the standard library. This rather remarkable
function can transform a value of any type into an integer.
Use it to hash several values of different types. 
Make sure to try at least `()`, `false`, `true`, `0`, `1`, `""`,
and `[]`, as well as several "larger" values of each type.
Try hashing lists of integers of increasing length (e.g., 
`[0]`, `[0;1]`, `[0;1;2]`, ...).  How long can the list get
before you find a collision?

&square;

## Hashtbl

OCaml's `Hashtbl` module offers two kinds of hash tables.  The 
first (and simpler to use) is for clients who are happy to use
OCaml's built-in hash function.  The second is for clients
who want to supply their own hash function; naturally, that is done
with a functor.

For the following exercises, consult the [documentation of
`Hashtbl`][hashtbl].

[hashtbl]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Hashtbl.html 	

##### Exercise: hashtbl usage  [&#10029;&#10029;] 

Create a hash table `tab` with `Hashtbl.create` whose initial size is 16.
(You can safely ignore the optional argument to that function
for now.) Add 31 bindings to it with `Hashtbl.add`.
For example, you could add the numbers 1..31 as keys and
the strings "1".."31" as their values.  Use `Hashtbl.find`
to look for keys that are in `tab`, as well as keys
that are not.

&square;

##### Exercise: hashtbl bindings  [&#10029;&#10029;] 

Define a function `bindings : ('a,'b) Hashtbl.t -> ('a*'b) list`,
such that `bindings h` returns a list of all bindings in `h`.
Use your function to see all the bindings in `tab`.  *Hint: fold.*

&square;

##### Exercise: hashtbl stats  [&#10029;] 

Use the `Hashtbl.stats` function to find out the statistics
of `tab`.  How many buckets are in the table?  How many buckets
have a single binding in them?

&square;

##### Exercise: hashtbl load factor [&#10029;&#10029;] 

Define a function `load_factor : ('a,'b) Hashtbl.t -> float`,
such that `load_factor h` is the load factor of `h`.
What is the load factor of `tab`? *Hint: stats.*

&square;

##### Exercise: hashtbl load factor [&#10029;] 

Add one more binding to `tab`.  Do the stats or load factor change?
Now add yet another binding.  Now do the stats or load factor change?
*Hint: Hashtbl [resizes][resize] when the load factor goes strictly 
above 2.*

[resize]: https://github.com/ocaml/ocaml/blob/trunk/stdlib/hashtbl.ml#L167

&square;

## Functorial Hashtbl

##### Exercise: functorial interface [&#10029;&#10029;&#10029;] 

Use the functorial interface (i.e., `Hashtbl.Make`) to
create a hash table whose keys are strings that are 
case insensitive.  Be careful to obey the specification of
`Hashtbl.HashedType.hash`:

> If two keys are equal according to `equal`, then they have 
> identical hash values as computed by `hash`. 

&square;

##### Exercise: equals and hash [&#10029;&#10029;] 

The previous exercise quoted the specification of `Hashtbl.HashedType.hash`.
Compare that to Java's `Object.hashCode()` [specification][hashCode].
Why do they both have this similar requirement?  

[hashCode]: https://docs.oracle.com/javase/8/docs/api/java/lang/Object.html#hashCode--

&square;

##### Exercise: bad hash [&#10029;&#10029;] 

Use the functorial interface to create a hash table with a really
bad hash function (e.g., a constant function).  Use the `stats`
function to see how bad the bucket distribution becomes.

&square;

## Challenge problem: Probing

In lecture we briefly mentioned *probing* as an alternative to
*chaining*.  Probing can be effectively used in hardware implementations
of hash tables, as well as in databases. With probing, every bucket
contains exactly one binding.  In case of a collision, we search forward
through the array, as described below.

**Find.** Suppose we are trying to find a binding in the table.  We hash
the binding's key and look in the appropriate bucket.  If there is
already a different key in that bucket, we start searching forward
through the array at the next bucket, then the next bucket, and so
forth, wrapping back around to the beginning of the array if necessary. 
Eventually we will either 

* find an empty bucket, in which case the key we're searching for is 
  not bound in the table;

* find the key before we reach an empty bucket, in which case we can 
  return the value; or

* never find the key or an empty bucket, instead wrapping back
  around to the original bucket, in which case all buckets are full and
  the key is not bound in the table.  This case actually should
  never occur, because we won't allow the load factor to get
  high enough for all buckets to be filled.

**Insert.** Insertion follows the same algorithm as finding a key,
except that whenever we first find an empty bucket, we can insert the
binding there. 

**Remove.** Removal is more difficult.  Once the key is found,
we can't just make the bucket empty, because that would affect
future searches by causing them to stop early.  Instead, 
we can introduce a special "deleted" value into that bucket
to indicate that the bucket does not contain a binding but
the searches should not stop at it.  

**Resizing.**  Since we never want the array to become
completely full, we can keep the load factor near 1/4.
When the load factor exceeds 1/2, we can double the array,
bringing the load factor back to 1/4.  When the load factor goes below
1/8, we can half the array, again bringing the load factor
back to 1/4.  "Deleted" bindings complicate the definition
of load factor:

* When determining whether to double the table size,
  we calculate the load factor as (# of bindings + # of deleted
  bindings) / (# of buckets).  That is, deleted bindings
  contribute toward increasing the load factor.  
  
* When determining whether the half the table size,
  we calculate the load factor as (# of bindings) / (# buckets).
  That is, deleted bindings do not count toward
  increasing the load factor.
  
When rehashing the table, deleted bindings are of course
not re-inserted into the new table.

##### Exercise: linear probing [&#10029;&#10029;&#10029;&#10029;] 

Implement a hash table that uses linear probing.

&square;

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
