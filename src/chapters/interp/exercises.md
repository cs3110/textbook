# Exercises

{{ solutions }}

Many of these exercises rely on the SimPL interpreter as starter code. You can
download it here: {{ code_link | replace("%%NAME%%", "simpl.zip") }}.

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "parse")}}

Run `make` in the SimPL interpreter implementation. It will compile the
interpreter and launch utop. Evaluate the following expressions. Note what each
returns.

* `parse "22"`
* `parse "1+2+3"`
* `parse "let x = 2 in 20+x"`

Also evaluate these expressions, which will raise exceptions.  Explain why
each one is an error, and whether the error occurs during parsing or lexing.

* `parse "3.14"`
* `parse "3+"`

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "generated parser and lexer")}}

Run OCamlbuild to generate the parser and lexer in the `_build` directory.

Open `parser.ml`, which is the module generated automatically by menhir from
`parser.mly`. Skim through the file to appreciate not having to write the parser
yourself.

Also open `lexer.ml`, which is the module generated automatically by ocamllex
from `lexer.mll`. Skim through the file to appreciate not having to write the
lexer yourself.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "simpl ids")}}

Examine the definition of the `id` regular expression in the SimPL lexer.
Identify at least one way in which it differs from the definition of OCaml
identifiers.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "times parsing")}}

In the SimPL parser, the `TIMES` token is declared as having higher precedence
than `PLUS`, and as being left associative. Let's experiment with other choices.

* Evaluate `parse "1*2*3"`. Note the AST. Now change the declaration of the
  associativity of `TIMES` in `parser.mly` to be `%right` instead of `%left`.
  Recompile and reevaluate `parse "1*2*3"`. How did the AST change? Before
  moving on, restore the declaration to be `%left`.

* Evaluate `parse "1+2*3"`. Note the AST. Now swap the declaration `%left TIMES`
  in `parser.mly` with the declaration `%left PLUS`. Recompile and reevaluate
  `parse "1+2*3"`. How did the AST change? Before moving on, restore the
  original declaration order.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "infer")}}

Type inference for SimPL can be done in a much simpler way than for the larger
language (with anonymous functions and let expression) that we considered in the
section on type inference.

Run `make` in the SimPL interpreter implementation. It will compile the
interpreter and launch utop. Now, define a function `infer : string -> typ` such
that `infer s` parses `s` into an expression and infers the type of `s` in the
empty context. Your solution will make use of the `typeof` function. You don't
need constraint collection or unification.

Try out your `infer` function on these test cases:

* `"3110"`
* `"1 <= 2"`
* `"let x = 2 in 20 + x"`

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "subexpression types")}}

Suppose that a SimPL expression is well typed in a context `ctx`. Are all of its
subexpressions also well typed in `ctx`? For every subexpression, does there
exist some context in which the subexpression is well typed? Why or why not?

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "typing")}}

Use the SimPL type system to show that
`{} |- let x = 0 in if x <= 1 then 22 else 42 : int`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "substitution")}}

What is the result of the following substitutions?

  - `(x + 1){2/x}`
  - `(x + y){2/x}{3/y}`
  - `(x + y){1/z}`
  - `(let x = 1 in x + 1){2/x}`
  - `(x + (let x=1 in x+1)){2/x}`
  - `((let x=1 in x+1) + x){2/x}`
  - `(let x=y in x+1){2/y}`
  - `(let x=x in x+1){2/x}`

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "step expressions")}}

Here is an example of evaluating an expression:

```text
  7+5*2
-->  (step * operation)
  7+10
-->  (step + operation)
  17
```

There are two steps in that example, and we've annotated each step with a
parenthetical comment to hint at which evaluation rule we've used. We stopped
evaluating when we reached a value.

Evaluate the following expressions using the small-step substitution model. Use
the "long form" of evaluation that we demonstrated above, in which you provide a
hint as to which rule is applied at each step.

 - `(3 + 5) * 2` (2 steps)
 - `if 2 + 3 <= 4 then 1 + 1 else 2 + 2` (4 steps)

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "step let expressions")}}

Evaluate these expressions, again using the "long form" from the previous
exercise.

 - `let x = 2 + 2 in x + x` (3 steps)
 - `let x = 5 in ((let x = 6 in x) + x)` (3 steps)
 - `let x = 1 in (let x = x + x in x + x)` (4 steps)

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "variants")}}

