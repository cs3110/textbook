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

# Fold

The map functional gives us a way to individually transform each element of a
list. The filter functional gives us a way to individually decide whether to
keep or throw away each element of a list. But both of those are really just
looking at a single element at a time. What if we wanted to somehow combine all
the elements of a list? That's what the *fold* functional is for. It turns out
that there are two versions of it, which we'll study in this section. But to
start, let's look at a related function&mdash;not actually in the standard
library&mdash;that we call *combine*.

## Combine

{{ video_embed | replace("%%VID%%", "uYJVwW2BFPg")}}

Once more, let's write two functions:

```{code-cell} ocaml
(** [sum lst] is the sum of all the elements of [lst]. *)
let rec sum = function
  | [] -> 0
  | h :: t -> h + sum t

let s = sum [1; 2; 3]
```

```{code-cell} ocaml
(** [concat lst] is the concatenation of all the elements of [lst]. *)
let rec concat = function
  | [] -> ""
  | h :: t -> h ^ concat t

let c = concat ["a"; "b"; "c"]
```

As when we went through similar exercises with map and filter, the functions
share a great deal of common structure. The differences here are:

* the case for the empty list returns a different initial value, `0` vs `""`

* the case of a non-empty list uses a different operator to combine the head
  element with the result of the recursive call, `+` vs `^`.

So can we apply the Abstraction Principle again? Sure! But this time we need to
factor out *two* arguments: one for each of those two differences.

To start, let's factor out only the initial value:
```{code-cell} ocaml
let rec sum' init = function
  | [] -> init
  | h :: t -> h + sum' init t

let sum = sum' 0

let rec concat' init = function
  | [] -> init
  | h :: t -> h ^ concat' init t

let concat = concat' ""
```
Now the only real difference left between `sum'` and `concat'` is the operator
used to combine the head with the recursive call on the tail. That operator can
also become an argument to a unified function we call `combine`:
```{code-cell} ocaml
let rec combine op init = function
  | [] -> init
  | h :: t -> op h (combine op init t)

let sum = combine ( + ) 0
let concat = combine ( ^ ) ""
```

One way to think of `combine` would be that:

- the `[]` value in the list gets replaced by `init`, and

- each `::` constructor gets replaced by `op`.

For example, `[a; b; c]` is just syntactic sugar for `a :: (b :: (c :: []))`. So
if we replace `[]` with `0` and `::` with `(+)`, we get `a + (b + (c + 0))`.
And that would be the sum of the list.

Once more, the Abstraction Principle has led us to an amazingly simple and
succinct expression of the computation.

## Fold Right

{{ video_embed | replace("%%VID%%", "WKKkIGncRn8")}}

The `combine` function is the idea underlying an actual OCaml library function.
To get there, we need to make a couple of changes to the implementation we have
so far.

First, let's rename some of the arguments: we'll change `op` to `f` to emphasize
that really we could pass in any function, not just a built-in operator like
`+`. And we'll change `init` to `acc`, which as usual stands for "accumulator".
That yields:

```{code-cell} ocaml
let rec combine f acc = function
  | [] -> acc
  | h :: t -> f h (combine f acc t)
```

Second, let's make an admittedly less well-motivated change. We'll swap the
implicit list argument to `combine` with the `init` argument:

```{code-cell} ocaml
let rec combine' f lst acc = match lst with
  | [] -> acc
  | h :: t -> f h (combine' f t acc)

let sum lst = combine' ( + ) lst 0
let concat lst = combine' ( ^ ) lst ""
```

It's a little less convenient to code the function this way, because we no
longer get to take advantage of the `function` keyword, nor of partial
application in defining `sum` and `concat`. But there's no algorithmic change.

What we now have is the actual implementation of the standard library function
`List.fold_right`. All we have left to do is change the function name:

```{code-cell} ocaml
let rec fold_right f lst acc = match lst with
  | [] -> acc
  | h :: t -> f h (fold_right f t acc)
```

Why is this function called "fold right"? The intuition is that the way it works
is to "fold in" elements of the list from the right to the left, combining each
new element using the operator. For example, `fold_right ( + ) [a; b; c] 0`
results in evaluation of the expression `a + (b + (c + 0))`. The parentheses
associate from the right-most subexpression to the left.

## Tail Recursion and Combine

Neither `fold_right` nor `combine` are tail recursive: after the recursive call
returns, there is still work to be done in applying the function argument `f` or
`op`. Let's go back to `combine` and rewrite it to be tail recursive. All that
requires is to change the cons branch:

```{code-cell} ocaml
let rec combine_tr f acc = function
  | [] -> acc
  | h :: t -> combine_tr f (f acc h) t  (* only real change *)
```

