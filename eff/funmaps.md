# Functional Maps

As we've now seen, hash tables are an efficient data structure for implementing
a map ADT. They offer amortized, expected constant-time performance&mdash;which
is a subtle guarantee because of those "amortized" and "expected" qualifiers we
have to add. Hash tables also require mutability to implement.  As functional
programmers, we prefer to avoid mutability when possible.

So, let's investigate how to implement functional maps.  One of the best
data structures for that is the *red-black tree*, which is a kind of balanced
binary search tree that offers worst-case logarithmic performance.  So 
on one hand the performance is somewhat worse than hash tables (logarithmic
vs. constant), but on the other hand we don't have to qualify the performance
with words like "amortized" and "expected".  Logarithmic is actually still
plenty efficient for even very large workloads.  And, we get to avoid
mutability!
