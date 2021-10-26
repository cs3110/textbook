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

# Hash Tables

The *hash table* is a widely used data structure whose performance relies upon
mutability. The implementation of a hash table is quite involved compared to
other data structures we've implemented so far. We'll build it up slowly, so
that the need for and use of each piece can be appreciated.

## Maps

{{ video_embed | replace("%%VID%%", "hr8SmQK8ld8")}}

{{ video_embed | replace("%%VID%%", "I5E_BPkE_fE")}}

Hash tables implement the *map* data abstraction. A map binds *keys* to
*values*. This abstraction is so useful that it goes by many other names, among
them *associative array*, *dictionary*, and *symbol table*. We'll write maps
abstractly (i.e, mathematically; not actually OCaml syntax) as { $k_1 : v_1,
k_2: v_2, \ldots, k_n : v_n$ }. Each $k : v$ is a *binding* of key $k$ to value
$v$. Here are a couple of examples:

* A map binding a course number to something about it: {3110 : "Fun", 2110 :
  "OO"}.

* A map binding a university name to the year it was chartered: {"Harvard" :
  1636, "Princeton" : 1746, "Penn": 1740, "Cornell" : 1865}.

The order in which the bindings are abstractly written does not matter, so the
first example might also be written {2110 : "OO", 3110 : "Fun"}. That's why we
use set braces&mdash;they suggest that the bindings are a set, with no ordering
implied.

```{note}
As that notation suggests, maps and sets are very similar. Data structures that
can implement a set can also implement a map, and vice-versa:

* Given a map data structure, we can treat the keys as elements of a set, and
  simply ignore the values which the keys are bound to. This admittedly wastes a
  little space, because we never need the values.

* Given a set data structure, we can store key&ndash;value pairs as the
  elements. Searching for elements (hence insertion and removal) might become
  more expensive, because the set abstraction is unlikely to support searching
  for keys by themselves.
```

Here is an interface for maps:

```{code-cell} ocaml
:tags: ["hide-output"]
module type Map = sig

  (** [('k, 'v) t] is the type of maps that bind keys of type
      ['k] to values of type ['v]. *)
  type ('k, 'v) t

  (** [insert k v m] is the same map as [m], but with an additional
      binding from [k] to [v].  If [k] was already bound in [m],
      that binding is replaced by the binding to [v] in the new map. *)
  val insert : 'k -> 'v -> ('k, 'v) t -> ('k, 'v) t

  (** [find k m] is [Some v] if [k] is bound to [v] in [m],
      and [None] if not. *)
  val find : 'k -> ('k, 'v) t -> 'v option

  (** [remove k m] is the same map as [m], but without any binding of [k].
      If [k] was not bound in [m], then the map is unchanged. *)
  val remove : 'k -> ('k, 'v) t -> ('k, 'v) t

  (** [empty] is the empty map. *)
  val empty : ('k, 'v) t

  (** [of_list lst] is a map containing the same bindings as
      association list [lst].
      Requires: [lst] does not contain any duplicate keys. *)
  val of_list : ('k * 'v) list -> ('k, 'v) t

  (** [bindings m] is an association list containing the same
      bindings as [m]. There are no duplicates in the list. *)
  val bindings : ('k, 'v) t -> ('k * 'v) list
end
```

Next, we're going to examine three implementations of maps based on

- association lists,

- arrays, and

- a combination of the above known as a *hash table with chaining*.

Each implementation will need a slightly different interface, because of
constraints resulting from the underlying representation type. In each case
we'll pay close attention to the AF, RI, and efficiency of the operations.

## Maps as Association Lists

{{ video_embed | replace("%%VID%%", "6JUcwUgAHl8")}}

The simplest implementation of a map in OCaml is as an association list. We've
seen that representation twice so far [[1]][assoc-list] [[2]][map-module]. Here
is an implementation of `Map` using it:

