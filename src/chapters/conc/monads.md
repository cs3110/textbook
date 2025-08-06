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

# Monads

A *monad* is more of a design pattern than a data structure. That is, there are
many data structures that, if you look at them in the right way, turn out to be
monads.

The name "monad" comes from the mathematical field of *category theory*, which
studies abstractions of mathematical structures. If you ever take a PhD level
class on programming language theory, you will likely encounter that idea in
more detail. Here, though, we will omit most of the mathematical theory and
concentrate on code.

Monads became popular in the programming world through their use in Haskell, a
functional programming language that is even more pure than OCaml&mdash;that is,
Haskell avoids side effects and imperative features even more than OCaml. But no
practical language can do without side effects. After all, printing to the
screen is a side effect. So Haskell set out to control the use of side effects
through the monad design pattern. Since then, monads have become recognized as
useful in other functional programming languages, and are even starting to
appear in imperative languages.

Monads are used to model *computations*. Think of a computation as being like a
function, which maps an input to an output, but as also doing "something more."
The something more is an effect that the function has as a result of being
computed. For example, the effect might involve printing to the screen. Monads
provide an abstraction of effects, and help to make sure that effects happen in
a controlled order.

## The Monad Signature

For our purposes, a monad is a structure that satisfies two properties. First,
it must match the following signature:

```{code-cell} ocaml
:tags: ["hide-output"]
module type Monad = sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
end
```

Second, a monad must obey what are called the *monad laws*. We will return to
those much later, after we have studied the `return` and `bind` operations.

Think of a monad as being like a box that contains some value. The value has
type `'a`, and the box that contains it is of type `'a t`. We have previously
used a similar box metaphor for both options and promises. That was no accident:
options and promises are both examples of monads, as we will see in detail,
below.

**Return.** The `return` operation metaphorically puts a value into a box. You
can see that in its type: the input is of type `'a`, and the output is of type
`'a t`.

In terms of computations, `return` is intended to have some kind of trivial
effect. For example, if the monad represents computations whose side effect is
printing to the screen, the trivial effect would be to not print anything.

**Bind.** The `bind` operation metaphorically takes as input:

* a boxed value, which has type `'a t`, and

* a function that itself takes an *unboxed* value of type `'a` as input and
  returns a *boxed* value of type `'b t` as output.

The `bind` applies its second argument to the first. That requires taking the
`'a` value out of its box, applying the function to it, and returning the
result.

In terms of computations, `bind` is intended to sequence effects one after
another. Continuing the running example of printing, sequencing would mean first
printing one string, then another, and `bind` would be making sure that the
printing happens in the correct order.

The usual notation for `bind` is as an infix operator written `>>=` and still
pronounced "bind". So let's revise our signature for monads:

```{code-cell} ocaml
:tags: ["hide-output"]
module type Monad = sig
  type 'a t
  val return : 'a -> 'a t
  val ( >>= ) : 'a t -> ('a -> 'b t) -> 'b t
end
```

All of the above is likely to feel very abstract upon first reading. It will
help to see some concrete examples of monads. Once you understand several `>>=`
and `return` operations, the design pattern itself should make more sense.

So the next few sections look at several different examples of code in which
monads can be discovered. Because monads are a design pattern, they aren't
always obvious; it can take some study to tease out where the monad operations
are being used.

## The Maybe Monad

As we've seen before, sometimes functions are partial: there is no good output
they can produce for some inputs. For example, the function
`max_list : int list -> int` doesn't necessarily have a good output value to
return for the empty list. One possibility is to raise an exception. Another
possibility is to change the return type to be `int option`, and use `None` to
represent the function's inability to produce an output. In other words, *maybe*
the function produces an output, or *maybe* it is unable to do so hence returns
`None`.

As another example, consider the built-in OCaml integer division function
`( / ) : int -> int -> int`. If its second argument is zero, it raises an
exception. Another possibility, though, would be to change its type to be
`( / ) : int -> int -> int option`, and return `None` whenever the divisor is
zero.

Both of those examples involved changing the output type of a partial function
to be an option, thus making the function total. That's a nice way to program,
until you start trying to combine many functions together. For example, because
all the integer operations&mdash;addition, subtraction, division,
multiplication, negation, etc.&mdash;expect an `int` (or two) as input, you can
form large expressions out of them. But as soon as you change the output type of
division to be an option, you lose that *compositionality*.

Here's some code to make that idea concrete:

