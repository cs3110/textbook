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

# Modules

{{ video_embed | replace("%%VID%%", "hIUSrPxCdHc")}}

We begin with a couple of examples of the OCaml module system before diving
into the details.

A *structure* is simply a collection of definitions, such as:

```ocaml
struct
  let inc x = x + 1
  type primary_color = Red | Green | Blue
  exception Oops
end
```

In a way, the structure is like a record: the structure has some distinct
components with names. But unlike a record, it can define new types, exceptions,
and so forth.

By itself the code above won't compile, because structures do not have the same
first-class status as values like integers or functions. You can't just enter
that code in utop, or pass that structure to a function, etc. What you can do is
bind the structure to a name:

```{code-cell} ocaml
module MyModule = struct
  let inc x = x + 1
  type primary_color = Red | Green | Blue
  exception Oops
end
```

The output from OCaml has the form:

```ocaml
module MyModule : sig ... end
```

This indicates that `MyModule` has been defined, and that it has been inferred
to have the *module type* that appears to the right of the colon. That module
type is written as *signature*:

```ocaml
sig
  val inc : int -> int
  type primary_color = Red | Green | Blue
  exception Oops
end
```

The signature itself is a collection of *specifications*. The specifications for
variant types and exceptions are simply their original definitions, so
`primary_color` and `Oops` are no different than they were in the original
structure. The specification for `inc` though is written with the `val` keyword,
exactly as the toplevel would respond if we defined `inc` in it.

```{note}
This use of the word "specification" is perhaps confusing, since many
programmers would use that word to mean "the comments specifying the behavior of
a function." But if we broaden our sight a little, we could allow that the type
of a function is part of its specification. So it's at least a related sense of
the word.
```

{{ video_embed | replace("%%VID%%", "8Q-2b7iGvXE")}}

The definitions in a module are usually more closely related than those in
`MyModule`. Often a module will implement some data structure. For example, here
is a module for stacks implemented as linked lists:

```{code-cell} ocaml
module ListStack = struct
  (** [empty] is the empty stack. *)
  let empty = []

  (** [is_empty s] is whether [s] is empty. *)
  let is_empty = function [] -> true | _ -> false

  (** [push x s] pushes [x] onto the top of [s]. *)
  let push x s = x :: s

  (** [Empty] is raised when an operation cannot be applied
      to an empty stack. *)
  exception Empty

  (** [peek s] is the top element of [s].
      Raises [Empty] if [s] is empty. *)
  let peek = function
    | [] -> raise Empty
    | x :: _ -> x

  (** [pop s] is all but the top element of [s].
      Raises [Empty] if [s] is empty. *)
  let pop = function
    | [] -> raise Empty
    | _ :: s -> s
end
```

```{important}
The specification of `pop` might surprise you. Note that it does not return the
top element. That's the job of `peek`. Instead, `pop` returns all but the top
element.
```

We can then use that module to manipulate a stack:

```{code-cell} ocaml
ListStack.push 2 (ListStack.push 1 ListStack.empty)
```

```{warning}
There's a common confusion lurking here for those programmers coming from
object-oriented languages. It's tempting to think of `ListStack` as being an
object on which you invoke methods. Indeed `ListStack.push` vaguely looks like
we're invoking a `push` method on a `ListStack` object. But that's not what is
happening. In an OO language you could instantiate many stack objects. But here,
there is only one `ListStack`. Moreover it is not an object, in large part
because it has no notion of a `this` or `self` keyword to denote the receiving
object of the method call.
```

That's admittedly rather verbose code. Soon we'll see several solutions to that
problem, but for now here's one:

```{code-cell} ocaml
ListStack.(push 2 (push 1 empty))
```

By writing `ListStack.(e)`, all the names from `ListStack` become usable in `e`
without needing to write the prefix `ListStack.` each time. Another improvement
could be using the pipeline operator:

```{code-cell} ocaml
ListStack.(empty |> push 1 |> push 2)
```

Now we can read the code left-to-right without having to parse parentheses.
Nice.

