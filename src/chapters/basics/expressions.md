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

# Expressions

The primary piece of OCaml syntax is the *expression*. Just like programs in
imperative languages are primarily built out of *commands*, programs in
functional languages are primarily built out of expressions. Examples of
expressions include `2+2` and `increment 21`.

The OCaml manual has a complete definition of [all the expressions in the
language][exprs]. Though that page starts with a rather cryptic overview, if you
scroll down, you'll come to some English explanations. Don't worry about
studying that page now; just know that it's available for reference.

[exprs]:  https://ocaml.org/manual/expr.html

The primary task of computation in a functional language is to *evaluate* an
expression to a *value*. A value is an expression for which there is no
computation remaining to be performed. So, all values are expressions, but not
all expressions are values. Examples of values include `2`, `true`, and
`"yay!"`.

The OCaml manual also has a definition of [all the values][values], though
again, that page is mostly useful for reference rather than study.

[values]: https://ocaml.org/manual/values.html

Sometimes an expression might fail to evaluate to a value. There are two reasons
that might happen:

1. Evaluation of the expression raises an exception.
2. Evaluation of the expression never terminates (e.g., it enters an "infinite
   loop").

## Primitive Types and Values

The *primitive* types are the built-in and most basic types: integers,
floating-point numbers, characters, strings, and booleans. They will be
recognizable as similar to primitive types from other programming languages.

**Type `int`: Integers.** OCaml integers are written as usual: `1`, `2`, etc.
The usual operators are available: `+`, `-`, `*`, `/`, and `mod`. The latter
two are integer division and modulus:

```{code-cell} ocaml
65 / 60
```

```{code-cell} ocaml
65 mod 60
```

```{code-cell} ocaml
:tags: ["raises-exception"]
65 / 0
```

OCaml integers range from $-2^{62}$ to $2^{62}-1$ on modern platforms. They are
implemented with 64-bit machine *words*, which is the size of a register on
64-bit processor. But one of those bits is "stolen" by the OCaml implementation,
leading to a 63-bit representation. That bit is used at run time to distinguish
integers from pointers. For applications that need true 64-bit integers, there
is an [`Int64` module][int64] in the standard library. And for applications that
need arbitrary-precision integers, there is a separate [`Zarith`][zarith]
library. But for most purposes, the built-in `int` type suffices and offers the
best performance.

[int64]: https://ocaml.org/api/Int64.html
[zarith]: https://github.com/ocaml/Zarith

**Type `float`: Floating-point numbers.** OCaml floats are [IEEE 754
double-precision floating-point numbers][binary64]. Syntactically, they must
always contain a dot&mdash;for example, `3.14` or `3.0` or even `3.`.  The last
is a `float`; if you write it as `3`, it is instead an `int`:

```{code-cell} ocaml
3.
```

```{code-cell} ocaml
3
```

OCaml deliberately does not support operator overloading, Arithmetic operations
on floats are written with a dot after them. For example, floating-point
multiplication is written `*.` not `*`:

```{code-cell} ocaml
3.14 *. 2.
```

```{code-cell} ocaml
:tags: ["raises-exception"]
3.14 * 2.
```

OCaml will not automatically convert between `int` and `float`. If you want to
convert, there are two built-in functions for that purpose: `int_of_float` and
`float_of_int`.

```{code-cell} ocaml
3.14 *. (float_of_int 2)
```

As in any language, the floating-point representation is approximate. That can
lead to rounding errors:

```{code-cell} ocaml
0.1 +. 0.2
```

The same behavior can be observed in Python and Java, too.  If you haven't
encountered this phenomenon before, here's a [basic guide to floating-point
representation][fp-guide] that you might enjoy reading.

[binary64]: https://en.wikipedia.org/wiki/Double-precision_floating-point_format
[fp-guide]: https://floating-point-gui.de/basic/

**Type `bool`: Booleans.** The boolean values are written `true` and `false`.
The usual short-circuit conjunction `&&` and disjunction `||` operators are
available.

**Type `char`: Characters.** Characters are written with single quotes, such as
`'a'`, `'b'`, and `'c'`. They are represented as bytes &mdash;that is, 8-bit
integers&mdash; in the ISO 8859-1 "Latin-1" encoding. The first half of the
characters in that range are the standard ASCII characters. You can convert
characters to and from integers with `char_of_int` and `int_of_char`.

**Type `string`: Strings.** Strings are sequences of characters. They are
written with double quotes, such as `"abc"`.  The string concatenation operator
is `^`:

```{code-cell} ocaml
"abc" ^ "def"
```

