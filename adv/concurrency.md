# Concurrency

So far in this class we have only considered *sequential* programs.
Execution of a sequential program proceeds one step at a time, with no
choice about which step to take next. Sequential programs are limited in
that they are not very good at dealing with multiple sources of
simultaneous input and they can only execute on a single processor. 
Many modern applications are instead *concurrent*.  Concurrent programs
enable computations to overlap in duration, instead of being forced
to happen sequentially.

*Graphical user interfaces* (GUIs), for example, rely on concurrency to
keep the interface responsive while computation continues in the
background.

* A spreadsheet needs concurrency to re-compute all the cells while 
  still keeping the menus and editing capabilities available for
  the user.  
  
* A web browser needs concurrency to read and render web pages 
  incrementally as new data comes in over the network, to run 
  JavaScript programs embedded in the web page, and to enable
  the user to navigate through the page and click on hyperlinks.
  
Without concurrency, a GUI would "lock up" until the current
action is completed.  Sometimes, because of concurrency bugs, that
happens anyway&mdash;and it's frustrating for the user!

*Servers* are another example of applications that need concurrency.
A web server needs to respond to many requests from clients, and 
clients would prefer not to wait.  If an assignment is released in CMS,
for example, you would prefer to be able to view that assignment at
the same time as everyone else in the class, rather than having to
"take a number" a wait for your number to be called&mdash;as at
the Department of Motor Vehicles, or at an old-fashioned deli, etc.

One of the primary jobs of an *operating system* (OS) is to provide
concurrency.  The OS makes it possible for many applications to
be executing concurrently:  a music player, a web browser, a code
editor, etc.  How does it do that?  There are two fundamental,
complementary approaches:

* **Interleaving:**  rapidly switch back and forth between computations.
  For example, execute the music player for 100 milliseconds, then the
  browser, then the editor, then repeat.  That makes it appear as though
  multiple computations are occurring simultaneously, but in reality,
  only one is ever occurring at the same time.  

* **Parallelism:**  use hardware that is capable of performing two
  or more computations literally at the same time.  Many processors
  these days are *multicore*, meaning that they have multiple
  central processing units (CPUs), each of which can be executing
  a program simultaneously.

## Challenges of Concurrency

Regardless of the approaches being used, concurrent programming is
challenging.  Even if there are multiple cores available for
simultaneous use, there are still many other resources that must be
shared:  memory, the screen, the network interface, etc. Managing that
sharing, especially without introducing bugs, is quite difficult.  For
example, if two programs want to communicate by using the computer's
memory, there needs to be some agreement on when each program is allowed
to read and write from the memory. Otherwise, for example, both programs
might attempt to write to the same location in memory, leading to
corrupted data. Those kinds of *race conditions*, where a program races
to complete its operations before another program, are notoriously
difficult to avoid.

The most fundamental challenge is that concurrency makes the execution
of a program become *nondeterministic:* the order in which operations
occur cannot necessarily be known ahead of time.  Race conditions are an
example of nondeterminism.  To program correctly in the face of
nondeterminism, the programmer is forced to think about *all* possible
orders in which operations might execute, and ensure that in *all* of
them the program works correctly. 

Purely functional programs make nondeterminism easier to reason about,
because evaluation of an expression always returns the same value no
matter what. For example, in the expression `(2*4)+(3*5)`, the
operations can be executed concurrently (e.g., with the left and right
products evaluated simultaneously) without changing the answer.
Imperative programming is more problematic. For example, the expressions
`!x` and `incr x; !x`, if executed concurrently, could give different
results depending on which executes first.

## Threads

To make concurrent programming easier, computer scientists have invented
many abstractions.  One of the best known is *threads*. Abstractly, a
thread is a single sequential computation.  There can be many threads
running at a time, either interleaved or in parallel depending on the
hardware, and a *scheduler* handles choosing which threads are running
at any given time.  Scheduling can either be *preemptive*, meaning that
the scheduler is permitted to stop a thread and restart it later without
the thread getting a choice in the matter, or *cooperative*, meaning
that the thread must choose to relinquish control back to the scheduler.
The former can lead to race conditions, and the latter can lead to
unresponsive applications.

Concretely, a thread is a set of values that are loaded into the
registers of a processor.  Those values tell the processor where to find
the next instruction to execute, where its stack and heap are located in
memory, etc.  To implement preemption, a scheduler sets a timer in the
hardware; when the timer goes off, the current thread is interrupted and
the scheduler gets to run.  CS 3410 and 4410 cover those concepts in
detail.

## Promises

In the functional programming paradigm, one of the best known
abstractions for concurrency is *promises*.  Other names for this idea
include *futures*, *deferreds*, and *delayeds*.  All those names refer
to the idea of a computation that is not yet finished:  it has promised
to eventually produce a value in the future, but the completion of the
computation has been deferred or delayed.  There may be many such
values being computed concurrently, and when the value is finally
available, there may be computations ready to execute that depend on
the value.

This idea has been widely adopted in many languages and libraries,
including Java, JavaScript, and .NET.  Indeed, modern JavaScript
adds an `async` keyword that causes a function to return a promise,
and an `await` keyword that waits for a promise to finish computing.
There are two widely-used libraries in OCaml that implement promises:
Async and Lwt.  Async is developed by Jane Street.  Lwt is part of
the Ocsigen project, which is a web framework for OCaml.

We now take a deeper look at promises in Lwt.  The name of the library
was an acronym for "light-weight threads."  But that was a misnomer,
as the [Github page][lwt-github] admits (as of 10/22/18):

> Much of the current manual refers to ... "lightweight threads" or 
just "threads." This will be fixed in the new manual. 
[Lwt implements] promises, and has nothing to do with system 
or preemptive threads.

So don't think of Lwt as having anything to do with threads:  it
really is a library for promises.

[lwt-github]: https://github.com/ocsigen/lwt


