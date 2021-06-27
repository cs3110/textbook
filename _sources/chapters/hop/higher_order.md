---
jupytext:
  cell_metadata_filter: -all
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.10.3
kernelspec:
  display_name: OCaml
  language: OCaml
  name: ocaml-jupyter
---

# Higher-Order Functions

Consider these functions `double` and `square` on integers:

```{code-cell} ocaml
let double x = 2 * x
let square x = x * x
```

Let's use these functions to write other functions that quadruple and raise a
number to the fourth power:

```{code-cell} ocaml
let quad x = double (double x)
let fourth x = square (square x)
```

There is an obvious similarity between these two functions: what they do is
apply a given function twice to a value. By passing in the function to another
function `twice` as an argument, we can abstract this functionality:

```{code-cell} ocaml
let twice f x = f (f x)
```

The function `twice` is higher-order: its input `f` is a function.
And&mdash;recalling that all OCaml functions really take only a single
argument&mdash;its output is technically `fun x -> f (f x)`, so `twice` returns
a function hence is also higher-order in that way.

Using `twice`, we can implement `quad` and `fourth` in a uniform way:

```{code-cell} ocaml
let quad x = twice double x
let fourth x = twice square x
```

## The Abstraction Principle

Above, we have exploited the structural similarity between `quad` and `fourth`
to save work. Admittedly, in this toy example it might not seem like much work.
But imagine that `twice` were actually some much more complicated function. Then
if someone comes up with a more efficient version of it, every function written
in terms of it (like `quad` and `fourth`) could benefit from that improvement in
efficiency, without needing to be recoded.

Part of being an excellent programmer is recognizing such similarities and
*abstracting* them by creating functions (or other units of code) that implement
them. Bruce MacLennan names this the **Abstraction Principle** in his textbook
*Functional Programming: Theory and Practice* (1990). The Abstraction Principle
says to avoid requiring something to be stated more than once; instead, *factor
out* the recurring pattern.Higher-order functions enable such refactoring,
because they allow us to factor out functions and parameterize functions on
other functions.

Besides `twice`, here are some more relatively simple examples, indebted also to
MacLennan:

**Apply.** We can write a function that applies its first input to its second
input:
```{code-cell} ocaml
let apply f x = f x
```
Of course, writing `apply f` is a lot more work than just writing `f`.

**Pipeline.** The pipeline operator, which we've previously seen, is a
higher-order function:
```{code-cell} ocaml
let pipeline x f = f x
let (|>) = pipeline
let x = 5 |> double
```

**Compose.** We can write a function that composes two other functions:
```{code-cell} ocaml
let compose f g x = f (g x)
```
This function would let us create a new function that can be applied
many times, such as the following:
```{code-cell} ocaml
let square_then_double = compose double square
let x = square_then_double 1
let y = square_then_double 2
```

**Both.** We can write a function that applies two functions to the same
argument and returns a pair of the result:
```{code-cell} ocaml
let both f g x = (f x, g x)
let ds = both double square
let p = ds 3
```

**Cond.** We can write a function that conditionally chooses which of two
functions to apply based on a predicate:
```{code-cell} ocaml
let cond p f g x =
  if p x then f x else g x
```

## The Meaning of "Higher Order"

The phrase "higher order" is used throughout logic and computer science, though
not necessarily with a precise or consistent meaning in all cases.

In logic, *first-order quantification* refers primarily to the universal and
existential ($\forall$ and $\exists$) quantifiers. These let you quantify over
some *domain* of interest, such as the natural numbers. But for any given
quantification, say $\forall x$, the variable being quantified represents an
individual element of that domain, say the natural number 42.

*Second-order quantification* lets you do something strictly more powerful,
which is to quantify over *properties* of the domain. Properties are assertions
about individual elements, for example, that a natural number is even, or that
it is prime. In some logics we can equate properties with sets of individual,
for example the set of all even naturals. So second-order quantification is
often thought of as quantification over *sets*. You can also think of properties
as being functions that take in an element and return a Boolean indicating
whether the element satisfies the property; this is called the *characteristic
function* of the property.

*Third-order* logic would allow quantification over properties of properties,
and *fourth-order* over properties of properties of properties, and so forth.
*Higher-order logic* refers to all these logics that are more powerful than
first-order logic; though one interesting result in this area is that all
higher-order logics can be expressed in second-order logic.

In programming languages, *first-order functions* similarly refer to functions
that operate on individual data elements (e.g., strings, ints, records,
variants, etc.). Whereas *higher-order function* can operate on functions, much
like higher-order logics can quantify over over properties (which are like
functions).

## Famous Higher-order Functions

In the next few sections we'll dive into three of the most famous higher-order
functions: map, filter, and fold. These are functions that can be defined for
many data structures, including lists and trees. The basic idea of each is that:

* *map* transforms elements,
* *filter* eliminates elements, and
* *fold* combines elements.