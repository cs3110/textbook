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

So far we have only considered *sequential* programs. Execution of a sequential
program proceeds one step at a time, with no choice about which step to take
next. Sequential programs are limited in that they are not very good at dealing
with multiple sources of simultaneous input, and they can only execute on a
single processor. Many modern applications are instead *concurrent*.

## Concurrency

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
class, rather than having to "take a number" a wait for your number to be
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
the scheduler gets to run.  CS 3410 and 4410 cover those concepts in
detail.

## Promises

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
*resolved*, which is like putting something inside the box. Instead of being
resolved, the promise can instead be *rejected*, in which case the box is filled
with an exception. Regardless of whether the promise is resolved or rejected,
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
  promise&mdash;that is, to actually resolve or reject it. Client code does not
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

## Making Our Own Promises

Here is an interface for our own Lwt-style promises. The names have been changed
to make the interface clearer.

```{code-cell} ocaml
(** A signature for Lwt-style promises, with better names. *)
module type PROMISE = sig
  type 'a state =
    | Pending
    | Resolved of 'a
    | Rejected of exn

  type 'a promise

  type 'a resolver

  (** [make ()] is a new promise and resolver. The promise is pending. *)
  val make : unit -> 'a promise * 'a resolver

  (** [return x] is a new promise that is already resolved with value
      [x]. *)
  val return : 'a -> 'a promise

  (** [state p] is the state of the promise. *)
  val state : 'a promise -> 'a state

  (** [resolve r x] resolves the promise [p] associated with [r] with
      value [x], meaning that [state p] will become [Resolved x].
      Requires: [p] is pending. *)
  val resolve : 'a resolver -> 'a -> unit

  (** [reject r x] rejects the promise [p] associated with [r] with
      exception [x], meaning that [state p] will become [Rejected x].
      Requires: [p] is pending. *)
  val reject : 'a resolver -> exn -> unit
end
```

To implement that interface, we can make the representation type of
`'a promise` be a reference to a state:

```{code-cell} ocaml
type 'a state = Pending | Resolved of 'a | Rejected of exn
type 'a promise = 'a state ref
```

That way it's possible to mutate the contents of the promise.

For the representation type of the resolver, we'll do something a little clever.
It will simply be the same as a promise.

```{code-cell} ocaml
type 'a resolver = 'a promise
```

So internally, the two types are exactly the same. But externally no client of
the `Promise` module will be able to distinguish them. In other words, we're
using the type system to control whether it's possible to apply certain
functions (e.g., `state` vs `resolve`) to a promise.

To help implement the rest of the functions, let's start by writing a helper
function `write_once : 'a promise -> 'a state -> unit` to update the reference. This
function will implement changing the state of the promise from pending to either
resolved or rejected, and once the state has changed, it will not allow it to be
changed again. That is, it enforces the "write once" invariant.

```{code-cell} ocaml
(** [write_once p s] changes the state of [p] to be [s].  If [p] and [s]
    are both pending, that has no effect.
    Raises: [Invalid_arg] if the state of [p] is not pending. *)
let write_once p s =
  if !p = Pending
  then p := s
  else invalid_arg "cannot write twice"
```

Using that helper, we can implement the `make` function:

```{code-cell} ocaml
let make () =
  let p = ref Pending in
  p, p
```

The remaining functions in the interface are trivial to implement.
Putting it altogether in a module, we have:

```{code-cell} ocaml
module Promise : PROMISE = struct
  type 'a state =
    | Pending
    | Resolved of 'a
    | Rejected of exn

  type 'a promise = 'a state ref

  type 'a resolver = 'a promise

  (** [write_once p s] changes the state of [p] to be [s]. If [p] and
      [s] are both pending, that has no effect. Raises: [Invalid_arg] if
      the state of [p] is not pending. *)
  let write_once p s =
    if !p = Pending then p := s else invalid_arg "cannot write twice"

  let make () =
    let p = ref Pending in
    (p, p)

  let return x = ref (Resolved x)

  let state p = !p

  let resolve r x = write_once r (Resolved x)

  let reject r x = write_once r (Rejected x)
end
```

