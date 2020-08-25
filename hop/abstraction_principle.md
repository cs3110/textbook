# The Abstraction Principle

Above, we have exploited the structural similarity between `quad` and
`fourth` to save work. Admittedly, in this toy example it might not seem
like much work. But imagine that `twice` were actually some much more
complicated function. Then if someone comes up with a more efficient
version of it, every function written in terms of it (like `quad` and
`fourth`) could benefit from that improvement in efficiency, without
needing to be recoded.

Part of being an excellent programmer is recognizing such similarities
and *abstracting* them by creating functions (or other units of code)
that implement them.  This is known as the **Abstraction Principle**,
which says to avoid requiring something to be stated more than once;
instead, *factor out* the recurring pattern.

Higher-order functions enable such refactoring, because they allow
us to factor out functions and parameterize functions on other functions.

Besides `twice`, here are some more relatively simple examples. 

**Apply.** We can write
a function that applies its first input to its second input:
```
let apply f x = f x
```
Of course, writing `apply f` is a lot more work than just writing `f`.

**Pipeline.** The pipeline operator, which we've previously seen,
is a higher-order function:
```
let pipeline x f = f x
let (|>) = pipeline
let x = 5 |> double  (* 10 *)
```

**Compose.** We can write a function that composes two other functions:
```
let compose f g x = f (g x)
```
This function would let us create a new function that can be applied
many times, such as the following:
```
let square_then_double = compose double square
let x = square_then_double 1  (* 2 *)
let y = square_then_double 2  (* 8 *)
```

**Both.** We can write a function that applies two functions
to the same argument and returns a pair of the result:
```
let both f g x = (f x, g x)
let ds = both double square
let p = ds 3  (* (6,9) *)
```

**Cond.** We can write a function that conditionally chooses
which of two functions to apply based on a predicate:
```
let cond p f g x =
  if p x then f x else g x
```

Having seen some simpler examples, let's move on to some more
complicated but really useful examples of higher-order functions.
