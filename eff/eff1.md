# Algorithms and Efficiency, Attempt 1

What does it mean for an algorithm to be *efficient*? Our own Profs. Kleinberg
and Tardos have a wonderful explanation in chapter 2 of their CS 4820 textbook,
*Algorithm Design* (2006). Here's a summary of it.

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
work.  What's less than exponential (e.g., $$2^n$$)?  One possibility
is polynomial (e.g., $$n^2$$).

An immediate objection might be that polynomials come in all sizes. For example,
$$n^100$$ is way bigger than $$n^2$$. And some non-polynomials, such as 
$$n^{1 +.02 (\log n)}$$}, might do an adequate job of beating exponentials.
But in practice, polynomials do seem to work fine.
