# Exercises

{{ solutions }}

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "promise and resolve")}}

Use the finished version of the `Promise` module we developed to do the
following: create an integer promise and resolver, bind a function on the
promise to print the contents of the promise, then resolve the promise. Only
after the promise is resolved should the printing occur.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "promise and resolve lwt")}}

Repeat the above exercise, but use the Lwt library instead of our own Promise
library. Make sure to use Lwt's I/O functions (e.g., `Lwt_io.printf`).

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "map via bind")}}

Use the finished version of the `Promise` module we developed to also implement the `map` operator. Review the text for a description of the behavior of `map p f`. You may call `bind` in your implementation of `map`. Hint: use `return`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "map anew")}}

Use the finished version of the `Promise` module we developed to also implement the `map` operator. Review the text for a description of the behavior of `map p f`. You may use the code we developed for `bind` as a template, but you may not call `bind` in your implementation of `map`.


<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "timing challenge 1")}}

Here is a function that produces a time delay.  We can use it
to simulate an I/O call that takes a long time to complete.

```ocaml
(** [delay s] is a promise that resolves after about [s] seconds. *)
let delay (sec : float) : unit Lwt.t =
  Lwt_unix.sleep sec
```

Write a function `delay_then_print : unit -> unit Lwt.t` that delays for three
seconds then prints `"done"`.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "timing challenge 2")}}

What happens when `timing2 ()` is run? How long does it take to run? Make a
prediction, then run the code to find out.

```ocaml
open Lwt.Infix

let timing2 () =
  let _t1 = delay 1. >>= fun () -> Lwt_io.printl "1" in
  let _t2 = delay 10. >>= fun () -> Lwt_io.printl "2" in
  let _t3 = delay 20. >>= fun () -> Lwt_io.printl "3" in
  Lwt_io.printl "all done"
```

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "timing challenge 3")}}

What happens when `timing3 ()` is run? How long does it take to run? Make a
prediction, then run the code to find out.

```ocaml
open Lwt.Infix

let timing3 () =
  delay 1. >>= fun () ->
  Lwt_io.printl "1" >>= fun () ->
  delay 10. >>= fun () ->
  Lwt_io.printl "2" >>= fun () ->
  delay 20. >>= fun () ->
  Lwt_io.printl "3" >>= fun () ->
  Lwt_io.printl "all done"
```

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "timing challenge 4")}}

What happens when `timing4 ()` is run? How long does it take to run? Make a
prediction, then run the code to find out.

```ocaml
open Lwt.Infix

let timing4 () =
  let t1 = delay 1. >>= fun () -> Lwt_io.printl "1" in
  let t2 = delay 10. >>= fun () -> Lwt_io.printl "2" in
  let t3 = delay 20. >>= fun () -> Lwt_io.printl "3" in
  Lwt.join [t1; t2; t3] >>= fun () ->
  Lwt_io.printl "all done"
```

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "file monitor")}}

Write an Lwt program that monitors the contents of a file named "log".
Specifically, your program should open the file, continually read a line from
the file, and as each line becomes available, print the line to stdout. When you
reach the end of the file (EOF), your program should terminate cleanly without
any exceptions.

Here is starter code:

```ocaml
open Lwt.Infix
open Lwt_io
open Lwt_unix

(** [log ()] is a promise for an [input_channel] that reads from
    the file named "log". *)
let log () : input_channel Lwt.t =
  openfile "log" [O_RDONLY] 0 >>= fun fd ->
  Lwt.return (of_fd ~mode:input fd)

(** [loop ic] reads one line from [ic], prints it to stdout,
    then calls itself recursively. It is an infinite loop. *)
let rec loop (ic : input_channel) =
  failwith "TODO"
  (* hint: use [Lwt_io.read_line] and [Lwt_io.printlf] *)

(** [monitor ()] monitors the file named "log". *)
let monitor () : unit Lwt.t =
  log () >>= loop

(** [handler] is a helper function for [main]. If its input is
    [End_of_file], it handles cleanly exiting the program by
    returning the unit promise. Any other input is re-raised
    with [Lwt.fail]. *)
let handler : exn -> unit Lwt.t =
  failwith "TODO"

let main () : unit Lwt.t =
  Lwt.catch monitor handler

let _ = Lwt_main.run (main ())
```

Complete `loop` and `handler`. You might find the
[Lwt manual](https://ocsigen.org/lwt/) to be useful.

To compile your code, put it in a file named `monitor.ml`. Create a dune file
for it:
```text
(executable
 (name monitor)
 (libraries lwt.unix))
```

And run it as usual:

```console
$ dune exec ./monitor.exe
```

To simulate a file to which lines are being added over time, open a new terminal
window and enter the following commands:

```console
$ mkfifo log
$ cat >log
```

Now anything you type into the terminal window (after pressing return) will be
added to the file named `log`. That will enable you to interactively test your
program.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "add opt")}}

