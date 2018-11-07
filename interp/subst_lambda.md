# Capture-Avoiding Substitution

The definition of substitution for SimPL was a little tricky
but not too complicated. It turns out, though, that for 
other languages, the definition gets more complicated.

Let's consider this tiny language:
```
e ::= x | e1 e2 | fun x -> e
v ::= fun x -> e
```
It is known as the *lambda calculus*.  There are only three kinds of
expressions in it:  variables, function application, and anonymous
functions.  The only values are anonymous functions.  The language isn't
even typed.  Yet, one of its most remarkable properties is that it
*computationally universal:*  it can express any computable function. 
(To learn more about that, take CS 6810 or read about the *Church-Turing
Hypothesis*.)

Defining a big-step evaluation relation for the lambda calculus is
straightforward.  In fact, there's only one rule required:
```
e1 e2 ==> v
  if e1 ==> fun x -> e
  and e2 ==> v2
  and e{v2/x} ==> v
```
That rule is named *call by value*, because it requires arguments
to be reduced to a value before a function can be applied.  If that
seems obvious, it's because you're used to it from OCaml.  Other
languages use other rules.  For example, Haskell uses a variant
on *call by name*, which is this rule:
```
e1 e2 ==> v
  if e1 ==> fun x -> e
  and e{e2/x} ==> v
```
With call by name, `e2` does not have to be reduced to a value;
that can lead to greater efficiency if the value of `e2` is never
needed.  

Now we need to define the substitution operation for the lambda
calculus.  We'd like a definition that works for either call by
name or call by value.  Inspired by our definition for SimPL, here's
the beginning of a definition:
```
x{e/x} = e
y{e/x} = y
(e1 e2){e/x} = e1{e/x} e2{e/x}
```
The first two lines are exactly how we defined variable substitution
in SimPL.  The next line resembles how we defined binary operator
substitution; we just recurse into the subexpressions.

What about substitution in a function?  In SimPL, we stopped
substituting when we reached a bound variable of the same name;
otherwise, we proceeded.  In the lambda calculus, that
idea would be stated as follows:
```
(fun x -> e'){e/x} = fun x -> e'
(fun y -> e'){e/x} = fun y -> e'{e/x}
```
Perhaps surprisingly, that definition turns out to be incorrect.
Here's why:  it violates the [Principle of Name Irrelevance](../basics/scope.html).
Suppose we were attempting this substitution:
```
(fun z -> x){z/x}
```
The result would be:
```
  fun z -> x{z/x}
= fun z -> z
```
And, suddenly, a function that was *not* the identity function
becomes the identity function.  Whereas, if we had attempted
this substitution:
```
(fun y -> x){z/x}
```
The result would be:
```
  fun y -> x{z/x}
= fun y -> z
```
Which is not the identity function.  So our definition of
substitution inside anonymous functions is incorrect, because
it *captures* variables.  A variable name being substituted
inside an anonymous function can accidentally be "captured"
by the function's argument name.

Note that we never had this problem in SimPL, in part because SimPL
was typed.  The function `fun y -> z` if applied to any argument
would just return `z`, which is an unbound variable.  But the
lambda calculus is untyped, so we can't rely on typing to rule
out this possibility here.  Moreover, with rules such as call
by name, we might well end up needing to evaluate such expressions.

So the question becomes, how do we define substitution so that
it gets the right answer, without capturing variables?  
The answer is called *capture-avoiding substitution*,
and a correct definition of it eluded mathematicians for
centuries.

A correct definition is as follows:
```
(fun x -> e'){e/x} = fun x -> e'
(fun y -> e'){e/x} = fun y -> e'{e/x}  if y is not in FV(e)
```
where `FV(e)` means the "free variables" of `e`, i.e., the variables
that are not bound in it, and is defined as follows:
```
FV(x) = {x}
FV(e1 e2) = FV(e1) + FV(e2)
FV(fun x -> e) = FV(e) - {x}
```
and `+` means set union, and `-` means set difference.

That definition prevents the substitution `(fun z -> x){z/x}` from
occurring, because `z` is in `FV(z)`.

Unfortunately, because of the side-condition `y is not in FV(e)`,
the substitution operation is now *partial*:  there are times,
like the example we just gave, where it cannot be applied.

That problem can be solved by changing the names of variables:
if we detect that a partiality has been encountered, we can
change the name of the function's argument.  For example, when
`(fun z -> x){z/x}` is encountered, the function's argument
could be replaced with a new name `w` that doesn't occur anywhere else,
yielding `(fun w -> x){z/x}`.  (And if `z` occurred anywhere in the body,
it would be replaced by `w`, too.)  This is *replacement*, not substitution:
absolutely anywhere we see `z`, we replace it with `w`.  Then the 
substitution may proceed and correctly produce `fun w -> z`.

The tricky part of that is how to pick a new name that doesn't occur anywhere else,
that is, how to pick a *fresh* name.  Here are three strategies:

1. Pick a new variable name, check whether is fresh or not,
  and if not, try again, until that succeeds.  For example, if trying to replace 
  `z`, you might first try `z'`, then `z''`, etc.
  
1. Augment the evaluation relation to maintain a stream (i.e., infinite list)
   of unused variable names.  Each time you need a new one, take the head of the
   stream.  But you have to be careful to use the tail of the stream anytime after
   that.  To guarantee that they are unused, reserve some variable names for use
   by the interpreter alone, and make them illegal as variable names chosen
   by the programmer.  For example, you might decide that programmer variable
   names may never start with the character `$`, then have a stream 
   `<$x1, $x2, $x3, ...>` of fresh names.
   
1. Use an imperative counter to simulate the stream from the previous strategy.
   For example, the following function is guaranteed to return a fresh
   variable name each time it is called:
   ```
   let gensym =
     let counter = ref 0 in
     fun () -> incr counter; "$x" ^ string_of_int !counter
   ```
   The name `gensym` is traditional for this kind of function.  It comes from LISP,
   and shows up throughout compiler implementations.
   It means <u>gen</u>erate a fresh <u>sym</u>bol.  
   
## An Implementation

There is a complete implementation of an interpreter for the
lambda calculus, including capture-avoiding substitution, that you
can [download here](lambda-subst.zip).  It uses the `gensym` strategy from
above the generate fresh names, as you can see in [this file](lambda-subst/main.ml).
There is a definition named `strategy` that you can use to switch between call-by-value
and call-by-name.