# Higher-order Functions

Functions are values just like any other value in OCaml. What does that
mean exactly? This means that we can pass functions around as arguments
to other functions, that we can store functions in data structures, that
we can return functions as a result from other functions.

Let us look at why it is useful to have higher-order functions. The
first reason is that it allows you to write general, reusable code.
Consider these functions `double` and `square` on integers:

```
let double x = 2 * x
let square x = x * x
```

Let's use these functions to write other functions that
quadruple and raise a number to the fourth power:
```
let quad x   = double (double x)
let fourth x = square (square x)
```

There is an obvious similarity between these two functions: what they do
is apply a given function twice to a value. By passing in the function
to another function `twice` as an argument, we can abstract this
functionality:

```
let twice f x = f (f x)
(* twice : ('a -> 'a) -> 'a -> 'a *)
```

Using `twice`, we can implement `quad` and `fourth` in a uniform way:

```
let quad   x = twice double x
let fourth x = twice square x
```

*Higher-order functions* either take other functions as input or return
other functions as output (or both).  The function `twice` is higher-order: 
its input `f` is a function.  And&mdash;recalling that all OCaml functions
really take only a single argument&mdash;its output is technically 
`fun x -> f (f x)`, so `twice` returns a function hence is also higher-order
in that way.  Higher-order functions are also known as *functionals*, and
programming with them could be called *functional programming*&mdash;indicating
what the heart of programming in languages like OCaml is all about.
