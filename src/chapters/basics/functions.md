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

```{important}
Methods and functions are not the same idea. A method is a component of an
object, and it implicitly has a receiver that is usually accessed with a keyword
like `this` or `self`. OCaml functions are not methods: they are not components
of objects, and they do not have a receiver.

Some might say that all methods are functions, but not all functions are
methods. Some might even quibble with that, making a distinction between
functions and procedures. The latter would be functions that do not return any
meaningful value, such as a `void` return type in Java or `None` return value in
Python.

So if you're coming from an object-oriented background, be careful about the
terminology. **Everything here is strictly a function, not a method.**
```

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
definitions&mdash;they are distinct syntactic classes.

[definitions]: https://ocaml.org/manual/modules.html

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

```{code-cell} ocaml
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

[man]: https://ocaml.org/manual/values.html#sss:values:integer


Here's another recursive function:
```{code-cell} ocaml
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

[lowercase]: https://ocaml.org/manual/lex.html#lowercase-ident

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
```{code-cell} ocaml
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
```{code-cell} ocaml
42
```

Or we can bind it to a name:
```{code-cell} ocaml
let x = 42
```

Similarly, OCaml functions do not have to have names; they may be *anonymous*.
For example, here is an anonymous function that increments its input:
`fun x -> x + 1`. Here, `fun` is a keyword indicating an anonymous function, `x`
is the argument, and `->` separates the argument from the body.

We now have two ways we could write an increment function:
```{code-cell} ocaml
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
above as well as a function `square` that squares its input:

```{code-cell} ocaml
let square x = x * x
```

Here are two equivalent ways of squaring `6`:

```{code-cell} ocaml
square (inc 5);;
5 |> inc |> square;;
```

The latter uses the pipeline operator to send `5` through the `inc` function,
then send the result of that through the `square` function. This is a nice,
idiomatic way of expressing the computation in OCaml. The former way is arguably
not as elegant: it involves writing extra parentheses and requires the reader's
eyes to jump around, rather than move linearly from left to right. The latter
way scales up nicely when the number of functions being applied grows, where as
the former way requires more and more parentheses:

```{code-cell} ocaml
5 |> inc |> square |> inc |> inc |> square;;
square (inc (inc (square (inc 5))));;
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

```{code-cell} ocaml
let id x = x
```

Or equivalently as an anonymous function:
```{code-cell} ocaml
let id = fun x -> x
```

The `'a` is a *type variable*: it stands for an unknown type, just like a
regular variable stands for an unknown value. Type variables always begin with a
single quote. Commonly used type variables include `'a`, `'b`, and `'c`, which
OCaml programmers typically pronounce in Greek: alpha, beta, and gamma.

We can apply the identity function to any type of value we like:

```{code-cell} ocaml
id 42;;
id true;;
id "bigred";;
```

Because you can apply `id` to many types of values, it is a *polymorphic*
function: it can be applied to many (*poly*) forms (*morph*).

With manual type annotations, it's possible to give a more restrictive type
to a polymorphic function than the type the compiler automatically infers.
For example:

```{code-cell} ocaml
let id_int (x : int) : int = x
```

That's the same function as `id`, except for the two manual type annotations.
Because of those, we cannot apply `id_int` to a bool like we did `id`:

```{code-cell} ocaml
:tags: ["raises-exception"]
id_int true
```

Another way of writing `id_int` would be in terms of `id`:

```{code-cell} ocaml
let id_int' : int -> int = id
```

In effect we took a value of type `'a -> 'a`, and we bound it to a name whose
type was manually specified as being `int -> int`. You might ask, why does that
work? They aren't the same types, after all.

One way to think about this is in terms of **behavior.** The type of `id_int`
specifies one aspect of its behavior: given an `int` as input, it promises to
produce an `int` as output. It turns out that `id` also makes the same promise:
given an `int` as input, it too will return an `int` as output. Now `id` also
makes many more promises, such as: given a `bool` as input, it will return a
`bool` as output. So by binding `id` to a more restrictive type `int -> int`, we
have thrown away all those additional promises as irrelevant. Sure, that's
information lost, but at least no promises will be broken.  It's always
going to be safe to use a function of type `'a -> 'a` when what we needed
was a function of type `int -> int`.

The converse is not true. If we needed a function of type `'a -> 'a` but tried
to use a function of type `int -> int`, we'd be in trouble as soon as someone
passed an input of another type, such as `bool`. To prevent that trouble, OCaml
does something potentially surprising with the following code:

