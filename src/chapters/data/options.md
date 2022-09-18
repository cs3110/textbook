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

# Options

{{ video_embed | replace("%%VID%%", "lByoIw5wpao")}}

Suppose you want to write a function that *usually* returns a value of type `t`,
but *sometimes* returns nothing. For example, you might want to define a
function `list_max` that returns the maximum value in a list, but there's not a
sensible thing to return on an empty list:

```ocaml
let rec list_max = function
  | [] -> ???
  | h :: t -> max h (list_max t)
```

There are a couple possibilities to consider:

 - Return `min_int`? But then `list_max` will only work for integers&mdash; not
   floats or other types.

 - Raise an exception? But then the user of the function has to remember to
   catch the exception.

 - Return `null`? That works in Java, but by design OCaml does not have a `null`
   value. That's actually a good thing: null pointer bugs are not fun to debug.

```{note}
Sir Tony Hoare calls his invention of `null` a
["billion-dollar mistake"][null-mistake].
```

[null-mistake]: https://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare/

In addition to those possibilities, OCaml provides something even better called
an *option.* (Haskellers will recognize options as the Maybe monad.)

You can think of an option as being like a closed box. Maybe there's something
inside the box, or maybe box is empty. We don't know which until we open the
box. If there turns out to be something inside the box when we open it, we can
take that thing out and use it. Thus, options provide a kind of "maybe type,"
which ultimately is a kind of one-of type: the box is in one of two states, full
or empty.

In `list_max` above, we'd like to metaphorically return a box that's empty if
the list is empty, or a box that contains the maximum element of the list if the
list is non empty.

Here's how we create an option that is like a box with `42` inside it:
```{code-cell} ocaml
Some 42
```
And here's how we create an option that is like an empty box:
```{code-cell} ocaml
None
```
The `Some` means there's something inside the box, and it's `42`. The `None`
means there's nothing inside the box.

Like `list`, we call `option` a *type constructor*: given a type, it produces a
new type; but, it is not itself a type. So for any type `t`, we can write
`t option` as a type. But `option` all by itself cannot be used as a type.
Values of type `t option` might contain a value of type `t`, or they might
contain nothing. `None` has type `'a option` because it's unconstrained what the
type is of the thing inside &mdash; as there isn't anything inside.

You can access the contents of an option value `e` using pattern matching.
Here's a function that extracts an `int` from an option, if there is one inside,
and converts it to a string:
```{code-cell} ocaml
let extract o =
  match o with
  | Some i -> string_of_int i
  | None -> "";;
```
And here are a couple of example usages of that function:
```{code-cell} ocaml
extract (Some 42);;
extract None;;
```

Here's how we can write `list_max` with options:
```{code-cell} ocaml
let rec list_max = function
  | [] -> None
  | h :: t -> begin
      match list_max t with
        | None -> Some h
        | Some m -> Some (max h m)
      end
```

```{tip}
The `begin`..`end` wrapping the nested pattern match above is not strictly
required here but is not a bad habit, as it will head off potential syntax
errors in more complicated code. The keywords `begin` and `end` are equivalent
to `(` and `)`.
```

In Java, every object reference is implicitly an option. Either there is an
object inside the reference, or there is nothing there. That "nothing" is
represented by the value `null`. Java does not force programmers to explicitly
check for the null case, which leads to null pointer exceptions. OCaml options
force the programmer to include a branch in the pattern match for `None`, thus
guaranteeing that the programmer thinks about the right thing to do when there's
nothing there. So we can think of options as a principled way of eliminating
`null` from the language. Using options is usually considered better coding
practice than raising exceptions, because it forces the caller to do something
sensible in the `None` case.

**Syntax and semantics of options.**

 - `t option` is a type for every type `t`.

 - `None` is a value of type `'a option`.

 - `Some e` is an expression of type `t option` if `e : t`. If `e ==> v` then
   `Some e ==> Some v`
