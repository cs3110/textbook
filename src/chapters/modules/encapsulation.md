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

# Encapsulation

One of the main concerns of a module system is to provide *encapsulation*: the
hiding of information about implementation behind an interface. OCaml's module
system makes this possible with a feature we've already seen: the *opacity* that
module type annotations create. One special use of opacity is the declaration of
*abstract types*. We'll study both of those ideas in this section.

## Opacity

When implementing a module, you might sometimes have helper functions that you
don't want to expose to clients of the module.  For example, maybe you're
implementing a math module that provides a tail-recursive factorial function:

```{code-cell} ocaml
module Math = struct
  (** [fact_aux n acc] is [n! * acc]. *)
  let rec fact_aux n acc =
    if n = 0 then acc else fact_aux (n - 1) (n * acc)

  (** [fact n] is [n!]. *)
  let fact n = fact_aux n 1
end
```

You'd like to make `fact` usable by clients of `Math`, but you'd also like to
keep `fact_aux` hidden. But in the code above, you can see that `fact_aux` is
visible in the signature inferred for `Math`. One way to hide it is simply to
nest `fact_aux`:

```{code-cell} ocaml
module Math = struct
  (** [fact n] is [n!]. *)
  let fact n =
    (** [fact_aux n acc] is [n! * acc]. *)
    let rec fact_aux n acc =
      if n = 0 then acc else fact_aux (n - 1) (n * acc)
    in
    fact_aux n 1
end
```

Look at the signature, and notice how `fact_aux` is gone. But, that nesting
makes `fact` just a little harder to read. It also means `fact_aux` is not
available for any other functions *inside* `Math` to use. In this case that's
probably fine&mdash;there probably aren't any other functions in `Math` that
need `fact_aux`. But if there were, we couldn't nest `fact_aux`.

So another way to hide `fact_aux` from clients of `Math`, while still leaving it
available for implementers of `Math`, is to use a module type that exposes only
those names that clients should see:

```{code-cell} ocaml
module type MATH = sig
  (** [fact n] is [n!]. *)
  val fact : int -> int
end

module Math : MATH = struct
  (** [fact_aux n acc] is [n! * acc]. *)
  let rec fact_aux n acc =
    if n = 0 then acc else fact_aux (n - 1) (n * acc)

  let fact n = fact_aux n 1
end
```

Now since `MATH` does not mention `fact_aux`, the module type annotation
`Math : MATH` causes `fact_aux` to be hidden:

```{code-cell} ocaml
:tags: ["raises-exception"]
Math.fact_aux
```

In that sense, module type annotations are *opaque*: they can prevent visibility
of module items. We say that the module type *seals* the module, making any
components not named in the module type be inaccessible.

```{important}
Remember that module type annotations are therefore not *only* about checking to
see whether a module defines certain items. The annotations also hide items.
```

What if you did want to just check the definitions, but not hide anything?
Then don't supply the annotation at the time of module definition:

```{code-cell} ocaml
module type MATH = sig
  (** [fact n] is [n!]. *)
  val fact : int -> int
end

module Math = struct
  (** [fact_aux n acc] is [n! * acc]. *)
  let rec fact_aux n acc =
    if n = 0 then acc else fact_aux (n - 1) (n * acc)

  let fact n = fact_aux n 1
end

module MathCheck : MATH = Math
```

Now `Math.fact_aux` is visible, but `MathCheck.fact_aux` is not:

```{code-cell} ocaml
Math.fact_aux
```

```{code-cell} ocaml
:tags: ["raises-exception"]
MathCheck.fact_aux
```

You wouldn't even have to give the "check" module a name since you probably
never intend to access it; you could instead leave it anonymous:

```{code-cell} ocaml
module _ : MATH = Math
```

**A Comparison to Visibility Modifiers.** The use of sealing in OCaml is thus
similar to the use of visibility modifiers such as `private` and `public` in
Java. In fact one way to think about Java class definitions is that they
simultaneously define multiple signatures.

For example, consider this Java class:
```java
class C {
  private int x;
  public int y;
}
```

An analogy to it in OCaml would be the following modules and types:

```{code-cell} ocaml
module type C_PUBLIC = sig
  val y : int
end

module CPrivate = struct
  let x = 0
  let y = 0
end

module C : C_PUBLIC = CPrivate
```

With those definitions, any code that uses `C` will have access only to the
names exposed in the `C_PUBLIC` module type.

That analogy can be extended to the other visibility modifiers, `protected` and
default, as well. Which means that Java classes are effectively defining four
related types, and the compiler is making sure the right type is used at each
place in the code base `C` is named. No wonder it can be challenging to master
visibility in OO languages at first.

## Abstract Types

{{ video_embed | replace("%%VID%%", "vuKBUhMpr-c")}}

In an earlier section we implemented stacks as lists with the following
module and type:

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

module ListStack : LIST_STACK = struct
  exception Empty
  let empty = []
  let is_empty = function [] -> true | _ -> false
  let push x s = x :: s
  let peek = function [] -> raise Empty | x :: _ -> x
  let pop = function [] -> raise Empty | _ :: s -> s
end
```

What if we wanted to modify that data structure to add an operation for
the size of the stack?  The easy way would be to implement it using
`List.length`:

```ocaml
module type LIST_STACK = sig
  ...
  (** [size s] is the number of elements on the stack. *)
  val size : 'a list -> int
end

module ListStack : LIST_STACK = struct
  ...
  let size = List.length
end
```

That results in a linear-time implementation of `size`. What if we wanted a
faster, constant-time implementation? At the cost of a little space, we could
cache the size of the stack. Let's now represent the stack as a pair, where the
first component of the pair is the same list as before, and the second component
of the pair is the size of the stack:

```{code-cell} ocaml
:tags: ["hide-output"]
module ListStackCachedSize = struct
  exception Empty
  let empty = ([], 0)
  let is_empty = function ([], _) -> true | _ -> false
  let push x (stack, size) = (x :: stack, size + 1)
  let peek = function ([], _) -> raise Empty | (x :: _, _) -> x
  let pop = function
    | ([], _) -> raise Empty
    | (_ :: stack, size) -> (stack, size - 1)
end
```

We have a big problem.  `ListStackCachedSize` does not implement the
`LIST_STACK` module type, because that module type specifies `'a list`
throughout it to represent the stack&mdash;not `'a list * int`.

```{code-cell} ocaml
:tags: ["raises-exception"]
module CheckListStackCachedSize : LIST_STACK = ListStackCachedSize
```

Moreover, any code we previously wrote using `ListStack` now has to be modified
to deal with the pair, which could mean revising pattern matches, function
types, and so forth.

As you no doubt learned in earlier programming courses, the problem we are
encountering here is a lack of encapsulation. We should have kept the type that
implements `ListStack` hidden from clients. In Java, for example, we might have
written:

```java
class ListStack<T> {
  private List<T> stack;
  private int size;
  ...
}
```

That way clients of `ListStack` would be unaware of `stack` or `size`.  In fact,
they wouldn't be able to name those fields at all.  Instead, they would
just use `ListStack` as the type of the stack:

```java
ListStack<Integer> s = new ListStack<>();
s.push(1);
```

So in OCaml, how can we keep the *representation type* of the stack hidden? What
we learned about opacity and sealing thus far does not suffice. The problem is
that the type `'a list * int` literally appears in the signature of
`ListStackCachedSize`, e.g., in `push`:

```{code-cell} ocaml
ListStackCachedSize.push
```

A module type annotation could hide one of the values defined in
`ListStackCachedSize`, e.g., `push` itself, but that doesn't solve the problem:
we need to **hide the type** `'a list * int` while **exposing the operation**
`push`. So OCaml has a feature for doing exactly that: *abstract types*.
Let's see an example of this feature.

We begin by modifying `LIST_STACK`, replacing `'a list` with a new type
`'a stack` everywhere. We won't repeat the specification comments here, so as to
keep the example shorter. And while we're at it, let's add the `size` operation.

```{code-cell} ocaml
:tags: [hide-output]
module type LIST_STACK = sig
  type 'a stack
  exception Empty
  val empty : 'a stack
  val is_empty : 'a stack -> bool
  val push : 'a -> 'a stack -> 'a stack
  val peek : 'a stack -> 'a
  val pop : 'a stack -> 'a stack
  val size : 'a stack -> int
end
```