[assoc-list]: ../data/assoc_list
[map-module]: ../modules/functional_data_structures

```{code-cell} ocaml
:tags: ["hide-output"]
module ListMap : Map = struct
  (** AF: [[(k1, v1); (k2, v2); ...; (kn, vn)]] is the map {k1 : v1, k2 : v2,
      ..., kn : vn}. If a key appears more than once in the list, then in the
      map it is bound to the left-most occurrence in the list. For example,
      [[(k, v1); (k, v2)]] represents {k : v1}. The empty list represents
      the empty map.
      RI: none. *)
  type ('k, 'v) t = ('k * 'v) list

  (** Efficiency: O(1). *)
  let insert k v m = (k, v) :: m

  (** Efficiency: O(n). *)
  let find = List.assoc_opt

  (** Efficiency: O(n). *)
  let remove k lst = List.filter (fun (k', _) -> k <> k') lst

  (** Efficiency: O(1). *)
  let empty = []

  (** Efficiency: O(1). *)
  let of_list lst = lst

  (** [keys m] is a list of the keys in [m], without
      any duplicates.
      Efficiency: O(n log n). *)
  let keys m = m |> List.map fst |> List.sort_uniq Stdlib.compare

  (** [binding m k] is [(k, v)], where [v] is the value that [k]
       binds in [m].
       Requires: [k] is a key in [m].
       Efficiency: O(n). *)
  let binding m k = (k, List.assoc k m)

  (** Efficiency: O(n log n) + O(n) * O(n), which is O(n^2). *)
  let bindings m = List.map (binding m) (keys m)
end
```

{{ video_embed | replace("%%VID%%", "yZkQhcIM0OA")}}

{{ video_embed | replace("%%VID%%", "5aZNbVTXmtE")}}

{{ video_embed | replace("%%VID%%", "bKFfD3oHKTE")}}

{{ video_embed | replace("%%VID%%", "ek2Obhfx064")}}

## Maps as Arrays

{{ video_embed | replace("%%VID%%", "cUEN8sFVkS4")}}

*Mutable maps* are maps whose bindings may be mutated. The interface for a
mutable map therefore differs from a immutable map. Insertion and removal
operations for a mutable map therefore return `unit`, because they do not
produce a new map but instead mutate an existing map.

An array can be used to represent a mutable map whose keys are integers. A
binding from a key to a value is stored by using the key as an index into the
array, and storing the binding at that index. For example, we could use an array
to map office numbers to their occupants:

|Office|Occupant|
|-|-|
|459|Fan|
|460|Gries|
|461|Clarkson|
|462|Muhlberger|
|463|*does not exist*|

This kind of map is called a *direct address table*. Since arrays have a fixed
size, the implementer now needs to know the client's desire for the *capacity*
of the table (i.e., the number of bindings that can be stored in it) whenever an
empty table is created. That leads to the following interface:

```{code-cell} ocaml
:tags: ["hide-output"]
module type DirectAddressMap = sig
  (** [t] is the type of maps that bind keys of type int to values of
      type ['v]. *)
  type 'v t

  (** [insert k v m] mutates map [m] to bind [k] to [v]. If [k] was
      already bound in [m], that binding is replaced by the binding to
      [v] in the new map. Requires: [k] is in bounds for [m]. *)
  val insert : int -> 'v -> 'v t -> unit

  (** [find k m] is [Some v] if [k] is bound to [v] in [m], and [None]
      if not. Requires: [k] is in bounds for [m]. *)
  val find : int -> 'v t -> 'v option

  (** [remove k m] mutates [m] to remove any binding of [k]. If [k] was
      not bound in [m], then the map is unchanged. Requires: [k] is in
      bounds for [m]. *)
  val remove : int -> 'v t -> unit

  (** [create c] creates a map with capacity [c]. Keys [0] through [c-1]
      are _in bounds_ for the map. *)
  val create : int -> 'v t

  (** [of_list c lst] is a map containing the same bindings as
      association list [lst] and with capacity [c]. Requires: [lst] does
      not contain any duplicate keys, and every key in [lst] is in
      bounds for capacity [c]. *)
  val of_list : int -> (int * 'v) list -> 'v t

  (** [bindings m] is an association list containing the same bindings
      as [m]. There are no duplicate keys in the list. *)
  val bindings : 'v t -> (int * 'v) list
end
```

