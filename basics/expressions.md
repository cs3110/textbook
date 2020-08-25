# Expressions

The primary piece of OCaml syntax is the *expression*.  Just like
programs in imperative languages are primarily built out of *commands*,
programs in functional languages are primarily built out of expressions.
Examples of expressions include `2+2` and `increment 21`.

The OCaml manual has a complete definition of [all the expressions in
the language][exprs].  Though that page starts with a rather cryptic
overview, if you scroll down, you'll come to some English explanations. 
Don't worry about studying that page now; just know that it's
available for reference.

[exprs]:  http://caml.inria.fr/pub/docs/manual-ocaml/expr.html

The primary task of computation in a functional language is to
*evaluate* an expression to a *value*.  A value is an expression for
which there is no computation remaining to be performed.  So, all values
are expressions, but not all expressions are values.  Examples of values
include `2`, `true`, and `"yay!"`.

The OCaml manual also has a definition of [all the values][values], though again,
that page is mostly useful for reference rather than study.

[values]: http://caml.inria.fr/pub/docs/manual-ocaml/values.html

Sometimes an expression might fail to evaluate to a value.  There are two
reasons that might happen:

1. Evaluation of the expression raises an exception.  
2. Evaluation of the expression never terminates (e.g., it enters an "infinite loop").

## Assertions

The expression `assert e` evaluates `e`.  If the result is `true`, nothing
more happens, and the entire expression evaluates to a special value called
*unit*.  The unit value is written `()` and its type is `unit`.
But if the result is `false`, an exception is raised.
