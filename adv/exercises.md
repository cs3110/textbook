# Exercises

## Streams

The next few exercises ask you to work with this type:
```
type 'a stream =
  Cons of 'a * (unit -> 'a stream)
```

##### Exercise: pow2 [&#10029;&#10029;] 

Define a value `pow2 : int stream` whose elements are the powers
of two:  `<1; 2; 4; 8; 16, ...>`.

&square;

##### Exercise: more streams [&#10029;&#10029;, optional] 

Define the following streams:

  - the even naturals
  
  - the lower-case alphabet on endless repeat:  a, b, c, ..., z, a, b, ...
  
  - a stream of pseudorandom coin flips (e.g., booleans or a variant
    with `Heads` and `Tails` constructors)
    
&square;    

##### Exercise: nth [&#10029;&#10029;] 

Define a function `nth : 'a stream -> int -> 'a`, such that
`nth s n` the element at zero-based position `n` in stream `s`.
For example, `nth pow2 0 = 1`, and `nth pow2 4 = 16`.

&square;

##### Exercise: hd tl [&#10029;&#10029;] 

Explain how each of the following stream expressions is evaluated:
  
- `hd nats`
- `tl nats`
- `hd (tl nats)`
- `tl (tl nats)`
- `hd (tl (tl nats))`

&square;

##### Exercise: filter [&#10029;&#10029;&#10029;] 

Define a function `filter : ('a -> bool) -> 'a stream -> 'a stream`,
such that `filter p s` is the sub-stream of `s` whose elements
satisfy the predicate `p`.  For example, `filter (fun n -> n mod 2 = 0) nats`
would be the stream `<0; 2; 4; 6; 8; 10; ...>`.  If there is no
element of `s` that satisfies `p`, then `filter p s` does not terminate.

&square;

##### Exercise: interleave [&#10029;&#10029;&#10029;] 

Define a function `interleave : 'a stream -> 'a stream -> 'a stream`,
such that `interleave <a1; a2; a3; ...> <b1; b2; b3; ...>` 
is the stream `<a1; b1; a2; b2; a3; b3; ...>`.  For example,
`interleave nats pow2` would be `<0; 1; 1; 2; 2; 4; 3; 8; ...>`

&square;

## Sieve Stream

The *Sieve of Eratosthenes* is a way of computing the prime numbers.  

* Start with the stream `<2; 3; 4; 5; 6; ...>`.

* Take 2 as prime.  Delete all multiples of 2, since they cannot be prime.
  That leaves `<3; 5; 7; 9; 11; ...>`.
  
* Take 3 as prime and delete its multiples.
  That leaves `<5; 7; 11; 13; 17; ...>`.

* Take 5 as prime, etc.

##### Exercise: sift [&#10029;&#10029;&#10029;] 

Define a function `sift : int -> int stream -> int stream`,
such that `sift n s` removes all multiples of `n` from `s`.
*Hint: filter.*

&square;

##### Exercise: primes [&#10029;&#10029;&#10029;] 

Define a sequence `prime : int stream`,
containing all the prime numbers starting with 2.

&square;

## e Stream

##### Exercise: approximately e [&#10029;&#10029;&#10029;&#10029;] 

The exponential function $$e^x$$ can be computed by the following
infinite sum:

$$
e^x = \frac{x^0}{0!} + \frac{x^1}{1!} + \frac{x^2}{2!} + \frac{x^3}{3!} + \cdots + \frac{x^k}{k!} + \cdots 
$$

Define a function `e_terms : float -> float stream`.  Element `k` of
the stream should be term `k` from the infinite sum.  For
example, `e_terms 1.0` is the stream 
`<1.0; 1.0; 0.5; 0.1666...; 0.041666...; ...>`.  The easy way to 
compute that involves a function that computes $$f(k) = \frac{x^k}{k!}$$.