```{warning}
There's another common OO confusion lurking here. It's tempting to think of
`ListStack` as being a class from which objects are instantiated. That's not the
case though. Notice how there is no `new` operator used to create a stack above,
nor any constructors (in the OO sense of that word).
```

Modules are considerably more basic than classes. A module is just a collection
of definitions in its own namespace. In `ListStack`, we have some definitions of
functions&mdash;`push`, `pop`, etc.&mdash;and one value, `empty`.

So whereas in Java we might create a couple of stacks using code like this:

```java
Stack s1 = new Stack();
s1.push(1);
s1.push(2);
Stack s2 = new Stack();
s2.push(3);
```

In OCaml the same stacks could be created as follows:

```{code-cell} ocaml
let s1 = ListStack.(empty |> push 1 |> push 2)
let s2 = ListStack.(empty |> push 3)
```


## Module Definitions

{{ video_embed | replace("%%VID%%", "EUJXBpra0oY")}}

The `module` definition keyword is much like the `let` definition keyword that
we learned before. (The OCaml designers hypothetically could have chosen to use
`let_module` instead of `module` to emphasize the similarity.) The difference is
just that:

- `let` binds a value to a name, whereas
- `module` binds a *module value* to a name.

**Syntax.**

The most common syntax for a module definition is simply:

```ocaml
module ModuleName = struct
  module_items
end
```

where `module_items` inside a structure can include `let` definitions, `type`
definitions, and `exception` definitions, as well as nested `module`
definitions. Module names must begin with an uppercase letter, and idiomatically
they use `CamelCase` rather than `Snake_case`.

But a more accurate version of the syntax would be:

```ocaml
module ModuleName = module_expression
```

where a `struct` is just one sort of `module_expression`. Here's another: the
name of an already defined module. For example, you can write `module L = List`
if you'd like a short alias for the `List` module. We'll see other sorts of
module expressions later in this section and chapter.

The definitions inside a structure can optionally be terminated by `;;` as in
the toplevel:

```{code-cell} ocaml
module M = struct
  let x = 0;;
  type t = int;;
end
```
Sometimes that can be useful to add temporarily if you are trying to diagnose
a syntax error.  It will help OCaml understand that you want two definitions
to be syntactically separate.  After fixing whatever the underlying error is,
though, you can remove the `;;`.

One use case for `;;` is if you want to evaluate an expression as part of a
module:

```{code-cell} ocaml
module M = struct
  let x = 0;;
  assert (x = 0);;
end
```

But that can be rewritten without `;;` as:

```{code-cell} ocaml
module M = struct
  let x = 0
  let _ = assert (x = 0)
end
```

Structures can also be written on a single line, with optional `;;` between
items for readability:

```{code-cell} ocaml
module N = struct let x = 0 let y = 1 end
module O = struct let x = 0;; let y = 1 end
```

An empty structure is permitted:

```{code-cell} ocaml
module E = struct end
```

**Dynamic semantics.**

We already know that expressions are evaluated to values. Similarly, a module
expression is evaluated to a *module value* or just "module" for short. The only
interesting kind of module expression we have so far, from the perspective of
evaluation anyway, is the structure. Evaluation of structures is easy: just
evaluate each definition in it, in the order they occur. Because of that,
earlier definitions are therefore in scope in later definitions, but not vice
versa. So this module is fine:

```{code-cell} ocaml
module M = struct
  let x = 0
  let y = x
end
```

But this module is not, because at the time the `let` definition of `x` is
being evaluated, `y` has not yet been bound:

```{code-cell} ocaml
:tags: ["raises-exception"]
module M = struct
  let x = y
  let y = 0
end
```

Of course, mutual recursion can be used if desired:

```{code-cell} ocaml
module M = struct
  (* Requires: input is non-negative. *)
  let rec even = function 
    | 0 -> true 
    | n -> odd (n - 1)
  and odd = function 
    | 0 -> false 
    | n -> even (n - 1)
end
```

**Static semantics.**