(Careful readers will notice that the type of `combine_tr` is different than the
type of `combine`. We will address that soon.)

Now the function `f` is applied to the head element `h` and the accumulator
`acc` *before* the recursive call is made, thus ensuring there's no work
remaining to be done after the call returns.  If that seems a little mysterious,
here's a rewriting of the two functions that might help:

```{code-cell} ocaml
let rec combine f acc = function
  | [] -> acc
  | h :: t ->
    let acc' = combine f acc t in
    f h acc'

let rec combine_tr f acc = function
  | [] -> acc
  | h :: t ->
    let acc' = f acc h in
    combine_tr f acc' t
```

Pay close attention to the definition of `acc'`, the new accumulator, in each
of those version:

- In the original version, we procrastinate using the head element `h`. First,
  we combine all the remaining tail elements to get `acc'`. Only then do we use
  `f` to fold in the head. So the value passed as the initial value of `acc`
  turns out to be the same for every recursive invocation of `combine`: it's
  passed all the way down to where it's needed, at the right-most element of the
  list, then used there exactly once.

- But in the tail recursive version, we "pre-crastinate" by immediately folding
  `h` in with the old accumulator `acc`. Then we fold that in with all the tail
  elements. So at each recursive invocation, the value passed as the argument
  `acc` can be different.

The tail recursive version of combine works just fine for summation (and
concatenation, which we elide):

```{code-cell} ocaml
let sum = combine_tr ( + ) 0
let s = sum [1; 2; 3]
```

But something possibly surprising happens with subtraction:

```{code-cell} ocaml
let sub = combine ( - ) 0
let s = sub [3; 2; 1]

let sub_tr = combine_tr ( - ) 0
let s' = sub_tr [3; 2; 1]
```

The two results are different!

- With `combine` we compute `3 - (2 - (1 - 0))`. First we fold in `1`, then `2`,
  then `3`. We are processing the list from right to left, putting the initial
  accumulator at the far right.

- But with `combine_tr` we compute `(((0 - 3) - 2) - 1)`. We are processing the
  list from left to right, putting the initial accumulator at the far left.

With addition it didn't matter which order we processed the list, because
addition is associative and commutative. But subtraction is not, so the two
directions result in different answers.

Actually this shouldn't be too surprising if we think back to when we made `map`
be tail recursive. Then, we discovered that tail recursion can cause us to
process the list in reverse order from the non-tail recursive version of the
same function. That's what happened here.

## Fold Left

Our `combine_tr` function is also in the standard library under the name
`List.fold_left`:

```{code-cell} ocaml
let rec fold_left f acc = function
  | [] -> acc
  | h :: t -> fold_left f (f acc h) t

let sum = fold_left ( + ) 0
let concat = fold_left ( ^ ) ""
```

We have once more succeeded in applying the Abstraction Principle.

## Fold Left vs. Fold Right

Let's review the differences between `fold_right` and `fold_left`:

- They combine list elements in opposite orders, as indicated by their names.
  Function `fold_right` combines from the right to the left, whereas `fold_left`
  proceeds from the left to the right.

- Function `fold_left` is tail recursive whereas `fold_right` is
  not.

- The types of the functions are different.

Regarding that final point, it can be hard to remember what those types are!
Luckily we can always ask the toplevel:

```{code-cell} ocaml
List.fold_left;;
List.fold_right;;
```

To understand those types, look for the list argument in each one of them. That
tells you the type of the values in the list. Then look for the type of the
return value; that tells you the type of the accumulator. From there you can
work out everything else.

* In `fold_left`, the list argument is of type `'b list`, so the list contains
  values of type `'b`. The return type is `'a`, so the accumulator has type
  `'a`. Knowing that, we can figure out that the second argument is the initial
  value of the accumulator (because it has type `'a`). And we can figure out
  that the first argument, the combining operator, takes as its own first
  argument an accumulator value (because it has type `'a`), as its own second
  argument a list element (because it has type `'b`), and returns a new
  accumulator value.

* In `fold_right`, the list argument is of type `'a list`, so the list contains
  values of type `'a`. The return type is `'b`, so the accumulator has type
  `'b`. Knowing that, we can figure out that the third argument is the initial
  value of the accumulator (because it has type `'b`). And we can figure out
  that the first argument, the combining operator, takes as its own second
  argument an accumulator value (because it has type `'b`), as its own first
  argument a list element (because it has type `'a`), and returns a new
  accumulator value.

```{tip}
You might wonder why the argument orders are different between the two `fold`
functions. Good question. Other libraries do in fact use different argument
orders. One way to remember it for OCaml is that in `fold_X` the accumulator
argument goes to the `X` of the list argument.
```

