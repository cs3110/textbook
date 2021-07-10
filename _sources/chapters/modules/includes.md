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

# Includes

Copying and pasting code is almost always a bad idea. Duplication of code causes
duplication and proliferation of errors. So why are we so prone to making this
mistake? Maybe because it always seems like the easier option &mdash; easier and
quicker than applying the Abstraction Principle as we should to factor out
common code.

The OCaml module system provides a neat feature called *includes* that is like a
principled copy-and-paste that is quick and easy to use, but avoids actual
duplication. It can be used to solve some of the same problems as *inheritance*
in object-oriented languages.

Let's start with an example. Recall this implementation of sets as lists:

```{code-cell} ocaml
:tags: ["hide-output"]
module type Set = sig
  type 'a t
  val empty : 'a t
  val mem : 'a -> 'a t -> bool
  val add : 'a -> 'a t -> 'a t
  val elements : 'a t -> 'a list
end

module ListSet : Set = struct
  type 'a t = 'a list
  let empty = []
  let mem = List.mem
  let add = List.cons
  let elements s = List.sort_uniq Stdlib.compare s
end
```

Suppose we wanted to add a function `of_list : 'a list -> 'a t` that could
construct a set out of a list. If we had access to the source code of both
`ListSet` and `Set`, and if we were permitted to modify it, this wouldn't be
hard. But what if they were third-party libraries for which we didn't have
source code?

In Java, we might use inheritance to solve this problem:

```java
interface Set<T> { ... }
class ListSet<T> implements Set<T> { ... }
class ListSetExtended<T> extends ListSet<T> {
  Set<T> ofList(List<T> lst) { ... }
}
```

That helps us to reuse code, because the subclass inherits all the methods of
its superclass.

OCaml *includes* are similar. They enable a module to include all the items
defined by another module, or a module type to include all the specifications of
another module type.

Here's how we can use includes to solve the problem of adding `of_list` to
`ListSet`:

```{code-cell} ocaml
module ListSetExtended = struct
  include ListSet
  let of_list lst = List.fold_right add lst empty
end
```

This code says that `ListSetExtended` is a module that includes all the
definitions of the `ListSet` module, as well as a definition of `of_list`. We
don't have to know the source code implementing `ListSet` to make this happen.

```{note}
You might wonder we why can't simply implement `of_list` as the identity
function. See the section below on encapsulation for the answer.
```

## Semantics of Includes

Includes can be used inside of structures and signatures. When we include inside
a signature, we must be including another signature. And when we include inside
a structure, we must be including another structure.

**Including a structure** is effectively just syntactic sugar for writing a
local definition for each name defined in the module. Writing `include ListSet`
as we did above, for example, has an effect similar to writing the following:

```{code-cell} ocaml
module ListSetExtended = struct
  (* BEGIN all the includes *)
  type 'a t = 'a ListSet.t
  let empty = ListSet.empty
  let mem = ListSet.mem
  let add = ListSet.add
  let elements = ListSet.elements
  (* END all the includes *)
  let of_list lst = List.fold_right add lst empty
end
```
None of that is actually copying the source code of `ListSet`. Rather, the
`include` just creates a new definition in `ListSetExtended` with the same name
as each definition in `ListSet`. But if the set of names defined inside
`ListSet` ever changed, the `include` would reflect that change, whereas a
copy-paste job would not.

**Including a signature** is much the same. For example, we could write:

```{code-cell} ocaml
module type SetExtended = sig
  include Set
  val of_list : 'a list -> 'a t
end
```

Which would have an effect similar to writing the following:

```{code-cell} ocaml
module type SetExtended = sig
  (* BEGIN all the includes *)
  type 'a t
  val empty : 'a t
  val mem : 'a -> 'a t -> bool
  val add : 'a -> 'a t -> 'a t
  val elements  : 'a t -> 'a list
  (* END all the includes *)
  val of_list : 'a list -> 'a t
end
```

That module type would be suitable for `ListSetExtended`:

```{code-cell} ocaml
module ListSetExtended : SetExtended = struct
  include ListSet
  let of_list lst = List.fold_right add lst empty
end
```

## Encapsulation and Includes

We mentioned above that you might wonder why we didn't write this simpler
definition of `of_list`:

```{code-cell} ocaml
:tags: ["raises-exception"]
module ListSetExtended : SetExtended = struct
  include ListSet
  let of_list lst = lst
end
```

Check out that error message.  It looks like `of_list` doesn't have the right
type.  What if we try adding some type annotations?

```{code-cell} ocaml
:tags: ["raises-exception"]
module ListSetExtended : SetExtended = struct
  include ListSet
  let of_list (lst : 'a list) : 'a t = lst
end
```

Ah, now the problem is clearer: in the body of `of_list`, the equality of `'a t`
and `'a list` isn't known. In `ListSetExtended`, we do know that
`'a t = 'a ListSet.t`, because that's what the `include` gave us. But the fact
that `'a ListSet.t = 'a list` was hidden when `ListSet` was sealed at module
type `Set`. So, includes must obey encapsulation, just like the rest of the
module system.

One workaround is to rewrite the definitions as follows:

```{code-cell} ocaml
module ListSetImpl = struct
  type 'a t = 'a list
  let empty = []
  let mem = List.mem
  let add = List.cons
  let elements s = List.sort_uniq Stdlib.compare s
end

module ListSet : Set = ListSetImpl

module type SetExtended = sig
  include Set
  val of_list : 'a list -> 'a t
end

module ListSetExtendedImpl = struct
  include ListSetImpl
  let of_list lst = lst
end

module ListSetExtended : SetExtended = ListSetExtendedImpl
```

