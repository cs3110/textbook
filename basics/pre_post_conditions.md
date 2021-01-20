# Preconditions and Postconditions

Here are a few more examples of comments written in the style
we favor in this course.
```
(** [lowercase_ascii c] is the lowercase ASCII equivalent of 
    character [c]. *)

(** [index s c] is the index of the first occurrence of 
    character [c] in string [s].  Raises: [Not_found] 
    if [c] does not occur in [s]. *)
    
(** [random_int bound] is a random integer between 0 (inclusive)
    and [bound] (exclusive).  Requires: [bound] is greater than 0 
    and less than 2^30. *)
```

The documentation of `index` specifies that the function raises an
exception, as well as what that exception is and the condition under
which it is raised.  (We will cover exceptions in more detail in the
next chapter.)  The documentation of `random_int` specifies that the
function's argument must satisfy a condition.

In studying Python and Java in CS 1110 and 2110, you were exposed to the
ideas of *preconditions* and *postconditions*. A precondition is
something that must be true before some section of code; and a
postcondition, after.

The "Requires" clause above in the documentation of `random_int` is a
kind of precondition.  It says that the client of the `random_int`
function is responsible for guaranteeing something about the value of
`bound`. Likewise, the first sentence of that same documentation is a
kind of postcondition.  It guarantees something about the value returned
by the function.

The "Raises" clause in the documentation of `index` is another kind of
postcondition.  It guarantees that the function raises an exception.  
Note that the clause is not a precondition, even though it states a condition in
terms of an input.

Note that none of these examples has a "Requires" clause that says
something about the type of an input.  If you're coming from a
dynamically-typed language, like Python, this could be a surprise.
Python programmers frequently document preconditions regarding
the types of function inputs.  OCaml programmers, however, do not.
That's because the compiler itself does the type checking to ensure
that you never pass a value of the wrong type to a function. 
Consider `lowercase_ascii` again:  although the English comment
helpfully identifies the type of `c` to the reader, the comment
does not state a "Requires" clause like this:
```
(** [lowercase_ascii c] is the lowercase ASCII equivalent of [c].
    Requires: [c] is a character. *)
```
Such a comment reads as highly unidiomatic to an OCaml programmer, who
would read that comment and be puzzled, perhaps thinking: "Well of
course `c` is a character; the compiler will guarantee that.  What did
the person who wrote that really mean?  Is there something they or I am
missing?"