Note how `'a stack` is not actually defined in that signature. We haven't said
anything about what it is. It might be `'a list`, or `'a list * int`, or
`{stack : 'a list; size : int}`, or anything else. That is what makes it an
*abstract* type: we've declared its name but not specified its definition.

Now `ListStackCachedSize` can implement that module type with the addition
of just one line of code: the first line of the structure, which defines
`'a stack`:

```{code-cell} ocaml
module ListStackCachedSize : LIST_STACK = struct
  type 'a stack = 'a list * int
  exception Empty
  let empty = ([], 0)
  let is_empty = function ([], _) -> true | _ -> false
  let push x (stack, size) = (x :: stack, size + 1)
  let peek = function ([], _) -> raise Empty | (x :: _, _) -> x
  let pop = function
    | ([], _) -> raise Empty
    | (_ :: stack, size) -> (stack, size - 1)
  let size = snd
end
```

Take a careful look at the output: nowhere does `'a list` show up in it. In
fact, only `LIST_STACK` does. And `LIST_STACK` mentions only `'a stack`. So no
one's going to know that internally a list is used. (Ok, they're going to know:
the name suggests it. But the point is they can't take advantage of that,
because the type is abstract.)

Likewise, our original implementation with linear-time `size` satisfies
the module type.  We just have to add a line to define `'a stack`:

```{code-cell} ocaml
module ListStack : LIST_STACK = struct
  type 'a stack = 'a list
  exception Empty
  let empty = []
  let is_empty = function [] -> true | _ -> false
  let push x s = x :: s
  let peek = function [] -> raise Empty | x :: _ -> x
  let pop = function [] -> raise Empty | _ :: s -> s
  let size = List.length
end
```

Note that omitting that added line would result in an error, just as if
we had failed to define `push` or any of the other operations from
the module type:

```{code-cell} ocaml
:tags: ["raises-exception"]
module ListStack : LIST_STACK = struct
  (* type 'a stack = 'a list *)
  exception Empty
  let empty = []
  let is_empty = function [] -> true | _ -> false
  let push x s = x :: s
  let peek = function [] -> raise Empty | x :: _ -> x
  let pop = function [] -> raise Empty | _ :: s -> s
  let size = List.length
end
```

Here is a third, custom implementation of `LIST_STACK`. This one is deliberately
overly-complicated, in part to illustrate how the abstract type can hide
implementation details that are better not revealed to clients:

```{code-cell} ocaml
module CustomStack : LIST_STACK = struct
  type 'a entry = {top : 'a; rest : 'a stack; size : int}
  and 'a stack = S of 'a entry option
  exception Empty
  let empty = S None
  let is_empty = function S None -> true | _ -> false
  let size = function S None -> 0 | S (Some {size}) -> size
  let push x s = S (Some {top = x; rest = s; size = size s + 1})
  let peek = function S None -> raise Empty | S (Some {top}) -> top
  let pop = function S None -> raise Empty | S (Some {rest}) -> rest
end
```

Is that really a "list" stack? It satisfies the module type `LIST_STACK`. But
upon reflection, that module type never really had anything to do with lists
once we made the type `'a stack` abstract. There's really no need to call it
`LIST_STACK`. We'd be better off using just `STACK`, since it can be implemented
with `list` or without. At that point, we could just go with `Stack` as its
name, since there is no module named `Stack` we've written that would be
confused with it. That avoids the all-caps look of our code shouting at us.

```{code-cell} ocaml
:tags: [hide-output]
module type Stack = sig
  type 'a stack
  exception Empty
  val empty : 'a stack
  val is_empty : 'a stack -> bool
  val push : 'a -> 'a stack -> 'a stack
  val peek : 'a stack -> 'a
  val pop : 'a stack -> 'a stack
  val size : 'a stack -> int
end

module ListStack : Stack = struct
  type 'a stack = 'a list
  exception Empty
  let empty = []
  let is_empty = function [] -> true | _ -> false
  let push x s = x :: s
  let peek = function [] -> raise Empty | x :: _ -> x
  let pop = function [] -> raise Empty | _ :: s -> s
  let size = List.length
end
```

