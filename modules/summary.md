# Summary

The OCaml module system provides mechanisms for modularity that provide the
similar capabilities as mechanisms you will have seen in other languages. 
But seeing those mechanisms appear in different ways is hopefully helping
you understand them better.  OCaml abstract types and signatures, for example, provide a
mechanism for abstraction that resembles Java visibility modifiers and interfaces.
Seeing the same idea embodied in two different languages, but expressed in 
rather different ways, will hopefully help you recognize that idea when you
encounter it in other languages in the future.

Moreover, the idea that a type could be abstract is a foundational notion in
programming language design.  The OCaml module system makes that idea brutally apparent.
Other languages like Java obscure it a bit by coupling it together with many
other features all at once.  There's a sense in which every Java class 
implicitly defines an abstract type (actually, four abstract types that are
related by subtyping, one for each visibility modifier [`public`, `protected`, `private`,
and `default`]), and all the methods of the class are functions on that abstract type.  

Using the OCaml module system can feel a bit backwards at first, though, because
you pass values of an abstract type into functions, rather than invoking methods on 
objects.  Don't worry if that's true for you; you'll get used to it quickly.

## Terms and concepts

* abstract type
* abstraction
* client
* code reuse
* compilation unit
* declaration
* definition
* encapsulation
* ephemeral data structure
* functional data structure
* implementation
* implementer
* information hiding
* interface
* local reasoning
* modular programming
* module
* module type
* namespace
* open
* persistant data structure
* representation type
* scope
* sealed
* sharing constraints
* signature
* signature matching
* specification
* structure

## Further reading

* *Introduction to Objective Caml*, chapters 11 and 12
* *OCaml from the Very Beginning*, chapter 16
* *Real World OCaml*, chapters 4 and 10
* *Purely Functional Data Structures*, chapters 1 and 2, by Chris Okasaki.
  Available online from the [Cornell Library][okasaki].
* "Design Considerations for ML-Style Module Systems" by Robert Harper and Benjamin
  C. Pierce, chapter 8 of *Advanced Topics in Types and Programming Languages*, ed.
  Benjamin C. Pierce, MIT Press, 2005.  An advanced treatment of the static semantics of
  modules, which we omitted here. Available online from the [Cornell Library][attapl].


[okasaki]: https://newcatalog.library.cornell.edu/catalog/9494445
[attapl]: https://newcatalog.library.cornell.edu/catalog/6176852

