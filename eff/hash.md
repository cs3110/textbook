# Hash Tables

As an example of analyzing the efficiency, and of the tradeoffs between
functional and imperative data structures, let's analyze the efficiency
of hash tables.  Hash tables are an implementation of the map ADT.

## Maps

A *map* binds keys to values.  This abstraction is so useful that it
goes by many other names, among them *associative array*, *dictionary*,
and *symbol table*.  We'll write maps abstractly (i.e, mathematically; 
not actually OCaml syntax) as { $$k_1 : v_1, k_2: v_2, \ldots, k_n : v_n$$ }.
Each $$k : v$$ is a *binding* of key $$k$$ to value $$v$$.  Here are a couple
of examples:

* A map binding a course number to something about it: {3110 : "Fun", 2110 : "OO"}.

* A map binding a university name to the year it was chartered: 
  {"Harvard" : 1636, "Princeton" : 1746, "Penn": 1740, "Cornell" : 1865}.

The order in which the bindings are abstractly written does not matter, so the first
example might also be written {2110 : "OO", 3110 : "Fun"}.  That's why we use set
brackets&mdash;they suggest that the bindings are a set, with no ordering implied.

Here is an interface for maps:
```
module type Map = sig
  (* [('k, 'v) t] is the type of maps that bind keys of type
   * ['k] to values of type ['v]. *)
  type ('k, 'v) t

  (* [empty] is the empty map *)
  val empty : ('k,'v) t

  (* [insert k v m] is the same map as [m], but with an additional
   * binding from [k] to [v].  If [k] was already bound in [m],
   * that binding is replaced by the binding to [v] in the new map. *)
  val insert : 'k -> 'v -> ('k,'v) t -> ('k,'v) t

  (* [find k m] is [Some v] if [k] is bound to [v] in [m],
   * and [None] if not. *)
  val find : 'k -> ('k,'v) t -> 'v option

  (* [remove k m] is the same map as [m], but without any binding of [k].
   * If [k] was not bound in [m], then the map is unchanged. *)
  val remove : 'k -> ('k,'v) t -> ('k,'v) t

  (* [of_list lst] is a map containing the same bindings as
   * association list [lst]. *)
  val of_list : ('k*'v) list -> ('k,'v) t

  (* [bindings m] is an association list containing the same
   * bindings as [m]. *)
  val bindings : ('k,'v) t -> ('k*'v) list
end
```

**Maps vs. dictionaries.**
We've seen data structures called both maps and dictionaries 
before in the course.  We do not intend for there to be
any intrinsic difference between those terms.  Both
are abstractions that bind keys to values.  

**Maps vs. sets.**
Maps and sets are very similar.  Data structures that
can implement a set can also implement a map, and vice-versa:

* Given a map data structure, we can treat the keys as elements of
  a set, and simply ignore the values which the keys are bound to.
  This wastes a little space, because we never need the values.
  
* Given a set data structure, we can store key-value pairs as the 
  elements.  Searching for elements (hence insertion and removal)
  might become more expensive, because the set abstraction is
  unlikely to support searching for keys by themselves.

## Maps as association lists

The simplest implementation of a map in OCaml is as an association list.
We've seen that implementation a number of times so far.  So here it
is, offered without any further explanation:

```
module ListMap : Map = struct
  (* AF: [[k1,v1; k2,v2; ...; kn,vn]] is the map {k1:v1, k2:v2, ..., kn:vn}.
   * If a key appears more than once in the list, then in the map it is
   * bound to the left-most occurrence in the list---e.g., [[k,v1;k,v2]]
   * is the map {k:v1}.
   * RI: none. *)
  type ('k,'v) t = ('k*'v) list
  let empty = []
  let of_list lst = lst
  let bindings m = m
  let insert k v m = (k,v)::m
  let find = List.assoc_opt
  let remove k lst = List.filter (fun (k',_) -> k <> k') lst
end
```

What is the efficiency of insert, find and remove?

* `insert` is just a cons onto the front of the list, 
   which is constant time&mdash;that is, $$O(1)$$.

* `find` potentially requires examining all elements of the list,
  which is linear time&mdash;that is, $$O(n)$$, where
  $$n$$ is the number of bindings in the map.
  
* `remove` is the same complexity as `find`, $$O(n)$$.

<!--
## Maps as balanced trees

