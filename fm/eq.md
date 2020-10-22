# Equality

When are two expressions equal?  Two possible answers are:

- When they are syntatically identical.

- When they are semantically equivalent: they produce the same value.

For example, are `42` and `41+1` equal?  The syntactic answer
would say they are not, because they involve different tokens.
The semantic answer would say they are:  they both produce the value `42`.

What about functions:  are `fun x -> x` and `fun y -> y` equal?  Syntactically
they are different.  But semantically, they both produce a value that is the
identity function:  when they are applied to an input, they will both produce
the same output.  That is, `(fun x -> x) z = z`, and `(fun y -> y) z =  z`. If
it is the case that for all inputs two functions produce the same output,
we will consider the functions to be equal:
```
if (forall x, f x = g x), then f = g.
```
That definition of equality for functions is known as the *Axiom of
Extensionality* in some branches of mathematics; henceforth we'll refer to it
simply as "extensionality".

Here we will adopt the semantic approach.  If `e1` and `e2` evaluate to the same
value `v`, then we write `e1 = e2`.  We are using `=` here in a mathematical
sense of equality, not as the OCaml polymorphic equality operator.  For example,
we allow `(fun x -> x) = (fun y -> y)`, even though OCaml's operator would raise
an exception and refuse to compare functions.

We're also going to restrict ourselves to expressions that are well typed, pure
(meaning they have no side effects), and total (meaning they don't have
exceptions or infinite loops).