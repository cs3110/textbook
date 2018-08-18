# Summary

Lists are a highly useful built-in data structure in OCaml.  The language
provides a lightweight syntax for building them, rather than requiring
you to use a library.  Accessing parts of a list makes use of pattern matching,
a very powerful feature (as you might expect from its rather lengthy semantics).
We'll see more uses for pattern matching as the course proceeds.

These built-in lists are implemented as singly-linked lists.  That's important
to keep in mind when your needs go beyond small to medium sized lists.
Recursive functions on long lists will take up a lot of stack space,
so tail recursion becomes important.  And if you're attempting to
process really huge lists, you probably don't want linked lists at all,
but instead a data structure that will do a better job of exploiting 
memory locality.

OCaml provides data types for variants (one-of types), tuples and
products (each-of types), and options (maybe types). Pattern matching
can be used to access values of each of those data types. And pattern
matching can be used in let expressions and functions.

Association lists combine lists and tuples to create a lightweight
implementation of dictionaries.

Variants are a powerful language feature.  They are the workhorse
of representing data in a functional language.  OCaml variants actually combine
several theoretically independent language features into one:  sum types, 
product types, recursive types, and parameterized (polymorphic) types.  The result
is an ability to express many kinds of data, including lists, options, trees,
and even exceptions. 

## Terms and concepts

* algebraic data type
* append
* association list
* binary trees as variants
* binding
* branch
* carried data
* catch-all cases
* cons
* constant constructor
* constructor
* copying 
* desugaring
* each-of type
* exception
* exception as variants
* exception packet
* exception pattern
* exception value
* exhaustiveness
* field
* head
* induction
* leaf
* list
* lists as variants
* maybe type
* mutually recursive functions
* natural numbers as variants
* nil
* node
* non-constant constructor
* one-of type
* options
* options as variants
* order of evaluation
* pair
* parameterized variant
* parametric polymorphism
* pattern matching
* prepend
* product type
* record
* recursion
* recursive variant
* sharing
* stack frame
* sum type
* syntactic sugar
* tag
* tail
* tail call
* tail recursion
* test-driven development (TDD)
* triple
* tuple
* type constructor
* type constructor
* type synonym
* variant
* wildcard

## Further reading

* *Introduction to Objective Caml*, chapters 4, 5.2, 5.3, 5.4, 6, 7, 8.1
* *OCaml from the Very Beginning*, chapters 3, 4, 5, 7, 8, 10, 11
* *Real World OCaml*, chapter 3, 5, 6, 7

