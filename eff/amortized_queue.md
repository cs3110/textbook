# Amortized Analysis of Two-List Queues

The implemention of [queues with two lists](../modules/ex_queues.md) was in a
way more efficient than the implementation with just one list, because it
managed to achieve a constant time `enqueue` operation. But, that came at the
tradeoff of making the `dequeue` operation sometimes take more than constant
time: whenever the front became empty, the back had to be reversed, which
required an additional linear-time operation.

As we observed then, the reversal is relatively rare. It happens only when the
front gets exhausted. Amortized analysis gives us a way to account for that. We
can actually show that the `dequeue` operation is amortized constant time.

To keep the analysis simple at first, let's assume the queue starts off with
exactly one element `1` already enqueued, and that we do three `enqueue`
operations of `2`, `3`, then `4`, followed by a single `dequeue`. The single
initial element had to be in the front of the queue. All three `enqueue`
operations will cons an element onto the back. So just before the `dequeue`, the
queue looks like:

```
{front = [1]; back = [4; 3; 2]}
```

and after the `dequeue`:

```
{front = [2; 3; 4]; back = []}
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

- If `dequeue` doesn't need to reverse the back, it really does just constant
  work, and

- If `dequeue` does need to reverse a back list with $$n$$ elements, it already
  has $$n$$ units of work "saved up" from each of the enqueues of those $$n$$
  elements.

So if we just pretend each enqueue costs twice its normal price, every operation
in a sequence is amortized constant time. Is this just a bookkeeping trick?
Absolutely. But it also reveals the deeper truth that on average we get
constant-time performance, even though some operations might rarely have
worst-case linear-time performance.