Evaluate these Core OCaml expressions using the small-step substitution model:

 - `Left (1+2)` (1 step)
 - `match Left 42 with Left x -> x+1 | Right y -> y-1` (2 steps)

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "application")}}

Evaluate these Core OCaml expressions using the small-step substitution model:

 - `(fun x -> 3 + x) 2` (2 steps)
 - `let f = (fun x -> x + x) in (f 3) + (f 3)` (6 steps)
 - `let f = fun x -> x + x in let x = 1 in let g = fun y -> x + f y in g 3` (7 steps)
 - `let f = (fun x -> fun y -> x + y) in let g = f 3 in (g 1) + (f 2 3)` (9 steps)


<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "omega")}}

Try evaluating `(fun x -> x x) (fun x -> x x)`. This expression, which is
usually called $\Omega$, doesn't type check in real OCaml, but we can still use
the Core OCaml small-step semantics on it.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "pair parsing")}}

Add pairs (i.e., tuples with exactly two components) to SimPL. Implement lexing
and parsing of pairs. Assume that the parentheses around the pair are required
(not optional, as they sometimes are in OCaml). Follow this strategy:

* Add a constructor for pairs to the `expr` type.
* Add a comma token to the parser.
* Implement lexing the comma token.
* Implement parsing of pairs.

When you compile, you will get some inexhaustive pattern match warnings, because
you have not yet implemented type checking nor interpretation of pairs. But you
can still try parsing them in utop with the `parse` function.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "pair type checking")}}

Implement type checking of pairs.  Follow this strategy:

* Write down a new typing rule before implementing any code.
* Add a new constructor for pairs to the `typ` type.
* Add a new branch to `typeof`.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "pair evaluation")}}

Implement evaluation of pairs.  Follow this strategy:

* Implement `is_value` for pairs. A pair of values (e.g., `(0,1)`) is itself a
  value, so the function will need to become recursive.
* Implement `subst` for pairs:  `(e1, e2){v/x} = (e1{v/x}, e2{v/x})`.
* Implement small-step and big-step evaluation of pairs, using these rules:

```text
(e1, e2) --> (e1', e2)
  if e1 --> e1'

(v1, e2) --> (v1, e2')
  if e2 --> e2'

(e1, e2) ==> (v1, v2)
  if e1 ==> v1
  and e2 ==> v2
```

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "desugar list")}}

Suppose we treat list expressions like syntactic sugar in the following way:

* `[]` is syntactic sugar for `Left 0`.
* `e1 :: e2` is syntactic sugar for `Right (e1, e2)`.

What is the core OCaml expression to which `[1; 2; 3]` desugars?

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "list not empty")}}

Write a core OCaml function `not_empty` that returns `1` if a list is non-empty
and `0` if the list is empty. Use the substitution model to check that your
function behaves properly on these test cases:

 - `not_empty []`
 - `not_empty [1]`

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "list not empty")}}

In core OCaml, there are only two patterns: `Left x` and `Right x`,
where `x` is a variable name.  But in full OCaml, patterns are far more
general. Let's see how far we can generalize patterns in core OCaml.

**Step 1:** Here is a BNF grammar for patterns, and slightly revised
BNF grammar for expressions:

```text
p ::= i | (p1, p2) | Left p | Right p | x | _

e ::= ...
    | match e with | p1 -> e1 | p2 -> e2 | ... | pn -> en
```

In the revised syntax for `match`, only the very first `|` on the line,
immediately before the keyword `match`, is meta-syntax.  The remaining
four `|` on the line are syntax.  Note that we require `|` before the
first pattern.

**Step 2:** A value `v` matches a pattern `p` if by substituting any
variables or wildcards in `p` with values, we can obtain exactly `v`.
For example:

* `2` matches `x` because `x{2/x}` is `2`.
* `Right(0,Left 0)` matches `Right(x,_)` because
  `Right(x,_){0/x}{Left 0/_}` is `Right(0,Left 0)`.

Let's define a new ternary relation called `matches`, guided by those
examples:

```text
v =~ p // s
```

Pronounce this relation as "`v` matches `p` producing substitutions `s`."