Define a function `total : float stream -> float stream`, such that
`total <a; b; c; ...>` is a running total of the input elements, i.e.,
`<a; a+.b; a+.b+.c; ...>`.

Define a function `within : float -> float stream -> float`, such
that `within eps s` is the first element of `s` for which the
absolute difference between that element and the element before it
is strictly less than `eps`.   If there is no such element, `within`
is permitted not to terminate (i.e., go into an "infinite loop").
As a precondition, the *tolerance* `eps` must be strictly positive.
For example, `within 0.1 <1.0; 2.0; 2.5; 2.75; 2.875; 2.9375; 2.96875; ...>`
is `2.9375`. 

Finally, define a function `e : float -> float -> float` such that
`e x eps` is $$e^x$$ computed to within a tolerance of `eps`,
which must be strictly positive.  Note that there is an interesting
boundary case where `x=1.0` for the first two terms of the sum; you
could choose to drop the first term (which is always `1.0`) from the
stream before using `within`.

&square;

##### Exercise: better e [&#10029;&#10029;&#10029;&#10029;, advanced] 

Although the idea for computing $$e^x$$ above through the summation of
an infinite series is good, the exact algorithm suggested above could be
improved. For example, computing the 20th term in the sequence leads to
a very large numerator and denominator if $$x$$ is large.  Investigate
that behavior, comparing it to the built-in function `exp : float ->
float`. Find a better way to structure the computation to improve the
approximations you obtain.  *Hint: what if when computing term $$k$$
you already had term $$k-1$$?  Then you could just do a single 
multiplication and division.*

Also, you could improve the test that `within` uses to determine
whether two values are close.  A good one for determining whether
$$a$$ and $$b$$ are close might be:

$$
\frac{|a - b|}{\frac{|a| + |b|}{2} + 1} < \epsilon.
$$

&square;

## Alternative Streams

##### Exercise: different stream rep [&#10029;&#10029;&#10029;] 

Consider this representation of streams:
```
type 'a stream = Cons of (unit -> 'a * 'a stream)
```

How would you code up `hd : 'a stream -> 'a`, 
`tl : 'a stream -> 'a stream`, `nats : int stream`, 
and `map : ('a -> 'b) -> 'a stream -> 'b stream` for it?
Explain how this representation is even lazier than our
original representation.

&square;
  
## Laziness

##### Exercise: lazy hello [&#10029;] 

Define a value of type `unit Lazy.t` (which is synonymous with
`unit lazy_t`), such that forcing that value with `Lazy.force`
causes `"Hello lazy world"` to be printed.  If you force it again,
the string should not be printed.

&square;

##### Exercise: lazy and [&#10029;&#10029;] 

Define a function `(&&&) : bool Lazy.t -> bool Lazy.t -> bool`.
It should behave like a short circuit Boolean AND.  That is,
`lb1 &&& lb2` should first force `lb1`.  If it is `false`,
the function should return `false`.  Otherwise, it should
force `lb2` and return its value.

&square;

##### Exercise: lazy stream [&#10029;&#10029;&#10029;] 

Implement `map` and `filter` for the `'a lazystream` type
provided in the section on laziness.

&square;

## Promises and Lwt

##### Exercise: promise and resolve [&#10029;&#10029;] 

Download the [completed implementation of `Promise`](promises.ml).
Use it to do the following:  create a integer promise and resolver,
bind a function on the promise to print the contents of the promise,
then resolve the promise.  Only after the promise is resolved should
the printing occur.

&square;

##### Exercise: promise and resolve lwt [&#10029;&#10029;] 

Repeat the **promise and resolve** exercise, but
use the Lwt library instead of our own Promise library.
Make sure to use Lwt's I/O functions (e.g., `Lwt_io.printf`).

&square;

##### Exercise: timing challenge 1 [&#10029;&#10029;] 

Here is a function that produces a time delay.  We can use it
to simulate an I/O call that takes a long time to complete.
```
(** [delay s] is a promise that resolves after about [s] seconds. *)
let delay (sec : float) : unit Lwt.t =
  Lwt_unix.sleep sec
```

