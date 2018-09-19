# Specification of Modules

Let us now consider the use of specification in module *implementations*. The
first question we must ask ourselves is who is going to read the
comments written in module implementations. Because we are going to work
hard to allow module clients to program against the module while reading
only its interface, clearly clients are not the intended audience. Rather,
the purpose of implementation comments is to explain the implementation
to other implementers or maintainers of the module. This is done by
writing comments that convince the reader that the implementation
correctly implements its interface.

It is inappropriate to copy the specifications of functions found in the
module interface into the module implementation. Copying runs the risk
of introducing inconsistency as the program evolves, because programmers
don't keep the copies in sync. Copying code and specifications is a
major source (if not *the* major source) of program bugs. In any case,
implementers can always look at the interface for the specification.

Implementation comments fall into two categories. The first category
arises because a module implementation may define new types and
functions that are purely internal to the module. If their significance
is not obvious, these types and functions should be documented in much
the same style that we have suggested for documenting interfaces. Often,
as the code is written, it becomes apparent that the new types and
functions defined in the module form an internal data abstraction or at
least a collection of functionality that makes sense as a module in its
own right. This is a signal that the internal data abstraction might be
moved to a separate module and manipulated only through its operations.

The second category of implementation comments is associated with the
use of *data abstraction*. Suppose we are implementing an abstraction
for a set of items of type `'a`. The interface might look something like
this:

```
(** A set is an unordered collection in which multiplicity is ignored. *)
module type Set = sig

  (** the type representing a set whose elements are type ['a] *)
  type 'a set
  
  (** the set containing no elements *)
  val empty : 'a set
  
  (** [mem x s] is whether [x] is a member of set [s] *)
  val mem : 'a -> 'a set -> bool
  
  (** [add x s] is the set containing all the elements of [s]
      as well as [x]. *)
  val add : 'a -> 'a set -> 'a set
  
  (** [rem x s] is the set containing all the elements of [s],
      minus [x]. *)
  val rem : 'a -> 'a set -> 'a set
  
  (** [size s] is the cardinality of [s] *)
  val size: 'a set -> int
  
  (** [union s1 s2] is the set containing all the elements that
      are in either [s1] or [s2]. *)
  val union: 'a set -> 'a set -> 'a set
  
  (** [inter s1 s2] is the set containing all the elements that
      are in both [s1] and [s2]. *)
  val inter: 'a set -> 'a set -> 'a set
end
```

In a real signature for sets, we'd want operations such as `map` and
`fold` as well, but let's omit these for now for simplicity. There are
many ways to implement this abstraction. One easy way is as a list:

```
(* Implementation of sets as lists with duplicates *)
module ListSetDups : Set = struct
  type 'a set = 'a list
  let empty = []
  let mem = List.mem
  let add x l = x :: l
  let rem x = List.filter ((<>) x)
  let rec size = function
	| [] -> 0
	| h :: t -> size t + (if mem h t then 0 else 1)
  let union l1 l2 = l1 @ l2
  let inter l1 l2 = List.filter (fun h -> mem h l2) l1
end
```

This implementation has the advantage of simplicity. For small sets that
tend not to have duplicate elements, it will be a fine choice. Its
performance will be poor for large sets or applications with many
duplicates but for some applications that's not an issue.

Notice that the types of the functions do not need to be written down in
the implementation. They aren't needed because they're already present
in the signature, just like the specifications that are also in the
signature don't need to be replicated in the structure.

Here is another implementation of `Set` that also uses `'a list` but
requires the lists to contain no duplicates. This implementation is also
correct (and also slow for large sets). Notice that we are using the
same representation type, yet some important aspects of the
implementation are quite different.

```
(* Implementation of sets as lists without duplicates *)
module ListSetNoDups : Set = struct
  type 'a set = 'a list
  let empty = []
  let mem = List.mem
  (* add checks if already a member *)
  let add x l = if mem x l then l else x :: l 
  let rem x = List.filter ((<>) x)
  let size = List.length (* size is just length if no duplicates *)
  let union l1 l2 = (* check if already in other set *)
	List.fold_left (fun a x -> if mem x l2 then a else x :: a) l2 l1
  let inter l1 l2 = List.filter (fun h -> mem h l2) l1
end
```

An important reason why we introduced the writing of function
specifications was to enable *local reasoning*: once a function has a
spec, we can judge whether the function does what it is supposed to
without looking at the rest of the program. We can also judge whether
the rest of the program works without looking at the code of the
function. However, we cannot reason locally about the individual
functions in the three module implementations just given. The problem is
that we don't have enough information about the relationship between the
concrete type (`int list`) and the corresponding
abstract type (`set`). This lack of information can be addressed by
adding two new kinds of comments to the implementation: the *abstraction
function* and the *representation invariant* for the abstract data type.
We turn to discussion of those, next.
