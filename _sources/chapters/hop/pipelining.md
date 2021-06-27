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

# Pipelining

Suppose we wanted to compute the sum of squares of the numbers from 0 up to $n$.
How might we go about it? Of course (math being the best form of optimization),
the most efficient way would be a closed-form formula:

$$
\frac{n (n+1) (2n+1)}{6}
$$

But let's imagine you've forgotten that formula. In an imperative language you
might use a for loop:

```python
# Python
def sum_sq(n):
	sum = 0
	for i in range(0, n):
		sum += i * i
	return sum
```

The equivalent (tail) recursive code in OCaml would be:
```{code-cell} ocaml
let sum_sq n =
  let rec loop i sum =
    if i > n then sum
    else loop (i + 1) (sum + i * i)
  in loop 0 0
```

Another, clearer way of producing the same result in OCaml uses higher-order
functions and the pipeline operator:
```{code-cell} ocaml
let rec ( -- ) i j = if i > j then [] else i :: i + 1 -- j
let square x = x * x
let sum = List.fold_left ( + ) 0

let sum_sq n =
  0 -- n              (* [0;1;2;...;n]   *)
  |> List.map square  (* [0;1;4;...;n*n] *)
  |> sum              (*  0+1+4+...+n*n  *)
```
The function `sum_sq` first constructs a list containing all the numbers `0..n`.
Then it uses the pipeline operator `|>` to pass that list through
`List.map square`, which squares every element. Then the resulting list is
pipelined through `sum`, which adds all the elements together.

The other alternatives that you might consider are somewhat uglier:
```{code-cell} ocaml
(* Maybe worse: a lot of extra [let..in] syntax and unnecessary names to
   for intermediate values we don't care about. *)
let sum_sq n =
  let l = 0 -- n in
  let sq_l = List.map square l in
  sum sq_l

(* Maybe worse: have to read the function applications from right to left
   rather than top to bottom, and extra parentheses. *)
let sum_sq n =
  sum (List.map square (0--n))
```

The downside of all of these compared to the original tail recursive version is
that they are wasteful of space&mdash;linear instead of constant&mdash;and take
a constant factor more time. So as is so often the case in programming, there is
a tradeoff between clarity and efficiency of code.

Note that the inefficiency is *not* from the pipeline operator itself, but from
having to construct all those unnecessary intermediate lists. So don't get the
idea that pipelining is intrinsically bad. In fact it can be quite useful. When
we get to the chapter on modules, we'll use it quite often with some of the data
structures we study there.
