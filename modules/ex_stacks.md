# Example: Stacks

In previous sections we developed some code for stacks.  Here we'll
recapitulate some of that code, while augmenting it with documentation.

## Stack Signature

```
module type Stack = sig
  (* The type of a stack whose elements are type 'a *)
  type 'a stack
  
  (* The empty stack *)
  val empty : 'a stack

  (* Whether the stack is empty*)
  val is_empty : 'a stack -> bool

  (* [push x s] is the stack [s] with [x] pushed on the top *)
  val push : 'a -> 'a stack -> 'a stack
  
  (* [peek s] is the top element of [s]. 
     Raises Failure if [s] is empty. *)
  val peek : 'a stack -> 'a

  (* [pop s] pops and discards the top element of [s]. 
     Raises Failure if [s] is empty. *)
  val pop : 'a stack -> 'a stack
end
```

## Stack Implemented as List

This implementation of `Stack` uses OCaml's built-in `list` 
to represent a stack.

```
module ListStack : Stack = struct
  type 'a stack = 'a list
  
  let empty = []
  let is_empty s = s = []
  let push x s = x :: s
  let peek = function 
    | []   -> failwith "Empty"
    | x::_ -> x
  let pop = function 
    | []    -> failwith "Empty"
    | _::xs -> xs
end
```

## Stack Implemented as Variant

This implementation uses a custom-coded variant to represent
a stack.  Note, though, how `'a stack` is essentially the
same as the built-in `'a list`:  both have two constructors,
and their constructors carry similar data.

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
