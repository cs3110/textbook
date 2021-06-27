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

# Functions

Since OCaml is a functional language, there's a lot to cover about functions.
Let's get started.

## Function Definitions

{{ video_embed | replace("%%VID%%", "vCxIlagS7kA")}}

The following code
```ocaml
let x = 42
```
has an expression in it (`42`) but is not itself an expression. Rather, it is a
*definition*. Definitions bind values to names, in this case the value `42`
being bound to the name `x`. The OCaml manual describes
[definitions][definitions] (see the third major grouping titled "*definition*"
on that page), but that manual page is again primarily for reference not for
study. Definitions are not expressions, nor are expressions
definitions&mdash;they are distinct syntactic classes. But definitions can have
expressions nested inside them, and vice-versa.

[definitions]: http://caml.inria.fr/pub/docs/manual-ocaml/modules.html

For now, let's focus on one particular kind of definition, a *function
definition*. Non-recursive functions are defined like this:

```ocaml
let f x = ...
```

{{ video_embed | replace("%%VID%%", "_x82qitu2R8")}}

Recursive functions are defined like this:

```ocaml
let rec f x = ...
```

The difference is just the `rec` keyword. It's probably a bit surprising that
you explicitly have to add a keyword to make a function recursive, because most
languages assume by default that they are. OCaml doesn't make that assumption,
though. (Nor does the Scheme family of languages.)

One of the best known recursive functions is the factorial function. In OCaml,
it can be written as follows:

```ocaml
(** [fact n] is [n]!.
    Requires: [n >= 0]. *)
let rec fact n = if n = 0 then 1 else n * fact (n - 1)
```

We provided a specification comment above the function to document the
precondition (`Requires`) and postcondition (`is`) of the function.

Note that, as in many languages, OCaml integers are not the "mathematical"
integers but are limited to a fixed number of bits. The [manual][man] specifies
that (signed) integers are at least 31 bits, but they could be wider. As
architectures have grown, so has that size. In current implementations, OCaml
integers are 63 bits. So if you test on large enough inputs, you might begin to
see strange results. The problem is machine arithmetic, not OCaml. (For
interested readers: why 31 or 63 instead of 32 or 64? The OCaml garbage
collector needs to distinguish between integers and pointers. The runtime
representation of these therefore steals one bit to flag whether a word is an
integer or a pointer.)

[man]: http://caml.inria.fr/pub/docs/manual-ocaml/values.html#sec76


Here's another recursive function:
```ocaml
(** [pow x y] is [x] to the power of [y].
     Requires: [y >= 0]. *)
let rec pow x y = if y = 0 then 1 else x * pow x (y - 1)
```

Note how we didn't have to write any types in either of our functions: the OCaml
compiler infers them for us automatically. The compiler solves this *type
inference* problem algorithmically, but we could do it ourselves, too. It's like
a mystery that can be solved by our mental power of deduction:

* Since the `if` expression can return `1` in the `then` branch, we know by the
  typing rule for `if` that the entire `if` expression has type `int`.

* Since the `if` expression has type `int`, the function's return type must be
  `int`.

* Since `y` is compared to `0` with the equality operator, `y` must be an `int`.

* Since `x` is multiplied with another expression using the `*` operator, `x`
  must be an `int`.

If we wanted to write down the types for some reason, we could do that:
```ocaml
let rec pow (x : int) (y : int) : int = ...
```
The parentheses are mandatory when we write the *type annotations* for `x` and
`y`. We will generally leave out these annotations, because it's simpler to let
the compiler infer them. There are other times when you'll want to explicitly
write down types. One particularly useful time is when you get a type error from
the compiler that you don't understand. Explicitly annotating the types can help
with debugging such an error message.

**Syntax.**
The syntax for function definitions:
```ocaml
let rec f x1 x2 ... xn = e
```
The `f` is a metavariable indicating an identifier being used as a function
name. These identifiers must begin with a lowercase letter. The remaining
[rules for lowercase identifiers][lowercase] can be found in the manual. The
names `x1` through `xn` are metavariables indicating argument identifiers. These
follow the same rules as function identifiers. The keyword `rec` is required if
`f` is to be a recursive function; otherwise it may be omitted.

[lowercase]: http://caml.inria.fr/pub/docs/manual-ocaml/lex.html#lowercase-ident

