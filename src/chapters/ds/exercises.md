# Exercises

{{ solutions }}

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "hash insert")}}

Suppose we have a hash table on integer keys. The table currently has 7
empty buckets, and the hash function is simply `let hash k = k mod 7`.
Draw the hash table that results from inserting the keys 4, 8, 15, 16,
23, and 42 (with whatever values you like).

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "relax bucket RI")}}

We required that hash table buckets must not contain duplicates. What would
happen if we relaxed this RI to allow duplicates? Would the efficiency of any
operations (insert, find, or remove) change?

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "strengthen bucket RI")}}

What would happen if we strengthened the bucket RI to require each bucket to be
sorted by the key? Would the efficiency of any operations (insert, find, or
remove) change?

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "hash values")}}

Use `Hashtbl.hash : 'a -> int` to hash several values of different types. Make
sure to try at least `()`, `false`, `true`, `0`, `1`, `""`, and `[]`, as well as
several "larger" values of each type. We saw that lists quickly can create
collisions. Try creating binary trees and finding a collision.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "hashtbl usage")}}

Create a hash table `tab` with `Hashtbl.create` whose initial size is 16. Add 31
bindings to it with `Hashtbl.add`. For example, you could add the numbers 1..31
as keys and the strings "1".."31" as their values. Use `Hashtbl.find` to look
for keys that are in `tab`, as well as keys that are not.

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "hashtbl stats")}}

Use the `Hashtbl.stats` function to find out the statistics of `tab` (from an
exercise above). How many buckets are in the table? How many buckets have a
single binding in them?

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "hashtbl bindings")}}

Define a function `bindings : ('a,'b) Hashtbl.t -> ('a*'b) list`, such that
`bindings h` returns a list of all bindings in `h`. Use your function to see all
the bindings in `tab` (from an exercise above). *Hint: fold.*

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "hashtbl load factor")}}

Define a function `load_factor : ('a,'b) Hashtbl.t -> float`, such that
`load_factor h` is the load factor of `h`. What is the load factor of `tab`?
*Hint: stats.*

Add one more binding to `tab`. Do the stats or load factor change? Now add yet
another binding. Now do the stats or load factor change? *Hint: `Hashtbl`
resizes when the load factor goes strictly above 2.*

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "functorial interface")}}

Use the functorial interface (i.e., `Hashtbl.Make`) to create a hash table whose
keys are strings that are case-insensitive. Be careful to obey the specification
of `Hashtbl.HashedType.hash`:

> If two keys are equal according to `equal`, then they have identical hash
> values as computed by `hash`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "equals and hash")}}

The previous exercise quoted the specification of `Hashtbl.HashedType.hash`.
Compare that to Java's `Object.hashCode()` [specification][hashCode]. Why do
they both have this similar requirement?

[hashCode]: https://docs.oracle.com/javase/8/docs/api/java/lang/Object.html#hashCode--

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "bad hash")}}

Use the functorial interface to create a hash table with a really bad hash
function (e.g., a constant function). Use the `stats` function to see how bad
the bucket distribution becomes.

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "linear probing")}}

We briefly mentioned *probing* as an alternative to *chaining*. Probing can be
effectively used in hardware implementations of hash tables, as well as in
databases. With probing, every bucket contains exactly one binding. In case of a
collision, we search forward through the array, as described below.

**Your task:** Implement a hash table that uses linear probing. The details are
below.

**Find.** Suppose we are trying to find a binding in the table. We hash the
binding's key and look in the appropriate bucket. If there is already a
different key in that bucket, we start searching forward through the array at
the next bucket, then the next bucket, and so forth, wrapping back around to the
beginning of the array if necessary. Eventually we will either

* find an empty bucket, in which case the key we're searching for is not bound
  in the table;

* find the key before we reach an empty bucket, in which case we can return the
  value; or

* never find the key or an empty bucket, instead wrapping back around to the
  original bucket, in which case all buckets are full and the key is not bound
  in the table. This case actually should never occur, because we won't allow
  the load factor to get high enough for all buckets to be filled.

**Insert.** Insertion follows the same algorithm as finding a key, except that
whenever we first find an empty bucket, we can insert the binding there.

**Remove.** Removal is more difficult. Once the key is found, we can't just make
the bucket empty, because that would affect future searches by causing them to
stop early. Instead, we can introduce a special "deleted" value into that bucket
to indicate that the bucket does not contain a binding but the searches should
not stop at it.

**Resizing.** Since we never want the array to become completely full, we can
keep the load factor near 1/4. When the load factor exceeds 1/2, we can double
the array, bringing the load factor back to 1/4. When the load factor goes below
1/8, we can half the array, again bringing the load factor back to 1/4.
"Deleted" bindings complicate the definition of load factor:

* When determining whether to double the table size, we calculate the load
  factor as (# of bindings + # of deleted bindings) / (# of buckets). That is,
  deleted bindings contribute toward increasing the load factor.

* When determining whether the half the table size, we calculate the load factor
  as (# of bindings) / (# buckets). That is, deleted bindings do not count
  toward increasing the load factor.

When rehashing the table, deleted bindings are of course not re-inserted into
the new table.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "functorized BST")}}

Our implementation of BSTs assumed that it was okay to compare values using the
built-in comparison operators `<`, `=`, and `>`. But what if the client wanted
to use their own comparison operators? (e.g., to ignore case in strings, or to
have sets of records where only a single field of the record was used for
ordering.) Implement a `BstSet` abstraction as a functor parameterized on a
structure that enables client-provided comparison operator(s), much like the
[standard library `Set`][stdlib-set].

[stdlib-set]: https://ocaml.org/api/Set.html

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "efficient traversal")}}

Suppose you wanted to convert a tree to a list. You'd have to put the values
stored in the tree in some order. Here are three ways of doing that:

* *preorder*: each node's value appears in the list before the values of its
  left then right subtrees.

* *inorder*: the values of the left subtree appear, then the value at the node,
  then the values of the right subtree.

* *postorder*: the values of a node's left then right subtrees appear, followed
  by the value at the node.

Here is code that implements those *traversals*, along with some example
applications:

```ocaml
type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree

let rec preorder = function
  | Leaf -> []
  | Node (l,v,r) -> [v] @ preorder l @ preorder r

let rec inorder = function
  | Leaf -> []
  | Node (l,v,r) ->  inorder l @ [v] @ inorder r

let rec postorder = function
  | Leaf -> []
  | Node (l,v,r) ->  postorder l @ postorder r @ [v]

let t =
  Node(Node(Node(Leaf, 1, Leaf), 2, Node(Leaf, 3, Leaf)),
       4,
       Node(Node(Leaf, 5, Leaf), 6, Node(Leaf, 7, Leaf)))

(*
  t is
        4
      /   \
     2     6
    / \   / \
   1   3 5   7
*)

let () = assert (preorder t  = [4;2;1;3;6;5;7])
let () = assert (inorder t   = [1;2;3;4;5;6;7])
let () = assert (postorder t = [1;3;2;5;7;6;4])
```

On unbalanced trees, the traversal functions above require quadratic worst-case
time (in the number of nodes), because of the `@` operator. Re-implement the
functions without `@`, and instead using `::`, such that they perform exactly
one cons per `Node` in the tree. Thus the worst-case execution time will be
linear. You will need to add an additional accumulator argument to each
function, much like with tail recursion. (But your implementations won't
actually be tail recursive.)

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "RB draw complete")}}

Draw the perfect binary tree on the values 1, 2, ..., 15. Color the nodes in
three different ways such that (i) each way is a red-black tree (i.e., satisfies
the red-black invariants), and (ii) the three ways create trees with black
heights of 2, 3, and 4, respectively. Recall that the *black height* of a tree
is the maximum number of black nodes along any path from its root to a leaf.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "RB draw insert")}}

Draw the red-black tree that results from inserting the characters D A T A S T R
U C T U R E into an empty tree. Carry out the insertion algorithm yourself by
hand, then check your work with the implementation provided in the book.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "standard library set")}}

Read the [source code][stdlib-set-ml] of the standard library `Set` module.
Find the representation invariant for the balanced trees that it uses.
Which kind of tree does it most resemble:  2-3, AVL, or red-black?

[stdlib-set-ml]: https://github.com/ocaml/ocaml/blob/trunk/stdlib/set.ml

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "pow2")}}

Using this type:

```ocaml
type 'a sequence = Cons of 'a * (unit -> 'a sequence)
```

Define a value `pow2 : int sequence` whose elements are the powers of two:
`<1; 2; 4; 8; 16, ...>`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "more sequences")}}

Define the following sequences:

  - the even naturals

  - the lower-case alphabet on endless repeat:  a, b, c, ..., z, a, b, ...

  - unending pseudorandom coin flips (e.g., booleans or a variant with `Heads`
    and `Tails` constructors)

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "nth")}}

Define a function `nth : 'a sequence -> int -> 'a`, such that
`nth s n` the element at zero-based position `n` in sequence `s`.
For example, `nth pow2 0 = 1`, and `nth pow2 4 = 16`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "hd tl")}}

Explain how each of the following sequence expressions is evaluated:

- `hd nats`
- `tl nats`
- `hd (tl nats)`
- `tl (tl nats)`
- `hd (tl (tl nats))`

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "filter")}}

Define a function `filter : ('a -> bool) -> 'a sequence -> 'a sequence`, such
that `filter p s` is the sub-sequence of `s` whose elements satisfy the
predicate `p`. For example, `filter (fun n -> n mod 2 = 0) nats` would be the
sequence `<0; 2; 4; 6; 8; 10; ...>`. If there is no element of `s` that
satisfies `p`, then `filter p s` does not terminate.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "interleave")}}