{{ video_embed | replace("%%VID%%", "eDd9i-imDYo")}}

Here is an implementation of that interface:

```{code-cell} ocaml
:tags: ["hide-output"]
module ArrayMap : DirectAddressMap = struct
  (** AF: [[|Some v0; Some v1; ... |]] represents {0 : v0, 1 : v1, ...}.
      If element [i] of the array is instead [None], then [i] is not
      bound in the map.
      RI: None. *)
  type 'v t = 'v option array

  (** Efficiency: O(1) *)
  let insert k v a = a.(k) <- Some v

  (** Efficiency: O(1) *)
  let find k a = a.(k)

  (** Efficiency: O(1) *)
  let remove k a = a.(k) <- None

  (** Efficiency: O(c) *)
  let create c = Array.make c None

  (** Efficiency: O(c) *)
  let of_list c lst =
    (* O(c) *)
    let a = create c in
    (* O(c) * O(1) = O(c) *)
    List.iter (fun (k, v) -> insert k v a) lst;
    a

  (** Efficiency: O(c) *)
  let bindings a =
    let bs = ref [] in
    (* O(1) *)
    let add_binding k v =
      match v with None -> () | Some v -> bs := (k, v) :: !bs
    in
    (* O(c) *)
    Array.iteri add_binding a;
    !bs
end
```

Its efficiency is great! The `insert`, `find`, and `remove` operations are
constant time. But that comes at the expense of forcing keys to be integers.
Moreover, they need to be small integers (or at least integers from a small
range), otherwise the arrays we use will need to be huge.

{{ video_embed | replace("%%VID%%", "mrpti_Guevs")}}

## Maps as Hash Tables

{{ video_embed | replace("%%VID%%", "NyZ07rpq7tk")}}

Arrays offer constant time performance, but come with severe restrictions on
keys. Association lists don't place those restrictions on keys, but they also
don't offer constant time performance. Is there a way to get the best of both
worlds? Yes (more or less)! *Hash tables* are the solution.

The key idea is that we assume the existence of a *hash function* `hash : 'a ->
int` that can convert any key to a non-negative integer. Then we can use that
function to index into an array, as we did with direct address tables. Of
course, we want the hash function itself to run in constant time, otherwise the
operations that use it would not be efficient.

{{ video_embed | replace("%%VID%%", "8IJpySZ5iLM")}}

That leads to the following interface, in which the client of the hash table has
to pass in a hash function when a table is created:

```{code-cell} ocaml
module type TableMap = sig
  (** [('k, 'v) t] is the type of mutable table-based maps that bind
      keys of type ['k] to values of type ['v]. *)
  type ('k, 'v) t

  (** [insert k v m] mutates map [m] to bind [k] to [v]. If [k] was
      already bound in [m], that binding is replaced by the binding to
      [v]. *)
  val insert : 'k -> 'v -> ('k, 'v) t -> unit

  (** [find k m] is [Some v] if [m] binds [k] to [v], and [None] if [m]
      does not bind [k]. *)
  val find : 'k -> ('k, 'v) t -> 'v option

  (** [remove k m] mutates [m] to remove any binding of [k]. If [k] was
      not bound in [m], the map is unchanged. *)
  val remove : 'k -> ('k, 'v) t -> unit

  (** [create hash c] creates a new table map with capacity [c] that
      will use [hash] as the function to convert keys to integers.
      Requires: The output of [hash] is always non-negative, and [hash]
      runs in constant time. *)
  val create : ('k -> int) -> int -> ('k, 'v) t

  (** [bindings m] is an association list containing the same bindings
      as [m]. *)
  val bindings : ('k, 'v) t -> ('k * 'v) list

  (** [of_list hash lst] creates a map with the same bindings as [lst],
      using [hash] as the hash function. Requires: [lst] does not
      contain any duplicate keys. *)
  val of_list : ('k -> int) -> ('k * 'v) list -> ('k, 'v) t
end
```