Note that syntax for function definitions is actually simplified compared to
what OCaml really allows. We will learn more about some augmented syntax for
function definition in the next couple weeks. But for now, this simplified
version will help us focus.

Mutually recursive functions can be defined with the `and` keyword:
```ocaml
let rec f x1 ... xn = e1
and g y1 ... yn = e2
```

For example:
```ocaml
(** [even n] is whether [n] is even.
    Requires: [n >= 0]. *)
let rec even n =
  n = 0 || odd (n - 1)

(** [odd n] is whether [n] is odd.
    Requires: [n >= 0]. *)
and odd n =
  n <> 0 && even (n - 1);;
```

{{ video_embed | replace("%%VID%%", "W0rO84YXIXo")}}

The syntax for function types is:
```ocaml
t -> u
t1 -> t2 -> u
t1 -> ... -> tn -> u
```
The `t` and `u` are metavariables indicating types. Type `t -> u` is the type of
a function that takes an input of type `t` and returns an output of type `u`. We
can think of `t1 -> t2 -> u` as the type of a function that takes two inputs,
the first of type `t1` and the second of type `t2`, and returns an output of
type `u`. Likewise for a function that takes `n` arguments.

**Dynamic semantics.** There is no dynamic semantics of function definitions.
There is nothing to be evaluated. OCaml just records that the name `f` is bound
to a function with the given arguments `x1..xn` and the given body `e`. Only
later, when the function is applied, will there be some evaluation to do.

**Static semantics.** The static semantics of function definitions:

* For non-recursive functions: if by assuming that `x1 : t1` and `x2 : t2` and ...
  and `xn : tn`, we can conclude that `e : u`, then
  `f : t1 -> t2 -> ... -> tn -> u`.
* For recursive functions: if by assuming that `x1 : t1` and `x2 : t2` and ...
  and `xn : tn` and `f : t1 -> t2 -> ... -> tn -> u`, we can conclude that
  `e : u`, then `f : t1 -> t2 -> ... -> tn -> u`.

Note how the type checking rule for recursive functions assumes that the
function identifier `f` has a particular type, then checks to see whether the
body of the function is well-typed under that assumption. This is because `f` is
in scope inside the function body itself (just like the arguments are in scope).

## Anonymous Functions

{{ video_embed | replace("%%VID%%", "JwoIIrj0bcM")}}

We already know that we can have values that are not bound to names.
The integer `42`, for example, can be entered at the toplevel without
giving it a name:
```{code-cell}
42
```

Or we can bind it to a name:
```{code-cell}
let x = 42
```

Similarly, OCaml functions do not have to have names; they may be *anonymous*.
For example, here is an anonymous function that increments its input:
`fun x -> x + 1`. Here, `fun` is a keyword indicating an anonymous function, `x`
is the argument, and `->` separates the argument from the body.

We now have two ways we could write an increment function:
```ocaml
let inc x = x + 1
let inc = fun x -> x + 1
```

They are syntactically different but semantically equivalent. That is, even
though they involve different keywords and put some identifiers in different
places, they mean the same thing.

{{ video_embed | replace("%%VID%%", "zHHCD7MOjmw")}}

Anonymous functions are also called *lambda expressions*, a term that comes from
the *lambda calculus*, which is a mathematical model of computation in the same
sense that Turing machines are a model of computation. In the lambda calculus,
`fun x -> e` would be written $\lambda x . e$. The $\lambda$ denotes an
anonymous function.

It might seem a little mysterious right now why we would want functions that
have no names. Don't worry; we'll see good uses for them later in the course,
especially when we study so-called "higher-order programming". In particular, we
will often create anonymous functions and pass them as input to other functions.

**Syntax.**
```ocaml
fun x1 ... xn -> e
```

**Static semantics.**

* If by assuming that
  `x1 : t1` and `x2 : t2` and ... and `xn : tn`, we can conclude that `e : u`,
  then `fun x1 ... xn -> e : t1 -> t2 -> ... -> tn -> u`.

**Dynamic semantics.** An anonymous function is already a value. There is no
computation to be performed.

## Function Application

{{ video_embed | replace("%%VID%%", "fgCTDhXAYnQ")}}

Here we cover a somewhat simplified syntax of function application compared to
what OCaml actually allows.

**Syntax.**
```ocaml
e0 e1 e2 ... en
```
The first expression `e0` is the function, and it is applied to arguments `e1`
through `en`. Note that parentheses are not required around the arguments to
indicate function application, as they are in languages in the C family,
including Java.

