# The OCaml Toplevel

{{ video_embed | replace("%%VID%%", "3fzrFY-2ZQ8")}}

The *toplevel* is like a calculator or command-line interface to OCaml. It's
similar to JShell for Java, or the interactive Python interpreter. The toplevel
is handy for trying out small pieces of code without going to the trouble of
launching the OCaml compiler. But don't get too reliant on it, because creating,
compiling, and testing large programs will require more powerful tools. Some
other languages would call the toplevel a *REPL*, which stands for
read-eval-print-loop: it reads programmer input, evaluates it, prints the
result, and then repeats.

In a terminal window, type `utop` to start the toplevel. Press Control-D to exit
the toplevel. You can also enter `#quit;;` and press return. Note that you must
type the `#` there: it is in addition to the `#` prompt you already see.


## Types and values

You can enter expressions into the OCaml toplevel. End an expression with a
double semi-colon `;;` and press the return key. OCaml will then evaluate the
expression, tell you the resulting value, and the value's type. For example:

```ocaml
# 42;;
- : int = 42
```

Let's dissect that response from utop, reading right to left:

* `42` is the value.
* `int` is the type of the value.
* The value was not given a name, hence the symbol `-`.


{{ video_embed | replace("%%VID%%", "eRnG4gwOTlI")}}

You can bind values to names with a `let` definition, as follows:

```ocaml
# let x = 42;;
val x : int = 42
```

Again, let's dissect that response, this time reading left to right:

* A value was bound to a name, hence the `val` keyword.
* `x` is the name to which the value was bound.
* `int` is the type of the value.
* `42` is the value.

You can pronounce the entire output as "`x` has type `int` and equals `42`."

## Functions

A function can be defined at the toplevel using syntax like this:

```ocaml
# let increment x = x+1;;
val increment : int -> int = <fun>
```

Let's dissect that response:

* `increment` is the identifier to which the value was bound.
* `int -> int` is the type of the value. This is the type of functions that take
  an `int` as input and produce an `int` as output. Think of the arrow `->` as a
  kind of visual metaphor for the transformation of one value into another
  value&mdash;which is what functions do.
* The value is a function, which the toplevel chooses not to print (because it
  has now been compiled and has a representation in memory that isn't easily
  amenable to pretty printing). Instead, the toplevel prints `<fun>`, which is
  just a placeholder.

```{note}
`<fun>` itself is not a value. It just indicates an unprintable function value.
```

You can "call" functions with syntax like this:

```ocaml
# increment 0;;
- : int = 1
# increment(21);;
- : int = 22
# increment (increment 5);;
- : int = 7
```

But in OCaml the usual vocabulary is that we "apply" the function rather than
"call" it.

Note how OCaml is flexible about whether you write the parentheses or not, and
whether you write whitespace or not. One of the challenges of first learning
OCaml can be figuring out when parentheses are actually required. So if you find
yourself having problems with syntax errors, one strategy is to try adding some
parentheses.

## Loading code in the toplevel

In addition to allowing you to define functions, the toplevel will also accept
*directives* that are not OCaml code but rather tell the toplevel itself to do
something. All directives begin with the `#` character. Perhaps the most common
directive is `#use`, which loads all the code from a file into the toplevel,
just as if you had typed the code from that file into the toplevel.

For example, suppose you create a file named `mycode.ml`. In that file put the
following code:

```ocaml
let inc x = x + 1
```

Start the toplevel. Try entering the following expression, and observe the
error:

```ocaml
# inc 3;;
Error: Unbound value inc
Hint: Did you mean incr?
```

The error occurs because the toplevel does not yet know anything about a
function named `inc`. Now issue the following directive to the toplevel:

```ocaml
# #use "mycode.ml";;
```

Note that the first `#` character above indicates the toplevel prompt to you.
The second `#` character is one that you type to tell the toplevel that you are
issuing a directive. Without that character, the toplevel would think that you
are trying to apply a function named `use`.

Now try again:

```ocaml
# inc 3;;
- : int = 4
```

## Workflow in the toplevel

The best workflow when using the toplevel with code stored in files is:

* Edit the code in the file.
* Load the code in the toplevel with `#use`.
* Interactively test the code.
* Exit the toplevel.  **Warning:** do not skip this step.

```{tip}
Suppose you wanted to fix a bug in your code. It's tempting to not exit the
toplevel, edit the file, and re-issue the `#use` directive into the same
toplevel session. Resist that temptation. The "stale code" that was loaded from
an earlier `#use` directive in the same session can cause surprising things to
happen&mdash;surprising when you're first learning the language, anyway. So
**always exit the toplevel before re-using a file.**
```