Write a function `delay_then_print : unit -> unit Lwt.t` 
that delays for three seconds then prints `"done"`.

&square;

##### Exercise: timing challenge 2 [&#10029;&#10029;&#10029;] 

What happens when `timing2 ()` is run? How long does it take to run?
Make a prediction, then run the code to find out.

```
open Lwt.Infix

let timing2 () =
  let _t1 = delay 1. >>= fun () -> Lwt_io.printl "1" in
  let _t2 = delay 10. >>= fun () -> Lwt_io.printl "2" in
  let _t3 = delay 20. >>= fun () -> Lwt_io.printl "3" in
  Lwt_io.printl "all done"
```

&square;

##### Exercise: timing challenge 3 [&#10029;&#10029;&#10029;] 

What happens when `timing3 ()` is run? How long does it take to run?
Make a prediction, then run the code to find out.

```
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

&square;

##### Exercise: timing challenge 4 [&#10029;&#10029;&#10029;] 

What happens when `timing4 ()` is run? How long does it take to run?
Make a prediction, then run the code to find out.

```
open Lwt.Infix

let timing4 () =
  let t1 = delay 1. >>= fun () -> Lwt_io.printl "1" in
  let t2 = delay 10. >>= fun () -> Lwt_io.printl "2" in
  let t3 = delay 20. >>= fun () -> Lwt_io.printl "3" in
  Lwt.join [t1; t2; t3] >>= fun () ->
  Lwt_io.printl "all done"
```

&square;

##### Exercise: file monitor [&#10029;&#10029;&#10029;&#10029;] 

Write an Lwt program that monitors the contents of a file named "log".
Specifically, your program should open the file, continually
read a line from the file, and as each line becomes available,
print the line to stdout.  When you reach the end of the file (EOF),
your program should terminate cleanly without any exceptions.

Here is starter code:
```
open Lwt.Infix
open Lwt_io
open Lwt_unix

(** [log ()] is a promise for an [input_channel] that reads from
    the file named "log". *)
let log () : input_channel Lwt.t = 
  openfile "log" [O_RDONLY] 0 >>= fun fd ->
  Lwt.return (of_fd input fd)

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