## Lwt Promises

The types and names used in Lwt are a bit more obscure than those we used above.
Lwt uses analogical terminology that comes from threads&mdash;but since Lwt does
not actually implement threads, that terminology is not necessarily helpful. (We
don't mean to demean Lwt! It is a library that has been developing and changing
over time.)

The Lwt interface includes the following declarations, which we have annotated
with comments to compare them to the interface we implemented above:

```{code-cell} ocaml
module type Lwt = sig
  (* [Sleep] means pending.  [Return] means resolved.
     [Fail] means rejected. *)
  type 'a state = Sleep | Return of 'a | Fail of exn

  (* a [t] is a promise *)
  type 'a t

  (* a [u] is a resolver *)
  type 'a u

  val state : 'a t -> 'a state

  (* [wakeup] means [resolve] *)
  val wakeup : 'a u -> 'a -> unit

  (* [wakeup_exn] means [reject] *)
  val wakeup_exn : 'a u -> exn -> unit

  (* [wait] means [make] *)
  val wait : unit -> 'a t * 'a u

  val return : 'a -> 'a t
end
```

Lwt's implementation of that interface is much more complex than our own
implementation above, because Lwt actually supports many more operations on
promises. Nonetheless, the core ideas that we developed above provide sound
intuition for what Lwt implements.

Here is some example Lwt code that you can try out in utop:

```{code-cell} ocaml
:tags: ["remove-cell"]
#use "topfind";;
```

```{code-cell} ocaml
:tags: ["remove-output"]
#require "lwt";;
```

```{code-cell} ocaml
let p, r = Lwt.wait();;
```

To avoid those weak type variables, we can provide a further hint to OCaml as to
what type we want to eventually put into the promise. For example, if we wanted
to have a promise that will eventually contain an `int`, we could write this
code:
```{code-cell} ocaml
let (p : int Lwt.t), r = Lwt.wait ()
```

Now we can resolve the promise:

```{code-cell} ocaml
Lwt.state p
```
```{code-cell} ocaml
Lwt.wakeup r 42
```
```{code-cell} ocaml
Lwt.state p;;
```
```{code-cell} ocaml
:tags: ["raises-exception"]
Lwt.wakeup r 42
```

That last exception was raised because we attempted to resolve the promise a
second time, which is not permitted.

To reject a promise, we can write similar code:

```{code-cell} ocaml
let (p : int Lwt.t), r = Lwt.wait ();;
Lwt.wakeup_exn r (Failure "nope");;
Lwt.state p;;
```

Note that nothing we have implemented so far does anything concurrently.
The promise abstraction by itself is not inherently concurrent.  It's
just a data structure that can be written at most once, and that provides
a means to control who can write to it (through the resolver).

## Asynchronous I/O

Now that we understand promises as a data abstraction, let's turn to how they
can be used for concurrency. The typical way they're used with Lwt is for
concurrent input and output (I/O).

The I/O functions that are part of the OCaml standard library are *synchronous*
aka *blocking*: when you call such a function, it does not return until the I/O
has been completed. "Synchronous" here refers to the synchronization between
your code and the I/O function: your code does not get to execute again until
the I/O code is done. "Blocking" refers to the fact that your code has to
wait&mdash;it is blocked&mdash;until the I/O completes.

For example, the `Stdlib.input_line : in_channel -> string` function reads
characters from an *input channel* until it reaches a newline character, then
returns the characters it read. The type `in_channel` is abstract; it represents
a source of data that can be read, such as a file, or the network, or the
keyboard. The value `Stdlib.stdin : in_channel` represents the *standard input*
channel, which is the channel which usually, by default, provides keyboard
input.

If you run the following code in utop, you will observe the blocking behavior:

```text
# ignore(input_line stdin); print_endline "done";;
<type your own input here>
done
- : unit = ()
```

The string `"done"` is not printed until after the input operation completes,
which happens after you type Enter.

Synchronous I/O makes it impossible for a program to carry on other computations
while it is waiting for the I/O operation to complete. For some programs that's
just fine. A text adventure game, for example, doesn't have any background
computations it needs to perform. But other programs, like spreadsheets or
servers, would be improved by being able to carry on computations in the
background rather than having to completely block while waiting for input.

