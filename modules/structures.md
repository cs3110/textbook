# Structures

Modules in OCaml are implemented by `module` definitions that have the
following syntax:

```
module ModuleName = struct 
  (* definitions *)
end
```
Here, for example, is a module for stacks implemented as lists:
```
module ListStack = struct
  let empty = []
  let is_empty s = (s = [])
  
  let push x s = x :: s

  let peek = function
    | [] -> failwith "Empty"
    | x::_ -> x

  let pop = function
    | [] -> failwith "Empty"
    | _::xs -> xs
end
```

Module names must begin with an uppercase letter. The part of the module definition
that is written
```
struct (* definitions *) end
```
is called a *structure*.  A structure is simply a sequence of definitions.  The
structure itself is anonymous&mdash;it has no name&mdash;until it is bound
to a name by a module definition.  

Modules partition the namespace, so that any symbol `x` that is bound in
the implementation of a module named `Module` must be referenced by the
qualifed name `Module.x` outside the implementation of the module
(unless the namespace has been exposed using `open`).

The implementation of a module can contain `type` definitions,
`exception` definitions, `let` definitions, `open` statements, as well as some other
things we haven't seen so far.  All the definitions inside a module
are permitted to end with double semicolon `;;` for compatibility
with the toplevel, but 3110 considers it unidiomatic to do so.

Modules are not as first-class in OCaml as functions.  There are some
language extensions that make it possible to bundle up modules as values,
but we won't be looking at them.  If you're curious you can have a look
at [the manual][firstclassmodules].

[firstclassmodules]: http://caml.inria.fr/pub/docs/manual-ocaml/extn.html#sec230
