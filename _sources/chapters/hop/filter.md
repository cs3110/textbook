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

# Filter

Suppose we wanted to filter out only the even numbers from a list, or the odd
numbers.  Here are some functions to do that:

```{code-cell} ocaml
(** [even n] is whether [n] is even. *)
let even n =
  n mod 2 = 0

(** [evens lst] is the sublist of [lst] containing only even numbers. *)
let rec evens = function
  | [] -> []
  | h :: t -> if even h then h :: evens t else evens t

let lst1 = evens [1; 2; 3; 4]
```

```{code-cell} ocaml
(** [odd n] is whether [n] is odd. *)
let odd n =
  n mod 2 <> 0

(** [odds lst] is the sublist of [lst] containing only odd numbers. *)
let rec odds = function
  | [] -> []
  | h :: t -> if odd h then h :: odds t else odds t

let lst2 = odds [1; 2; 3; 4]
```

Functions `evens` and `odds` are nearly the same code: the only essential
difference is the test they apply to the head element. So as we did with `map`
in the previous section, let's factor out that test as a function. Let's name
the function `p` as short for "predicate", which is a fancy way of saying
that it tests whether something is true or false:

```{code-cell} ocaml
let rec filter p = function
  | [] -> []
  | h :: t -> if p h then h :: filter p t else filter p t
```

And now we can reimplement our original two functions:

```{code-cell} ocaml
let evens = filter even
let odds = filter odd
```

How simple these are! How clear! (At least to the reader who is familiar with
`filter`.)

## Filter and Tail Recursion

As we did with `map`, we can create a tail-recursive version of `filter`:

```{code-cell} ocaml
let rec filter_aux p acc = function
  | [] -> acc
  | h :: t -> if p h then filter_aux p (h :: acc) t else filter_aux p acc t

let filter p = filter_aux p []

let lst = filter even [1; 2; 3; 4]
```

And again we discover the output is backwards. Here, the standard library makes
a different choice than it did with `map`. It builds in the reversal to
`List.filter`, which is implemented like this:

```{code-cell} ocaml
let rec filter_aux p acc = function
  | [] -> List.rev acc (* note the built-in reversal *)
  | h :: t -> if p h then filter_aux p (h :: acc) t else filter_aux p acc t

let filter p = filter_aux p []
```

Why does the standard library treat `map` and `filter` differently on this
point? Good question. Perhaps there has simply never been a demand for a
`filter` function whose time efficiency is a constant factor better. Or perhaps
it is just historical accident.

## Filter in Other Languages

Again, the idea of filter exists in many programming languages. Here it is in
Python:
```python
>>> print(list(filter(lambda x: x % 2 == 0, [1, 2, 3, 4])))
[2, 4]
```
And in Java:
```java
jshell> Stream.of(1, 2, 3, 4).filter(x -> x % 2 == 0).collect(Collectors.toList())
$1 ==> [2, 4]
```
