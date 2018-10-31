(* The type of the abstract syntax tree (AST). *)
type expr =
  | Var of string
  | Int of int
  | Bool of bool  
  | Mult of expr * expr
  | Add of expr * expr
  | Leq of expr * expr
  | Let of string*expr * expr
  | If of expr * expr * expr

type value =
  | VInt of int
  | VBool of bool