OCaml's own `Map` module is implemented as a balanced tree (specifically,
a variant of the AVL tree data structure).  It's straightforward
to adapt the red-black trees that we previously studied to represent
maps instead of sets.  All we have to do is store both a key and a value
at each node.  The key is what we compare on and has to satisfy the
binary search tree invariants.  Here is the representation type:

```
  (* AF:  [Leaf] represents the empty map.  [Node (_, l, (k,v), r)] represents
   *   the map ${k:v} \union AF(l) \union AF(r)$, where the union of two
   *   maps (with distinct keys) means the map that contains the bindings
   *   from both. *)
  (* RI:
   * 1. for every [Node (l, (k,v), r)], all the keys in [l] are strictly
   *    less than [k], and all the keys in [r] are strictly greater
   *    than [k].
   * 2. no Red Node has a Red child.
   * 3. every path from the root to a leaf has the same number of
        Blk nodes. *)
  type ('k,'v) t = Leaf | Node of (color * ('k,'v) t * ('k * 'v) * ('k,'v) t)
```

You can find the rest of the implementation in the code accompanying
this lecture.  It does not change in any interesting way from the
implementation we already saw when we studied red-black sets.

What is the efficiency of insert, find and remove?  All three
might require traversing the tree from root to a leaf.  Since
balanced trees have a height that is $$O(\log n)$$, where
$$n$$ is the number of nodes in the tree (which is the number
of bindings in the map), all three operations are logarithmic time.
-->

## Maps as arrays

*Mutable maps* are maps whose bindings may be mutated. The interface for
a mutable map therefore differs from a non-mutable (aka persistent or
functional) map.  Insertion and removal operations now return `unit`,
because they do not produce a new map but instead mutate an existing
map.

An array can be used to represent a mutable map whose keys are
integers. A binding from a key to a value is stored by using the key as
an index into the array, and storing the binding at that index. 
For example, we could use an array to map Gates office numbers to
their occupants:
```
459 Fan
460 Gries
461 Clarkson
462 Muhlberger
463 (does not exist)
```

Since arrays have a fixed size, the implementer now needs to know the
client's desire for the *capacity* of the table (i.e., the number of
bindings that can be stored in it) whenever an empty table is created.
That leads us to the following very easy implementation:

```
module ArrayMap = struct
  (* AF: [|Some v0; Some v1; ...|]] represents {0:v0, 1:v1, ...}.
   * But if element [i] of [a] is None, then [i] is not bound in the map. *)
  type 'v t = 'v option array

  let create n = Array.make n None

  let insert k v a = a.(k) <- Some v

  let find k a = a.(k)

  let remove k a = a.(k) <- None

end
```

This kind of map is called a *direct address table*. Its efficiency is
great!  Every operation is constant time.  But that comes at the expense
of forcing keys to be integers.  Moreover, they need to be small
integers (or at least integers from a small range), otherwise the arrays
we use will need to be huge.

## Hash tables

Let's compare the efficiency of the map implementations we have so far:

<table>
<tr><th>Data structure</th><th>insert</th><th>find</th><th>remove</th></tr>
<tr><td>Arrays</td><td>O(1)</td><td>O(1)</td><td>O(1)</td></tr>
<tr><td>Association lists</td><td>O(1)</td><td>O(n)</td><td>O(n)</td></tr>
</table>

Arrays offer constant time performance, but come with severe
restrictions on keys. Trees and association lists don't place those
restrictions on keys, but they also don't offer constant time
performance. Is there a way to get the best of both worlds?  Yes! *Hash
tables* are the solution.

The key idea is that we assume the existence of a *hash function* `hash
: 'a -> int` that can convert any key to a non-negative integer.  Then
we can use that function to index into an array, as we did with direct
address tables.  Of course, we want the hash function itself to run in
constant time, otherwise the operations that use it would not be
efficient.  

One immediate problem with this idea is what to do if the output of the
hash is not within the bounds of the array.  It's easy to solve this: 
if `a` is the length of the array then computing `(hash k) mod a` will
return an index that is within bounds.

Another problem is what to do if the hash function is not
*injective*, meaning that it is not one-to-one.  Then multiple
keys could *collide* and need to be stored at the same index
in the array.  That's okay!  We deliberately allow that.
But it does mean we need a strategy for what to do when keys
collide.  

