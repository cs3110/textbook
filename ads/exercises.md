# Exercises

## Streams

The next few exercises ask you to work with this type:
```
type 'a stream =
  Cons of 'a * (unit -> 'a stream)
```

##### Exercise: pow2 [&#10029;&#10029;] 

Define a value `pow2 : int stream` whose elements are the powers
of two:  `<1; 2; 4; 8; 16, ...>`.

&square;

##### Exercise: more streams [&#10029;&#10029;, optional] 

Define the following streams:

  - the even naturals
  
  - the lower-case alphabet on endless repeat:  a, b, c, ..., z, a, b, ...
  
  - a stream of pseudorandom coin flips (e.g., booleans or a variant
    with `Heads` and `Tails` constructors)
    
&square;    

##### Exercise: nth [&#10029;&#10029;] 

Define a function `nth : 'a stream -> int -> 'a`, such that
`nth s n` the element at zero-based position `n` in stream `s`.
For example, `nth pow2 0 = 1`, and `nth pow2 4 = 16`.

&square;

##### Exercise: hd tl [&#10029;&#10029;] 

Recall these definitions:
```	
(** [from n] is the stream [<n; n+1; n+2; ...>]. *)
let rec from n = 
  Cons (n, fun () -> from (n+1))
  
(** [nats] is the stream [<0; 1; 2; ...>]. *)
let nats = from 0
  
(** [hd s] is the head of [s] *)  
let hd (Cons (h, _)) = h

(** [tl s] is the tail of [s] *)
let tl (Cons (_, tf)) = tf ()
```  
  
Explain how each of the following is evaluated:
  
  - `hd nats`
  - `tl nats`
  - `hd (tl nats)`
  - `tl (tl nats)`
  - `hd (tl (tl nats))`

&square;


##### Exercise: filter [&#10029;&#10029;&#10029;] 

Define a function `filter : ('a -> bool) -> 'a stream -> 'a stream`,
such that `filter p s` is the sub-stream of `s` whose elements
satisfy the predicate `p`.  For example, `filter (fun n -> n mod 2 = 0) nats`
would be the stream `<0; 2; 4; 6; 8; 10; ...>`.  If there is no
element of `s` that satisfies `p`, then `filter p s` does not terminate.

&square;

##### Exercise: interleave [&#10029;&#10029;&#10029;] 

Define a function `interleave : 'a stream -> 'a stream -> 'a stream`,
such that `interleave <a1; a2; a3; ...> <b1; b2; b3; ...>` 
is the stream `<a1; b1; a2; b2; a3; b3; ...>`.  For example,
`interleave nats pow2` would be `<0; 1; 1; 2; 2; 4; 3; 8; ...>`

&square;

## Sieve Stream

The *Sieve of Eratosthenes* is a way of computing the prime numbers.  

* Start with the stream `<2; 3; 4; 5; 6; ...>`.

* Take 2 as prime.  Delete all multiples of 2, since they cannot be prime.
  That leaves `<3; 5; 7; 9; 11; ...>`.
  
* Take 3 as prime and delete its multiples.
  That leaves `<5; 7; 11; 13; 17; ...>`.

* Take 5 as prime, etc.

##### Exercise: sift [&#10029;&#10029;&#10029;] 

Define a function `sift : int -> int stream -> int stream`,
such that `sift n s` removes all multiples of `n` from `s`.
*Hint: filter.*

&square;

##### Exercise: primes [&#10029;&#10029;&#10029;] 

Define a sequence `prime : int stream`,
containing all the prime numbers starting with 2.

&square;

## e Stream

##### Exercise: approximately e [&#10029;&#10029;&#10029;&#10029;] 

The exponential function \\(e^x\\) can be computed by the following
infinite sum:

\\[ 
e^x = \\frac{x^0}{0!} + \\frac{x^1}{1!} + \\frac{x^2}{2!} 
    + \\frac{x^3}{3!} + \\cdots + \\frac{x^k}{k!} + \\cdots 
\\]

Define a function `e_terms : float -> float stream`.  Element `k` of
the stream should be term `k` from the infinite sum.  For
example, `e_terms 1.0` is the stream 
`<1.0; 1.0; 0.5; 0.1666...; 0.041666...; ...>`.  The easy way to 
compute that involves a function that computes \\(f(k) = \\frac{x^k}{k!}\\).

