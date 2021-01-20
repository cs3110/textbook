# Printing

OCaml has built-in printing functions for several of the built-in
primitive types: `print_char`, `print_int`, `print_string`, and
`print_float`. There's also a `print_endline` function, which is like
`print_string`, but also outputs a newline.

Let's look at the type of a couple of those functions:
```
# print_endline;;
- : string -> unit = <fun>

# print_string;;
- : string -> unit = <fun>
```

They both take a string as input and return a value of type `unit`,
which we haven't seen before. There is only one value of this type,
which is written `()` and is also pronounced "unit".  So `unit` is like
`bool`, except there is one fewer value of type `unit` than there is of
`bool`. Unit is therefore used when you need to take an argument or
return a value, but there's no interesting value to pass or return. Unit
is often used when you're writing or using code that has side effects.
Printing is an example of a side effect: it changes the world and can't
be undone.

If you want to print one thing after another, you could sequence some
print functions using nested let expressions:
```
let x = print_endline "THIS" in
let y = print_endline "IS" in
print_endline "3110"
```

But the boilerplate of all the `let x = ... in` above is annoying to
have to write!  We don't really care about giving names to the unit
values returned by those printing functions.  So there's a special
syntax that can be used to chain together multiple functions who return
unit. The expression `e1; e2` first evaluates `e1`, which should
evaluate to `()`, then discards that value, and evaluates `e2`.  So we
could rewrite the above code as:
```
print_endline "THIS";
print_endline "IS";
print_endline "3110"
```
And that is far more idiomatic code.

If `e1` does not have type `unit`, then `e1; e2` will give a warning, because
you are discarding useful values.  If that is truly your intent, you can call
the built-in function `ignore : 'a -> unit` to convert any value to `()`:

```
# 3; 5;;
Warning 10: this expression should have type unit.                                                                                                                      
- : int = 5

# ignore 3; 5;;
- : int = 5
```

