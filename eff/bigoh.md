# Big-Oh Notation

Before reviewing Big-Oh notation, let's start with something simpler that
you might not have seen before:  Big-Ell notation.

## Big-Ell Notation

Big-Ell is an imprecise abstraction of natural numbers <u>l</u>ess than or equal
to another number, hence the L. It's defined as follows:

$$
L(n) = \{ m \mathrel{|} 0 \leq m \leq n\}
$$

where $$m$$ and $$n$$ are natural numbers.  That is, $$L(n)$$ represents
all the natural numbers less than or equal to $$n$$.  For example,
$$L(5) = \{0, 1, 2, 3, 4, 5\}$$.

Could you do arithmetic with Big-Ell?  For example, what would $$1 + L(5)$$ be?
It's not a well-posed question, to be honest: addition is an operation we
think of being defined on integers, not sets of integers.  But a reasonable
interpretation of $$1 + \{0, 1, 2, 3, 4, 5\}$$ could be doing the addition
for each element in the set, yielding $$\{1, 2, 3, 4, 5, 6\}$$. Note that
$$\{1, 2, 3, 4, 5, 6\}$$ is a proper subset of $$\{0, 1, 2, 3, 4, 5, 6\}$$, and
the latter is $$L(6)$$.  So we could say that $$1 + L(5) \subseteq L(6)$$.
We could even say that $$1 + L(5) \subseteq L(7)$$, but it's not *tight*:
the former subset relation included the fewest possible extra elements,
whereas the latter was *loose* by needlessly including extra.

For more about Big Ell, see *Concrete Mathematics*, chapter 9, 1989, by
Graham, Knuth, and Patashnik.

## Big-Oh Notation

If you understand Big-Ell, and you understand functional programming, here's
some good news: you can easily understand Big-Oh.

Let's build up the definition of Big-Oh in a few steps.  We'll start with
version 1, which we'll write as $$O_1$$.

- $$L(n)$$ represents any **natural number** that is less than or equal to a
  **natural number** $$n$$.

- $$O_1(g)$$ represents any **natural function** that is less than or equal
  to a **natural function** $$g$$.

A *natural function* is just a function on natural numbers; that is, its type is
$$\mathbb{N} \rightarrow \mathbb{N}$$.

All we do with $$O_1$$ is upgrade from **natural numbers** to **natural
functions**. So Big-Oh version 1 is just the *higher-order* version of Big-Ell.
How about that!

Of course, we need to work out what it means for a function to be less than
another function.  Here's a reasonable formalization:

**Big-Oh Version 1:** $$O_1(g) = \{ f \mathrel{|} \forall n \mathrel{.} f(n) \leq g(n)\}$$

For example, consider the function that doubles its input.  In math
textbooks, that function might be written as $$g(n) = 2n$$.  In OCaml
we would write `let g n = 2 * n` or `let g = fun n -> 2 * n` or just 
anonymously as `fun n -> 2 * n`.  In math that same anonymous function
would be written with lambda notation as $$\lambda n . 2n$$.
Proceeding with lambda notation, we have:

$$
O_1(\lambda n . 2n) = \{ f \mathrel{|} \forall n . f(n) \leq 2n \}
$$

and therefore

- $$(\lambda n . n) \in O_1(\lambda n . 2n)$$,
- $$(\lambda n . \frac{n}{2}) \in O_1(\lambda n . 2n)$$, but
- $$(\lambda n . 3n) \notin O_1(\lambda n . 2n)$$.

Next, recall that in defining algorithmic efficiency, we wanted to ignore
constant factors.  $$O_1$$ does not help us with that.  We'd really
like for all these functions:

- $$(\lambda n . n)$$
- $$(\lambda n . 2n)$$
- $$(\lambda n . 3n) $$

to be in $$O(\lambda n . n)$$.

Toward that end, let's define $$O_2$$ to ignore constant factors:

**Big-Oh Version 2:** $$O_2(g) = \{ f \mathrel{|} \exists c \gt 0 \forall n \mathrel{.} f(n) \leq c g(n)\}$$

