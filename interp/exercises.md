# Exercises

## SimPL

Download the completed [SimPL interpreter](simpl.zip) to do these exercises.
TODO: create that file.

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


##### Exercise: pair parsing [&#10029;&#10029;&#10029;] 

Add pairs (i.e., tuples with exactly two components) to the SimPL language.
Assume that the parentheses around the pair are required (not optional,
as they sometimes are in OCaml).

Follow this strategy:

* Add a constructor for pairs to the AST type.
* Add a comma token to the parser.
* Implement lexing the comma token.
* Implement parsing of pairs.

When you compile, you will get some inexhaustive pattern match warnings, because
you have not yet implemented interpretation of pairs.  But you can still
try parsing them in utop with the `parse` function.

&square;

