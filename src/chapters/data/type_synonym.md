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

# Type Synonyms

A *type synonym* is a new name for an already existing type. For example, here
are some type synonyms that might be useful in representing some types from
linear algebra:
```{code-cell} ocaml
type point = float * float
type vector = float list
type matrix = float list list
```

Anywhere that a `float * float` is expected, you could use `point`, and
vice-versa. The two are completely exchangeable for one another. In the
following code, `get_x` doesn't care whether you pass it a value that is
annotated as one vs. the other:

```{code-cell} ocaml
let get_x = fun (x, _) -> x

let p1 : point = (1., 2.)
let p2 : float * float = (1., 3.)

let a = get_x p1
let b = get_x p2
```

Type synonyms are useful because they let us give descriptive names to complex
types. They are a way of making code more self-documenting.
