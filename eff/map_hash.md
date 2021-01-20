# Maps as Hash Tables

Arrays offer constant time performance, but come with severe restrictions on
keys. Association lists don't place those restrictions on keys, but they also
don't offer constant time performance. Is there a way to get the best of both
worlds? Yes (more or less)! *Hash tables* are the solution.

The key idea is that we assume the existence of a *hash function* `hash : 'a ->
int` that can convert any key to a non-negative integer. Then we can use that
function to index into an array, as we did with direct address tables. Of
course, we want the hash function itself to run in constant time, otherwise the
operations that use it would not be efficient.  

One immediate problem with this idea is what to do if the output of the hash is
not within the bounds of the array. It's easy to solve this: if `a` is the
length of the array then computing `(hash k) mod a` will return an index that is
within bounds.

Another problem is what to do if the hash function is not *injective*, meaning
that it is not one-to-one. Then multiple keys could *collide* and need to be
stored at the same index in the array. That's okay! We deliberately allow that.
But it does mean we need a strategy for what to do when keys collide.  

**Collisions.** There are two well-known strategies for dealing with collisions.
One is to store multiple bindings at each array index. The array elements are
called *buckets*. Typically, the bucket is implemented as a linked list. This
strategy is known by many names, including *chaining*, *closed addressing*, and
*open hashing*. We'll use **chaining** as the name. To check whether an element
is in the hash table, the key is first hashed to find the correct bucket to look
in. Then, the linked list is scanned to see if the desired element is present.
If the linked list is short, this scan is very quick. An element is added or
removed by hashing it to find the correct bucket. Then, the bucket is checked to
see if the element is there, and finally the element is added or removed
appropriately from the bucket in the usual way for linked lists.

The other strategy is to **store bindings at places other than their proper
location according to the hash.** When adding a new binding to the hash table
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

Chaining is usually preferred over probing in software implementations, because
it's easier to implement the linked lists in software. Hardware implementations
have often used probing, when the size of the table is fixed by circuitry. But
ssome modern software implementations are rexamining the benefits of probing.

## Hash table interface

```
module type TableMap = sig
  (** [('k, 'v) t] is the type of mutable table-based maps that
      bind keys of type ['k] to values of type ['v]. *)
  type ('k, 'v) t

  (** [insert k v m] mutates map [m] to bind [k] to [v]. If
      [k] was already bound in [m], that binding is replaced
      by the binding to [v]. *)
  val insert : 'k -> 'v -> ('k, 'v) t -> unit

  (** [find k m] is [Some v] if [m] binds [k] to [v], and
      [None] if [m] does not bind [k]. *)
  val find : 'k -> ('k, 'v) t -> 'v option

  (** [remove k m] mutates [m] to remove any binding of [k].
      If [k] was not bound in [m], the map is unchanged. *)
  val remove : 'k -> ('k, 'v) t -> unit

  (** [create hash c] creates a new table map with capacity [c]
      that will use [hash] as the function to convert keys to
      integers. 
      Requires: [hash] distributes keys uniformly over integers,
      and the output of [hash] is always non-negative, and [hash]
      runs in constant time. *)
  val create : ('k -> int) -> int -> ('k, 'v) t

  (** [bindings m] is an association list containing the same bindings as [m].
      *)
  val bindings : ('k, 'v) t -> ('k * 'v) list

  (** [of_list hash lst] creates a map with the same bindings as [lst], using
      [hash] as the hash function.
      Requires: [lst] does not contain any duplicate keys. *)
  val of_list : ('k -> int) -> ('k * 'v) list -> ('k, 'v) t  
end
```

## Hash table representation type

Here is a representation type for a hash table that uses chaining:

```
type ('k,'v) t = {
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
type? All require hashing the key (constant time), indexing into the appropriate
bucket (constant time), and finding out whether the key is already in the
association list (linear in the number of elements in that list). So the
efficiency of the hash table depends on the number of elements in each bucket.
That, in turn, is determined by how well the hash function distributes keys
across all the buckets.

A terrible hash function, such as the constant function `fun k -> 42`, would put
all keys into same bucket. Then every operation would be linear in the number
$$n$$ of bindings in the map&mdash;that is, $$O(n)$$. We definitely don't want
that.

Instead, we want hash functions that distribute keys more or less randomly
across the buckets. Then the expected length of every bucket will be about the
same. If we could arrange that, on average, the bucket length were a constant
$$L$$, then insert, find, and remove would all in expectation run in time
$$O(L)$$.

## Load factor and resizing

How could we arrange for buckets to have expected constant length? To answer
that, let's think about the number of bindings and buckets in the table. Define
the *load factor* of the table to be (# bindings) / (# buckets). So a table with
20 bindings and 10 buckets has a load factor of 2, and a table with 10 bindings
and 20 buckets has a load factor of 0.5. The load factor is therefore the
average number of bindings in a bucket. So if we could keep the load factor
constant, we could keep $$L$$ constant, thereby keeping the performance to
(expected) constant time.

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

Resizing the bucket array to become larger is an essential technique for hash
tables. Resizing it to become smaller, though, is not essential. As long as the
load factor is bounded by a constant from above, we can achieve expected
constant bucket length. So not all implementations will reduce the size of the
array. Although doing so would recover some space, it might not be worth the
effort. That's especially true if the size of the hash table is cyclic: although
sometimes it becomes smaller, eventually it becomes bigger again.

Unfortunately, resizing would seem to ruin our expected constant-time
performance though. Insertion of a binding might cause the load factor to go
over 2, thus causing a resize. When the resize occurs, all the existing bindings
must be rehashed and added to the new bucket array. Thus, insertion has become a
worst-case linear time operation! The same is true for removal, if we resize the
array to become smaller when the load factor is too low.

## Hash table implementation

```
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

An optimization of `rehash` is possible. When it calls `insert_no_resize` to
re-insert a binding, extra work is being done: there's no need for that
insertion to call `remove_assoc` or `mem_assoc`, because we are guaranteed the
binding does not contain a duplicate key. We could omit that work. If the hash
function is good, it's only a constant amount of work that we save. But if the
hash function is bad and doesn't distribute keys uniformly, that could be
an important optimization.

## Hash functions

Hash tables are one of the most useful data structures ever invented.
Unfortunately, they are also one of the most misused. Code built using hash
tables often falls far short of achievable performance. There are two reasons
for this:

- Clients choose poor hash functions that do not distribute keys randomly
  over buckets.
    
- Hash table abstractions do not adequately specify what is required of the
  hash function, or make it difficult to provide a good hash function.

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
    
3.  Compute the hash bucket index as *x* mod *m*. This is particularly cheap if
    *m* is a power of two.

Unfortunately, hash table implementations are rarely forthcoming about what they
assume of client hash functions. So it can be hard to know, as a client, how to
get good performance from a table. The more information the implementation can
provide to a client about how well distributed keys are in buckets, the better.
OCaml's `Hashtbl` includes a function to get statistics about the bucket
distribution, which can be helpful in diagnosing whether the hash function is
providing adequate diffusion.


