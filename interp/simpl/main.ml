open Ast

(** [parse s] parses [s] into an AST. *)
let parse (s : string) : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

(** [typ] represents the type of an expression. *)
type typ =
  | TInt
  | TBool

(** The error message produced if a variable is unbound. *)
let unbound_var_err = "unbound variable"

(** The error message produced if binary operators and their
    operands do not have the correct types. *)
let bop_err = "operator and operand type mismatch"

(** The error message produced if the [then] and [else] branches
    of an [if] do not have the same type. *)
let if_branch_err = "branches of if must have same type"

(** The error message produced if the guard
    of an [if] does not have type [bool]. *)
let if_guard_err = "guard of if must have type bool"

(** A [Context] is a mapping from variable names to
    types, aka a symbol table, aka a typing environment. *)
module type Context = sig

  (** [t] is the type of a context. *)
  type t

  (** [empty] is the empty context. *)
  val empty : t

  (** [lookup ctx x] gets the binding of [x] in [ctx]. 
      Raises: [Failure unbound_var_err] if [x] is
      not bound in [ctx]. *) 
  val lookup : t -> string -> typ

  (** [extend ctx x ty] is [ctx] extended with a binding
      of [x] to [ty]. *)
  val extend : t -> string -> typ -> t
end

(** The [Context] module implements the [Context] signature 
    with an association list. *)
module Context : Context = struct
  type t = (string * typ) list

  let empty = []

  let lookup ctx x =
    try List.assoc x ctx
    with Not_found -> failwith unbound_var_err

  let extend ctx x ty =
    (x, ty) :: ctx
end

open Context

(** [typeof ctx e] is the type of [e] in context [ctx]. 
    Raises: [Failure] if [e] is not well typed in [ctx]. *)
let rec typeof ctx = function
  | Int _ -> TInt
  | Bool _ -> TBool
  | Var x -> lookup ctx x
  | Let (x, e1, e2) -> typeof_let ctx x e1 e2
  | Binop (bop, e1, e2) -> typeof_bop ctx bop e1 e2
  | If (e1, e2, e3) -> typeof_if ctx e1 e2 e3

(** Helper function for [typeof]. *)
and typeof_let ctx x e1 e2 = 
  let t1 = typeof ctx e1 in
  let ctx' = extend ctx x t1 in
  typeof ctx' e2

(** Helper function for [typeof]. *)
and typeof_bop ctx bop e1 e2 =
  let t1, t2 = typeof ctx e1, typeof ctx e2 in
  match bop, t1, t2 with
  | Add, TInt, TInt 
  | Mult, TInt, TInt -> TInt
  | Leq, TInt, TInt -> TBool
  | _ -> failwith bop_err

(** Helper function for [typeof]. *)
and typeof_if ctx e1 e2 e3 =
  if typeof ctx e1 = TBool 
  then begin
    let t2 = typeof ctx e2 in
    if t2 = typeof ctx e3 then t2
    else failwith if_branch_err
  end
  else failwith if_guard_err

(** [typecheck e] checks whether [e] is well typed in
    the empty context. Raises: [Failure] if not. *)
let typecheck e =
  ignore (typeof empty e)

(** [is_value e] is whether [e] is a value. *)
let is_value : expr -> bool = function
  | Int _ | Bool _ -> true
  | Var _ | Let _ | Binop _ | If _ -> false

(** [subst e v x] is [e] with [v] substituted for [x], that
    is, [e{v/x}]. *)
let rec subst e v x = match e with
  | Var y -> if x = y then v else e
  | Bool _ -> e
  | Int _ -> e
  | Binop (bop, e1, e2) -> Binop (bop, subst e1 v x, subst e2 v x)
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

(** [step] is the [-->] relation, that is, a single step of 
    evaluation. *)
let rec step = function
  | Int _ | Bool _ -> failwith "Does not step"
  | Var _ -> failwith "Unbound variable"
  | Binop (bop, e1, e2) when is_value e1 && is_value e2 -> 
    step_bop bop e1 e2
  | Binop (bop, e1, e2) when is_value e1 ->
    Binop (bop, e1, step e2)
  | Binop (bop, e1, e2) -> Binop (bop, step e1, e2)
  | Let (x, Int n, e2) -> subst e2 (Int n) x
  | Let (x, Bool b, e2) -> subst e2 (Bool b) x
  | Let (x, e1, e2) -> Let (x, step e1, e2)
  | If (Bool true, e2, _) -> e2
  | If (Bool false, _, e3) -> e3
  | If (e1, e2, e3) -> If (step e1, e2, e3)

(** Helper function for [step]. *)
and step_bop bop e1 e2 = match bop, e1, e2 with
  | Add, Int a, Int b -> Int (a + b)
  | Mult, Int a, Int b -> Int (a * b)
  | Leq, Int a, Int b -> Bool (a <= b)
  | _ -> failwith "Ill-typed binary operator application"

(** [eval e] is the [e -->* v] relation.  That is,
    keep applying [step] until a value is produced.  *)
let rec eval : expr -> expr = fun e ->
  if is_value e then e
  else eval (step e)

(** [interp s] interprets [s] by parsing, typeofing
    and evaluating it. *)
let interp (s : string) : expr =
  let e = parse s in
  typecheck e;
  eval e