A structure is well-typed if all the definitions in it are themselves
well-typed, according to all the typing rules we have already learned.

As we've seen in toplevel output, the module type of a structure is a signature.
There's more to module types than that, though. Let's put that off for a moment
to first talk about scope.

## Scope and Open

{{ video_embed | replace("%%VID%%", "GjlKfsY2nY8")}}

After a module `M` has been defined, you can access the names within it using
the dot operator. For example:

```{code-cell} ocaml
module M = struct let x = 42 end
```

```{code-cell} ocaml
M.x
```

Of course from outside the module the name `x` by itself is not meaningful:

```{code-cell} ocaml
:tags: ["raises-exception"]
x
```

But you can bring all of the definitions of a module into the current scope
using `open`:

```{code-cell} ocaml
open M
```

```{code-cell} ocaml
x
```

Opening a module is like writing a local definition for each name defined in the
module. For example, `open String` brings all the definitions from the
[String module][string] into scope, and has an effect similar to the following
on the local namespace:
```ocaml
let length = String.length
let get = String.get
let lowercase_ascii = String.lowercase_ascii
...
```

[string]: https://ocaml.org/api/String.html

If there are types, exceptions, or modules defined in a module, those also are
brought into scope with `open`.

**The Always-Open Module.**
There is a [special module called `Stdlib`][stdlib] that is automatically opened
in every OCaml program. It contains the "built-in" functions and operators. You
therefore never need to prefix any of the names it defines with `Stdlib.`,
though you could do so if you ever needed to unambiguously identify a name from
it. In earlier days, this module was named `Pervasives`, and you might still see
that name in some code bases.

[stdlib]: https://ocaml.org/api/Stdlib.html

**Open as a Module Item.**
An `open` is another sort of `module_item`. So we can open one module inside
another:

```{code-cell} ocaml
module M = struct
  open List

  (** [uppercase_all lst] upper-cases all the elements of [lst]. *)
  let uppercase_all = map String.uppercase_ascii
end
```

Since `List` is open, the name `map` from it is in scope.  But what if we wanted
to get rid of the `String.` as well?

```{code-cell} ocaml
:tags: ["raises-exception"]
module M = struct
  open List
  open String

  (** [uppercase_all lst] upper-cases all the elements of [lst]. *)
  let uppercase_all = map uppercase_ascii
end
```

Now we have a problem, because `String` also defines the name `map`, but with a
different type than `List`. As usual a later definition shadows an earlier one,
so it's `String.map` that gets chosen instead of `List.map` as we intended.

If you're using many modules inside your code, chances are you'll have at least
one collision like this. Often it will be with a standard higher-order function
like `map` that is defined in many library modules.

```{tip}
It is therefore generally good practice **not** to `open` all the modules you're
going to use at the top of a `.ml` file or structure. This is perhaps different
than how you're used to working with languages like Java, where you might
`import` many packages with `*`. Instead, it's good to restrict the scope in
which you open modules.
```

**Limiting the Scope of Open.**
We've already seen one way of limiting the scope of an open: `M.(e)`. Inside `e`
all the names from module `M` are in scope. This is useful for briefly using `M`
in a short expression:

```{code-cell} ocaml
(* remove surrounding whitespace from [s] and convert it to lower case *)
let s = "BigRed "
let s' = s |> String.trim |> String.lowercase_ascii (* long way *)
let s'' = String.(s |> trim |> lowercase_ascii) (* short way *)
```

But what if you want to bring a module into scope for an entire function, or
some other large block of code? The (admittedly strange) syntax for that is
`let open M in e`. It makes all the names from `M` be in scope in `e`. For
example:

```{code-cell} ocaml
(** [lower_trim s] is [s] in lower case with whitespace removed. *)
let lower_trim s =
  let open String in
  s |> trim |> lowercase_ascii
```

Going back to our `uppercase_all` example, it might be best to eschew any kind
of opening and simply to be explicit about which module we are using where:

```{code-cell} ocaml
module M = struct
  (** [uppercase_all lst] upper-cases all the elements of [lst]. *)
  let uppercase_all = List.map String.uppercase_ascii
end
```

## Module Type Definitions

{{ video_embed | replace("%%VID%%", "4Uew8GEegyg")}}

We've already seen that OCaml will infer a signature as the type of a module.
Let's now see how to write those modules types ourselves. As an example, here is
a module type for our list-based stacks:

```{code-cell} ocaml
module type LIST_STACK = sig
  exception Empty
  val empty : 'a list
  val is_empty : 'a list -> bool
  val push : 'a -> 'a list -> 'a list
  val peek : 'a list -> 'a
  val pop : 'a list -> 'a list
end
```

Now that we have both a module and a module type for list-based stacks, we
should move the specification comments from the structure into the signature.
Those comments are properly part of the specification of the names in the
signature. They specify behavior, thus augmenting the specification of types
provided by the `val` declarations.

```{code-cell} ocaml
:tags: [hide-output]
module type LIST_STACK = sig
  (** [Empty] is raised when an operation cannot be applied
      to an empty stack. *)
  exception Empty

  (** [empty] is the empty stack. *)
  val empty : 'a list

  (** [is_empty s] is whether [s] is empty. *)
  val is_empty : 'a list -> bool

  (** [push x s] pushes [x] onto the top of [s]. *)
  val push : 'a -> 'a list -> 'a list

  (** [peek s] is the top element of [s].
      Raises [Empty] if [s] is empty. *)
  val peek : 'a list -> 'a

  (** [pop s] is all but the top element of [s].
      Raises [Empty] if [s] is empty. *)
  val pop : 'a list -> 'a list
end

module ListStack = struct
  let empty = []

  let is_empty = function [] -> true | _ -> false

  let push x s = x :: s

  exception Empty

  let peek = function
    | [] -> raise Empty
    | x :: _ -> x

  let pop = function
    | [] -> raise Empty
    | _ :: s -> s
end
```

Nothing so far, however, tells OCaml that there is a relationship between
`LIST_STACK` and `ListStack`. If we want OCaml to ensure that `ListStack` really
does have the module type specified by `LIST_STACK`, we can add a type
annotation in the first line of the `module` definition:

```{code-cell} ocaml
module ListStack : LIST_STACK = struct
  let empty = []

  let is_empty = function [] -> true | _ -> false

  let push x s = x :: s

  exception Empty

  let peek = function
    | [] -> raise Empty
    | x :: _ -> x

  let pop = function
    | [] -> raise Empty
    | _ :: s -> s
end
```

The compiler agrees that the module `ListStack` does define all the items
specified by `LIST_STACK` with appropriate types.  If we had accidentally
omitted some item, the type annotation would have been rejected:

```{code-cell} ocaml
:tags: ["raises-exception"]
module ListStack : LIST_STACK = struct
  let empty = []

  let is_empty = function [] -> true | _ -> false

  let push x s = x :: s

  exception Empty

  let peek = function
    | [] -> raise Empty
    | x :: _ -> x

  (* [pop] is missing *)
end
```

**Syntax.**

The most common syntax for a module type is simply:

```ocaml
module type ModuleTypeName = sig
  specifications
end
```

where `specifications` inside a signature can include `val` declarations, type
definitions, exception definitions, and nested `module type` definitions. Like
structures, a signature can be written on many lines or just one line, and the
empty signature `sig end` is allowed.

But, as we saw with module definitions, a more accurate version of the syntax
would be:

```ocaml
module type ModuleTypeName = module_type
```

where a signature is just one sort of `module_type`. Another would be the name
of an already defined module type&mdash;e.g., `module type LS = LIST_STACK`.
We'll see other module types later in this section and chapter.

By convention, module type names are usually `CamelCase`, like module names. So
why did we use `ALL_CAPS` above for `LIST_STACK`? It was to avoid a possible
point of confusion in that example, which we now illustrate. We could instead
have used `ListStack` as the name of both the module and the module type:

```ocaml
module type ListStack = sig ... end
module ListStack : ListStack = struct ... end
```

