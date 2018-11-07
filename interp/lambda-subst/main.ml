open Ast

(** [parse s] parses [s] into an AST. *)
let parse (s : string) : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

(** [is_value e] is whether [e] is a value. *)
let is_value : expr -> bool = function
  | Fun _ -> true
  | Var _ | App _ -> false

module VarSet = Set.Make(String)
let singleton = VarSet.singleton
let union = VarSet.union
let diff = VarSet.diff
let mem = VarSet.mem

(** [fv e] is a set-like list of the free variables of [e]. *)
let rec fv : expr -> VarSet.t = function
  | Var x -> singleton x
  | App (e1, e2) -> union (fv e1) (fv e2)
  | Fun (x, e) -> diff (fv e) (singleton x)

(** [gensym ()] is a fresh variable name. *)
let gensym =
  let counter = ref 0 in
  fun () ->
    incr counter; "$x" ^ string_of_int !counter

(** [replace e y x] is [e] with the name [x] replaced
    by the name [y] anywhere it occurs. *)
let rec replace e y x = match e with
  | Var z -> if z = x then Var y else e
  | App (e1, e2) -> App (replace e1 y x, replace e2 y x)
  | Fun (z, e') -> Fun ((if z = x then y else z), replace e' y x)

(** [subst e v x] is [e] with [v] substituted for [x], that
    is, [e{v/x}]. *)
let rec subst e v x = match e with
  | Var y -> if x = y then v else e
  | App (e1, e2) -> App (subst e1 v x, subst e2 v x)
  | Fun (y, e') -> 
    if x = y then e
    else if not (mem y (fv v)) then Fun (y, subst e' v x)
    else 
      let fresh = gensym () in
      let new_body = replace e' y fresh in
      Fun (fresh, subst new_body v x)

let unbound_var_err = "Unbound variable"
let apply_non_fn_err = "Cannot apply non-function"

type eval_strategy = CBV | CBN
let strategy = CBV

(** [eval e] is the [e ==> v] relation. *)
let rec eval (e : expr) : expr = match e with
  | Var _ -> failwith unbound_var_err
  | App (e1, e2) -> eval_app e1 e2
  | Fun _ -> e

(** [eval_app e1 e2] is the [e] such that [e1 e2 ==> e]. *)
and eval_app e1 e2 = match eval e1 with
  | Fun (x, e) -> 
    let e2' = 
      match strategy with
      | CBV -> eval e2
      | CBN -> e2
    in subst e e2' x |> eval
  | _ -> failwith apply_non_fn_err

(** [interp s] interprets [s] by parsing
    and evaluating it with the big-step model. *)
let interp (s : string) : expr =
  s |> parse |> eval
