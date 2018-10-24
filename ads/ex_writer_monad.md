# Example: The Writer Monad

When trying to diagnose faults in a system, it's often the case
that a *log* of what functions have been called, as well as what their
inputs and outputs were, would be helpful.

Imagine that we had two functions we wanted to debug,
both of type `int -> int`.  For example:
```
let f x = x + 1
let g x = x - 1
```
(Ok, those are really simple functions.  But imagine they compute
something far more complicated, like encryptions or decryptions
of integers.)

One way to keep a log of function calls would be to augment
each function to return a pair:  the integer value the function
would normally return, as well as a string containing a log
message.  For example:
```
let f_log x = x + 1, "Called f on " ^ string_of_int x ^ "; "
let g_log x = x - 1, "Called g on " ^ string_of_int x ^ "; "
```

But that changes the return type of both functions, which makes
it hard to *compose* the functions.  Previously, we could
have written code such as
```
let h x = g (f x)
```
and that would have worked just fine.  But trying to do the same
thing with the loggable versions of the functions produces
a type-checking error:
```
# let h x = g_log (f_log x);;
Error: This expression has type int * string
       but an expression was expected of type int
```
That's because `f_log x` is a pair, but `g_log` expects simply
an integer as input.

We could code up an upgraded version of `g_log` that is able to 
take a pair as input:
```
let g_log_upgraded (x, s) =
  x - 1, s ^ "Called g on " ^ string_of_int x ^ "; "
  
let h x = g_log_upgraded (f_log x)
```

That works fine, but we also will need to code up a similar
upgraded version of `f_log` if we ever want to call them
in reverse order, e.g., 
```
# let h x = f_log (g_log x);;
Error: This expression has type int * string
       but an expression was expected of type int
```
So we have to write:
```
let f_log_upgraded (x, s) =
  x + 1, s ^ "Called f on " ^ string_of_int x ^ "; "
  
let h x = f_log_upgraded (g_log x)
```

And at this point we've duplicated far too much code.  The
implementations of `f` and `g` are duplicated inside
both `f_log` and `g_log`, as well as inside both upgraded
versions of the functions.  And both the upgrades duplicate
the code for concatenating log messages together.  The
more functions we want to make loggable, the worse
this duplication is going to become!


