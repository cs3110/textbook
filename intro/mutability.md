# Mutability

*Imperative* programming languages such as C and Java involve *mutable*
state that changes throughout execution. *Commands* specify how to
compute by destructively changing that state. Procedures (or methods)
can have *side effects* that update state in addition to producing a
return value.

The **fantasy of mutability** is that it's easy to reason about: the
machine does this, then this, etc.

The **reality of mutability** is that whereas machines are good at
complicated manipulation of state, humans are not good at understanding
it. The essence of why that's true is that mutability breaks
*referential transparency*: the ability to replace an expression with its
value without affecting the result of a computation. In math, if $$f(x)=y$$,
then you can substitute $$y$$ anywhere you see $$f(x)$$. In imperative
languages, you cannot:  $$f$$ might have side effects, so computing $$f(x)$$ at
time $$t$$ might result in a different value than at time $$t'$$.

It's tempting to believe that there's a single state that the machine
manipulates, and that the machine does one thing at a time. Computer
systems go to great lengths in attempting to provide that illusion. But
it's just that: an illusion.  In reality, there are many states, spread
across threads, cores, processors, and networked computers.  And the
machine does many things concurrently.  Mutability makes reasoning about
distributed state and concurrent execution immensely difficult.

*Immutability*, however, frees the programmer from these concerns.  It provides
powerful ways to build correct and concurrent programs.  OCaml is primarily
an immutable language, like most functional languages.  It does support
imperative programming with mutable state, but we won't use those features
until about two months into the course&mdash;in part because we simply won't need
them, and in part to get you to quit "cold turkey" from a dependence you might
not have known that you had.  This freedom from mutability is one of the biggest
changes in perspective that 3110 can give you.
