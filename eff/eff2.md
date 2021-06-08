# Algorithms and Efficiency, Attempt 2

Combining lessons 1 through 3 from Attempt 1, we have a second attempt at
defining efficiency:

**Attempt 2:** An algorithm is efficient if its maximum number of execution
steps is polynomial in the size of its input.

Note how all three ideas come together there: steps, size, polynomial.

But if we try to put that definition to use, it still isn't perfect. Coming up
with an exact formula for the maximum number of execution steps can be insanely
tedious. For example, in one other algorithm textbook that we won't name (except
see the end of this page), the authors develop this following polynomial for the
number of execution steps taken by a pseudo-code implementation of insertion
sort:

$$
c_1 n + c_2 (n - 1) + c_4 (n - 1) + c_5 \sum_{j=2}^{n} t_j + c_6 \sum_{j=2}^{n} (t_j - 1) + c_7 \sum_{j=2}^{n} (t_j - 1) + c_8 (n - 1)
$$

No need for us to explain what all the variables mean. It's too complicated. Our
hearts go out to the poor grad student who had to work out that one!

Precise execution bounds like that are exhausting to find and somewhat
meaningless. If it takes 25 steps in Java pseudocode, but compiled down to
RISC-V would take 250 steps, is the precision useful?

In some cases, yes. If you're building code that flies an airplane or controls a
nuclear reactor, you might actually care about precise, real-time guarantees.

But otherwise, it would be better for us to identify broad classes of algorithms
with similar performance. Instead of saying that an algorithm runs in $$1.62 n^2
+ 3.5 n + 8$$ steps, how about just saying it runs in $$n^2$$ steps? That is, we
could ignore the *low-order terms* and the *constant factor* of the
highest-order term.

We ignore low-order terms because we want to THINK BIG. Algorithm efficiency is
all about explaining the performance of algorithms when inputs get really big.
We don't care so much about small inputs. And low-order terms don't matter when
we think big. The following table shows the number of steps as a function of
input size N, assuming each step takes 1 microsecond. "Very long" means more
than the estimated number of atoms in the universe.

 |$$N$$|$$N^2$$|$$N^3$$|$$2^N$$
:-----:|:-----:|:-----:|:-----:|:-----:
N=10|< 1 sec|< 1 sec|< 1 sec|< 1 sec
N=100|< 1 sec|< 1 sec|1 sec|1017 years
N=1,000|< 1 sec|1 sec|18 min|very long
N=10,000|< 1 sec|2 min|12 days|very long
N=100,000|< 1 sec|3 hours|32 years|very long
N=1,000,000|1 sec|12 days|104 years|very long

As you can see, when inputs get big, there's a serious difference between
$$N^3$$ and $$N^2$$ and $$N$$. We might as well ignore low-order terms,
because they are completely dominated by the highest-order term when we think
big.

What about constant factors? My current laptop might be 2x faster (that is, a
constant factor of 2) than the one I bought several years ago, but that's not an
interesting property of the algorithm. Likewise, $$1.62 n^2$$ steps in
pseduocode might be $$1620 n^2$$ steps in assembly (that is, a constant factor
of 1000), but it's again not an interesting property of the algorithm. So,
should we really care if one algorithm takes 2x or 1000x longer than another, if
it's just a constant factor?

The answer is: maybe. Performance tuning in real-world code is about getting the
constants to be small. Your employer might be really happy if you make something
run twice as fast! But that's not about the **algorithm.** When we're measuring
algorithm efficiency, in practice the constant factors just don't matter much.

So all that argues for having an **imprecise abstraction** to measure running
time. Instead of $$1.62 n^2 + 3.5 n + 8$$, we can just write $$n^2$$.
Imprecise abstractions are nothing new to you. You might write $$\pm 1$$ to
imprecisely abstract a quantity within 1. In computer science, you already know
that we use Big-Oh notation as an imprecise abstraction:
$$1.62 n^2 + 3.5 n + 8$$ is $$O(n^2)$$.

Next, we'll review Big-Oh notation.

PS. The formula for running time of insertion sort above is from *Introduction
to Algorithms*, 3rd edition, 2009, by Cormen, Leiserson, Rivest, and Stein. We
didn't mean to insult them. They would also tell you that such formulas are too
complicated.