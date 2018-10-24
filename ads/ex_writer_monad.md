# Example: The Writer Monad

When trying to diagnose faults in a system, it's often the case
that a *log* of what functions have been called, as well as what their
inputs and outputs were, would be helpful.

Imagine that we had two functions we wanted to debug,
both of type `int -> int`.  For example:
```
let inc x = x + 1
let dec x = x - 1
```
(Ok, those are really simple functions; we probably don't need any help
debugging them.  But imagine they compute something far more
complicated, like encryptions or decryptions of integers.)

One way to keep a log of function calls would be to augment
each function to return a pair:  the integer value the function
would normally return, as well as a string containing a log
message.  For example:
```
let inc_log x = x + 1, Printf.sprintf "Called inc on %i; " x
let dec_log x = x - 1, Printf.sprintf "Called dec on %i; " x
```

But that changes the return type of both functions, which makes
it hard to *compose* the functions.  Previously, we could
have written code such as
```
let id x = dec (inc x)
```
or even better
```
let id x = x |> inc |> dec
```
or even better still, using the *composition operator* `>>`,
```
let (>>) f g x = x |> f |> g
let id = inc >> dec
```
and that would have worked just fine.  But trying to do the same
thing with the loggable versions of the functions produces
a type-checking error:
```
let id = inc_log >> dec_log (* error *)
```
That's because `inc_log x` would be a pair, but `dec_log` expects simply
an integer as input.

We could code up an upgraded version of `dec_log` that is able to 
take a pair as input:
```
let dec_log_upgraded (x, s) =
  x - 1, Printf.sprintf "Called dec on %i; " x
  
let id x = x |> inc_log |> dec_log_upgraded
```

That works fine, but we also will need to code up a similar
upgraded version of `f_log` if we ever want to call them
in reverse order, e.g., `let id = dec_log >> inc_log`.
So we have to write:
```
let inc_log_upgraded (x, s) =
  x + 1, Printf.sprintf "Called inc on %i; " x
  
let id = dec_log >> inc_log_upgraded
```

And at this point we've duplicated far too much code.  The
implementations of `inc` and `dec` are duplicated inside
both `inc_log` and `dec_log`, as well as inside both upgraded
versions of the functions.  And both the upgrades duplicate
the code for concatenating log messages together.  The
more functions we want to make loggable, the worse
this duplication is going to become!

So, let's start over, and factor out a couple helper functions.
The first helper calls a function and produces a log message:
```
let log (name : string) (f : int -> int) : int -> int * string = 
  fun x -> (f x, Printf.sprintf "Called %s on %i; " name x)
```
The second helper produces a logging function
of type `'a * string -> 'b * string` out of a non-loggable function

````
let loggable (name : string) (f : int -> int) : int * string -> int * string =
  fun (x, s1) ->
    let (y, s2) = log name f x in
    (y, s1 ^ s2)
```
Using those helpers, we can implement the logging versions of our
functions without any duplication of code involving pairs or
pattern matching or string concatenation:
```
let inc' : int * string -> int * string = 
  loggable "inc" inc

let dec' : int * string -> int * string = 
  loggable "dec" dec

let id' : int * string -> int * string = 
  inc' >> dec'
```

Here's an example usage:
```
# id' (5, "");;
- : int * string = (5, "Called inc on 5; Called dec on 6; ")
```
Notice how it's inconvenient to call our loggable functions on
integers, since we have to pair the integer with a string.
So let's write one more function to help with that by pairing
an integer with the *empty* log:
```
let e x = (x, "")
```
And now we can write `id' (e 5)` instead of `id' (5, "")`.

## Where's the Monad?

The work we just did was to take functions on integers and tranform them
into functions on integers paired with log messages.  We can think of
these "upgraded" functions as computations that log. They produce
metaphorical boxes, and those boxes contain function outputs as well as
log messages.

There were two fundamental ideas in the code we just wrote, which
correspond to the monad operations of `return` and `bind`.

The first was upgrading a value from `int` to `int * string` by pairing
it with the empty string.  That's what `e` does.  We could rename it
`return`:
```
let return (x : int) : int * string =
  (x, "")
```
This function has the *trivial effect* of putting a value into the 
metaphorical box along with the empty log message.

The second idea was factoring out code to handle pattern matching
against pairs and string concatenation. Here's that idea expressed as
its own function:
```
let (>>=) (m : int * string) (f : int -> int * string) : int * string =
  let (x, s1) = m in
  let (y, s2) = f x in
  (y, s1 ^ s2)
```

Using `return` and `>>=`, we can re-implement `loggable`, such that no pairs
or pattern matching are ever used in its body:
```
let loggable (name : string) (f : int -> int) : int * string -> int * string =
  fun m -> 
    m >>= fun x ->
    log name f x >>= fun y ->
    return y
```

## The Writer Monad

The monad we just discovered is usually called the *writer monad* (as in,
"additionally writing to a log or string").
Here's an implementation of the monad signature for it:

```
module Writer : Monad = struct
  type 'a t = 'a * string

  let return x = (x, "")

  let (>>=) m f =
    let (x, s1) = m in
    let (y, s2) = f x in
    (y, s1 ^ s2)
end 
```

As we saw with the maybe monad, these are the same implementations of
`return` and `>>=` as we invented above, but without the type
annotations to force them to work only on integers. Indeed, we never
needed those annotations; they just helped make the code above a little
clearer.

It's debatable which version of `loggable` is easier to read.  Certainly
you need to be comfortable with the monadic style of programming
to appreciate the version of it that uses `>>=`.  But if you were developing
a much larger code base (i.e., with more functions involving paired
strings than just `loggable`), using the `>>=` operator is likely to
be a good choice:  it means the code you write can concentrate on the
`'a` in the type `'a Writer.t` instead of on the strings.  In other
words, the writer monad will take care of the strings for you, as long
as you use `return` and `>>=`.