```{code-cell} ocaml
(* works fine *)
let x = 1 + (4 / 2)
```

```{code-cell} ocaml
:tags: ["raises-exception"]
let div (x:int) (y:int) : int option =
  if y = 0 then None else Some (x / y)

let ( / ) = div

(* won't type check *)
let x = 1 + (4 / 2)
```

The problem is that we can't add an `int` to an `int option`:  the addition
operator expects its second input to be of type `int`, but the new division
operator returns a value of type `int option`.

One possibility would be to re-code all the existing operators to
accept `int option` as input.  For example,

```{code-cell} ocaml
:tags: ["hide-output"]
let plus_opt (x:int option) (y:int option) : int option =
  match x,y with
  | None, _ | _, None -> None
  | Some a, Some b -> Some (Stdlib.( + ) a b)

let ( + ) = plus_opt

let minus_opt (x:int option) (y:int option) : int option =
  match x,y with
  | None, _ | _, None -> None
  | Some a, Some b -> Some (Stdlib.( - ) a b)

let ( - ) = minus_opt

let mult_opt (x:int option) (y:int option) : int option =
  match x,y with
  | None, _ | _, None -> None
  | Some a, Some b -> Some (Stdlib.( * ) a b)

let ( * ) = mult_opt

let div_opt (x:int option) (y:int option) : int option =
  match x,y with
  | None, _ | _, None -> None
  | Some a, Some b ->
    if b=0 then None else Some (Stdlib.( / ) a b)

let ( / ) = div_opt
```

```{code-cell} ocaml
(* does type check *)
let x = Some 1 + (Some 4 / Some 2)
```

But that's a tremendous amount of code duplication. We ought to apply the
Abstraction Principle and deduplicate. Three of the four operators can be
handled by abstracting a function that just does some pattern matching to
propagate `None`:

```{code-cell} ocaml
let propagate_none (op : int -> int -> int) (x : int option) (y : int option) =
  match x, y with
  | None, _ | _, None -> None
  | Some a, Some b -> Some (op a b)

let ( + ) = propagate_none Stdlib.( + )
let ( - ) = propagate_none Stdlib.( - )
let ( * ) = propagate_none Stdlib.( * )
```

Unfortunately, division is harder to deduplicate. We can't just pass
`Stdlib.( / )` to `propagate_none`, because neither of those functions will
check to see whether the divisor is zero. It would be nice if we could pass our
function `div : int -> int -> int option` to `propagate_none`, but the return
type of `div` makes that impossible.

So, let's rewrite `propagate_none` to accept an operator of the same type as
`div`, which makes it easy to implement division:

```{code-cell} ocaml
let propagate_none
  (op : int -> int -> int option) (x : int option) (y : int option)
=
  match x, y with
  | None, _ | _, None -> None
  | Some a, Some b -> op a b

let ( / ) = propagate_none div
```

Implementing the other three operations requires a little more work, because
their return type is `int` not `int option`. We need to wrap their return value
with `Some`:

```{code-cell} ocaml
let wrap_output (op : int -> int -> int) (x : int) (y : int) : int option =
  Some (op x y)

let ( + ) = propagate_none (wrap_output Stdlib.( + ))
let ( - ) = propagate_none (wrap_output Stdlib.( - ))
let ( * ) = propagate_none (wrap_output Stdlib.( * ))
```

Finally, we could re-implement `div` to use `wrap_output`:

```{code-cell} ocaml
let div (x : int) (y : int) : int option =
  if y = 0 then None else wrap_output Stdlib.( / ) x y

let ( / ) = propagate_none div
```

**Where's the Monad?** The work we just did was to take functions on integers
and transform them into functions on values that maybe are integers, but maybe
are not&mdash;that is, values that are either `Some i` where `i` is an integer,
or are `None`. We can think of these "upgraded" functions as computations that
*may have the effect of producing nothing*. They produce metaphorical boxes, and
those boxes may be full of something, or contain nothing.

There were two fundamental ideas in the code we just wrote, which correspond to
the monad operations of `return` and `bind`.

The first (which admittedly seems trivial) was upgrading a value from `int` to
`int option` by wrapping it with `Some`. That's what the body of `wrap_output`
does. We could expose that idea even more clearly by defining the following
function:

```{code-cell} ocaml
let return (x : int) : int option = Some x
```
This function has the *trivial effect* of putting a value into the metaphorical
box.

