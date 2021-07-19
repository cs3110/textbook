# Summary

Documentation and testing are crucial to establishing the truth of what a
correct program does. Documentation communicates to other humans the intent of
the programmer. Testing communicates evidence about the success of the
programmer.

Good documentation provides several pieces:  a summary, preconditions,
postconditions (including errors), and examples.  Documentation is written
for two different audiences, clients and maintainers.  The latter needs
to know about abstraction functions and representation invariants.

Testing methodologies include black-box, glass-box, and randomized tests. These
are complementary, not orthogonal, approaches to developing correct code.

Formal methods is an important link between mathematics and computer science. We
can use techniques from discrete math, such as induction, to prove the
correctness of functional programs. Equational reasoning makes the proofs
relatively pleasant.

Proving the correctness of imperative programs can be more challenging, because
of the need to reason about mutable state. That can break equational reasoning.
Instead, _Hoare logic_, named for Tony Hoare, is a common formal method for
imperative programs. Dijkstra's _weakest precondition_ calculus is another.

## Terms and Concepts

* abstract value
* abstraction by specification
* abstraction function
* algebraic specification
* asserting
* associative
* base case
* black box
* boundary case
* bug
* canonical form
* client
* code inspection
* code review
* code walkthrough
* comments
* commutative
* commutative diagram
* concrete value
* conditional compilation
* consumer
* correctness
* data abstraction
* debugging by scientific method
* defensive programming
* equation
* equational reasoning
* example clause
* extensionality
* failure
* fault
* formal methods
* formal methods
* generator
* glass box
* identity
* implementer
* induction
* induction hypothesis
* induction principle
* inductive case
* inputs for classes of output
* inputs that satisfy precondition
* inputs that trigger exceptions
* iterative
* locality
* manipulator
* many to one
* minimal test case
* modifiability
* natural numbers
* pair programming
* partial
* partial correctness
* partial function
* path coverage
* paths through implementation
* paths through specification
* postcondition
* postcondition
* precondition
* precondition
* producer
* query
* raises clause
* randomized testing
* regression testing
* rely
* rep ok
* representation invariant
* representation type
* representative inputs
* requires clause
* returns clause
* satisfaction
* social methods
* specification
* specification
* testing
* total correctness
* total function
* typical input
* validation
* verification
* well-founded

## Further Reading

* *Program Development in Java: Abstraction, Specification, and
  Object-Oriented Design*, chapters 3, 5, and 9, by Barbara
  Liskov with John Guttag.

- *The Functional Approach to Programming*, section 3.4.  Guy Cousineau and
  Michel Mauny. Cambridge, 1998.

- *ML for the Working Programmer*, second edition, chapter 6.  L.C. Paulson.
  Cambridge, 1996.

- *Thinking Functionally with Haskell*, chapter 6.  Richard Bird.  Cambridge,
  2015.

- *Software Foundations*, volume 1, chapters Basic, Induction, Lists, Poly.
  Benjamin Pierce et al. https://softwarefoundations.cis.upenn.edu/

- "Algebraic Specifications", Robert McCloskey,
  https://www.cs.scranton.edu/~mccloske/courses/se507/alg_specs_lec.html.

- *Software Engineering: Theory and Practice*, third edition, section 4.5.
  Shari Lawrence Pfleeger and Joanne M. Atlee.  Prentice Hall, 2006.

- "Algebraic Semantics", chapter 12 of *Formal Syntax and Semantics of
  Programming Languages*, Kenneth Slonneger and Barry L. Kurtz, Addison-Wesley,
  1995.

- "Algebraic Semantics", Muffy Thomas.  Chapter 6 in *Programming Language
  Syntax and Semantics*, David Watt, Prentice Hall, 1991.

- *Fundamentals of Algebraic Specification 1: Equations and Initial Semantics*.
  H. Ehrig and B. Mahr.  Springer-Verlag, 1985.

## Acknowledgments

Our treatment of formal methods is inspired by and indebted to course materials
for Princeton COS 326 by David Walker et al.

Our example algebraic specifications are based on McCloskey's. The terminology
of "generator", "manipulator", and "query" is based on Pfleeger and Atlee.

Many of our exercises on formal methods are inspired by *Software Foundations*,
volume 1.