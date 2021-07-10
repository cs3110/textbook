# Summary

This chapter is one of the most important in the book. It didn't cover any new
language features. Instead, we learned how to use some of the existing features
in ways that might be new, surprising, or challenging. Higher-order programming
and the Abstraction Principle are two ideas that will help make you a better
programmer in any language, not just OCaml. Of course, languages do vary in the
extent to which they support these ideas, with some providing significantly less
assistance in writing higher-order code&mdash;which is one reason we use OCaml
in this course.

Map, filter, fold and other functionals are becoming widely recognized as
excellent ways to structure computation. Part of the reason for that is they
factor out the *iteration* over a data structure from the *computation* done at
each element. Languages such as Python, Ruby, and Java 8 now have support for
this kind of iteration.

## Terms and concepts

* Abstraction Principle
* accumulator
* apply
* associative
* compose
* factor
* filter
* first-order function
* fold
* functional
* generalized fold operation
* higher-order function
* map
* pipeline
* pipelining

## Further reading

* *Introduction to Objective Caml*, chapters 3.1.3, 5.3
* *OCaml from the Very Beginning*, chapter 6
* *More OCaml: Algorithms, Methods, and Diversions*, chapter 1, by John
  Whitington. This book is a sequel to *OCaml from the Very Beginning*.
* *Real World OCaml*, chapter 3 (beware that this book's `Core` library has a
  different `List` module than the standard library's `List` module, with
  different types for `map` and `fold` than those we saw here)
* "Higher Order Functions", chapter 6 of *Functional Programming: Practice and
  Theory*. Bruce J. MacLennan, Addison-Wesley, 1990. Our discussion of
  higher-order functions and the Abstraction Principle is indebted to this
  chapter.
* "Can Programming be Liberated from the von Neumann Style? A Functional Style
  and Its Algebra of Programs." John Backus' 1977 Turing Award lecture in its
  elaborated form as a [published article][backus-turing].
* "[Second-order and Higher-order Logic][solhol]" in *The Stanford Encyclopedia
  of Philosophy*.

[solhol]:  http://plato.stanford.edu/entries/logic-higher-order/
[backus-turing]: https://dl.acm.org/doi/pdf/10.1145/359576.359579
