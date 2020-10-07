# Amortized Analysis of Hash Tables

"Amortization" is a financial term.  One of its meanings is to pay off a debt
over time.  In algorithmic analysis, we use it to refer to paying off the cost
of an expensive operation by inflating the cost of inexpensive operations.
In effect, we pre-pay the cost of a later expensive operation by adding some
additional cost to earlier cheap operations.

The *amortized complexity* or *amortized running time* of a sequence of
operations that each have cost $$T_1, T_2, \ldots, T_n$$, is just the average
cost of each operation:

$$
\frac{T_1 + T_2 + ... + T_n}{n}.
$$

Thus, even if one operation is especially expensive, we could average that out
over a bunch of inexpensive operations.

Applying that idea to a hash table, suppose the table has 8 bindings and 8
buckets. Then 8 more inserts are made. The first 7 are (expected) constant-time,
but the 8th insert is linear time: it increases the load factor to 2, causing a
resize, thus causing rehashing of all 16 bindings into a new table. The total
cost over that series of operations is therefore the cost of 8+16 inserts. For
simplicity of calculation, we could grossly round that up to 16+16 = 32 inserts.
So the average cost of each operation in the sequence is 32/8 = 4 inserts.

In other words, if we just pretended each insert cost four times its normal
price, the final operation in the sequence would have been "pre-paid" by the
extra price we paid for earlier inserts. And all of them would be constant-time,
since four times a constant is still a constant.

Generalizing from the example above, let's suppose that the the number of
buckets currently in a hash table is $$2^n$$, and that the load factor is
currently 1.  Therefore, there are currently $$2^n$$ bindings in the table.
Next:

- A series of $$2^n - 1$$ inserts occurs.  There are now $$2^n + 2^n - 1$$
  bindings in the table.

- One more insert occurs.  That brings the number of bindings up to
  $$2^n + 2^n$$, which is $$2^{n+1}$$.  But the number of buckets is $$2^n$$,
  so the the load factor just reached 2.  A resize is necessary.

- The resize occurs.  That doubles the number of buckets.  All
  $$2^{n+1}$$ bindings have to be reinserted into the new table, which
  is of size $$2^{n+1}$$.  The load factor is back down to 1.

So in total we did $$2^n + 2^{n+1}$$ inserts. which we could grossly round up to
$$2^{n+2}$$. Over a series of $$2^n$$ insert operations, that's an average cost
of $$\frac{2^{n+2}}{2^n}$$, which equals 4. So if we just pretend each insert
costs four times its normal price, every operation in the sequence is amortized
(and expected) constant time.

## Doubling vs. Constant-size Increasing

Notice that it is crucial that the array size grows by doubling (or at least
geometrically). A bad mistake would be to instead grow the array by a fixed
increment&mdash;for example, 100 buckets at time. Then we'd be in real trouble
as the number of bindings continued to grow:

- Start with 100 buckets and 100 bindings.  The load factor is 1.
- **Round 1.**
  Insert 100 bindings.  There are now 200 bindings and 100 buckets.  The
  load factor is 2.
- Increase the number of buckets by 100 and rehash. That's 200 more insertions.
  The load factor is back down to 1.
- The average cost of each insert is so far just 3x the cost of an actual
  insert (100+200 insertions / 100 bindings inserted).
  So far so good.
- **Round 2.**
  Insert 200 more bindings.  There are now 400 bindings and 200 buckets.
  The load factor is 2.
- Increase the number of buckets **by 100** and rehash.  That's 400 more
  insertions.  There are now 400 bindings and 300 buckets.
  The load factor is 400/300 = 4/3, not 1.
- The average cost of each insert is now 100+200+200+400 / 300 = 3.
  That's still okay.
- **Round 3.**
  Insert 200 more bindings.  There are now 600 bindings and 300 buckets.
  The load factor is 2.
- Increase the number of buckets **by 100** and rehash.  That's 600 more
  insertions.  There are now 600 bindings and 400 buckets.
  The load factor is 3/2, not 1.
- The average cost of each insert is now 100+200+200+400+200+600 / 500 = 3.2.
  It's going up.
- **Round 4.**
  Insert 200 more bindings.  There are now 800 bindings and 400 buckets.
  The load factor is 2.
- Increase the number of buckets **by 100** and rehash. That's 800 more
  insertions.  There are now 800 bindings and 500 buckets.
  The load factor is 8/5, not 1.
- The average cost of each insert is now 100+200+200+400+200+600+200+800 / 700
  = 3.7.  It's continuing to go up, not staying constant.

After $$k$$ rounds we have $$200k$$ bindings and $$100k$$ buckets. 
We have called `insert` to insert $$100+200k$$ bindings, but all the rehashing has
caused us to do $$100+200(k-1)+\sum_{i=1}^{k} 200i$$ actual insertions.
That last term is the real problem.  It's quadratic:  

$$
\sum_{i=1}^{k} 200i \quad = \quad \frac{200k (200 (k+1))}{2} \quad = \quad 20,000 (k^2 + k)
$$

So over a series of $$n$$ calls to `insert`, we do $$O(n^2)$$ actual inserts.
That makes the amortized cost of `insert` be $$O(n)$$, which is linear! Not
constant.

That's why it's so important to double the size of the array at each rehash.
It's what gives us the amortized constant-time performance.
