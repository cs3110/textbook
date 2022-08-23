# The Present of OCaml

{{ video_embed | replace("%%VID%%", "JTEwC3HihFc")}}

OCaml is a functional programming language. The key linguistic abstraction of
functional languages is the mathematical function. A function maps an input to
an output; for the same input, it always produces the same output. That is,
mathematical functions are *stateless*: they do not maintain any extra
information or *state* that persists between usages of the function. Functions
are *first-class*: you can use them as input to other functions, and produce
functions as output. Expressing everything in terms of functions enables a
uniform and simple programming model that is easier to reason about than the
procedures and methods found in other families of languages.

*Imperative* programming languages such as C and Java involve *mutable* state
that changes throughout execution. *Commands* specify how to compute by
destructively changing that state. Procedures (or methods) can have *side
effects* that update state in addition to producing a return value.

The **fantasy of mutability** is that it's easy to reason about: the machine
does this, then this, etc.

The **reality of mutability** is that whereas machines are good at complicated
manipulation of state, humans are not good at understanding it. The essence of
why that's true is that mutability breaks *referential transparency*: the
ability to replace an expression with its value without affecting the result of
a computation. In math, if $f(x)=y$, then you can substitute $y$ anywhere
you see $f(x)$. In imperative languages, you cannot: $f$ might have side
effects, so computing $f(x)$ at time $t$ might result in a different value
than at time $t'$.

It's tempting to believe that there's a single state that the machine
manipulates, and that the machine does one thing at a time. Computer systems go
to great lengths in attempting to provide that illusion. But it's just that: an
illusion. In reality, there are many states, spread across threads, cores,
processors, and networked computers. And the machine does many things
concurrently. Mutability makes reasoning about distributed state and concurrent
execution immensely difficult.

*Immutability*, however, frees the programmer from these concerns. It provides
powerful ways to build correct and concurrent programs. OCaml is primarily an
immutable language, like most functional languages. It does support imperative
programming with mutable state, but we won't use those features until many
chapters into the book&mdash;in part because we simply won't need them, and in
part to get you to quit "cold turkey" from a dependence you might not have known
that you had. This freedom from mutability is one of the biggest changes in
perspective that OCaml can give you.

## The Features of OCaml

{{ video_embed | replace("%%VID%%", "T-DIW1dhYzo")}}

OCaml is a *statically-typed* and *type-safe* programming language. A
statically-typed language detects type errors at compile time, so that programs
with type errors cannot be executed. A type-safe language limits which kinds of
operations can be performed on which kinds of data. In practice, this prevents a
lot of silly errors (e.g., treating an integer as a function) and also prevents
a lot of security problems: over half of the reported break-ins at the Computer
Emergency Response Team (CERT, a US government agency tasked with cybersecurity)
were due to buffer overflows, something that's impossible in a type-safe
language.

Some languages, like Python and Racket, are type-safe but *dynamically typed*.
That is, type errors are caught only at run time. Other languages, like C and
C++, are statically typed but not type safe. There's no guarantee that a type
error won't occur at run time. And still other languages, like Java, use a
combination of static and dynamic typing to achieve type safety.

OCaml supports a number of advanced features, some of which you will have
encountered before, and some of which are likely to be new:

-   **Algebraic datatypes:** You can build sophisticated data structures in
    OCaml easily, without fussing with pointers and memory management. *Pattern
    matching*&mdash;a feature we'll soon learn about that enables examining the shape
    of a data structure&mdash;makes them even more convenient.

-   **Type inference:** You do not have to write type information down
    everywhere. The compiler automatically figures out most types. This can make
    the code easier to read and maintain.

-   **Parametric polymorphism:** Functions and data structures can be
    parameterized over types. This is crucial for being able to re-use code.

-   **Garbage collection:** Automatic memory management relieves you from the
    burden of memory allocation and deallocation, a common source of bugs in
    languages such as C.

-   **Modules:** OCaml makes it easy to structure large systems through the use
    of modules. Modules are used to encapsulate implementations behind
    interfaces. OCaml goes well beyond the functionality of most languages with
    modules by providing functions (called *functors*) that manipulate modules.

## OCaml in Industry

{{ video_embed | replace("%%VID%%", "eNLm5Xbgmd0")}}

OCaml and other functional languages are nowhere near as popular as Python, C,
or Java. OCaml's real strength lies in language manipulation (i.e., compilers,
analyzers, verifiers, provers, etc.). This is not surprising, because OCaml
evolved from the domain of theorem proving.

That's not to say that functional languages aren't used in industry. There are
many [industry projects using OCaml][ocaml-industry] and
[Haskell][haskell-industry], among other languages. Yaron Minsky (Cornell PhD
'02) even wrote a paper about [using OCaml in the financial industry][minsky].
It explains how the features of OCaml make it a good choice for quickly building
complex software that works.

[minsky]: http://dx.doi.org/10.1017/S095679680800676X
[ocaml-industry]: https://ocaml.org/learn/companies.html
[haskell-industry]: https://wiki.haskell.org/Haskell_in_industry
