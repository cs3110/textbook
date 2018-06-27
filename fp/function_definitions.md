# Function Definitions

The following code
```
let x = 42
```
has an expression in it (`42`) 
but is not itself an expression.  Rather, it is a *definition*. 
Definitions bind values to names, in this case the value `42` being
bound to the name `x`.  The OCaml manual has definition of
[all definitions][definitions] 
(see the third major grouping titled "*definition*" on that page), but again
that manual page is primarily for reference not for study.
Definitions are not expressions, nor are expressions definitions&mdash;
they are distinct syntactic classes.  But definitions can have expressions
nested inside them, and vice-versa.

[definitions]: http://caml.inria.fr/pub/docs/manual-ocaml/modules.html

For now, let's focus on one particular kind of definition, a *function definition*.
Non-recursive functions are defined like this:

	let f x = ...

Recursive functions are defined like this:

	let rec f x = ...

The difference is just the `rec` keyword.  It's probably a bit surprising that
you explicitly have to add a keyword to make a function recursive, because
most languages assume by default that they are.  OCaml doesn't make that 
assumption, though.

One of the best known recursive functions is the factorial function.
In OCaml it can be written as follows:

```
(* requires: n >= 0 *)
(* returns: n! *)
let rec fact n = 
  if n=0 then 1 else n * fact (n-1)
```

We provided a specification comment above the function to document the
precondition (`requires`) and postcondition (`returns`) of the function. 

Note that, as in many languages, OCaml integers are not the
"mathematical" integers but are limited to a fixed number of bits.  The
[manual][man] specifies that integers are at least 30 bits but might be
wider.  So if you test on large enough inputs, you might begin to see
strange results.  The problem is machine arithmetic, not OCaml.  

[man]: http://caml.inria.fr/pub/docs/manual-ocaml/values.html#sec76


Here's another recursive function:
```
(* requires: y>=0 *)
(* returns: x to the power of y *)
let rec pow x y = 
  if y=0 then 1 
  else x * pow x (y-1)
```

Note how we didn't have to write any types in either of our functions:
the OCaml compiler infers them for us automatically.  The compiler
solves this *type inference* problem algorithmically, but we could do
it ourselves, too. It's like a mystery that can be solved by our
mental power of deduction:

* Since the if expression can return `1` in the `then`
  branch, we know by the typing rule for `if` that the entire if expression
  has type `int`.  
  
* Since the if expression has type `int`, the function's return type must
  be `int`.
  
* Since `y` is compared to `0` with the equality operator, `y` must be an `int`.

* Since `x` is multiplied with another expression using the `*` operator,
  `x` must be an `int`.
  
If we did want to write down the types for some reason, we could do that:
```
(* requires: y>=0 *)
(* returns: x to the power of y *)
let rec pow (x:int) (y:int) : int = 
  if y=0 then 1 
  else x * pow x (y-1)
```
When we write the *type annotations* for `x` and `y` the parentheses are
mandatory.  We will generally leave out these annotations, because
it's simpler to let the compiler infer them.  There are other times when you'll
want to explicitly write down types though.  One particularly useful time
is when you get a type error from the compiler that doesn't make sense.
Explicitly annotating the types can help with debugging such an error message.

**Syntax.**
The syntax for function definitions:
```
let rec f x1 x2 ... xn = e
```
The `f` is a metavariable indicating an identifier being used as a function
name.  These identifiers must begin with a lowercase letter.  The remaining
[rules for lowercase identifiers][lowercase] can be found in the manual.
The names `x1` through `xn` are metavariables indicating argument identifiers.
These follow the same rules as function identifiers.  The keyword `rec`
is required if `f` is to be a recursive function; otherwise it may be omitted.

[lowercase]: http://caml.inria.fr/pub/docs/manual-ocaml/lex.html#lowercase-ident

Note that syntax for function definitions is actually simplified compared
to what OCaml really allows.  We will learn more about some augmented
syntax for function definition in the next couple weeks.  But for now,
this simplified version will help us focus.

Mutually recursive functions can be defined with the `and` keyword:
```
let rec f x1 ... xn = e1
and g y1 ... yn = e2
```
For example:
```
(* [even n] is whether [n] is even.
 * requires: [n >= 0] *)
let rec even n = 
  n=0 || odd (n-1) 
  
(* [odd n] is whether [n] is odd.
 * requires: [n >= 0] *)
and odd n = 
  n<>0 && even (n-1);;
```

The syntax for function types:
```
t -> u
t1 -> t2 -> u
t1 -> ... -> tn -> u
```
The `t` and `u` are metavariables indicating types. Type `t -> u` is the
type of a function that takes an input of type `t` and returns an output
of type `u`.  We can think of `t1 -> t2 -> u` as the type of a function
that takes two inputs, the first of type `t1` and the second of type
`t2`, and returns an output of type `u`.  Likewise for a function that
takes `n` arguments.  

**Dynamic semantics.**
There is no dynamic semantics of function definitions.  There is nothing
to be evaluated.  OCaml just records that the name `f` is bound to a function
with the given arguments `x1..xn` and the given body `e`.  Only later, when
the function is applied, will there be some evaluation to do.

**Static semantics.**
The static semantics of function definitions:

* For non-recursive functions: if by assuming that 
  `x1:t1` and `x2:t2` and ... and `xn:tn`, we can conclude that `e:u`, 
  then `f : t1 -> t2 -> ... -> tn -> u`.
* For recursive functions: if by assuming that 
  `x1:t1` and `x2:t2` and ... and `xn:tn` and
  `f : t1 -> t2 -> ... -> tn -> u`, we can conclude that `e:u`,
  then `f : t1 -> t2 -> ... -> tn -> u`.
  
Note how the type checking rule for recursive functions assumes that the
function identifier `f` has a particular type, then checks to see whether
the body of the function is well-typed under that assumption.  This is
because `f` is in scope inside the function body itself (just like the arguments
are in scope).

