# Labeled and optional arguments

Usually the type and name of a function give you a pretty good idea of what the
arguments should be.  However, for functions with many arguments (especially
arguments of the same type), it can be useful to label them.  For example, you
might guess that the function `String.sub` returns a substring of the given string
(and you would be correct).  You could type in `String.sub` to find its type:

    # String.sub;;
    - : string -> int -> int -> string

But it's not clear from the type how to use it&mdash;you're forced to consult the
documentation.

OCaml supports labeled arguments to functions.  You can declare this
kind of function using the following syntax:

    # let f ~name1:arg1 ~name2:arg2 = arg1 + arg2;;
    val f : name1:int -> name2:int -> int = <fun>

This function can be called by passing the labeled arguments in either order:

    f ~name2:3 ~name1:4;;

Labels for arguments are often the same as the variable names for them.  OCaml
provides a shorthand for this case.  The following are equivalent:

    let f ~name1:name1 ~name2:name2 = name1+name2
    let f ~name1 ~name2 = name1 + name2

Use of labeled arguments is a largely matter of taste: they convey extra
information, but they can also add clutter to types.

If you need to write both a labeled argument and an explicit type annotation
for it, here's the syntax for doing so:

	let f ~name1:(arg1:int) ~name2:(arg2:int) = arg1 + arg2

It is also possible to make some arguments optional: when called without the
argument, a default value will be provided.  To declare such a function, use the
following syntax:

    # let f ?name:(arg1=8) arg2 = arg1 + arg2;;
    val f : ?name:int -> int -> int = <fun>

You can then call a function with or without the argument:

    # f ~name:2 7;;
    - : int = 9

    # f 7;;
    - : int = 15