**Collisions.**
There are two well-known strategies for dealing with collisions. One is
to **store multiple bindings at each array index.** The array elements
are called *buckets*. Typically, the bucket is implemented as a linked
list. This strategy is known by many names, including *chaining*,
*closed addressing*, and *open hashing*. To check whether an element is
in the hash table, the key is first hashed to find the correct bucket to
look in. Then, the linked list is scanned to see if the desired element
is present. If the linked list is short, this scan is very quick. An
element is added or removed by hashing it to find the correct bucket.
Then, the bucket is checked to see if the element is there, and finally
the element is added or removed appropriately from the bucket in the
usual way for linked lists.

The other strategy is to **store bindings at places other than their
proper location according to the hash.** When adding a new binding to
the hash table would create a collision, the insert operation instead
finds an empty location in the array to put the binding.  This strategy
is (confusingly) known as *probing*, *open addressing*, and *closed
hashing*. A simple way to find an empty location is to search ahead
through the array indices with a fixed stride (often 1), looking for an
unused entry; this *linear probing* strategy tends to produce a lot of
clustering of elements in the table, leading to bad performance. A
better strategy is to use a second hash function to compute the probing
interval; this strategy is called *double hashing*. Regardless of how
probing is implemented, however, the time required to search for or add
an element grows rapidly as the hash table fills up. 

Chaining is usually to be preferred over probing: the performance of
chaining degrades more gracefully.  And chaining is usually faster than
probing, even when the hash table is not nearly full. 

## Implementing a hash table

Here is a representation type for a hash table that uses chaining:

```
type ('k,'v) t = {
  hash : 'k -> int;
  mutable size : int;
  mutable buckets : ('k*'v) list array
}
```

The `buckets` array has elements that are association lists, which
store the bindings.  The `hash` function is used to determine
which bucket a key goes into.  The `size` is used to keep
track of the number of bindings currently in the table, since that
would be expensive to compute by iterating over `buckets`.

Here are the AF and RI:
```
(* AF:  If [buckets] is
 *   [|[(k11,v11); (k12,v12);...];
 *     [(k21,v21); (k22,v22);...]; ...|]
 * that represents the map
 *   {k11:v11, k12:v12, ...,
 *    k21:v21, k22:v22, ...,  ...}.
 * RI: No key appears more than once in array (so, no duplicate keys in
 *   association lists).  All keys are in the right buckets:  [k] appears
 *   in [buckets] at index [b] iff [hash(k)=b].  The number of bindings
 *   in [buckets] equals [size]. 
 *)
```

What is the efficiency of insert, find, and remove for this rep type?
All require hashing the key (constant time), indexing into the
appropriate bucket (constant time), and finding out whether the key
is already in the association list (linear in the number of elements
in that list).  So the efficiency of the hash table depends on the
number of elements in each bucket.  That, in turn, is determined
by how well the hash function distributes keys across all the buckets.

A terrible hash function, such as the constant function  `fun k -> 42`,
would put all keys into same bucket.  Then every operation
would be linear in the number of bindings in the map&mdash;that is,
$$O(n)$$.  We definitely don't want that.

Instead, we want hash functions that distribute keys more or less
randomly across the buckets.  Then the expected length of every bucket
will be about the same.  If we could arrange that, on average, the
bucket length were a constant $$L$$, then insert, find, 
and remove would all in expectation run in time $$O(L)$$.

## Load factor and resizing

