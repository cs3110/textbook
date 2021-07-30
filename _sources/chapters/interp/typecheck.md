# Type Checking

Earlier, we skipped over the type checking phase. Let's come back to that now.
After lexing and parsing, the next phase of compilation is semantic analysis,
and the primary task of semantic analysis is type checking.

A *type system* is a mathematical description of how to determine whether an
expression is *ill typed* or *well typed*, and in the latter case, what the type
of the expression is. A *type checker* is a program that implements a type
system, i.e., that implements the static semantics of the language.

Commonly, a type system is formulated as a ternary relation
$\mathit{HasType}(\Gamma, e, t)$, which means that expression $e$ has type $t$
in typing context $\Gamma$. A *typing context*, aka *typing environment*, is a
map from identifiers to types. The context is used to record what variables are
in scope, and what their types are. The use of the Greek letter $\Gamma$ for
contexts is traditional.

That ternary relation $\mathit{HasType}$ is typically written with infix
notation, though, as $\Gamma \vdash e : t$. You can read the turnstile symbol
$\vdash$ as "proves" or "shows", i.e., the context $\Gamma$ shows that $e$ has
type $t$.

Let's make that notation a little friendlier by eliminating the Greek and the
math typesetting. We'll just write `ctx |- e : t` to mean that typing context
`ctx` shows that `e` has type `t`. Let's write `{}` for the empty context, and
`x:t` to mean that `x` is bound to `t`. So, `{foo:int, bar:bool}` would be the
context is which `foo` has type `int` and `bar` has type `bool`. A context may
bind an identifier at most once. We'll write `ctx[x -> t]` to mean a context
that contains all the bindings of `ctx`, and also binds `x` to `t`. If `x` was
already bound in `ctx`, then that old binding is replaced by the new binding to
`t` in `ctx[x -> t]`.

With all that machinery, we can at last define what it means to be well typed:
An expression `e` is **well typed** in context `ctx` if there exists a type `t`
for which `ctx |- e : t`. The goal of a type checker is thus to find such a type
`t`, starting from some initial context.

It's convenient to pretend that the initial context is empty. But in practice,
it's rare that a language truly uses the empty context to determine whether a
program is well typed. In OCaml, for example, there are many built-in
identifiers that are always in scope, such as everything in the `Stdlib` module.

## A Type System for SimPL

Recall the syntax of SimPL:

```text
e ::= x | i | b | e1 bop e2
    | if e1 then e2 else e3
    | let x = e1 in e2

bop ::= + | * | <=
```

Let's define a type system `ctx |- e : t` for SimPL. The only types in SimPL are
integers and booleans:

```text
t ::= int | bool
```

To define `|-`, we'll invent a set of *typing rules* that specify what the type
of an expression is based on the types of its subexpressions. In other words,
`|-` is an *inductively-defined relation*, as can be learned about in a discrete
math course. So, it has some base cases, and some inductive cases.

For the base cases, an integer constant has type `int` in any context
whatsoever, a Boolean constant likewise always has type `bool`, and a variable
has whatever type the context says it should have. Here are the typing rules
that express those ideas:

```text
ctx |- i : int
ctx |- b : bool
{x : t, ...} |- x : t
```

The remaining syntactic forms are inductive cases.

**Let.** As we already know from OCaml, we type check the body of a let
expression using a scope that is extended with a new binding.

```text
ctx |- let x = e1 in e2 : t2
  if ctx |- e1 : t1
  and ctx[x -> t1] |- e2 : t2
```

The rule says that `let x = e1 in e2` has type `t2` in context `ctx`, but only
if certain conditions hold. The first condition is that `e1` has type `t1` in
`ctx`. The second is that `e2` has type `t2` in a new context, which is `ctx`
extended to bind `x` to `t1`.

**Binary operators.** We'll need a couple different rules for binary operators.

```text
ctx |- e1 bop e2 : int
  if bop is + or *
  and ctx |- e1 : int
  and ctx |- e2 : int

ctx |- e1 <= e2 : bool
  if ctx |- e1 : int
  and ctx |- e2 : int
```

**If.** Just like OCaml, an if expression must have a Boolean guard, and its two
branches must have the same type.

```text
ctx |- if e1 then e2 else e3 : t
  if ctx |- e1 : bool
  and ctx |- e2 : t
  and ctx |- e3 : t
```

## A Type Checker for SimPL

Let's implement a type checker for SimPL, based on the type system we defined in
the previous section. You can download the completed type checker as part of the
SimPL interpreter: {{ code_link | replace("%%NAME%%", "simpl.zip") }}

We need a variant to represent types:

```ocaml
type typ =
  | TInt
  | TBool
```

The natural name for that variant would of course have been "type" not "typ",
but the former is already a keyword in OCaml. We have to prefix the constructors
with "T" to disambiguate them from the constructors of the `expr` type, which
include `Int` and `Bool`.

Let's introduce a small signature for typing contexts, based on the abstractions
we've introduced so far: the empty context, looking up a variable, and extending
a context.

```ocaml
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

```ocaml
module Context : Context = struct
  type t = (string * typ) list

  let empty = []

  let lookup ctx x =
    try List.assoc x ctx
    with Not_found -> failwith "Unbound variable"

  let extend ctx x ty =
    (x, ty) :: ctx
end
```

Now we can implement the typing relation `|-`. We'll do that by writing a
function `typeof : Context.t -> expr -> typ`, such that `typeof ctx e = t` if
and only if `ctx |- e : t`. Note that the `typeof` function produces the type as
output, so the function is actually inferring the type! That inference is easy
for SimPL; it would be considerably harder for larger languages.

Let's start with the base cases:

```ocaml
open Context

(** [typeof ctx e] is the type of [e] in context [ctx].
    Raises: [Failure] if [e] is not well typed in [ctx]. *)
let rec typeof ctx = function
  | Int _ -> TInt
  | Bool _ -> TBool
  | Var x -> lookup ctx x
  ...
```

Note how the implementation of `typeof` so far is based on the rules we
previously defined for `|-`. In particular:

* `typeof` is a recursive function, just as `|-` is an inductive relation.
* The base cases for the recursion of `typeof` are the same as the base cases
  for `|-`.

Also note how the implementation of `typeof` differs in one major way from the
definition of `|-`: error handling. The type system didn't say what to do about
errors; rather, it just defined what it meant to be well typed. The type
checker, on the other hand, needs to take action and report ill typed programs.
Our `typeof` function does that by raising exceptions. The `lookup` function, in
particular, will raise an exception if we attempt to lookup a variable that
hasn't been bound in the context.

Let's continue with the recursive cases:

```ocaml
  ...
  | Let (x, e1, e2) -> typeof_let ctx x e1 e2
  | Binop (bop, e1, e2) -> typeof_bop ctx bop e1 e2
  | If (e1, e2, e3) -> typeof_if ctx e1 e2 e3
```

We're factoring out a helper function for each branch for the sake of keeping
the pattern match readable. Each of the helpers directly encodes the ideas of
the `|-` rules, with error handling added.

```ocaml
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
  | _ -> failwith "Operator and operand type mismatch"

and typeof_if ctx e1 e2 e3 =
  if typeof ctx e1 = TBool
  then begin
    let t2 = typeof ctx e2 in
    if t2 = typeof ctx e3 then t2
    else failwith "Branches of if must have same type"
  end
  else failwith "Guard of if must have type bool"
```

Note how the recursive calls in the implementation of `typeof` occur exactly in
the same places where the definition of `|-` is inductive.

Finally, we can implement a function to check whether an expression is well
typed:

```ocaml
(** [typecheck e] checks whether [e] is well typed in
    the empty context. Raises: [Failure] if not. *)
let typecheck e =
  ignore (typeof empty e)
```

## Type Safety

What is the purpose of a type system? There might be many, but one of the
primary purposes is to ensure that certain run-time errors don't occur. Now that
we know how to formalize type systems with the `|-` relation and evaluation with
the `-->` relation, we can make that idea precise.

The goals of a language designer usually include ensuring that these two
properties, which establish a relationship between `|-` and `-->`, both hold:

* **Progress:** If an expression is well typed, then either it is already a
  value, or it can take at least one step. We can formalize that as, "for all
  `e`, if there exists a `t` such that `{} |- e : t`, then `e` is a value, or
  there exists an `e'` such that `e --> e'`."

* **Preservation:** If an expression is well typed, then if the expression
  steps, the new expression has the same type as the old expression. Formally,
  "for all `e` and `t` such that `{} |- e : t`, if there exists an `e'` such
  that `e --> e'`, then `{} |- e' : t`."

Put together, progress plus preservation imply that that evaluation of a
well-typed expression can never *get stuck*, meaning it reaches a non-value that
cannot take a step. This property is known as *type safety*.

For example, `5 + true` would get stuck using the SimPL evaluation relation,
because the primitive `+` operation cannot accept a Boolean as an operand. But
the SimPL type system won't accept that program, thus saving us from ever
reaching that situation.

Looking back at the SimPL we wrote, everywhere in the implementation of `step`
where we raised an exception was a place where evaluation would get stuck. But
the type system guarantees those exceptions will never occur.
