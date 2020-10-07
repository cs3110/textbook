# Amortized Analysis and Persistence

Amortized analysis breaks down as a technique when data structures are used
persistently. For example, suppose we have a two-list queue `q` into which we've
inserted $$n+1$$ elements. One elements will be in the front, and the other
$$n$$ will be in the back. Now we do the following:

```
# let q1 = dequeue q
# let q2 = dequeue q
...
# let qn = dequeue q
```

Each one of those $$n$$ `dequeue` operations requires an actual cost of $$O(n)$$
to reverse the back list. So the entire series has an actual cost of $$O(n^2)$$.
But the amortized analysis techniques only apply to the first `dequeue`. After
that, all the the accounts are empty (banker's method), or the potential is zero
(physicist's), which means the remaining operations can't use them to pay for
the expensive list reversal. The total cost of the series is therefore $$O(n^2 -
n)$$, which is $$O(n^2)$$.

The problem with persistence is that it violates the assumption built-in to
amortized analysis that credits (or energy units) are spent only once.  Every
persistent copy of the data structure instead tries to spend them itself, not
being aware of all the other copies.

So we must be careful not to use functional data structures persistently if we
want amortized analysis bounds to hold. There are more advanced techniques for
amortized analysis that can account for persistence. Those techniques are based
on the idea of accumulating debt that is later paid off, rather than
accumulating savings that are later spent. The difference is that although our
banks would never (financially speaking) allow us to spend money twice, they
would be fine with us paying off our debt multiple times.