One immediate problem with this idea is what to do if the output of the hash is
not within the bounds of the array. It's easy to solve this: if `a` is the
length of the array then computing `(hash k) mod a` will return an index that is
within bounds.

Another problem is what to do if the hash function is not *injective*, meaning
that it is not one-to-one. Then multiple keys could *collide* and need to be
stored at the same index in the array. That's okay! We deliberately allow that.
But it does mean we need a strategy for what to do when keys collide.

There are two well-known strategies for dealing with collisions. One is to store
multiple bindings at each array index. The array elements are called *buckets*.
Typically, the bucket is implemented as a linked list. This strategy is known by
many names, including *chaining*, *closed addressing*, and *open hashing*. We'll
use **chaining** as the name. To check whether an element is in the hash table,
the key is first hashed to find the correct bucket to look in. Then, the linked
list is scanned to see if the desired element is present. If the linked list is
short, this scan is very quick. An element is added or removed by hashing it to
find the correct bucket. Then, the bucket is checked to see if the element is
there, and finally the element is added or removed appropriately from the bucket
in the usual way for linked lists.

The other strategy is to store bindings at places other than their proper
location according to the hash. When adding a new binding to the hash table
would create a collision, the insert operation instead finds an empty location
in the array to put the binding. This strategy is (confusingly) known as
*probing*, *open addressing*, and *closed hashing*. We'll use **probing** as the
name. A simple way to find an empty location is to search ahead through the
array indices with a fixed stride (often 1), looking for an unused entry; this
*linear probing* strategy tends to produce a lot of clustering of elements in
the table, leading to bad performance. A better strategy is to use a second hash
function to compute the probing interval; this strategy is called *double
hashing*. Regardless of how probing is implemented, however, the time required
to search for or add an element grows rapidly as the hash table fills up.

Chaining has often been preferred over probing in software implementations,
because it's easy to implement the linked lists in software. Hardware
implementations have often used probing, when the size of the table is fixed by
circuitry. But some modern software implementations are re-examining the
performance benefits of probing.

### Chaining Representation

{{ video_embed | replace("%%VID%%", "LOWAC3WOl6Q")}}

Here is a representation type for a hash table that uses chaining:

```ocaml
type ('k, 'v) t = {
  hash : 'k -> int;
  mutable size : int;
  mutable buckets : ('k * 'v) list array
}
```

The `buckets` array has elements that are association lists, which store the
bindings. The `hash` function is used to determine which bucket a key goes into.
The `size` is used to keep track of the number of bindings currently in the
table, since that would be expensive to compute by iterating over `buckets`.

Here are the AF and RI:
```
  (** AF:  If [buckets] is
        [| [(k11,v11); (k12,v12); ...];
           [(k21,v21); (k22,v22); ...];
           ... |]
      that represents the map
        {k11:v11, k12:v12, ...,
         k21:v21, k22:v22, ...,  ...}.
      RI: No key appears more than once in array (so, no
        duplicate keys in association lists).  All keys are
        in the right buckets: if [k] is in [buckets] at index
        [b] then [hash(k) = b]. The output of [hash] must always
        be non-negative. [hash] must run in constant time.*)
```

What would the efficiency of `insert`, `find`, and `remove` be for this rep
type? All require

- hashing the key (constant time),
- indexing into the appropriate bucket (constant time), and
- finding out whether the key is already in the association list (linear in the
  number of elements in that list).

