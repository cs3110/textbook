# Refs

A *ref* is like a pointer or reference in an imperative language.
It is a location in memory whose contents may change.  Refs
are also called *ref cells*, the idea being that there's a cell
in memory that can change.

Here's an example utop transcript to introduce refs:
```
# let x = ref 0;;
val x : int ref = {contents = 0}

# !x;;
- : int = 0

# x := 1;;
- : unit = ()

# !x;;
- : int = 1
```

At a high level, what that shows is creating a ref, getting the value from inside it,
changing its contents, and observing the changed contents.  Let's dig a little deeper.

The first phrase, `let x = ref 0`, creates a reference using the `ref` keyword.
That's a location in memory whose contents are initialized to `0`.  Think of the
location itself as being an address&mdash;for example, 0x3110bae0&mdash;even though
there's no way to write down such an address in an OCaml program.  The keyword
`ref` is what causes the memory location to be allocated and initialized.

The first part of the response from utop, `val x : int ref`, indicates
that `x` is a variable whose type is `int ref`.  We have a new type
constructor here.  Much like `list` and `option` are type constructors,
so is `ref`.  A `t ref`, for any type `t`, is a reference to a memory
location that is guaranteed to contain a value of type `t`.  As usual
we should read a type from right to left:  `t ref` means a
reference to a `t`.
The second part of the response shows us the contents of the memory
location.  Indeed, the contents have been initialized to `0`.

The second phrase, `!x`, dereferences `x` and returns the contents
of the memory location.  Note that `!` is the dereference operator
in OCaml, not Boolean negation.

The third phrase, `x := 1`, is an assignment.  It mutates the contents
`x` to be `1`.  Note that `x` itself still points to the same location
(i.e., address) in memory. Variables really are immutable in that way. 
What changes is the contents of that memory location.  Memory is
mutable; variable bindings are not.  The response from utop is simply
`()`, meaning that the assignment took place&mdash;much like printing
functions return `()` to indicate that the printing did happen.

The fourth phrase, `!x` again dereferences `x` to demonstrate that 
the contents of the memory location did indeed change.

## Aliasing

Now that we have refs, we have *aliasing*: two refs could point to the
same memory location, hence updating through one causes the other to also be updated.
For example,

```
let x = ref 42 
let y = ref 42 
let z = x
let () = x := 43
let w = (!y) + (!z)
```

The result of executing that code is that `w` is bound to `85`, because `let z = x`
causes `z` and `x` to become aliases, hence updating `x` to be `43` also causes `z`
to be `43`.
