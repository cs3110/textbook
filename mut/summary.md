# Summary

Mutable data types make programs harder to reason about.  For
example, before refs, we didn't have to worry about aliasing in OCaml.  
But mutability does have its uses.  I/O is fundamentally about mutation.
And some data structures (like arrays and hash tables) cannot be 
implemented as efficiently without mutability.

Mutability thus offers great power, but with great power comes great
responsibility.  Try not to abuse your new-found power!

## Terms and concepts

* address
* alias
* array
* assignment
* dereference
* determinstic
* immutable
* index
* loop
* memory safety
* mutable
* mutable field
* nondeterministic
* physical equality
* pointer
* pure
* ref
* ref cell
* reference
* sequencing
* structural equality

## Further reading

* *Introduction to Objective Caml*, chapters 7 and 8.

* *OCaml from the Very Beginning*, chapter 13.

* *Real World OCaml*, chapters 8.

