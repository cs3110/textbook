# Fold Right

The map functional gives us a way to individually transform each element
of a list.  The filter functional gives us a way to individually decide
whether to keep or throw away each element of a list.  But both of those
are really just looking at a single element at a time.  What if we wanted
to somehow combine all the elements of a list?

Once more, let's write two functions:
```
let rec sum = function
  | [] -> 0
  | h::t -> h + sum t
  
let concat = function
  | [] -> ""
  | h::t -> h ^ concat t
```

As before, the functions share a great deal of common structure. 
The differences are:

* the case for the empty list returns a different initial value, `0` vs `""`

* the case of a non-empty list uses a different operator to combine
  the head element with the result of the recursive call, `+` vs `^`.

So can we apply the Abstraction Principle again?  Sure!  This time we
need to factor out two arguments:  one for each of those two differences.

Here's how we could rewrite the functions to factor out just the initial value
(we won't factor out an operator just yet):
```
let rec sum' init = function
  | [] -> init
  | h::t -> h + sum' init t

let sum = sum' 0

let rec concat' init = function
  | [] -> init
  | h::t -> h ^ concat' init t
  
let concat = concat' ""
```
Now the only real difference left between `sum'` and `concat'` is the operator.
That can also become an argument to a unified function we call `combine`:
```
let rec combine op init = function
  | [] -> init
  | h::t -> op h (combine op init t)
  
let sum    = combine (+) 0
let concat = combine (^) ""
```
Once more, the Abstraction Principle has led us to an amazingly simple and
succinct expression of the computation.  One way of thinking of the first two
arguments `op` and `init` to `combine` is that they say what to do for the two possible
constructors of the implicit third argument:  if the third argument is constructed
with `[]`, then return `init`.  If it's constructed with `::`, then return `op`
applied to the values found inside the data that `::` carries.  Of course, one
of the data items that `::` carries is itself another list, so we have to
recursively call `combine` on that list to get a value out that's suitable
to pass to `op`.

The `combine` function is the basis for an OCaml library function named
`List.fold_right`. Here is its implementation:
```
let rec fold_right op lst init = match lst with
  | [] -> init
  | h::t -> op h (fold_right op t init)
  
let sum    lst = fold_right (+) lst 0
let concat lst = fold_right (^) lst ""
``` 
This is nearly the same function as `combine`, except that it takes its
list argument as the penultimate rather than ultimate argument. 

The intuition for why this function is called `fold_right` is that the
way it works is to "fold in" elements of the list from the right to the left,
combining each new element using the operator.  For example,
`fold_right (+) [a;b;c] 0` results in evaluation of the expression
`a+(b+(c+0))`.  The parentheses associate from the right-most subexpression
to the left.  

One way to think of `fold_right` would be that the `[]` value in the
list gets replaced by `init`, and each `::` constructor gets replaced by
`op`.  For example, `[a;b;c]` is just syntactic sugar for
`a::(b::(c::[]))`. So if we replace `[]` with `0` and `::` with `(+)`,
we get `a+(b+(c+0))`.