```{code-cell} ocaml
let id' : 'a -> 'a = fun x -> x + 1
```

Function `id'` is actually the increment function, not the identity function. So
passing it a `bool` or `string` or some complicated data structure is not safe;
the only data `+` can safely manipulate are integers. OCaml therefore
*instantiates* the type variable `'a` to `int`, thus preventing us from
applying `id'` to non-integers:

```{code-cell} ocaml
:tags: ["raises-exception"]
id' true
```

That leads us to another, more mechanical, way to think about all of this in
terms of **application**. By that we mean the very same notion of how a function
is applied to arguments: when evaluating the application `id 5`, the argument
`x` is *instantiated* with value `5`. Likewise, the `'a` in the type of `id` is
being instantiated with type `int` at that application. So if we write

```{code-cell} ocaml
let id_int' : int -> int = id
```

we are in fact instantiating the `'a` in the type of `id` with the type `int`.
And just as there is no way to "unapply" a function&mdash;for example, given `5`
we can't compute backwards to `id 5`&mdash;we can't unapply that type
instantiation and change `int` back to `'a`.

To make that precise, suppose we have a `let` definition [or expression]:

```ocaml
let x = e [in e']
```

and that OCaml infers `x` has a type `t` that includes some type variables `'a`,
`'b`, etc. Then we are permitted to instantiate those type variables. We can do
that by applying the function to arguments that reveal what the type
instantiations should be (as in `id 5`) or by a type annotation (as in
`id_int'`), among other ways. But we have to be consistent with the
instantiation. For example, we cannot take a function of type `'a -> 'b -> 'a`
and instantiate it at type `int -> 'b -> string`, because the instantiation of
`'a` is not the same type in each of the two places it occurred:

```{code-cell} ocaml
:tags: ["raises-exception"]
let first x y = x;;
let first_int : int -> 'b -> int = first;;
let bad_first : int -> 'b -> string = first;;
```

## Labeled and Optional Arguments

The type and name of a function usually give you a pretty good idea of what the
arguments should be. However, for functions with many arguments (especially
arguments of the same type), it can be useful to label them. For example, you
might guess that the function `String.sub` returns a substring of the given
string (and you would be correct). You could type in `String.sub` to find its
type:

```{code-cell} ocaml
String.sub;;
```

But it's not clear from the type how to use it&mdash;you're forced to consult
the documentation.

OCaml supports labeled arguments to functions. You can declare this kind of
function using the following syntax:

```{code-cell} ocaml
let f ~name1:arg1 ~name2:arg2 = arg1 + arg2;;
```

This function can be called by passing the labeled arguments in either order:

```ocaml
f ~name2:3 ~name1:4
```

Labels for arguments are often the same as the variable names for them. OCaml
provides a shorthand for this case. The following are equivalent:

```ocaml
let f ~name1:name1 ~name2:name2 = name1 + name2
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

```{code-cell} ocaml
let f ?name:(arg1=8) arg2 = arg1 + arg2
```

You can then call a function with or without the argument:

```{code-cell} ocaml
f ~name:2 7
```

```{code-cell} ocaml
f 7
```

## Partial Application

{{ video_embed | replace("%%VID%%", "85xVK0wmDTw")}}

We could define an addition function as follows:

```{code-cell} ocaml
let add x y = x + y
```

Here's a rather similar function:

```{code-cell} ocaml
let addx x = fun y -> x + y
```

Function `addx` takes an integer `x` as input and returns a *function* of type
`int -> int` that will add `x` to whatever is passed to it.

The type of `addx` is `int -> int -> int`. The type of `add` is also
`int -> int -> int`. So from the perspective of their types, they are the same
function. But the form of `addx` suggests something interesting: we can apply it
to just a single argument.

```{code-cell} ocaml
let add5 = addx 5
```

```{code-cell} ocaml
add5 2
```

It turns out the same can be done with `add`:

```{code-cell} ocaml
let add5 = add 5
```

```{code-cell} ocaml
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

Are you ready for the truth?  Take a deep breath.  Here goes...

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

```{code-cell} ocaml
( + )
```

```{code-cell} ocaml
( + ) 3 4;;
```

```{code-cell} ocaml
let add3 = ( + ) 3
```

```{code-cell} ocaml
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

## Tail Recursion

Consider the following seemingly uninteresting function, which counts from 1 to
`n`:

```{code-cell} ocaml
(** [count n] is [n], computed by adding 1 to itself [n] times.  That is,
    this function counts up from 1 to [n]. *)
