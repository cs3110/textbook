# Testing Data Abstractions

When testing a data abstraction, a simple first step is to look at the
abstraction function and representation invariant for hints about what
boundaries may exist in the space of values manipulated by a data
abstraction. The rep invariant is a particularly effective tool for
constructing useful test cases. Looking at the rep invariant of the
rational data abstraction above, we see that it requires that q is
non-zero. Therefore we should construct test cases that make q as close
to 0 as possible, i.e. 1 or -1.

We should also test how each *consumer* of the data abstraction handles
every path through each *producer* of it.  A consumer is an operation
that takes a value of the data abstraction as input, and a producer is
an operation that returns such a value.  

For example, consider this set abstraction:
```
module type Set = sig

  (** ['a t] is the type of a set whose elements have type ['a]. *)
  type 'a t

  (** [empty] is the empty set. *)
  val empty : 'a t

  (** [size s] is the number of elements in [s]. *
      [size empty] is [0]. *)
  val size : 'a t -> int

  (** [add x s] is a set containing all the elements of
      [s] as well as element [x]. *)
  val add : 'a -> 'a t -> 'a t

  (** [mem x s] is [true] iff [x] is an element of [s]. *)
  val mem : 'a -> 'a t -> bool

end
```

The `empty` and `add` functions are producers; and the `size`, `add`
and `mem` functions are consumers.  So we should test how 

* `size` handles the `empty` set;

* `size` handles a set produced by `add`, both when `add` leaves the
set unchanged as well as when it increases the set;

* `add` handles sets produced by `empty` as well as `add` itself;

* `mem` handles sets produced by `empty` as well as `add`, including
paths where `mem` is invoked on elements that have been added as
well as elements that have not.
