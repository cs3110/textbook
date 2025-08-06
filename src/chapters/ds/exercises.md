# Exercises

{{ solutions }}

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "hash insert")}}

Suppose we have a hash table on integer keys. The table currently has 7
empty buckets, and the hash function is simply `let hash k = k mod 7`.
Draw the hash table that results from inserting the keys 4, 8, 15, 16,
23, and 42 (with whatever values you like).

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "relax bucket RI")}}

We required that hash table buckets must not contain duplicates. What would
happen if we relaxed this RI to allow duplicates? Would the efficiency of any
operations (insert, find, or remove) change?

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "strengthen bucket RI")}}

What would happen if we strengthened the bucket RI to require each bucket to be
sorted by the key? Would the efficiency of any operations (insert, find, or
remove) change?

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "hash values")}}

Use `Hashtbl.hash : 'a -> int` to hash several values of different types. Make
sure to try at least `()`, `false`, `true`, `0`, `1`, `""`, and `[]`, as well as
several "larger" values of each type. We saw that lists quickly can create
collisions. Try creating binary trees and finding a collision.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "hashtbl usage")}}

Create a hash table `tab` with `Hashtbl.create` whose initial size is 16. Add 31
bindings to it with `Hashtbl.add`. For example, you could add the numbers 1..31
as keys and the strings "1".."31" as their values. Use `Hashtbl.find` to look
for keys that are in `tab`, as well as keys that are not.

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "hashtbl stats")}}

Use the `Hashtbl.stats` function to find out the statistics of `tab` (from an
exercise above). How many buckets are in the table? How many buckets have a
single binding in them?

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "hashtbl bindings")}}

Define a function `bindings : ('a,'b) Hashtbl.t -> ('a*'b) list`, such that
`bindings h` returns a list of all bindings in `h`. Use your function to see all
the bindings in `tab` (from an exercise above). *Hint: fold.*

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "hashtbl load factor")}}

Define a function `load_factor : ('a,'b) Hashtbl.t -> float`, such that
`load_factor h` is the load factor of `h`. What is the load factor of `tab`?
*Hint: stats.*

Add one more binding to `tab`. Do the stats or load factor change? Now add yet
another binding. Now do the stats or load factor change? *Hint: `Hashtbl`
resizes when the load factor goes strictly above 2.*

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "functorial interface")}}

Use the functorial interface (i.e., `Hashtbl.Make`) to create a hash table whose
keys are strings that are case-insensitive. Be careful to obey the specification
of `Hashtbl.HashedType.hash`:

> If two keys are equal according to `equal`, then they have identical hash
> values as computed by `hash`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "equals and hash")}}

The previous exercise quoted the specification of `Hashtbl.HashedType.hash`.
Compare that to Java's `Object.hashCode()` [specification][hashCode]. Why do
they both have this similar requirement?

[hashCode]: https://docs.oracle.com/javase/8/docs/api/java/lang/Object.html#hashCode--

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "bad hash")}}

Use the functorial interface to create a hash table with a really bad hash
function (e.g., a constant function). Use the `stats` function to see how bad
the bucket distribution becomes.

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "linear probing")}}

We briefly mentioned *probing* as an alternative to *chaining*. Probing can be
effectively used in hardware implementations of hash tables, as well as in
databases. With probing, every bucket contains exactly one binding. In case of a
collision, we search forward through the array, as described below.

**Your task:** Implement a hash table that uses linear probing. The details are
below.

**Find.** Suppose we are trying to find a binding in the table. We hash the
binding's key and look in the appropriate bucket. If there is already a
different key in that bucket, we start searching forward through the array at
the next bucket, then the next bucket, and so forth, wrapping back around to the
beginning of the array if necessary. Eventually we will either

* find an empty bucket, in which case the key we're searching for is not bound
  in the table;

* find the key before we reach an empty bucket, in which case we can return the
  value; or

* never find the key or an empty bucket, instead wrapping back around to the
  original bucket, in which case all buckets are full and the key is not bound
  in the table. This case actually should never occur, because we won't allow
  the load factor to get high enough for all buckets to be filled.

**Insert.** Insertion follows the same algorithm as finding a key, except that
whenever we first find an empty bucket, we can insert the binding there.

**Remove.** Removal is more difficult. Once the key is found, we can't just make
the bucket empty, because that would affect future searches by causing them to
stop early. Instead, we can introduce a special "deleted" value into that bucket
to indicate that the bucket does not contain a binding but the searches should
not stop at it.