Complete `loop` and `handler`.  You might find the [Lwt manual](https://ocsigen.org/lwt/)
to be useful.

To compile your code, put it in a file named `monitor.ml` and run
```
$ ocamlbuild -use-ocamlfind -pkg lwt.unix -tag thread monitor.byte
```

To simulate a file to which lines are being added over time,
open a new terminal window and enter the following commands:
```
$ mkfifo log
$ cat >log
```
Now anything you type into the terminal window (after pressing return)
will be added to the file named `log`.  That will enable you to interactively
test your program.

&square;

## Monads

##### Exercise: add opt [&#10029;&#10029;] 

Here are the definitions for the maybe monad:
```
module type Monad = sig
  type 'a t
  val return : 'a -> 'a t
  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
end

module Maybe : Monad = 
struct
  type 'a t = 'a option

  let return x = Some x 

  let (>>=) m f = 
    match m with 
    | Some x -> f x 
    | None -> None

end

let add : int Maybe.t -> int Maybe.t -> int Maybe.t = 
  failwith "TODO"
```

Implement `add`. If either of the inputs is `None`, then the output
should be `None`. Otherwise, if the inputs are `Some a` and `Some b`
then the output should be `Some (a+b)`. The definition of `add`
must be located outside of `Maybe`, as shown above, which means
that your solution may not use the constructors `None` or `Some`
in its code.

&square;

##### Exercise: fmap and join [&#10029;&#10029;] 

Here is an extended signature for monads that adds two new operations:
```
module type ExtMonad = sig
  type 'a t
  val return : 'a -> 'a t
  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
  val (>>|) : 'a t -> ('a -> 'b) -> 'b t
  val join : 'a t t -> 'a t
end
```

Just as the infix operator `>>=` is known as `bind`, the infix
operator `>>|` is known as `fmap`.  The two operators differ only in the
return type of their function argument.

Using the box metaphor, `>>|` takes a boxed value, and a function that only
knows how to work on unboxed values, extracts the value from the box,
runs the function on it, and boxes up that output as its own return value.

Also using the box metaphor, `join` takes a value that is wrapped in two boxes and
removes one of the boxes.

It's possible to implement `>>|` and `join` directly with pattern matching
(as we already implemented `>>=`).  It's also possible to implement them
without pattern matching.

For this exercise, do the former: implement `>>|` and `join` as part of the
`Maybe` monad, and do not use `>>=` or `return` in the body of `>>|` or `join`.

&square;

##### Exercise: fmap and join again [&#10029;&#10029;] 

Solve the previous exercise again.  This time, you must use `>>=` and `return`
to implement `>>|` and `join`, and you may not use `Some` or `None` in the body
of `>>|` and `join`.

&square;

##### Exercise: bind from fmap+join [&#10029;&#10029;&#10029;] 

The previous exercise demonstrates that `>>|` and `join` can be implemented
entirely in terms of `>>=` (and `return`), without needing to know anything
about the representation type `'a t` of the monad.

It's actually possible to go the other direction.  That is, `>>=`
can be implemented using just `>>|` and `join`, without needing to know
anything about the representation type `'a t`.

Prove that this is so by completing the following code:

```
module type FmapJoinMonad = sig
  type 'a t
  val (>>|) : 'a t -> ('a -> 'b) -> 'b t
  val join : 'a t t -> 'a t
  val return : 'a -> 'a t
end

module type BindMonad = sig
  type 'a t
  val return : 'a -> 'a t
  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
end

module MakeMonad (M : FmapJoinMonad) : BindMonad = struct
  (* TODO *)
end
```

*Hint: let the types be your guide.*

&square;

## The List Monad

We've seen three examples of monads already; let's examine a fourth, the
*list monad*. The "something more" that it does is to upgrade functions
to work on lists instead of just single values.  (Note, there is no
notion of concurrency intended here.  It's not that the list monad runs
functions concurrently on every element of a list.  The Lwt monad does,
however, provide that kind of functionality.)

For example, suppose you have these functions:
```
let inc x = x + 1
let pm x = [x; -x]
```
Then the list monad could be used to apply those functions to every
element of a list and return the result as a list. For example,

* `[1; 2; 3] >>| inc` is `[2; 3; 4]`.
* `[1; 2; 3] >>= pm` is `[1; -1; 2; -2; 3; -3]`.
* `[1; 2; 3] >>= pm >>| inc` is `[2; 0; 3; -1; 4; -2]`.

One way to think about this is that the list monad operators take a list
of inputs to a function, run the function on all those inputs, and give
you back the combined list of outputs.  

##### Exercise: list monad [&#10029;&#10029;&#10029;] 

Complete the following definition of the list monad:
```
module type ExtMonad = sig
  type 'a t
  val return : 'a -> 'a t
  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
  val (>>|) : 'a t -> ('a -> 'b) -> 'b t
  val join : 'a t t -> 'a t
end

module ListMonad : ExtMonad = struct
  type 'a t = 'a list

  (* TODO *)
end
```

*Hints:* Leave `>>=` for last.  Let the types be your guide.  There are
two very useful list library functions that can help you.

&square;

## Monad Laws

##### Exercise: trivial monad laws [&#10029;&#10029;&#10029;] 

Here is the world's most trivial monad.  All it does is wrap
a value inside of a constructor.

```
module Trivial : Monad = struct
  type 'a t = Wrap of 'a
  let return x = Wrap x
  let (>>=) (Wrap x) f = f x
end
```

Prove that the three monad laws, as formulated using `>>=`
and `return`, hold for the trivial monad.