let rec count n =
  if n = 0 then 0 else 1 + count (n - 1)
```

Counting to 10 is no problem:
```{code-cell} ocaml
count 10
```

Counting to 100,000 is no problem either:
```{code-cell} ocaml
count 100_000
```

But try counting to 1,000,000 and you'll get the following error:
```
Stack overflow during evaluation (looping recursion?).
```

What's going on here?

**The Call Stack.** The issue is that the *call stack* has a limited size. You
probably learned in one of your introductory programming classes that most
languages implement function calls with a stack. That stack contains one element
for each function call that has been started but has not yet completed. Each
element stores information like the values of local variables and which
instruction in the function is currently being executed. When the evaluation of
one function body calls another function, a new element is pushed on the call
stack, and it is popped off when the called function completes.

The size of the stack is usually limited by the operating system. So if the
stack runs out of space, it becomes impossible to make another function call.
Normally this doesn't happen, because there's no reason to make that many
successive function calls before returning. In cases where it does happen,
there's good reason for the operating system to make that program stop: it might
be in the process of eating up *all* the memory available on the entire
computer, thus harming other programs running on the same computer. The `count`
function isn't likely to do that, but this function would:

```{code-cell} ocaml
let rec count_forever n = 1 + count_forever n
```

So the operating system for safety's sake limits the call stack size. That means
eventually `count` will run out of stack space on a large enough input. Notice
how that choice is really independent of the programming language. So this same
issue can and does occur in languages other than OCaml, including Python and
Java. You're just less likely to have seen it manifest there, because you
probably never wrote quite as many recursive functions in those languages.

**Tail Recursion.** There is a solution to this issue that was described in a
[1977 paper about LISP by Guy Steele][lisp-tailcall]. The solution, *tail-call
optimization*, requires some cooperation between the programmer and the
compiler. The programmer does a little rewriting of the function, which the
compiler then notices and applies an optimization. Let's see how it works.

[lisp-tailcall]: https://dl.acm.org/doi/pdf/10.1145/800179.810196

Suppose that a recursive function `f` calls itself then returns the result of
that recursive call. Our `count` function does *not* do that:
```{code-cell} ocaml
let rec count n =
  if n = 0 then 0 else 1 + count (n - 1)
```
Rather, after the recursive call `count (n - 1)`, there is computation
remaining: the computer still needs to add `1` to the result of that call.

But we as programmers could rewrite the `count` function so that it does *not*
need to do any additional computation after the recursive call. The trick is
to create a helper function with an extra parameter:
```{code-cell} ocaml
let rec count_aux n acc =
  if n = 0 then acc else count_aux (n - 1) (acc + 1)

let count_tr n = count_aux n 0
```
Function `count_aux` is almost the same as our original `count`, but it adds an
extra parameter named `acc`, which is idiomatic and stands for "accumulator".
The idea is that the value we want to return from the function is slowly, with
each recursive call, being accumulated in it. The "remaining computation"
&mdash;the addition of 1&mdash; now happens *before* the recursive call not
*after*.  When the base case of the recursion finally arrives, the function
now returns `acc`, where the answer has been accumulated.

But the original base case of 0 still needs to exist in the code somewhere.
And it does, as the original value of `acc` that is passed to `count_aux`.
Now `count_tr` (we'll get to why the name is "tr" in just a minute) works
as a replacement for our original `count`.

At this point we've completed the programmer's responsibility, but it's probably
not clear why we went through this effort. After all `count_aux` will still call
itself recursively too many times as `count` did, and eventually overflow the
stack.

That's where the compiler's responsibility kicks in. A good compiler (and the
OCaml compiler is good this way) can notice when a recursive call is in *tail
position*, which is a technical way of saying "there's no more computation to be
done after it returns". The recursive call to `count_aux` is in tail position;
the recursive call to `count` is not. Here they are again so you can compare
them:
```{code-cell} ocaml
:tags: ["remove-output"]
let rec count n =
  if n = 0 then 0 else 1 + count (n - 1)

let rec count_aux n acc =
  if n = 0 then acc else count_aux (n - 1) (acc + 1)