If you find it hard to keep track of all these argument orders, the
[`ListLabels` module][listlabels] in the standard library can help. It uses
labeled arguments to give names to the combining operator (which it calls `f`)
and the initial accumulator value (which it calls `init`). Internally, the
implementation is actually identical to the `List` module.

```{code-cell} ocaml
ListLabels.fold_left;;
ListLabels.fold_left ~f:(fun x y -> x - y) ~init:0 [1;2;3];;
```

```{code-cell} ocaml
ListLabels.fold_right;;
ListLabels.fold_right ~f:(fun y x -> x - y) ~init:0 [1;2;3];;
```

Notice how in the two applications of fold above, we are able to write the
arguments in a uniform order thanks to their labels. However, we still have to
be careful about which argument to the combining operator is the list element
vs. the accumulator value.

[listlabels]: https://ocaml.org/api/ListLabels.html

## A Digression on Labeled Arguments and Fold

It's possible to write our own version of the fold functions that would label
the arguments to the combining operator, so we don't even have to remember their
order:

```{code-cell} ocaml
let rec fold_left ~op:(f: acc:'a -> elt:'b -> 'a) ~init:acc lst =
  match lst with
  | [] -> acc
  | h :: t -> fold_left ~op:f ~init:(f ~acc:acc ~elt:h) t

let rec fold_right ~op:(f: elt:'a -> acc:'b -> 'b) lst ~init:acc =
  match lst with
  | [] -> acc
  | h :: t -> f ~elt:h ~acc:(fold_right ~op:f t ~init:acc)
```

But those functions aren't as useful as they might seem:

```{code-cell} ocaml
:tags: ["raises-exception"]
let s = fold_left ~op:( + ) ~init:0 [1;2;3]
```

The problem is that the built-in `+` operator doesn't have labeled arguments,
so we can't pass it in as the combining operator to our labeled functions.
We'd have to define our own labeled version of it:

```
let add ~acc ~elt = acc + elt
let s = fold_left ~op:add ~init:0 [1; 2; 3]
```

But now we have to remember that the `~acc` parameter to `add` will become
the left-hand argument to `( + )`.  That's not really much of an improvement
over what we had to remember to begin with.

## Using Fold to Implement Other Functions

Folding is so powerful that we can write many other list functions in terms of
`fold_left` or `fold_right`. For example,

```{code-cell} ocaml
let length lst =
  List.fold_left (fun acc _ -> acc + 1) 0 lst

let rev lst =
  List.fold_left (fun acc x -> x :: acc) [] lst

let map f lst =
  List.fold_right (fun x acc -> f x :: acc) lst []

let filter f lst =
  List.fold_right (fun x acc -> if f x then x :: acc else acc) lst []
```

At this point it begins to become debatable whether it's better to express the
computations above using folding or using the ways we have already seen. Even
for an experienced functional programmer, understanding what a fold does can
take longer than reading the naive recursive implementation. If you peruse the
[source code of the standard library][list-src], you'll see that none of the
`List` module internally is implemented in terms of folding, which is perhaps
one comment on the readability of fold. On the other hand, using fold ensures
that the programmer doesn't accidentally program the recursive traversal
incorrectly. And for a data structure that's more complicated than lists, that
robustness might be a win.

[list-src]: https://github.com/ocaml/ocaml/blob/trunk/stdlib/list.ml

## Fold vs. Recursive vs. Library

We've now seen three different ways for writing functions that manipulate lists:

- directly as a recursive function that pattern matches against the empty list
  and against cons,
- using `fold` functions, and
- using other library functions.

Let's try using each of those ways to solve a problem, so that we can appreciate
them better.

Consider writing a function `lst_and: bool list -> bool`, such that
`lst_and [a1; ...; an]` returns whether all elements of the list are `true`.
That is, it evaluates the same as `a1 && a2 && ... && an`. When applied to an
empty list, it evaluates to `true`.

Here are three possible ways of writing such a function. We give each way a
slightly different function name for clarity.

```{code-cell} ocaml
let rec lst_and_rec = function
  | [] -> true
  | h :: t -> h && lst_and_rec t

let lst_and_fold =
	List.fold_left (fun acc elt -> acc && elt) true

let lst_and_lib =
	List.for_all (fun x -> x)
```

The worst-case running time of all three functions is linear in the length of
the list. But:

- The first function, `lst_and_rec` has the advantage that it need not process
  the entire list. It will immediately return `false` the first time they
  discover a `false` element in the list.

- The second function, `lst_and_fold`, will always process every element of the
  list.

- As for the third function `lst_and_lib`, according to the documentation of
  `List.for_all`, it returns `(p a1) && (p a2) && ... && (p an)`. So like
  `lst_and_rec` it need not process every element.
