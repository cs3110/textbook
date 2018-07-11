# Abstract Types

The type `'a stack` above is *abstract*: the `Stack` module type says
that there is a type name `'a stack` in any module that implements the
module type, but it does not say what that type is defined to be. Once
we add the `: Stack` module type annotation to `ListStack`, its `'a
stack` type also becomes abstract.  Outside of the module, no one is
allowed to know that `'a stack` and `'a list` are synonyms.  

A module that implements a module type must specify concrete types for
the abstract types in the signature and define all the names declared in
the signature. Only declarations in the signature are accessible outside
of the module.  For example, functions defined in the module's structure
but not in the module type's signature are not accessible.  We say that
the structure is *sealed* by the signature:  nothing except what is 
revealed in the signature may be accessed.

Here is another implementation of the `Stack` module type:
```
module MyStack : Stack = struct
  type 'a stack = 
  | Empty 
  | Entry of 'a * 'a stack
  
  let empty = Empty
  let is_empty s = s = Empty
  let push x s = Entry (x, s)
  let peek = function
    | Empty -> failwith "Empty"
    | Entry(x,_) -> x
  let pop = function
    | Empty -> failwith "Empty"
    | Entry(_,s) -> s
end
```
In that implementation, we provide our own custom variant for the representation type.
Of course, that custom variant is more or less the same as the built-in list type:
it has two constructors, one the carries no data, and the other that carries a pair 
of an element and (recursively) the same variant type.  

Because `'a stack` is abstract in the `Stack` module type, no client of this 
data structure will be able to discern whether stacks are being implemented
with the built-in list type or the custom one we just used.  Clients may
only access the stack in the ways that are defined by the `Stack` interface,
which nowhere mentions `list` or `Empty` or `Entry`.  

You can even observe that abstraction in utop.  Observe what happens when
utop displays the value that results from this expression:
```
# MyStack.push 1 MyStack.empty;;
- : int MyStack.stack = <abstr> 
```
The value has type `int MyStack.stack`, which is to say, it is the `MyStack.stack` 
type constructor applied to `int`.  And the value is...well, utop won't tell us!
It simply prints `<abstr>` to indicate that the value has been abstracted.

Notice how verbose the type `int MyStack.stack` is.  The module name already
tells us that the value is related to `MyStack`; the word `stack` following
that isn't particularly helpful.  For that reason, it is idiomatic OCaml
to name the primary representation type of a data structure simply `t`.
Here's the `Stack` module type rewritten that way:
```
module type Stack = sig
  type 'a t
  val empty    : 'a t
  val is_empty : 'a t -> bool
  val push     : 'a -> 'a t -> 'a t
  val peek     : 'a t -> 'a
  val pop      : 'a t -> 'a t
end
```
Given that renaming, here's what the toplevel would display as the type:
```
# MyStack.push 1 MyStack.empty;;
- : int MyStack.t = <abstr> 
```
And now by convention we would usually pronounce that type as "int MyStack",
simply ignoring the `t`, though it does technically have to be there to be
legal OCaml code.

## Custom Printers

It is possible to install custom printers so that the toplevel will convert a
value of an abstract type to a string and print it instead of `<abstr>`. 
This doesn't violate abstraction, because programmers still can't access the
value.  It just allows the toplevel to provide better pretty printing.
Here's an example utop session, based on code that appears below:
```
# #install_printer ListStack.format;;

# open ListStack;;

# empty |> push 1 |> push 2;;
- : int stack = [2; 1; ] 
```
Notice how the value of the stack is helpfully printed.  The code that makes
this happen is in `ListStack.format`:
```
module type Stack = sig
  type 'a stack
  (* ... all the usual operations ... *)
  val format : (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a stack -> unit
end

module ListStack : Stack = struct
  type 'a stack = 'a list
  (* ... all the usual operations ... *)
  let format fmt_elt fmt s =
    Format.fprintf fmt "[";
    List.iter (fun elt -> Format.fprintf fmt "%a; " fmt_elt elt) s; 
    Format.fprintf fmt "]"
end
```
For more information, see the [toplevel manual][toplevel] (search for `#install_printer`),
and the [Format module][format], as well as this [patch in the OCaml Bug Tracker][patch].

[toplevel]: http://caml.inria.fr/pub/docs/manual-ocaml/toplevel.html
[format]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Format.html
[patch]: http://caml.inria.fr/mantis/print_bug_page.php?bug_id=5958