Here, `s` is a sequence of substitutions, such as `{0/x}{Left 3/y}{(1,2)/z}`.
There is just a single rule for this relation:

```text
v =~ p // s
  if v = p s
```

For example,

```text
2 =~ x // {2/x}
  because 2 = x{2/x}
```

**Step 3:** To evaluate a match expression:

* Evaluate the expression being matched to a value.
* If that expression matches the first pattern, evaluate the expression
  corresponding to that pattern.
* Otherwise, match against the second pattern, the third, etc.
* If none of the patterns matches, evaluation is *stuck*: it cannot take any
  more steps.

Using those insights, complete the following evaluation rules
by filling in the places marked with `???`:

```text
(* This rule should implement evaluation of e. *)
match e with | p1 -> e1 | p2 -> e2 | ... | pn -> en
--> ???
  if ???

(* This rule implements moving past p1 to the next pattern. *)
match v with | p1 -> e1 | p2 -> e2 | ... | pn -> en
--> match v with | p2 -> e2 | ... | pn -> en
  if there does not exist an s such that ???

(* This rule implements matching v with p1 then proceeding to evaluate e1. *)
match v with | p1 -> e1 | p2 -> e2 | ... | pn -> en
--> ??? (* something involving e1 *)
  if ???
```

Note that we don't need to write the following rule explicitly:

```text
match v with |  -/->
```

Evaluation will get stuck at that point because none of the three other
rules above will apply.

**Step 4:** Double check your rules by evaluating the following
expression:

`match (1 + 2, 3) with | (1,0) -> 4 | (1,x) -> x | (x,y) -> x + y`

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "let rec")}}

One of the evaluation rules for `let` is

```text
let x = v in e --> e{v/x}
```

We could try adapting that to `let rec`:

```text
let rec x = v in e --> e{v/x}   (* broken *)
```

But that rule doesn't work properly, as we see in the following example:

```text
  let rec fact = fun x ->
	if x <= 1 then 1 else x * (fact (x - 1)) in
  fact 3

-->

  (fun x -> if x <= 1 then 1 else x * (fact (x - 1)) 3

-->

  if 3 <= 1 then 1 else 3 * (fact (3 - 1))

-->

  3 * (fact (3 - 1))

-->

  3 * (fact 2)

-/->
```

We're now stuck, because we need to evaluate `fact`, but it doesn't step. In
essence, the semantic rule we used "forgot" the function value that should have
been associated with `fact`.

A good way to fix this problem is to introduce a new language construct for
recursion called simply `rec`. (Note that OCaml does not have any construct that
corresponds directly to `rec`.) Formally, we extend the syntax for expressions
as follows:

```text
e ::= ...
    | rec f -> e
```

and add the following evaluation rule:

```text
rec f -> e  -->  e{(rec f -> e)/f}
```

The intuitive reading of this rule is that when evaluating
`rec f -> e`, we "unfold" `f` in the body of `e`.  For example,
here is an infinite loop coded with `rec`:

```text
  rec f -> f

-->  (* step rec *)

  f{(rec f -> f)/f}

= (* substitute *)

  rec f -> f

--> (* step rec *)

  f{(rec f -> f)/f}

...
```

Now we can use `rec` to implement `let rec`. Anywhere `let rec` appears in a
program:

```ocaml
let rec f = e1 in e2
```

we *desugar* (i.e., rewrite) it to

```ocaml
let f = rec f -> e1 in e2
```

Note that the second occurrence of `f` (inside the `rec`) shadows the first one.
Going back to the `fact` example, its desugared version is

```ocaml
let fact = rec fact -> fun x ->
  if x <= 1 then 1 else x * (fact (x - 1)) in
fact 3
```

Evaluate the following expression (17 steps, we think, though it does get pretty
tedious). You may want to simplify your life by writing "F" in place of
`(rec fact -> fun x -> if x <= 1 then 1 else x * (fact (x-1)))`

```text
let rec fact = fun x ->
  if x <= 1 then 1 else x * (fact (x - 1)) in
fact 3
```

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "simple expressions")}}

In the small-step substitution model, evaluation of an expression was rather
*list-like*: we could write an evaluation in a linear form like
`e --> e1 --> e2 --> ... --> en --> v`. In the big-step environment model,
evaluation is instead rather *tree-like*: evaluations have a nested, recursive
structure. Here's an example:

