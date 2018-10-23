# Monads
 
A *monad* is more of a design pattern than a data structure.  That is,
there are many data structures that, if you look at them in the right
way, turn out to be monads.

The name "monad" comes from the mathematical field of *category theory*,
which studies abstractions of mathematical structures.  If you ever take
a PhD level class on programming language theory, you will likely
encounter that idea in more detail.  Here, though, we will omit most of
the mathematical theory and concentrate on code.

Monads became popular in the programming world through their use in
Haskell, a functional programming language that is even more pure than
OCaml*mdash;that is, Haskell avoids side effects and imperative features
even more than OCaml.  But no practical language can do without side
effects.  After all, printing to the screen is a side effect.  So
Haskell set out to control the use of side effects through the monad
design pattern. Since then, monads have become recognized as useful in
other functional programming languages, and are even starting to appear
in imperative languages.

Monads are used to model *computations*.  Think of a computation as
being like a function, which maps an input to an output, but as also
doing "something more."  The something more is an effect that the function
has as a result of being computed.  For example, the effect might
involve printing to the screen.  Monads provide an abstraction of effects,
and help to make sure that effects happen in a controlled order.

## The Monad Signature  

For our purposes, a monad is a structure that satisfies two properties.
First, it must match the following signature:
```
module type Monad = sig
  type 'a t
  val return : 'a -> 'a t  
  val bind : 'a t -> ('a -> 'b t) -> 'b t
end
```
Second, a monad must obey what are called the *monad laws*.  We will
return to those much later, after we have studied the `return` and `bind`
operations.

Think of a monad as being like a box that contains some value.  The
value has type `'a`, and the box that contains it is of type `'a t`.
We have previously used a similar box metaphor for both options
and promises.  That was no accident: options and promises are both
examples of monads, as we will see in detail, below.

## Return

The `return` operation metaphorically puts a value into a box.  You can
see that in its type:  the input is of type `'a`, and the output is
of type `'a t`.

In terms of computations, `return` is intended to have some kind of
trivial effect.  For example, if the monad represents computations
whose side effect is printing to the screen, the trivial effect would
be to not print anything.

## Bind

The `bind` operation metaphorically takes as input:

* a boxed value, which has type `'a t`, and 
* a function that itself takes an *unboxed* value of type `'a` as input
  and returns a *boxed* value of type `'b t` as output.  
  
The `bind` applies its second argument to the first.  That requires
taking the `'a` value out of its box, applying the function to it, and
returning the result.

In terms of computations, `bind` is intended to sequence effects one
after another.  Continuing the running example of printing, sequencing
would mean first printing one string, then another, and `bind` would
be making sure that the printing happens in the correct order.

The usual notation for `bind` is as an infix operator written `>>=` and
still pronounced "bind". So let's revise our signature for monads:
```
module type Monad = sig
  type 'a t
  val return : 'a -> 'a t  
  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
end
```

## Examples

All of the above is likely to feel very abstract upon first reading.
It will help to see some concrete examples of monads.  Once you understand
several `>>=` and `return` operations, the design pattern itself should
make more sense.

So the next few sections look at several different examples of code in
which monads can be discovered.  Because monads are a design pattern,
they aren't always obvious; it can take some study to tease out where
the monad operations are being used.
