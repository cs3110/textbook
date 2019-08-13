# Refs: Syntax and Semantics

The semantics of refs is based on *locations* in memory.
Locations are values that can be passed to and returned from functions.
But unlike other values (e.g., integers, variants), there is no way to directly
write a location in an OCaml program.  That's different than languages like C,
in which programmers can directly write memory addresses and do arithmetic on pointers.
C programmers want that kind of low-level access to do things like interface with
hardware and build operating systems.  Higher-level programmers are willing to
forego it to get *memory safety*.  That's a hard term to define,
but according to [Hicks 2014][memory-safety-hicks] it intuitively means that 

* pointers are only created in a safe way that defines their legal memory region,

* pointers can only be dereferenced if they point to their allotted memory region,

* that region is (still) defined. 

[memory-safety-hicks]: http://www.pl-enthusiast.net/2014/07/21/memory-safety/


## Syntax and Dynamic Semantics

**Syntax.** 

* Ref creation: `ref e`

* Ref assignment: `e1 := e2`

* Dereference: `!e`

**Dynamic semantics.** 

* To evaluate `ref e`, 
  
  - Evaluate `e` to a value `v`

  - Allocate a new location `loc` in memory to hold `v`

  - Store `v` in `loc`

  - Return `loc`
  
* To evaluate `e1 := e2`,
 
  - Evaluate `e2` to a value `v`, and `e1` to a location `loc`.  
  
  - Store `v` in `loc`.
  
  - Return `()`, i.e., unit.
  
* To evaluate `!e`,

  - Evaluate `e` to a location `loc`.
  
  - Return the contents of `loc`.
  
## Static Semantics

We have a new type constructor, `ref`, such that
`t ref` is a type for any type `t`.  Note that the `ref` keyword is used
in two ways:  as a type constructor, and as an expression that constructs refs.

* `ref e : t ref` if  `e : t`.

* `e1 := e2 : unit` if `e1 : t ref` and `e2 : t`.

* `!e : t` if `e : t ref`.
