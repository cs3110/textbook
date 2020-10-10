# Maps as Arrays

*Mutable maps* are maps whose bindings may be mutated. The interface for a
mutable map therefore differs from a non-mutable (aka persistent or functional)
map. Insertion and removal operations now return `unit`, because they do not
produce a new map but instead mutate an existing map.

An array can be used to represent a mutable map whose keys are integers. A
binding from a key to a value is stored by using the key as an index into the
array, and storing the binding at that index. For example, we could use an array
to map Gates office numbers to their occupants:
```
459 Fan
460 Gries
461 Clarkson
462 Muhlberger
463 (does not exist)
```

This kind of map is called a *direct address table*. Since arrays have a fixed
size, the implementer now needs to know the client's desire for the *capacity*
of the table (i.e., the number of bindings that can be stored in it) whenever an
empty table is created. That leads to the following interface:

```
module type DirectAddressMap = sig

  (** [t] is the type of maps that bind keys of type int
      to values of type ['v]. *)
  type 'v t

  (** [insert k v m] mutates map [m] to bind [k] to [v].
      If [k] was already bound in [m], that binding is
      replaced by the binding to [v] in the new map.
      Requires: [k] is in bounds for [m]. *)
  val insert : int -> 'v -> 'v t -> unit

  (** [find k m] is [Some v] if [k] is bound to [v] in [m],
      and [None] if not.
      Requires: [k] is in bounds for [m]. *)
  val find : int -> 'v t -> 'v option

  (** [remove k m] mutates [m] to remove any binding of [k].
      If [k] was not bound in [m], then the map is unchanged.
      Requires: [k] is in bounds for [m]. *)
  val remove : int -> 'v t -> unit

  (** [create c] creates a map with capacity [c]. Keys [0]
      through [c-1] are _in bounds_ for the map. *)
  val create : int -> 'v t

  (** [of_list c lst] is a map containing the same bindings
      as association list [lst] and with capacity [c].
      Requires: [lst] does not contain any duplicate keys, 
      and every key in [lst] is in bounds for capacity [c]. *)
  val of_list : int -> (int * 'v) list -> 'v t

  (** [bindings m] is an association list containing the same
      bindings as [m]. There are no duplicate keys in the list. *)
  val bindings : 'v t -> (int * 'v) list

end
```

Here is an implementation of that interface:

```
module ArrayMap : DirectAddressMap = struct

  (** AF: [[|Some v0; Some v1; ... |]] represents
          {0 : v0, 1 : v1, ...}.  If element [i] of
          the array is instead [None], then [i] is not
          bound in the map.
      RI: None.
  *)
  type 'v t = 'v option array

  (** Efficiency: O(1) *)
  let insert k v a =
    a.(k) <- Some v

  (** Efficiency: O(1) *)
  let find k a =
    a.(k)

  (** Efficiency: O(1) *)
  let remove k a =
    a.(k) <- None

  (** Efficiency: O(c) *)
  let create c =
    Array.make c None

  (** Efficiency: O(c) *)
  let of_list c lst =
    let a = create c in (* O(c) *)
    List.iter (fun (k, v) -> insert k v a) lst;
    (* O(c) * O(1) = O(c) *)
    a

  (** Efficiency: O(c) *)
  let bindings a =
    let bs = ref [] in
    let add_binding k v = (* O(1) *)
      match v with
      | None -> ()
      | Some v -> bs := (k, v) :: !bs
    in
    Array.iteri add_binding a; (* O(c) *)
    !bs
end
```

Its efficiency is great! The insert, find, and remove operations are constant
time. But that comes at the expense of forcing keys to be integers. Moreover,
they need to be small integers (or at least integers from a small range),
otherwise the arrays we use will need to be huge.
