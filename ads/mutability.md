# Mutability

OCaml is not a *pure* language: it does admit side effects.  We have
seen that already with I/O, especially printing.  But up till now we
have limited ourself to the subset of the language that is *immutable*:
values could not change.  

Mutability is neither good nor bad.  It enables new functionality that
we couldn't implement (at least not easily) before, and it enables
us to create certain data structures that are asymptotically more
efficient than their purely functional analogues.  But mutability
does make code more difficult to reason about, hence it is a source
of many faults in code.  One reason for that might be that humans
are not good at thinking about change.  With immutable values,
we're guaranteed that any fact we might establish about them
can never change.  But with mutable values, that's no longer true.
"Change is hard," as they say.

We cover mutable data types in the "Advanced Data Structures" section of
this book because they are, in fact, harder to reason about.  For
example, before refs, we didn't have to worry about aliasing in OCaml.  
But mutability does have its uses.  I/O is fundamentally about mutation.
And some data structures (like arrays and hash tables) cannot be 
implemented as efficiently without mutability.

Mutability thus offers great power, but with great power comes great
responsibility.  Try not to abuse your new-found power!