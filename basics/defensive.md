# Defensive Programming

As we discussed earlier in the section on debugging, one
defense against bugs is to make any bugs (or errors) 
immediately visible.  That idea connects with idea
of preconditions, which we just discussed.

Consider `random_int` again:
```
(** [random_int bound] is a random integer between 0 (inclusive)
    and [bound] (exclusive).  Requires: [bound] is greater than 0 
    and less than 2^30. *)
```

If the client of `random_int` passes a value of `bound` that violates
the "Raises" clause, such as `-1`, the implementation of `random_int` is
free to do anything whatsoever.  All bets are off when the client
violates the precondition.

But the most helpful thing for `random_int` to do is to immediately
expose the fact that the precondition was violated.  After all, chances
are that the client didn't *mean* to violate it.

So the implementor of `random_int` would do well to check whether the
precondition is violated, and if so, to raise an exception.  Here are
three possibilities of that kind of *defensive programming:* 

```
(* possibility 1 *)
let random_int bound =
  assert (bound > 0 && bound < 1 lsl 30);
  (* proceed with the implementation of the function *)

(* possibility 2 *)
let random_int bound =
  if not (bound > 0 && bound < 1 lsl 30)
  then invalid_arg "bound";
  (* proceed with the implementation of the function *)

(* possibility 3 *)
let random_int bound =
  if not (bound > 0 && bound < 1 lsl 30)
  then failwith "bound";
  (* proceed with the implementation of the function *)
```

The second possibility is probably the most informative to the client,
because it uses the built-in function `invalid_arg` to raise the 
well-named exception `Invalid_argument`.  (And in fact that's exactly
what the standard library implementation of this function does.)

The first possibility is probably most useful when you are trying to
debug your own code, rather than choosing to expose a failed assertion
to a client.

The third possibility differs from the second only in the name (`Failure`)
of the exception that is raised.  It might be useful in situations where
the precondition involves more than just a single invalid argument.

In this example, checking the precondition is computationally cheap.
In other cases, it might require a lot of computation, so
the implementer of the function might prefer not to check
the precondition, or only to check some inexpensive approximation
to it.

Finally, the implementer might even choose to eliminate the precondition
and restate it as a postcondition:
```
(** [random_int bound] is a random integer between 0 (inclusive)
    and [bound] (exclusive).  Raises: [Invalid_argument "bound"]
    unless [bound] is greater than 0 and less than 2^30. *)
```
Now instead of being free to do whatever when `bound` is too big
or too small, `random_int` must raise an exception.  For
this function, that's probably the best choice.

In this course we're not going to force you to program defensively.
But if you're savvy, you'll start (or continue) doing it anyway. The
small amount of time you spend coding up such defenses will save you
hours of time in debugging, making you a more productive programmer.  
