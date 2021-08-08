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

# Currying

We've already seen that an OCaml function that takes two arguments of types `t1`
and `t2` and returns a value of type `t3` has the type `t1 -> t2 -> t3`. We use
two variables after the function name in the let expression:

```{code-cell} ocaml
let add x y = x + y
```

Another way to define a function that takes two arguments is to write a function
that takes a tuple:

```{code-cell} ocaml
let add' t = fst t + snd t
```

Instead of using `fst` and `snd`, we could use a tuple pattern in the
definition of the function, leading to a third implementation:

```{code-cell} ocaml
let add'' (x, y) = x + y
```

Functions written using the first style (with type `t1 -> t2 -> t3`) are called
*curried* functions, and functions using the second style (with type
`t1 * t2 -> t3`) are called *uncurried*. Metaphorically, curried functions are
"spicier" because you can partially apply them (something you can't do with
uncurried functions: you can't pass in half of a pair). Actually, the term curry
does not refer to spices, but to a logician named [Haskell Curry][curry] (one of
a very small set of people with programming languages named after both their
first and last names).

[curry]: https://en.wikipedia.org/wiki/Haskell_Curry

Sometimes you will come across libraries that offer an uncurried version of a
function, but you want a curried version of it to use in your own code; or vice
versa. So it is useful to know how to convert between the two kinds of
functions, as we did with `add` above.

You could even write a couple of higher-order functions to do the conversion
for you:

```{code-cell} ocaml
let curry f x y = f (x, y)
let uncurry f (x, y) = f x y
```

```{code-cell} ocaml
let uncurried_add = uncurry add
let curried_add = curry add''
```