In OCaml the namespaces for modules and module types are distinct, so it's
perfectly valid to have a module named `ListStack` and a module type named
`ListStack`. The compiler will not get confused about which you mean, because
they occur in distinct syntactic contexts. But as a human you might well get
confused by those seemingly overloaded names.

```{note}
The use of `ALL_CAPS` for module types was at one point common, and you might
see it still. It's an older convention from Standard ML. But the social
conventions of all caps have changed since those days. To modern readers, a name
like `LIST_STACK` might feel like your code is impolitely shouting at you. That
is a connotation that [evolved in the 1980s][all-caps]. Older programming
languages (e.g., Pascal, COBOL, FORTRAN) commonly used all caps for keywords and
even their own names. Modern languages still idiomatically use all caps for
constants&mdash;see, for example, Java's `Math.PI` or Python's
[style guide][python-caps].
```

[all-caps]: https://newrepublic.com/article/117390/netiquette-capitalization-how-caps-became-code-yelling

[python-caps]: https://www.python.org/dev/peps/pep-0008/#constants

**More Syntax.**

We should also add syntax now for module type annotations.  Module
definitions may include an optional type annotation:
```ocaml
module ModuleName : module_type = module_expression
```
And module expressions may include manual type annotations:
```ocaml
(module_expression : module_type)
```
That syntax is analogous to how we can write `(e : t)` to manually specify the
type `t` of an expression `e`.

Here are a few examples to show how that syntax can be used:

```{code-cell} ocaml
:tags: ["hide-output"]
module ListStackAlias : LIST_STACK = ListStack
(* equivalently *)
module ListStackAlias = (ListStack : LIST_STACK)

module M : sig val x : int end = struct let x = 42 end
(* equivalently *)
module M = (struct let x = 42 end : sig val x : int end)
```

And, module types can include nested module specifications:

```{code-cell} ocaml
:tags: ["hide-output"]
module type X = sig
  val x : int
end

module type T = sig
  module Inner : X
end

module M : T = struct
  module Inner : X = struct
    let x = 42
  end
end
```

In the example above, `T` specifies that there must be an inner module named
`Inner` whose module type is `X`. Here, the type annotation is mandatory,
because otherwise nothing would be known about `Inner`. In implementing `T`,
module `M` therefore has to provide a module (i) with that name, which also (ii)
meets the specifications of module type `X`.

**Dynamic semantics.**

Since module types are in fact types, they are not evaluated. They have no
dynamic semantics.

**Static semantics.**

Earlier in this section we delayed discussing the static semantics of module
expressions. Now that we have learned about module types, we can return to that
discussion.  We do so, next, in its own section, because the discussion will
be lengthy.

## Module Type Semantics

{{ video_embed | replace("%%VID%%", "VprvFk7KKWk")}}

If `M` is just a `struct` block, its module type is whatever signature the
compiler infers for it. But that can be changed by module type annotations. The
key question we have to answer is: what does a type annotation mean for modules?
That is, what does it mean when we write the `: T` in `module M : T = ...`?

There are two properties the compiler guarantees:

  1. *Signature matching:* every name declared in `T` is defined in `M` at the
      same or a more general type.

  2. *Opacity:* any name defined in `M` that does not appear in `T` is not
     visible to code outside of `M`.

But a more complete answer turns out to involve *subtyping*, which is a concept
you've probably seen before in an object-oriented language. We're going to take
a brief detour into that realm now, then come back to OCaml and modules.

In Java, the `extends` keyword creates subtype relationships between classes:

```java
class C { }
class D extends C { }

D d = new D();
C c = d;
```

Subtyping is what permits the assignment of `d` to `c` on the last line of that
example. Because `D` extends `C`, Java considers `D` to be a subtype of `C`, and
therefore permits an object instantiated from `D` to be used any place where an
object instantiated from `C` is expected. It's up to the programmer of `D` to
ensure that doesn't lead to any run-time errors, of course. The methods of `D`
have to ensure that class invariants of `C` hold, for example. So by writing
`D extends C`, the programmer is taking on some responsibility, and in turn
gaining some flexibility by being able to write such assignment statements.

