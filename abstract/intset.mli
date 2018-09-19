(* [t] is the type of an integer set. *)
type t

(* [empty] is the empty set. *)
val empty : t

(* [size s] is the number of elements in [s]. *
 * [size empty] is [0]. *)
val size : t -> int

(* [insert x s] is a set containing all the elements of
 * [s] as well as element [x]. *)
val insert : int -> t -> t

(* [member x s] is [true] iff [x] is an element of [s]. *)
val member : int -> t -> bool

(* [remove x s] contains all the elements of [s] except
 * [x].  If [x] is not an element of [s], then
 * [remove] returns a set with the same elements as [s]. *)
val remove : int -> t -> t

(* [choose s] is [Some x], where [x] is an unspecified
 * element of [s].  If [s] is empty, then [choose s] is [None]. *)
val choose : t -> int option

(* [to_list s] is the smallest list containing the same
 * elements as [s].  The elements of the list are sorted
 * in ascending order. *)
val to_list : t -> int list