# Comments

In addition to specifying functions, programmers need to provide
comments in the body of the functions.  In fact,
programmers usually do not write enough comments in their code. But
this doesn't mean that adding more comments is always better. The wrong
comments will simply obscure the code further. Shoveling as many
comments into code as possible usually makes the code worse! Both code
and comments are precise tools for communication (with the computer and
with other programmers) that should be wielded carefully.

It is particularly annoying to read code that contains many interspersed
comments (typically of questionable value), e.g.:

```
let y = x+1 (* make y one greater than x *)
```

For complex algorithms, some comments may be necessary to explain how
the code implementing the algorithm works. Programmers are often tempted
to write comments about the algorithm interspersed through the code. But
someone reading the code will often find these comments confusing
because they don't have a high-level picture of the algorithm. It is
usually better to write a paragraph-style comment at the beginning of
the function explaining how its implementation works. Explicit points in
the code that need to be related to that paragraph can then be marked
with very brief comments, like `(* case 1 *)`.

Another common but well-intentioned mistake is giving variables long,
descriptive names, as in the following verbose code:

```
let number_of_zeros_in_the_list =
   fold_left (fun (accumulator:int) (list_element:int) ->
		  accumulator + (if list_element=0 then 1 else 0)) 0 the_list
in ...
```

Code using such long names is verbose and hard to read.
Instead of trying to embed a complete description of a variable in its
name, use a short and suggestive name (e.g., `zeroes`), and if
necessary, add a comment at its declaration explaining the purpose of
the variable.

A related bad practice is to encode the type of the variable in its
name, e.g. naming a variable `count` a name like `i_count` to show that
it's an integer. Instead, just write a type declaration. If the variable
is so far from its type that you can't see the type declaration, the
code should probably be restructured anyway.
