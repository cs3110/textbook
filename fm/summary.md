# Summary

This chapter has helped us discover an important link between mathematics
and computer science.  We can use techniques from discrete math, such
as induction, to prove the correctness of functional programs.  Equational
reasoning makes the proofs relatively pleasant.

Proving the correctness of imperative programs can be more challenging,
because of the need to reason about mutable state.  That can break equational
reasoning.  Instead, _Hoare logic_, named for Tony Hoare, is a common
formal method for imperative programs.  Dijkstra's _weakest precondition_
calculus is another.

## Terms and concepts

* algebraic specification
* associative
* base case
* canonical form
* correctness
* commutative
* equation
* equational reasoning
* extensionality
* formal methods
* generator
* identity
* induction
* inductive case
* induction hypothesis
* induction principle
* iterative
* manipulator
* natural numbers
* partial correctness
* postcondition
* precondition
* query
* specification
* total correctness
* verification
* well-founded

## Further reading

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

## Acknowledgment

Our treatment of formal methods is inspired by and indebted to course materials
for Princeton COS 326 by David Walker et al.

Our example algebraic specifications are based on McCloskey's.  The terminology
of "generator", "manipulator", and "query" is based on Pfleeger and Atlee.