The second idea was factoring out code to handle all the pattern matching
against `None`. We had to upgrade functions whose inputs were of type `int` to
instead accept inputs of type `int option`. Here's that idea expressed as its
own function:

```{code-cell} ocaml
let bind (x : int option) (op : int -> int option) : int option =
  match x with
  | None -> None
  | Some a -> op a

let ( >>= ) = bind
```

The `bind` function can be understood as doing the core work of upgrading `op`
from a function that accepts an `int` as input to a function that accepts an
`int option` as input. In fact, we could even write a function that does that
upgrading for us using `bind`:

```{code-cell} ocaml
let upgrade : (int -> int option) -> (int option -> int option) =
  fun (op : int -> int option) (x : int option) -> (x >>= op)
```

All those type annotations are intended to help the reader understand
the function.  Of course, it could be written much more simply as:

```{code-cell} ocaml
let upgrade op x = x >>= op
```

Using just the `return` and `>>=` functions, we could re-implement the
arithmetic operations from above:

```{code-cell} ocaml
let ( + ) (x : int option) (y : int option) : int option =
  x >>= fun a ->
  y >>= fun b ->
  return (Stdlib.( + ) a b)

let ( - ) (x : int option) (y : int option) : int option =
  x >>= fun a ->
  y >>= fun b ->
  return (Stdlib.( - ) a b)

let ( * ) (x : int option) (y : int option) : int option =
  x >>= fun a ->
  y >>= fun b ->
  return (Stdlib.( * ) a b)

let ( / ) (x : int option) (y : int option) : int option =
  x >>= fun a ->
  y >>= fun b ->
  if b = 0 then None else return (Stdlib.( / ) a b)
```

Recall, from our discussion of the bind operator in Lwt, that the syntax above
should be parsed by your eye as

* take `x` and extract from it the value `a`,
* then take `y` and extract from it `b`,
* then use `a` and `b` to construct a return value.

Of course, there's still a fair amount of duplication going on there. We can
de-duplicate by using the same techniques as we did before:

```{code-cell} ocaml
let upgrade_binary op x y =
  x >>= fun a ->
  y >>= fun b ->
  op a b

let return_binary op x y = return (op x y)

let ( + ) = upgrade_binary (return_binary Stdlib.( + ))
let ( - ) = upgrade_binary (return_binary Stdlib.( - ))
let ( * ) = upgrade_binary (return_binary Stdlib.( * ))
let ( / ) = upgrade_binary div
```

**The Maybe Monad.** The monad we just discovered goes by several names: the
*maybe monad* (as in, "maybe there's a value, maybe not"), the *error monad* (as
in, "either there's a value or an error", and error is represented by
`None`&mdash;though some authors would want an error monad to be able to
represent multiple kinds of errors rather than just collapse them all to
`None`), and the *option monad* (which is obvious).

Here's an implementation of the monad signature for the maybe monad:

```{code-cell} ocaml
module Maybe : Monad = struct
  type 'a t = 'a option

  let return x = Some x

  let (>>=) m f =
    match m with
    | None -> None
    | Some x -> f x
end
```

These are the same implementations of `return` and `>>=` as we invented above,
but without the type annotations to force them to work only on integers. Indeed,
we never needed those annotations; they just helped make the code above a little
clearer.

In practice the `return` function here is quite trivial and not really
necessary. But the `>>=` operator can be used to replace a lot of boilerplate
pattern matching, as we saw in the final implementation of the arithmetic
operators above. There's just a single pattern match, which is inside of `>>=`.
Compare that to the original implementations of `plus_opt`, etc., which had many
pattern matches.

The result is we get code that (once you understand how to read the bind
operator) is easier to read and easier to maintain.

Now that we're done playing with integer operators, we should restore
their original meaning for the rest of this file:

```{code-cell} ocaml
let ( + ) = Stdlib.( + )
let ( - ) = Stdlib.( - )
let ( * ) = Stdlib.( * )
let ( / ) = Stdlib.( / )
```

## Example: The Writer Monad

When trying to diagnose faults in a system, it's often the case that a *log* of
what functions have been called, as well as what their inputs and outputs were,
would be helpful.

Imagine that we had two functions we wanted to debug, both of type `int -> int`.
For example:

```{code-cell} ocaml
let inc x = x + 1
let dec x = x - 1
```

(Ok, those are really simple functions; we probably don't need any help
debugging them. But imagine they compute something far more complicated, like
encryptions or decryptions of integers.)

