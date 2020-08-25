# The Meaning of "Higher Order"

The phrase "higher order" is used throughout logic and computer science,
though not necessarily with a precise or consistent meaning in all
cases.  

In logic, *first-order quantification* refers to the kind of universal
and existential ($$\forall$$ and $$\exists$$) quantifiers that you
see in CS 2800.  These let you quantify over some *domain* of interest,
such as the natural numbers.  But for any given quantification, say
$$\forall x$$, the variable being quantified represents an individual
element of that domain, say the natural number 42.

*Second-order quantification* lets you do something strictly more
powerful, which is to quantify over *properties* of the domain.
Properties are assertions about individual elements, for example, that a
natural number is even, or that it is prime.  In some logics we can
equate properties with sets of individual, for example the set of all
even naturals.  So second-order quantification is often thought of as
quantification over *sets*. You can also think of properties as being
functions that take in an element and return a Boolean indicating
whether the element satisfies the property; this is called the
*characteristic function* of the property.

*Third-order* logic would allow quantification over properties of
properties, and *fourth-order* over properties of properties of
properties, and so forth. *Higher-order logic* refers to all these
logics that are more powerful than first-order logic; though one
interesting result in this area is that all higher-order logics can be
expressed in second-order logic. 

In programming languages, *first-order functions* similarly refer to
functions that operate on individual data elements (e.g., strings, ints,
records, variants, etc.).  Whereas *higher-order function* can operate
on functions, much like higher-order logics can quantify over over
properties (which are like functions).
