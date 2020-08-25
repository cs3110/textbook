# Amortized Analysis

*Under development.*

The *amortized complexity* or *amortized running time* of a sequence
of operations that each have cost $$T_1, T_2, \ldots, T_n$$, 
is the average cost of each operation: 
$$
\frac{T_1 + T_2 + ... + T_n}{n}.
$$
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

Generalizing from the example above, let's suppose that the the number of
buckets currently in a hash table is $$2^n$$, and that the load factor is
currently 1.  Therefore, there are currently $$2^n$$ bindings in the table.
Next:

- A series of $$2^n - 1$$ inserts occurs.  There are now $$2^n + 2^n - 1$$
  bindings in the table.

- One more insert occurs.  That would bring the number of bindings up to
  $$2^n + 2^n$$, which is $$2^{n+1}$$, which would make the load factor
  become 2.  So a resize is necessary before the insert can happen.

- The resize occurs.  That doubles the number of buckets.  All existing $$2^n +
  2^n - 1$$ bindings have to be reinserted.

- The last insert can now occur.

So in total we did:

- $$2^n - 1$$ inserts before the resize

- $$2^n + 2^n - 1$$ inserts during the resize

- 1 insert after the resize

That's a total of $$2^{n+1} + 2^n$$ inserts. which we could grossly round up
to $$2^{n+2}$$.  Over a series of $$2^n$$ operations, that's an average cost
of (the equivalent of) 4 inserts per operation.  So if we just pretend each
insert costs four times its normal price, every operation in the sequence is
amortized constant time.

Notice that it is crucial that the array size grows geometrically
(i.e., by doubling). It may be tempting to grow the array by a fixed increment
(e.g., 100 elements at time), but this causes n elements to be rehashed
$$O(n)$$ times on average, resulting in $$O(n^2)$$ total insertion time, or
amortized complexity of $$O(n)$$.
