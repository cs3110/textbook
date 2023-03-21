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

# Refs

{{ video_embed | replace("%%VID%%", "R0tGac0jaEQ")}}

A *ref* is like a pointer or reference in an imperative language. It is a
location in memory whose contents may change. Refs are also called *ref cells*,
the idea being that there's a cell in memory that can change.

Here's an example of creating a ref, getting the value from inside it, changing
its contents, and observing the changed contents:

```{code-cell} ocaml
let x = ref 0;;
```
```{code-cell} ocaml
!x;;
```
```{code-cell} ocaml
x := 1;;
```
```{code-cell} ocaml
!x;;
```

The first phrase, `let x = ref 0`, creates a reference using the `ref` keyword.
That's a location in memory whose contents are initialized to `0`. Think of the
location itself as being an address&mdash;for example, 0x3110bae0&mdash;even
though there's no way to write down such an address in an OCaml program. The
keyword `ref` is what causes the memory location to be allocated and
initialized.

The first part of the response from OCaml, `val x : int ref`, indicates that `x`
is a variable whose type is `int ref`. We have a new type constructor here. Much
like `list` and `option` are type constructors, so is `ref`. A `t ref`, for any
type `t`, is a reference to a memory location that is guaranteed to contain a
value of type `t`. As usual we should read a type from right to left: `t ref`
means a reference to a `t`. The second part of the response shows us the
contents of the memory location. Indeed, the contents have been initialized to
`0`.

The second phrase, `!x`, dereferences `x` and returns the contents of the memory
location. Note that `!` is the dereference operator in OCaml, not Boolean
negation.

The third phrase, `x := 1`, is an assignment. It mutates the contents `x` to be
`1`. Note that `x` itself still points to the same location (i.e., address) in
memory. Memory is mutable; variable bindings are not. What changes is the
contents. The response from OCaml is simply `()`, meaning that the assignment
took place&mdash;much like printing functions return `()` to indicate that the
printing did happen.

The fourth phrase, `!x` again dereferences `x` to demonstrate that the contents
of the memory location did indeed change.

## Aliasing

{{ video_embed | replace("%%VID%%", "pt06BxGhjDQ")}}

Now that we have refs, we have *aliasing*: two refs could point to the same
memory location, hence updating through one causes the other to also be updated.
For example,

```{code-cell} ocaml
let x = ref 42;;
let y = ref 42;;
let z = x;;
x := 43;;
let w = !y + !z;;
```

The result of executing that code is that `w` is bound to `85`, because
`let z = x` causes `z` and `x` to become aliases, hence updating `x` to be `43`
also causes `z` to be `43`.

## Syntax and Semantics

{{ video_embed | replace("%%VID%%", "ByV1N3hDgSw")}}

The semantics of refs is based on *locations* in memory. Locations are values
that can be passed to and returned from functions. But unlike other values
(e.g., integers, variants), there is no way to directly write a location in an
OCaml program. That's different than languages like C, in which programmers can
directly write memory addresses and do arithmetic on pointers. C programmers
want that kind of low-level access to do things like interfacing with hardware
and building operating systems. Higher-level programmers are willing to forego
it to get *memory safety*. That's a hard term to define, but according to
[Hicks 2014][memory-safety-hicks] it intuitively means that

* pointers are only created in a safe way that defines their legal memory
  region,

* pointers can only be dereferenced if they point to their allotted memory
  region,

* that region is (still) defined.

[memory-safety-hicks]: http://www.pl-enthusiast.net/2014/07/21/memory-safety/

**Syntax.**

* Ref creation: `ref e`

* Ref assignment: `e1 := e2`

* Dereference: `!e`

**Dynamic semantics.**

* To evaluate `ref e`,

  - Evaluate `e` to a value `v`

  - Allocate a new location `loc` in memory to hold `v`

  - Store `v` in `loc`

  - Return `loc`

* To evaluate `e1 := e2`,

  - Evaluate `e2` to a value `v`, and `e1` to a location `loc`.

  - Store `v` in `loc`.

  - Return `()`, i.e., unit.