**Resizing.** Since we never want the array to become completely full, we can
keep the load factor near 1/4. When the load factor exceeds 1/2, we can double
the array, bringing the load factor back to 1/4. When the load factor goes below
1/8, we can half the array, again bringing the load factor back to 1/4.
"Deleted" bindings complicate the definition of load factor:

* When determining whether to double the table size, we calculate the load
  factor as (# of bindings + # of deleted bindings) / (# of buckets). That is,
  deleted bindings contribute toward increasing the load factor.

* When determining whether the half the table size, we calculate the load factor
  as (# of bindings) / (# buckets). That is, deleted bindings do not count
  toward increasing the load factor.

When rehashing the table, deleted bindings are of course not re-inserted into
the new table.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "functorized BST")}}

Our implementation of BSTs assumed that it was okay to compare values using the
built-in comparison operators `<`, `=`, and `>`. But what if the client wanted
to use their own comparison operators? (e.g., to ignore case in strings, or to
have sets of records where only a single field of the record was used for
ordering.) Implement a `BstSet` abstraction as a functor parameterized on a
structure that enables client-provided comparison operator(s), much like the
[standard library `Set`][stdlib-set].

[stdlib-set]: https://ocaml.org/api/Set.html

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "efficient traversal")}}

Suppose you wanted to convert a tree to a list. You'd have to put the values
stored in the tree in some order. Here are three ways of doing that:

* *preorder*: each node's value appears in the list before the values of its
  left then right subtrees.

* *inorder*: the values of the left subtree appear, then the value at the node,
  then the values of the right subtree.

* *postorder*: the values of a node's left then right subtrees appear, followed
  by the value at the node.

Here is code that implements those *traversals*, along with some example
applications:

```ocaml
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

On unbalanced trees, the traversal functions above require quadratic worst-case
time (in the number of nodes), because of the `@` operator. Re-implement the
functions without `@`, and instead using `::`, such that they perform exactly
one cons per `Node` in the tree. Thus, the worst-case execution time will be
linear. You will need to add an additional accumulator argument to each
function, much like with tail recursion. (But your implementations won't
actually be tail recursive.)

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "RB draw complete")}}

Draw the perfect binary tree on the values 1, 2, ..., 15. Color the nodes in
three different ways such that (i) each way is a red-black tree (i.e., satisfies
the red-black invariants), and (ii) the three ways create trees with black
heights of 2, 3, and 4, respectively. Recall that the *black height* of a tree
is the maximum number of black nodes along any path from its root to a leaf.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "RB draw insert")}}

Draw the red-black tree that results from inserting the characters D A T A S T R
U C T U R E into an empty tree. Carry out the insertion algorithm yourself by
hand, then check your work with the implementation provided in the book.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "pow2")}}

Using this type:

```ocaml
type 'a sequence = Cons of 'a * (unit -> 'a sequence)
```

Define a value `pow2 : int sequence` whose elements are the powers of two:
`<1; 2; 4; 8; 16, ...>`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "more sequences")}}

Define the following sequences:

  - the even naturals

  - the lower-case alphabet on endless repeat:  a, b, c, ..., z, a, b, ...

  - unending pseudorandom coin flips (e.g., booleans or a variant with `Heads`
    and `Tails` constructors)

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "nth")}}

Define a function `nth : 'a sequence -> int -> 'a`, such that
`nth s n` the element at zero-based position `n` in sequence `s`.
For example, `nth pow2 0 = 1`, and `nth pow2 4 = 16`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "hd tl")}}

Explain how each of the following sequence expressions is evaluated:

- `hd nats`
- `tl nats`
- `hd (tl nats)`
- `tl (tl nats)`
- `hd (tl (tl nats))`

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "filter")}}

Define a function `filter : ('a -> bool) -> 'a sequence -> 'a sequence`, such
that `filter p s` is the sub-sequence of `s` whose elements satisfy the
predicate `p`. For example, `filter (fun n -> n mod 2 = 0) nats` would be the
sequence `<0; 2; 4; 6; 8; 10; ...>`. If there is no element of `s` that
satisfies `p`, then `filter p s` does not terminate.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "interleave")}}

Define a function `interleave : 'a sequence -> 'a sequence -> 'a sequence`, such
that `interleave <a1; a2; a3; ...> <b1; b2; b3; ...>` is the sequence
`<a1; b1; a2; b2; a3; b3; ...>`. For example, `interleave nats pow2` would be
`<0; 1; 1; 2; 2; 4; 3; 8; ...>`.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "sift")}}

The *Sieve of Eratosthenes* is a way of computing the prime numbers.

* Start with the sequence `<2; 3; 4; 5; 6; ...>`.

