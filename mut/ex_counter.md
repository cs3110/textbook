# Example: Mutable Counter

Here is code that implements a *counter*.  Every time `next_val` 
is called, it returns one more than the previous time.
```
# let counter = ref 0;;
val counter : int ref = {contents = 0}

# let next_val = 
    fun () ->
      counter := (!counter) + 1;
      !counter;;
val next_val : unit -> int = <fun> 

# next_val();;
- : int = 1

# next_val();;
- : int = 2

# next_val();;
- : int = 3
```

In the implementation of `next_val`, there are two expressions
separated by semi-colon.  The first expression, `counter := (!counter) + 1`,
is an assignment that increments `counter` by 1.  The second 
expression, `!counter`, returns the newly incremented contents
of `counter`.

This function is unusual in that every time we call it, it returns
a different value.  That's quite different than any of the functions
we've implemented ourselves so far, which have always been
*deterministic*: for a given input, they always produced the same output.
On the other hand, we've seen some library functions that
are *nondeterministic*, for example, functions in the `Random` module,
and `Stdlib.read_line`.  It's no coincidence that those happen to be 
implemented using mutable features.

We could improve our counter in a couple ways.  First, there is a 
library function `incr : int ref -> unit` that increments an `int ref`
by 1.  Thus it is like the `++` operator in many language in the
C family.  Using it, we could write `incr counter` instead of
`counter := (!counter) + 1`.

Second, the way we coded the counter currently exposes the `counter`
variable to the outside world.  Maybe we're prefer to hide it so
that clients of `next_val` can't directly change it.  We could
do so by nesting `counter` inside the scope of `next_val`:
```
let next_val = 
  let counter = ref 0 
  in fun () ->
    incr counter;
    !counter
```
Now `counter` is in scope inside of `next_val`, but not accessible
outside that scope.

When we gave the dynamic semantics of let expressions before,
we talked about substitution.  One way to think about the definition
of `next_val` is as follows.

* First, the expression `ref 0` is evaluated.  That returns a location
  `loc`, which is an address in memory.  The contents of that address
  are initialized to `0`.
  
* Second, everywhere in the body of the let expression that `counter`
  occurs, we substitute for it that location.  So we get:
  ```
  fun () -> incr loc; !loc
  ```

* Third, that anonymous function is bound to `next_val`.

So any time `next_val` is called, it increments and returns the contents
of that one memory location `loc`.

Now imagine that we instead had written the following (broken) code:
```
let next_val_broken = fun () ->
  let counter = ref 0
  in incr counter;
     !counter
```
It's only a little different:  the binding of `counter` occurs after
the `fun () ->` instead of before.  But it makes a huge difference:
```
# next_val_broken ();;
- : int = 1

# next_val_broken ();;
- : int = 1

# next_val_broken ();;
- : int = 1
```
Every time we call `next_val_broken`, it returns `1`:  we no longer
have a counter.  What's going wrong here?

The problem is that every time `next_val_broken` is called, the first
thing it does is to evaluate `ref 0` to a new location that is initialized
to `0`.  That location is then incremented to `1`, and `1` is returned. 
Every call to `next_val_broken` is thus allocating a new ref cell, whereas
`next_val` allocates just one new ref cell.