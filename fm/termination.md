# Termination

Sometimes correctness of programs is further divided into:

- **partial correctness**:  meaning that *if* a program terminates, then
  its output is correct; and

- **total correctness**:  meaning that a program *does* terminate, *and*
  its output is correct.

Total correctness is therefore the conjunction of partial correctness and
termination.  Thus far, we have been proving partial correctness.

To prove that a program terminates is difficult.  Indeed, it is impossible in
general for an algorithm to do so:  a computer can't precisely decide whether a
program will terminate.  (Look up the "halting problem" for more details.) But,
a smart human sometimes can do so.

There is a simple heuristic that can be used to show that a recursive
function terminates:

- All recursive calls are on a "smaller" input, and
- all base cases are terminating.

For example, consider the factorial function:
```
let rec fact n =
  if n = 0 then 1
  else n * fact (n - 1)
```

The base case, `1`, obviously terminates.  The recursive call is on `n - 1`,
which is a smaller input than the original `n`.  So `fact` always terminates
(as long as its input is a natural number).

The same reasoning applies to all the other functions we've discussed above.

To make this more precise, we need a notion of what it means to be smaller.
Suppose we have a binary relation `<` on inputs.  Despite the notation, this
relation need not be the less-than relation on integers---although that will
work for `fact`.  Also suppose that it is never possible to create an infinite
sequence `x0 > x1 > x2 > x3 ...` of elements using this relation.  (Where of
course `a > b` iff `b < a`.)  That is, there are no infinite descending chains
of elements:  once you pick a starting element `x0`, there can be only a finite
number of "descents" according to the `<` relation before you bottom out and hit
a base case. This property of `<` makes it a *well-founded relation*.

So, a recursive function terminates if all its recursive calls are on
elements that are smaller according to `<`.  Why?  Because there can be only
a finite number of calls before a base case is reached, and base cases must
terminate.

The usual `<` relation is well-founded on the natural numbers, because
eventually any chain must reach the base case of 0.  But it is not
well-founded on the integers, which can get just keep getting smaller:
`-1 > -2 > -3 > ...`.

Here's an interesting function for which the usual `<` relation doesn't suffice
to prove termination:

```
let rec ack = function
  | (0, n) -> n + 1
  | (m, 0) -> ack (m - 1, 1)
  | (m, n) -> ack (m - 1, ack (m, n - 1))
```

This is known as *Ackermann's function*.  It grows faster than any exponential
function.  Try running `ack (1, 1)`, `ack (2, 1)`, `ack (3, 1)`, then `ack (4,
1)` to get a sense of that.  It also is a famous example of a function that can
be implemented with `while` loops but not with `for` loops.  Nonetheless, it
does terminate.

To show that, the base case is easy:  when the input is `(0, _)`, the function
terminates.  But in other cases, it makes a recursive call, and we need
to define an appropriate `<` relation.  It turns out *lexicograpic ordering*
on pairs works.  Define `(a, b) < (c, d)` if:

- `a < c`, or
- `a = c` and `b < d`.

The `<` order in those two cases is the usual `<` on natural numbers.

In the first recursive call, `(m - 1, 1) < (m, 0)` by the first case of the
definition of `<`, because `m - 1 < m`.  In the nested recursive call
`ack (m - 1, ack (m, n - 1))`, both cases are needed:

- `(m, n - 1) < (m, n)` because `m = m` and `n - 1 < n`
- `(m - 1, _) < (m, n)` because `m - 1 < m`.
