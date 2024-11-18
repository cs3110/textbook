# Amortized Analysis

{{ video_embed | replace("%%VID%%", "1fPx0hcXlRg")}}

Our analysis of the efficiency of hash table operations concluded that `find`
runs in expected constant time, where the modifier "expected" is needed to
express the fact the performance is on average and depends on the hash function
satisfying certain properties.

We also concluded that `insert` would usually run in expected constant time, but
that in the worst case it would require linear time because of needing to rehash
the entire table. That kind of defeats the goal of a hash table, which is to
offer constant-time performance, or at least as close to it as we can get.

It turns out there is another way of looking at this analysis that allows us to
conclude that `insert` does have "amortized" expected constant time
performance&mdash;that is, for excusing the occasional worst-case linear
performance. Right away, we have to acknowledge this technique is just a change
in perspective. We're not going to change the underlying algorithms. The
`insert` algorithm will still have worst-case linear performance. That's a fact.

But the change in perspective we now undertake is to recognize that if it's very
rare for `insert` to require linear time, then maybe we can "spread out" that
cost over all the other calls to `insert`. It's a creative accounting trick!

**Sushi vs. Ramen.** Let's amuse ourselves with a real-world example for a
moment. Suppose that you have $20 to spend on lunches for the week. You like to
eat sushi, but you can't afford to have sushi every day. So instead you eat as
follows:

- Monday: $1 ramen
- Tuesday: $1 ramen
- Wednesday: $1 ramen
- Thursday: $1 ramen
- Friday: $16 sushi

Most of the time, your lunch was cheap. On a rare occasion, it was expensive. So
you could look at it in one of two ways:

- My worst-case lunch cost was $16.
- My average lunch cost was $4.

Both are true statements, but maybe the latter is more helpful in understanding
your spending habits.

**Back to Hash Tables.** It's the same with hash tables. Even though `insert` is
occasionally expensive, it's so rarely expensive that the average cost of an
operation is actually constant time! But, we need to do more complicated math
(or more complicated than our lunch budgeting anyway) to actually demonstrate
that's true.

## Amortized Analysis of Hash Tables

{{ video_embed | replace("%%VID%%", "GwnYcPmn8PQ")}}

"Amortization" is a financial term. One of its meanings is to pay off a debt
over time. In algorithmic analysis, we use it to refer to paying off the cost of
an expensive operation by inflating the cost of inexpensive operations. In
effect, we pre-pay the cost of a later expensive operation by adding some
additional cost to earlier cheap operations.

The *amortized complexity* or *amortized running time* of a sequence of
operations that each have cost $T_1, T_2, \ldots, T_n$, is just the average cost
of each operation:

$$
\frac{T_1 + T_2 + \dotsb + T_n}{n}.
$$

Thus, even if one operation is especially expensive, we could average that out
over a bunch of inexpensive operations.

{{ video_embed | replace("%%VID%%", "eKzgddLniSw")}}

Applying that idea to a hash table, let's analyze what happens when an insert
operation causes an expensive resize. Assume the table resizes when the load
factor reaches 2. (That is more proactive than OCaml's `Hashtbl`, which resizes
when the load factor *exceeds* 2. It doesn't really matter which choice we make,
but resize-on-reaching will simplify our analysis a little.)

Suppose the table has 8 bindings and 8 buckets. Then 8 more inserts are made.
The first 7 are (expected) constant-time, but the 8th insert is linear time: it
increases the load factor to 2, causing a resize, thus causing rehashing of all
16 bindings into a new table. The total cost over that series of operations is
therefore: the cost of 8 inserts into the old table, plus the cost of allocating 
a new 16-element table, plus the cost of 16 inserts into the new table.
That is, a total cost of 40.
So the average cost of each operation in the sequence is 40/8 = 5 inserts.

In other words, if we just pretended each insert cost five times its normal
price, the final operation in the sequence would have been "pre-paid" by the
extra price we paid for earlier inserts. And all of them would be constant-time,
since five times a constant is still a constant.