So what is a "subtype"? That notion is in many ways dependent on the language.
For a language-independent notion, we turn to Barbara Liskov. She won the Turing
Award in 2008 in part for her work on object-oriented language design. Twenty
years before that, she invented what is now called the *Liskov Substitution
Principle* to explain subtyping. It says that if `S` is a subtype of `T`, then
substituting an object of type `S` for an object of type `T` should not change
any desirable behaviors of a program. You can see that at work in the Java
example above, both in terms of what the language allows and what the programmer
must guarantee.

The particular flavor of subtyping in Java is called *nominal subtyping*, which
is to say, it is based on names. In our example, `D` is a subtype of `C` just
because of the way the names were declared. The programmer decreed that subtype
relationship, and the language accepted the decree without question. Indeed, the
*only* subtype relationships that exist are those that have been decreed by name
through such uses of `extends` and `implements`.

Now it's time to return to OCaml. Its module system also uses subtyping, with
the same underlying intuition about the Liskov Substitution Principle. But OCaml
uses a different flavor called *structural subtyping*. That is, it is based on
the structure of modules rather than their names. "Structure" here simply means
the definitions contained in the module. Those definitions are used to determine
whether `(M : T)` is acceptable as a type annotation, where `M` is a module and
`T` is a module type.

Let's play with this idea of structure through several examples, starting with
this module:

```{code-cell} ocaml
module M = struct
  let x = 0
  let z = 2
end
```

Module `M` contains two definitions. You can see those in the signature for
the module that OCaml outputs: it contains `x : int` and `z : int`.  Because
of the former, the module type annotation below is accepted:

```{code-cell} ocaml
module type X = sig
  val x : int
end

module MX = (M : X)
```

Module type `X` requires a module item named `x` with type `int`.  Module `M`
does contain such an item.  So `(M : X)` is valid.  The same would work
for `z`:

```{code-cell} ocaml
module type Z = sig
  val z : int
end

module MZ = (M : Z)
```

Or for both `x` and `z`:

```{code-cell} ocaml
module type XZ = sig
  val x : int
  val z : int
end

module MXZ = (M : XZ)
```

But not for `y`, because `M` contains no such item:

```{code-cell} ocaml
:tags: ["raises-exception"]
module type Y = sig
  val y : int
end

module MY = (M : Y)
```

Take a close look at that error message. Learning to read such errors on small
examples will help you when they appear in large bodies of code. OCaml is
comparing two signatures, corresponding to the two expressions on either side of
the colon in `(M : Y)`. The line

```ocaml
sig val x : int val z : int end
```

is the signature that OCaml is using for `M`. Since `M` is a module, that
signature is just the names and types as they were defined in `M`. OCaml
compares that signature to `Y`, and discovers a mismatch:

```text
The value `y' is required but not provided
```

That's because `Y` requires `y` but `M` provides no such definition.

Here's another error message to practice reading:

```{code-cell} ocaml
:tags: ["raises-exception"]
module type Xstring = sig
  val x : string
end

module MXstring = (M : Xstring)
```

This time the error is

```text
Values do not match: val x : int is not included in val x : string
```

The error changed, because `M` does provide a definition of `x`, but at a
different type than `Xstring` requires. That's what "is not included in" means
here. So why doesn't OCaml say something a little more straightforward, like "is
not the same as"? It's because the types do not have to be exactly the same. If
the provided value's type is polymorphic, it suffices for the required value's
type to be an instantiation of that polymorphic type.

For example, if a signature requires a type `int -> int`, it suffices for a
structure to provide a value of type `'a -> 'a`:

```{code-cell} ocaml
:tags: ["raises-exception"]
module type IntFun = sig
  val f : int -> int
end

module IdFun = struct
  let f x = x
end

