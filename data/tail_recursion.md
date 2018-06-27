# Tail Recursion

A function is *tail recursive* if it calls itself recursively but does not
perform any computation after the recursive call returns, and
immediately returns to its caller the value of its recursive call. 
Consider these two implementations, `sum` and `sum_tr` of summing a list,
where we've provided some type annotations to help you understand the code:

```
let rec sum (l : int list) : int =
  match l with
    [] -> 0
  | x :: xs -> x + (sum xs)

let rec sum_plus_acc (acc : int) (l : int list) : int =
  match l with
    [] -> acc
  | x :: xs -> sum_plus_acc (acc + x) xs

let sum_tr : int list -> int = 
  sum_plus_acc 0
```

Observe the following difference between the `sum` and `sum_tr` functions
above:  In the `sum` function, which is not tail recursive, after the
recursive call returned its value, we add `x` to it.  In the tail
recursive `sum_tr`, or rather in `sum_plus_acc`, after the recursive call
returns, we immediately return the value without further computation.

Why do we care about tail recursion? Actually, sometimes functional
programmers fixate a bit too much upon it.  If all you care about is
writing the first draft of a function, you probably don't need to worry
about it.

But if you're going to write functions on really long lists, tail
recursion becomes important for performance. Recall (from CS 1110) that
there is a call stack, which is a stack (the data structure with push
and pop operations) with one element for each function call that has
been started but has not yet completed. Each element stores things like
the value of local variables and what part of the function has not been
evaluated yet. When the evaluation of one function body calls another
function, a new element is pushed on the call stack and it is popped off
when the called function completes.

When a function makes a recursive call to itself and there is nothing
more for the caller to do after the callee returns (except return the
callee's result), this situation is called a tail call. Functional
languages like OCaml (and even imperative languages like C++) typically
include an hugely useful optimization: when a call is a tail call, the
caller's stack-frame is popped before the call&mdash;the callee's stack-frame
just replaces the caller's. This makes sense: the caller was just going
to return the callee's result anyway. With this optimization, recursion
can sometimes be as efficient as a while loop in imperative languages
(such loops don't make the call-stack bigger.) The "sometimes" is
exactly when calls are tail calls&mdash;something both you and the compiler
can (often) figure out. With tail-call optimization, the space
performance of a recursive algorithm can be reduced from \\(O(n)\\) to \\(O(1)\\),
that is, from one stack frame per call to a single stack frame for all
calls.

So when you have a choice between using a tail-recursive vs.
non-tail-recursive function, you are likely better off using the
tail-recursive function on really long lists to achieve space
efficiency. For that reason, the List module documents which functions
are tail recursive and which are not.

But that doesn't mean that a tail-recursive implementation is strictly
better. For example, the tail-recursive function might be harder to
read.  (Consider `sum_plus_acc`.)  Also, there are cases where
implementing a tail-recursive function entails having to do a pre- or
post-processing pass to reverse the list.  On small to medium sized
lists, the overhead of reversing the list (both in time and in
allocating memory for the reversed list) can make the tail-recursive
version less time efficient.  What constitutes "small" vs. "big" here?
That's hard to say, but maybe 10,000 is a good estimate, according
to the [standard library documentation of the `List` module][list].

[list]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/List.html
