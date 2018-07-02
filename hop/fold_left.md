# Fold Left

Given that there's a fold function that works from right to left, it
stands to reason that there's one that works from left to right.  That
function is called `List.fold_left` in the OCaml library.  Here is its
implementation:
```
let rec fold_left op acc = function
    | []   -> acc
    | h::t -> fold_left op (op acc h) t
```
The idea is that `fold_left (+) 0 [a;b;c]` results in evaluation of
`((0+a)+b)+c`.  The parentheses associate from the left-most
subexpression to the right.  So `fold_left` is "folding in" elements of
the list from the left to the right, combining each new element using
the operator.

This function therefore works a little differently than `fold_right`. 
As a simple difference, notice that the list argument is the ultimate
argument rather than penultimate.  

More importantly, the name of the initial value argument has changed
from `init` to `acc`, because it's no longer going to just be the
initial value. The reason we call it `acc` is that we think of it as an
*accumulator*, which is the result of combining list elements so far. 
In `fold_right`, you will notice that the value passed as the `init`
argument is the same for every recursive invocation of `fold_right`:
it's passed all the way down to where it's needed, at the right-most
element of the list, then used there exactly once. But in `fold_left`,
you will notice that at each recursive invocation, the value passed as
the argument `acc` can be different. 

For example, if we want to walk across a list of integers and sum them,
we could store the current sum in the accumulator. We start with the
accumulator set to 0. As we come across each new element, we add the
element to the accumulator. When we reach the end, we return the value
stored in the accumulator.
```
let rec sum' acc = function
  | []   -> acc
  | h::t -> sum' (acc+x) xs

let sum = sum' 0
```
Our `fold_left` function abstracts from the particular operator used
in the `sum'`.

Using `fold_left`, we can rewrite `sum` and `concat` as follows:

```
let sum    = List.fold_left (+) 0  
let concat = List.fold_left (^) "" 
```
We have once more succeeded in applying the Abstraction Principle.

Here is the actual [code from the standard library][list-stdlib-src] that implements
the two fold functions:
```
let rec fold_left f accu l =
  match l with
    [] -> accu
  | a::l -> fold_left f (f accu a) l

let rec fold_right f l accu =
  match l with
    [] -> accu
  | a::l -> f a (fold_right f l accu)
```
The library calls the operator (or combining function) `f` instead of
`op`, and the initial value for `fold_right` it calls `accu` by analogy
to `fold_left`'s accumulator, even though it's not truly an accumulator
for `fold_right`.

[list-stdlib-src]: https://github.com/ocaml/ocaml/blob/trunk/stdlib/list.ml#L85
