# If Expressions

The expression `if e1 then e2 else e3` evaluates to `e2` if `e1` evaluates to `true`,
and to `e3` otherwise.  We call `e1` the *guard* of the if expression.

```
# if 3 + 5 > 2 then "yay!" else "boo!";;
- : string = "yay!"
```

Unlike if-then-else *statements* that you may have used in imperative languages,
if-then-else *expressions* in OCaml are just like any other expression; they can
be put anywhere an expression can go.  That makes them similar to the ternary operator
`? :` that you might have used in other languages.

```
# 4 + (if 'a' = 'b' then 1 else 2);;
- : int = 6
```

If expressions can be nested in a pleasant way:

```
if e1 then e2
else if e3 then e4
else if e5 then e6
...
else en
```

You should regard the final `else` as mandatory, regardless of whether you are writing
a single if expression or a highly nested if expression.  If you leave it off you'll
likely get an error message that, for now, is inscrutable:

```
# if 2>3 then 5;;
Error: This expression has type int but an expression was expected of type unit
```
 

**Syntax.** The syntax of an if expression:
```
if e1 then e2 else e3
```
The letter `e` is used here to represent any other OCaml expression; it's an
example of a *syntactic variable* aka *metavariable*, which is not actually
a variable in the OCaml language itself, but instead a name for a certain
syntactic construct.  The numbers after the letter `e` are being used
to distinguish the three different occurrences of it.

**Dynamic semantics.**
The dynamic semantics of an if expression:

* if `e1` evaluates to `true`, and if `e2` evaluates to a value `v`, 
  then `if e1 then e2 else e3` evaluates to `v`

* if `e1` evaluates to `false`, and if `e3` evaluates to a value `v`, 
  then `if e1 then e2 else e3` evaluates to `v`.

We call these *evaluation rules*:  they define how to evaluate expressions. 
Note how it takes two rules to describe the evaluation of an if expression,
one for when the guard is true, and one for when the guard is false.
The letter `v` is used here to represent any OCaml value; it's another
example of a metavariable.  Later in the semester we will develop
a more mathematical way of expressing dynamic semantics, but for now
we'll stick with this more informal style of explanation.

**Static semantics.** The static semantics of an if expression:

* if `e1` has type `bool` and `e2` has type `t` and `e3` has type `t` 
  then `if e1 then e2 else e3` has type `t`
  
We call this a *typing rule*:  it describes how to type check an expression.
Note how it only takes one rule to describe the type checking of an if expression.
At compile time, when type checking is done, it makes no difference whether the
guard is true or false; in fact, there's no way for the compiler to know
what value the guard will have at run time.  The letter `t` here is used
to represent any OCaml type; the OCaml manual also has definition of
[all types][types] (which curiously does not name 
the base types of the language like `int` and `bool`).

[types]: http://caml.inria.fr/pub/docs/manual-ocaml/types.html

We're going to be write "has type" a lot, so let's introduce a more compact
notation for it.  Whenever we would write "`e` has type `t`", let's instead
write `e : t`.  The colon is pronounced "has type".  This usage of colon
is consistent with how the toplevel responds after it evaluates an expression
that you enter:
```
# let x = 42;;
val x : int = 42
```
In the above example, variable `x` has type `int`, which is what the colon indicates.