**Static semantics.**

* If `e0 : t1 -> ... -> tn -> u` and `e1 : t1` and ... and `en : tn`
  then `e0 e1 ... en : u`.

**Dynamic semantics.**

To evaluate `e0 e1 ... en`:

1. Evaluate `e0` to a function. Also evaluate the argument expressions `e1`
   through `en` to values `v1` through `vn`.

   For `e0`, the result might be an anonymous function `fun x1 ... xn ->
   e` or a name `f`. In the latter case, we need to find the definition of `f`,
   which we can assume to be of the form `let rec f x1 ... xn =
   e`.  Either way, we now know the argument names `x1` through `xn` and the
   body `e`.

2. Substitute each value `vi` for the corresponding argument name `xi` in the
   body `e` of the function. That substitution results in a new expression `e'`.

3. Evaluate `e'` to a value `v`, which is the result of evaluating
   `e0 e1 ... en`.

If you compare these evaluation rules to the rules for `let` expressions, you
will notice they both involve substitution. This is not an accident. In fact,
anywhere `let x = e1 in e2` appears in a program, we could replace it with
`(fun x -> e2) e1`. They are syntactically different but semantically
equivalent. In essence, `let` expressions are just syntactic sugar for anonymous
function application.

## Pipeline

{{ video_embed | replace("%%VID%%", "arS9kEqCFEU")}}

There is a built-in infix operator in OCaml for function application called the
*pipeline* operator, written `|>`. Imagine that as depicting a triangle pointing
to the right. The metaphor is that values are sent through the pipeline from
left to right. For example, suppose we have the increment function `inc` from
above as well as a function `square` that squares its input. Here are two
equivalent ways of writing the same computation:
```ocaml
square (inc 5)
5 |> inc |> square
(* both yield 36 *)
```
The latter uses the pipeline operator to send `5` through the `inc` function,
then send the result of that through the `square` function. This is a nice,
idiomatic way of expressing the computation in OCaml. The former way is arguably
not as elegant: it involves writing extra parentheses and requires the reader's
eyes to jump around, rather than move linearly from left to right. The latter
way scales up nicely when the number of functions being applied grows, where as
the former way requires more and more parentheses:
```ocaml
5 |> inc |> square |> inc |> inc |> square
square (inc (inc (square (inc 5))))
(* both yield 1444 *)
```
It might feel weird at first, but try using the pipeline operator in your own
code the next time you find yourself writing a big chain of function
applications.

Since `e1 |> e2` is just another way of writing `e2 e1`, we don't need to state
the semantics for `|>`: it's just the same as function application. These two
programs are another example of expressions that are syntactically different but
semantically equivalent.

## Polymorphic Functions

{{ video_embed | replace("%%VID%%", "UWmxYBEKzN8")}}

The *identity* function is the function that simply returns its input:
```{code-cell}
let id x = x;;
```

The `'a` is a *type variable*: it stands for an unknown type, just like a
regular variable stands for an unknown value. Type variables always begin with a
single quote. Commonly used type variables include `'a`, `'b`, and `'c`, which
OCaml programmers typically pronounce in Greek: alpha, beta, and gamma.

We can apply the identity function to any type of value we like:

```text
# id 42;;
- : int = 42

# id true;;
- : bool = true

# id "bigred";;
- : string = "bigred"
```

Because you can apply `id` to many types of values, it is a *polymorphic*
function: it can be applied to many (*poly*) forms (*morph*).

## Labeled and Optional Arguments

The type and name of a function usually give you a pretty good idea of what the
arguments should be. However, for functions with many arguments (especially
arguments of the same type), it can be useful to label them. For example, you
might guess that the function `String.sub` returns a substring of the given
string (and you would be correct). You could type in `String.sub` to find its
type:

```{code-cell}
String.sub;;
```

But it's not clear from the type how to use it&mdash;you're forced to consult
the documentation.

OCaml supports labeled arguments to functions. You can declare this kind of
function using the following syntax:

```{code-cell}
let f ~name1:arg1 ~name2:arg2 = arg1 + arg2;;
```

This function can be called by passing the labeled arguments in either order:

```ocaml
f ~name2:3 ~name1:4
```

Labels for arguments are often the same as the variable names for them. OCaml
provides a shorthand for this case. The following are equivalent:

```ocaml
let f ~name1:name1 ~name2:name2 = name1+name2
let f ~name1 ~name2 = name1 + name2
```

Use of labeled arguments is largely a matter of taste. They convey extra
information, but they can also add clutter to types.

The syntax to write both a labeled argument and an explicit type annotation for
it is:

```
let f ~name1:(arg1 : int) ~name2:(arg2 : int) = arg1 + arg2
```

It is also possible to make some arguments optional. When called without an
optional argument, a default value will be provided. To declare such a function,
use the following syntax:

```{code-cell}
let f ?name:(arg1=8) arg2 = arg1 + arg2
```

You can then call a function with or without the argument:

```{code-cell}
f ~name:2 7
```

```{code-cell}
f 7
```

## Partial Application

{{ video_embed | replace("%%VID%%", "85xVK0wmDTw")}}

We could define an addition function as follows:

```{code-cell}
let add x y = x + y
```

Here's a rather similar function:

```{code-cell}
let addx x = fun y -> x + y
```

Function `addx` takes an integer `x` as input and returns a *function* of type
`int -> int` that will add `x` to whatever is passed to it.

The type of `addx` is `int -> int -> int`. The type of `add` is also
`int -> int -> int`. So from the perspective of their types, they are the same
function. But the form of `addx` suggests something interesting: we can apply it
to just a single argument.

```{code-cell}
let add5 = addx 5
```

```{code-cell}
add5 2
```

It turns out the same can be done with `add`:

```{code-cell}
let add5 = add 5
```

```{code-cell}
add5 2;;
```

What we just did is called *partial application*: we partially applied the
function `add` to one argument, even though you would normally think of it as a
multi-argument function. This works because the following three functions are
*syntactically different* but *semantically equivalent*. That is, they are
different ways of expressing the same computation:

```ocaml
let add x y = x + y
let add x = fun y -> x + y
let add = fun x -> (fun y -> x + y)
```

So `add` is really a function that takes an argument `x` and returns a function
`(fun y -> x + y)`. Which leads us to a deep truth...

## Function Associativity

Are you ready for the truth?  Here goes...

**Every OCaml function takes exactly one argument.**

Why? Consider `add`: although we can write it as `let add x y = x + y`, we know
that's semantically equivalent to `let add = fun x -> (fun y -> x + y)`. And in
general,

```ocaml
let f x1 x2 ... xn = e
```

is semantically equivalent to

```ocaml
let f =
  fun x1 ->
    (fun x2 ->
       (...
          (fun xn -> e)...))
```

So even though you think of `f` as a function that takes `n` arguments, in
reality it is a function that takes 1 argument and returns a function.

The type of such a function

```ocaml
t1 -> t2 -> t3 -> t4
```

really means the same as

```ocaml
t1 -> (t2 -> (t3 -> t4))
```

That is, function types are *right associative*: there are implicit parentheses
around function types, from right to left. The intuition here is that a function
takes a single argument and returns a new function that expects the remaining
arguments.

Function application, on the other hand, is *left associative*: there
are implicit parenthesis around function applications, from left to right.
So

```ocaml
e1 e2 e3 e4
```

really means the same as

```ocaml
((e1 e2) e3) e4
```

The intuition here is that the left-most expression grabs the next
expression to its right as its single argument.

## Operators as Functions

{{ video_embed | replace("%%VID%%", "OVKOx8UiwxM")}}

The addition operator `+` has type `int -> int -> int`. It is normally written
*infix*, e.g., `3 + 4`. By putting parentheses around it, we can make it a
*prefix* operator:

```{code-cell}
( + )
```

```{code-cell}
( + ) 3 4;;
```

```{code-cell}
let add3 = ( + ) 3
```

```{code-cell}
add3 2
```

The same technique works for any built-in operator.

Normally the spaces are unnecessary. We could write `(+)` or `( + )`, but it is
best to include them. Beware of multiplication, which *must* be written as
`( * )`, because `(*)` would be parsed as beginning a comment.

We can even define our own new infix operators, for example:
```ocaml
let ( ^^ ) x y = max x y
```
And now `2 ^^ 3` evaluates to `3`.

The rules for which punctuation can be used to create infix operators are not
necessarily intuitive. Nor is the relative precedence with which such operators
will be parsed. So be careful with this usage.
