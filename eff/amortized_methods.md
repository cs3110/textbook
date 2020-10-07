# Bankers and Physicists

Conceptually, amortized analysis can be understood in three ways:

1. Taking the average cost over a series of operations.  This is what we've
   done so far.

2. Keeping a "bank account" at each individual element of a data structure. Some
   operations deposit credits, and others withdraw them. The goal is for account
   totals to never be negative. The amortized cost of any operation is the
   actual cost, plus any credits deposited, minus any credits spent. So if an
   operation actually costs $$n$$ but spends $$n-1$$ credits, then its amortized
   cost is just $$1$$. This is called the *banker's method* of amortized
   analysis.

3. Regarding the entire data structure as having an amount of "potential energy"
   stored up. Some operations increase the energy, some decrease it. The energy
   should never be negative. The amortized cost of any operation is its actual
   cost, plus the change in potential energy. So if an operation actually costs
   $$n$$, and before the operation the potential energy is $$n$$, and after the
   operation the potential energy is $$0$$, then the amortized cost is
   $$n + (0 - n)$$, which is just $$0$$. This is called the *physicist's method*
   of amortized analysis.

The banker's and physicist's methods can be easier to use in many situations
than a complicated analysis of a series of operations.  Let's revisit our
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

- **Banker's method, two-list queues:** When an element is added to the queue,
  save up 1 credit in its account.  When the back must be reversed, use the
  credit in each element to pay for the cons onto the front.  Since elements
  enter at the back and transition at most once to the front, every element
  will have 0 or 1 credits.  So the accounts never go negative.

- **Physicist's method, hash tables:** At first, define the potential energy of
  the table to be the number of bindings inserted. That energy will therefore
  never be negative. Each insertion increases the energy by 1 unit. When the
  first rehash is needed after inserting $$n$$ bindings, the potential energy is
  $$n$$. The potential goes back down to $$0$$ at the rehash. So the actual cost
  is $$n$$, but the change in potential is $$n$$, which makes the amortized cost
  $$0$$, or constant. From now on, define the potential energy to be twice the
  number of bindings inserted since the last rehash. Again, the energy will
  never be negative. Each insertion increases the energy by 2 units. When the
  next rehash is needed after inserting $$n$$ bindings, there will be $$2n$$
  bindings that need to be rehashed. Again, the amortized cost will be constant,
  because the actual cost of $$2n$$ re-insertions is offset by the $$2n$$ change
  in potential.

- **Physicist's method, two-list queues:** Define the potential energy of the
  queue to be the length of the back. It therefore will never be negative. When
  a `dequeue` has to reverse a back list of length $$n$$, there is an actual cost
  of $$n$$ but a change in potential of $$n$$ too, which offsets the cost and
  makes it constant.

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
