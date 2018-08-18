# Documentation

OCaml provides a tool called OCamldoc that works a lot like
Java's Javadoc tool:  it extracts specially formatted comments
from source code and renders them as HTML, making it easy for
programmers to read documentation.

## How to document

Here's an example of an OCamldoc comment:
```
(** [sum lst] is the sum of the elements of [lst]. *)
let rec sum lst = ...
```

* The double asterisk is what causes the comment to be
  recognized as an OCamldoc comment that should be extracted.

* The square brackets around parts of the comment mean
  that those parts should be rendered in HTML as `typewriter font`
  rather than the regular font.  

Also like Javadoc, OCamldoc supports *documentation tags*,
such as `@author`, `@deprecated`, `@param`, `@return`, etc.  For
example, in the first line of most programming assignments, we ask you
to complete a comment like this:

```
(** @author Your Name (your netid) *)
```

For the full range of possible markup inside a OCamldoc comment,
see [the OCamldoc manual](https://caml.inria.fr/pub/docs/manual-ocaml/ocamldoc.html).
But what we've covered here is good enough for most documentation
that you'll need to write.

## What to document

The documentation style we favor in this course resembles that
of the OCaml standard library:  concise and declarative.  As an
example, let's revisit the documentation of `sum`:
```
(** [sum lst] is the sum of the elements of [lst]. *)
let rec sum lst = ...
```

That comment starts with `sum lst`, which is an example application of
the function to an argument.  The comment continues with the word "is",
thus declaratively describing the result of the application.  (The word
"returns" could be used instead, but "is" emphasizes the mathematical
nature of the function.)  That description uses the name of the
argument, `lst`, to explain the result.

Note how there is no need to additionally add tags to redundantly
describe parameters or return values, as is often done with Javadoc. 
Everything that needs to be said has already been said.  We strongly
discourage documentation like the following:
```
(** Sum a list.
    @param lst The list to be summed.
    @return The sum of the list. *)
let rec sum lst = ...
```
That poor documentation takes three needlessly hard-to-read lines to say
the same thing as the limpid one-line version.

There are two ways we might improve the documentation we have so far. 
The first is that it is silent about what happens when `lst` is empty. 
Mathematically, of course, that's well defined:  the sum of an empty
sequence is 0.  But that's a question that might reasonably arise in a
reader's mind.  So adding it to the documentation doesn't hurt.
```
(** [sum lst] is the sum of the elements of [lst]. 
    The sum of an empty list is 0. *)
let rec sum lst = ...
```

The second is that it doesn't hurt to clarify the type of the
arguments in the documentation, as follows:
```
(** [sum lst] is the sum of the elements of list [lst]. 
    The sum of an empty list is 0. *)
let rec sum lst = ...
```

Since the variable name `lst` is so naturally read as a list,
this usage might be overkill.  But in the examples in the next
section, providing that extra clarification is useful.