One way to keep a log of function calls would be to augment each function to
return a pair: the integer value the function would normally return, as well as
a string containing a log message. For example:

```{code-cell} ocaml
let inc_log x = (x + 1, Printf.sprintf "Called inc on %i; " x)
let dec_log x = (x - 1, Printf.sprintf "Called dec on %i; " x)
```

But that changes the return type of both functions, which makes it hard to
*compose* the functions. Previously, we could have written code such as

```{code-cell} ocaml
let id x = dec (inc x)
```

or even better

```{code-cell} ocaml
let id x = x |> inc |> dec
```

or even better still, using the *composition operator* `>>`,

```{code-cell} ocaml
let ( >> ) f g x = x |> f |> g
let id = inc >> dec
```

and that would have worked just fine. But trying to do the same thing with the
loggable versions of the functions produces a type-checking error:

```{code-cell} ocaml
:tags: ["raises-exception"]
let id = inc_log >> dec_log
```

That's because `inc_log x` would be a pair, but `dec_log` expects simply an
integer as input.

We could code up an upgraded version of `dec_log` that is able to take a pair as
input:

```{code-cell} ocaml
let dec_log_upgraded (x, s) =
  (x - 1, Printf.sprintf "%s; Called dec on %i; " s x)

let id x = x |> inc_log |> dec_log_upgraded
```

That works fine, but we also will need to code up a similar upgraded version of
`f_log` if we ever want to call them in reverse order, e.g.,
`let id = dec_log >> inc_log`. So we have to write:

```{code-cell} ocaml
let inc_log_upgraded (x, s) =
  (x + 1, Printf.sprintf "%s; Called inc on %i; " s x)

let id = dec_log >> inc_log_upgraded
```

And at this point we've duplicated far too much code. The implementations of
`inc` and `dec` are duplicated inside both `inc_log` and `dec_log`, as well as
inside both upgraded versions of the functions. And both the upgrades duplicate
the code for concatenating log messages together. The more functions we want to
make loggable, the worse this duplication is going to become!

So, let's start over, and factor out a couple helper functions. The first helper
calls a function and produces a log message:

```{code-cell} ocaml
let log (name : string) (f : int -> int) : int -> int * string =
  fun x -> (f x, Printf.sprintf "Called %s on %i; " name x)
```
The second helper produces a logging function of type
`'a * string -> 'b * string` out of a non-loggable function:

```{code-cell} ocaml
let loggable (name : string) (f : int -> int) : int * string -> int * string =
  fun (x, s1) ->
    let (y, s2) = log name f x in
    (y, s1 ^ s2)
```

Using those helpers, we can implement the logging versions of our functions
without any duplication of code involving pairs or pattern matching or string
concatenation:

```{code-cell} ocaml
let inc' : int * string -> int * string =
  loggable "inc" inc

let dec' : int * string -> int * string =
  loggable "dec" dec

let id' : int * string -> int * string =
  inc' >> dec'
```

Here's an example usage:

```{code-cell} ocaml
id' (5, "")
```

Notice how it's inconvenient to call our loggable functions on integers, since
we have to pair the integer with a string. So let's write one more function to
help with that by pairing an integer with the *empty* log:

```{code-cell} ocaml
let e x = (x, "")
```

And now we can write `id' (e 5)` instead of `id' (5, "")`.

**Where's the Monad?** The work we just did was to take functions on integers
and transform them into functions on integers paired with log messages. We can
think of these "upgraded" functions as computations that log. They produce
metaphorical boxes, and those boxes contain function outputs as well as log
messages.

There were two fundamental ideas in the code we just wrote, which correspond to
the monad operations of `return` and `bind`.

The first was upgrading a value from `int` to `int * string` by pairing it with
the empty string. That's what `e` does. We could rename it `return`:

```{code-cell} ocaml
let return (x : int) : int * string = (x, "")
```
This function has the *trivial effect* of putting a value into the metaphorical
box along with the empty log message.

The second idea was factoring out code to handle pattern matching against pairs
and string concatenation. Here's that idea expressed as its own function:

```{code-cell} ocaml
let ( >>= ) (m : int * string) (f : int -> int * string) : int * string =
  let (x, s1) = m in
  let (y, s2) = f x in
  (y, s1 ^ s2)
```

Using `>>=`, we can re-implement `loggable`, such that no pairs
or pattern matching are ever used in its body:

```{code-cell} ocaml
let loggable (name : string) (f : int -> int) : int * string -> int * string =
  fun m ->
    m >>= fun x ->
    log name f x
```

