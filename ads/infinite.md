# Infinite Data Structures

We already know that OCaml allows us to create recursive functions&mdash;that is,
functions defined in terms of themselves.  It turns out we can define other values
in terms of themselves, too.

```
# let rec ones = 1::ones;;
val ones : int list = [1; <cycle>]

# let rec a = 0::b and b = 1::a;;
val a : int list = [0; 1; <cycle>]
val b : int list = [1; 0; <cycle>]
```

The expressions above create *recursive values*.  The list `ones` contains an
infinite sequence of `1`, and the lists `a` and `b` alternate infinitely between
`0` and `1`.  As the lists are infinite, the toplevel cannot print them in their
entirety.  Instead, it indicates a *cycle*: the list cycles back to its beginning.
Even though these lists represent an infinite sequence of values, their representation
in memory is finite:  they are linked lists with back pointers that create those cycles.

There are other kinds of infinite mathematical objects we might want to represent
with finite data structures:

* Infinite sequences, such as the sequence of all natural numbers, or the sequence of
  all primes, or the sequence of all Fibonacci numbers.

* A stream of inputs read from a file, a network socket, or a user.  All of these are
  unbounded in length, hence we can think of them as being infinite in length.  In fact,
  many I/O libraries treat reaching the end of an I/O stream as an unexpected situation
  and raise an exception.

* A *game tree* is a tree in which the positions of a game (e.g., chess or tic-tac-toe)_
  are the nodes and the edges are possible moves.  For some games this tree is
  in fact infinite (imagine, e.g., that the pieces on the board could chase each other
  around forever), and for other games, it's so deep that we would never want to
  manifest the entire tree, hence it is effectively infinite.

Suppose we wanted to represent the first of those examples:  the sequence of all
natural numbers.  Some of the obvious things we might try simply don't work:

```
# let rec from n = n :: from (n+1);;
# let nats = from 0;;
Stack overflow during evaluation (looping recursion?).

# let rec nats = 0 :: List.map (fun x -> x+1) nats;;
Error: This kind of expression is not allowed as right-hand side of let rec
```

The problem with the first attempt is that `nats` attempts to compute the entire
infinite sequence of natural numbers.  Because the function isn't tail recursive,
it quickly overflows the stack.  If it were tail recursive, it would go into an
infinite loop.

The second attempt doesn't work for a more subtle reason.  In the definition of a
recursive value, we are not permitted to use a value before it is finished being
defined.  The problem is that `List.map` is applied to `nats`, and therefore
pattern matches to extract the head and tail of `nats`, but we are in the middle
of defining `nats`, so that use of `nats` is not permitted.