So the efficiency of the hash table depends on the number of elements in each
bucket. That, in turn, is determined by how well the hash function distributes
keys across all the buckets.

A terrible hash function, such as the constant function `fun k -> 42`, would put
all keys into same bucket. Then every operation would be linear in the number
$n$ of bindings in the map&mdash;that is, $O(n)$. We definitely don't want
that.

Instead, we want hash functions that distribute keys more or less randomly
across the buckets. Then the expected length of every bucket will be about the
same. If we could arrange that, on average, the bucket length were a constant
$L$, then `insert`, `find`, and `remove` would all in expectation run in time
$O(L)$.

### Resizing

{{ video_embed | replace("%%VID%%", "mn2pDfusFyY")}}

How could we arrange for buckets to have expected constant length? To answer
that, let's think about the number of bindings and buckets in the table. Define
the *load factor* of the table to be

$$
\frac{\mbox{number of bindings}}{\mbox{number of buckets}}
$$

So a table with 20 bindings and 10 buckets has a load factor of 2, and a table
with 10 bindings and 20 buckets has a load factor of 0.5. The load factor is
therefore the average number of bindings in a bucket. So if we could keep the
load factor constant, we could keep $L$ constant, thereby keeping the
performance to (expected) constant time.

Toward that end, note that the number of bindings is not under the control of
the hash table implementer&mdash;but the number of buckets is. So by changing
the number of buckets, the implementer can change the load factor. A common
strategy is to keep the load factor from approximately 1/2 to 2. Then each
bucket contains only a couple bindings, and expected constant-time performance
is guaranteed.

There's no way for the implementer to know in advance, though, exactly how many
buckets will be needed. So instead, the implementer will have to *resize* the
bucket array whenever the load factor gets too high. Typically the newly
allocated bucket will be of a size to restore the load factor to about 1.

Putting those two ideas together, if the load factor reaches 2, then there are
twice as many bindings as buckets in the table. So by doubling the size of the
array, we can restore the load factor to 1. Similarly, if the load factor
reaches 1/2, then there are twice as many buckets as bindings, and halving the
size of the array will restore the load factor to 1.

{{ video_embed | replace("%%VID%%", "BzusuFH1tNw")}}

Resizing the bucket array to become larger is an essential technique for hash
tables. Resizing it to become smaller, though, is not essential. As long as the
load factor is bounded by a constant from above, we can achieve expected
constant bucket length. So not all implementations will reduce the size of the
array. Although doing so would recover some space, it might not be worth the
effort. That's especially true if the size of the hash table cycles over time:
although sometimes it becomes smaller, eventually it becomes bigger again.

Unfortunately, resizing would seem to ruin our expected constant-time
performance though. Insertion of a binding might cause the load factor to go
over 2, thus causing a resize. When the resize occurs, all the existing bindings
must be rehashed and added to the new bucket array. Thus, insertion has become a
worst-case linear time operation! The same is true for removal, if we resize the
array to become smaller when the load factor is too low.

### Implementation

The implementation of a hash table, below, puts together all the pieces we
discussed above.

