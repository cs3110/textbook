# Type Checking

{{ video_embed | replace("%%VID%%", "_whuqDIWiO0")}}

Earlier, we skipped over the type checking phase. Let's come back to that now.
After lexing and parsing, the next phase of compilation is semantic analysis,
and the primary task of semantic analysis is type checking.

A *type system* is a mathematical description of how to determine whether an
expression is *ill typed* or *well typed*, and in the latter case, what the type
of the expression is. A *type checker* is a program that implements a type
system, i.e., that implements the static semantics of the language.

Commonly, a type system is formulated as a ternary relation
$\mathit{HasType}(\Gamma, e, t)$, which means that expression $e$ has type $t$
in static environment $\Gamma$. A *static environment*, aka *typing context*, is
a map from identifiers to types. The static environment is used to record what
variables are in scope, and what their types are. The use of the Greek letter
$\Gamma$ for static environments is traditional.

That ternary relation $\mathit{HasType}$ is typically written with infix
notation, though, as $\Gamma \vdash e : t$. You can read the turnstile symbol
$\vdash$ as "proves" or "shows", i.e., the static environment $\Gamma$ shows
that $e$ has type $t$.

Let's make that notation a little friendlier by eliminating the Greek and the
math typesetting. We'll just write `env |- e : t` to mean that static
environment `env` shows that `e` has type `t`. We previously used `env` to mean
a dynamic environment in the big-step relation `==>`. Since it's always possible
to see whether we're using the `==>` or `|-` relation, the meaning of `env` as
either a dynamic or static environment is always discernible.

Let's write `{}` for the empty static environment, and `x:t` to mean that `x` is
bound to `t`. So, `{foo:int, bar:bool}` would be the static environment is which
`foo` has type `int` and `bar` has type `bool`. A static environment may bind an
identifier at most once. We'll write `env[x -> t]` to mean a static environment
that contains all the bindings of `env`, and also binds `x` to `t`. If `x` was
already bound in `env`, then that old binding is replaced by the new binding to
`t` in `env[x -> t]`. As with dynamic environments, if we wanted a more
mathematical notation we would write $\mapsto$ instead of `->` in
`env[x -> v]`, but we're aiming for notation that is easily typed on a standard
keyboard.

With all that machinery, we can at last define what it means to be well typed:
An expression `e` is **well typed** in static environment `env` if there exists
a type `t` for which `env |- e : t`. The goal of a type checker is thus to find
such a type `t`, starting from some initial static environment.

It's convenient to pretend that the initial static environment is empty. But in
practice, it's rare that a language truly uses the empty static environment to
determine whether a program is well typed. In OCaml, for example, there are many
built-in identifiers that are always in scope, such as everything in the
`Stdlib` module.

## A Type System for SimPL

{{ video_embed | replace("%%VID%%", "9Lxz8qS3uQ8")}}

Recall the syntax of SimPL:

```text
e ::= x | i | b | e1 bop e2
    | if e1 then e2 else e3
    | let x = e1 in e2

bop ::= + | * | <=
```

Let's define a type system `env |- e : t` for SimPL. The only types in SimPL are
integers and booleans:

```text
t ::= int | bool
```

To define `|-`, we'll invent a set of *typing rules* that specify what the type
of an expression is based on the types of its subexpressions. In other words,
`|-` is an *inductively-defined relation*, as can be learned about in a discrete
math course. So, it has some base cases, and some inductive cases.

For the base cases, an integer constant has type `int` in any static environment
whatsoever, a Boolean constant likewise always has type `bool`, and a variable
has whatever type the static environment says it should have. Here are the
typing rules that express those ideas:

```text
env |- i : int
env |- b : bool
{x : t, ...} |- x : t
```

The remaining syntactic forms are inductive cases.

**Let.** As we already know from OCaml, we type check the body of a let
expression using a scope that is extended with a new binding.

```text
env |- let x = e1 in e2 : t2
  if env |- e1 : t1
  and env[x -> t1] |- e2 : t2
```