* Take 2 as prime.  Delete all multiples of 2, since they cannot be prime.
  That leaves `<3; 5; 7; 9; 11; ...>`.

* Take 3 as prime and delete its multiples.
  That leaves `<5; 7; 11; 13; 17; ...>`.

* Take 5 as prime, etc.

Define a function `sift : int -> int sequence -> int sequence`, such that
`sift n s` removes all multiples of `n` from `s`. *Hint: filter.*

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "primes")}}

Define a sequence `prime : int sequence`, containing all the prime numbers
starting with 2.

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "approximately e")}}

The exponential function $e^x$ can be computed by the following
infinite sum:

$$
e^x = \frac{x^0}{0!} + \frac{x^1}{1!} + \frac{x^2}{2!} + \frac{x^3}{3!} + \cdots + \frac{x^k}{k!} + \cdots
$$

Define a function `e_terms : float -> float sequence`. Element `k` of the
sequence should be term `k` from the infinite sum. For example, `e_terms 1.0` is
the sequence `<1.0; 1.0; 0.5; 0.1666...; 0.041666...; ...>`. The easy way to
compute that involves a function that computes $f(k) = \frac{x^k}{k!}$.

Define a function `total : float sequence -> float sequence`, such that
`total <a; b; c; ...>` is a running total of the input elements, i.e.,
`<a; a+.b; a+.b+.c; ...>`.

By using `e_terms` and `total` together, you will be able to compute successive
approximations of $e^x$ that correspond to finite prefixes of the infinite
summation. For example, you could compute the stream
`<1.; 2.; 2.5; 2.66666666666666652; 2.70833333333333304; ...>`. It contains
successive approximations of $e^1$, such that element $n$ of the stream is
$\sum_{k=0}^{n} \frac{1^k}{k!}$.

Define a function `within : float -> float sequence -> float`, such that
`within eps s` is the first element of `s` for which the absolute difference
between that element and the element before it is strictly less than `eps`. If
there is no such element, `within` is permitted not to terminate (i.e., go into
an "infinite loop"). As a precondition, the *tolerance* `eps` must be strictly
positive. For example,
`within 0.1 <1.0; 2.0; 2.5; 2.75; 2.875; 2.9375; 2.96875; ...>` is `2.9375`.

Finally, define a function `e : float -> float -> float` such that `e x eps` is
$e^x$ computed using a finite prefix of the infinite summation above. The
computation should halt when the absolute difference between successive
approximations is below `eps`, which must be strictly positive. For
example, `e 1. 0.01` would be `2.71666666666666634`.

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "better e")}}

Although the idea for computing $e^x$ above through the summation of an infinite
series is good, the exact algorithm suggested above could be improved. For
example, computing the 20th term in the sequence leads to a very large numerator
and denominator if $x$ is large. Investigate that behavior, comparing it to the
built-in function `exp : float -> float`. Find a better way to structure the
computation to improve the approximations you obtain. *Hint: what if when
computing term $k$ you already had term $k-1$? Then you could just do a single
multiplication and division.*

Also, you could improve the test that `within` uses to determine whether two
values are close. A good one for determining whether $a$ and $b$ are close might
be [*relative distance*][boost-rel-dist]:

$$
\left|\frac{a - b}{\mathit{min}(a, b)}\right| < \epsilon.
$$

[boost-rel-dist]: https://www.boost.org/doc/libs/1_77_0/libs/math/doc/html/math_toolkit/float_comparison.html

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "different sequence rep")}}

Consider this alternative representation of sequences:
```ocaml
type 'a sequence = Cons of (unit -> 'a * 'a sequence)
```

How would you code up `hd : 'a sequence -> 'a`,
`tl : 'a sequence -> 'a sequence`, `nats : int sequence`, and
`map : ('a -> 'b) -> 'a sequence -> 'b sequence` for it? Explain how this
representation is even lazier than our original representation.

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "lazy hello")}}

Define a value of type `unit Lazy.t` (which is synonymous with `unit lazy_t`),
such that forcing that value with `Lazy.force` causes `"Hello lazy world"` to be
printed. If you force it again, the string should not be printed.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "lazy and")}}

Define a function `(&&&) : bool Lazy.t -> bool Lazy.t -> bool`. It should behave
like a short circuit Boolean AND. That is, `lb1 &&& lb2` should first force
`lb1`. If it is `false`, the function should return `false`. Otherwise, it
should force `lb2` and return its value.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "lazy sequence")}}

Implement `map` and `filter` for the `'a lazysequence` type provided in the
section on laziness.
