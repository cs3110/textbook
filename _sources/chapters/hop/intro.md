# Higher-Order Programming

{{ video_embed | replace("%%VID%%", "rTbinjZ9-oc")}}

Functions are values just like any other value in OCaml. What does that mean
exactly? This means that we can pass functions around as arguments to other
functions, that we can store functions in data structures, that we can return
functions as a result from other functions, and so forth.

*Higher-order functions* either take other functions as input or return other
functions as output (or both). Higher-order functions are also known as
*functionals*, and programming with them could therefore be called *functional
programming*&mdash;indicating what the heart of programming in languages like
OCaml is all about.

Higher-order functions were one of the more recent adoptions from functional
languages into mainstream languages. The Java 8 Streams library and Python 2.3's
`itertools` modules are examples of that; C++ has also been increasing its
support since at least 2011.

```{note}
C wizards might object the adoption isn't so recent. After all, C has long had
the ability to do higher-order programming through function pointers. But that
ability also depends on the programming pattern of passing an additional
*environment* parameter to provide the values of variables in the function to be
called through the pointer. As we'll see in our later chapter on interpreters,
the essence of (higher-order) functions in a functional language is that they
are really something called a *closure* that obviates the need for that extra
parameter. Bear in mind that the issue is not what is *possible* to compute in a
language&mdash;after all everything is eventually compiled down to machine code,
so we could just write in that exclusively&mdash;but what is *pleasant* to
compute.
```

In this chapter we will see what all the fuss is about.  Higher-order functions
enable beautiful, general, reusable code.