Here are the definitions for the maybe monad:

```ocaml
module type Monad = sig
  type 'a t
  val return : 'a -> 'a t
  val ( >>= ) : 'a t -> ('a -> 'b t) -> 'b t
end

module Maybe : Monad =
struct
  type 'a t = 'a option

  let return x = Some x

  let ( >>= ) m f =
    match m with
    | Some x -> f x
    | None -> None

end
```

Implement `add : int Maybe.t -> int Maybe.t -> int Maybe.t`. If either of the
inputs is `None`, then the output should be `None`. Otherwise, if the inputs are
`Some a` and `Some b` then the output should be `Some (a+b)`. The definition of
`add` must be located outside of `Maybe`, as shown above, which means that your
solution may not use the constructors `None` or `Some` in its code.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "fmap and join")}}

Here is an extended signature for monads that adds two new operations:

```ocaml
module type ExtMonad = sig
  type 'a t
  val return : 'a -> 'a t
  val ( >>= ) : 'a t -> ('a -> 'b t) -> 'b t
  val ( >>| ) : 'a t -> ('a -> 'b) -> 'b t
  val join : 'a t t -> 'a t
end
```
Just as the infix operator `>>=` is known as `bind`, the infix operator `>>|` is
known as `fmap`. The two operators differ only in the return type of their
function argument.

Using the box metaphor, `>>|` takes a boxed value, and a function that only
knows how to work on unboxed values, extracts the value from the box, runs the
function on it, and boxes up that output as its own return value.

Also using the box metaphor, `join` takes a value that is wrapped in two boxes
and removes one of the boxes.

It's possible to implement `>>|` and `join` directly with pattern matching (as
we already implemented `>>=`). It's also possible to implement them without
pattern matching.

For this exercise, do the former: implement `>>|` and `join` as part of the
`Maybe` monad, and do not use `>>=` or `return` in the body of `>>|` or `join`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "fmap and join again")}}

Solve the previous exercise again.  This time, you must use `>>=` and `return`
to implement `>>|` and `join`, and you may not use `Some` or `None` in the body
of `>>|` and `join`.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "bind from fmap+join")}}

The previous exercise demonstrates that `>>|` and `join` can be implemented
entirely in terms of `>>=` (and `return`), without needing to know anything
about the representation type `'a t` of the monad.

It's actually possible to go the other direction. That is, `>>=` can be
implemented using just `>>|` and `join`, without needing to know anything about
the representation type `'a t`.

Prove that this is so by completing the following code:

```ocaml
module type FmapJoinMonad = sig
  type 'a t
  val ( >>| ) : 'a t -> ('a -> 'b) -> 'b t
  val join : 'a t t -> 'a t
  val return : 'a -> 'a t
end

module type BindMonad = sig
  type 'a t
  val return : 'a -> 'a t
  val ( >>= ) : 'a t -> ('a -> 'b t) -> 'b t
end

module MakeMonad (M : FmapJoinMonad) : BindMonad = struct
  (* TODO *)
end
```

*Hint: let the types be your guide.*

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "list monad")}}

We've seen three examples of monads already; let's examine a fourth, the *list
monad*. The "something more" that it does is to upgrade functions to work on
lists instead of just single values. (Note, there is no notion of concurrency
intended here. It's not that the list monad runs functions concurrently on every
element of a list. The Lwt monad does, however, provide that kind of
functionality.)

For example, suppose you have these functions:

```ocaml
let inc x = x + 1
let pm x = [x; -x]
```

Then the list monad could be used to apply those functions to every
element of a list and return the result as a list. For example,

* `[1; 2; 3] >>| inc` is `[2; 3; 4]`.
* `[1; 2; 3] >>= pm` is `[1; -1; 2; -2; 3; -3]`.
* `[1; 2; 3] >>= pm >>| inc` is `[2; 0; 3; -1; 4; -2]`.

One way to think about this is that the list monad operators take a list of
inputs to a function, run the function on all those inputs, and give you back
the combined list of outputs.

Complete the following definition of the list monad:

```ocaml
module type ExtMonad = sig
  type 'a t
  val return : 'a -> 'a t
  val ( >>= ) : 'a t -> ('a -> 'b t) -> 'b t
  val ( >>| ) : 'a t -> ('a -> 'b) -> 'b t
  val join : 'a t t -> 'a t
end

module ListMonad : ExtMonad = struct
  type 'a t = 'a list

  (* TODO *)
end
```

*Hints:* Leave `>>=` for last.  Let the types be your guide.  There are
two very useful list library functions that can help you.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "trivial monad laws")}}

Here is the world's most trivial monad. All it does is wrap a value inside a
constructor.

```ocaml
module Trivial : Monad = struct
  type 'a t = Wrap of 'a
  let return x = Wrap x
  let ( >>= ) (Wrap x) f = f x
end
```

Prove that the three monad laws, as formulated using `>>=` and `return`, hold
for the trivial monad.
