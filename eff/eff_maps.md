# Efficient Maps

A *map* binds keys to values. This abstraction is so useful that it goes by many
other names, among them *associative array*, *dictionary*, and *symbol table*.
We'll write maps abstractly (i.e, mathematically; not actually OCaml syntax) as
{ $$k_1 : v_1, k_2: v_2, \ldots, k_n : v_n$$ }. Each $$k : v$$ is a *binding* of
key $$k$$ to value $$v$$. Here are a couple of examples:

* A map binding a course number to something about it: {3110 : "Fun", 2110 :
  "OO"}.

* A map binding a university name to the year it was chartered: {"Harvard" :
  1636, "Princeton" : 1746, "Penn": 1740, "Cornell" : 1865}.

The order in which the bindings are abstractly written does not matter, so the
first example might also be written {2110 : "OO", 3110 : "Fun"}. That's why we
use set brackets&mdash;they suggest that the bindings are a set, with no
ordering implied.

Here is an interface for maps:

```
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

**Maps vs. dictionaries.** We've seen data structures called both maps and
dictionaries before in the course. We do not intend for there to be any
intrinsic difference between those terms. Both are abstractions that bind keys
to values.  

**Maps vs. sets.** Maps and sets are very similar. Data structures that can
implement a set can also implement a map, and vice-versa:

* Given a map data structure, we can treat the keys as elements of a set, and
  simply ignore the values which the keys are bound to. This wastes a little
  space, because we never need the values.
  
* Given a set data structure, we can store key-value pairs as the elements.
  Searching for elements (hence insertion and removal) might become more
  expensive, because the set abstraction is unlikely to support searching for
  keys by themselves.

## Data structures for maps

Next, we're going to examine three implementations of maps based on

- association lists,

- arrays, and

- a combination of the above known as a *hash table with chaining*.

Each implementation will need a slightly different interface, because of
contraints resulting from the underlying representation type.  In each
case we'll pay close attention to the AF, RI, and efficiency of the operations.
