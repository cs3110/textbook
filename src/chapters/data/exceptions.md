---
jupytext:
  cell_metadata_filter: -all
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.10.3
kernelspec:
  display_name: OCaml
  language: OCaml
  name: ocaml-jupyter
---

# Exceptions

{{ video_embed | replace("%%VID%%", "0zZNEJvcZqg")}}

OCaml has an exception mechanism similar to many other programming languages. A
new type of OCaml exception is defined with this syntax:
```ocaml
exception E of t
```
where `E` is a constructor name and `t` is a type. The `of t` is optional.
Notice how this is similar to defining a constructor of a variant type. For
example:
```{code-cell} ocaml
exception A
exception B
exception Code of int
exception Details of string
```

To create an exception value, use the same syntax you would for creating a
variant value. Here, for example, is an exception value whose constructor is
`Failure`, which carries a `string`:
```{code-cell} ocaml
Failure "something went wrong"
```
This constructor is [pre-defined in the standard library][stdlib-exn] and is one of the more common exceptions that
OCaml programmers use.

[stdlib-exn]: https://ocaml.org/manual/core.html#ss:predef-exn

To raise an exception value `e`, simply write
```ocaml
raise e
```

There is a convenient function `failwith : string -> 'a` in the standard library
that raises `Failure`. That is, `failwith s` is equivalent to
`raise (Failure s)`.

{{ video_embed | replace("%%VID%%", "XTdT1zdF2IY")}}

To catch an exception, use this syntax:
```ocaml
try e with
| p1 -> e1
| ...
| pn -> en
```
The expression `e` is what might raise an exception. If it does not, the entire
`try` expression evaluates to whatever `e` does. If `e` does raise an exception
value `v`, that value `v` is matched against the provided patterns, exactly
like `match` expression.

## Exceptions are Extensible Variants

All exception values have type `exn`, which is a variant defined in the
[core][core]. It's an unusual kind of variant, though, called an *extensible*
variant, which allows new constructors of the variant to be defined after the
variant type itself is defined. See the OCaml manual for more information about
[extensible variants][extvar] if you're interested.

[core]: https://ocaml.org/manual/core.html
[extvar]: https://ocaml.org/manual/extn.html

## Exception Semantics

Since they are just variants, the syntax and semantics of exceptions is already
covered by the syntax and semantics of variants&mdash;with one exception (pun
intended), which is the dynamic semantics of how exceptions are raised and
handled.

**Dynamic semantics.** As we originally said, every OCaml expression either

* evaluates to a value

* raises an exception

* or fails to terminate (i.e., an "infinite loop").

So far we've only presented the part of the dynamic semantics that handles the
first of those three cases. What happens when we add exceptions? Now, evaluation
of an expression either produces a value or produces an *exception packet*.
Packets are not normal OCaml values; the only pieces of the language that
recognizes them are `raise` and `try`. The exception value produced by (e.g.)
`Failure "oops"` is part of the exception packet produced by
`raise (Failure "oops")`, but the packet contains more than just the exception
value; there can also be a stack trace, for example.

For any expression `e` other than `try`, if evaluation of a subexpression of `e`
produces an exception packet `P`, then evaluation of `e` produces packet `P`.

But now we run into a problem for the first time: what order are subexpressions
evaluated in? Sometimes the answer to that question is provided by the semantics
we have already developed. For example, with let expressions, we know that the
binding expression must be evaluated before the body expression. So the
following code raises `A`:
```{code-cell} ocaml
:tags: ["raises-exception"]
let _ = raise A in raise B;;
```
And with functions, OCaml does not officially specify the evaluation order of a function
and its argument, but the current implementation evaluates the argument before the function.
So the following code also raises `A`, in addition to producing some compiler warnings
that the first expression will never actually be applied as a function to an
argument:
```{code-cell} ocaml
:tags: ["raises-exception", "hide-output"]
(raise B) (raise A)
```
It makes sense that both those pieces of code would raise the same exception,
given that we know `let x = e1 in e2` is syntactic sugar for `(fun x -> e2) e1`.

