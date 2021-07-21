# Amortized Analysis

Our analysis of the efficiency of hash table operations concluded that `find`
runs in expected constant time, where the modifier "expected" is needed to
express the fact the performance is on average and depends on the hash function
satisfying certain properties.

We also concluded that `insert` would usually run in expected constant time,
but that in the worst case it would require linear time because of needing
to rehash the entire table.  That kind of defeats the goal of a hash table,
which is to offer constant-time performance, or at least as close to it
as we can get.

It turns out there is another way of looking at this analysis that allows us to
conclude that `insert` does have "amortized" expected constant time
performance&mdash;that is, for excusing the occasional worst-case linear
performance. Right away, we have to acknowledge this technique is just a change
in perspective. We're not going to change the underlying algorithms. The
`insert` algorithm will still have worst-case linear performance. That's a fact.

But the change in perspective we now understake is to recognize that if it's
very rare for `insert` to require linear time, then maybe we can "spread out"
that cost over all the other calls to `insert`. It's a creative accounting
trick!

**Sushi vs. Ramen.**
Let's amuse ourselves with a real-world example for a moment.  Suppose that
you have $20 to spend on lunches for the week.  You like to eat sushi, but you
can't afford to have sushi every day.  So instead you eat as follows:

- Monday: $1 ramen 
- Tuesday: $1 ramen
- Wednesday: $1 ramen
- Thursday: $1 ramen
- Friday: $16 sushi

Most of the time, your lunch was cheap.  On a rare occasion, it was expensive.
So you could look at it in one of two ways:

- My worst-case lunch cost was $16.
- My average lunch cost was $4.

Both are true statements, but maybe the latter is more helpful in understanding
your spending habits.

**Back to Hash Tables.**
It's the same with hash tables.  Even though `insert` is occasionally expensive,
it's so rarely expensive that the average cost of an operation is actually
constant time!  But, we need to do more complicated math (or more complicated
than our lunch budgeting anyway) to actually demonstrate that's true.
