# Amortized Analysis

*Under development.*

The *amortized complexity* or *amortized running time* of a sequence
of operations that each have cost \\(T_1, T_2, \ldots, T_n\\), 
is the average cost of each operation: 
\\[
\frac{T_1 + T_2 + ... + T_n}{n}.
\\]
Thus, even if one operation is especially expensive, we could average
that out over a bunch of inexpensive operations.

Applying that idea to a hash table, suppose the table has 8 bindings and 8
buckets.  Then 8 more inserts are made. The first 7 are (on average)
constant-time, but the 8th insert is linear time:  it increases the
load factor to 2, causing a resize, thus causing rehashing of all
previous 15 bindings. The total cost over that series of operations is
therefore the cost of 7+16 inserts. For simplicity, we could grossly
round that up to 16+16 = 32 inserts. So the average cost of each operation 
in the sequence is 32/8 = 4 inserts.

In other words, if we just pretended each insert cost four times its normal
price, the final operation in the sequence would have been "pre-paid" by
the extra price we paid for earlier inserts. And all of them would be
constant-time, since four times a constant is still a constant.

Generalizing from the example above, let's suppose that the load factor
of a table is currently 1.  Suppose a series of insert operations
occurs, and that the length of the series triggers a resize.  Then the
length of the series must be equal to the number of buckets.  Let's
assume the number of buckets is \\(2^n\\).  Then there have been
\\(2^n-1\\) inserts before the resize was triggered, followed by another
\\(2^n + 2^n = 2^{n+1}\\) inserts for the resize and final insert.
That's a total of \\(2^{n+1} + 2^n - 1\\) inserts, which we could
grossly round up to \\(2^{n+2}\\).  Over a series of \\(2^n\\)
operations, that's an average cost of (the equivalent of) 4 inserts per
operation.  So if we just pretend each insert costs four times its
normal price, every operation in the sequence is amortized constant time.

Notice that it is crucial that the array size grows geometrically
(i.e., by doubling). It may be tempting to grow the array by a fixed increment
(e.g., 100 elements at time), but this causes n elements to be rehashed
\\(O(n)\\) times on average, resulting in \\(O(n^2)\\) total insertion time, or
amortized complexity of \\(O(n)\\).