**The Writer Monad.** The monad we just discovered is usually called the *writer
monad* (as in, "additionally writing to a log or string"). Here's an
implementation of the monad signature for it:

```{code-cell} ocaml
module Writer : Monad = struct
  type 'a t = 'a * string

  let return x = (x, "")

  let ( >>= ) m f =
    let (x, s1) = m in
    let (y, s2) = f x in
    (y, s1 ^ s2)
end
```

As we saw with the maybe monad, these are the same implementations of `return`
and `>>=` as we invented above, but without the type annotations to force them
to work only on integers. Indeed, we never needed those annotations; they just
helped make the code above a little clearer.

It's debatable which version of `loggable` is easier to read. Certainly you need
to be comfortable with the monadic style of programming to appreciate the
version of it that uses `>>=`. But if you were developing a much larger code
base (i.e., with more functions involving paired strings than just `loggable`),
using the `>>=` operator is likely to be a good choice: it means the code you
write can concentrate on the `'a` in the type `'a Writer.t` instead of on the
strings. In other words, the writer monad will take care of the strings for you,
as long as you use `return` and `>>=`.

## Example: The Lwt Monad

By now, it's probably obvious that the Lwt promises library that we discussed is
also a monad. The type `'a Lwt.t` of promises has a `return` and `bind`
operation of the right types to be a monad:

```ocaml
val return : 'a -> 'a t
val bind : 'a t -> ('a -> 'b t) -> 'b t
```

And `Lwt.Infix.( >>= )` is a synonym for `Lwt.bind`, so the library does provide
an infix bind operator.

Now we start to see some of the great power of the monad design pattern. The
implementation of `'a t` and `return` that we saw before involves creating
references, but those references are completely hidden behind the monadic
interface. Moreover, we know that `bind` involves registering callbacks, but
that functionality (which as you might imagine involves maintaining collections
of callbacks) is entirely encapsulated.

Metaphorically, as we discussed before, the box involved here is one that starts
out empty but eventually will be filled with a value of type `'a`. The
"something more" in these computations is that values are being produced
asynchronously, rather than immediately.

## Monad Laws

Every data structure has not just a signature, but some expected behavior. For
example, a stack has a push and a pop operation, and we expect those operations
to behave in particular ways. For example, if we push an element onto a stack then
peek at the element on the top of the stack, we expect the to see the element that
we had just pushed.

A monad, though, is not just a single data structure. It's a design pattern for
data structures. So it's impossible to write specifications of `return` and
`>>=` for monads in general: the specifications would need to discuss the
particular monad, like the writer monad or the Lwt monad.

On the other hand, it turns out that we can write down some laws that ought to
hold of any monad. The reason for that goes back to one of the intuitions we
gave about monads, namely, that they represent computations that have effects.
Consider Lwt, for example. We might register a callback C on promise X with
`bind`. That produces a new promise Y, on which we could register another
callback D. We expect a sequential ordering on those callbacks: C must run
before D, because Y cannot be resolved before X.

That notion of *sequential order* is part of what the monad laws stipulate. We
will state those laws below. But first, let's pause to consider sequential order
in imperative languages.

**Sequential Order.* In languages like Java and C, there is a semicolon that
imposes a sequential order on statements, e.g.:

```java
System.out.println(x);
x++;
System.out.println(x);
```

First `x` is printed, then incremented, then printed again. The effects that
those statements have must occur in that sequential order.

