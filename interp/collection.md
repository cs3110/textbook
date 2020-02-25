# Constraint Collection

We now present an algorithm that generates constraints. This algorithm
is a precise description of how constraint gathering works in the
examples we discussed above. The algorithm is not *exactly* what HM does,
because HM actually performs type checking at the same time as type
inference. However, the resulting types are the same, and separating
inference from checking hopefully will give you a clearer idea of how
inference itself works.

The algorithm takes as input an expression `e`. We'll
assume that every function `fun x -> e'` in that expression has an
argument with a different name. (If not, our algorithm could make a
pre-pass to rename variables. This is feasible because of lexical scope.)
The output of the algorithm is a set of constraints.

The first thing the algorithm does is to assign unique preliminary
type variables, e.g. `R` or `S`, 

- one to each *defining* occurrence of a variable, which could be as
  a function argument or a let binding, and
- one to each occurrence of each subexpression of `e`.

Call the type variable assigned to `x` in the former clause
`D(x)`, and call the type variable assigned to occurrence of a
subexpression `e'` in the latter clause `U(e')`.  The names of these
are mnemonics:  `U` stands for the <u>u</u>se of an expression,
and `D` stands for the <u>d</u>efinition of a variable name.

Next, the algorithm generates the following constraints:

- For integer constants `n`:  `U(n) = int`.  This constraints follows
  from the type checking rule for integers, which says that every
  integer constant has type `int`.  Constraints for other types of 
  constants are generated in a similar way.
- For variables `x`:  `D(x) = U(x)`.  This constraint follows from the type
  checking rule for variables, which says the type of a variable use (in this case, `U(x)`)
  must be the same as the type at which that variable was defined (here, `D(x)`).
- For function application `e1 e2`: `U(e1) = U(e2) -> U(e1 e2)`, 
  as well as any constraints resulting from `e1` and `e2`.  This constraint follows
  from the type checking rule for function application.
- For anonymous functions `fun x -> e`: `U(fun x -> e) = D(x) -> U(e)`,
  as well as any constraints resulting from `e`.  This constraint follows from the
  type checking rule for anonymous functions.
- For let expressions `let x=e1 in e2`: `D(x)=U(e1)`, `U(let x=e1 in e2) = U(e2)`,
  as well as any constraints resulting from `e1` and `e2`.  This constraint follows
  from the type checking rule for let expressions.
- Other expression forms:  similar kinds of constraints likewise derived from the
  type checking rule for the expression form.

The result is a set of constraints, which is the output of the
algorithm. It's not too hard to implement this algorithm as a recursive
function over a tree representing the syntax of `e`.

**Example.**
Given expression `fun x -> (fun y -> x)`, a type variable `R` is
associated with argument `x`, and `S` with argument `y`.  For
subexpressions, `T` is associated with the occurrence of `fun x -> (fun
y -> x)`, and `X` with the occurrence of `(fun y -> x)`, and `Y` with
the occurrence of `x`. (Note that the names we've chosen for the type
variables are completely arbitrary.) The constraints generated are `T =
R -> X`, and `X = S -> Y`, and `Y = R`.

