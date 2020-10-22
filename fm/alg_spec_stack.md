# Example: Stacks

Here are a few familiar operations on stacks along with their types.
```
module type Stack = sig
  type 'a t
  val empty : 'a t
  val is_empty : 'a t -> bool
  val peek : 'a t -> 'a
  val push : 'a -> 'a t -> 'a t
  val pop : 'a t -> 'a t
end
```
As usual, there is a design choice to be made with `peek` etc. about what to do
with empty stacks.  Here we have not used `option`, which suggests that `peek`
will raise an exception on the empty stack.  So we are cautiously relaxing
our prohibition on exceptions.

In the past we've given these operations specifications in English, e.g.,
```
  (* [push x s] is the stack [s] with [x] pushed on the top *)
  val push : 'a -> 'a stack -> 'a stack
```

But now, we'll instead write some equations to describe how the operations
work:
```
1. is_empty empty = true
2. is_empty (push x s) = false
3. peek (push x s) = x
4. pop (push x s) = s
```
(Later we'll return to the question of *how* to design such equations.)
The variables appearing in these equations are implicitly universally
quantified. Here's how to read each equation:

1. `is_empty empty = true`.  The empty stack is empty.
2. `is_empty (push x s) = false`.  A stack that has just been pushed is
   non-empty.
3. `peek (push x s) = x`.  Pushing then immediately peeking yields whatever
   value was pushed.
4. `pop (push x s) = s`.  Pushing then immediately popping yields the original
   stack.

Just with these equations alone, we already can infer a lot about how any
sequence of stack operations must work.  For example,
```
  peek (pop (push 1 (push 2 empty)))
=   { equation 4 }
  peek (push 2 empty)
=   { equation 3 }
  2
```
And `peek empty` doesn't equal any value according to the equations, since there
is no equation of the form `peek empty = ...`.  All that is true regardless of
the stack implementation that is chosen:  any correct implementation must cause
the equations to hold.

Suppose we implemented stacks as lists, as follows:
```
module ListStack = struct
  type 'a t = 'a list
  let empty = []
  let is_empty s = (s = [])
  let peek = List.hd
  let push = List.cons
  let pop = List.tl
end
```

Next we could *prove* that each equation holds of the implementation.  All these
proofs are quite easy by now, and proceed entirely by evaluation.  For example,
here's a proof of equation 3:
```
  peek (push x s)
=   { evaluation }
  peek (x :: s)
=   { evaluation }
  x
```
