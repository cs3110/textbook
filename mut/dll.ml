(* An ['a node] is a node of a mutable doubly-linked list.
 * It contains a value of type ['a] and optionally has 
 * pointers to previous and/or next nodes. *)
type 'a node = {
  mutable prev : 'a node option;
  mutable next : 'a node option;
  value : 'a
}

(* An ['a dlist] is a mutable doubly-linked list with elements 
 * of type ['a].  It is possible to access the first and 
 * last elements in constant time.  
 * RI: The list does not contain any cycles. *)
type 'a dlist = {
  mutable first : 'a node option;
  mutable last : 'a node option;
}

(* [create_node v] is a node containing value [v] with
 * no links to other nodes. *)
let create_node v = {prev=None; next=None; value=v}

(* [empty_dlist ()] is an empty doubly-linked list. *)
let empty_dlist () = {first=None; last=None}

(* [create_dlist n] is a doubly-linked list containing
 * exactly one node, [n]. *)
let create_dlist (n: 'a node) : 'a dlist = {first=Some n; last=Some n}

(* [insert_first d n] mutates dlist [d] by
 * inserting node [n] as the first node. *)
let insert_first (d: 'a dlist) (n: 'a node) : unit =
  failwith "unimplemented"

(* [insert_last d n] mutates dlist [d] by
 * inserting node [n] as the last node. *)
let insert_last (d: 'a dlist) (n: 'a node) : unit =
  failwith "unimplemented"

(* [insert_after d n1 n2] mutates dlist [d] by
 * inserting node [n2] after node [n1]. *)
let insert_after (d: 'a dlist) (n1: 'a node) (n2: 'a node) : unit =
  failwith "unimplemented"

(* [insert_before d n1 n2] mutates dlist [d] by
 * inserting node [n2] before node [n1]. *)
let insert_before (d: 'a dlist) (n1: 'a node) (n2: 'a node) : unit =
  failwith "unimplemented"
  
(* [remove d n] mutates dlist [d] by removing node [n].
 * requires: [n] is a node of [d]. *)
let remove (d: 'a dlist) (n: 'a node) : unit =
  failwith "unimplemented"

(* [iter_forward d f] on a dlist [d] which has 
 * elements n1; n2; ... is (f n1); (f n2); ... *)
let iter_forward (d: 'a dlist) (f: 'a -> unit) : unit =
  failwith "unimplemented"

(* [iter_backward d f] on a dlist [d] which has 
 * elements n1; n2; ... is ...; (f n2); (f n1) *)
let iter_backward (d: 'a dlist) (f: 'a -> unit) : unit =
  failwith "unimplemented"