How could we arrange for buckets to have expected constant length? 
To answer that, let's think about the number
of bindings and buckets in the table.  Define the *load factor*
of the table to be (# bindings) / (# buckets).  So a table with 
20 bindings and 10 buckets has a load factor of 2, and a table
with 10 bindings and 20 buckets has a load factor of 0.5.  The
load factor is therefore the average number of bindings in a bucket.
So if we could keep the load factor constant, we could keep $$L$$
constant, thereby keeping the performance to (expected) constant time.

Toward that end, note that the number of bindings is not under the
control of the hash table implementer&mdash;but the number of buckets is. 
So by changing the number of buckets, the implementer can change the
load factor. A common strategy is to keep the load factor from
approximately 1/2 to 2.  Then each bucket contains only a couple
bindings, and expected constant-time performance is guaranteed.

There's no way for the implementer to know in advance, though, exactly
how many buckets will be needed.  So instead, the implementer
will have to *resize* the bucket array whenever the load factor gets
too high.  Typically the newly allocated bucket will be of a size
to restore the load factor to about 1.

Putting those two ideas together, if the load factor reaches 2, then
there are twice as many bindings as buckets in the table. So by doubling
the size of the array, we can restore the load factor to 1.  Similarly,
if the load factor reaches 1/2, then there are twice as many buckets as
bindings, and halving the size of the array will restore the load factor
to 1.

Resizing the bucket array to become larger is an essential technique
for hash tables.  Resizing it to become smaller, though, is not
essential.  As long as the load factor is bounded by a constant from
above, we can achieve expected constant bucket length.  So not all
implementations will reduce the size of the array.  Although doing
so would recover some space, it might not be worth the effort.
That's especially true if the size of the hash table is cyclic:
although sometimes it becomes smaller, eventually it becomes bigger
again.

Unfortunately, resizing would seem to ruin our expected constant-time
performance though.  Insertion of a binding might cause the load factor
to go over 2, thus causing a resize.  When the resize occurs, all the
existing bindings must be rehashed and added to the new bucket array. 
Thus, insertion has become a worst-case linear time operation!  The same
is true for removal, if we resize the array to become smaller when the
load factor is too low.

## Hash functions

Hash tables are one of the most useful data structures ever invented.
Unfortunately, they are also one of the most misused. Code built using
hash tables often falls far short of achievable performance. There are
two reasons for this:

-   Clients choose poor hash functions that do not act like random
    number generators, invalidating the simple uniform hashing
    assumption.
    
-   Hash table abstractions do not adequately specify what is required
    of the hash function, or make it difficult to provide a good hash
    function.

Clearly, a bad hash function can destroy our attempts at a constant
running time. A lot of obvious hash function choices are bad. For
example, if we're mapping names to phone numbers, then hashing each name
to its length would be a very poor function, as would a hash function
that used only the first name, or only the last name. We want our hash
function to use all of the information in the key. This is a bit of an
art. While hash tables are extremely effective when used well, all too
often poor hash functions are used that sabotage performance.

Hash tables work well when the hash function looks
random. If it is to look random, this means that any change to a key,
even a small one, should change the bucket index in an apparently random
way. If we imagine writing the bucket index as a binary number, a small
change to the key should randomly flip the bits in the bucket index.
This is called information *diffusion*. For example, a one-bit change
to the key should cause every bit in the index to flip with 1/2
probability.

**Client vs. implementer.**
As we've described it, the hash function is a single function that maps
from the key type to a bucket index. In practice, the hash function is
the composition of *two* functions, one provided by the client and one
by the implementer. This is because the implementer doesn't understand
the element type, the client doesn't know how many buckets there are,
and the implementer probably doesn't trust the client to achieve
diffusion.

The client function `hash_c` first converts the key into an integer hash
code, and the implementation function `hash_i` converts the hash code
into a bucket index. The actual hash function is the composition of
these two functions. As a hash table designer, you need to figure out
which of the client hash function and the implementation hash function
is going to provide diffusion. If clients are sufficiently savvy, it
makes sense to push the diffusion onto them, leaving the hash table
implementation as simple and fast as possible. The easy way to
accomplish this is to break the computation of the bucket index into
three steps.

1.  Serialization: Transform the key into a stream of bytes that
    contains all of the information in the original key. Two equal keys
    must result in the same byte stream. Two byte streams should be
    equal only if the keys are actually equal. How to do this depends on
    the form of the key. If the key is a string, then the stream of
    bytes would simply be the characters of the string.
    
2.  Diffusion: Map the stream of bytes into a large integer *x* in a way
    that causes every change in the stream to affect the bits of *x*
    apparently randomly. There is a tradeoff in performance versus 
    randomness (and security) here.
    
3.  Compute the hash bucket index as *x* mod *m*. This is particularly
    cheap if *m* is a power of two.

Unfortunately, hash table implementations are rarely forthcoming
about what they assume of client hash functions.  So it can be
hard to know, as a client, how to get good performance from a table.
The more information the implementation can provide to a client about
how well distributed keys are in buckets, the better.  OCaml's
`Hashtbl` includes a function to get statistics about the bucket
distribution, which can be helpful in diagnosing whether the hash
function is providing adequate diffusion.


