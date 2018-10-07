# Example: Queues

## Queue Signature

Queues and stacks are fairly similar interfaces.  Here, for sake of
example, we do something different with the interface that has nothing
to do with the data structure is a stack or a queue:  we choose to
return an `option` from some functions instead of raising an exception.
We could go back to our stack signature and re-code it in a similar way.

Which way to code it is in part a matter of taste:

* The way we do it here, with options, ensures that surprising exceptions
  regarding empty queues never occur at run-time.  The program is therefore
  more robust.
  
* The way we did it before, with exceptions, means that programmers don't
  have to write as much code.  If they are sure that an exception can't occur,
  they can omit the code for handling it.
  
There is thus a tradeoff between writing more code early (with options) 
or doing more debugging later (with exceptions).

```
module type Queue = sig
  (* An ['a queue] is a queue whose elements have type ['a]. *)
  type 'a queue
  
  (* The empty queue. *)
  val empty : 'a queue
  
  (* Whether a queue is empty. *)
  val is_empty : 'a queue -> bool
  
  (* [enqueue x q] is the queue [q] with [x] added to the end. *)
  val enqueue : 'a -> 'a queue -> 'a queue
  
  (* [peek q] is [Some x], where [x] is the element at the front of the queue,
     or [None] if the queue is empty. *)
  val peek : 'a queue -> 'a option
  
  (* [dequeue q] is [Some q'], where [q'] is the queue containing all the elements
     of [q] except the front of [q], or [None] if [q] is empty. *)
  val dequeue : 'a queue -> 'a queue option
end
```

## Queue Implemented as a List

Here is an implementation of a functional queue data structure as a list:

```
module ListQueue : Queue = struct
  (* Represent a queue as a list.  The list [x1; x2; ...; xn] represents
     the queue with [x1] at its front, followed by [x2], ..., followed
     by [xn]. *)
  type 'a queue = 'a list
  
  let empty = []

  let is_empty q = q = []

  let enqueue x q = q @ [x] 

  let peek = function
    | [] -> None
    | x::_ -> Some x

  let dequeue = function
    | [] -> None
    | _::q -> Some q
end
```

Dequeueing is constant-time with this representation, but enqueueing is
a linear-time operation.  That's because `dequeue` does a single pattern
match, whereas `enqueue` must traverse the entire list to put the new
element at the end.
  
## Queue Implemented with Two Lists

Here is a second, more efficient implementation of the Queue interface, 
using two lists to represent a single queue. This representation seems
to have been invented independently by (1) Hood and Melville, and by 
(2) our very own Prof. David Gries.

1. Robert Hood and Robert Melville. Real-time queue operations
   in pure LISP.  *Information Processing Letters*, 13(2):50-53, 
   November 1981. 
2. David Gries.  *The Science of Programming*, p. 55.  Springer-Verlag,
   New York, 1981.

```
module TwoListQueue : Queue = struct
  (* [{front=[a;b]; back=[e;d;c]}] represents the queue
     containing the elements a,b,c,d,e. That is, the
     back of the queue is stored in reverse order. 
     [{front; back}] is in *normal form* if [front]
     being empty implies [back] is also empty. 
     All queues passed into or out of the module 
     must be in normal form. *)
  type 'a queue = {front:'a list; back:'a list}
  
  let empty = {front=[]; back=[]}

  let is_empty = function
    | {front=[]; back=[]} -> true
    | _ -> false
    
  (* Helper function to ensure that a queue is in normal form. *)
  let norm = function
    | {front=[]; back} -> {front=List.rev back; back=[]}
    | q -> q
    
  let enqueue x q = norm {q with back=x::q.back} 
  
  let peek = function 
    | {front=[]; _} -> None
    | {front=x::_; _} -> Some x

  let dequeue = function
    | {front=[]; _} -> None
    | {front=_::xs; back} -> Some (norm {front=xs; back})
end
```

With two-list queues, we now get a constant time `enqueue` operation:
just cons a new element onto `back`.  But `dequeue` is no longer just a
simple pattern match: it has to call `norm` to ensure the queue it
returns is in normal form.  So it might seem as though `dequeue` no
longer has constant time efficiency. Nonetheless, with an advanced
algorithmic analysis technique (not covered here) called *amortized
analysis*, it is possible to conclude that this implementation of
`dequeue` is essentially constant time.

That efficiency comes at a price in readability, though. If we compare
`ListQueue` and `TwoListQueue`, it's hopefully clear that `ListQueue` is
a simple and correct implementation of a queue data structure.  It's
probably far less clear that `TwoListQueue` is a correct implementation!
 
Some of the exercises at the end of this chapter ask you to
explore the efficiencies of these two implementations a bit further.