*Asynchronous* aka *non-blocking* I/O is the opposite style of I/O. Asynchronous
I/O operations return immediately, regardless of whether the input or output has
been completed. That enables a program to launch an I/O operation, carry on
doing other computations, and later come back to make use of the completed
operation.

The Lwt library provides its own I/O functions in the `Lwt_io` module, which is
in the `lwt.unix` package. The function
`Lwt_io.read_line : Lwt_io.input_channel -> string Lwt.t` is the asynchronous
equivalent of `Stdlib.input_line`. Similarly, `Lwt_io.input_channel` is the
equivalent of the OCaml standard library's `in_channel`, and `Lwt_io.stdin`
represents the standard input channel.

Run this code in utop to observe the non-blocking behavior:

```text
# #require "lwt.unix";;
# open Lwt_io;;
# ignore(read_line stdin); printl "done";;
done
- : unit = ()
# <type your own input here>
```

The string `"done"` is printed immediately by `Lwt_io.printl`, which is Lwt's
equivalent of `Stdlib.print_endline`, before you even type. Note that it's best
to use just one library's I/O functions, rather than mix them together.

When you do type your input, you don't see it echoed to the screen, because it's
happening in the background. Utop is still executing&mdash;it is not
blocked&mdash;but your input is being sent to that `read_line` function instead
of to utop. When you finally type Enter, the input operation completes, and you
are back to interacting with utop.

Now imagine that instead of reading a line asynchronously, the program was a web
server reading a file to be served to a client. And instead of printing a
string, the server was delivering the contents of a different file that had
completed reading to a different client. That's why asynchronous I/O can be so
useful: it helps to *hide latency*. Here, "latency" means waiting for data to be
transferred from one place to another, e.g., from disk to memory. Latency hiding
is an excellent use for concurrency.

Note that all the concurrency here is really coming from the operating system,
which is what provides the underlying asynchronous I/O infrastructure. Lwt is
just exposing that infrastructure to you through a library.

## Promises and Asynchronous I/O

The output type of `Lwt_io.read_line` is `string Lwt.t`, meaning that the
function returns a `string` promise. Let's investigate how the state of that
promise evolves.

When the promise is returned from `read_line`, it is pending:

```text
# let p = read_line stdin in Lwt.state p;;
- : string Lwt.state = Lwt.Sleep
# <now you have to type input and Enter to regain control of utop>
```

When the Enter key is pressed and input is completed, the promise returned from
`read_line` should become resolved. For example, suppose you enter "Camels are
bae":

```text
# let p = read_line stdin;;
val p : string Lwt.t = <abstr>
<now you type Camels are bae followed by Enter>
# p;;
- : string = "Camels are bae"
```

But, if you study that output carefully, you'll notice something very strange
just happened! After the `let` statement, `p` had type `string Lwt.t`, as
expected. But when we evaluated `p`, it came back as type `string`. It's as if
the promise disappeared.

What's actually happening is that utop has some special&mdash;and potentially
confusing&mdash;functionality built into it that is related to Lwt.
Specifically, whenever you try to directly evaluate a promise at the top level,
*utop will give you the contents of the promise, rather than the promise itself,
and if the promise is not yet resolved, utop will block until the promise
becomes resolved so that the contents can be returned.*

So the output `- : string = "Camels are bae"` really means that `p` contains a
resolved `string` whose value is `"Camels are bae"`, not that `p` itself is a
`string`. Indeed, the `#show_val` directive will show us that `p` is a promise:

```text
# #show_val p;;
val p : string Lwt.t
```

To disable that feature of utop, or to re-enable it, call the function
`UTop.set_auto_run_lwt : bool -> unit`, which changes how utop evaluates Lwt
promises at the top level. You can see the behavior change in the following
code:

```text
# UTop.set_auto_run_lwt false;;
- : unit = ()
<now you type Camels are bae followed by Enter>
# p;;
- : string Lwt.state = <abstr>
# Lwt.state p;;
- : string Lwt.state = Lwt.Return "Camels are bae"
```

