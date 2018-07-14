# Includes

Recall our implementation of sets as lists that allow duplicates:
```
module type Set = sig
  type 'a t
  val empty : 'a t
  val mem   : 'a -> 'a t -> bool
  val add   : 'a -> 'a t -> 'a t
  val elts  : 'a t -> 'a list
end

module ListSetDups : Set = struct
  type 'a t   = 'a list
  let empty   = []
  let mem     = List.mem
  let add x s = x::s
  let elts s  = List.sort_uniq Pervasives.compare s
end
```

Suppose we wanted to add a function `of_list : 'a list -> 'a t` to the
`ListSetDups` module that could construct a set out of a list.  If we
had access to the source code of both `ListSetDups` and `Set`, and if we
were permitted to modify it, this wouldn't be hard.  But what if they
were third-party libraries for which we didn't have source code?

In CS 2110, you learned about extending classes and inheriting
methods of a superclass.  Those object-oriented language features
provide (among many other things) the ability to reuse code.  For
example, a subclass includes all the methods of its superclasses, though
some might by overridden.

OCaml provides a language features called *includes* that also enables
code reuse.  This feature is similar to the object-oriented example we
just gave:  it enables a structure to include all the values defined by
another structure, or a signature to include all the names declared by
another signature.

We can use includes to solve the problem of adding `of_list` to `ListSetDups`:
```
module ListSetDupsExtended = struct
  include ListSetDups
  let of_list lst = List.fold_right add lst empty
end
```
This code says that `ListSetDupsExtended` is a structure containing all
the definitions of the `ListSetDups` structure, as well as a definition
of `of_list`. We don't have to know the source code implementing `ListSetDups`
to make this happen.  (You might wonder we why can't simply write 
`let of_list lst = lst`.  See the section on the semantics of includes,
below, for the answer.)

If we want to provide a new implementation of one of the included
functions we could do that too:
```
module ListSetDupsExtended = struct
  include ListSetDups
  let of_list lst = List.fold_right add lst empty
  let rec elts = function
    | [] -> []
    | h::t -> if mem h t then elts' t else h::(elts' t)
end
```
But that's actually a less efficient implementation of 
`elts`, so we probably shouldn't do that for real. 

One misconception to watch out for is that the above example
does not *replace* the original implementation of `elts`.  If
any code inside `ListSetDups` called that original implementation,
it still would in `ListSetDupsExtended`.  Why?  Remember
the semantics of modules:  all definitions are evaluated from
top to bottom, in order.  So the new definition of `elts` above
won't come into use until the very end of evaluation.  This differs
from what you might expect from object-oriented languages like Java,
which use a language feature called [dynamic dispatch][dd] to figure
out which implementation to invoke.

[dd]: https://en.wikipedia.org/wiki/Dynamic_dispatch