* To evaluate `!e`,

  - Evaluate `e` to a location `loc`.

  - Return the contents of `loc`.

**Static semantics.**

We have a new type constructor, `ref`, such that `t ref` is a type for any type
`t`. Note that the `ref` keyword is used in two ways: as a type constructor, and
as an expression that constructs refs.

* `ref e : t ref` if  `e : t`.

* `e1 := e2 : unit` if `e1 : t ref` and `e2 : t`.

* `!e : t` if `e : t ref`.

## Sequencing of Effects

{{ video_embed | replace("%%VID%%", "aj0bpOyv7Gs")}}

The semicolon operator is used to sequence effects, such as mutating refs. We've
seen semicolon occur previously with printing. Now that we're studying
mutability, it's time to treat it formally.

* **Syntax:** `e1; e2`

* **Dynamic semantics:** To evaluate `e1; e2`,

  - First evaluate `e1` to a value `v1`.

  - Then evaluate `e2` to a value `v2`.

  - Return `v2`.  (`v1` is not used at all.)

  - If there are multiple expressions in a sequence, e.g., `e1; e2; ...; en`,
    then evaluate each one in order from left to right, returning only `vn`.

* **Static semantics:** `e1; e2 : t` if `e1 : unit` and `e2 : t`. Similarly,
  `e1; e2; ...; en : t` if `e1 : unit`, `e2 : unit`, ... (i.e., all expressions
  except `en` have type `unit`), and `en : t`.

The typing rule for semicolon is designed to prevent programmer mistakes. For
example, a programmer who writes `2+3; 7` probably didn't mean to: there's no
reason to evaluate `2+3` then throw away the result and instead return `7`. The
compiler will give you a warning if you violate this particular typing rule.

To get rid of the warning (if you're sure that's what you need to do), there's a
function `ignore : 'a -> unit` in the standard library. Using it,
`ignore(2+3); 7` will compile without a warning. Of course, you could code up
`ignore` yourself: `let ignore _ = ()`.

## Example: Mutable Counter

{{ video_embed | replace("%%VID%%", "o5wFQvCRJsc")}}

Here is code that implements a *counter*. Every time `next_val` is called, it
returns one more than the previous time.

```{code-cell} ocaml
let counter = ref 0

let next_val =
  fun () ->
    counter := !counter + 1;
    !counter
```

```{code-cell} ocaml
next_val ()
```

```{code-cell} ocaml
next_val ()
```

```{code-cell} ocaml
next_val ()
```

In the implementation of `next_val`, there are two expressions separated by
semi-colon. The first expression, `counter := !counter + 1`, is an assignment
that increments `counter` by 1. The second expression, `!counter`, returns the
newly incremented contents of `counter`.

The `next_val` function is unusual in that every time we call it, it returns a
different value. That's quite different than any of the functions we've
implemented ourselves so far, which have always been *deterministic*: for a
given input, they always produced the same output. On the other hand, we've seen
some library functions that are *nondeterministic*, for example, functions in
the `Random` module, and `Stdlib.read_line`. It's no coincidence that those
happen to be implemented using mutable features.

