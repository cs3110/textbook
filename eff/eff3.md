# Algorithms and Efficiency, Attempt 3

Let's review.  Our first attempt at defining efficiency was:

**Attempt 1:** An algorithm is efficient if, when implemented, it runs in a
small amount of time on particular input instances.

By replacing time with steps, particular instances with input size, and small
with polynomial, we improved that to:

**Attempt 2:** An algorithm is efficient if its maximum number of execution
steps is polynomial in the size of its input.

And that's really a pretty good definition.  But using Big-Oh notation to
make it a little more concrete, we can produce our third and final attempt:

**Attempt 3:** An algorithm is efficient if its worst-case running time
on input size $$n$$ is $$O(n^d)$$ for some constant $$d$$.

By "worst-case running time" we mean the same thing as "maximum number of
execution steps", just expressed in different and probably more common words.
The worst-case is when execution takes the longest.  "Time" is a common
euphamism here for execution steps, and is used to emphasize we're thinking
about how long a computation takes.

*Space* is the most common other feature of efficiency to consider. Algorithms
can be more or less efficient at requiring constant or linear space, for
example. You're already familiar with that from tail recursion and lists in
OCaml.