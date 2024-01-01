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

# Function Documentation

*This section continues the discussion of
[documentation](../basics/documentation), which we began in chapter 2.*

{{ video_embed | replace("%%VID%%", "ggm5rjAyjhw")}}

A specification is written for humans to read, not machines. "Specs" can take
time to write well, and it is time well spent. The main goal is clarity. It is
also important to be concise, because client programmers will not always take
the effort to read a long spec. As with anything we write, we need to be aware
of our audience when writing specifications. Some readers may need a more
verbose specification than others.

A well-written specification usually has several parts communicating different
kinds of information about the thing specified. If we know what the usual
ingredients of a specification are, we are less likely to forget to write down
something important. Let's now look at a recipe for writing specifications.

{{ video_embed | replace("%%VID%%", "p5OTwjNTQIs")}}

## Returns Clause

How might we specify `sqr`, a square-root function? First, we need to describe
its result. We will call this description the *returns clause* because it is a
part of the specification that describes the result of a function call. It is
also known as a *postcondition*: it describes a condition that holds after the
function is called. Here is an example of a returns clause:

```ocaml
(** returns: [sqr x] is the square root of [x]. *)
```

But we would typically leave out the `returns:`, and simply write the returns
clause as the first sentence of the comment:

```ocaml
(** [sqr x] is the square root of [x]. *)
```

For numerical programming, we should probably add some information about how
accurate it is.

```ocaml
(** [sqr x] is the square root of [x]. Its relative accuracy is no worse than
    [1.0e-6]. *)
```

Similarly, here's how we might write a returns clause for a `find` function:

```ocaml
(** [find lst x] is the index of [x] in [lst], starting from zero. *)
```

A good specification is concise but clear&mdash;it should say enough that the
reader understands what the function does, but without extra verbiage to plow
through and possibly cause the reader to miss the point. Sometimes there is a
balance to be struck between brevity and clarity.

These two specifications use a useful trick to make them more concise: they talk
about the result of applying the function being specified to some arbitrary
arguments. Implicitly we understand that the stated postcondition holds for all
possible values of any unbound variables (the argument variables).

## Requires Clause

The specification for `sqr` doesn't completely make sense because the square
root does not exist for some `x` of type `real`. The mathematical square root
function is a *partial* function that is defined over only part of its domain. A
good function specification is complete with respect to the possible inputs; it
provides the client with an understanding of what inputs are allowed and what
the results will be for allowed inputs.

We have several ways to deal with partial functions. A straightforward approach
is to restrict the domain so that it is clear the function cannot be
legitimately used on some inputs. The specification rules out bad inputs with a
*requires clause* establishing when the function may be called. This clause is
also called a *precondition* because it describes a condition that must hold
before the function is called. Here is a requires clause for `sqr`:

```ocaml
(** [sqr x] is the square root of [x]. Its relative accuracy is no worse
    than [1.0e-6].  Requires: [x >= 0] *)
```

This specification doesn't say what happens when `x < 0`, nor does it have to.
Remember that the specification is a contract. This contract happens to push the
burden of showing that the square root exists onto the client. If the requires
clause is not satisfied, the implementation is permitted to do anything it
likes: for example, go into an infinite loop or throw an exception. The
advantage of this approach is that the implementer is free to design an
algorithm without the constraint of having to check for invalid input
parameters, which can be tedious and slow down the program. The disadvantage is
that it may be difficult to debug if the function is called improperly, because
the function can misbehave and the client has no understanding of how it might
misbehave.

## Raises Clause

Another way to deal with partial functions is to convert them into total
functions (functions defined over their entire domain). This approach is
arguably easier for the client to deal with because the function's behavior is
always defined; it has no precondition. However, it pushes work onto the
implementer and may lead to a slower implementation.

How can we convert `sqr` into a total function? One approach that is (too) often
followed is to define some value that is returned in the cases that the requires
clause would have ruled; for example:

```ocaml
(** [sqr x] is the square root of [x] if [x >= 0],
    with relative accuracy no worse than 1.0e-6.
    Otherwise, a negative number is returned. *)
```

This practice is not recommended because it tends to encourage broken,
hard-to-read client code. Almost any correct client of this abstraction will
write code like this if the precondition cannot be argued to hold:

```ocaml
if sqr(a) < 0.0 then ... else ...
```

The error must still be handled in the `if` expression, so the job of the client
of this abstraction isn't any easier than with a requires clause: the client
still needs to wrap an explicit test around the call in cases where it might
fail. If the test is omitted, the compiler won't complain, and the negative
number result will be silently treated as if it were a valid square root, likely
causing errors later during program execution. This coding style has been the
source of innumerable bugs and security problems in the Unix operating systems
and its descendents (e.g., Linux).

