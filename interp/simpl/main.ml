open Ast

(** [is_value e] is whether [e] is a syntactic value *)
let is_value : expr -> bool = function
  | Int _ | Bool _ -> true
  | Add _ | Mult _ | Var _ | Let _ | Leq _ | If _ -> false

(** [subst e v x] is [e] with [v] substituted for [x], that
    is, [e{v/x}]. *)
let rec subst e v x = match e with
  | Var y -> if x = y then v else e
  | Bool _ -> e
  | Int _ -> e
  | Add (e1, e2) -> Add (subst e1 v x, subst e2 v x)
  | Mult (e1, e2) -> Mult (subst e1 v x, subst e2 v x)
  | Leq (e1, e2) -> Leq (subst e1 v x, subst e2 v x)
  | Let (y, ebind, ebody) ->
    let ebind' = subst ebind v x in
    if x = y
    then Let (y, ebind', ebody)
    else 
      (* This is not capture avoiding substitution,
         but it works because we assume that the original 
         program type checked hence had no free variables. *)
      Let (y, ebind', subst ebody v x)
  | If (e1, e2, e3) -> 
    If (subst e1 v x, subst e2 v x, subst e3 v x)

(* [step] is the [-->] relation, that is, a single step of evaluation. *)
let rec step = function
  | Int _ | Bool _ -> failwith "Does not step"
  | Var _ -> failwith "Unbound variable"
  | Add (Int n1, Int n2) -> Int (n1 + n2)
  | Add (Int n1, e2) -> Add (Int n1, step e2)
  | Add (e1, e2) -> Add (step e1, e2)
  | Mult (Int n1, Int n2) -> Int (n1 * n2)
  | Mult (Int n1, e2) -> Mult (Int n1, step e2)
  | Mult (e1, e2) -> Mult (step e1, e2)
  | Leq (Int n1, Int n2) -> Bool (n1 <= n2)
  | Leq (Int n1, e2) -> Leq(Int n1, step e2)
  | Leq (e1, e2) -> Leq(step e1, e2)
  | Let (x, Int n, e2) -> subst e2 (Int n) x
  | Let (x, Bool b, e2) -> subst e2 (Bool b) x
  | Let (x, e1, e2) -> Let (x, step e1, e2)
  | If (Bool true, e2, _) -> e2
  | If (Bool false, _, e3) -> e3
  | If (e1, e2, e3) -> If (step e1, e2, e3)

(* [eval e] is the [e -->* v] relation.  That is,
 * keep applying [step] until a value is produced.  *)
let rec eval : expr -> expr = fun e ->
  if is_value e then e
  else eval (step e)

(* Parse a string into an ast *)
let parse s =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

(* Extract a value from an ast node.
   Raises Failure if the argument is not a node containing a value. *)
let extract_value = function
  | Int i -> VInt i
  | Bool b -> VBool b
  | _ -> failwith "Not a value"

(* Interpret an expression *)
let interp e =
  e |> parse |> eval |> extract_value
