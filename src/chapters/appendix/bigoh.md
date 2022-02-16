# Big-Oh Notation

What does it mean to be *efficient*? Cornell professors Jon Kleinberg and Eva
Tardos have a wonderful explanation in chapter 2 of their textbook, *Algorithm
Design* (2006). This appendix is a summary and reinterpretation of that
explanation from a functional programming perspective. The ultimate answer will
be that an algorithm is *efficient* if its worst-case running time on input size
$n$ is $O(n^d)$ for some constant $d$. But it will take us several steps to
build up to that definition.

## Algorithms and Efficiency, Attempt 1

A naive attempt at defining efficiency might proceed as follows:

**Attempt 1:** An algorithm is efficient if, when implemented, it runs in a
small amount of time on particular input instances.

But there are many problems with that definition, such as:

- Inefficient algorithms can run quickly on small test cases.

- Fast processors and optimizing compilers can make inefficient algorithms run
  quickly.

- Efficient algorithms can run slowly when coded sloppily.

- Some input instances are harder than others.

- Efficiency on small inputs doesn't imply efficiency on large inputs.

- Some clients can afford to be more patient than others; quick for me might be
  slow for you.

**Lesson 1:** One lesson learned from that attempt is: time measured by a clock
is not the right metric for algorithm efficiency. We need a metric that is
reasonably independent of the hardware, compiler, other software that is
running, etc. Perhaps a good metric would be to give up on time and instead
count the number of *steps* taken during evaluation.

But, now we have a new problem: how should we define a "step"? It needs to be
something machine independent. It ought to somehow represent a primitive unit of
computation. There's a lot of flexibility. Here are some common choices:

- In pseudocode, we might think of a step as being a single line.

- In imperative languages, we might count assignments, array indexes, pointer
  dereferences, and arithmetic operations as steps.

- In OCaml, we could count function or operator application, let bindings, and
  choosing a branch of an `if` or `match` as steps.

In reality, all of those "steps" could really take a different amount of time.
But in practice, that doesn't really matter much.

**Lesson 2:** Another lesson we learned from attempt 1 was: running time on a
particular input instance is not the right metric. We need a metric that can
predict running time on any input instance. So instead of using the particular
input (e.g., a number, or a matrix, or a text document), it might be better to
use the *size* of the input (e.g., the number of bits it takes to represent the
number, or the number of rows and columns in the matrix, or the number of bytes
in the document) as the metric.

But again we have a new problem: how to define "size"? As in the examples we
just gave, size should be some measure of how big an input is compared to other
inputs. Perhaps the most common representation of size in the context of data
structures is just the number of elements maintained by the data structure: the
number of nodes in a list, or the number of nodes and edges in a graph, etc.

Could an algorithm run in a different amount of time on two inputs of the same
"size"? Sure. For example, multiplying a matrix by all zeroes might be faster
than multiplying by arbitrary numbers. But in practice, size matters more than
exact inputs.

**Lesson 3:** A third lesson we learned from attempt 1 was that "small amount of
time" is too relative a term. We want a metric that is reasonably objective,
rather than relying on subjective notions of what constitutes "small".

One sort-of-okay idea would be that an efficient algorithm needs to beat
*brute-force search*. That means enumerating all answers one-by-one, checking
each to see whether it's right. For example, a brute-force sorting algorithm
would enumerate every possible permutation of a list, checking to see whether
it's a sorted version of the input list. That's a terrible sorting algorithm!
Certainly quicksort beats it.

Brute-force search is the simple, dumb solution to nearly any algorithmic
problem. But it requires enumeration of a huge space. In fact, an
exponentially-sized space. So a better idea would be doing less than exponential
work. What's less than exponential (e.g., $2^n$)? One possibility is polynomial
(e.g., $n^2$).

An immediate objection might be that polynomials come in all sizes. For example,
$n^{100}$ is way bigger than $n^2$. And some non-polynomials, such as
$n^{1 +.02 (\log n)}$, might do an adequate job of beating exponentials.
But in practice, polynomials do seem to work fine.

## Algorithms and Efficiency, Attempt 2

Combining lessons 1 through 3 from Attempt 1, we have a second attempt at
defining efficiency:

