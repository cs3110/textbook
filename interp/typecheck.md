# Type Checking

After lexing and parsing, the next phase of compilation is semantic
analysis, and the primary task of semantic analysis is type checking.

A *type system* is a mathematical description of how to determine
whether an expression is *ill typed* or *well typed*, and in the
latter case, what the type of the expression is.  A *type checker*
is a program that implements a type system.

Commonly, a type system is formulated as a ternary relation 
\\(\\mathit{HasType}(\\Gamma, e, t)\\), which means that expression
\\(e\\) has type \\(t\\) in typing context \\(\\Gamma\\).
A *typing context*, aka *typing environment*, is a map from
identifiers to types.  The context is used to record what variables
are in scope, and what their types are.  The use of the Greek letter
\\(\\Gamma\\) for contexts is traditional.

That ternary relation is typically written with infix notation, though,
as \\(\\Gamma \\vdash e : t\\).  You can read the turnstile symbol
\\(\\vdash\\) as "proves" or "shows", i.e., the context \\(\\Gamma\\)
shows that \\(e\\) has type \\(t\\).

Let's make that notation a little friendlier by eliminating the Greek
and the math typesetting.  We'll just write `ctx |- e : t` to mean
that typing context `ctx` shows that `e` has type `t`.  Let's write
`{}` for the empty context, and `x:t` to mean that `x` is bound to `t`.
So, `{foo:int, bar:bool}` would be the context is which `foo`
has type `int` and `bar` has type `bool`.  A context may bind an
identifier at most once.  We'll write `ctx[x -> t]` to mean
a context that contains all the bindings of `ctx`, and also binds
`x` to `t`.  If `x` was already bound in `ctx`, then that old binding
is replaced by the new binding to `t` in `ctx[x -> t]`.

With all that machinery, we can at least define what it means to
be well typed:
An expression `e` is **well typed** if there exists a type `t` for
which `{} |- e : t`.
The goal of a type checker is thus to find such a type `t`.

In practice, it's rare that a language truly uses the empty context
to determine whether a program is well typed.
In OCaml, for example, there are many built-in identifiers that
are always in scope, such as everything in the `Pervasives` module.
We won't worry about that detail in our presentation here.



