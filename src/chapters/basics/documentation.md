# Documentation

OCaml provides a tool called OCamldoc that works a lot like Java's Javadoc tool:
it extracts specially formatted comments from source code and renders them as
HTML, making it easy for programmers to read documentation.

## How to Document

Here's an example of an OCamldoc comment:
```ocaml
(** [sum lst] is the sum of the elements of [lst]. *)
let rec sum lst = ...
```

* The double asterisk is what causes the comment to be recognized as an OCamldoc
  comment.

* The square brackets around parts of the comment mean that those parts should
  be rendered in HTML as `typewriter font` rather than the regular font.

Also like Javadoc, OCamldoc supports *documentation tags*, such as `@author`,
`@deprecated`, `@param`, `@return`, etc. For example, in the first line of most
programming assignments, we ask you to complete a comment like this:

```ocaml
(** @author Your Name (your netid) *)
```

For the full range of possible markup inside a OCamldoc comment, see
[the OCamldoc manual](https://ocaml.org/manual/ocamldoc.html).
But what we've covered here is good enough for most documentation that you'll
need to write.

## What to Document

The documentation style we favor in this book resembles that of the OCaml
standard library: concise and declarative. As an example, let's revisit the
documentation of `sum`:
```ocaml
(** [sum lst] is the sum of the elements of [lst]. *)
let rec sum lst = ...
```

That comment starts with `sum lst`, which is an example application of the
function to an argument. The comment continues with the word "is", thus
declaratively describing the result of the application. (The word "returns"
could be used instead, but "is" emphasizes the mathematical nature of the
function.) That description uses the name of the argument, `lst`, to explain the
result.

Note how there is no need to add tags to redundantly describe parameters or
return values, as is often done with Javadoc. Everything that needs to be said
has already been said. We strongly discourage documentation like the following:
```ocaml
(** Sum a list.
    @param lst The list to be summed.
    @return The sum of the list. *)
let rec sum lst = ...
```
That poor documentation takes three needlessly hard-to-read lines to say the
same thing as the limpid one-line version.

There is one way we might improve the documentation we have so far, which is to
explicitly state what happens with empty lists:
```ocaml
(** [sum lst] is the sum of the elements of [lst].
    The sum of an empty list is 0. *)
let rec sum lst = ...
```

## Preconditions and Postconditions

Here are a few more examples of comments written in the style we favor.
```ocaml
(** [lowercase_ascii c] is the lowercase ASCII equivalent of
    character [c]. *)

(** [index s c] is the index of the first occurrence of
    character [c] in string [s].  Raises: [Not_found]
    if [c] does not occur in [s]. *)

(** [random_int bound] is a random integer between 0 (inclusive)
    and [bound] (exclusive).  Requires: [bound] is greater than 0
    and less than 2^30. *)
```

The documentation of `index` specifies that the function raises an exception, as
well as what that exception is and the condition under which it is raised. (We
will cover exceptions in more detail in the next chapter.) The documentation of
`random_int` specifies that the function's argument must satisfy a condition.

In previous courses, you were exposed to the ideas of *preconditions* and
*postconditions*. A precondition is something that must be true before some
section of code; and a postcondition, after.

The "Requires" clause above in the documentation of `random_int` is a kind of
precondition. It says that the client of the `random_int` function is
responsible for guaranteeing something about the value of `bound`. Likewise, the
first sentence of that same documentation is a kind of postcondition. It
guarantees something about the value returned by the function.

The "Raises" clause in the documentation of `index` is another kind of
postcondition. It guarantees that the function raises an exception.
Note that the clause is not a precondition, even though it states a condition in
terms of an input.

Note that none of these examples has a "Requires" clause that says something
about the type of an input. If you're coming from a dynamically-typed language,
like Python, this could be a surprise. Python programmers frequently document
preconditions regarding the types of function inputs. OCaml programmers,
however, do not. That's because the compiler itself does the type checking to
ensure that you never pass a value of the wrong type to a function. Consider
`lowercase_ascii` again: although the English comment helpfully identifies the
type of `c` to the reader, the comment does not state a "Requires" clause like
this:
```ocaml
(** [lowercase_ascii c] is the lowercase ASCII equivalent of [c].
    Requires: [c] is a character. *)
```
Such a comment reads as highly unidiomatic to an OCaml programmer, who would
read that comment and be puzzled, perhaps thinking: "Well of course `c` is a
character; the compiler will guarantee that. What did the person who wrote that
really mean? Is there something they or I am missing?"