A better way to make functions total is to have them raise an exception when the
expected input condition is not met. Exceptions avoid the necessity of
distracting error-handling logic in the client's code. If the function is to be
total, the specification must say what exception is raised and when. For
example, we might make our square root function total as follows:

```ocaml
(** [sqr x] is the square root of [x], with relative accuracy no worse
    than 1.0e-6. Raises: [Negative] if [x < 0]. *)
```

Note that the implementation of this `sqr` function must check whether `x >= 0`,
even in the production version of the code, because some client may be relying
on the exception to be raised.

## Examples Clause

It can be useful to provide an illustrative example as part of a specification.
No matter how clear and well written the specification is, an example is often
useful to clients.

```ocaml
(** [find lst x] is the index of [x] in [lst], starting from zero.
    Example: [find ["b","a","c"] "a" = 1]. *)
```

## The Specification Game

When evaluating specifications, it can be useful to imagine that a game is being
played between two people: a *specifier* and a *devious programmer.*

Suppose that the specifier writes the following specification:

```ocaml
(** returns a list *)
val reverse : 'a list -> 'a list
```

This spec is clearly incomplete.  For example, a devious programmer could meet
the spec with an implementation that gives the following output:

```ocaml
# reverse [1; 2; 3];;
- : int list = []
```

The specifier, upon realizing this, refines the spec as follows:

```ocaml
(** [reverse lst] returns a list that is the same length as [lst] *)
val reverse : 'a list -> 'a list
```

But the specifier discovers that the spec still allows broken
implementations:

```ocaml
# reverse [1; 2; 3];;
- : int list = [0; 0; 0]
```

Finally, the specifier settles on a third spec:

```ocaml
(** [reverse lst] returns a list [m] satisfying the following conditions:
    - [length lst = length m]
    - for all [i], [nth m i = nth lst (n - i - 1)],
      where [n] is the length of [lst].
    For example, [reverse [1; 2; 3]] is [3; 2; 1], and [reverse []] is []. *)
val reverse : 'a list -> 'a list
```

With this spec, the devious programmer is forced to provide a working
implementation to meet the spec, so the specifier has successfully written her
spec.

The point of playing this game is to improve your ability to write
specifications. Obviously we're not advocating that you deliberately try to
violate the intent of a specification and get away with it. When reading someone
else's specification, read as generously as possible. But be ruthless about
improving your own specifications.

## Comments

In addition to specifying functions, programmers need to provide comments in the
body of the functions. In fact, programmers usually do not write enough comments
in their code. (For a classic example, check out the
[actual comment on line 561][quake3-wtf] of the Quake 3 Arena game engine.)

[quake3-wtf]: https://archive.softwareheritage.org/swh:1:cnt:bb0faf6919fc60636b2696f32ec9b3c2adb247fe;origin=https://github.com/id-Software/Quake-III-Arena;visit=swh:1:snp:4ab9bcef131aaf449a7c01370aff8c91dcecbf5f;anchor=swh:1:rev:dbe4ddb10315479fc00086f08e25d968b4b43c49;path=/code/game/q_math.c;lines=558-564

But this doesn't mean that adding more comments is always better. The wrong
comments will simply obscure the code further. Shoveling as many comments into
code as possible usually makes the code worse! Both code and comments are
precise tools for communication (with the computer and with other programmers)
that should be wielded carefully.

It is particularly annoying to read code that contains many interspersed
comments (typically of questionable value), e.g.:

```ocaml
let y = x + 1 (* make y one greater than x *)
```

For complex algorithms, some comments may be necessary to explain how the code
implementing the algorithm works. Programmers are often tempted to write
comments about the algorithm interspersed through the code. But someone reading
the code will often find these comments confusing because they don't have a
high-level picture of the algorithm. It is usually better to write a
paragraph-style comment at the beginning of the function explaining how its
implementation works. Explicit points in the code that need to be related to
that paragraph can then be marked with very brief comments, like `(* case 1 *)`.

Another common but well-intentioned mistake is giving variables long,
descriptive names, as in the following verbose code:

```{code-cell} ocaml
let number_of_zeros the_list =
  List.fold_left (fun (accumulator : int) (list_element : int) ->
    accumulator + (if list_element = 0 then 1 else 0)) 0 the_list
```

Code using such long names is verbose and hard to read. Instead of trying to
embed a complete description of a variable in its name, use a short and
suggestive name (e.g., `zeros`), and if necessary, add a comment at its
declaration explaining the purpose of the variable.

```{code-cell} ocaml
let zeros lst =
  let is0 = function 0 -> 1 | _ -> 0 in
  List.fold_left (fun zs x -> zs + is0 x) 0 lst
```

A similarly bad practice is to encode the type of the variable in its name,
e.g., naming a variable `i_count` to show that it's an integer. The type system
is going to guarantee that for you, and your editor can provide a hover-over to
show the type. If you really want to emphasize the type in the code, add a type
annotation at the point where the variable comes into scope.
