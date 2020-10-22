# Algebraic Specification

Now that we are proficient at proofs about functions, we can tackle a bigger
challenge:  proving the correctness of a data structure, such as a stack,
queue, or set.

Correctness proofs always need specifications.  In proving the correctness of
iterative factorial, we used recursive factorial as a specification.  By
analogy, we could provide two implementations of a data structure---one simple,
the other complex and efficient---and prove that the two are equivalent.  
That would require us to introduce ways to translate between the two
implementations. For example, we could prove the correctness of a dictionary
implemented as a red-black tree relative to an implementation as an association
list, by defining functions to convert trees to lists.  Such an approach is
certainly valid, but it doesn't lead to new ideas about verification for us
to study.

Instead, we will pursue a different approach based on *equational
specifications*, aka *algebraic specifications*.  The idea with these is to

- define the types of the data structure operations, and 
- to write a set of equations that define how the operations interact with one
  another.

The reason the word "algebra" shows up here is (in part) that this
type-and-equation based approach is something we learned in high-school algebra.
For example, here is a specification for some operators:
```
0 : int
1 : int
- : int -> int
+ : int -> int -> int
* : int -> int -> int

(a + b) + c = a + (b + c)
a + b = b + a
a + 0 = a
a + (-a) = 0
(a * b) * c = a * (b * c)
a * b = b * a
a * 1 = a
a * 0 = 0
a * (b + c) = a * b + a * c
```
The types of those operators, and the associated equations, are facts you
learned when studying algebra.  (And if you take an *abstract algebra* course in
college, you will learn even more about them.)

Our goal is now to write similar specifications for data structures, and
use them to reason about the correctness of implementations.