Define a function `total : float stream -> float stream`, such that
`total <a; b; c; ...>` is a running total of the input elements, i.e.,
`<a; a+.b; a+.b+.c; ...>`.

Define a function `within : float -> float stream -> float`, such
that `within eps s` is the first element of `s` for which the
absolute difference between that element and the element before it
is strictly less than `eps`.   If there is no such element, `within`
is permitted not to terminate (i.e., go into an "infinite loop").
As a precondition, the *tolerance* `eps` must be strictly positive.
For example, `within 0.1 <1.0; 2.0; 2.5; 2.75; 2.875; 2.9375; 2.96875; ...>`
is `2.9375`. 

Finally, define a function `e : float -> float -> float` such that
`e x eps` is \\(e^x\\) computed to within a tolerance of `eps`,
which must be strictly positive.  Note that there is an interesting
boundary case where `x=1.0` for the first two terms of the sum; you
could choose to drop the first term (which is always `1.0`) from the
stream before using `within`.

&square;

##### Exercise: better e [&#10029;&#10029;&#10029;&#10029;, advanced] 

Although the idea for computing \\(e^x\\) above through the summation of
an infinite series is good, the exact algorithm suggested above could be
improved. For example, computing the 20th term in the sequence leads to
a very large numerator and denominator if \\(x\\) is large.  Investigate
that behavior, comparing it to the built-in function `exp : float ->
float`. Find a better way to structure the computation to improve the
approximations you obtain.  *Hint: what if when computing term \\(k\\)
you already had term \\(k-1\\)?  Then you could just do a single 
multiplication and division.*

Also, you could improve the test that `within` uses to determine
whether two values are close.  A good one for determining whether
\\(a\\) and \\(b\\) are close might be:

\\[
\\frac{|a - b|}
{\\frac{|a| + |b|}{2} + 1}
<
\epsilon.
\\]

&square;

## Alternative Streams

##### Exercise: different stream rep [&#10029;&#10029;&#10029;] 

Consider this representation of streams:
```
type 'a stream = Cons of (unit -> 'a * 'a stream)
```

How would you code up `hd`, `tl`, `nats`, and `map` for it?
Explain how this representation is even lazier than our
original representation.

&square;
  
##### Exercise: infinite tree [&#10029;&#10029;&#10029;&#10029;] 
  
How could you represent an infinite binary tree?  What functions
would be reasonable to define on it?  What interesting infinite
trees could you construct?

&square;

## Laziness

##### Exercise: lazy hello [&#10029;] 

Define a value of type `unit Lazy.t` (which is synonymous with
`unit lazy_t`), such that forcing that value with `Lazy.force`
causes `"Hello lazy world"` to be printed.  If you force it again,
the string should not be printed.

&square;

##### Exercise: lazy and [&#10029;&#10029;] 

Define a function `(&&&) : bool Lazy.t -> bool Lazy.t -> bool`.
It should behave like a short circuit Boolean AND.  That is,
`lb1 &&& lb2` should first force `lb1`.  If it is `false`,
the function should return `false`.  Otherwise, it should
force `lb2` and return its value.

&square;

##### Exercise: lazy list [&#10029;&#10029;&#10029;] 

Implement an infinite list data abstraction using `Lazy.t`
instead of a thunk for the representation.  Your structure
should match the following signature:
```
type 'a lazylist 
val hd : 'a lazylist -> 'a
val tl : 'a lazylist -> 'a lazylist
val take : int -> 'a lazylist -> 'a list
val from : int -> int lazylist
val map : ('a -> 'b) -> 'a lazylist -> 'b lazylist
val filter : ('a -> bool) -> 'a lazylist -> 'a lazylist
```
The specifications of these functions were already provided
in lecture or in this lab.

*Hint: use the following representation type.  Don't forget
to document an AF and RI.*
```
type 'a lazylist = Cons of 'a * 'a lazylist Lazy.t
```

Use your lazy lists to compute the Fibonacci sequence.  
How does the speed compare to the stream implementation?

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
