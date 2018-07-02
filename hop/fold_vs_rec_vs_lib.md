# Fold vs. Recursive vs. Library

We've now seen three different ways for writing functions that manipulate lists: 
directly as a recursive function that pattern matches against the empty list and
against cons, using `fold` functions, and using other library functions.
Let's try using each of those ways to solve a problem, so that we can
appreciate them better.

Consider writing a function `lst_and: bool list -> bool`, such that
`lst_and [a1; ...; an]` returns whether all elements of the list are
`true`. That is, it evaluates the same as `a1 && a2 && ... && an`. 
When applied to an empty list, it evaluates to `true`.

Here are three possible ways of writing such a function.  We give
each way a slightly different function name for clarity. 
```
let rec lst_and_rec = function
  | []   -> true
  | h::t -> h && lst_and_rec t

let lst_and_fold =
	List.fold_left (fun acc elt -> acc && elt) true

let lst_and_lib = 
	List.for_all (fun x -> x)
```

The worst-case running time of all three functions is linear in the
length of the list.  But the first function, `lst_and_rec`
has the advantage that it need not process
the entire list:  it will immediately return `false` the first time
they discover a `false` element in the list.  The second function,
`lst_and_fold`, will always process every element of the list.
As for the third function `lst_and_lib`, according to its
documentation it

> returns `(p a1) && (p a2) && ... && (p an)`.

So like `lst_and_rec` it need not process every element.