We could improve our counter in a couple ways. First, there is a library
function `incr : int ref -> unit` that increments an `int ref` by 1. Thus it is
like the `++` operator that is familiar from many languages in the C family.
Using it, we could write `incr counter` instead of `counter := !counter + 1`.
(There's also a `decr` function that decrements by 1.)

Second, the way we coded the counter currently exposes the `counter` variable to
the outside world. Maybe we're prefer to hide it so that clients of `next_val`
can't directly change it. We could do so by nesting `counter` inside the scope
of `next_val`:

```{code-cell} ocaml
let next_val =
  let counter = ref 0 in
  fun () ->
    incr counter;
    !counter
```

Now `counter` is in scope inside of `next_val`, but not accessible outside that
scope.

When we gave the dynamic semantics of let expressions before, we talked about
substitution. One way to think about the definition of `next_val` is as follows.

* First, the expression `ref 0` is evaluated. That returns a location `loc`,
  which is an address in memory. The contents of that address are initialized to
  `0`.

* Second, everywhere in the body of the let expression that `counter` occurs, we
  substitute for it that location. So we get:
  ```
  fun () -> incr loc; !loc
  ```

* Third, that anonymous function is bound to `next_val`.

So any time `next_val` is called, it increments and returns the contents of that
one memory location `loc`.

Now imagine that we instead had written the following (broken) code:

```{code-cell} ocaml
let next_val_broken = fun () ->
  let counter = ref 0 in
  incr counter;
  !counter
```

It's only a little different:  the binding of `counter` occurs after
the `fun () ->` instead of before.  But it makes a huge difference:

```{code-cell} ocaml
next_val_broken ();;
next_val_broken ();;
next_val_broken ();;
```

Every time we call `next_val_broken`, it returns `1`: we no longer have a
counter. What's going wrong here?

The problem is that every time `next_val_broken` is called, the first thing it
does is to evaluate `ref 0` to a new location that is initialized to `0`. That
location is then incremented to `1`, and `1` is returned. *Every* call to
`next_val_broken` is thus allocating a new ref cell, whereas `next_val`
allocates just *one* new ref cell.

## Example: Pointers

In languages like C, pointers combine two features: they can be null, and they
can be changed. (Java has a similar construct with object references, but that
term is confusing in our OCaml context since "reference" currently means a ref
cell. So we'll stick with the word "pointer".) Let's code up pointers using
OCaml ref cells.

```{code-cell} ocaml
type 'a pointer = 'a ref option
```

As usual, read that type right to left. The `option` part of it encodes the fact
that a pointer might be null. We're using `None` to represent that possibility.

```{code-cell} ocaml
let null : 'a pointer = None
```

The `ref` part of the type encodes the fact that the contents are mutable. We
can create a helper function to allocate and initialize the contents of a new
pointer:

```{code-cell} ocaml
let malloc (x : 'a) : 'a pointer = Some (ref x)
```

Now we could create a pointer to any value we like:

```{code-cell} ocaml
let p = malloc 42
```

*Dereferencing* a pointer is the `*` prefix operator in C. It returns the
contents of the pointer, and raises an exception if the pointer is null:

```{code-cell} ocaml
exception Segfault

let deref (ptr : 'a pointer) : 'a =
  match ptr with None -> raise Segfault | Some r -> !r
```

```{code-cell} ocaml
deref p
```

```{code-cell} ocaml
:tags: ["raises-exception"]
deref null
```

We could even introduce our own OCaml operator for dereference. We have to put
`~` in front of it to make it parse as a prefix operator, though.

```{code-cell} ocaml
let ( ~* ) = deref;;
~*p
```

In C, an assignment through a pointer is written `*p = x`.  That changes
the memory to which `p` points, making it contain `x`.  We can code up
that operator as follows:

```{code-cell} ocaml
let assign (ptr : 'a pointer) (x : 'a) : unit =
  match ptr with None -> raise Segfault | Some r -> r := x
```

```{code-cell} ocaml
assign p 2;
deref p
```

```{code-cell} ocaml
:tags: ["raises-exception"]
assign null 0
```

Again, we could introduce our own OCaml operator for that, though it's hard to
pick a good symbol involving `*` and `=` that won't be misunderstood as
involving multiplication:

```{code-cell} ocaml
let ( =* ) = assign;;
p =* 3;;
~*p
```

The one thing we can't do is treat a pointer as an integer. C allows that,
including taking the address of a variable, which enables *pointer arithmetic*.
That's great for efficiency, but also terrible because it leads to all kinds of
program errors and security vulnerabilities.

````{admonition} Evil Secret
Okay that wasn't actually true what we just said, but this is dangerous
knowledge that you really shouldn't even read.  There is an undocumented
function `Obj.magic` that we could use to get a memory address of a ref:

```ocaml
let address (ptr : 'a pointer) : int =
  match ptr with None -> 0 | Some r -> Obj.magic r

let ( ~& ) = address
```

But you have to promise to never, ever use that function yourself, because it
completely circumvents the safety of the OCaml type system. All bets are off if
you do.
````

None of this pointer encoding is part of the OCaml standard library, because you
don't need it. You can always use refs and options yourself as you need to.
Coding as we just did above is not particularly idiomatic. The reason we did it
was to illustrate the relationship between OCaml refs and C pointers
(equivalently, Java references).

## Example: Recursion Without Rec

Here's a neat trick that's possible with refs:  we can build recursive functions
without ever using the keyword `rec`.  Suppose we want to define a recursive
function such as `fact`, which we would normally write as follows:

```{code-cell} ocaml
let rec fact_rec n = if n = 0 then 1 else n * fact_rec (n - 1)
```

We want to define that function without using `rec`.  We can begin by
defining a ref to an obviously incorrect version of the function:

```{code-cell} ocaml
let fact0 = ref (fun x -> x + 0)
```

The way in which `fact0` is incorrect is actually irrelevant. We just need it to
have the right type. We could just as well have used `fun x -> x` instead of
`fun x -> x + 0`.

At this point, `fact0` clearly doesn't compute the factorial function.
For example, $5!$ ought to be 120, but that's not what `fact0` computes:

```{code-cell} ocaml
!fact0 5
```

Next, we write `fact` as usual, but without `rec`. At the place where we need to
make the recursive call, we instead invoke the function stored inside `fact0`:

```{code-cell} ocaml
let fact n = if n = 0 then 1 else n * !fact0 (n - 1)
```

Now `fact` does actually get the right answer for `0`, but not for `5`:

```{code-cell} ocaml
fact 0;;
fact 5;;
```

The reason it's not right for `5` is that the recursive call isn't actually
to the right function.  We want the recursive call to go to `fact`, not to
`fact0`.  **So here's the trick:** we mutate `fact0` to point to `fact`:

```{code-cell} ocaml
fact0 := fact
```

Now when `fact` makes its recursive call and dereferences `fact0`, it gets
back itself!  That makes the computation correct:

```{code-cell} ocaml
fact 5
```

Abstracting a little, here's what we did. We started with a function that is
recursive:

```ocaml
let rec f x = ... f y ...
```

We rewrote it as follows:

```ocaml
let f0 = ref (fun x -> x)

let f x = ... !f0 y ...

f0 := f
```

Now `f` will compute the same result as it did in the version where we defined
it with `rec`.

What's happening here is sometimes called "tying the recursive knot": we update
the reference to `f0` to point to `f`, such that when `f` dereferences `f0`, it
gets itself back. The initial function to which we made `f0` point (in this case
the identity function) doesn't really matter; it's just there as a placeholder
until we tie the knot.

## Weak Type Variables

Perhaps you have already tried using the identity function to define `fact0`,
as we mentioned above.  If so, you will have encountered this rather puzzling
output:

```{code-cell} ocaml
let fact0 = ref (fun x -> x)
```

What is this strange type for the identity function, `'_weak1 -> '_weak1`? Why
isn't it the usual `'a -> 'a`?

The answer has to do with a particularly tricky interaction between polymorphism
and mutability. In a later chapter on interpreters, we'll learn how type
inference works, and at that point we'll be able to explain the problem in
detail. In short, allowing the type `'a -> 'a` for that ref would lead to the
possibility of programs that crash at run time because of type errors.

For now, think about it this way: although the *value* stored in a ref cell is
permitted to change, the *type* of that value is not. And if OCaml gave
`ref (fun x -> x)` the type `('a -> 'a) ref`, then that cell could first store
`fun x -> x + 1 : int -> int` but later store
`fun x -> s ^ "!" : string -> string`. That would be the kind of change in type
that is not allowed.

So OCaml uses *weak type variables* to stand for unknown but not polymorphic
types. These variables always start with `_weak`. Essentially, type inference
for these is just not finished yet. Once you give OCaml enough information, it
will finish type inference and replace the weak type variable with the actual
type:

```{code-cell} ocaml
!fact0
```

```{code-cell} ocaml
!fact0 1
```

```{code-cell} ocaml
!fact0
```

After the application of `!fact0` to `1`, OCaml now knows that the function
is meant to have type `int -> int`. So from then on, that's the only type
at which it can be used. It can't, for example, be applied to a string.

```{code-cell} ocaml
:tags: ["raises-exception"]
!fact0 "camel"
```

If you would like to learn more about weak type variables right now, take a look
at Section 2 of [*Relaxing the value restriction*][relaxing] by Jacques
Garrigue, or [this section][weak] of the OCaml manual.

[relaxing]: https://caml.inria.fr/pub/papers/garrigue-value_restriction-fiwflp04.pdf
[weak]: https://ocaml.org/manual/polymorphism.html

## Physical Equality

OCaml has two equality operators, physical equality and structural equality. The
[documentation][stdlib] of `Stdlib.(==)` explains physical equality:

> `e1 == e2` tests for physical equality of `e1` and `e2`. On mutable types such
> as references, arrays, byte sequences, records with mutable fields and objects
> with mutable instance variables, `e1 == e2` is `true` if and only if physical
> modification of `e1` also affects `e2`. On non-mutable types, the behavior of
> `( == )` is implementation-dependent; however, it is guaranteed that
> `e1 == e2` implies `compare e1 e2 = 0`.

[stdlib]: https://ocaml.org/api/Stdlib.html

One interpretation could be that `==` should be used only when comparing refs
(and other mutable data types) to see whether they point to the same location in
memory. Otherwise, don't use `==`.

Structural equality is also explained in the documentation of `Stdlib.(=)`:

> `e1 = e2` tests for structural equality of `e1` and `e2`. Mutable structures
> (e.g. references and arrays) are equal if and only if their current contents
> are structurally equal, even if the two mutable objects are not the same
> physical object. Equality between functional values raises `Invalid_argument`.
> Equality between cyclic data structures may not terminate.

Structural equality is usually what you want to test. For refs, it checks
whether the contents of the memory location are equal, regardless of whether
they are the same location.

The negation of physical equality is `!=`, and the negation of structural
equality is `<>`. This can be hard to remember.

Here are some examples involving equality and refs to illustrate the difference
between structural equality (`=`) and physical equality (`==`):

```{code-cell} ocaml
let r1 = ref 42
let r2 = ref 42
```

A ref is physically equal to itself, but not to another ref that is a different
location in memory:

```{code-cell} ocaml
r1 == r1
```
```{code-cell} ocaml
r1 == r2
```
```{code-cell} ocaml
r1 != r2
```

Two refs that are at different locations in memory but store structurally
equal values are themselves structurally equal:

```{code-cell} ocaml
r1 = r1
```
```{code-cell} ocaml
r1 = r2
```
```{code-cell} ocaml
r1 <> r2
```

Two refs that store structurally unequal values are themselves structurally
unequal:

```{code-cell} ocaml
ref 42 <> ref 43
```

## Example: Singly-linked Lists

OCaml's built-in singly-linked lists are functional, not imperative. But we can
code up imperative singly-linked lists, of course, with refs. (We could also use
the pointers we invented above, but that only makes the code more complicated.)

We start by defining a type `'a node` for nodes of a list that contains values
of type `'a`.  The `next` field of a node is itself another list.

```{code-cell} ocaml
(** An ['a node] is a node of a mutable singly-linked list. It contains a value
    of type ['a] and a link to the [next] node. *)
type 'a node = { next : 'a mlist; value : 'a }

(** An ['a mlist] is a mutable singly-linked list with elements of type ['a].
    The [option] represents the possibility that the list is empty.
    RI: The list does not contain any cycles. *)
and 'a mlist = 'a node option ref
```

To create an empty list, we simply return a ref to `None`:

```{code-cell} ocaml
(** [empty ()] is an empty singly-linked list. *)
let empty () : 'a mlist = ref None
```

Note the type of `empty`: instead of being a value, it is now a function. This
is typical of functions that create mutable data structures. At the end of this
section, we'll return to why `empty` *has* to be a function.

Inserting a new first element just requires creating a new node, linking from
it to the original list, and mutating the list:

```{code-cell} ocaml
(** [insert_first lst v] mutates mlist [lst] by inserting value [v] as the
    first value in the list. *)
let insert_first (lst : 'a mlist) (v : 'a) : unit =
  lst := Some { next = ref !lst; value = v }
```

Again, note the type of `insert_first`. Rather than returning an `'a mlist`, it
returns `unit`. This again is typical of functions that modify mutable data
structures.

In both `empty` and `insert_first`, the use of `unit` makes the functions more
like their equivalents in an imperative language. The constructor for an empty
list in Java, for example, might not take any arguments (which is equivalent to
taking `unit`). And the `insert_first` operation for a Java linked list might
return `void`, which is equivalent to returning `unit`.

Finally, here's a conversion function from our new mutable lists to
OCaml's built-in lists:

```{code-cell} ocaml
(** [to_list lst] is an OCaml list containing the same values as [lst]
    in the same order. Not tail recursive. *)
let rec to_list (lst : 'a mlist) : 'a list =
  match !lst with None -> [] | Some { next; value } -> value :: to_list next
```

Now we can see mutability in action:

```{code-cell} ocaml
let lst0 = empty ();;
let lst1 = lst0;;
insert_first lst0 1;;
to_list lst1;;
```

The change to `lst0` mutates `lst1`, because they are aliases.

**The type of `empty`.** Returning to `empty`, why must it be a function? It
might seem as though we could define it more simply as follows:

```{code-cell} ocaml
let empty = ref None
```

But now there is only ever *one* ref that gets created, hence there is only one
list ever in existence:

```{code-cell} ocaml
let lst2 = empty;;
let lst3 = empty;;
insert_first lst2 2;;
insert_first lst3 3;;
to_list lst2;;
to_list lst3;;
```

Note how the mutations affect both lists, because they are both aliases
for the same ref.

By correctly making `empty` a function, we guarantee that a new ref is
returned every time an empty list is created.

```{code-cell} ocaml
let empty () = ref None
```

It really doesn't matter what argument that function takes, since it will
never use it.  We could define it as any of these in principle:

```{code-cell} ocaml
let empty _ = ref None
let empty (b : bool) = ref None
let empty (n : int) = ref None
(* etc. *)
```

But the reason we prefer `unit` as the argument type is to indicate to the
client that the argument value is not going to be used. After all, there's
nothing interesting that the function can do with the unit value. Another way to
think about that would be that a function whose input type is `unit` is like a
function or method in an imperative language that takes in no arguments. For
example, in Java a linked list class could have a constructor that takes no
arguments and creates an empty list:

```java
class LinkedList {
  /** Returns an empty list. */
  LinkedList() { ... }
}
```

**Mutable values.** In `mlist`, the nodes of the list are mutable, but the
values are not.  If we wanted the values also to be mutable, we can make
them refs too:

```{code-cell} ocaml
:tags: ["hide-output"]
type 'a node = { next : 'a mlist; value : 'a ref }
and 'a mlist = 'a node option ref

let empty () : 'a mlist = ref None

let insert_first (lst : 'a mlist) (v : 'a) : unit =
  lst := Some { next = ref !lst; value = ref v }

let rec set (lst : 'a mlist) (n : int) (v : 'a) : unit =
  match (!lst, n) with
  | None, _ -> invalid_arg "out of bounds"
  | Some { value }, 0 -> value := v
  | Some { next }, _ -> set next (n - 1) v

let rec to_list (lst : 'a mlist) : 'a list =
  match !lst with None -> [] | Some { next; value } -> !value :: to_list next
```

Now rather than having to create new nodes if we want to change a value,
we can directly mutate the value in a node:

```{code-cell} ocaml
let lst = empty ();;
insert_first lst 42;;
insert_first lst 41;;
to_list lst;;
set lst 1 43;;
to_list lst;;
```
