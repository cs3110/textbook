# OCaml

We begin this course by studying OCaml for that very reason:
it's a vastly different perspective from what most of you will have seen
in previous programming courses.  Since you've already taken 1110 and 2110, you
have learned how to program.  This course gives you the opportunity to
now learn a new language from scratch and reflect along the way about
the difference between *programming* and *programming in a language.*

> "A language that doesn't affect the way you think about
> programming is not worth knowing."
> &mdash;Alan J. Perlis (1922-1990), first recipient of the Turing Award

**OCaml will change the way you think about programming.**

OCaml is a *functional* programming language.  The key linguistic
abstraction of functional languages is the mathematical function.  A
function maps an input to an output; for the same input, it always
produces the same output.  That is, mathematical functions are
*stateless*:  they do not maintain any extra information or *state* that
persists between usages of the function. Functions are *first-class*:
you can use them as input to other functions, and produce functions as
output. Expressing everything in terms of functions enables a uniform
and simple programming model that is easier to reason about than the
procedures and methods found in other families of languages.

OCaml supports a number of advanced features, some of which you will
have encountered before, and some of which are likely to be new:

-   **Algebraic datatypes:**  You can build sophisticated data
    structures in OCaml easily, without fussing with pointers and
    memory management. *Pattern matching* makes them even more
    convenient.

-   **Type inference:**  You do not have to write type information
    down everywhere.  The compiler automatically figures out most
    types.  This can make the code easier to read and maintain.

-   **Parametric polymorphism:**  Functions and data
    structures can be parameterized over types.  This is crucial for
    being able to re-use code.

-   **Garbage collection:**  Automatic memory
    management relieves you from the burden of memory allocation and deallocation,
    a common source of bugs in languages such as C.

-   **Modules:** OCaml makes it easy to structure large
    systems through the use of modules.  Modules (called *structures*)
    are used to encapsulate implementations behind interfaces (called
    *signatures*).  OCaml goes well beyond the functionality of most
    languages with modules by providing functions (called *functors*)
    that manipulate modules.

OCaml is a *statically-typed* and *type-safe* programming language. A
statically-typed language detects type errors at compile time, so that
programs with type errors cannot be executed. A type-safe language
limits which kinds of operations can be performed on which kinds of data. 
In practice, this prevents a lot of silly errors (e.g., treating an
integer as a function) and also prevents a lot of security problems: 
over half of the reported break-ins at the Computer Emergency Response
Team (CERT, a US government agency tasked with cybersecurity) were due
to buffer overflows, something that's impossible in a type-safe language.

Some languages, like Scheme and Lisp, are type-safe but *dynamically
typed*. That is, type errors are caught only at run time. Other
languages, like C and C++, are statically typed but not type safe.
There's no guarantee that a type error won't occur.

Genealogically, OCaml comes from the line of programming languages whose
grandfather is Lisp and includes modern languages such as Clojure, F#, Haskell,
and Racket. Functional languages have a surprising tendency to
predict the future of more mainstream languages. Java brought garbage
collection into the mainstream in 1995; Lisp had it in 1958. Java didn't
have generics until version 5 in 2004; the ML family had it in 1990.
First-class functions and type inference have been incorporated into
mainstream languages like Java, C#, and C++ over the last 10 years, long
after functional languages introduced them.  By studying functional
programming, you get a taste of what might be coming down the pipe next.
 Who knows what it might be? (My bet would be pattern matching.)

## A digression on the history of OCaml

Robin Milner and others at the Edinburgh Laboratory for Computer Science
in Scotland were working on theorem provers in the late '70s and early
'80s. Traditionally, theorem provers were implemented in languages such
as Lisp. Milner kept running into the problem that the theorem provers
would sometimes put incorrect "proofs" (i.e., non-proofs) together and
claim that they were valid.  So he tried to develop a language that only
allowed you to construct valid proofs. ML, which stands for "Meta
Language", was the result of that work.  The type system of ML was
carefully constructed so that you could only construct valid proofs in
the language.  A theorem prover was then written as a program that
constructed a proof. Eventually, this "Classic ML" evolved into a
full-fledged programming language.

In the early '80s, there was a schism in the ML community with the
French on one side and the British and US on another.  The French went
on to develop CAML and later Objective CAML (OCaml) while the Brits and
Americans developed Standard ML.  The two dialects are quite similar.
Microsoft introduced its own variant of OCaml called F# in 2005.

Milner received the Turing Award in 1991 in large part for his work on ML.
The award citation includes this praise:  "ML was way ahead of its time.
It is built on clean and well-articulated mathematical ideas, teased apart
so that they can be studied independently and relatively easily remixed and
reused. ML has influenced many practical languages, including Java, Scala,
and Microsoft's F#. Indeed, no serious language designer should ignore
this example of good design."

## Industry

OCaml and other functional languages are nowhere near as popular
as C, C++, and Java.  OCaml's real strength lies in language manipulation
(i.e., compilers, analyzers, verifiers, provers, etc.).  This is not
surprising, because OCaml evolved from the domain of theorem proving.

That's not to say that functional languages aren't used in industry.
There are many [industry projects using OCaml][ocaml-industry]
and [Haskell][haskell-industry], among other languages.  A Cornellian,
Yaron Minsky (PhD '02), wrote a paper about [using OCaml in the financial
industry][minsky] (that link must be accessed from inside Cornell's network).
It explains how the features of OCaml make it a good choice for quickly
building complex software that works.

[minsky]: http://dx.doi.org/10.1017/S095679680800676X
[ocaml-industry]: https://ocaml.org/learn/companies.html
[haskell-industry]: https://wiki.haskell.org/Haskell_in_industry

But ultimately this course is about your education as a programmer, not
about finding you a job.

> "Education is what remains after one has forgotten everything one learned
> in school."
> &mdash;Albert Einstein

OCaml does a great job of clarifying and simplifying the essence of
functional programming in a way that other languages that blend
functional and imperative programming (like Scala) or take functional
programming to the extreme (like Haskell) do not.  Having learned OCaml,
you'll be well equipped to teach yourself any other
functional(-inspired) language.

## Beauty

A non-scientific, subjective reason to study OCaml that I will put forth as
my own opinion:  OCaml is beautiful.

> "Beauty is our Business"
> &mdash;title of a book in honor of Edsger W. Dijkstra

(Dijkstra was the recipient of the Turing award in 1972 for "fundamental
contributions to programming."  David Gries was an editor of the book.)

OCaml is elegant, simple, and graceful.  The code you write can be stylish and
tasteful.  At first, this might not be apparent.  You are
learning a new language after all&mdash;you wouldn't expect to appreciate
Sanskrit poetry on day 1 of [SANSK 1131][sansk1131].  In fact, you'll likely
feel frustrated for awhile as you struggle to express yourself in a new language.
So give it some time.  I've lost track of how many students have come back to tell
me in future semesters how "ugly" other languages felt after they went back to
writing in them after 3110.

[sansk1131]: https://classes.cornell.edu/browse/roster/FA17/class/SANSK/1131

Aesthetics do matter.  Code isn't written just to be executed by machines.
It's also written to communicate to humans.  Elegant code is easier to
read and maintain.  It isn't necessarily easier to write.