If you re-enable this "auto run" feature, and directly try to evaluate the
promise returned by `read_line`, you'll see that it behaves exactly like
synchronous I/O, i.e., `Stdlib.input_line`:

```text
# UTop.set_auto_run_lwt true;;
- : unit = ()
# read_line stdin;;
Camels are bae
- : string = "Camels are bae"
```

Because of the potential confusion, we will henceforth assume that auto running
is disabled. A good way to make that happen is to put the following line in your
`.ocamlinit` file:

```text
UTop.set_auto_run_lwt false;;
```

## Callbacks

For a program to benefit from the concurrency provided by asynchronous
I/O and promises, there needs to be a way for the program to make use of
resolved promises.  For example, if a web server is asynchronously
reading and serving multiple files to multiple clients, the server needs
a way to (i) become aware that a read has completed, and (ii) then do a
new asynchronous write with the result of the read. In other words,
programs need a mechanism for managing the dependencies among promises.

The mechanism provided in Lwt is named *callbacks.*  A callback is a
function that will be run sometime after a promise has been resolved,
and it will receive as input the contents of the resolved promise.
Think of it like asking your friend to do some work for you: they
promise to do it, and to call you back on the phone with the result of
the work sometime after they've finished.

**Registering a callback.** Here is a function that prints a string using Lwt's
version of the `printf` function:
```ocaml
let print_the_string str = Lwt_io.printf "The string is: %S\n" str
```

And here, repeated from the previous section, is our code that returns a promise
for a string read from standard input:
```ocaml
let p = read_line stdin
```

To register the printing function as a callback for that promise, we use the
function `Lwt.bind`, which *binds* the callback to the promise:

```ocaml
Lwt.bind p print_the_string
```

Sometime after `p` is resolved, hence contains a string, the callback function
will be run with that string as its input. That causes the string to be printed.

Here's a complete utop transcript as an example of that:
```text
# let print_the_string str = Lwt_io.printf "The string is: %S\n" str;;
val print_the_string : string -> unit Lwt.t = <fun>
# let p = read_line stdin in Lwt.bind p print_the_string;;
- : unit Lwt.t = <abstr>
  <type Camels are bae followed by Enter>
# The string is: "Camels are bae"
```

**Bind.** The type of `Lwt.bind` is important to understand:
```ocaml
'a Lwt.t -> ('a -> 'b Lwt.t) -> 'b Lwt.t
```

The `bind` function takes a promise as its first argument. It doesn't matter
whether that promise has been resolved yet or not. As its second argument,
`bind` takes a callback function. That callback takes an input which is the same
type `'a` as the contents of the promise. It's not an accident that they have
the same type: the whole idea is to eventually run the callback on the resolved
promise, so the type the promise contains needs to be the same as the type the
callback expects as input.

After being invoked on a promise and callback, e.g., `bind p c`, the `bind`
function does one of three things, depending on the state of `p`:

* If `p` is already resolved, then `c` is run immediately on the contents of
  `p`. The promise that is returned might or might not be pending, depending on
  what `c` does.

* If `p` is already rejected, then `c` does not run. The promise that is
  returned is also rejected, with the same exception as `p`.

* If `p` is pending, then `bind` does not wait for `p` to be resolved, nor for
  `c` to be run. Rather, `bind` just registers the callback to eventually be run
  when (or if) the promise is resolved. Therefore, the `bind` function returns a
  new promise. That promise will become resolved when (or if) the callback
  completes running, sometime in the future. Its contents will be whatever
  contents are contained within the promise that the callback itself returns.

```{note}
For the first case above: The Lwt source code claims that this behavior might
change in a later version: under high load, `c` might be registered to run
later. But as of v4.1.0 that behavior has not yet been activated. So, don't
worry about it&mdash;this paragraph is just here to future-proof this
discussion.
```

Let's consider that final case in more detail. We have one promise of type
`'a Lwt.t` and two promises of type `'b Lwt.t`:

* The promise of type `'a Lwt.t`, call it promise X, is an input to `bind`. It
  was pending when `bind` was called, and when `bind` returns.