module Iid = (IdFun : IntFun)
```

So far all these examples were just a matter of comparing the definitions
required by a signature to the definitions provided by a structure. But here's
an example that might be surprising:

```{code-cell} ocaml
:tags: ["raises-exception"]
module MXZ' = ((M : X) : Z)
```

Why does OCaml complain that `z` is required but not provided? We know from the
definition of `M` that it indeed does have a value `z : int`.  Yet the
error message perhaps strangely claims:

```text
The value `z' is required but not provided.
```

The reason for this error is that we've already supplied the type annotation
`X` in the module expression `(M : X)`.  That causes the module expression
to be known only at the module type `X`.  In other words, we've forgotten
irrevocably about the existence of `z` after that annotation.  All that is
known is that the module has items required by `X`.

After all those examples, here are the static semantics of module type
annotations:

- Module type annotation `(M : T)` is valid if the module type of `M` is a
  subtype of `T`. The module type of `(M : T)` is then `T` in any further type
  checking.

- Module type `S` is a subtype of `T` if the set of definitions in `S` is a
  superset of those in `T`.  Definitions in `T` are permitted to instantiate
  type variables from `S`.

The "sub" vs. "super" in the second rule is not a typo. Consider these module
types and modules:

```{code-cell} ocaml
module type T = sig
  val a : int
end

module type S = sig
  val a : int
  val b : bool
end

module A = struct
  let a = 0
end

module AB = struct
  let a = 0
  let b = true
end

module AC = struct
  let a = 0
  let c = 'c'
end
```

Module type `S` provides a *super*set of the definitions in `T`, because it adds
a definition of `b`. So why is `S` called a *sub*type of `T`? Think about the
set $\mathit{Type}(T)$ of all module values `M` such that `M : T`. That set
contains `A`, `AB`, `AC`, and many others. Also think about the set
$\mathit{Type}(S)$ of all module values `M` such that `M : S`. That set contains
`AB` but not `A` nor `AC`. So $\mathit{Type}(S) \subset \mathit{Type}(T)$,
because there are some module values that are in $\mathit{Type}(T)$ but not in
$\mathit{Type}(S)$.

As another example, a module type `StackHistory` for stacks might customize our
usual `Stack` signature by adding an operation `history : 'a t -> int` to return
how many items have ever been pushed on the stack in its history. That `history`
operation makes the set of definitions in `StackHistory` bigger than the set in
`Stack`, hence the use of "superset" in the rule above. But the set of module
values that implement `StackHistory` is smaller than the set of module values
that implement `Stack`, hence the use of "subset".

## Module Types are Static

Decisions about validity of module type annotations are made at compile time
rather than run time.

```{important}
Module type annotations therefore offer potential confusion to programmers
accustomed to object-oriented languages, in which subtyping works differently.
```

Python programmers, for example, are accustomed to so-called "duck typing". They
might expect `((M : X) : Z)` to be valid, because `z` does exist at run-time in
`M`. But in OCaml, the compile-time type of `(M : X)` has hidden `z` from view
irrevocably.

Java programmers, on the other hand, might expect that module type annotations
work like type casts. So it might seem valid to first "cast" `M` to `X` then to
`Z`. In Java such type casts are checked, as needed, at run time. But OCaml
module type annotations are static. Once an annotation of `X` is made, there is
no way to check at compile time what other items might exist in the
module&mdash;that would require a run-time check, which OCaml does not permit.

In both cases it might feel as though OCaml is being too restrictive. Maybe. But
in return for that restrictiveness, OCaml is guaranteeing an **absence of
run-time errors** of the kind that would occur in Java or Python, whether
because of a run-time error from a cast, or a run-time error from a missing
method.

## First-Class Modules

Modules are not as first-class in OCaml as functions. But it is possible to
*package* modules as first-class values. Briefly:

- `(module M : T)` packages module `M` with module type `T` into a value.
- `(val e : T)` un-packages `e` into a module with type `T`.

We won't cover this much further, but if you're curious you can have a look at
[the manual][firstclassmodules].

[firstclassmodules]: https://ocaml.org/manual/firstclassmodules.html
