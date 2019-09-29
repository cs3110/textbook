(******************************************************************
 * INSERTION SORT
 ******************************************************************)

(* [insert x lst] is a list containing all the elements of [lst] as
 * well as [x], sorted according to the built-in operator [>=]. 
 * requires: [lst] is already sorted according to [<=] *)
let rec insert x = function
  | [] -> [x]
  | h::t ->
    if h >= x
    then x::h::t
    else h::(insert x t)

(* [ins_sort lst] is [lst] sorted according to the built-in operator [<=].
 * performance: O(n^2) time, where n is the number of elements in [lst].
 *   Not tail recursive. *)
let rec ins_sort = function
  | [] -> []
  | h::t -> insert h (ins_sort t)

(******************************************************************
 * MERGE SORT
 ******************************************************************)

(* [take k lst] is the first [k] elements of [lst], or just [lst]
 * if it has fewer than [k] elements.
 * requires: [k>=0] *)
let rec take k = function
  | [] -> []
  | h::t ->
    if k=0
    then []
    else h::(take (k-1) t)

(* [drop k lst] is all but the first [k] elements of [lst], or just []
 * if it has fewer than [k] elements.
 * requires: [k>=0] *)
let rec drop k = function
  | [] -> []
  | _::t as lst ->
    if k=0
    then lst
    else drop (k-1) t

(* [merge xs ys] is a list containing all the elements of [xs] as well as [ys],
 *   in sorted order according to [<=].
 * requires: [xs] and [ys] are both already sorted according to [<=]. *)
let rec merge xs ys =
  match xs, ys with
  | [], _ -> ys
  | _, [] -> xs
  | x::xs', y::ys' ->
    if x <= y
    then x::(merge xs' ys)
    else y::(merge xs  ys')

(* [merge_sort lst] is [lst] sorted according to the built-in operator [<=].
 * performance: O(n log n) time, where n is the number of elements in [lst].
 *   Not tail recursive. *)
let rec merge_sort = function
  | [] -> []
  | [x] -> [x]
  | xs ->
    let k = (List.length xs) / 2 in
    merge
      (merge_sort (take k xs))
      (merge_sort (drop k xs))
