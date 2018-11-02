# Example: A Type Checker for SimPL

Let's implement a type checker for SimPL, based on
the type system we defined in the previous section.

## Types

We need a variant to represent types:
```
type typ =
  | TInt
  | TBool
```
The natural name for that variant would of course have been
"type" not "typ", but the former is already a keyword in OCaml.
We have to prefix the constructors with "T" to disambiguate
them from the constructors of the `expr` type, which include
`Int` and `Bool`.

## Contexts

Let's introduce a small signature for typing contexts, 
based on the abstractions we've introduced so far:
the empty context, looking up a variable, and extending
a context.
```
module type Context = sig
  (** [t] is the type of a context. *)
  type t

  (** [empty] is the empty context. *)
  val empty : t

  (** [lookup ctx x] gets the binding of [x] in [ctx]. 
      Raises: [Failure] if [x] is not bound in [ctx]. *) 
  val lookup : t -> string -> typ

  (** [extend ctx x ty] is [ctx] extended with a binding
      of [x] to [ty]. *)
  val extend : t -> string -> typ -> t
end
```

It's easy to implement that signature with an association list.
```
module Context : Context = struct
  type t = (string * typ) list

  let empty = []

  let lookup ctx x =
    try List.assoc x ctx
    with Not_found -> failwith "unbound variable"

  let extend ctx x ty =
    (x, ty) :: ctx
end
```

## The Typing Relation

Now we can implement the typing relation `|-`.  We'll do that
by writing a function `typeof : Context.t -> expr -> typ`,
such that `typeof ctx e = t` if and only if `ctx |- e : t`.
Note that the `typeof` function produces the type as output,
so the function is actually inferring the type!
That inference is easy for SimPL; it would be considerably harder 
for larger languages.

Let's start with the base cases:
```
open Context

(** [typeof ctx e] is the type of [e] in context [ctx]. 
    Raises: [Failure] if [e] is not well typed in [ctx]. *)
let rec typeof ctx = function
  | Int _ -> TInt
  | Bool _ -> TBool
  | Var x -> lookup ctx x
  ...
```

Note how the implementation of `typeof` so far is based on the rules 
we previously defined for `|-`.  In particular:

* `typeof` is a recursive function, just as `|-` is an inductive relation.
* The base cases for the recursion of `typeof` are the same as
  the base cases for `|-`.
  
Also note how the implementation of `typeof` differs in one major
way from the definition of `|-`:  error handling.  The type system
didn't say what to do about errors; rather, it just defined what
it meant to be well typed.  The type checker, on the other hand,
needs to take action and report ill typed programs.  Our `typeof`
function does that by raising exceptions.  The `lookup` function,
in particular, will raise an exception if we attempt to lookup
a variable that hasn't been bound in the context.

Let's continue with the recursive cases:
```
  ...
  | Let (x, e1, e2) -> typeof_let ctx x e1 e2
  | Binop (bop, e1, e2) -> typeof_bop ctx bop e1 e2
  | If (e1, e2, e3) -> typeof_if ctx e1 e2 e3
```

We're factoring out a helper function for each branch for the sake
of keeping the pattern match readable.  Each of the helpers
directly encodes the ideas of the `|-` rules, with error handling
added.

```
and typeof_let ctx x e1 e2 = 
  let t1 = typeof ctx e1 in
  let ctx' = extend ctx x t1 in
  typeof ctx' e2

and typeof_bop ctx bop e1 e2 =
  let t1, t2 = typeof ctx e1, typeof ctx e2 in
  match bop, t1, t2 with
  | Add, TInt, TInt 
  | Mult, TInt, TInt -> TInt
  | Leq, TInt, TInt -> TBool
  | _ -> failwith "operator and operand type mismatch"

and typeof_if ctx e1 e2 e3 =
  if typeof ctx e1 = TBool 
  then begin
    let t2 = typeof ctx e2 in
    if t2 = typeof ctx e3 then t2
    else failwith "branches of if must have same type"
  end
  else failwith "guard of if must have type bool"
```
  
Note how the recursive calls in the implementation of `typeof` occur
exactly in the same places where the definition of `|-` is
inductive.

## Type Checking

Finally, we can implement a function to check whether an
expression is well typed:

```
(** [typecheck e] checks whether [e] is well typed in
    the empty context. Raises: [Failure] if not. *)
let typecheck e =
  ignore (typeof empty e)
```

You can [view the completed type checker in this file](simpl/main.ml).