Generalizing from the example above, let's suppose that the number of buckets
currently in a hash table is $2^n$, and that the load factor is currently 1.
Therefore, there are currently $2^n$ bindings in the table. Next:

- A series of $2^n - 1$ inserts occurs. There are now $2^n + 2^n - 1$ bindings
  in the table.

- One more insert occurs. That brings the number of bindings up to $2^n + 2^n$,
  which is $2^{n+1}$. But the number of buckets is $2^n$, so the load factor
  just reached 2. A resize is necessary.

- The resize occurs. It costs $2^{n+1}$ to allocate memory for the new table.
  That doubles the number of buckets. All $2^{n+1}$ bindings
  have to be reinserted into the new table, which is of size $2^{n+1}$. The load
  factor is back down to 1.

So in total we did $2^n + 2^{n+1}$ inserts, which included $2^n$ inserts of
bindings and $2^{n+1}$ re-insertions after the resize. We also incurred the 
cost of allocating a new table of size $2^{n+1}$ in memory, and that cost is $2^{n+1}$.

Over a series of $2^n$ insert operations, that's
an average cost of $\frac{2^n + 2^{n+1} + 2^{n+1}}{2^n}$, which equals 5. 
So if we just pretend each insert costs five times its normal price, 
every operation in the sequence is amortized (and expected) constant time.

**Doubling vs. Constant-size Increasing.** Notice that it is crucial that the
array size grows by doubling (or at least geometrically). A bad mistake would be
to instead grow the array by a fixed increment&mdash;for example, 100 buckets at
time. Then we'd be in real trouble as the number of bindings continued to grow:

- Start with 100 buckets and 100 bindings.  The load factor is 1.

- **Round 1.** Insert 100 bindings. There are now 200 bindings and 100 buckets.
  The load factor is 2.

- Increase the number of buckets by 100 and rehash. That's 200 more insertions.
  The load factor is back down to 1.

- The average cost of each insert is so far just 3x the cost of an actual insert
  (100+200 insertions / 100 bindings inserted). So far so good.

- **Round 2.** Insert 200 more bindings. There are now 400 bindings and 200
  buckets. The load factor is 2.

- Increase the number of buckets **by 100** and rehash. That's 400 more
  insertions. There are now 400 bindings and 300 buckets. The load factor is
  400/300 = 4/3, not 1.

- The average cost of each insert is now (100+200+200+400) / 300 = 3. That's
  still okay.

- **Round 3.** Insert 200 more bindings. There are now 600 bindings and 300
  buckets. The load factor is 2.

- Increase the number of buckets **by 100** and rehash. That's 600 more
  insertions. There are now 600 bindings and 400 buckets. The load factor is
  3/2, not 1.

- The average cost of each insert is now (100+200+200+400+200+600) / 500 = 3.4.
  It's going up.

- **Round 4.** Insert 200 more bindings. There are now 800 bindings and 400
  buckets. The load factor is 2.

- Increase the number of buckets **by 100** and rehash. That's 800 more
  insertions. There are now 800 bindings and 500 buckets. The load factor is
  8/5, not 1.

- The average cost of each insert is now (100+200+200+400+200+600+200+800) / 700
  = 3.9. It's continuing to go up, not staying constant.

After $k$ rounds we have $200k$ bindings and $100(k+1)$ buckets. We have called
`insert` to insert $100+200(k-1)$ bindings, but all the rehashing has caused us to
do $100+200(k-1)+\sum_{i=1}^{k} 200i$ actual insertions. That last term is the
real problem. It's quadratic:

$$
\sum_{i=1}^{k} 200i \quad = \quad 200 \sum_{i=1}^k i = \quad 200 \frac{k(k+1)}{2} \quad = \quad 100 (k^2 + k) .
$$

So over a series of $n$ calls to `insert`, we do $O(n^2)$ actual inserts. That
makes the amortized cost of `insert` be $O(n)$, which is linear! Not constant.

That's why it's so important to double the size of the array at each rehash.
It's what gives us the amortized constant-time performance.

## Amortized Analysis of Batched Queues