That existentially-quantified positive constant $$c$$ lets us "bump up" the
function $$g$$ to whatever constant factor we need. For example,

$$
O_2(\lambda n . n^3) = \{ f \mathrel{|} \exists c \gt 0 \forall n . f(n) \leq c n^3 \}
$$

and therefore $$(\lambda n . 3n^3) \in O_2(\lambda n . n^3)$$, because
$$3 n^3 \leq c n^3$$ if we take $$c = 3$$, or $$c = 4$$, or any larger $$c$$.

Finally, recall that we don't care about small inputs: we want to THINK BIG
when we analyze algorithmic efficiency.  It doesn't matter whether the running
time of an algorithm happens to be a little faster or a little slower for small
inputs.  In fact, we could just hardcode a lookup table for those small inputs
if the algorithm is too slow on them!  What matters really is the performance
on big-sized inputs.

Toward that end, let's define $$O_3$$ to ignore small inputs:

**Big-Oh Version 3:** $$O_3(g) = \{ f \mathrel{|} \exists c \gt 0 \exists n_0 \gt 0 \forall n \geq n_0 \mathrel{.} f(n) \leq c g(n)\}$$

That existentially quantified positive constant $$n_0$$ lets us "ignore"
all inputs of that size or smaller.  For example,

$$
O_3(\lambda n . n^2) = \{ f \mathrel{|} \exists c \gt 0 \exists n_0 \gt 0 \forall n \geq n_0 \mathrel{.} f(n) \leq c n^2\}
$$

and therefore $$(\lambda n . 2n) \in O_3(\lambda n . n^2)$$, because
$$2n \leq c n^2$$ if we take $$c = 2$$ and $$n_0 = 2$$.
Note how we get to ignore the fact that $$\lambda n . 2n$$
is temporarily a little too big at $$n = 1$$ by picking $$n_0 = 2$$.
That's the power of ignoring "small" inputs.

## Big-Oh, Finished

Version 3 is the right definition of Big-Oh.  We repeat it here, for real:

**Big-Oh:** $$O(g) = \{ f \mathrel{|} \exists c \gt 0 \exists n_0 \gt 0 \forall n \geq n_0 \mathrel{.} f(n) \leq c g(n)\}$$

That's the final, important version you should know. But don't just memorize it.
If you understand the derivation we gave here, you'll be able to recreate it
from scratch anytime you need it.

Big-Oh is called an *asymptotic upper bound*.  If $$f \in O(g)$$, then
$$f$$ is at least as efficient as $$g$$, and might be more efficient.

## Big-Oh Notation Warnings

1. Because it's an upper bound, we can always inflate a Big-Oh statement:
for example, if $$f \in O(n^2)$$, then also $$f \in O(n^3)$$, and 
$$f \in O(2^n)$$, etc.  But our goal is always to give *tight* upper bounds,
whether we explicitly say that or not.  So when asked what the running
time of an algorithm is, you must always give the tightest bound you can
with Big-Oh.

1. Instead of $$O(g) = \{ f \mathrel{|} \ldots \}$$, most authors
instead write $$O(g(n)) = \{ f(n) \mathrel{|} \ldots \}$$.  They don't really
mean $$g$$ applied to $$n$$.  They mean a function $$g$$ parameterized on
input $$n$$ but not yet applied.  This is badly misleading and generally
a result of not understanding anonymous functions.  Moral of that story:
more people need to study functional programming.

1. Instead of $$\lambda n . 2n \in O(\lambda n . n^2)$$ nearly all authors write
$$2n = O(n^2)$$.  This is a hideous and inexcusable abuse of notation that
should never have been allowed and yet has permanently infected the
computer science consciousness.  The standard defense is that $$=$$ here
should be read as "is" not as "equals".  That is patently ridiculous, and even
those who make that defense usually have the good grace to admit it's nonsense.
Sometimes we become stuck with the mistakes of our ancestors.  This is one of
those times.  Be careful of this "one-directional equality" and, if you ever
have a chance, teach your (intellectual) children to do better.

