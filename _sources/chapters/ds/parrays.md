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

# Persistent Arrays

OCaml's built-in `array` type offers constant-time get and set operations. But it is an ephemeral data structure. That leads to the question: could we have persistent arrays, and if so, how good of performance could we get?

Here is the interface we would like to implement:

```{code-cell} ocaml
module type PersistentArray = sig
  type 'a t
  (** The type of persistent arrays whose elements have type ['a]. The
      array indexing is zero based, meaning that the first element is at
      index [0], and the last element is at index [n - 1], where [n] is 
      the length of the array. Any index less than [0] or greater
      than [n - 1] is out of bounds. *)

  val make : int -> 'a -> 'a t
  (** [make n x] is a persistent array of length [n], with each element
      initialized to [x]. Raises [Invalid_argument] if [n] is negative
      or too large for the system. *)

  val length : 'a t -> int
  (** [length a] is the number of elements in [a]. *)

  val get : 'a t -> int -> 'a
  (** [get a i] is the element at index [i] in [a]. Raises [Invalid_argument]
      if [i] is out of bounds. *)

  val set : 'a t -> int -> 'a -> 'a t
  (** [set a i x] is an array that stores [x] at index [i] and otherwise is
      the same as [a]. Raises: [Invalid_argument] if [i] is out of bounds. *)
end
```

That interface essentially the same as OCaml's `Array` module, but reduced to just four essential functions.

We'll next see three implementations of that interface. Each will achieve progressively better performance. Our final implementation is based on Conchon and Filliâtre (2007); see the end of this section for citations.

## Copy-On-Set Arrays

The easiest implementation of persistent arrays is to just make a copy of the entire array on each `set` operation. That way, old copies of the array persist—they are not changed by later `set` operations. Here is the implementation:

```{code-cell} ocaml
module CopyOnSetArray : PersistentArray = struct
  type 'a t = 'a array

  (** Efficiency: O(n). *)
  let make = Array.make

  (** Efficiency: O(1). *)
  let length = Array.length

  (** Efficiency: O(1). *)
  let get = Array.get
  
  (** Efficiency: O(n). *)
  let set a i x =
    let a' = Array.copy a in (* copy the array *)
    a'.(i) <- x; (* mutate one element *)
    a'
end
```

We pay a large price for `set` in this implementation: instead of $O(1)$ like `array`, it is $O(n)$. We'll improve on that in our next implementation.

```{note}
Before moving on, let's pause and consider one aspect of `CopyOnSetArray` that is different than any data structure we've seen before. The interface it satisfies is written in the functional style, but the implementation uses imperative features. Note that the `set` operation does not return `unit`; instead, it produces a new array out of an old array. Underneath the hood, it achieves that persistence despite using an ephemeral data structure, the `array`. A lesson we can learn is that it is possible to build persistent data structures in imperative languages using the features they provide. 
```

## Version-Tree Arrays

The expensive `set` operation in copy-on-set is doing way too much work. Even though only one array element is being changed, all of the array elements are copied. To achieve better performance, we could eliminate the copying and instead keep a little log of all the `set` operations that have occurred. Each entry in the log would need to record just one change that has been made. For example, suppose we had the following sequence of operations:

```
let a0 = make 3 0
let a1 = set a0 1 7
let a2 = set a1 2 8
let a3 = set a1 2 9
```

Our log would say:

- `a0` is `[|0; 0; 0|]`. That takes linear space to store.
- `a1` is the same as `a0` except that index `1` is `7`. That takes only constant space to store.
- `a2` is the same as `a1` except that index `2` is `8`. Again, constant space.
- `a3` is the same as `a1` except that index `2` is `9`. Again, constant space.

Note how both `a2` and `a3` share the same base array `a1`, but diverge in different ways by setting index `2` to either `8` or `9`. So the structure of this log is best represented not as a list, but as a tree:

```text
       (entry for a0)
             |
       (entry for a1)
       /            \
(entry for a2)     (entry for a3)
```

Each of the nodes in that tree tell us what different _versions_ of the array should be. That idea leads us to introduce the following tree type:

```{code-cell} ocaml
type 'a version_tree =
  | Base of 'a array
  | Diff of int * 'a * 'a version_tree
```

A `Base` node contains the base version of the array; in our example above, that would be `a0`. A `Diff` node records a difference that is created by a `set` operation. The version tree for our example above would look like this:

