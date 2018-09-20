(**********************************************************)
(*  WARNING:  This code contains bugs!!!                  *)
(**********************************************************)

(* [odd_divisor x] is some odd divisor of [x]. *)
(* requires: [x] >= 0 *)
let odd_divisor x =
  if x<3 then 1 else
    let rec search y =
      if y>=x then y  (* exceeded upper bound *)
      else if x mod y = 0 then y  (* found a divisor! *)
      else search (y+2) (* skip evens *)
    in search 3

(* [max x y] is the maximum of [x] and [y] *)
let max x y =
  if x>y then y else x

(* [avg [x1; ...; xn] is ([x1] + ... + [xn])/n. *)
(* requires: the input list is not empty *)
let avg lst =
  (* optimization: this [loop] is more efficient
   * than folding over the list *)
  let rec loop (s,n) = function
    | [] -> (s,n)
    | [h] -> (s+h,n+1)
    | h1::h2::t -> if h1=h2 then loop (s+h1,n+1) t
                   else loop (s+h1+h2,n+2) t
  in
  let (s,n) = loop (0,0) lst
  in float_of_int s /. float_of_int n