Object-oriented languages often provide an overridable method for converting
objects to strings, such as `toString()` in Java or `__str__()` in Python. But
most OCaml values are not objects, so another means is required to convert to
strings. For three of the primitive types, there are built-in functions:
`string_of_int`, `string_of_float`, `string_of_bool`.  Strangely,
there is no `string_of_char`, but the library function `String.make` can
be used to accomplish the same goal.

```{code-cell} ocaml
string_of_int 42
```

```{code-cell} ocaml
String.make 1 'z'
```

Likewise, for the same three primitive types, there are built-in functions to
convert from a string if possible: `int_of_string`, `float_of_string`, and
`bool_of_string`.

```{code-cell} ocaml
int_of_string "123"
```

```{code-cell} ocaml
:tags: ["raises-exception"]
int_of_string "not an int"
```

There is no `char_of_string`, but the individual characters of a string can be
accessed by a 0-based index. The indexing operator is written with a dot and
square brackets:

```{code-cell} ocaml
"abc".[0]
```

```{code-cell} ocaml
"abc".[1]
```

```{code-cell} ocaml
:tags: ["raises-exception"]
"abc".[3]
```

## More Operators

We've covered most of the built-in operators above, but there are a few more
that you can see in the [OCaml manual][ops].

There are two equality operators in OCaml, `=` and `==`, with corresponding
inequality operators `<>` and `!=`. Operators `=` and `<>` examine *structural*
equality whereas `==` and `!=` examine *physical* equality. Until we've studied
the imperative features of OCaml, the difference between them will be tricky to
explain. See the [documentation][stdlib] of `Stdlib.(==)` if you're curious now.

```{important}
Start training yourself now to use `=` and not to use `==`. This will be
difficult if you're coming from a language like Java where `==` is the usual
equality operator.
```

[ops]: https://ocaml.org/manual/expr.html#ss%3Aexpr-operators
[stdlib]: https://ocaml.org/api/Stdlib.html

## Assertions

The expression `assert e` evaluates `e`. If the result is `true`, nothing more
happens, and the entire expression evaluates to a special value called *unit*.
The unit value is written `()` and its type is `unit`. But if the result is
`false`, an exception is raised.

## If Expressions

{{ video_embed | replace("%%VID%%", "XJ6QPtlPD7s")}}

The expression `if e1 then e2 else e3` evaluates to `e2` if `e1` evaluates to
`true`, and to `e3` otherwise. We call `e1` the *guard* of the `if` expression.

```{code-cell}
if 3 + 5 > 2 then "yay!" else "boo!"
```

Unlike `if-then-else` *statements* that you may have used in imperative
languages, `if-then-else` *expressions* in OCaml are just like any other
expression; they can be put anywhere an expression can go. That makes them
similar to the ternary operator `? :` that you might have used in other
languages.

```{code-cell}
4 + (if 'a' = 'b' then 1 else 2)
```

`If` expressions can be nested in a pleasant way:

```ocaml
if e1 then e2
else if e3 then e4
else if e5 then e6
...
else en
```

You should regard the final `else` as mandatory, regardless of whether you are
writing a single `if` expression or a highly nested `if` expression. If you
omit it you'll likely get an error message that, for now, is inscrutable:

```{code-cell}
:tags: ["raises-exception"]
if 2 > 3 then 5
```

+++

**Syntax.** The syntax of an `if` expression:

```ocaml
if e1 then e2 else e3
```

The letter `e` is used here to represent any other OCaml expression; it's an
example of a *syntactic variable* aka *metavariable*, which is not actually a
variable in the OCaml language itself, but instead a name for a certain
syntactic construct. The numbers after the letter `e` are being used to
distinguish the three different occurrences of it.

**Dynamic semantics.** The dynamic semantics of an `if` expression:

* If `e1` evaluates to `true`, and if `e2` evaluates to a value `v`, then
  `if e1 then e2 else e3` evaluates to `v`

* If `e1` evaluates to `false`, and if `e3` evaluates to a value `v`, then
  `if e1 then e2 else e3` evaluates to `v`.

We call these *evaluation rules*: they define how to evaluate expressions. Note
how it takes two rules to describe the evaluation of an `if` expression, one for
when the guard is true, and one for when the guard is false. The letter `v` is
used here to represent any OCaml value; it's another example of a metavariable.
Later we will develop a more mathematical way of expressing dynamic semantics,
but for now we'll stick with this more informal style of explanation.

**Static semantics.** The static semantics of an `if` expression:

* If `e1` has type `bool` and `e2` has type `t` and `e3` has type `t` then
  `if e1 then e2 else e3` has type `t`