```text
              (Base [|0; 0; 0|])      <---- a0
                      |
                  (Diff 1 7)          <---- a1
                 /          \
a2 ----> (Diff 2 8)        (Diff 2 9) <---- a3
```

The tree itself is shown in the middle of that diagram. The pointers for `a0` through `a3` are to individual nodes of that tree and capture each of the persistent versions of the array.

```{tip}
In understanding this version tree type, there is a possibly helpful analogy to association lists. Each of the `Diff` nodes is like a cons cell in an association list: both contain a pair of a key (the array index) and a value (the element at that index). Moreover each cons cell then continues onto another cons cell until eventually reaching the the base case of nil, just like a version tree eventually reaches the base case of a `Base` node. The `Base` node is a little more interesting than the empty list though, because it contains an entire array.
```

**Set.** To implement `set a i x`, all we have to do is create a new `Diff` node:

```{code-cell} ocaml
let set a i x = Diff (i, x, a)
```

The efficiency of that is merely $O(1)$, which is a great improvement over copy-on-set arrays.

**Get.** To implement `get a i`, we just have to walk a path in the tree starting at `a` to find the first `Diff` that records a change in index `i`. If there never is such a change found, we can return the value at that index in the `Base` node:

```{code-cell} ocaml
let rec get a i =
  match a with
  | Base b -> b.(i)
  | Diff (j, v, a') ->
      if i = j then v else get a' i
```

The efficiency of that implementation is $O(k)$, where $k$ is the number of `set` operations that have been performed on the persistent array. In the worst case, all of those `set` operations were performed on a different index than we want to `get`, and they were all performed without creating any branches in the tree — for example, `make 2 0 |> set 0 1 |> set 0 2 |> ... |> set 0 k |> get 1`. Then the tree degenerates to a linked list, and `get` is forced to walk down the entire list to the `Base` node to find the original value.

Note that $k$ might be much bigger or much smaller than $n$, the size of the array. So in improving the performance of `set`, we potentially worsened the performance of `get`. In our next implementation, we'll return to this issue and improve the performance of `get`.

**Version-tree implementation.** Pulling it all together, here is an implementation of persistent arrays using version trees:

```{code-cell} ocaml
module VersionTreeArray : PersistentArray = struct
  (** AF: A rep such as [Diff (i, x, Diff (j, y, Base a))] represents the 
      array [a] except element [j] is [y] and element [i] is [x]. If there 
      are multiple diffs for an index, the outermost wins. E.g.,
      [Diff (i, x, Diff (i, y, Base a))] represents an array whose 
      element [i] is [x], not [y]. *)
  type 'a t =
    | Base of 'a array
    | Diff of int * 'a * 'a t

  (** Efficiency: O(n). *)
  let make n x = Base (Array.make n x)

  (** Efficiency: O(k), where k is the number of [set] operations that have
      been performed on the array. *)
  let rec length = function
    | Base b -> Array.length b
    | Diff (_, _, a) -> length a

  (** Efficiency: O(k). *)
  let rec get a i =
    match a with
    | Base b -> b.(i)
    | Diff (j, x, a') ->
        if i = j then x else get a' i

  (** Efficiency: O(1). *)
  let set a i x = Diff (i, x, a)
end
```

## Rebasing Version-Tree Arrays

With version trees, we achieved constant-time `set` operations for a persistent array, but `get` operations were no longer constant time — they were $O(k)$ where $k$ was the number of `set` operations that had been perfromed. Is there a way to make both operations constant time while still being persistent? The answer is: almost! 

Right now, the original version of the array as stored in the `Base` node is _primary_ and always has constant-time access with `get`. We are going to introduce a new _rebasing_ operation that can make any other version of the array become primary. Then that version will have constant-time access with `get`, even though other versions will still be $O(k)$. When a version $v$ of an array is accessed (either with `length` or `set`), we will mutate the version tree to make $v$ primary. That means changing the `Base` node to store the contents according to $v$, and adjusting `Diff` nodes as needed to compensate for that change in the base.

Since we will now be mutating trees, the representation type needs to change to add a level of indirection:

```{code-cell} ocaml
type 'a rebasing_tree = 'a node ref
and 'a node =
  | Base of 'a array
  | Diff of int * 'a * 'a rebasing_tree
```

**Make and set.** The `make` and `set` operations require just the insertion of a call to `ref` to adapt to the new representation type:

```{code-cell} ocaml
let make n x = ref (Base (Array.make n x))
let set a i x = ref (Diff (i, x, a))
```

Their efficiency is unchanged: $O(n)$ for `make`, and $O(1)$ for `set`.

**Rebase.** To rebase a tree we introduce a new recursive helper function `rebase : 'a rebasing_tree -> 'a rebasing tree` such that `rebase t` mutates tree `t` to make the version of the array represented by `t` be primary. Therefore, when `rebase` returns `t` is guaranteed to be a ref to a `Base` node. 

There are two cases to consider. First, if `t` is a ref to a `Base` node, then our work is already done. That version is already primary.

Second, if `t` is a ref to a `Diff` node, then we have work to do. That node has the form `Diff(i, x, t')` where `t'` represents another version of the array. We call `rebase` on `t'` to make it primary; after that, `t'` must be a ref to a `Base` node. That means we have the following situation, where `a` is an array:

```text
t  ---> Diff (i, x, t')
t' ---> Base a
```

To make `t` primary, we just need to swap those nodes around, as well as swap the values found at index `i`. Suppose that in the `Base` node `a.(i)` is `y`. We mutate `a.(i)` to be `x`; let's call that array `a'`. And we create a new `Diff` node with `y`:

```text
t  ---> Base a'
t' ---> Diff (i, y, t)
```

Now `t` is primary and represents the same version of the array as it did before the rebase.

Here is the code that implements rebasing:

```{code-cell} ocaml
let rec rebase a =
  match !a with
  | Base b -> b
  | Diff (i, x, a') ->
      let b = rebase a' in
      let old_x = b.(i) in
      b.(i) <- x;
      a := Base b;
      a' := Diff (i, old_x, a);
      b
```

The efficiency of `rebase` is $O(k)$, because there could be up to $k$ `Diff` nodes between `t` and its original `Base`. Immediately after calling `rebase t`, any further calls to `rebase t` will be only $O(1)$, because `t` is now primary. 

**Get and length.** Now that we have `rebase`, there is only a small modification needed to `length` and `get` to call `rebase`:

```{code-cell} ocaml
let length a = Array.length (rebase a)
let get a i = (rebase a).(i)
```

The efficiency of these is the same as `rebase`: $O(k)$ on the first call, then $O(1)$ on future calls as long as no other version of the array has been accessed in the mean time.

**Rebasing version-tree implementation:** Pulling it all together, here is an implementation of persistent arrays using rebasing version trees:

```{code-cell} ocaml
module RebasingVersionTreeArray : PersistentArray = struct
  type 'a t = 'a node ref
  (** See [VersionTreeArray]. *)

  and 'a node =
    | Base of 'a array
    | Diff of int * 'a * 'a t

  (** Efficiency: O(n). *)
  let make n x = ref (Base (Array.make n x))

  (** Efficiency: O(k), where k is the number of diffs between this version
      of the array and its base. At most, that is the number of [set] 
      operations performed on all versions of the array. If there aren't 
      any diffs, O(1). After a [rebase], remains O(1) until a different 
      version of the array is accessed. Not tail recursive. *)
  let rec rebase a =
    match !a with
    | Base b -> b
    | Diff (i, x, a') ->
        let b = rebase a' in
        let old_x = b.(i) in
        b.(i) <- x;
        a := Base b;
        a' := Diff (i, old_x, a);
        b

  (** Efficiency: Same as [rebase]. *)
  let length a = Array.length (rebase a)

  (** Efficiency: Same as [rebase]. *)
  let get a i = (rebase a).(i)

  (** Efficiency: O(1). *)
  let set a i v = ref (Diff (i, v, a))
end
```

With rebasing we now have $O(1)$ `get` and `set` operations on the primary (most recently accessed version) of the array. We pay an $O(k)$ price to change to a new primary version, but after that, access to it remains $O(1)$ until another rebase occurs.

## Citations

Our final implementation is most similar to that of Sylvain Conchon and Jean-Christophe Filliâtre (_A persistent union-find data structure_, ACM Workshop on ML, 2007). They credit Henry Baker for the idea of version trees (Shallow binding in LISP 1.5, _CACM_ 21:7, 1978) and rebasing (Shallow binding makes functional arrays fast, _SIGPLAN Not._, 26(8):145-147, 1991).