The important change is that `ListSetImpl` is not sealed, so its type `'a t` is
not abstract. When we include it in `ListSetExtended`, we can therefore exploit
the fact that it's a synonym for `'a list`.

What we just did is effectively the same as what Java does to handle the
visibility modifiers `public`, `private`, etc. The "private version" of a class
is like the `Impl` version above: anyone who can see that version gets to see
all the exposed items (fields in Java, types in OCaml), without any
encapsulation. The "public version" of a class is like the sealed version above:
anyone who can see that version is forced to treat the items as abstract, hence
encapsulated.

With that technique, if we want to provide a new implementation of one of the
included functions we *could* do that too:

```{code-cell} ocaml
module ListSetExtendedImpl = struct
  include ListSetImpl
  let of_list lst = List.fold_right add lst empty
  let rec elements = function
    | [] -> []
    | h :: t -> if mem h t then elements t else h :: elements t
end
```

But that's a bad idea. First, it's actually a quadratic implementation of
`elements` instead of linearithmic. Second, it does not *replace* the original
implementation of `elements`. Remember the semantics of modules: all definitions
are evaluated from top to bottom, in order. So the new definition of `elements`
above won't come into use until the very end of evaluation. If any earlier
functions had happened to use `elements` as a helper, they would use the
original linearithmic version, not the new quadratic version.

```{warning}
This differs from what you might expect from Java, which uses a language feature
called [dynamic dispatch][dd] to figure out which method implementation to
invoke. Dynamic dispatch is arguably *the* defining feature of object-oriented
languages. OCaml functions are not methods, and they do not use dynamic
dispatch.
```

[dd]: https://en.wikipedia.org/wiki/Dynamic_dispatch


## Include vs. Open

The `include` and `open` statements are quite similar, but they have
a subtly different effect on a structure.  Consider this code:

```{code-cell} ocaml
module M = struct
  let x = 0
end

module N = struct
  include M
  let y = x + 1
end

module O = struct
  open M
  let y = x + 1
end
```

Look closely at the values contained in each structure. `N` has both an `x` and
`y`, whereas `O` has only a `y`. The reason is that `include M` causes all the
definitions of `M` to also be included in `N`, so the definition of `x` from `M`
is present in `N`. But `open M` only made those definitions available in the
*scope* of `O`; it doesn't actually make them part of the *structure*. So `O`
does not contain a definition of `x`, even though `x` is in scope during the
evaluation of `O`'s definition of `y`.

A metaphor for understanding this difference might be: `open M` imports
definitions from `M` and makes them available for local consumption, but they
aren't exported to the outside world. Whereas `include M` imports definitions
from `M`, makes them available for local consumption, and additionally exports
them to the outside world.

## Including Code in Multiple Modules

Recall that we also had an implementation of sets that made sure every element
of the underlying list was unique:

```{code-cell} ocaml
module UniqListSet : Set = struct
  (** All values in the list must be unique. *)
  type 'a t = 'a list
  let empty = []
  let mem = List.mem
  let add x s = if mem x s then s else x :: s
  let elements = Fun.id
end
```

Suppose we wanted add `of_list` to that module too. One possibility would be to
copy and paste that function from `ListSet` into `UniqListSet`. But that's poor
software engineering. So let's rule that out right away as a non-solution.

Instead, suppose we try to define the function outside of either module:

```{code-cell} ocaml
:tags: ["raises-exception"]
let of_list lst = List.fold_right add lst empty
```

The problem is we either need to choose which module's `add` and `empty` we
want. But as soon as we do, the function becomes useful only with that one
module:

```{code-cell} ocaml
let of_list lst = List.fold_right ListSet.add lst ListSet.empty
```

We could make `add` and `empty` be parameters instead:

```{code-cell} ocaml
let of_list' add empty lst = List.fold_right add lst empty

let of_list lst = of_list' ListSet.add ListSet.empty lst
let of_list_uniq lst = of_list' UniqListSet.add UniqListSet.empty lst
```

But this is annoying in a couple of ways. First, we have to remember which
function name to call, whereas all the other operations that are part of those
modules have the same name, regardless of which module they're in. Second, the
`of_list` functions live outside either module, so clients who open one of the
modules won't automatically get the ability to name those functions.

Let's try to use includes to solve this problem. First, we write a module that
contains the parameterized implementation:

```{code-cell} ocaml
module SetOfList = struct
  let of_list' add empty lst = List.fold_right add lst empty
end
```

Then we include that module to get the helper function:

```{code-cell} ocaml
module UniqListSetExtended : SetExtended = struct
  include UniqListSet
  include SetOfList
  let of_list lst = of_list' add empty lst
end

module ListSetExtended : SetExtended = struct
  include ListSet
  include SetOfList
  let of_list lst = of_list' add empty lst
end
```

That works, but we've only partially succeeded in achieving code reuse:

- On the positive side, the code that implements `of_list'` has been factored
  out into a single location and reused in the two structures.

- But on the negative side, we still had to write an implementation of `of_list`
  in both modules. Worse yet, those implementations are identical. So there's
  still code duplication occurring.

Could we do better? Yes. And that leads us to functors, next.