We call this a *typing rule*: it describes how to type check an expression. Note
how it only takes one rule to describe the type checking of an `if` expression.
At compile time, when type checking is done, it makes no difference whether the
guard is true or false; in fact, there's no way for the compiler to know what
value the guard will have at run time. The letter `t` here is used to represent
any OCaml type; the OCaml manual also has definition of [all types][types]
(which curiously does not name the base types of the language like `int` and
`bool`).

[types]: https://ocaml.org/manual/types.html

We're going to be writing "has type" a lot, so let's introduce a more compact
notation for it. Whenever we would write "`e` has type `t`", let's instead write
`e : t`. The colon is pronounced "has type". This usage of colon is consistent
with how the toplevel responds after it evaluates an expression that you enter:

```{code-cell}
let x = 42
```
In the above example, variable `x` has type `int`, which is what the colon
indicates.

## Let Expressions

{{ video_embed | replace("%%VID%%", "ug3L97FXC6A")}}

In our use of the word `let` thus far, we've been making definitions in the
toplevel and in `.ml` files. For example,
```{code-cell}
let x = 42;;
```
defines `x` to be 42, after which we can use `x` in future definitions at the
toplevel. We'll call this use of `let` a *let definition*.

There's another use of `let` which is as an expression:
```{code-cell}
let x = 42 in x + 1
```
Here we're *binding* a value to the name `x` then using that binding inside
another expression, `x+1`. We'll call this use of `let` a *let expression*.
Since it's an expression it evaluates to a value. That's different than
definitions, which themselves do not evaluate to any value. You can see that if
you try putting a let definition in place of where an expression is expected:
```{code-cell}
:tags: ["raises-exception"]
(let x = 42) + 1
```
Syntactically, a `let` definition is not permitted on the left-hand side of the
`+` operator, because a value is needed there, and definitions do not evaluate
to values. On the other hand, a `let` expression would work fine:
```{code-cell}
(let x = 42 in x) + 1
```

Another way to understand let definitions at the toplevel is that they are like
let expression where we just haven't provided the body expression yet.
Implicitly, that body expression is whatever else we type in the future. For
example,
```ocaml
# let a = "big";;
# let b = "red";;
# let c = a ^ b;;
# ...
```
is understood by OCaml in the same way as
```ocaml
let a = "big" in
let b = "red" in
let c = a ^ b in
...
```
That latter series of `let` bindings is idiomatically how several variables
can be bound inside a given block of code.

**Syntax.**

```ocaml
let x = e1 in e2
```

As usual, `x` is an identifier. These identifiers must begin with lower-case,
not upper, and idiomatically are written with `snake_case` not `camelCase`. We
call `e1` the *binding expression*, because it's what's being bound to `x`; and
we call `e2` the *body expression*, because that's the body of code in which the
binding will be in scope.

**Dynamic semantics.**

To evaluate `let x = e1 in e2`:

* Evaluate `e1` to a value `v1`.

* Substitute `v1` for `x` in `e2`, yielding a new expression `e2'`.

* Evaluate `e2'` to a value `v2`.

* The result of evaluating the let expression is `v2`.

Here's an example:
```text
    let x = 1 + 4 in x * 3
-->   (evaluate e1 to a value v1)
    let x = 5 in x * 3
-->   (substitute v1 for x in e2, yielding e2')
    5 * 3
-->   (evaluate e2' to v2)
    15
      (result of evaluation is v2)
```

**Static semantics.**

* If `e1 : t1` and if under the assumption that `x : t1` it holds that
  `e2 : t2`, then `(let x = e1 in e2) : t2`.

We use the parentheses above just for clarity. As usual, the compiler's type
inferencer determines what the type of the variable is, or the programmer could
explicitly annotate it with this syntax:
```ocaml
let x : t = e1 in e2
```

## Scope

{{ video_embed | replace("%%VID%%", "_TpTC6eo34M")}}

`Let` bindings are in effect only in the block of code in which they occur. This
is exactly what you're used to from nearly any modern programming language. For
example:
```ocaml
let x = 42 in
  (* y is not meaningful here *)
  x + (let y = "3110" in
         (* y is meaningful here *)
         int_of_string y)
```
The *scope* of a variable is where its name is meaningful. Variable `y` is in
scope only inside of the `let` expression that binds it above.

It's possible to have overlapping bindings of the same name. For example:
```ocaml
let x = 5 in
  ((let x = 6 in x) + x)
```
But this is darn confusing, and for that reason, it is strongly discouraged
style&mdash;much like ambiguous pronouns are discouraged in natural language.
Nonetheless, let's consider what that code means.