There's one further naming improvement we could make. Notice the type of
`ListStack.empty` (and don't worry about the `abstr` part for now; we'll come
back to it):

```{code-cell} ocaml
ListStack.empty
```

That type, `'a ListStack.stack`, is rather unwieldy, because it conveys the word
"stack" twice: once in the name of the module, and again in the name of the
representation type inside that module. In places like this, OCaml programmers
idiomatically use a standard name, `t`, in place of a longer representation type
name:

```{code-cell} ocaml
:tags: [hide-output]
module type Stack = sig
  type 'a t
  exception Empty
  val empty : 'a t
  val is_empty : 'a t -> bool
  val push : 'a -> 'a t -> 'a t
  val peek : 'a t -> 'a
  val pop : 'a t -> 'a t
  val size : 'a t -> int
end

module ListStack : Stack = struct
  type 'a t = 'a list
  exception Empty
  let empty = []
  let is_empty = function [] -> true | _ -> false
  let push x s = x :: s
  let peek = function [] -> raise Empty | x :: _ -> x
  let pop = function [] -> raise Empty | _ :: s -> s
  let size = List.length
end

module CustomStack : Stack = struct
  type 'a entry = {top : 'a; rest : 'a t; size : int}
  and 'a t = S of 'a entry option
  exception Empty
  let empty = S None
  let is_empty = function S None -> true | _ -> false
  let size = function S None -> 0 | S (Some {size}) -> size
  let push x s = S (Some {top = x; rest = s; size = size s + 1})
  let peek = function S None -> raise Empty | S (Some {top}) -> top
  let pop = function S None -> raise Empty | S (Some {rest}) -> rest
end
```

Now the type of stacks is simpler:

```{code-cell} ocaml
ListStack.empty;;
CustomStack.empty;;
```

That idiom is fairly common when there's a single representation type exposed by
an interface to a data structure. You'll see it used throughout the standard
library.

In informal conversation we would usually pronounce those types without the "dot
t" part. For example, we might say "alpha ListStack", simply ignoring the
`t`&mdash;though it does technically have to be there to be legal OCaml code.

Finally, abstract types are really just a special case of opacity. You actually
can expose the definition of a type in a signature if you want to:

```{code-cell} ocaml
module type T = sig
  type t = int
  val x : t
end

module M : T = struct
  type t = int
  let x = 42
end

let a : int = M.x
```

Note how we're able to use `M.x` at its type of `int`.  That works because
the equality of types `t` and `int` has been exposed in the module type.
But if we kept `t` abstract, the same usage would fail:

```{code-cell} ocaml
:tags: ["raises-exception"]
module type T = sig
  type t (* = int *)
  val x : t
end

module M : T = struct
  type t = int
  let x = 42
end

let a : int = M.x
```

We're not allowed to use `M.x` at type `int` outside of `M`, because its type
`M.t` is abstract. This is encapsulation at work, keeping that implementation
detail hidden.

## Pretty Printing

In some output above, we observed something curious: the toplevel prints
`<abstr>` in place of the actual contents of a value whose type is abstract:

```{code-cell} ocaml
ListStack.empty;;
ListStack.(empty |> push 1 |> push 2);;
```

Recall that the toplevel uses this angle-bracket convention to indicate an
unprintable value. We've encountered that before with functions and `<fun>`:

```{code-cell} ocaml
fun x -> x
```

On the one hand, it's reasonable for the toplevel to behave this way. Once a
type is abstract, its implementation isn't meant to be revealed to clients. So
actually printing out the list `[]` or `[2; 1]` as responses to the above inputs
would be revealing more than is intended.

On the other hand, it's also reasonable for implementers to provide clients with
a friendly way to view a value of an abstract type. Java programmers, for
example, will often write `toString()` methods so that objects can be printed
as output in the terminal or in JShell.  To support that, the OCaml toplevel
has a directive `#install_printer`, which registers a function to print values.
Here's how it works.

- You write a *pretty printing* function of type
  `Format.formatter -> t -> unit`, for whatever type `t` you like. Let's suppose
  for sake of example that you name that function `pp`.

- You invoke `#install_printer pp` in the toplevel.

