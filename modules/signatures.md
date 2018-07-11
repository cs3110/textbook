# Signatures

Module types let us describe groups of related modules.  The syntax
for defining a module type is:
```
module type ModuleTypeName = sig 
  (* declarations *)
end
```
Here is a module type for stacks:
```
module type Stack = sig
  type 'a stack
  val empty    : 'a stack
  val is_empty : 'a stack -> bool
  val push     : 'a -> 'a stack -> 'a stack
  val peek     : 'a stack -> 'a
  val pop      : 'a stack -> 'a stack
end
```
By convention, the module type name is capitalized, but it does
not have to be.  There is an older convention from the SML language
that signature names are in ALLCAPS, and you might occasionally see
that still, but we don't typically follow it in OCaml. 

The part of the module type that is written 
```
sig (* declarations *) end
```
is called a *signature*.  A signature is simply a sequence of declarations.  The
signature itself is anonymous&mdash;it has no name&mdash;until it is bound
to a name by a module type definition.  The syntax `val id : t` means that
there is a value named `id` whose type is `t`.

A structure *matches* a signature if the structure provides definitions 
for all the names specified in the signature (and possibly more), and 
these definitions meet the type requirements given in the signature.
Usually, a definition meets a type requirement by providing a value
of exactly that type.  But the definition could instead provide
a value that has a more general type.  For example:
```
module type Sig = sig
  val f : int -> int
end

module M1 : Sig = struct
  let f x = x+1
end

module M2 : Sig = struct
  let f x = x
end
```
Module `M1` provides a function `f` of exactly the type specified by
`Sig`, namely, `int->int`. Module `M2` provides a function that is
instead of type `'a -> 'a`. Both `M1` and `M2` match `Sig`.  Note that
anywhere a value `v1` of type `int->int` is needed, it's safe to instead
use a value `v2` of type `'a -> 'a`. That's because if we apply `v2` to
an `int`, its type guarantees us that we will get an `int` back.

Returning to our example, the structure given above for `ListStack`
doesn't yet match the signature given above for `Stack`, because that
structure doesn't define the type `'a stack`.  So we could amend the
definition of `ListStack` to:
```
module ListStack = struct
  type 'a stack = 'a list
  (* the rest is the same as before *)
end
```

Now that structure matches the signature of `Stack`.  We can ask the compiler
to check that by providing a module type annotation for the module:

```
module ListStack : Stack = struct
  type 'a stack = 'a list
  (* the rest is the same as before *)
end
```

The type `'a stack` is an example of a *representation type*:  a type that is 
used to represent a version of a data structure.  Here, we're implementing stacks
using lists, so the representation type is a list. 