* The first promise of type `'b Lwt.t`, call it promise Y, is created by `bind`
  and returned to the user. It is pending at that point.

* The second promise of type `'b Lwt.t`, call it promise Z, has not yet been
  created. It will be created later, when promise X has been resolved, and the
  callback has been run on the contents of X. The callback then returns promise
  Z. There is no guarantee about the state of Z; it might well still be pending
  when returned by the callback.

* When Z is finally resolved, the contents of Y are updated to be the same as
  the contents of Z.

The reason why `bind` is designed with this type is so that programmers can set
up a *sequential chain* of callbacks. For example, the following code
asynchronously reads one string; then when that string has been read, proceeds
to asynchronously read a second string; then prints the concatenation of both
strings:

```ocaml
Lwt.bind (read_line stdin) (fun s1 ->
  Lwt.bind (read_line stdin) (fun s2 ->
    Lwt_io.printf "%s\n" (s1^s2)));;
```

If you run that in utop, something slightly confusing will happen again: after
you press Enter at the end of the first string, Lwt will allow utop to read one
character. The problem is that we're mixing Lwt input operations with utop input
operations. It would be better to just create a program and run it from the
command line.

To do that, put the following code in a file called `read2.ml`:
```ocaml
open Lwt_io

let p =
  Lwt.bind (read_line stdin) (fun s1 ->
    Lwt.bind (read_line stdin) (fun s2 ->
      Lwt_io.printf "%s\n" (s1^s2)))

let _ = Lwt_main.run p
```

We've added one new function: `Lwt_main.run : 'a Lwt.t -> 'a`. It waits for its
input promise to be resolved, then returns the contents. Typically this function
is called only once in an entire program, near the end of the main file; and the
input to it is typically a promise whose resolution indicates that all execution
is finished.

Create a dune file:
```text
(executable
 (name read2)
 (libraries lwt.unix))
```

And run the program, entering a couple strings:
```console
dune exec ./read2.exe
My first string
My second string
My first stringMy second string
```

Now try removing the last line of `read2.ml`.  You'll see that the program
exits immediately, without waiting for you to type.

**Bind as an Operator.** There is another syntax for bind that is used far more
frequently than what we have seen so far. The `Lwt.Infix` module defines an
infix operator written `>>=` that is the same as `bind`. That is, instead of
writing `bind p c` you write `p >>= c`. This operator makes it much easier to
write code without all the extra parentheses and indentations that our previous
example had:

```ocaml
open Lwt_io
open Lwt.Infix

let p =
  read_line stdin >>= fun s1 ->
  read_line stdin >>= fun s2 ->
  Lwt_io.printf "%s\n" (s1^s2)

let _ = Lwt_main.run p
```

The way to visually parse the definition of `p` is to look at each line as
computing some promised value. The first line, `read_line stdin >>= fun s1 ->`
means that a promise is created, resolved, and its contents extracted under the
name `s1`. The second line means the same, except that its contents are named
`s2`. The third line creates a final promise whose contents are eventually
extracted by `Lwt_main.run`, at which point the program may terminate.

The `>>=` operator is perhaps most famous from the functional language Haskell,
which uses it extensively for monads. We'll cover monads as our next major
topic.

**Bind as Let Syntax.** There is a *syntax extension* for OCaml that makes using
bind even simpler than the infix operator `>>=`. To install the syntax
extension, run the following command:

`$ opam install lwt_ppx`

(You might need to `opam update` followed by `opam upgrade` first.)

With that extension, you can use a specialized `let` expression written
`let%lwt x = e1 in e2`, which is equivalent to `bind e1 (fun x -> e2)` or
`e1 >>= fun x -> e2`. We can rewrite our running example as follows:

```ocaml
(* to compile, add lwt_ppx to the libraries in the dune file *)
open Lwt_io

let p =
  let%lwt s1 = read_line stdin in
  let%lwt s2 = read_line stdin in
  Lwt_io.printf "%s\n" (s1^s2)

let _ = Lwt_main.run p
```

