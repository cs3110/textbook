# Mutating Lists

Lists are immutable.  There's no way to change an element of a list from
one value to another.  Instead, OCaml programmers create new lists out
of old lists.  For example, suppose we wanted to write a function that
returned the same list as its input list, but with the first element (if
there is one) incremented by 1.  We could do that:
```
let inc_first lst =
  match lst with
  | [] -> []
  | h::t -> (h+1)::t
```

Now you might be concerned about whether we're being wasteful of space.
After all, there are at least two ways the compiler could implement
the above code:

1. Copy the entire tail list `t` when the new list is created in
   the pattern match with cons, such that the amount of memory
   in use just increased by an amount proportionate to the length of `t`.

2. Share the tail list `t` between the old list and the new list,
   such that the amount of memory in use does not increase (beyond
   the one extra piece of memory needed to store `h+1`).
   
In fact, the compiler does the latter.  So there's no need for concern.
The reason that it's quite safe for the compiler to implement sharing
is exactly that list elements are immutable.  If they were instead mutable,
then we'd start having to worry about whether the list I have
is shared with the list you have, and whether changes I make will be
visible in your list.  So immutability makes it easier to reason about
the code, and makes it safe for the compiler to perform an optimization.