```{code-cell} ocaml
:tags: ["hide-output"]
module HashMap : TableMap = struct

  (** AF and RI: above *)
  type ('k, 'v) t = {
    hash : 'k -> int;
    mutable size : int;
    mutable buckets : ('k * 'v) list array
  }

  (** [capacity tab] is the number of buckets in [tab].
      Efficiency: O(1) *)
  let capacity {buckets} =
    Array.length buckets

  (** [load_factor tab] is the load factor of [tab], i.e., the number of
      bindings divided by the number of buckets. *)
  let load_factor tab =
    float_of_int tab.size /. float_of_int (capacity tab)

  (** Efficiency: O(n) *)
  let create hash n =
    {hash; size = 0; buckets = Array.make n []}

  (** [index k tab] is the index at which key [k] should be stored in the
      buckets of [tab].
      Efficiency: O(1) *)
  let index k tab =
    (tab.hash k) mod (capacity tab)

  (** [insert_no_resize k v tab] inserts a binding from [k] to [v] in [tab]
      and does not resize the table, regardless of what happens to the
      load factor.
      Efficiency: expected O(L) *)
  let insert_no_resize k v tab =
    let b = index k tab in (* O(1) *)
    let old_bucket = tab.buckets.(b) in
    tab.buckets.(b) <- (k,v) :: List.remove_assoc k old_bucket; (* O(L) *)
    if not (List.mem_assoc k old_bucket) then
      tab.size <- tab.size + 1;
    ()

  (** [rehash tab new_capacity] replaces the buckets array of [tab] with a new
      array of size [new_capacity], and re-inserts all the bindings of [tab]
      into the new array.  The keys are re-hashed, so the bindings will
      likely land in different buckets.
      Efficiency: O(n), where n is the number of bindings. *)
  let rehash tab new_capacity =
    (* insert (k, v) into tab *)
    let rehash_binding (k, v) =
      insert_no_resize k v tab
    in
    (* insert all bindings of bucket into tab *)
    let rehash_bucket bucket =
      List.iter rehash_binding bucket
    in
    let old_buckets = tab.buckets in
    tab.buckets <- Array.make new_capacity []; (* O(n) *)
    tab.size <- 0;
    (* [rehash_binding] is called by [rehash_bucket] once for every binding *)
    Array.iter rehash_bucket old_buckets (* expected O(n) *)

  (* [resize_if_needed tab] resizes and rehashes [tab] if the load factor
     is too big or too small.  Load factors are allowed to range from
     1/2 to 2. *)
  let resize_if_needed tab =
    let lf = load_factor tab in
    if lf > 2.0 then
      rehash tab (capacity tab * 2)
    else if lf < 0.5 then
      rehash tab (capacity tab / 2)
    else ()

  (** Efficiency: O(n) *)
  let insert k v tab =
    insert_no_resize k v tab; (* O(L) *)
    resize_if_needed tab (* O(n) *)

  (** Efficiency: expected O(L) *)
  let find k tab =
    List.assoc_opt k tab.buckets.(index k tab)

  (** [remove_no_resize k tab] removes [k] from [tab] and does not trigger
      a resize, regardless of what happens to the load factor.
      Efficiency: expected O(L) *)
  let remove_no_resize k tab =
    let b = index k tab in
    let old_bucket = tab.buckets.(b) in
    tab.buckets.(b) <- List.remove_assoc k tab.buckets.(b);
    if List.mem_assoc k old_bucket then
      tab.size <- tab.size - 1;
    ()

  (** Efficiency: O(n) *)
  let remove k tab =
    remove_no_resize k tab; (* O(L) *)
    resize_if_needed tab (* O(n) *)

  (** Efficiency: O(n) *)
  let bindings tab =
    Array.fold_left
      (fun acc bucket ->
         List.fold_left
           (* 1 cons for every binding, which is O(n) *)
           (fun acc (k,v) -> (k,v) :: acc)
           acc bucket)
      [] tab.buckets

  (** Efficiency: O(n^2) *)
  let of_list hash lst =
    let m = create hash (List.length lst) in  (* O(n) *)
    List.iter (fun (k, v) -> insert k v m) lst; (* n * O(n) is O(n^2) *)
    m
end
```

{{ video_embed | replace("%%VID%%", "FN-YyNaSkz8")}}

{{ video_embed | replace("%%VID%%", "Du4SxDJzS6g")}}

{{ video_embed | replace("%%VID%%", "GKtcy5AfPgc")}}

{{ video_embed | replace("%%VID%%", "YQUHqv-RXI8")}}

An optimization of `rehash` is possible. When it calls `insert_no_resize` to
re-insert a binding, extra work is being done: there's no need for that
insertion to call `remove_assoc` or `mem_assoc`, because we are guaranteed the
binding does not contain a duplicate key. We could omit that work. If the hash
function is good, it's only a constant amount of work that we save. But if the
hash function is bad and doesn't distribute keys uniformly, that could be an
important optimization.

