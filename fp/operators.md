## Operators

Operators can be used to form expressions.
OCaml has more or less all the usual operators you would expect in a language
from the C or Java family of languages.  See the [table of all operators in 
the OCaml manual][ops] for details.

Here are two things to watch out for as you begin:

* OCaml deliberately does not support operator overloading.
  As a consequence, the integer and floating-point operators are distinct.
  E.g., to add integers, use `+`.  To add floating-point numbers, use `+.`.
  
* There are two equality operators in OCaml, `=` and `==`, with
  corresponding inequality operators `<>` and `!=`.  Operators `=` and
  `<>` examine *structural* equality whereas `==` and `!=` examine
  *physical* equality.  Until we've studied the imperative features of
  OCaml, the difference between them will be tricky to
  explain.  (See the [documentation][pervasives] of `Pervasives.(==)` if you're
  curious now.)  But what's important now is that you train yourself only to
  use `=` and not to use `==`, which might be difficult if you're coming
  from a language like Java where `==` is the usual equality operator.

[ops]: http://caml.inria.fr/pub/docs/manual-ocaml/expr.html#sec139
[pervasives]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Pervasives.html