**Attempt 2:** An algorithm is efficient if its maximum number of execution
steps is polynomial in the size of its input.

Note how all three ideas come together there: steps, size, polynomial.

But if we try to put that definition to use, it still isn't perfect. Coming up
with an exact formula for the maximum number of execution steps can be insanely
tedious. For example, in one other algorithm textbook, the authors develop this
following polynomial for the number of execution steps taken by a pseudo-code
implementation of insertion sort:

$$
c_1 n + c_2 (n - 1) + c_4 (n - 1) + c_5 \sum_{j=2}^{n} t_j + c_6 \sum_{j=2}^{n} (t_j - 1) + c_7 \sum_{j=2}^{n} (t_j - 1) + c_8 (n - 1)
$$

No need for us to explain what all the variables mean. It's too complicated. Our
hearts go out to the poor grad student who had to work out that one!

```{note}
That formula for running time of insertion sort is from *Introduction to
Algorithms*, 3rd edition, 2009, by Cormen, Leiserson, Rivest, and Stein. We
aren't making fun of them. They would also tell you that such formulas are too
complicated.
```

Precise execution bounds like that are exhausting to find and somewhat
meaningless. If it takes 25 steps in Java pseudocode, but compiled down to
RISC-V would take 250 steps, is the precision useful?

In some cases, yes. If you're building code that flies an airplane or controls a
nuclear reactor, you might actually care about precise, real-time guarantees.

But otherwise, it would be better for us to identify broad classes of algorithms
with similar performance. Instead of saying that an algorithm runs in

$$1.62 n^2 + 3.5 n + 8$$

steps, how about just saying it runs in $n^2$ steps? That is, we could ignore
the *low-order terms* and the *constant factor* of the highest-order term.

We ignore low-order terms because we want to THINK BIG. Algorithm efficiency is
all about explaining the performance of algorithms when inputs get really big.
We don't care so much about small inputs. And low-order terms don't matter when
we think big. The following table shows the number of steps as a function of
input size N, assuming each step takes 1 microsecond. "Very long" means more
than the estimated number of atoms in the universe.

|$N$|$N^2$|$N^3$|$2^N$
:-----:|:-----:|:-----:|:-----:|:-----:
N=10|< 1 sec|< 1 sec|< 1 sec|< 1 sec
N=100|< 1 sec|< 1 sec|1 sec|1017 years
N=1,000|< 1 sec|1 sec|18 min|very long
N=10,000|< 1 sec|2 min|12 days|very long
N=100,000|< 1 sec|3 hours|32 years|very long
N=1,000,000|1 sec|12 days|104 years|very long

As you can see, when inputs get big, there's a serious difference between
$N^3$ and $N^2$ and $N$. We might as well ignore low-order terms,
because they are completely dominated by the highest-order term when we think
big.

What about constant factors? My current laptop might be 2x faster (that is, a
constant factor of 2) than the one I bought several years ago, but that's not an
interesting property of the algorithm. Likewise, $1.62 n^2$ steps in pseduocode
might be $1620 n^2$ steps in assembly (that is, a constant factor of 1000), but
it's again not an interesting property of the algorithm. So, should we really
care if one algorithm takes 2x or 1000x longer than another, if it's just a
constant factor?

The answer is: maybe. Performance tuning in real-world code is about getting the
constants to be small. Your employer might be really happy if you make something
run twice as fast! But that's not about the **algorithm.** When we're measuring
algorithm efficiency, in practice the constant factors just don't matter much.

So all that argues for having an **imprecise abstraction** to measure running
time. Instead of $1.62 n^2 + 3.5 n + 8$, we can just write $n^2$. Imprecise
abstractions are nothing new to you. You might write $\pm 1$ to imprecisely
abstract a quantity within 1. In computer science, you already know that we use
Big-Oh notation as an imprecise abstraction: $1.62 n^2 + 3.5 n + 8$ is $O(n^2)$.

## Big-Ell Notation

Before reviewing Big-Oh notation, let's start with something simpler that you
might not have seen before: Big-Ell notation.

Big-Ell is an imprecise abstraction of natural numbers <u>l</u>ess than or equal
to another number, hence the L. It's defined as follows:

$$
L(n) = \{ m \mathrel{|} 0 \leq m \leq n\}
$$

