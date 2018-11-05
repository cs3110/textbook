# Exercises

Many of these exercises rely on the [completed SimPL interpreter](simpl.zip) 
as starter code.

## Parsing 

##### Exercise: parse [&#10029;] 

Run `make` in the SimPL interpreter implementation.  It will compile the
interpreter and launch utop.  Evaluate the following expressions.
Note what each returns.

* `parse "22"`
* `parse "1+2+3"`
* `parse "let x = 2 in 20+x"`

Also evaluate these expressions, which will raise exceptions.  Explain why
each one is an error, and whether the error occurs during parsing or lexing.

* `parse "3.14"`
* `parse "3+"`

&square;

##### Exercise: parser.ml and lexer.ml [&#10029;] 

Open `_build/parser.ml`, which is the module generated automatically
by menhir from `parser.mly`.  Skim through the file to appreciate not
having to write the parser yourself.

Also open `_build/lexer.ml`, which is the module generated
automatically by ocamllex from `lexer.mll`.  Skim through the file to
appreciate not having to write the lexer yourself.

&square;

##### Exercise: simpl ids [&#10029;&#10029;] 

Examine the definition of the `id` regular expression in the SimPL lexer.
Identify at least one way in which it differs from the definition of
OCaml identifiers.

&square;

##### Exercise: times parsing [&#10029;&#10029;] 

In the SimPL parser, the `TIMES` token is declared as having higher precedence 
than `PLUS`, and as being left associative.  Let's experiment with other choices.

* Evaluate `parse "1*2*3"`.  Note the AST.
  Now change the declaration of the associativity of `TIMES` in `parser.mly` to be 
  `%right` instead of `%left`.  Recompile and reevaluate `parse "1*2*3"`.  How did
  the AST change?  Before moving on, restore the declaration to be `%left`.
  
* Evaluate `parse "1+2*3"`.  Note the AST.
  Now swap the declaration `%left TIMES` in `parser.mly` with the declaration
  `%left PLUS`.  Recompile and reevaluate `parse "1+2*3"`.  How did
  the AST change?  Before moving on, restore the original declaration order.
  
&square;

## Type Checking

##### Exercise: infer [&#10029;] 

Run `make` in the SimPL interpreter implementation.  It will compile the
interpreter and launch utop.  Now, define a function `infer : string -> typ`
such that `infer s` parses `s` into an expression and infers the type of
`s` in the empty context.  Your solution will make use of the `typeof`
function.

Try out your `infer` function on these test cases:

* `"3110"`
* `"1 <= 2"`
* `"let x = 2 in 20 + x"`

##### Exercise: subexpression types [&#10029;&#10029;] 

Suppose that a SimPL expression is well typed in a context `ctx`.
Are all of its subexpressions also well typed in `ctx`?  For every
subexpression, does there exist some context in which the
subexpression is well typed? Why or why not?

&square;

##### Exercise: typing [&#10029;&#10029;] 

Use the SimPL type system to show that
`{} |- let x = 0 in if x <= 1 then 22 else 42 : int`.

&square;

##### Exercise: typing [&#10029;&#10029;] 

Use the SimPL type system to show that
`{} |- let x = 0 in if x <= 1 then 22 else 42 : int`.

&square;

## The Substitution Model

##### Exercise: substitution [&#10029;&#10029;] 

What is the result of the following substitutions?

  - `(x+1){2/x}` 
  - `(x+y){2/x}{3/y}`
  - `(x+y){1/z}`
  - `(let x=1 in x+1){2/x}`
  - `(x + (let x=1 in x+1)){2/x}`
  - `((let x=1 in x+1) + x){2/x}`
  - `(let x=y in x+1){2/y}`
  - `(let x=x in x+1){2/x}`
  
&square;

##### Exercise: step expressions [&#10029;] 

Here is an example of evaluating an expression:
```
  7+5*2
-->  (step * operation)
  7+10
-->  (step + operation)
  17
```
There are two steps in that example, and we've annotated each
step with a parenthetical comment to hint at which evaluation
rule we've used.  We stopped evaluating when we reached a value.

Evaluate the following expressions using the small-step substitution model.
Use the "long form" of evaluation that we demonstrated above, in which
you provide a hint as to which rule is applied at each step.

 - `(3 + 5) * 2` (2 steps)
 - `if 2 + 3 <= 4 then 1 + 1 else 2 + 2` (4 steps)
 
&square;

##### Exercise: step let expressions [&#10029;&#10029;] 

Evaluate these expressions, again using the "long form" from the
previous exercise.  

 - `let x = 2 + 2 in x + x` (3 steps)
 - `let x = 5 in ((let x = 6 in x) + x)` (3 steps)
 - `let x = 1 in (let x = x + x in x + x)` (4 steps)

&square;

## Pairs

Add pairs (i.e., tuples with exactly two components) to SimPL.
Start with the [base SimPL interpreter](simpl.zip).

##### Exercise: pair parsing [&#10029;&#10029;&#10029;] 

Implement lexing and parsing of pairs. Assume that the parentheses
around the pair are required (not optional, as they sometimes are in
OCaml).  Follow this strategy:

* Add a constructor for pairs to the `expr` type.
* Add a comma token to the parser.
* Implement lexing the comma token.
* Implement parsing of pairs.

When you compile, you will get some inexhaustive pattern match warnings,
because you have not yet implemented type checking nor interpretation of
pairs.  But you can still try parsing them in utop with the `parse`
function.

&square;

##### Exercise: pair type checking [&#10029;&#10029;&#10029;] 

Implement type checking of pairs.  Follow this strategy:

* Write down a new typing rule before implementing any code.
* Add a new constructor for pairs to the `typ` type.
* Add a new branch to `typeof`.

&square;

##### Exercise: pair type checking [&#10029;&#10029;&#10029;] 

Implement evaluation of pairs.  Follow this strategy:

* Implement `is_value` for pairs.  A pair of values (e.g., `(0,1)`)
  is itself a value, so the function will need to become recursive.
* Implement `subst` for pairs:  `(e1, e2){v/x} = (e1{v/x}, e2{v/x})`.
* Implement small-step and big-step evaluation of pairs, using these 
  rules:

```
(e1, e2) --> (e1', e2)
  if e1 --> e1'

(v1, e2) --> (v1, e2')
  if e2 --> e2'
  
(e1, e2) ==> (v1, v2)
  if e1 ==> v1
  and e2 ==> v2
```

&square;
