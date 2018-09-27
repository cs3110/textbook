# Summary

The stream data structure can be used to represent an infinite
mathematical sequence, but with only a finite amount of memory.
That's because the values of the sequence are not produced 
until they are specifically requested.  The thunks used in streams
are used to pause evaluation until such a request is made.
Thunks are a way of implementing lazy evaluation, which OCaml
also has available.  The advantage of OCaml's built-in implementation
is that it can memoize results, avoiding the need for recomputation.

## Terms and concepts

* caching
* cycle
* delayed evaluation
* eager
* force
* infinite data structure
* lazy
* memoization
* thunk
* recursive values
* stream
* strict

## Further reading

* *More OCaml: Algorithms, Methods, and Diversions*, chapter 2, by
  John Whitington.  This book is a sequel to *OCaml from the Very Beginning*.
