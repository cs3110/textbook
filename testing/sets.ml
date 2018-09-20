module type Set = sig

  (* ['a t] is the type of a set whose elements have type ['a]. *)
  type 'a t

  (* [empty] is the empty set. *)
  val empty : 'a t

  (* [size s] is the number of elements in [s]. *
   * [size empty] is [0]. *)
  val size : 'a t -> int

  (* [insert x s] is a set containing all the elements of
   * [s] as well as element [x]. *)
  val insert : 'a -> 'a t -> 'a t

  (* [member x s] is [true] if [x] is an element of [s],
   * and [false] otherwise. *)
  val member : 'a -> 'a t -> bool

  (* [remove x s] contains all the elements of [s] except
   * [x].  If [x] is not an element of [s], then
   * [remove] returns a set with the same elements as [s]. *)
  val remove : 'a -> 'a t -> 'a t

  (* [choose s] is [Some x], where [x] is an unspecified
   * element of [s].  If [s] is empty, then [choose s] is [None]. *)
  val choose : 'a t -> 'a option

  (* [to_list s] is a list containing the same
   * elements as [s].  The order of elements in the list is
   * unspecified. *)
  val to_list : 'a t -> 'a list

end

(*
 * TRY not to read any further in this file...
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 * Seriously, try HARDER...
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 * I mean it!!!  DO NOT read any farther.
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 * OK, I told you not to read this...
 *)

(**************************************************************
 * WARNING:  this module deliberately contains bugs!!!
 **************************************************************)
module ListSet : Set = struct

  (* AF:  [x1; ...; xn] represents the smallest set containing
   *      [x1], ..., and [xn].  The list may contain duplicates.
   * RI:  none  *)
  type 'a t = 'a list

  let empty = []

  let uniq s = List.sort_uniq Pervasives.compare s

  let size s = List.length (uniq s) - 1

  let insert x s = x::x::s

  let member x s = (x = (List.find (fun y -> y=x) s))

  let remove x s = List.filter (fun y -> y=x) s

  let choose s = None

  let to_list s = uniq s

end