# \*Induction Principles for All Variants

We've now seen induction principles for `nat`, `list`, and `bintree`.
Generalizing from what we've seen, each constructor of a variant either
generates a base case for the inductive proof, or an inductive case. And, if a
constructor itself carries values of that data type, each of those values
generates in inductive hypothesis.  For example:

- `Z`, `[]`, and `Leaf` all generated base cases.

- `S`, `::`, and `Node` all generated inductive cases.

- `S` and `::` each generated one IH, because each carries one value of the
  data type.

- `Node` generated two IHs, because it carries two values of the data type.

Suppose we have these types to represent the AST for expressions in a simple
language with integers, Booleans, unary operators, and binary operators:
```
type uop =
  | UMinus

type bop =
  | BPlus
  | BMinus

type expr =
  | Int of int
  | Bool of bool
  | Unop of uop * expr
  | Binop of expr * bop * expr
```

The induction principle for `expr` is:
```
forall properties P,
  if forall i, P(Int i)
  and forall b, P(Bool b)
  and forall u e, P(e) implies P(Unop (u, e))
  and forall b e1 e2, (P(e1) and P(e2)) implies P(Binop (e1, b, e2))
  then forall e, P(e)
```
There are two base cases, corresponding to the two constructors that don't carry
an `expr`.  There are two inductive cases, corresponding to the two constructors
that do carry `expr`s.  `Unop` gets one IH, whereas `Binop` gets two IHs,
because of the number of `expr`s that each carries.
