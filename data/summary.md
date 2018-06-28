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

## Terms and concepts

* append
* association list
* binding
* branch
* cons
* constructor
* copying 
* desugaring
* each-of type
* exhaustiveness
* field
* head
* induction
* list
* maybe type
* nil
* one-of type
* options
* pair
* pattern matching
* prepend
* product type
* record
* recursion
* sharing
* stack frame
* sum type
* syntactic sugar
* tail
* tail call
* tail recursion
* triple
* tuple
* type constructor
* variant
* wildcard

## Further reading

* *Introduction to Objective Caml*, chapters 4, 5.2, 5.3, 5.4, 8.1
* *OCaml from the Very Beginning*, chapters 3, 4, 5, 8
* *Real World OCaml*, chapter 3, 5