But what does the following code raise as an exception?
```{code-cell} ocaml
:tags: ["raises-exception", "hide-output"]
(raise A, raise B)
```
The answer is nuanced. The language specification does not stipulate what order
the components of pairs should be evaluated in. Nor did our semantics exactly
determine the order. (Though you would be forgiven if you thought it was left to
right.) So programmers actually cannot rely on that order. The current
implementation of OCaml, as it turns out, evaluates right to left. So the code
above actually raises `B`. If you really want to force the evaluation order, you
need to use let expressions:
```{code-cell} ocaml
:tags: ["raises-exception"]
let a = raise A in
let b = raise B in
(a, b)
```
That code is guaranteed to raise `A` rather than `B`.

One interesting corner case is what happens when a raise expression itself has
a subexpression that raises:
```{code-cell} ocaml
:tags: ["raises-exception"]
exception C of string;;
exception D of string;;
raise (C (raise (D "oops")))
```
That code ends up raising `D`, because the first thing that has to happen is to
evaluate `C (raise (D "oops"))` to a value. Doing that requires evaluating
`raise (D "oops")` to a value. Doing that causes a packet containing `D "oops"` to
be produced, and that packet then propagates and becomes the result of
evaluating `C (raise (D "oops"))`, hence the result of evaluating
`raise (C (raise (D "oops")))`.

Once evaluation of an expression produces an exception packet `P`, that packet
propagates until it reaches a `try` expression:
```ocaml
try e with
| p1 -> e1
| ...
| pn -> en
```
The exception value inside `P` is matched against the provided patterns using
the usual evaluation rules for pattern matching&mdash;with one exception (again,
pun intended). If none of the patterns matches, then instead of producing
`Match_failure` inside a new exception packet, the original exception packet `P`
continues propagating until the next `try` expression is reached.

## Pattern Matching

There is a pattern form for exceptions.  Here's an example
of its usage:
```{code-cell} ocaml
match List.hd [] with
  | [] -> "empty"
  | _ :: _ -> "non-empty"
  | exception (Failure s) -> s
```
Note that the code above is just a standard `match` expression, not a `try`
expression. It matches the value of `List.hd []` against the three provided
patterns. As we know, `List.hd []` will raise an exception containing the value
`Failure "hd"`. The *exception pattern* `exception (Failure s)` matches that
value. So the above code will evaluate to `"hd"`.

In general, exception patterns are a kind of syntactic sugar. Consider this
code:
```ocaml
match e with
  | p1 -> e1
  | ...
  | pn -> en
```
Some of the patterns `p1..pn` could be exception patterns of the form
`exception q`. Let `q1..qm` be that subsequence of patterns (without the
`exception` keyword), and let `r1..rn` be the subsequence of non-exception
patterns. Then we can rewrite the code as:
```ocaml
try
  match e with
    | r1 -> e1
    | ...
    | rn -> en
with
  | q1 -> e1
  | ...
  | qm -> em
```
Which is to say: try evaluating `e`. If it produces an exception packet, use the
exception patterns from the original match expression to handle that packet. If
it doesn't produce an exception packet but instead produces a non-exception
value, use the non-exception patterns from the original match expression to
match that value.

## Exceptions and OUnit

If it is part of a function's specification that it raises an exception, you
might want to write OUnit tests that check whether the function correctly does
so. Here's how to do that:
```ocaml
open OUnit2

let tests = "suite" >::: [
    "empty" >:: (fun _ -> assert_raises (Failure "hd") (fun () -> List.hd []));
  ]

let _ = run_test_tt_main tests
```
The expression `assert_raises exn (fun () -> e)` checks to see whether
expression `e` raises exception `exn`. If so, the OUnit test case succeeds,
otherwise it fails.

Note that the second argument of `assert_raises` is a *function* of type `unit
-> 'a`, sometimes called a "thunk". It may seem strange to write a function with
this type---the only possible input is `()`---but this is a common pattern in
functional languages to suspend or delay the evaluation of a program. In this
case, we want `assert_raises` to evaluate `List.hd []` when it is ready. If we
evaluated `List.hd []` immediately, `assert_raises` would not be able to check
if the right exception is raised. We'll learn more about thunks in a later
chapter.

```{warning}
A common error is to forget the `(fun () -> ...)` around `e`. If you make this
mistake, the program may still typecheck but the OUnit test case will fail:
without the extra anonymous function, the exception is raised before
`assert_raises` ever gets a chance to handle it.
```
