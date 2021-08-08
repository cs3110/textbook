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

# Mutable Fields

{{ video_embed | replace("%%VID%%", "9RNeX5t4_xA")}}

The fields of a record can be declared as mutable, meaning their contents can be
updated without constructing a new record. For example, here is a record type
for two-dimensional colored points whose color field `c` is mutable:

```{code-cell} ocaml
type point = {x : int; y : int; mutable c : string}
```

Note that `mutable` is a property of the field, rather than the type of the
field. In particular, we write `mutable field : type`, not
`field : mutable type`.

The operator to update a mutable field is `<-` which is meant to look like
a left arrow.

```{code-cell} ocaml
let p = {x = 0; y = 0; c = "red"}
```

```{code-cell} ocaml
p.c <- "white"
```

```{code-cell} ocaml
p
```

Non-mutable fields cannot be updated that way:

```{code-cell} ocaml
:tags: ["raises-exception"]
p.x <- 3;;
```

* **Syntax:** `e1.f <- e2`

* **Dynamic semantics:** To evaluate `e1.f <- e2`, evaluate `e2` to a value
  `v2`, and `e1` to a value `v1`, which must have a field named `f`. Update
  `v1.f` to `v2`. Return `()`.

* **Static semantics:** `e1.f <- e2 : unit` if `e1 : t1` and
  `t1 = {...; mutable f : t2; ...}`, and `e2 : t2`.

## Refs Are Mutable Fields

It turns out that refs are actually implemented as mutable fields. In
[`Stdlib`][stdlib] we find the following declaration:

```ocaml
type 'a ref = { mutable contents : 'a }
```

And that's why when the toplevel outputs a ref it looks like a record: it *is* a
record with a single mutable field named `contents`!

```{code-cell} ocaml
let r = ref 42
```

The other syntax we've seen for records is in fact equivalent to simple OCaml
functions:

```{code-cell} ocaml
let ref x = {contents = x}
```

```{code-cell} ocaml
let ( ! ) r = r.contents
```

```{code-cell} ocaml
let ( := ) r x = r.contents <- x
```

The reason we say "equivalent" is that those functions are actually implemented
not in OCaml itself but in the OCaml run-time, which is implemented mostly in C.
Nonetheless the functions do behave the same as the OCaml source given above.

[stdlib]: https://ocaml.org/api/Stdlib.html

## Example: Mutable Singly-Linked Lists

{{ video_embed | replace("%%VID%%", "dLi6Vo_Yp34")}}

Using mutable fields, we can implement singly-linked lists almost the same as we
did with references. The types for nodes and lists are simplified:

```{code-cell} ocaml
(** An ['a node] is a node of a mutable singly-linked list. It contains a value
    of type ['a] and optionally has a pointer to the next node. *)
type 'a node = {
  mutable next : 'a node option;
  value : 'a
}

(** An ['a mlist] is a mutable singly-linked list with elements of type ['a].
    RI: The list does not contain any cycles. *)
type 'a mlist = {
  mutable first : 'a node option;
}
```

{{ video_embed | replace("%%VID%%", "EEXa3bY4ZwI")}}

And there is no essential difference in the algorithms for implementing
the operations, but the code is slightly simplified because we don't
have to use reference operations:

```{code-cell} ocaml
(** [insert_first lst n] mutates mlist [lst] by inserting value [v] as the
    first value in the list. *)
let insert_first (lst : 'a mlist) (v : 'a) =
  lst.first <- Some {value = v; next = lst.first}

(** [empty ()] is an empty singly-linked list. *)
let empty () : 'a mlist = {
  first = None
}

(** [to_list lst] is an OCaml list containing the same values as [lst]
    in the same order. Not tail recursive. *)
let to_list (lst : 'a mlist) : 'a list =
  let rec helper = function
    | None -> []
    | Some {next; value} -> value :: helper next
  in
  helper lst.first
```

## Example: Mutable Stacks

We already know that lists and stacks can be implemented in quite similar
ways. Let's use what we've learned from mutable linked lists to
implement mutable stacks.  Here is an interface:

```{code-cell} ocaml
module type MutableStack = sig
  (** ['a t] is the type of mutable stacks whose elements have type ['a].
      The stack is mutable not in the sense that its elements can
      be changed, but in the sense that it is not persistent:
      the operations [push] and [pop] destructively modify the stack. *)
  type 'a t

  (** Raised if [peek] or [pop] encounter the empty stack. *)
  exception Empty

  (** [empty ()] is the empty stack *)
  val empty : unit -> 'a t

  (** [push x s] modifies [s] to make [x] its top element.
      The rest of the elements are unchanged. *)
  val push : 'a -> 'a t -> unit

  (**[peek s] is the top element of [s].
     Raises: [Empty] is [s] is empty. *)
  val peek : 'a t -> 'a

  (** [pop s] removes the top element of [s].
      Raises: [Empty] is [s] is empty. *)
  val pop : 'a t -> unit
end
```

Now let's implement the mutable stack with a mutable linked list.

```{code-cell} ocaml
module MutableRecordStack : MutableStack = struct
  (** An ['a node] is a node of a mutable linked list.  It has
     a field [value] that contains the node's value, and
     a mutable field [next] that is [Null] if the node has
     no successor, or [Some n] if the successor is [n]. *)
  type 'a node = {value : 'a; mutable next : 'a node option}

 (** AF: An ['a t] is a stack represented by a mutable linked list.
     The mutable field [top] is the first node of the list,
     which is the top of the stack. The empty stack is represented
     by {top = None}.  The node {top = Some n} represents the
     stack whose top is [n], and whose remaining elements are
     the successors of [n]. *)
  type 'a t = {mutable top : 'a node option}

  exception Empty

  let empty () = {top = None}

  let push x s = s.top <- Some {value = x; next = s.top}

  let peek s =
    match s.top with
    | None -> raise Empty
    | Some {value} -> value

  let pop s =
    match s.top with
    | None -> raise Empty
    | Some {next} -> s.top <- next
end
```
