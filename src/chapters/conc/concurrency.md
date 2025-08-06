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

# Concurrency

Concurrent programs enable computations to overlap in duration, instead of being
forced to happen sequentially.

* *Graphical user interfaces* (GUIs), for example, rely on concurrency to keep
  the interface responsive while computation continues in the background.
  Without concurrency, a GUI would "lock up" until the current action is
  completed. Sometimes, because of concurrency bugs, that happens
  anyway&mdash;and it's frustrating for the user!

* A spreadsheet needs concurrency to re-compute all the cells while still
  keeping the menus and editing capabilities available for the user.

* A web browser needs concurrency to read and render web pages incrementally as
  new data comes in over the network, to run JavaScript programs embedded in the
  web page, and to enable the user to navigate through the page and click on
  hyperlinks.

*Servers* are another example of applications that need concurrency. A web
server needs to respond to many requests from clients, and clients would prefer
not to wait. If an assignment is released in CMS, for example, you would prefer
to be able to view that assignment at the same time as everyone else in the
class, rather than having to "take a number" and wait for your number to be
called&mdash;as at the Department of Motor Vehicles, or at an old-fashioned
deli, etc.

One of the primary jobs of an *operating system* (OS) is to provide concurrency.
The OS makes it possible for many applications to be executing concurrently: a
music player, a web browser, a code editor, etc. How does it do that? There are
two fundamental, complementary approaches:

* **Interleaving:** rapidly switch back and forth between computations. For
  example, execute the music player for 100 milliseconds, then the browser, then
  the editor, then repeat. That makes it appear as though multiple computations
  are occurring simultaneously, but in reality, only one is ever occurring at
  the same time.

* **Parallelism:** use hardware that is capable of performing two or more
  computations literally at the same time. Many processors these days are
  *multicore*, meaning that they have multiple central processing units (CPUs),
  each of which can be executing a program simultaneously.

Regardless of the approaches being used, concurrent programming is challenging.
Even if there are multiple cores available for simultaneous use, there are still
many other resources that must be shared: memory, the screen, the network
interface, etc. Managing that sharing, especially without introducing bugs, is
quite difficult. For example, if two programs want to communicate by using the
computer's memory, there needs to be some agreement on when each program is
allowed to read and write from the memory. Otherwise, for example, both programs
might attempt to write to the same location in memory, leading to corrupted
data. Those kinds of *race conditions*, where a program races to complete its
operations before another program, are notoriously difficult to avoid.

The most fundamental challenge is that concurrency makes the execution of a
program become *nondeterministic:* the order in which operations occur cannot
necessarily be known ahead of time. Race conditions are an example of
nondeterminism. To program correctly in the face of nondeterminism, the
programmer is forced to think about *all* possible orders in which operations
might execute, and ensure that in *all* of them the program works correctly.

Purely functional programs make nondeterminism easier to reason about, because
evaluation of an expression always returns the same value no matter what. For
example, in the expression `(2 * 4) + (3 * 5)`, the operations can be executed
concurrently (e.g., with the left and right products evaluated simultaneously)
without changing the answer. Imperative programming is more problematic. For
example, the expressions `!x` and `incr x; !x`, if executed concurrently, could
give different results depending on which executes first.

## Threads

To make concurrent programming easier, computer scientists have invented many
abstractions. One of the best known is *threads*. Abstractly, a thread is a
single sequential computation. There can be many threads running at a time,
either interleaved or in parallel depending on the hardware, and a *scheduler*
handles choosing which threads are running at any given time. Scheduling can
either be *preemptive*, meaning that the scheduler is permitted to stop a thread
and restart it later without the thread getting a choice in the matter, or
*cooperative*, meaning that the thread must choose to relinquish control back to
the scheduler. The former can lead to race conditions, and the latter can lead
to unresponsive applications.

Concretely, a thread is a set of values that are loaded into the
registers of a processor.  Those values tell the processor where to find
the next instruction to execute, where its stack and heap are located in
memory, etc.  To implement preemption, a scheduler sets a timer in the
hardware; when the timer goes off, the current thread is interrupted and
the scheduler gets to run. Courses on systems programming and operating systems
will typically cover these concepts in detail.
