# Partial application

We could define an addition function as follows:

	let add x y = x + y

Here's a rather similar function:

	let addx x = fun y -> x + y

Function `addx` takes an integer `x` as input, and returns a *function*
of type `int -> int` that will add `x` to whatever is passed to it.

The type of `addx` is `int -> int -> int`.  The type of `add` is
also `int -> int -> int`.  So from the perspective of their types,
they are the same function.  But the form of `addx` suggests 
something interesting:  we can apply it to just a single argument.

```
# let add5 = addx 5;;
add5 : int -> int = <fun>

# add5 2;;
- : int = 7
```

It turns out the same can be done with `add`:

```
# let add5 = add 5;;
add5 : int -> int = <fun>

# add5 2;;
- : int = 7
```

What you just did is called *partial application*:
we partially applied the function `add` to one argument, even though
you normally would think of it as a multi-argument function.  Why does
this work? It's because the following three functions are
*syntactically different* but *semantically equivalent*.  That is,
they are different ways of expressing the same computation:

```
let add x y = x+y
let add x = fun y -> x+y
let add = fun x -> (fun y -> x+y)
```

So `add` is really a function that takes an argument `x` and returns
a function `(fun y -> x+y)`.  Which leads us to a deep truth...

## Function associativity

Are you ready for the truth?  Here goes...

**Every OCaml function takes exactly one argument.**

Why?  Consider `add`:  although we can write it as
`let add x y = x + y`, we know that's semantically
equivalent to `let add = fun x -> (fun y -> x+y)`.
And in general,

```
let f x1 x2 ... xn = e
```

is semantically equivalent to

```
let f =
  fun x1 ->
    (fun x2 ->
       (...
          (fun xn -> e)...))
```

So even though you think of `f` as a function that takes `n` arguments,
in reality it is a function that takes 1 argument, and returns
a function.

And the type of such a function

	t1 -> t2 -> t3 -> t4

really means the same as

	t1 -> (t2 -> (t3 -> t4))

That is, function types are *right associative*: there are implicit
parentheses around function types, from right to left. The intuition
here is that a function takes a single argument and returns a new
function that expects the remaining arguments.

Function application, on the other hand, is *left associative*: there
are implicit parenthesis around function applications, from left to right.
So

	e1 e2 e3 e4

really means the same as

	((e1 e2) e3) e4

The intuition here is that the left-most expression grabs the next
expression to its right as its single argument.