The rule says that `let x = e1 in e2` has type `t2` in static environment `env`,
but only if certain conditions hold. The first condition is that `e1` has type
`t1` in `env`. The second is that `e2` has type `t2` in a new static
environment, which is `env` extended to bind `x` to `t1`.

**Binary operators.** We'll need a couple different rules for binary operators.

```text
env |- e1 bop e2 : int
  if bop is + or *
  and env |- e1 : int
  and env |- e2 : int

env |- e1 <= e2 : bool
  if env |- e1 : int
  and env |- e2 : int
```

**If.** Just like OCaml, an if expression must have a Boolean guard, and its two
branches must have the same type.

```text
env |- if e1 then e2 else e3 : t
  if env |- e1 : bool
  and env |- e2 : t
  and env |- e3 : t
```

## A Type Checker for SimPL

{{ video_embed | replace("%%VID%%", "BN_nIMgFZ_o")}}

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

Let's introduce a small signature for static environments, based on the
abstractions we've introduced so far: the empty static environment, looking up a
variable, and extending a static environment.

```ocaml
module type StaticEnvironment = sig
  (** [t] is the type of a static environment. *)
  type t

  (** [empty] is the empty static environment. *)
  val empty : t

  (** [lookup env x] gets the binding of [x] in [env].
      Raises: [Failure] if [x] is not bound in [env]. *)
  val lookup : t -> string -> typ

  (** [extend env x ty] is [env] extended with a binding
      of [x] to [ty]. *)
  val extend : t -> string -> typ -> t
end
```

It's easy to implement that signature with an association list.

```ocaml
module StaticEnvironment : StaticEnvironment = struct
  type t = (string * typ) list

  let empty = []

  let lookup env x =
    try List.assoc x env
    with Not_found -> failwith "Unbound variable"

  let extend env x ty =
    (x, ty) :: env
end
```

Now we can implement the typing relation `|-`. We'll do that by writing a
function `typeof : StaticEnvironment.t -> expr -> typ`, such that
`typeof env e = t` if and only if `env |- e : t`. Note that the `typeof`
function produces the type as output, so the function is actually inferring the
type! That inference is easy for SimPL; it would be considerably harder for
larger languages.

{{ video_embed | replace("%%VID%%", "m3bt3BYB0vQ")}}

Let's start with the base cases:

```ocaml
open StaticEnvironment

(** [typeof env e] is the type of [e] in static environment [env].
    Raises: [Failure] if [e] is not well typed in [env]. *)
let rec typeof env = function
  | Int _ -> TInt
  | Bool _ -> TBool
  | Var x -> lookup env x
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
hasn't been bound in the static environment.

{{ video_embed | replace("%%VID%%", "TiKPU5rYeF8")}}

Let's continue with the recursive cases:

```ocaml
  ...
  | Let (x, e1, e2) -> typeof_let env x e1 e2
  | Binop (bop, e1, e2) -> typeof_bop env bop e1 e2
  | If (e1, e2, e3) -> typeof_if env e1 e2 e3
```

We're factoring out a helper function for each branch for the sake of keeping
the pattern match readable. Each of the helpers directly encodes the ideas of
the `|-` rules, with error handling added.

```ocaml
and typeof_let env x e1 e2 =
  let t1 = typeof env e1 in
  let env' = extend env x t1 in
  typeof env' e2

and typeof_bop env bop e1 e2 =
  let t1, t2 = typeof env e1, typeof env e2 in
  match bop, t1, t2 with
  | Add, TInt, TInt
  | Mult, TInt, TInt -> TInt
  | Leq, TInt, TInt -> TBool
  | _ -> failwith "Operator and operand type mismatch"

and typeof_if env e1 e2 e3 =
  if typeof env e1 = TBool
  then begin
    let t2 = typeof env e2 in
    if t2 = typeof env e3 then t2
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
    the empty static environment. Raises: [Failure] if not. *)
let typecheck e =
  ignore (typeof empty e)
```

## Type Safety

{{ video_embed | replace("%%VID%%", "MrmEIbDOfnk")}}

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