where $m$ and $n$ are natural numbers. That is, $L(n)$ represents all the
natural numbers less than or equal to $n$. For example, $L(5) = \{0, 1, 2, 3, 4,
5\}$.

Could you do arithmetic with Big-Ell? For example, what would $1 + L(5)$ be?
It's not a well-posed question, to be honest: addition is an operation we think
of being defined on integers, not sets of integers. But a reasonable
interpretation of $1 + \{0, 1, 2, 3, 4, 5\}$ could be doing the addition for
each element in the set, yielding $\{1, 2, 3, 4, 5, 6\}$. Note that $\{1, 2, 3,
4, 5, 6\}$ is a proper subset of $\{0, 1, 2, 3, 4, 5, 6\}$, and the latter is
$L(6)$. So we could say that $1 + L(5) \subseteq L(6)$. We could even say that
$1 + L(5) \subseteq L(7)$, but it's not *tight*: the former subset relation
included the fewest possible extra elements, whereas the latter was *loose* by
needlessly including extra.

For more about Big Ell, see *Concrete Mathematics*, chapter 9, 1989, by Graham,
Knuth, and Patashnik.

## Big-Oh Notation

If you understand Big-Ell, and you understand functional programming, here's
some good news: you can easily understand Big-Oh.

Let's build up the definition of Big-Oh in a few steps. We'll start with version
1, which we'll write as $O_1$. It's based on $L$:

- $L(n)$ represents any **natural number** that is less than or equal to a
  **natural number** $n$.

- $O_1(g)$ represents any **natural function** that is less than or equal
  to a **natural function** $g$.

A *natural function* is just a function on natural numbers; that is, its type is
$\mathbb{N} \rightarrow \mathbb{N}$.

All we do with $O_1$ is upgrade from **natural numbers** to **natural
functions**. So Big-Oh version 1 is just the *higher-order* version of Big-Ell.
How about that!

Of course, we need to work out what it means for a function to be less than
another function. Here's a reasonable formalization:

**Big-Oh Version 1:** $O_1(g) = \{ f \mathrel{|} \forall n \mathrel{.} f(n) \leq g(n)\}$

For example, consider the function that doubles its input. In math textbooks,
that function might be written as $g(n) = 2n$. In OCaml we would write
`let g n = 2 * n` or `let g = fun n -> 2 * n` or just anonymously as
`fun n -> 2 * n`. In math that same anonymous function would be written with
lambda notation as $\lambda n . 2n$. Proceeding with lambda notation, we have:

$$
O_1(\lambda n . 2n) = \{ f \mathrel{|} \forall n . f(n) \leq 2n \}
$$

and therefore

- $(\lambda n . n) \in O_1(\lambda n . 2n)$,

- $(\lambda n . \frac{n}{2}) \in O_1(\lambda n . 2n)$, but

- $(\lambda n . 3n) \notin O_1(\lambda n . 2n)$.

Next, recall that in defining algorithmic efficiency, we wanted to ignore
constant factors. $O_1$ does not help us with that. We'd really like for all
these functions:

- $(\lambda n . n)$

- $(\lambda n . 2n)$

- $(\lambda n . 3n)$

to be in $O(\lambda n . n)$.

Toward that end, let's define $O_2$ to ignore constant factors:

**Big-Oh Version 2:** $O_2(g) = \{ f \mathrel{|} \exists c \gt 0 \forall n
\mathrel{.} f(n) \leq c g(n)\}$

That existentially-quantified positive constant $c$ lets us "bump up" the
function $g$ to whatever constant factor we need. For example,

$$
O_2(\lambda n . n^3) = \{ f \mathrel{|} \exists c \gt 0 \forall n . f(n) \leq c n^3 \}
$$

and therefore $(\lambda n . 3n^3) \in O_2(\lambda n . n^3)$, because $3 n^3 \leq
c n^3$ if we take $c = 3$, or $c = 4$, or any larger $c$.

Finally, recall that we don't care about small inputs: we want to THINK BIG when
we analyze algorithmic efficiency. It doesn't matter whether the running time of
an algorithm happens to be a little faster or a little slower for small inputs.
In fact, we could just hardcode a lookup table for those small inputs if the
algorithm is too slow on them! What matters really is the performance on
big-sized inputs.

