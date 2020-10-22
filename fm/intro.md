# Proofs about Programs

Our goal in this chapter is to learn some techniques for proving the correctness
of programs.  Such techniques are known as _formal methods_ because of their
use of mathematical formalism.

*Correctness* here means that the program produces the right output
according to a *specification*. Specifications are usually provided in the
documentation of a function (hence the name "specification comment"): they
describe the program's precondition and postcondition. Postconditions, as we
have been writing them, have the form `[f x] is "...a description of the output
in terms of the input [x]..."`. For example, the specification of a factorial
function could be:
```
(** [fact n] is [n] factorial, i.e,. [n!].
    Requires: [n >= 0]. *)
let rec fact n = ...
```
The postcondition is asserting an equality between the output of the function
and some English description of a computation on the input.  

Equalities are one of the fundamental ways we think about correctness of
functional programs. The absence of mutable state makes it possible to reason
straightforwardly about whether two expressions are equal. It's difficult to do
that in an imperative language, because those expressions might have side
effects that change the state.