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

Functors are an advanced language feature in OCaml that might seem mysterious
at first.  If so, keep in mind:  they're really just a kind of function
that takes a structure as input and returns a structure as output.  The
reason they don't behave quite like normal OCaml functions is that structures
are not first-class values in OCaml:  you can't write regular functions
that take a structure as input or return a structure as output.  But functors
can do just that.

Functors and includes enable code reuse.  The kinds of code reuse 
you learned to achieve in CS 2110 with object-oriented features can
also be achieved with functors and include.  That's not to say that
functors and includes are exactly equivalent to those object-oriented features:
some kinds of code reuse might be easier to achieve with one set of features
than the other.

One way to think about this might be that class extension is a very
limited (but very useful) combination of functors and includes: extending
a class is like writing a functor that takes the base class as input, 
includes it, then adds new functions.  But functors provide more general
capability than class extension, because they can compute arbitrary functions
of their input structure, rather than being limited to just certain 
kinds of extension.

Perhaps the most important idea to get out of studying the OCaml module
system is an appreciation for the aspects of modularity that transcend
any given language:  namespaces, abstraction, and code reuse.  Having
seen those ideas in a couple very different languages, you're equipped
to recognize them more clearly in the next language you learn.

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
* functor
* implementation
* implementer
* include
* information hiding
* interface
* local reasoning
* maintainability
* maps
* modular programming
* modularity
* module
* module type
* namespace
* open
* parameterized structure
* persistant data structure
* representation type
* scope
* sealed
* set representations
* sharing constraints
* signature
* signature matching
* specification
* structure

## Further reading

* *Introduction to Objective Caml*, chapters 11, 12, and 13
* *OCaml from the Very Beginning*, chapter 16
* *Real World OCaml*, chapters 4, 9, and 10
* *Purely Functional Data Structures*, chapters 1 and 2, by Chris Okasaki.
  Available online from the [Cornell Library][okasaki].
* "Design Considerations for ML-Style Module Systems" by Robert Harper and Benjamin
  C. Pierce, chapter 8 of *Advanced Topics in Types and Programming Languages*, ed.
  Benjamin C. Pierce, MIT Press, 2005.  An advanced treatment of the static semantics of
  modules, which we omitted here. Available online from the [Cornell Library][attapl].

[okasaki]: https://newcatalog.library.cornell.edu/catalog/9494445
[attapl]: https://newcatalog.library.cornell.edu/catalog/6176852