Let's imagine a hypothetical statement that causes no effect whatsoever. For
example, `assert true` causes nothing to happen in Java. (Some compilers will
completely ignore it and not even produce bytecode for it.) In most assembly
languages, there is likewise a "no op" instruction whose mnemonic is usually
`NOP` that also causes nothing to happen. (Technically, some clock cycles would
elapse. But there wouldn't be any changes to registers or memory.) In the theory
of programming languages, statements like this are usually called `skip`, as in,
"skip over me because I don't do anything interesting."

Here are two laws that should hold of `skip` and semicolon:

* `skip; s;` should behave the same as just `s;`.

* `s; skip;` should behave the same as just `s;`.

In other words, you can remove any occurrences of `skip`, because it has no
effects. Mathematically, we say that `skip` is a *left identity* (the first law)
and a *right identity* (the second law) of semicolon.

Imperative languages also usually have a way of grouping statements together
into blocks. In Java and C, this is usually done with curly braces. Here is a
law that should hold of blocks and semicolon:

* `{s1; s2;} s3;` should behave the same as `s1; {s2; s3;}`.

In other words, the order is always `s1` then `s2` then `s3`, regardless of
whether you group the first two statements into a block or the second two into a
block. So you could even remove the braces and just write `s1; s2; s3;`, which
is what we normally do anyway. Mathematically, we say that semicolon is
*associative.*

**Sequential Order with the Monad Laws.** The three laws above embody exactly
the same intuition as the monad laws, which we will now state. The monad laws
are just a bit more abstract hence harder to understand at first.

Suppose that we have any monad, which as usual must have the following
signature:

```{code-cell} ocaml
module type Monad = sig
  type 'a t
  val return : 'a -> 'a t
  val ( >>= ) : 'a t -> ('a -> 'b t) -> 'b t
end
```

The three monad laws are as follows:

* **Law 1:** `return x >>= f` behaves the same as `f x`.

* **Law 2:** `m >>= return` behaves the same as `m`.

* **Law 3:** `(m >>= f) >>= g` behaves the same as `m >>= (fun x -> f x >>= g)`.

Here, "behaves the same as" means that the two expressions will both evaluate to
the same value, or they will both go into an infinite loop, or they will both
raise the same exception.

These laws are mathematically saying the same things as the laws for `skip`,
semicolon, and braces that we saw above: `return` is a left and right identity
of `>>=`, and `>>=` is associative. Let's look at each law in more detail.

*Law 1* says that having the trivial effect on a value, then binding a function
on it, is the same as just calling the function on the value. Consider the maybe
monad: `return x` would be `Some x`, and `>>= f` would extract `x` and apply `f`
to it. Or consider the Lwt monad: `return x` would be a promise that is already
resolved with `x`, and `>>= f` would register `f` as a callback to run on `x`.

*Law 2* says that binding on the trivial effect is the same as just not having
the effect. Consider the maybe monad: `m >>= return` would depend upon whether
`m` is `Some x` or `None`. In the former case, binding would extract `x`, and
`return` would just re-wrap it with `Some`. In the latter case, binding would
just return `None`. Similarly, with Lwt, binding on `m` would register `return`
as a callback to be run on the contents of `m` after it is resolved, and
`return` would just take those contents and put them back into an already
resolved promise.

*Law 3* says that bind sequences effects correctly, but it's harder to see it in
this law than it was in the version above with semicolon and braces. Law 3 would
be clearer if we could rewrite it as

>`(m >>= f) >>= g` behaves the same as `m >>= (f >>= g)`.

But the problem is that doesn't type check: `f >>= g` doesn't have the right
type to be on the right-hand side of `>>=`. So we have to insert an extra
anonymous function `fun x -> ...` to make the types correct.

## Composition and Monad Laws

There is another monad operator called `compose` that can be used to compose
monadic functions. For example, suppose you have a monad with type `'a t`, and
two functions:

* `f : 'a -> 'b t`
* `g : 'b -> 'c t`

The composition of those functions would be

* `compose f g : 'a -> 'c t`

That is, the composition would take a value of type `'a`, apply `f` to it, extract
the `'b` out of the result, apply `g` to it, and return that value.

We can code up `compose` using `>>=`; we don't need to know anything more about
the inner workings of the monad:

```{code-cell} ocaml
let compose f g x =
  f x >>= fun y ->
  g y

let ( >=> ) = compose
```

As the last line suggests, `compose` can be expressed as infix operator written
`>=>`.

Returning to our example of the maybe monad with a safe division operator,
imagine that we have increment and decrement functions:

```{code-cell} ocaml
let inc (x : int) : int option = Some (x + 1)
let dec (x : int) : int option = Some (x - 1)
let ( >>= ) x op =
  match x with
  | None -> None
  | Some a -> op a
```

The monadic compose operator would enable us to compose those two into
an identity function without having to write any additional code:

```{code-cell} ocaml
let ( >=> ) f g x =
  f x >>= fun y ->
  g y

let id : int -> int option = inc >=> dec
```

Using the compose operator, there is a much cleaner formulation of the monad
laws:

* **Law 1:** `return >=> f` behaves the same as `f`.

* **Law 2:** `f >=> return` behaves the same as `f`.

* **Law 3:** `(f >=> g) >=> h` behaves the same as `f >=> (g >=> h)`.

In that formulation, it becomes immediately clear that `return` is a left and
right identity, and that composition is associative.
