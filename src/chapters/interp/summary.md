# Summary

At first it might seem mysterious how a programming language could be
implemented. But, after this chapter, hopefully some of that mystery has been
revealed. Implementation of a programming language is just a matter of the same
studious application of syntax, dynamic semantics, and static semantics that
we've studied throughout this book. It also relies heavily on CS theory of the
kind studied in discrete mathematics or theory of computation courses.

## Terms and Concepts

- abstract syntax
- abstract syntax tree
- associativity
- back end
- Backus-Naur Form (BNF)
- big step
- bytecode
- call by name
- call by value
- capture-avoiding substitution
- closure
- compiler
- concrete syntax
- constraint
- context-free grammar
- context-free language
- desugaring
- dynamic environment
- dynamic scope
- environment model
- evaluation
- fresh
- front end
- generalization
- Hindley&ndash;Milner (HM) type inference algorithm
- implicit typing
- instantiation
- intermediate representation
- interpreter
- lambda calculus
- let polymorphism
- lexer
- machine configuration
- metavariable
- nonterminal
- operational semantics
- optimizing compiler
- parser
- precedence
- preliminary type variable
- preservation
- primitive operatiohn
- progress
- pushdown automata
- regular expression
- regular language
- relation
- semantic analysis
- short circuit
- small step
- source program
- static scope
- static typing
- stuck
- substitution
- substitution model
- symbol
- symbol table
- target program
- terminal
- token
- type annotation
- type checking
- type inference
- type reconstruction
- type safety
- type scheme
- type system
- type variable
- typing context
- unification
- unifier
- value
- value restriction
- virtual machine
- weak type variable
- well typed

## Further Reading

* *Types and Programming Languages* by Benjamin C. Pierce, chapters 1-14, 22.
* *Modern Compiler Implementation* (in Java or ML) by Andrew W. Appel, chapters
  1-5.
* *Automata and Computability* by Dexter C. Kozen, chapters 1-27.
* *Real World OCaml* has a
  [chapter on the OCaml frontend](https://dev.realworldocaml.org/compiler-frontend.html).
* This [webpage](http://okmij.org/ftp/ML/generalization.html) documents how some
  of the internals of the OCaml type checker and inferencer.
* The OCaml VM aka the Zinc Machine is described in these papers:
  [1](http://cadmium.x9c.fr/distrib/caml-instructions.pdf),
  [2](https://hal.inria.fr/inria-00070049/document).

## Acknowledgment

Our treatment of type inference is based on Pierce.