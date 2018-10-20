# Example: Mutable Stacks

As an example of a mutable data structure, let's look at stacks.  We're
already familiar with functional stacks:
```
exception Empty

module type Stack = sig
  (* ['a t] is the type of stacks whose elements have type ['a]. *)
  type 'a t

  (* [empty] is the empty stack *)
  val empty : 'a t

  (* [push x s] is the stack whose top is [x] and the rest is [s]. *)
  val push : 'a -> 'a t -> 'a t

  (* [peek s] is the top element of [s].
   * raises: [Empty] is [s] is empty. *)
  val peek : 'a t -> 'a

  (* [pop s] is all but the top element of [s].
   * raises: [Empty] is [s] is empty. *)
  val pop : 'a t -> 'a t
end
```

An interface for a *mutable* or *non-persistent* stack would look a 
little different:
```
module type MutableStack = sig
  (* ['a t] is the type of mutable stacks whose elements have type ['a].
   * The stack is mutable not in the sense that its elements can
   * be changed, but in the sense that it is not persistent:
   * the operations [push] and [pop] destructively modify the stack. *)
  type 'a t

  (* [empty ()] is the empty stack *)
  val empty : unit -> 'a t

  (* [push x s] modifies [s] to make [x] its top element.
   * The rest of the elements are unchanged. *)
  val push : 'a -> 'a t -> unit

  (* [peek s] is the top element of [s].
   * raises: [Empty] is [s] is empty. *)
  val peek : 'a t -> 'a

  (* [pop s] removes the top element of [s].
   * raises: [Empty] is [s] is empty. *)
  val pop : 'a t -> unit
end
```
Notice especially how the type of `empty` changes:  instead of being a
value, it is now a function.  This is typical of functions that create
mutable data structures. Also notice how the types of `push` and `pop`
change: instead of returning an `'a t`, they return `unit`.  This again
is typical of functions that modify mutable data structures. In all
these cases, the use of `unit` makes the functions more like their
equivalents in an imperative language.  The constructor for an empty
stack in Java, for example, might not take any arguments (which is
equivalent to taking unit).  And the push and pop functions for a Java
stack might return `void`, which is equivalent to returning `unit`.

Now let's implement the mutable stack with a mutable linked list.
We'll have to code that up ourselves, since OCaml linked lists
are persistent.
```
module MutableRecordStack = struct
  (* An ['a node] is a node of a mutable linked list.  It has
   * a field [value] that contains the node's value, and
   * a mutable field [next] that is [Null] if the node has
   * no successor, or [Some n] if the successor is [n]. *)
  type 'a node = {value : 'a; mutable next : 'a node option}

 (* AF: An ['a t] is a stack represented by a mutable linked list.
  * The mutable field [top] is the first node of the list,
  * which is the top of the stack. The empty stack is represented
  * by {top = None}.  The node {top = Some n} represents the
  * stack whose top is [n], and whose remaining elements are
  * the successors of [n]. *)
  type 'a t = {mutable top : 'a node option}

  let empty () = 
    {top = None}

  (* To push [x] onto [s], we allocate a new node with [Some {...}].
   * Its successor is the old top of the stack, [s.top].
   * The top of the stack is mutated to be the new node. *)
  let push x s =
    s.top <- Some {value = x; next = s.top}

  let peek s =
    match s.top with
    | None -> raise Empty
    | Some {value} -> value

  (* To pop [s], we mutate the top of the stack to become its successor. *)
  let pop s =
    match s.top with
    | None -> raise Empty
    | Some {next} -> s.top <- next
end
```

Here is some example usage of the mutable stack:
```
# let s = empty ();;
val s : '_a t = {top = None}

# push 1 s;;
- : unit = ()

# s;;
- : int t = {top = Some {value = 1; next = None}}

# push 2 s;;
- : unit = ()

# s;;
- : int t = {top = Some {value = 2; next = Some {value = 1; next = None}}} 

# pop s;;
- : unit = ()

# s;;
- : int t = {top = Some {value = 1; next = None}}
```

The `'_a` in the first utop response in that transcript is a 
*weakly polymorphic type variable.*  It indicates that the
type of elements of `s` is not yet fixed, but that as soon as
one element is added, the type (for that particular stack)
will forever be fixed.  

Weak type variables tend to appear 
once mutability is involved, and they are important for the type
system to prevent certain kinds of errors, but we won't discuss
them further.  If you would like to learn more, read Section 2 of
[*Relaxing the value restriction*][relaxing] by Jacques Garrigue,
or [this section][weak] of the OCaml manual.

[relaxing]: https://caml.inria.fr/pub/papers/garrigue-value_restriction-fiwflp04.pdf
[weak]: https://caml.inria.fr/pub/docs/manual-ocaml/polymorphism.html
