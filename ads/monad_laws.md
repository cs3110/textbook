# Monad Laws

Every data structure has not just a signature, but some expected behavior.
For example, a stack has a push and a pop operation, and we expect those
operations to satisfy certain laws:

* for all `x` and `s`, it holds that `peek (push x s) = x`
* for all `x`, it holds that `pop (push x empty) = empty`
* etc.

The laws for a given data structure usually follow from the specifications
for its operations, as do the two examples laws given above.

A monad, though, is not just a single data structure.  It's a design
pattern for data structures.  So it's impossible to write specifications
of `return` and `>>=` for monads in general:  the specifications would need
to discuss the particular monad, like the writer monad or the Lwt monad.

On the other hand, it turns out that we can write down some laws that
ought to hold of any monad.  The reason for that goes back to one
of the intuitions we gave about monads, namely, that they represent
computations that have effects.  Consider Lwt, for example.  We might
register a callback C on promise X with `bind`.  That produces a new
promise Y, on which we could register another callback D.  We expect
a sequential ordering on those callbacks:  C must run before D, because
Y cannot be resolved before X.

That notion of *sequential order* is part of what the monad laws stipulate.
We will state those laws below.  But first, let's pause to consider
sequential order in imperative languages.

## Sequential Order in Imperative Languages

In languages like Java and C, there is a semicolon that imposes a
sequential order on statements, e.g.:
```
System.out.println(x);
x++;
System.out.println(x);
```
First `x` is printed, then incremented, then printed again.  The effects that
those statements have must occur in that sequential order.

Let's imagine a hypothetical statement that causes no effect whatsoever.
For example, `assert true` causes nothing to happen in Java.  (Some compilers
will completely ignore it and not even produce bytecode for it.)
In most assembly languages, there is likewise a "no op" instruction whose
mnemonic is usually `NOP` that also causes nothing to happen.  (Technically,
some clock cycles would elapse.  But there wouldn't be any changes
to registers or memory.)  In the theory of programming languages, statements
like this are usually called `skip`, as in, "skip over me because I don't
do anything interesting."

Here are two laws that should hold of `skip` and semicolon:

* `skip; s;` should be the same as just `s;`.

* `s; skip;` should be the same as just `s;`.

In other words, you can remove any occurrences of `skip`, because it has
no effects.  Mathematically, we say that `skip` is a *left identity* (the first law)
and a *right identity* (the second law) of semicolon.

Imperative languages also usually have a way of grouping statements
together into blocks.  In Java and C, this is usually done with 
curly braces.  Here is a law that should hold of blocks and semicolon:

* `{s1; s2;} s3;` should be the same as `s1; {s2; s3;}`.

In other words, the order is always `s1` then `s2` then `s3`, regardless
of whether you group the first two statements into a block or the second two into
a block.  So you could even remove the braces and just write `s1; s2; s3;`, which
is what we normally do anyway.  Mathematically, we say that semicolon is
*associative.*

## Sequential Order with the Monad Laws

The three laws above embody exactly the same intuition as the monad laws,
which we will now state.  The monad laws are just a bit more abstract hence
harder to understand at first.

Suppose that we have any monad, which as usual must have the following signature:
```
module type Monad = sig
  type 'a t
  val return : 'a -> 'a t  
  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
end
```

The three monad laws are as follows:

* **Law 1:** `return x >>= f` is the same as `f x`.

* **Law 2:** `m >>= return` is the same as `m`.

* **Law 3:** `(m >>= f) >>= g` is the same as `m >>= (fun x -> f x >>= g)`.

These laws are mathematically saying the same things as the laws for
`skip`, semicolon, and braces that we saw above:  `return` is a left and
right identity of `>>=`, and `>>=` is associative.  
Let's look at each law in more detail.