## Hash Functions

{{ video_embed | replace("%%VID%%", "tGktnJWmCy0")}}

Hash tables are one of the most useful data structures ever invented.
Unfortunately, they are also one of the most misused. Code built using hash
tables often falls far short of achievable performance. There are two reasons
for this:

- Clients choose poor hash functions that do not distribute keys randomly over
  buckets.

- Hash table abstractions do not adequately specify what is required of the hash
  function, or make it difficult to provide a good hash function.

Clearly, a bad hash function can destroy our attempts at a constant running
time. A lot of obvious hash function choices are bad. For example, if we're
mapping names to phone numbers, then hashing each name to its length would be a
very poor function, as would a hash function that used only the first name, or
only the last name. We want our hash function to use all of the information in
the key. This is a bit of an art. While hash tables are extremely effective when
used well, all too often poor hash functions are used that sabotage performance.

Hash tables work well when the hash function looks random. If it is to look
random, this means that any change to a key, even a small one, should change the
bucket index in an apparently random way. If we imagine writing the bucket index
as a binary number, a small change to the key should randomly flip the bits in
the bucket index. This is called information *diffusion*. For example, a one-bit
change to the key should cause every bit in the index to flip with 1/2
probability.

**Client vs. implementer.** As we've described it, the hash function is a single
function that maps from the key type to a bucket index. In practice, the hash
function is the composition of *two* functions, one provided by the client and
one by the implementer. This is because the implementer doesn't understand the
element type, the client doesn't know how many buckets there are, and the
implementer probably doesn't trust the client to achieve diffusion.

The client function `hash_c` first converts the key into an integer hash code,
and the implementation function `hash_i` converts the hash code into a bucket
index. The actual hash function is the composition of these two functions. As a
hash table designer, you need to figure out which of the client hash function
and the implementation hash function is going to provide diffusion. If clients
are sufficiently savvy, it makes sense to push the diffusion onto them, leaving
the hash table implementation as simple and fast as possible. The easy way to
accomplish this is to break the computation of the bucket index into three
steps.

1.  Serialization: Transform the key into a stream of bytes that contains all of
    the information in the original key. Two equal keys must result in the same
    byte stream. Two byte streams should be equal only if the keys are actually
    equal. How to do this depends on the form of the key. If the key is a
    string, then the stream of bytes would simply be the characters of the
    string.

2.  Diffusion: Map the stream of bytes into a large integer *x* in a way that
    causes every change in the stream to affect the bits of *x* apparently
    randomly. There is a tradeoff in performance versus randomness (and
    security) here.

3.  Compression: Reduce that large integer to be within the range of the
    buckets. For example, compute the hash bucket index as *x* mod *m*. This
    is particularly cheap if *m* is a power of two.

Unfortunately, hash table implementations are rarely forthcoming about what they
assume of client hash functions. So it can be hard to know, as a client, how to
get good performance from a table. The more information the implementation can
provide to a client about how well distributed keys are in buckets, the better.

## Standard Library `Hashtbl`

Although it's great to know how to implement a hash table, and to see how
mutability is used in doing so, it's also great *not* to have to implement a
data structure yourself in your own projects. Fortunately the OCaml standard
library does provide a module `Hashtbl` [sic] that implements hash tables. You
can think of this module as the imperative equivalent of the functional `Map`
module.

**Hash function.** The function `Hashtbl.hash : 'a -> int` takes responsibility
for serialization and diffusion. It is capable of hashing any type of value.
That includes not just integers but strings, lists, trees, and so forth. So how
does it run in constant time, if the length of a tree or size of a tree can be
arbitrarily large? It looks only at a predetermined number of *meaningful nodes*
of the structure it is hashing. By default, that number is 10. A meaningful node
is an integer, floating-point number, string, character, booleans or constant
constructor.  You can see that as we hash these lists:

