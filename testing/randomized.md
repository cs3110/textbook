# Randomized Testing

*Randomized testing* aka *fuzz testing* is the process of generating
random inputs and feeding them to a program or a function to see whether
the program behaves correctly. The immediate issue is how to determine
what the correct output is for a given input.  If a *reference implementation*
is available&mdash;that is, an implementation that is believed to be correct
but in some other way does not suffice (e.g., its performance is too slow,
or it is in a different language)&mdash;then the outputs of the two
implementations can be compared.  Otherwise, perhaps some *property*
of the output could be checked.  For example, 

* "not crashing" is a property of interest in user interfaces;

* adding \\(n\\) elements to a data collection
  then removing those elements, and ending up with an empty collection,
  is a property of interest in data structures; and
  
* encrypting a string under a key then decrypting it under that key
  and getting back the original string is a property of interest
  in an encryption scheme like Enigma.

Randomized testing is an incredibly powerful technique.  It is often
used in testing programs for security vulnerabilities.  The 
[`qcheck` package][qcheck] for OCaml supports randomized testing.
We'll look at it, next, after we discuss random number generation.

[qcheck]: https://github.com/c-cube/qcheck