- From now on, anytime the toplevel wants to print a value of type `t` it uses
  your function `pp` to do so.

It probably makes sense the pretty printing function needs to take in a value of
type `t` (because that's what it needs to print) and returns `unit` (as other
printing functions do). But why does it take the `Format.formatter` argument?
It's because of a fairly high-powered feature that OCaml is attempting to
provide here: automatic line breaking and indentation in the middle of very
large outputs.

Consider the output from this expression, which creates nested lists:

```{code-cell} ocaml
List.init 15 (fun n -> List.init n (Fun.const n))
```

Each inner list contains `n` copies of the number `n`. Note how the indentation
and line breaks are somewhat sophisticated. All the inner lists are indented one
space from the left-hand margin. Line breaks have been inserted to avoid
splitting inner lists over multiple lines.

The `Format` module is what provides this functionality, and `Format.formatter`
is an abstract type in it. You could think of a formatter as being a place to
send output, like a file, and have it be automatically formatted along the way.
The typical use of a formatter is as argument to a function such as
`Format.fprintf`, which like `Printf` uses format specifiers.

For example, suppose you wanted to change how strings are printed by the
toplevel and add " kupo" to the end of each string. Here's code that would do
it:

```{code-cell} ocaml
let kupo_pp fmt s = Format.fprintf fmt "%s kupo" s;;
#install_printer kupo_pp;;
```

Now you can see that the toplevel adds " kupo" to each string while printing it,
even though it's not actual a part of the original string:

```{code-cell} ocaml
let h = "Hello"
let s = String.length h
```

To keep ourselves from getting confused about strings in the rest of this
section, let's uninstall that pretty printer before going on:

```{code-cell} ocaml
#remove_printer kupo_pp;;
```

As a bigger example, let's add pretty printing to `ListStack`:

```{code-cell} ocaml
:tags: ["hide-output"]
module type Stack = sig
  type 'a t
  exception Empty
  val empty : 'a t
  val is_empty : 'a t -> bool
  val push : 'a -> 'a t -> 'a t
  val peek : 'a t -> 'a
  val pop : 'a t -> 'a t
  val size : 'a t -> int
  val pp :
    (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a t -> unit
end
```

First, notice that we have to expose `pp` as part of the module type.
Otherwise it would be encapsulated, hence we wouldn't be able to install it.
Second, notice that the type of `pp` now takes an extra first argument
of type `Format.formatter -> 'a -> unit`.  That is itself a pretty printer
for type `'a`, on which `t` is parameterized.  We need that argument in order
to be able to pretty print the values of type `'a`.

```{code-cell} ocaml
:tags: ["hide-output"]
module ListStack : Stack = struct
  type 'a t = 'a list
  exception Empty
  let empty = []
  let is_empty = function [] -> true | _ -> false
  let push x s = x :: s
  let peek = function [] -> raise Empty | x :: _ -> x
  let pop = function [] -> raise Empty | _ :: s -> s
  let size = List.length
  let pp pp_val fmt s =
    let open Format in
    let pp_break fmt () = fprintf fmt "@," in
    fprintf fmt "@[<v 0>top of stack";
    if s <> [] then fprintf fmt "@,";
    pp_print_list ~pp_sep:pp_break pp_val fmt s;
    fprintf fmt "@,bottom of stack@]"
end
```

In `ListStack.pp`, we use some of the advanced features of the `Format` module.
Function `Format.pp_print_list` does the heavy lifting to print all the elements
of the stack. The rest of the code handles the indentation and line breaks.
Here's the result:

```{code-cell} ocaml
#install_printer ListStack.pp
```

```{code-cell} ocaml
ListStack.empty
```

```{code-cell} ocaml
ListStack.(empty |> push 1 |> push 2)
```

For more information, see the [toplevel manual][toplevel] (search for
`#install_printer`), the [Format module][format], and this
[OCaml GitHub issue][poly-printer]. The latter seems to be the only place that
documents the use of extra arguments, as in `pp_val` above, to print values of
polymorphic types.

[toplevel]: https://ocaml.org/manual/toplevel.html
[format]: https://ocaml.org/api/Format.html
[poly-printer]: https://github.com/ocaml/ocaml/issues/5958
