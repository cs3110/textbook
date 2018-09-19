# Specifications for Functions

*This section continues the discussion of 
[documentation](../basics/documentation.html), which we began in
chapter 2.*

A specification is written for humans to read, not machines. "Specs" can
take time to write well, and it is time well spent. The main goal is
clarity. It is also important to be concise, because client programmers
will not always take the effort to read a long spec. As with anything we
write, we need to be aware of your audience when writing specifications.
Some readers may need a more verbose specification than others.

A well-written specification usually has several parts communicating
different kinds of information about the thing specified. If we know
what the usual ingredients of a specification are, we are less likely to
forget to write down something important. Let's now look at a recipe for
writing specifications.

## Returns Clause

How might we specify `sqr`, a square-root function? First, we need to
describe its result. We will call this description the *returns clause*
because it is a part of the specification that describes the result of a
function call. It is also known as a *postcondition*: it describes a
condition that holds after the function is called. Here is an example of
a returns clause:

```
(* returns: [sqr x] is the square root of [x]. *)
```

But in OCamldoc documentation, we would typically leave out the
`returns:`, and simply write the returns clause as the first
sentence of the comment:

```
(** [sqr x] is the square root of [x]. *)
```

For numerical programming, we should probably add some information about
how accurate it is.

```
(** [sqr x] is the square root of [x].  Its relative accuracy is no worse 
    than 1.0*10^-6. *)
```

Similarly, here's how we might write a returns clause for a `find` function:

```
(** [find lst x] is the index of [x] in [lst], starting from zero. *)
```

A good specification is concise but clear&mdash;it should say enough that
the reader understands what the function does, but without extra
verbiage to plow through and possibly cause the reader to miss the
point. Sometimes there is a balance to be struck between brevity and
clarity.

These two specifications use a useful trick to make them more concise:
they talk about the result of applying the function being specified to
some arbitrary arguments. Implicitly we understand that the stated
postcondition holds for all possible values of any unbound variables
(the argument variables).

## Requires Clause

The specification for `sqr` doesn't completely make sense because the
square root does not exist for some `x` of type `real`. The mathematical
square root function is a *partial* function that is defined over only
part of its domain. A good function specification is complete with
respect to the possible inputs; it provides the client with an
understanding of what inputs are allowed and what the results will be
for allowed inputs.

We have several ways to deal with partial functions. A straightforward
approach is to restrict the domain so that it is clear the function
cannot be legitimately used on some inputs. The specification rules out
bad inputs with a *requires clause* establishing when the function may
be called. This clause is also called a *precondition* because it
describes a condition that must hold before the function is called.
Here is a requires clause for `sqr`:

```
(** [sqr x] is the square root of [x]. Its relative accuracy is no worse 
    than 1.0x10^-6.  Requires: [x >= 0] *)
```

This specification doesn't say what happens when `x < 0`, nor does it
have to. Remember that the specification is a contract. This contract
happens to push the burden of showing that the square root exists onto
the client. If the requires clause is not satisfied, the implementation is
permitted to do anything it likes: for example, go into an infinite loop
or throw an exception. The advantage of this approach is that the
implementer is free to design an algorithm without the constraint of
having to check for invalid input parameters, which can be tedious and
slow down the program. The disadvantage is that it may be difficult to
debug if the function is called improperly, because the function can
misbehave and the client has no understanding of how it might misbehave.

## Raises Clause

Another way to deal with partial functions is to convert them into
total functions (functions defined over their entire domain). This
approach is arguably easier for the client to deal with because the
function's behavior is always defined; it has no precondition. However,
it pushes work onto the implementer and may lead to a slower
implementation.

How can we convert `sqr` into a total function? One approach that is
(too) often followed is to define some value that is returned in the
cases that the requires clause would have ruled; for example:

```
(** [sqr x] is the square root of [x] if [x >= 0],
    with relative accuracy no worse than 1.0x10^-6.
    Otherwise, a negative number is returned. *)
```

This practice is not recommended because it tends to encourage broken,
hard-to-read client code. Almost any correct client of this abstraction will
write code like this if the precondition cannot be argued to hold:

```
if sqr(a) < 0.0 then ... else ...
```

The error must still be handled in the `if` expression, so
the job of the client of this abstraction isn't any easier than with a
requires clause: the client still needs to wrap an explicit test around
the call in cases where it might fail. If the test is omitted, the
compiler won't complain, and the negative number result will be silently
treated as if it were a valid square root, likely causing errors later
during program execution. This coding style has been the source of
innumerable bugs and security problems in the Unix operating systems and
its descendents (e.g., Linux).

A better way to make functions total is to have them raise an exception
when the expected input condition is not met. Exceptions avoid
the necessity of distracting error-handling logic in the client's code. If
the function is to be total, the specification must say what exception
is raised and when.  For example, we
might make our square root function total as follows:

```
(** [sqr x] is the square root of [x], with relative accuracy no worse 
    than 1.0x10^-6. Raises: [Negative] if [x < 0]. *)
```

Note that the implementation of this `sqr` function must check whether
`x >= 0`, even in the production version of the code, because some client
may be relying on the exception to be raised.

## Examples Clause

It can be useful to provide an illustrative
example as part of a specification. No matter how clear and well written
the specification is, an example is often useful to clients.

```
(** [find lst x] is the index of [x] in [lst], starting from zero.
    Example: [find ["b","a","c"] "a" = 1]. *)
```
