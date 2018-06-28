# Pattern Matching Examples

Here are many examples of how to use patterns with data:
```
(* Pokemon types *)
type ptype = 
  TNormal | TFire | TWater

(* A record to represent Pokemon *)
type mon = {name: string; hp : int; ptype: ptype}

(*********************************************
 * Several ways to get a Pokemon's hit points:
 *********************************************)

(* OK *)
let get_hp m =
  match m with
  | {name=n; hp=h; ptype=t} -> h

(* better *)
let get_hp m =
  match m with
  | {name=_; hp=h; ptype=_} -> h

(* better *)
let get_hp m =
  match t with
  | {name; hp; ptype} -> hp

(* better *)
let get_hp m =
  match m with
  | {hp} -> hp

(* best *)
let get_hp m = m.hp

(**************************************************
 * Several ways to get the 3rd component of a tuple
 **************************************************)

(* OK *)
let thrd t =
  match t with
  | (x,y,z) -> z

(* good *)
let thrd t = 
  let (x,y,z) = t in z
  
(* better *)
let thrd t =
  let (_,_,z) = t in z

(* best *)
let thrd (_,_,z) = z

(*************************************
 * How to get the components of a pair
 *************************************)
 
let fst (x,_) = x
let snd (_,y) = y

(* both fst and snd are functions already provided in the standard library *)
```

