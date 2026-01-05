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

# Callbacks

For a program to benefit from the concurrency provided by asynchronous
I/O and promises, there needs to be a way for the program to make use of
resolved promises.  For example, if a web server is asynchronously
reading and serving multiple files to multiple clients, the server needs
a way to (i) become aware that a read has completed, and (ii) then do a
new asynchronous write with the result of the read. In other words,
programs need a mechanism for managing the dependencies among promises.

The mechanism provided in Lwt is named *callbacks.*
A callback is a function that, when "registered" with a promise, will be
run sometime after that promise has been fulfilled.
The callback will receive as input the contents of the fulfilled promise.
Think of it like asking your friend to do some math for you: they
promise to do it, and to call you back on the phone with the answer sometime after they've finished.
You can do other things while you wait for them to call you back, and when they do, you can use the answer they give you.

## Registering a Callback

Here is a function that prints a string using Lwt's
version of the `printf` function:
```ocaml
let print_the_string str = Lwt_io.printf "The string is: %S\n" str
```

And here, repeated from the previous section, is our code that returns a promise
for a string read from standard input:
```ocaml
let p = read_line stdin
```

To register the printing function as a callback for the promise `p`, we use the
function `Lwt.bind`, which *binds* the callback to the promise:

```ocaml
Lwt.bind p print_the_string
```

Sometime after `p` is fulfilled, hence contains a string, the callback
will be run with that string as its input. That will cause the string to be printed.

Here's a complete utop transcript as an example of that:
```text
# let print_the_string str = Lwt_io.printf "The string is: %S\n" str;;
val print_the_string : string -> unit Lwt.t = <fun>
# let p = read_line stdin in Lwt.bind p print_the_string;;
- : unit Lwt.t = <abstr>
  <type Camels are bae followed by Enter>
# The string is: "Camels are bae"
```

## Bind

The type of `Lwt.bind` is important to understand:
```ocaml
'a Lwt.t -> ('a -> 'b Lwt.t) -> 'b Lwt.t
```

The `bind` function takes a promise as its first argument. It doesn't matter
whether that promise has been resolved yet. As its second argument,
`bind` takes a callback. Recall that a callback is a function: indeed, this callback takes an input which is the same
type `'a` as the contents of the promise. It's not an accident that they have
the same type: the whole idea is to eventually run the callback on the fulfilled
promise, so the type that the promise contains needs to be the same as the type that the
callback expects as input.

After being invoked on a promise and callback, e.g., `bind p c`, the `bind`
function does one of three things, depending on the state of `p`:

* If `p` is already fulfilled, then `c` is run immediately on the contents of
  `p`. The promise that is returned might or might not be pending, depending on
  what `c` does.

* If `p` is already rejected, then `c` does not run. The promise that is
  returned is also rejected, with the same exception as `p`.

* If `p` is pending, then `bind` does not wait for `p` to be resolved, nor for
  `c` to be run. Rather, `bind` just registers the callback to eventually be run
  when (or if) the promise is fulfilled. Therefore, the `bind` function returns a
  new promise. That promise may become resolved when (or if) the callback
  completes running, sometime in the future. Its contents will be whatever
  contents are contained within the promise that the callback itself returns.

```{note}
For the first case above: The Lwt source code claims that this behavior might
change: under high load, `c` might be registered to run
later. But as of [v5.5.0][lwt-bind-src] that behavior has not yet been activated. So, don't
worry about it&mdash;this paragraph is just here to future-proof this
discussion.
```

[lwt-bind-src]: https://github.com/ocsigen/lwt/blob/73f1a0f0acd5540f25e58bc410e1f63271189c6c/src/core/lwt.ml#L1820

Let's consider that final case in more detail. We have one promise of type
`'a Lwt.t` and two promises of type `'b Lwt.t`:

* The promise of type `'a Lwt.t`, call it promise X, is an input to `bind`. It
  was pending when `bind` was called, and when `bind` returns.

* The first promise of type `'b Lwt.t`, call it promise Y, is created by `bind`
  and immediately returned to the user. It is pending at that point.

* The second promise of type `'b Lwt.t`, call it promise Z, has not yet been
  created. It may be created later: if promise X is fulfilled, the
  callback will run on the contents of X, and the callback will return promise
  Z. There is no guarantee about the state of Z; it might well still be pending
  when returned by the callback.

* If Z is finally fulfilled, the contents of Y are updated to be the same as
  the contents of Z. If Z is rejected, then Y is also rejected with the same
  exception. If Z remains pending, then Y remains pending as well.
  Recall that Y has already been returned to the user.
  "Relaying" the contents of Z to Y ensures that the user can eventually benefit
  from the chain of operations that started with promise X.

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
input promise to be fulfilled, then returns the contents. This function
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

## Bind as an Operator

The `Lwt.Infix` module defines an
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
means that a promise is created, fulfilled, and its contents extracted under the
name `s1`. The second line means the same, except that its contents are named
`s2`. The third line creates a final promise whose contents are eventually
extracted by `Lwt_main.run`, at which point the program may terminate.

The `>>=` operator is perhaps most famous from the functional language Haskell,
which uses it extensively for monads. We'll cover monads in a later section.

## Bind as Let Syntax

There is a *syntax extension* for OCaml that makes using
bind even simpler than the infix operator `>>=`. To install the syntax
extension, run the following command:

`$ opam install lwt_ppx`

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
  Lwt_io.printf "%s\n" (s1 ^ s2)

let _ = Lwt_io.printf "Got here first\n"

let _ = Lwt_main.run p
```

You'll see that "Got here first" prints before you get a chance to enter any
input.

**Another `let` syntax.**
Instead of loading the additional library `lwt_ppx` to make `let%lwt` available, we can use a similar `let*` syntax provided by `Lwt.Syntax`:

```ocaml
open Lwt_io
open Lwt.Syntax

let p =
  let* s1 = read_line stdin in
  let* s2 = read_line stdin in
  Lwt_io.printf "%s\n" (s1 ^ s2)
```

But we generally prefer to use `lwt_ppx`, because it also makes some other useful syntax available.
For example, `lwt_ppx` also makes `try%lwt` available, and that is useful for exception handling that involves promises.

## Concurrent Composition

The `Lwt.bind` function provides a way to
sequentially compose callbacks: first one callback is run, then another, then
another, and so forth. There are other functions in the library for composition
of many callbacks as a set. For example,

* `Lwt.map : 'a Lwt.t -> ('a -> 'b) -> 'b Lwt.t` is a lot like `Lwt.bind`,
  but its callback immediately returns a *value* of type `'b`, not the
  *promise* of a value of type `'b`. `Lwt.map p f` returns a promise that is
  pending until `p` is resolved. If `p` is resolved via rejection, the callback is
  never called and the pending promise is rejected with the same exception. If
  `p` is resolved via fulfilment (say with value `v`), then the pending promise
  is resolved with `f v`. Note that `f` may itself raise an exception, in which
  case the pending promise is rejected with that exception.

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