{{ video_embed | replace("%%VID%%", "7OV9iKT0Huw")}}

The implementation of [batched queues][bq] with two lists was in a way more
efficient than the implementation with just one list, because it managed to
achieve a constant time `enqueue` operation. But, that came at the tradeoff of
making the `dequeue` operation sometimes take more than constant time: whenever
the outbox became empty, the inbox had to be reversed, which required an
additional linear-time operation.

[bq]: ../modules/functional_data_structures

As we observed then, the reversal is relatively rare. It happens only when the
outbox gets exhausted. Amortized analysis gives us a way to account for that. We
can actually show that the `dequeue` operation is amortized constant time.

To keep the analysis simple at first, let's assume the queue starts off with
exactly one element `1` already enqueued, and that we do three `enqueue`
operations of `2`, `3`, then `4`, followed by a single `dequeue`. The single
initial element would end up in the outbox. All three `enqueue` operations would
cons an element onto the inbox. So just before the `dequeue`, the queue looks
like:

```ocaml
{o = [1]; i = [4; 3; 2]}
```

and after the `dequeue`:

```ocaml
{o = [2; 3; 4]; i = []}
```

It required

- 3 cons operations to do the 3 enqueues, and

- another 3 cons operations to finish the dequeue by reversing the list.

That's a total of 6 cons operations to do the 4 `enqueue` and `dequeue`
operations. The average cost is therefore 1.5 cons operations per queue
operation. There were other pattern matching operations and record
constructions, but those all took only constant time, so we'll ignore them.

What about a more complicated situation, where there are `enqueues` and
`dequeues` interspersed with one another? Trying to take averages over the
series is going to be tricky to analyze. But, inspired by our analysis of hash
tables, suppose we pretend that the cost of each `enqueue` is twice its actual
cost, as measured in cons operations? Then at the time an element is enqueued,
we could "prepay" the later cost that will be incurred when that element is
cons'd onto the reversed list.

The `enqueue` operation is still constant time, because even though we're now
pretending its cost is 2 instead of 1, it's still the case that 2 is a constant.
And the `dequeue` operation is amortized constant time:

- If `dequeue` doesn't need to reverse the inbox, it really does just constant
  work, and

- If `dequeue` does need to reverse an inbox with $n$ elements, it already
  has $n$ units of work "saved up" from each of the enqueues of those $n$
  elements.

So if we just pretend each enqueue costs twice its normal price, every operation
in a sequence is amortized constant time. Is this just a bookkeeping trick?
Absolutely. But it also reveals the deeper truth that on average we get
constant-time performance, even though some operations might rarely have
worst-case linear-time performance.

## Bankers and Physicists

{{ video_embed | replace("%%VID%%", "-846PptyO7Q")}}

Conceptually, amortized analysis can be understood in three ways:

1. Taking the average cost over a series of operations. This is what we've done
   so far.

2. Keeping a "bank account" at each individual element of a data structure. Some
   operations deposit credits, and others withdraw them. The goal is for account
   totals to never be negative. The amortized cost of any operation is the
   actual cost, plus any credits deposited, minus any credits spent. So if an
   operation actually costs $n$ but spends $n-1$ credits, then its amortized
   cost is just $1$. This is called the *banker's method* of amortized analysis.

3. Regarding the entire data structure as having an amount of "potential energy"
   stored up. Some operations increase the energy, some decrease it. The energy
   should never be negative. The amortized cost of any operation is its actual
   cost, plus the change in potential energy. So if an operation actually costs
   $n$, and before the operation the potential energy is $n$, and after the
   operation the potential energy is $0$, then the amortized cost is $n + (0 -
   n)$, which is just $0$. This is called the *physicist's method* of amortized
   analysis.

{{ video_embed | replace("%%VID%%", "ICT_TfQUa8w")}}

The banker's and physicist's methods can be easier to use in many situations
than a complicated analysis of a series of operations. Let's revisit our
examples so far to illustrate their use:

- **Banker's method, hash tables:** The table starts off empty. When a binding
  is added to the table, save up 1 credit in its account. When a rehash becomes
  necessary, every binding is guaranteed to have 1 credit. Use that credit to
  pay for the rehash. Now all bindings have 0 credits. From now on, when a
  binding is added to the table, save up 1 credit in its account and 1 credit in
  the account of any one of the bindings that has 0 credits. At the time the
  next rehash becomes necessary, the number of bindings has doubled. But since
  we've saved 2 credits at each insertion, every binding now has 1 credit in its
  account again. So we can pay for the rehash. The accounts never go negative,
  because they always have either 0 or 1 credit.

- **Banker's method, batched queues:** When an element is added to the queue,
  save up 1 credit in its account. When the inbox must be reversed, use the
  credit in each element to pay for the cons onto the outbox. Since elements
  enter at the inbox and transition at most once to the outbox, every element
  will have 0 or 1 credits. So the accounts never go negative.

- **Physicist's method, hash tables:** At first, define the potential energy of
  the table to be the number of bindings inserted. That energy will therefore
  never be negative. Each insertion increases the energy by 1 unit. When the
  first rehash is needed after inserting $n$ bindings, the potential energy is
  $n$. The potential goes back down to $0$ at the rehash. So the actual cost is
  $n$, but the change in potential is $n$, which makes the amortized cost $0$,
  or constant. From now on, define the potential energy to be twice the number
  of bindings inserted since the last rehash. Again, the energy will never be
  negative. Each insertion increases the energy by 2 units. When the next rehash
  is needed after inserting $n$ bindings, there will be $2n$ bindings that need
  to be rehashed. Again, the amortized cost will be constant, because the actual
  cost of $2n$ re-insertions is offset by the $2n$ change in potential.

- **Physicist's method, batched queues:** Define the potential energy of the
  queue to be the length of the inbox. It therefore will never be negative. When
  a `dequeue` has to reverse an inbox of length $n$, there is an actual cost of
  $n$ but a change in potential of $n$ too, which offsets the cost and makes it
  constant.

The two methods are equivalent in their analytical power:

- To convert a banker's analysis into a physicist's, just make the potential be
  the sum of all the credits in the individual accounts.

- To convert a physicist's analysis into a banker's, just designate one
  distinguished element of the data structure to be the only one that will ever
  hold any credits, and have each operation deposit or withdraw the change in
  potential into that element's account.

So, the choice of which to use really just depends on which is easier for the
data structure being analyzed, or which is easier for you to wrap your head
around. You might find one or the other of the methods easier to understand for
the data structures above, and your friend might have a different opinion.

## Amortized Analysis and Persistence

Amortized analysis breaks down as a technique when data structures are used
persistently. For example, suppose we have a batched queue `q` into which we've
inserted $n+1$ elements. One element will be in the outbox, and the other $n$
will be in the inbox. Now we do the following:

```ocaml
# let q1 = dequeue q
# let q2 = dequeue q
...
# let qn = dequeue q
```

Each one of those $n$ `dequeue` operations requires an actual cost of $O(n)$ to
reverse the inbox. So the entire series has an actual cost of $O(n^2)$. But
the amortized analysis techniques only apply to the first `dequeue`. After that,
all the accounts are empty (banker's method), or the potential is zero
(physicist's), which means the remaining operations can't use them to pay for
the expensive list reversal. The total cost of the series is therefore $O(n^2 -
n)$, which is $O(n^2)$.

The problem with persistence is that it violates the assumption built-in to
amortized analysis that credits (or energy units) are spent only once. Every
persistent copy of the data structure instead tries to spend them itself, not
being aware of all the other copies.

There are more advanced techniques for amortized analysis that can account for
persistence. Those techniques are based on the idea of accumulating *debt* that
is later paid off, rather than accumulating savings that are later spent. The
reason that debt ends up working as an analysis technique can be summed up as:
although our banks would never (financially speaking) allow us to spend money
twice, they would be fine with us paying off our debt multiple times. Consult
Okasaki's *Purely Functional Data Structures* to learn more.
