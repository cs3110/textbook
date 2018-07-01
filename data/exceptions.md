# Exceptions

OCaml has an exception mechanism similar to many other programming languages.
A new type of OCaml exception is defined with this syntax:
```
exception E of t
```
where `E` is a constructor name and `t` is a type.  The `of t` is optional.
Notice how this is similar to defining a constructor of a variant type.

To create an exception value, use the same syntax you would for creating
a variant value.  Here, for example, is an exception value whose constructor
is `Failure`, which carries a `string`:
```
Failure "something went wrong"
```
This constructor is [pre-defined in the standard library][stdlib-exn] (scroll down
to "predefined exceptions") and is one of the more common exceptions that OCaml 
programmers use.

[stdlib-exn]: http://caml.inria.fr/pub/docs/manual-ocaml/core.html#sec512

To raise an exception value `e`, simply write
```
raise e
```

There is a convenient function `failwith : string -> 'a` in the standard library 
that raises `Failure`.  That is, `failwith s` is equivalent to `raise (Failure s)`.
(Often we use this function in the assignment release code we ship to you.)

## Exceptions are Extensible Variants

All exception values have type `exn`, which is a variant 
defined in the [Pervasives module][pervasives].  It's an unusual
kind of variant, though, called an *extensible* variant, which allows
new constructors of the variant to be defined after the variant type
itself is defined.  See the OCaml manual for more information about
[extensible variants][extvar] if you're interested.

[extvar]: http://caml.inria.fr/pub/docs/manual-ocaml/extn.html#sec251

## Exception Semantics

Since they are just variants, the syntax and semantics of exceptions
is already covered by the syntax and semantics of variants&mdash;with
one exception (pun intended), which is the dynamic semantics of
how exceptions are raised and handled.  

**Dynamic semantics.**
As we originally said, every OCaml expression either

* evaluates to a value

* raises an exception

* or fails to terminate (i.e., an "infinite loop").

So far we've only presented the part of the dynamic semantics that handles
the first of those three cases.  What happens when we add exceptions?
Now, evaluation of an expression either produces a value or produces an
*exception packet*.  Packets are not normal OCaml values; the only pieces
of the language that recognizes them are `raise` and `try`.  The exception value
produced by (e.g.) `Failure "oops"` is part of the exception packet produced
by `raise (Failure "oops")`, but the packet contains more than just the exception value;
there can also be a stack trace, for example.

For any expression `e` other than `try`, if evaluation of a subexpression of `e` 
produces an exception packet `P`, then evaluation of `e` produces packet `P`.

But now we run into a problem for the first time:  what order are subexpressions
evaluated in?  Sometimes the answer to that question is provided by the semantics
we have already developed.  For example, with let expressions, we know that the
binding expression must be evaluated before the body expression.  So the following
code raises `A`:
```
exception A 
exception B
let x = raise A in raise B
```
And with functions, the argument must be evaluated before the function.  So
the following code also raises `A`:
```
(raise B) (raise A)
```
It makes sense that both those pieces of code would raise the same exception, 
given that we know `let x = e1 in e2` is syntactic sugar for `(fun x -> e2) e1`.

But what does the following code raise as an exception?
```
(raise A, raise B)
```
The answer is nuanced.  The language specification does not stipulate what order the
components of pairs should be evaluated in.  Nor did our semantics exactly determine
the order.  (Though you would be forgiven if you thought it was left to right.)
So programmers actually cannot rely on that order.  The current implementation of OCaml,
as it turns out, evaluates right to left.  So the code above actually raises `B`.
If you really want to force the evaluation order, you need to use let expressions:
```
let a = raise A in
let b = raise B in
(a,b)
```
That code will raise `A`.	

One interesting corner case is what happens when a raise expression itself has
a subexpression that raises:
```
exception C of string
exception D of string
raise (C (raise D "oops"))
```
That code ends up raising `D`, because the first thing that has to happen is
to evaluate `C (raise D "oops")` to a value.  Doing that requires evaluating
`raise D "oops"` to a value.  Doing that causes a packet containing `D "oops"`
to be produced, and that packet then propagates and becomes the result of
evaluating `C (raise D "oops")`, hence the result of evaluating 
`raise (C (raise D "oops"))`.

Once evaluation of an expression produces an exception packet `P`, that packet
propagates until it reaches a `try` expression:
```
try e with
| p1 -> e1
| ...
| pn -> en
```
The exception value inside `P` is matched against the provided patterns using the 
usual evaluation rules for pattern matching&mdash;with one exception
(again, pun intended).  If none of the patterns matches, then instead of producing
`Match_failure` inside a new exception packet, the original exception packet `P`
continues propagating until the next `try` expression is reached.

## Pattern Matching
There is a pattern form for exceptions.  Here's an example
of its usage:
```
match List.hd [] with
  | [] -> "empty" 
  | h::t -> "nonempty" 
  | exception (Failure s) -> s
```
Note that the code is above is just a standard `match` expression, not a `try` expression.
It matches the value of `List.hd []` against the three provided patterns.  As we know,
`List.hd []` will raise an exception containing the value `Failure "hd"`. 
The *exception pattern* `exception (Failure s)` matches that value.  So the above
code will evaluate to `"hd"`.

In general, exception patterns are a kind of syntactic sugar.  Consider this code:
```
match e with 
  | p1 -> e1
  | ...
  | pn -> en
```
Some of the patterns `p1..pn` could be exception patterns of the form `exception q`.
Let `q1..qn` be that subsequence of patterns (without the `exception` keyword), 
and let `r1..rm` be the subsequence of non-exception patterns.  Then we can rewrite the 
code as:
```
match 
  try e with
    | q1 -> e1
    | ...
    | qn -> en
with
  | r1 -> e1
  | ...
  | rm -> em
```
Which is to say:  try evaluating `e`.  If it produces an exception packet, use the
exception patterns from the original match expression to handle that packet.
If it doesn't produce an exception packet but instead produces a normal value,
use the non-exception patterns from the original match expression to match that value.

## Exceptions and OUnit

If it is part of a function's specification that it raises an exception, you
might want to write OUnit tests that check whether the function correctly does so.
Here's how to do that:
```
open OUnit2

let tests = "suite" >:::
  [
    "empty"    >:: (fun _ -> assert_raises (Failure "hd") (fun () -> List.hd []));
    "nonempty" >:: (fun _ -> assert_equal  1              (List.hd [1]));
  ]

let _ = run_test_tt_main tests
```
The expression `assert_raises exc (fun () -> e)` checks to see whether expression `e`
raises exception `exc`.  If so, the OUnit test case succeeds, otherwise it fails.

**Note:** a common error is to forget the `(fun () -> ...)` around `e`.  If you do,
the OUnit test case will fail, and you will likely be confused as to why.  The reason
is that, without the extra anonymous function, the exception is raised before 
`assert_raises` ever gets a chance to handle it.
