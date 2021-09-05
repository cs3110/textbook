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

# Printing

OCaml has built-in printing functions for a few of the built-in primitive
types: `print_char`, `print_string`, `print_int`, and `print_float`. There's
also a `print_endline` function, which is like `print_string`, but also outputs
a newline.

```{code-cell} ocaml
print_endline "Camels are bae"
```

## Unit

Let's look at the types of a couple of those functions:
```{code-cell} ocaml
print_endline
```

```{code-cell} ocaml
print_string
```

They both take a string as input and return a value of type `unit`, which we
haven't seen before. There is only one value of this type, which is written `()`
and is also pronounced "unit". So `unit` is like `bool`, except there is one
fewer value of type `unit` than there is of `bool`.

Unit is used when you need to take an argument or return a value, but there's no
interesting value to pass or return. It is the equivalent of `void` in Java, and
is similar to `None` in Python. Unit is often used when you're writing or using
code that has side effects. Printing is an example of a side effect: it changes
the world and can't be undone.

## Semicolon

If you want to print one thing after another, you could sequence some print
functions using nested `let` expressions:

```{code-cell} ocaml
let _ = print_endline "Camels" in
let _ = print_endline "are" in
print_endline "bae"
```

The `let _ = e` syntax above is a way of evaluating `e` but not binding
its value to any name.  Indeed, we know the value each of those `print_endline`
functions will return: it will always be `()`, the unit value. So there's
no good reason to bind it to a variable name.  We could also write `let () = e`
to indicate we know it's just a unit value that we don't care about:

```{code-cell} ocaml
let () = print_endline "Camels" in
let () = print_endline "are" in
print_endline "bae"
```

But either way the boilerplate of all the `let..in` is annoying to have to
write! So there's a special syntax that can be used to chain
together multiple functions that return unit. The expression `e1; e2` first
evaluates `e1`, which should evaluate to `()`, then discards that value, and
evaluates `e2`. So we could rewrite the above code as:

```{code-cell} ocaml
print_endline "Camels";
print_endline "are";
print_endline "bae"
```

That is more idiomatic OCaml code, and it also looks more natural to imperative
programmers.

```{warning}
There is no semicolon after the final `print_endline` in that example. A common
mistake is to put a semicolon *after* each print statement. Instead, the
semicolons go strictly *between* statements. That is, semicolon is a statement
*separator* not a statement *terminator*. If you were to add a semicolon at the
end, you could get a syntax error depending on the surrounding code.
```

## Ignore

If `e1` does not have type `unit`, then `e1; e2` will give a warning, because
you are discarding a potentially useful value. If that is truly your intent, you
can call the built-in function `ignore : 'a -> unit` to convert any value to
`()`:

```{code-cell} ocaml
(ignore 3); 5
```

Actually `ignore` is easy to implement yourself:

```{code-cell} ocaml
let ignore x = ()
```

Or you can even write underscore to indicate the function takes in a value but
does not bind that value to a name. That means the function can never use that
value in its body. But that's okay: we want to ignore it.

```{code-cell} ocaml
let ignore _ = ()
```

## Printf

For complicated text outputs, using the built-in functions for primitive type
printing quickly becomes tedious. For example, suppose you wanted to write a
function to print a statistic:

```{code-cell} ocaml
(** [print_stat name num] prints [name: num]. *)
let print_stat name num =
  print_string name;
  print_string ": ";
  print_float num;
  print_newline ()
```

```{code-cell} ocaml
print_stat "mean" 84.39
```

How could we shorten `print_stat`? In Java you might use the overloaded `+`
operator to turn all objects into strings:

```java
void print_stat(String name, double num) {
   System.out.println(name + ": " + num);
}
```

But OCaml values are not objects, and they do not have a `toString()` method
they inherit from some root `Object` class. Nor does OCaml permit overloading of
operators.

Long ago though, FORTRAN invented a different solution that other languages like
C and Java and even Python support. The idea is to use a *format specifier* to
&mdash;as the name suggest&mdash; specify how to format output. The name this
idea is best known under is probably "printf", which refers to the name of the C
library function that implemented it. Many other languages and libraries still
use that name, including OCaml's `Printf` module.

Here's how we'd use `printf` to re-implement `print_stat`:

```{code-cell} ocaml
let print_stat name num =
  Printf.printf "%s: %F\n%!" name num
```

```{code-cell} ocaml
print_stat "mean" 84.39
```

The first argument to function `Printf.printf` is the format specifier. It
*looks* like a string, but there's more to it than that. It's actually
understood by the OCaml compiler in quite a deep way. Inside the format
specifier there are:

- plain characters, and

- conversion specifiers, which begin with `%`.

There are about two dozen conversion specifiers available, which you can read
about in the [documentation of `Printf`][printf-doc]. Let's pick apart the
format specifier above as an example.

[printf-doc]: https://ocaml.org/api/Printf.html

- It starts with `"%s"`, which is the conversion specifier for strings.  That means
  the next argument to `printf` must be a `string`, and the contents of that string
  will be output.

- It continues with `": "`, which are just plain characters.  Those are inserted
  into the output.

- It then has another conversion specifier, `%F`. That means the next argument of
  `printf` must have type `float`, and will be output in the same format that
  OCaml uses to print floats.

- The newline `"\n"` after that is another plain character sequence.

- Finally the conversion specifier `"%!"` means to *flush the output buffer*. As
  you might have learned in earlier programming classes, output is often
  *buffered*, meaning that it doesn't all happen at once or right away. Flushing
  the buffer ensures that anything still sitting in the buffer gets output
  immediately. This specifier is special in that it doesn't actually need
  another argument to `printf`.

If the type of an argument is incorrect with respect to the conversion specifier,
OCaml will detect that.  Let's add a type annotation to force `num` to be an
`int`, and see what happens with the float conversion specifier `%F`:

```{code-cell} ocaml
:tags: ["raises-exception"]
let print_stat name (num : int) =
  Printf.printf "%s: %F\n%!" name num
```

To fix that, we can change to the conversion specifier for `int`, which is `%i`:

```{code-cell} ocaml
let print_stat name num =
  Printf.printf "%s: %i\n%!" name num
```

Another very useful variant of `printf` is `sprintf`, which collects the output
in string instead of printing it:

```{code-cell} ocaml
let string_of_stat name num =
  Printf.sprintf "%s: %F" name num
```

```{code-cell} ocaml
string_of_stat "mean" 84.39
```
