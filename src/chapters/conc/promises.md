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

# Promises

In the functional programming paradigm, one of the best known abstractions for
concurrency is *promises*. Other names for this idea include *futures*,
*deferreds*, and *delayeds*. All those names refer to the idea of a computation
that is not yet finished: it has promised to eventually produce a value in the
future, but the completion of the computation has been deferred or delayed.
There may be many such values being computed concurrently, and when the value is
finally available, there may be computations ready to execute that depend on the
value.

This idea has been widely adopted in many languages and libraries, including
Java, JavaScript, and .NET. Indeed, modern JavaScript adds an `async` keyword
that causes a function to return a promise, and an `await` keyword that waits
for a promise to finish computing. There are two widely-used libraries in OCaml
that implement promises: Async and Lwt. Async is developed by Jane Street. Lwt
is part of the Ocsigen project, which is a web framework for OCaml.

We now take a deeper look at promises in Lwt. The name of the library was an
acronym for "light-weight threads." But that was a misnomer, as the
[GitHub page][lwt-github] admits (as of 10/22/18):

> Much of the current manual refers to ... "lightweight threads" or
just "threads." This will be fixed in the new manual. [Lwt implements] promises,
and has nothing to do with system or preemptive threads.

So don't think of Lwt as having anything to do with threads: it really is a
library for promises.

[lwt-github]: https://github.com/ocsigen/lwt

In Lwt, a *promise* is a
reference: a value that is permitted to
mutate at most once. When created, it is like an empty box that contains
nothing. We say that the promise is *pending*. Eventually the promise can be
*fulfilled*, which is like putting something inside the box. Instead of being
fulfilled, the promise can instead be *rejected*, in which case the box is filled
with an exception. In either case, fulfilled or rejected, we say that the promise
is *resolved*. Regardless of whether the promise is resolved or rejected,
once the box is filled, its contents may never change.

For now, we will mostly forget about concurrency. Later we'll come back and
incorporate it. But there is one part of the design for concurrency that we need
to address now. When we later start using functions for OS-provided concurrency,
such as concurrent reads and writes from files, there will need to be a division
of responsibilities:

* The client code that wants to make use of concurrency will need to *access*
  promises: query whether they are resolved or pending, and make use of the
  resolved values.

* The library and OS code that implements concurrency will need to *mutate* the
  promise&mdash;that is, to actually fulfill or reject it. Client code does not
  need that ability.

We therefore will introduce one additional abstraction called a *resolver*.
There will be a one-to-one association between promises and resolvers. The
resolver for a promise will be used internally by the concurrency library but
not revealed to clients. The clients will only get access to the promise.

For example, suppose the concurrency library supported an operation to
concurrently read a string from the network. The library would implement that
operation as follows:

* Create a new promise and its associated resolver. The promise is pending.

* Call an OS function that will concurrently read the string then invoke the
  resolver on that string.

* Return the promise (but not resolver) to the client. The OS meanwhile
  continues to work on reading the string.

You might think of the resolver as being a "private and writeable" value used
primarily by the library and the promise as being a "public and read-only" value
used primarily by the client.