To what value does that code evaluate? The answer comes down to how `x` is
replaced by a value each time it occurs. Here are a few possibilities for such
*substitution*:
```ocaml
(* possibility 1 *)
let x = 5 in
  ((let x = 6 in 6) + 5)

(* possibility 2 *)
let x = 5 in
  ((let x = 6 in 5) + 5)

(* possibility 3 *)
let x = 5 in
  ((let x = 6 in 6) + 6)
```
The first one is what nearly any reasonable language would do. And most likely
it's what you would guess But, **why?**

The answer is something we'll call the *Principle of Name Irrelevance*: the name
of a variable shouldn't intrinsically matter. You're used to this from math. For
example, the following two functions are the same:

\begin{align*}
f(x) &= x^2 \\
f(y) &= y^2
\end{align*}

It doesn't intrinsically matter whether we call the argument to the function
$x$ or $y$; either way, it's still the squaring function.
Therefore, in programs, these two functions should be identical:
```ocaml
let f x = x * x
let f y = y * y
```
This principle is more commonly known as *alpha equivalence*: the two functions
are equivalent up to renaming of variables, which is also called *alpha
conversion* for historical reasons that are unimportant here.

According to the Principle of Name Irrelevance, these two expressions should be
identical:
```ocaml
let x = 6 in x
let y = 6 in y
```
Therefore, the following two expressions, which have the above expressions
embedded in them, should also be identical:
```ocaml
let x = 5 in (let x = 6 in x) + x
let x = 5 in (let y = 6 in y) + x
```
But for those to be identical, we **must** choose the first of the three
possibilities above. It is the only one that makes the name of the variable be
irrelevant.

There is a term commonly used for this phenomenon: a new binding of a variable
*shadows* any old binding of the variable name. Metaphorically, it's as if the
new binding temporarily casts a shadow over the old binding. But eventually the
old binding could reappear as the shadow recedes.

{{ video_embed | replace("%%VID%%", "4SqMkUwakEA")}}

Shadowing is not mutable assignment. For example, both of the following
expressions evaluate to 11:
```ocaml
let x = 5 in ((let x = 6 in x) + x)
let x = 5 in (x + (let x = 6 in x))
```
Likewise, the following utop transcript is not mutable assignment, though at
first it could seem like it is:
```ocaml
# let x = 42;;
val x : int = 42
# let x = 22;;
val x : int = 22
```

Recall that every `let` definition in the toplevel is effectively a nested `let`
expression. So the above is effectively the following:
```ocaml
let x = 42 in
  let x = 22 in
    ... (* whatever else is typed in the toplevel *)
```
The right way to think about this is that the second `let` binds an entirely new
variable that just happens to have the same name as the first `let`.

Here is another utop transcript that is well worth studying:
```ocaml
# let x = 42;;
val x : int = 42
# let f y = x + y;;
val f : int -> int = <fun>
# f 0;;
: int = 42
# let x = 22;;
val x : int = 22
# f 0;;
- : int = 42  (* x did not mutate! *)
```

To summarize, each let definition binds an entirely new variable. If that new
variable happens to have the same name as an old variable, the new variable
temporarily shadows the old one. But the old variable is still around, and its
value is immutable: it never, ever changes. So even though `let` expressions
might superficially look like assignment statements from imperative languages,
they are actually quite different.

## Type Annotations

OCaml automatically infers the type of every expression, with no need for the
programmer to write it manually. Nonetheless, it can sometimes be useful to
manually specify the desired type of an expression. A *type annotation* does
that:

```{code-cell} ocaml
(5 : int)
```

An incorrect annotation will produce a compile-time error:

```{code-cell} ocaml
:tags: ["raises-exception"]
(5 : float)
```

And that example shows why you might use manual type annotations during
debugging.  Perhaps you had forgotten that `5` cannot be treated as a `float`,
and you tried to write:

```ocaml
5 +. 1.1
```

You might try manually specifying that `5` was supposed to be a `float`:

```{code-cell} ocaml
:tags: ["raises-exception"]
(5 : float) +. 1.1
```

It's clear that the type annotation has failed. Although that might seem silly
for this tiny program, you might find this technique to be effective as programs
get larger.

```{important}
Type annotations are **not** *type casts*, such as might be found in C or Java.
They do not indicate a conversion from one type to another. Rather they indicate
a check that the expression really does have the given type.
```

**Syntax.** The syntax of a type annotation:

```ocaml
(e : t)
```

Note that the parentheses are required.

**Dynamic semantics.** There is no run-time meaning for a type annotation.
It goes away during compilation, because it indicates a compile-time check.
There is no run-time conversion.
So, if `(e : t)` compiled successfully, then at run-time it is simply `e`,
and it evaluates as `e` would.

**Static semantics.**  If `e` has type `t` then `(e : t)` has type `t`.
