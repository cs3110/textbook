# Example: Queues

Stacks were easy.  How about queues?  Here is the specification:

```
module type Queue = sig
  type 'a t
  val empty : 'a t
  val is_empty : 'a t -> bool
  val front : 'a t -> 'a
  val enq : 'a -> 'a t -> 'a t
  val deq : 'a t -> 'a t
end

1.  is_empty empty = true
2.  is_empty (enq x q) = false
3a. front (enq x q) = x            if is_empty q = true
3b. front (enq x q) = front q      if is_empty q = false
4a. deq (enq x q) = empty          if is_empty q = true
4b. deq (enq x q) = enq x (deq q)  if is_empty q = false
```

The types of the queue operations are actually identical to the types
of the stack operations.  Here they are, side-by-side for comparison:
```
module type Stack = sig            module type Queue = sig
  type 'a t                          type 'a t
  val empty : 'a t                   val empty : 'a t
  val is_empty : 'a t -> bool        val is_empty : 'a t -> bool
  val peek : 'a t -> 'a              val front : 'a t -> 'a
  val push : 'a -> 'a t -> 'a t      val enq : 'a -> 'a t -> 'a t
  val pop : 'a t -> 'a t             val deq : 'a t -> 'a t
end                                end
```
Look at each line:  though the operation may have a different name, its type
is the same.  Obviously, the types alone don't tell us enough about the
operations.  But the equations do.  Here's how to read each equation:

1. The empty queue is empty.
2. Enqueueing makes a queue non-empty.
3. Enqueueing `x` on an empty queue makes `x` the front element.
   But if the queue isn't empty, enqueueing doesn't change the front element.
4. Enqueueing then dequeueing on an empty queue leaves the queue empty.
   But if the queue isn't empty, the enqueue and dequeue operations can
   be swapped.

For example,
```
  front (deq (enq 1 (enq 2 empty)))
=   { equation 4b }
  front (enq 1 (deq (enq 2 empty)))
=   { equation 4a }
  front (enq 1 empty)
=   { equation 3a }
  1
```
And `front empty` doesn't equal any value according to the equations.

Implementing a queue as a list results in an implementation that is
easy to verify just with evaluation.
```
module ListQueue : Queue = struct
  type 'a t = 'a list
  let empty = []
  let is_empty q = q = []
  let front = List.hd
  let enq x q = q @ [x]
  let deq = List.tl
end
```

For example, 4a can be verified as follows:
```
  deq (enq x empty) 
=   { evaluation of empty and enq}
  deq ([] @ [x])
=   { evaluation of @ }
  deq [x]
=   { evaluation of deq }
  []
=   { evaluation of empty }
  empty
```

And 4b, as follows:
```
  deq (enq x q) 
=  { evaluation of enq and deq }
  List.tl (q @ [x])
=  { lemma, below, and q <> [] }
  (List.tl q) @ [x]

  enq x (deq q)
=  { evaluation }
  (List.tl q) @ [x]
```

Here is the lemma:
```
Lemma: if xs <> [], then List.tl (xs @ ys) = (List.tl xs) @ ys.
Proof: if xs <> [], then xs = h :: t for some h and t.

  List.tl ((h :: t) @ ys)
=   { evaluation of @ }
  List.tl (h :: (t @ ys))
=   { evaluation of tl }
  t @ ys

  (List.tl (h :: t)) @ ys
=   { evaluation of tl }
  t @ ys

QED
```

Note how the precondition in 3b and 4b of `q` not being empty ensures
that we never have to deal with an exception being raised in the
equational proofs.
