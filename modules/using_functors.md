# Using Functors

Since functors are really just parameterized modules, we can use them to
produce functions that are parameterized on any structure that matches
a signature.  That can help to eliminate code duplication.
Here are two examples of doing that.

## Example 1: Producing a Test Suite for Multiple Structures

Recall our data structures for stacks:

```
module type StackSig = sig
  type 'a t
  val empty : 'a t
  val push  : 'a -> 'a t -> 'a t
  val peek  : 'a t -> 'a
end

module ListStack = struct
  type 'a t = 'a list
  let empty = []
  let push x s = x::s
  let peek = function [] -> failwith "empty" | x::_ -> x
end

(* called MyStack because the standard library already has a Stack *)
module MyStack = struct
  type 'a t = Empty | Entry of 'a * 'a t
  let empty = Empty
  let push x s = Entry (x, s)
  let peek = function Empty -> failwith "empty" | Entry(x,_) -> x
end
```

Suppose we wanted to write code that would test a `ListStack`:

```
assert (ListStack.(empty |> push 1 |> peek) = 1)
```

Unfortunately, to test a `MyStack`, we'd have to duplicate that code:

```
assert (MyStack.(empty |> push 1 |> peek) = 1)
```

And if we had other stack implementations, we'd have to duplicate
the test for them, too.  That's not so horrible to contemplate if
it's just one test case for a couple implementations, but if it's
hundreds of tests for even a couple implementations, that's just
too much duplication to be good software engineering.

Functors offer a better solution.  We can write a functor that
is parameterized on the stack implementation, and produces the
test for that implementation:

```
module StackTester (S:StackSig) = struct
  assert (S.(empty |> push 1 |> peek) = 1)
end

module MyStackTester = StackTester(MyStack)
module ListStackTester = StackTester(ListStack)
```

Now we can factor out all our tests into the functor `StackTester`, and
when we apply that functor to a stack implementation, we get a set of
tests for that implementation.  Of course, this would work with OUnit 
as well as assertions.

## Example 2: Adding a Function to Multiple Structures

Earlier, we tried to add a function `add_all` to both `ListSetNoDups`
and `ListSetDups` without having any duplicated code, but we didn't
totally succeed.  Now let's really do it right.

The problem we had earlier was that we needed to parameterize the
implementation of `add_all` on the `add` function in the set 
data structure.  We can accomplish that parameterization with 
a functor.

Here is a functor that takes in a structure named `S` that matches the `Set`
signature, then produces a new structure having a single function named
`add_all` in it:
```
module AddAll(S:Set) = struct
  let add_all lst set =
    let add' s x = S.add x s in
    List.fold_left add' set lst
end
```
Notice how the functor, in its body, uses `S.add`.  It takes the implementation
of `add` from `S` and uses it to implement `add_all`, thus solving the
exact problem we had before when we tried to use includes.

When we apply `AddAll` to our set implementations, we get structures
containing an `add_all` function for each implementation:
```
# module AddAllListSetDups = AddAll(ListSetDups);;
module AddAllListSetDups : 
  sig
    val add_all : 'a list -> 'a ListSetDups.t -> 'a ListSetDups.t               
  end

# module AddAllListSetNoDups = AddAll(ListSetNoDups);;
module AddAllListSetNoDups : 
  sig
    val add_all : 'a list -> 'a ListSetNoDups.t -> 'a ListSetNoDups.t               
  end
```
So the functor has enabled the code reuse we couldn't get before:
we now can implement a single `add_all` function and from it derive
implementations for two different set structures.

But that's the **only** function those two structures contain.  Really
what we want is a full set implementation that also contains the
`add_all` function.  We can get that by combining includes with functors:
```
module ExtendSet(S:Set) = struct
  include S
  
  let add_all lst set =
    let add' s x = S.add x s in
    List.fold_left add' set lst
end
```
That functor takes a set structure as input, and produces a structure that contains
everything from that set structure (because of the `include`) as well as
a new function `add_all` that is implemented using the `add` function from the
set.

When we apply the functor, we get a very nice set data structure as a result:
```
# module ListSetNoDupsExtended = ExtendSet(ListSetNoDups);;
module ListSetNoDupsExtended :
  sig 
    type 'a t = 'a ListSetNoDups.t                                      
    val empty : 'a t
    val mem : 'a -> 'a t -> bool
    val add : 'a -> 'a t -> 'a t
    val elts : 'a t -> 'a list
    val add_all : 'a list -> 'a t -> 'a t
  end
```
Notice how the output structure records the fact that its type `t` is the
same type as the type `t` in its input structure.  They share it because
of the `include`.

Stepping back, what we just did bears more than a passing resemblance
to what you're used to doing in CS 2110 with class extension in Java.  We 
created a base module and extended its functionality with new code
while preserving its old functionality.  But whereas class extension
necessitates that the newly extended class is a subtype of the old,
and that it still has all the old functionality, OCaml functors
are more fine-grained in what they can accomplish.  We can choose
whether they include the old functionality.  And no subtyping relationships
are necessarily involved.  Moreover, the functor we wrote can be used
to extend **any** set implementation with `add_all`, whereas class
extension applies to just a **single** base class.  There are ways
of achieving something similar in Java with *mixins*, which weren't
supported before Java 1.5.