Now the code looks pretty much exactly like what its equivalent synchronous
version would be. But don't be fooled: all the asynchronous I/O, the promises,
and the callbacks are still there. Thus, the evaluation of `p` first registers a
callback with a promise, then moves on to the evaluation of `Lwt_main.run`
without waiting for the first string to finish being read. To prove that to
yourself, run the following code:

```ocaml
open Lwt_io

let p =
  let%lwt s1 = read_line stdin in
  let%lwt s2 = read_line stdin in
  Lwt_io.printf "%s\n" (s1^s2)

let _ = Lwt_io.printf "Got here first\n"

let _ = Lwt_main.run p
```

You'll see that "Got here first" prints before you get a chance to enter any
input.

**Concurrent Composition.** The `Lwt.bind` function provides a way to
sequentially compose callbacks: first one callback is run, then another, then
another, and so forth. There are other functions in the library for composition
of many callbacks as a set. For example,

* `Lwt.join : unit Lwt.t list -> unit Lwt.t` enables waiting upon multiple
  promises. `Lwt.join ps` returns a promise that is pending until all the
  promises in `ps` become resolved. You might register a callback on the return
  promise from the `join` to take care of some computation that needs **all** of
  a set of promises to be finished.

* `Lwt.pick : 'a Lwt.t list -> 'a Lwt.t` also enables waiting upon multiple
  promises, but `Lwt.pick ps` returns a promise that is pending until at least
  one promise in `ps` becomes resolved. You might register a callback on the
  return promise from the `pick` to take care of some computation that needs
  just one of a set of promises to be finished, but doesn't care which one.

## Implementing Callbacks

When a callback is registered with `bind` or one of the other syntaxes, it is
added to a list of callbacks that is stored with the promise. Eventually, when
the promise has been resolved, the Lwt *resolution loop* runs the callbacks
registered for the promise. There is no guarantee about the execution order of
callbacks for a promise. In other words, the execution order is
nondeterministic. If the order matters, the programmer needs to use the
composition operators (such as `bind` and `join`) to enforce an ordering. If the
promise never becomes resolved (or is rejected), none of its callbacks will ever
be run.

Once again, it's important to keep track of where the concurrency really comes
from: the OS. There might be many asynchronous I/O operations occurring at the
OS level. But at the OCaml level, the resolution loop is sequential, meaning
that only one callback can ever be running at a time.

Finally, the resolution loop never attempts to interrupt a callback. So if the
callback goes into an infinite loop, no other callback will ever get to run.
That makes Lwt a cooperative concurrency mechanism, rather than preemptive.

To better understand callback resolution, let's implement it ourselves. We'll
use the `Promise` data structure we developed earlier. To start, we add a bind
operator to the `Promise` signature:

```ocaml
module type PROMISE = sig
  ...

  (** [p >>= c] registers callback [c] with promise [p].
      When the promise is resolved, the callback will be run
      on the promises's contents.  If the promise is never
      resolved, the callback will never run. *)
  val (>>=) : 'a promise -> ('a -> 'b promise) -> 'b promise
end
```

Next, let's re-develop the entire `Promise` structure.  We start
off just like before:

```ocaml
module Promise : PROMISE = struct
  type 'a state = Pending | Resolved of 'a | Rejected of exn
  ...
```

But now to implement the representation type of promises, we use a record with
mutable fields. The first field is the state of the promise, and it corresponds
to the `ref` we used before. The second field is more interesting and is
discussed below.

```ocaml
  (** RI: the input may not be [Pending]. *)
  type 'a handler = 'a state -> unit

  (** RI: if [state <> Pending] then [handlers = []]. *)
  type 'a promise = {
    mutable state : 'a state;
    mutable handlers : 'a handler list
  }
```

A *handler* is a new abstraction: a function that takes a non-pending state. It
will be used to handle resolving and rejecting promises when their state is
ready to switch away from pending. The primary use for a handler will be to run
callbacks. As a representation invariant, we require that only pending promises
may have handlers waiting in their list. Once the state becomes non-pending,
i.e., either resolved or rejected, the handlers will all be processed and
removed from the list.

This helper function that enqueues a handler on a promise's handler list will be
helpful later:

```ocaml
  let enqueue
      (handler : 'a state -> unit)
      (promise : 'a promise) : unit
    =
    promise.handlers <- handler :: promise.handlers
```

We continue to pun resolvers and promises internally:

```ocaml
  type 'a resolver = 'a promise
```

Because we changed the representation type from a `ref` to a record,
we have to update a few of the functions in trivial ways:

```ocaml
  (** [write_once p s] changes the state of [p] to be [s].  If [p] and [s]
      are both pending, that has no effect.
      Raises: [Invalid_arg] if the state of [p] is not pending. *)
  let write_once p s =
    if p.state = Pending
    then p.state <- s
    else invalid_arg "cannot write twice"

  let make () =
    let p = {state = Pending; handlers = []} in
    p, p

  let return x =
    {state = Resolved x; handlers = []}

  let state p = p.state
```

Now we get to the trickier parts of the implementation. To resolve or reject a
promise, the first thing we need to do is to call `write_once` on it, as we did
before. Now we also need to process the handlers. Before doing so, we mutate the
handlers list to be empty to ensure that the RI holds.

```ocaml
  (** Requires: [st] may not be [Pending]. *)
  let resolve_or_reject (r : 'a resolver) (st : 'a state) =
    assert (st <> Pending);
    let handlers = r.handlers in
    r.handlers <- [];
    write_once r st;
    List.iter (fun f -> f st) handlers

  let reject r x =
    resolve_or_reject r (Rejected x)

  let resolve r x =
    resolve_or_reject r (Resolved x)
```

Finally, the implementation of `>>=` is the trickiest part. First, if the
promise is already resolved, let's go ahead and immediately run the callback on
it:

```ocaml
  let (>>=)
      (input_promise : 'a promise)
      (callback : 'a -> 'b promise) : 'b promise
    =
    match input_promise.state with
    | Resolved x -> callback x
```

Second, if the promise is already rejected, then we return a promise
that is rejected with the same exception:

```ocaml
    | Rejected exc -> {state = Rejected exc; handlers = []}
```

Third, if the promise is pending, we need to do more work. Here's what we said
in our discussion of `bind` in the previous section:

> [T]he bind function returns a new promise. That promise will become
resolved when (or if) the callback completes running, sometime in the future.
Its contents will be whatever contents are contained within the promise that the
callback itself returns.

That's what we now need to implement. So, we create a new promise and resolver
called `output_promise` and `output_resolver`. That promise is what `bind`
returns. Before returning it, we use a helper function `handler_of_callback`
(described below) to transform the callback into a handler, and enqueue that
handler on the promise. That ensures the handler will be run when the promise
later becomes resolved or rejected:

```ocaml
    | Pending ->
      let output_promise, output_resolver = make () in
      enqueue (handler_of_callback callback output_resolver) input_promise;
      output_promise
```

All that's left is to implement that helper function to create handlers from
callbacks. The first two cases, below, are simple. It would violate the RI to
call a handler on a pending state. And if the state is rejected, then the
handler should propagate that rejection to the resolver, which causes the
promise returned by bind to also be rejected.

```ocaml
  let handler_of_callback
      (callback : 'a -> 'b promise)
      (resolver : 'b resolver) : 'a handler
    = function
      | Pending -> failwith "handler RI violated"
      | Rejected exc -> reject resolver exc
```

But if the state is resolved, then the callback provided by the user to bind
can&mdash;at last!&mdash;be run on the contents of the resolved promise. Running
the callback produces a new promise. It might already be rejected or resolved,
in which case that state again propagates.

```ocaml
      | Resolved x ->
        let promise = callback x in
        match promise.state with
        | Resolved y -> resolve resolver y
        | Rejected exc -> reject resolver exc
```

But the promise might still be pending.  In that case, we need to enqueue
a new handler whose purpose is to do the propagation once the result is
available:

```ocaml
        | Pending -> enqueue (handler resolver) promise
```

where `handler` is a new helper function that creates a very simple handler
to do that propagation:

```ocaml
  let handler (resolver : 'a resolver) : 'a handler
    = function
      | Pending -> failwith "handler RI violated"
      | Rejected exc -> reject resolver exc
      | Resolved x -> resolve resolver x
```