Define a function `interleave : 'a sequence -> 'a sequence -> 'a sequence`, such
that `interleave <a1; a2; a3; ...> <b1; b2; b3; ...>` is the sequence
`<a1; b1; a2; b2; a3; b3; ...>`. For example, `interleave nats pow2` would be
`<0; 1; 1; 2; 2; 4; 3; 8; ...>`.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "sift")}}

The *Sieve of Eratosthenes* is a way of computing the prime numbers.

* Start with the sequence `<2; 3; 4; 5; 6; ...>`.

* Take 2 as prime.  Delete all multiples of 2, since they cannot be prime.
  That leaves `<3; 5; 7; 9; 11; ...>`.

* Take 3 as prime and delete its multiples.
  That leaves `<5; 7; 11; 13; 17; ...>`.

* Take 5 as prime, etc.

Define a function `sift : int -> int sequence -> int sequence`, such that
`sift n s` removes all multiples of `n` from `s`. *Hint: filter.*

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "primes")}}

Define a sequence `prime : int sequence`, containing all the prime numbers
starting with 2.

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "approximately e")}}

The exponential function $e^x$ can be computed by the following
infinite sum:

$$
e^x = \frac{x^0}{0!} + \frac{x^1}{1!} + \frac{x^2}{2!} + \frac{x^3}{3!} + \cdots + \frac{x^k}{k!} + \cdots
$$

Define a function `e_terms : float -> float sequence`. Element `k` of the
sequence should be term `k` from the infinite sum. For example, `e_terms 1.0` is
the sequence `<1.0; 1.0; 0.5; 0.1666...; 0.041666...; ...>`. The easy way to
compute that involves a function that computes $f(k) = \frac{x^k}{k!}$.

Define a function `total : float sequence -> float sequence`, such that
`total <a; b; c; ...>` is a running total of the input elements, i.e.,
`<a; a+.b; a+.b+.c; ...>`.

Define a function `within : float -> float sequence -> float`, such that
`within eps s` is the first element of `s` for which the absolute difference
between that element and the element before it is strictly less than `eps`. If
there is no such element, `within` is permitted not to terminate (i.e., go into
an "infinite loop"). As a precondition, the *tolerance* `eps` must be strictly
positive. For example,
`within 0.1 <1.0; 2.0; 2.5; 2.75; 2.875; 2.9375; 2.96875; ...>` is `2.9375`.

Finally, define a function `e : float -> float -> float` such that `e x eps` is
$e^x$ computed to within a tolerance of `eps`, which must be strictly positive.
Note that there is an interesting boundary case where `x=1.0` for the first two
terms of the sum; you could choose to drop the first term (which is always
`1.0`) from the sequence before using `within`.

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "better e")}}

Although the idea for computing $e^x$ above through the summation of an infinite
series is good, the exact algorithm suggested above could be improved. For
example, computing the 20th term in the sequence leads to a very large numerator
and denominator if $x$ is large. Investigate that behavior, comparing it to the
built-in function `exp : float -> float`. Find a better way to structure the
computation to improve the approximations you obtain. *Hint: what if when
computing term $k$ you already had term $k-1$? Then you could just do a single
multiplication and division.*

Also, you could improve the test that `within` uses to determine whether two
values are close. A good one for determining whether $a$ and $b$ are close might
be [*relative distance*][boost-rel-dist]:

$$
\left|\frac{a - b}{\mathit{min}(a, b)}\right| < \epsilon.
$$

[boost-rel-dist]: https://www.boost.org/doc/libs/1_77_0/libs/math/doc/html/math_toolkit/float_comparison.html

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "different sequence rep")}}

Consider this alternative representation of sequences:
```ocaml
type 'a sequence = Cons of (unit -> 'a * 'a sequence)
```

How would you code up `hd : 'a sequence -> 'a`,
`tl : 'a sequence -> 'a sequence`, `nats : int sequence`, and
`map : ('a -> 'b) -> 'a sequence -> 'b sequence` for it? Explain how this
representation is even lazier than our original representation.

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "lazy hello")}}

Define a value of type `unit Lazy.t` (which is synonymous with `unit lazy_t`),
such that forcing that value with `Lazy.force` causes `"Hello lazy world"` to be
printed. If you force it again, the string should not be printed.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "lazy and")}}

Define a function `(&&&) : bool Lazy.t -> bool Lazy.t -> bool`. It should behave
like a short circuit Boolean AND. That is, `lb1 &&& lb2` should first force
`lb1`. If it is `false`, the function should return `false`. Otherwise, it
should force `lb2` and return its value.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "lazy sequence")}}

Implement `map` and `filter` for the `'a lazysequence` type provided in the
section on laziness.

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
