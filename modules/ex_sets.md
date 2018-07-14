# Example: Sets

Here is a signature for sets:
```
module type Set = sig
  type 'a t
  
  (* [empty] is the empty set *)
  val empty : 'a t
  
  (* [mem x s] holds iff [x] is an element of [s] *)
  val mem   : 'a -> 'a t -> bool
  
  (* [add x s] is the set [s] unioned with the set containing exactly [x] *)
  val add   : 'a -> 'a t -> 'a t
  
  (* [elts s] is a list containing the elements of [s].  No guarantee
   * is made about the ordering of that list. *)
  val elts  : 'a t -> 'a list
end
```
There are many other operations a set data structure might be expected to
support, but these will suffice for now.

Here's an implementation of that interface using a list to represent the
set. This implementation ensures that the list never contains any
duplicate elements, since sets themselves do not:
```
module ListSetNoDups : Set = struct
  type 'a t   = 'a list
  let empty   = []
  let mem     = List.mem
  let add x s = if mem x s then s else x::s
  let elts s  = s
end
```
Note how `add` ensures that the representation never contains any duplicates,
so the implementation of `elts` is quite easy.  Of course, that makes the
implementation of `add` linear time, which is not ideal.  But if we want
high-performance sets, lists are not the right representation anyway;
there are much better data structures for sets, which you might
see in an upper-level algorithms course.

Here's a second implementation, which permits duplicates in the list:
```
module ListSetDups : Set = struct
  type 'a t   = 'a list
  let empty   = []
  let mem     = List.mem
  let add x s = x::s
  let elts s  = List.sort_uniq Pervasives.compare s
end
```
In that implementation, the `add` operation is now constant time, and
the `elts` operation is logarithmic time.