The Lwt implementation of `bind` follows essentially the same algorithm as we
just implemented. Note that there is no concurrency in `bind`: as we said above,
everything in Lwt is sequential; it's the OS that provides the concurrency.

## The Full Implementation

Here's all of that code in one executable block:

```{code-cell} ocaml
(** A signature for Lwt-style promises, with better names. *)
module type PROMISE = sig
  type 'a state =
    | Pending
    | Resolved of 'a
    | Rejected of exn

  type 'a promise

  type 'a resolver

  (** [make ()] is a new promise and resolver. The promise is pending. *)
  val make : unit -> 'a promise * 'a resolver

  (** [return x] is a new promise that is already resolved with value
      [x]. *)
  val return : 'a -> 'a promise

  (** [state p] is the state of the promise. *)
  val state : 'a promise -> 'a state

  (** [resolve r x] resolves the promise [p] associated with [r] with
      value [x], meaning that [state p] will become [Resolved x].
      Requires: [p] is pending. *)
  val resolve : 'a resolver -> 'a -> unit

  (** [reject r x] rejects the promise [p] associated with [r] with
      exception [x], meaning that [state p] will become [Rejected x].
      Requires: [p] is pending. *)
  val reject : 'a resolver -> exn -> unit

  (** [p >>= c] registers callback [c] with promise [p].
      When the promise is resolved, the callback will be run
      on the promises's contents.  If the promise is never
      resolved, the callback will never run. *)
  val (>>=) : 'a promise -> ('a -> 'b promise) -> 'b promise
end

module Promise : PROMISE = struct
  type 'a state = Pending | Resolved of 'a | Rejected of exn

  (** RI: the input may not be [Pending]. *)
  type 'a handler = 'a state -> unit

  (** RI: if [state <> Pending] then [handlers = []]. *)
  type 'a promise = {
    mutable state : 'a state;
    mutable handlers : 'a handler list
  }

  let enqueue
      (handler : 'a state -> unit)
      (promise : 'a promise) : unit
    =
    promise.handlers <- handler :: promise.handlers

  type 'a resolver = 'a promise

  (** [write_once p s] changes the state of [p] to be [s].  If [p] and [s]
      are both pending, that has no effect.
      Raises: [Invalid_arg] if the state of [p] is not pending. *)
  let write_once p s =
    if p.state = Pending
    then p.state <- s
    else invalid_arg "cannot write twice"

  let make () =
    let p = {state = Pending; handlers = []} in
    p, p

  let return x =
    {state = Resolved x; handlers = []}

  let state p = p.state

  (** Requires: [st] may not be [Pending]. *)
  let resolve_or_reject (r : 'a resolver) (st : 'a state) =
    assert (st <> Pending);
    let handlers = r.handlers in
    r.handlers <- [];
    write_once r st;
    List.iter (fun f -> f st) handlers

  let reject r x =
    resolve_or_reject r (Rejected x)

  let resolve r x =
    resolve_or_reject r (Resolved x)

  let handler (resolver : 'a resolver) : 'a handler
    = function
      | Pending -> failwith "handler RI violated"
      | Rejected exc -> reject resolver exc
      | Resolved x -> resolve resolver x

  let handler_of_callback
      (callback : 'a -> 'b promise)
      (resolver : 'b resolver) : 'a handler
    = function
      | Pending -> failwith "handler RI violated"
      | Rejected exc -> reject resolver exc
      | Resolved x ->
        let promise = callback x in
        match promise.state with
        | Resolved y -> resolve resolver y
        | Rejected exc -> reject resolver exc
        | Pending -> enqueue (handler resolver) promise

  let (>>=)
      (input_promise : 'a promise)
      (callback : 'a -> 'b promise) : 'b promise
    =
    match input_promise.state with
    | Resolved x -> callback x
    | Rejected exc -> {state = Rejected exc; handlers = []}
    | Pending ->
      let output_promise, output_resolver = make () in
      enqueue (handler_of_callback callback output_resolver) input_promise;
      output_promise
end
```