Toward that end, let's define $O_3$ to ignore small inputs:

**Big-Oh Version 3:** $O_3(g) = \{ f \mathrel{|} \exists c \gt 0 \exists n_0 \gt
0 \forall n \geq n_0 \mathrel{.} f(n) \leq c g(n)\}$

That existentially quantified positive constant $n_0$ lets us "ignore" all
inputs of that size or smaller. For example,

$$
O_3(\lambda n . n^2) = \{ f \mathrel{|} \exists c \gt 0 \exists n_0 \gt 0 \forall n \geq n_0 \mathrel{.} f(n) \leq c n^2\}
$$

and therefore $(\lambda n . 2n) \in O_3(\lambda n . n^2)$, because $2n \leq c
n^2$ if we take $c = 2$ and $n_0 = 2$. Note how we get to ignore the fact that
$\lambda n . 2n$ is temporarily a little too big at $n = 1$ by picking $n_0 =
2$. That's the power of ignoring "small" inputs.

## Big-Oh, Finished

Version 3 is the right definition of Big-Oh.  We repeat it here, for real:

**Big-Oh:** $O(g) = \{ f \mathrel{|} \exists c \gt 0 \exists n_0 \gt 0 \forall n \geq n_0 \mathrel{.} f(n) \leq c g(n)\}$

That's the final, important version you should know. But don't just memorize it.
If you understand the derivation we gave here, you'll be able to recreate it
from scratch anytime you need it.

Big-Oh is called an *asymptotic upper bound*. If $f \in O(g)$, then $f$ is at
least as efficient as $g$, and might be more efficient.

## Big-Oh Notation Warnings

**Warning 1.** Because it's an upper bound, we can always inflate a Big-Oh
statement: for example, if $f \in O(n^2)$, then also $f \in O(n^3)$, and $f \in
O(2^n)$, etc. But our goal is always to give *tight* upper bounds, whether we
explicitly say that or not. So when asked what the running time of an algorithm
is, you must always give the tightest bound you can with Big-Oh.

**Warning 2.** Instead of $O(g) = \{ f \mathrel{|} \ldots \}$, most authors
instead write $O(g(n)) = \{ f(n) \mathrel{|} \ldots \}$. They don't really mean
$g$ applied to $n$. They mean a function $g$ parameterized on input $n$ but not
yet applied. This is badly misleading and generally a result of not
understanding anonymous functions. Moral of that story: more people need to
study functional programming.

**Warning 3.** Instead of $\lambda n . 2n \in O(\lambda n . n^2)$ nearly all
authors write $2n = O(n^2)$. This is a hideous and inexcusable abuse of notation
that should never have been allowed and yet has permanently infected the
computer science consciousness. The standard defense is that $=$ here should be
read as "is" not as "equals". That is patently ridiculous, and even those who
make that defense usually have the good grace to admit it's nonsense. Sometimes
we become stuck with the mistakes of our ancestors. This is one of those times.
Be careful of this "one-directional equality" and, if you ever have a chance,
teach your (intellectual) children to do better.

## Algorithms and Efficiency, Attempt 3

Let's review.  Our first attempt at defining efficiency was:

**Attempt 1:** An algorithm is efficient if, when implemented, it runs in a
small amount of time on particular input instances.

By replacing time with steps, particular instances with input size, and small
with polynomial, we improved that to:

**Attempt 2:** An algorithm is efficient if its maximum number of execution
steps is polynomial in the size of its input.

And that's really a pretty good definition.  But using Big-Oh notation to
make it a little more concrete, we can produce our third and final attempt:

**Attempt 3:** An algorithm is efficient if its worst-case running time on input
size $n$ is $O(n^d)$ for some constant $d$.

By "worst-case running time" we mean the same thing as "maximum number of
execution steps", just expressed in different and probably more common words.
The worst-case is when execution takes the longest. "Time" is a common euphemism
here for execution steps, and is used to emphasize we're thinking about how long
a computation takes.

*Space* is the most common other feature of efficiency to consider. Algorithms
can be more or less efficient at requiring constant or linear space, for
example. You're already familiar with that from tail recursion and lists in
OCaml.