```text
<{}, (3 + 5) * 2> ==> 16          (op rule)
    because <{}, (3 + 5)> ==> 8   (op rule)
        because <{},3> ==> 3      (int const rule)
        and     <{},5> ==> 5      (int const rule)
        and 3+5 is 8
    and <{}, 2> ==> 2             (int const rule)
    and 8*2 is 16
```

We've used indentation here to show the shape of the tree, and we've labeled
each usage of one of the semantic rules.

Evaluate the following expressions using the big-step environment model. Use the
notation for evaluation that we demonstrated above, in which you provide a hint
as to which rule is applied at each node in the tree.

 - `110 + 3*1000` *hint: three uses of the constant rule, two uses of the op
   rule*
 - `if 2 + 3 < 4 then 1 + 1 else 2 + 2` *hint: five uses of constant, three uses
   of op, one use of if(else)*

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "let and match expressions")}}

Evaluate these expressions, continuing to use the tree notation, and continuing
to label each usage of a rule.

 - `let x=0 in 1` *hint: one use of let, two uses of constant*
 - `let x=2 in x+1` *hint: one use of let, two uses of constant, one use of op,
   one use of variable*
 - `match Left 2 with Left x -> x+1 | Right x -> x-1` *hint: one use of
   match(left), two uses of constant, one use of op, one use of variable*

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "closures")}}

Evaluate these expressions:

 - `(fun x -> x+1) 2` *hint: one use of application, one use of anonymous
   function, two uses of constant, one use of op, one use of variable*
 - `let f = fun x -> x+1 in f 2` *hint: one use of let, one use of anonymous
   function, one use of application, two uses of variable, one use of op, two
   uses of constant*

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "lexical scope and shadowing")}}

Evaluate these expressions:

 - `let x=0 in x + (let x=1 in x)` *hint: two uses of let, two uses of variable,
   one use of op, two uses of constant*
 - `let x=1 in let f=fun y -> x in let x=2 in f 0` *hint: three uses of let, one
   use of anonymous function, one use of application, two uses of variable,
   three uses of constant*

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "more evaluation")}}

Evaluate these:

 - `let x = 2 + 2 in x + x`
 - `let x = 1 in let x = x + x in x + x`
 - `let f = fun x -> fun y -> x + y in let g = f 3 in g 2`
 - `let f = fst (let x = 3 in fun y -> x, 2) in f 0`

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "dynamic scope")}}

Use dynamic scope to evaluate the following expression. You do not need to write
down all of the evaluation steps unless you find it helpful. Compare your answer
to the answer you would expect from a language with lexical scope.

```ocaml
let x = 5 in
let f y = x + y in
let x = 4 in
f 3
```

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "more dynamic scope")}}

Use dynamic scope to evaluate the following expressions. Compare your answers to
the answers you would expect from a language with lexical scope.

Expression 1:

```ocaml
let x = 5 in
let f y = x + y in
let g x = f x in
let x = 4 in
g 3
```

Expression 2:

```ocaml
let f y = x + y in
let x = 3 in
let y = 4 in
f 2
```

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "constraints")}}

Show the derivation of the `env |- e : t -| C` relation for these expressions:

```text
1. fun x -> ( + ) 1 x
2. fun b -> if b then false else true
3. fun x -> fun y -> if x <= y then y else x
```

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "unify")}}

Use the unification algorithm to solve the following system of constraints. Your
answer should be a *substitution*, in the sense that the unification algorithm
defines that term.

```text
X = int
Y = X -> X
```

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "unify more")}}

Use the unification algorithm to solve the following system of constraints. Your
answer should be a *substitution*, in the sense that the unification algorithm
defines that term.

```text
X -> Y = Y -> Z
     Z = U -> W
```

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "infer apply")}}

Using the HM type inference algorithm, infer the type of the following
definition:

```ocaml
let apply f x = f x
```

Remember to go through these steps:

* desugar the definition entirely (i.e., construct an AST)
* collect constraints
* solve the constraints with unification

&square;

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "infer double")}}

Using the HM type inference algorithm, infer the type of the following
definition:

```ocaml
let double f x = f (f x)
```

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "infer S")}}

Using the HM type inference algorithm, infer the type of the following
definition:

```ocaml
let s x y z = (x z) (y z)
```