```{code-cell} ocaml
Hashtbl.hash [1; 2; 3; 4; 5; 6; 7; 8; 9];;
Hashtbl.hash [1; 2; 3; 4; 5; 6; 7; 8; 9; 10];;
Hashtbl.hash [1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11];;
Hashtbl.hash [1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12];;
```

The hash values stop changing after the list goes beyond 10 elements. That has
implications for how we use this built-in hash function: it will not necessarily
provide good diffusion for large data structures, which means performance could
degrade as collisions become common. To support clients who want to hash such
structures, `Hashtble` provides another function `hash_param` which can be
configured to examine more nodes.

**Hash table.** Here's an abstract of the hash table interface:

```ocaml
module type Hashtbl = struct
  type ('a, 'b) t
  val create : int -> ('a, 'b) t
  val add : ('a, 'b) t -> 'a -> 'b -> unit
  val find : ('a, 'b) t -> 'a -> 'b
  val remove : ('a, 'b) t -> 'a -> unit
  ...
end
```

The representation type `('a, 'b) Hashtbl.t` maps keys of type `'a` to values of
type `'b`. The `create` function initializes a hash table to have a given
capacity, as our implementation above did. But rather than requiring the client
to provide a hash function, the module uses `Hashtbl.hash`.

Resizing occurs when the load factor exceeds 2. Let's see that happen. First,
we'll create a table and fill it up:

```{code-cell} ocaml
open Hashtbl;;
let t = create 16;;
for i = 1 to 16 do
  add t i (string_of_int i)
done;;
```

We can query the hash table to find out how the bindings are distributed
over buckets with `Hashtbl.stats`:

```{code-cell} ocaml
stats t
```

The number of bindings and number of buckets are equal, so the load factor is 1.
The bucket histogram is an array `a` in which `a.(i)` is the number of buckets whose size is `i`.

Let's pump up the load factor to 2:

```{code-cell} ocaml
for i = 17 to 32 do
  add t i (string_of_int i)
done;;
stats t;;
```

Now adding one more binding will trigger a resize, which doubles the number of
buckets:

```{code-cell} ocaml
add t 33 "33";;
stats t;;
```

But `Hashtbl` does not implement resize on removal:

```{code-cell} ocaml
for i = 1 to 33 do
  remove t i
done;;
stats t;;
```

The number of buckets is still 32, even though all bindings have been removed.

```{note}
Java's `HashMap` has a default constructor `HashMap()` that creates an empty
hash table with a capacity of 16 that resizes when the load factor exceeds 0.75
rather than 2. So Java hash tables would tend to have a shorter bucket length
than OCaml hash tables, but also would tend to take more space to store because
of empty buckets.
```

**Client-provided hash functions.** What if a client of `Hashtbl` found that the
default hash function was leading to collisions, hence poor performance? Then
it would make sense to change to a different hash function.  To support that,
`Hashtbl` provides a functorial interface similar to `Map`.  The functor
is `Hashtbl.Make`, and it requires an input of the following module type:

```ocaml
module type HashedType = sig
  type t
  val equal : t -> t -> bool
  val hash : t -> int
end
```

Type `t` is the key type for the table, and the two functions `equal` and `hash`
say how to compare keys for equality and how to hash them. If two keys are equal
according to `equal`, they must have the same hash value according to `hash`. If
that requirement were violated, the hash table would no longer operate
correctly. For example, suppose that `equal k1 k2` holds but
`hash k1 <> hash k2`. Then `k1` and `k2` would be stored in different buckets.
So if a client added a binding of `k1` to `v`, then looked up `k2`, they would
not get `v` back.

```{note}
That final requirement might sound familiar from Java. There, if you override
`Object.equals()` and `Object.hashCode()` you must ensure the same
correspondence.
```