```
Here's why tail position matters: **A recursive call in tail position does not
need a new stack frame. It can just reuse the existing stack frame.** That's
because there's nothing left of use in the existing stack frame! There's no
computation left to be done, so none of the local variables, or next instruction
to execute, etc. matter any more. None of that memory ever needs to be read
again, because that call is effectively already finished. So instead of wasting
space by allocating another stack frame, the compiler "recycles" the space used
by the previous frame.

This is the *tail-call optimization*. It can even be applied in cases beyond
recursive functions if the calling function's stack frame is suitably compatible
with the callee. And, it's a big deal. The tail-call optimization reduces the
stack space requirements from linear to constant. Whereas `count` needed $O(n)$
stack frames, `count_aux` needs only $O(1)$, because the same frame gets reused
over and over again for each recursive call. And that means `count_tr` actually
can count to 1,000,000:

```{code-cell} ocaml
count_tr 1_000_000
```

Finally, why did we name this function `count_tr`? The "tr" stands for *tail
recursive*. A tail recursive function is a recursive function whose recursive
calls are all in tail position. In other words, it's a function that (unless
there are other pathologies) will not exhaust the stack.

**The Importance of Tail Recursion.** Sometimes beginning functional programmers
fixate a bit too much upon it. If all you care about is writing the first draft
of a function, you probably don't need to worry about tail recursion. It's
pretty easy to make it tail recursive later if you need to, just by adding an
accumulator argument. Or maybe you should rethink how you have designed the
function. Take `count`, for example: it's kind of dumb. But later we'll see
examples that aren't dumb, such as iterating over lists with thousands of
elements.

It is important that the compiler support the optimization. Otherwise, the
transformation you do to the code as a programmer makes no difference. Indeed,
most compilers do support it, at least as an option. Java is a notable
exception.

**The Recipe for Tail Recursion.** In a nutshell, here's how we made a function
be tail recursive:

1. Change the function into a helper function. Add an extra argument: the
   accumulator, often named `acc`.
1. Write a new "main" version of the function that calls the helper. It passes
   the original base case's return value as the initial value of the
   accumulator.
1. Change the helper function to return the accumulator in the base case.
1. Change the helper function's recursive case. It now needs to do the extra
   work on the accumulator argument, before the recursive call. This is the only
   step that requires much ingenuity.

**An Example: Factorial.** Let's transform this factorial function to be
tail recursive:

```{code-cell} ocaml
(* [fact n] is [n] factorial *)
let rec fact n =
  if n = 0 then 1 else n * fact (n - 1)
```

First, we change its name and add an accumulator argument:
```ocaml
let rec fact_aux n acc = ...
```

Second, we write a new "main" function that calls the helper with the original
base case as the accumulator:
```ocaml
let rec fact_tr n = fact_aux n 1
```

Third, we change the helper function to return the accumulator in the base case:
```ocaml
if n = 0 then acc ...
```

Finally, we change the recursive case:
```ocaml
else fact_aux (n - 1) (n * acc)
```

Putting it all together, we have:
```{code-cell} ocaml
let rec fact_aux n acc =
  if n = 0 then acc else fact_aux (n - 1) (n * acc)

let fact_tr n = fact_aux n 1
```

It was a nice exercise, but maybe not worthwhile.  Even before we exhaust the
stack space, the computation suffers from integer overflow:
```{code-cell} ocaml
fact 50
```
To solve that problem, we turn to OCaml's big integer library,
[Zarith][zarith]. Here we use a few OCaml features that are beyond anything
we've seen so far, but hopefully nothing terribly surprising. (If you want to
follow along with this code, first install Zarith in OPAM with
`opam install zarith`.)

[zarith]: https://antoinemine.github.io/Zarith/doc/latest/Z.html

```{code-cell} ocaml
:tags: ["remove-cell"]
#use "topfind";;
```

```{code-cell} ocaml
:tags: ["remove-output"]
#require "zarith.top";;
```

```{code-cell} ocaml
let rec zfact_aux n acc =
  if Z.equal n Z.zero then acc else zfact_aux (Z.pred n) (Z.mul acc n);;

let zfact_tr n = zfact_aux n Z.one;;

zfact_tr (Z.of_int 50)
```

If you want you can use that code to compute `zfact_tr 1_000_000` without stack
or integer overflow, though it will take several minutes.

The chapter on modules will explain the OCaml features we used above in detail,
but for now:

- `#require` loads the library, which provides a module named `Z`. Recall that
  $\mathbb{Z}$ is the symbol used in mathematics to denote the integers.

- `Z.n` means the name `n` defined inside of `Z`.

- The type `Z.t` is the library's name for the type of big integers.

- We use library values `Z.equal` for equality comparison, `Z.zero` for 0,
  `Z.pred` for predecessor (i.e., subtracting 1), `Z.mul` for multiplication,
  `Z.one` for 1, and `Z.of_int` to convert a primitive integer to a big integer.
