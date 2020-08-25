# Anonymous Functions

We already know that we can have values that are not bound to names.
The integer `42`, for example, can be entered at the toplevel without
giving it a name:
```
# 42;;
- : int = 42
```
Or we can bind it to a name:
```
# let x = 42;;
val x : int = 42
```

Similarly, OCaml functions do not have to have names; they may be
*anonymous*. For example, here is an anonymous function that increments
its input: `fun x -> x+1`. Here, `fun` is a keyword indicating an
anonymous function, `x` is the argument, and `->` separates the argument
from the body.

We now have two ways we could write an increment function:
```
let inc x = x + 1
let inc = fun x -> x+1
```
They are syntactically different but semantically equivalent.  That is,
even though they involve different keywords and put some identifiers
in different places, they mean the same thing.  

Anonymous functions are also called *lambda expressions*, a term that
comes out of the *lambda calculus*, which is a mathematical model
of computation in the same sense that Turing machines are a model
of computation.  In the lambda calculus, `fun x -> e` would
be written $$\lambda x . e$$.  The $$\lambda$$ denotes
an anonymous function.

It might seem a little mysterious right now why we would want functions
that have no names.  Don't worry; we'll see good uses for them later 
in the course.  In particular, we will often create anonymous functions
and pass them as input to other functions.

**Syntax.** 
```
fun x1 ... xn -> e
```

**Static semantics.**

* If by assuming that 
  `x1:t1` and `x2:t2` and ... and `xn:tn`, we can conclude that `e:u`, 
  then `fun x1 ... xn -> e : t1 -> t2 -> ... -> tn -> u`.

**Dynamic semantics.**

An anonymous function is already a value.  There is no computation
to be performed.
