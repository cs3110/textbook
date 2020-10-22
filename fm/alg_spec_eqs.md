# Designing Algebraic Specifications

For both stacks and queues we provided some equations as the specification.
Designing those equations is, in part, a matter of thinking hard about
the data structure.  But there's more to it than that.

Every value of the data structure is constructed with some operations. For a
stack, those operations are `empty` and `push`.  There might be some `pop`
operations involved, but those can be eliminated.  For example, `pop (push 1
(push 2 empty))` is really the same stack as `push 2 empty`. The latter is the
*canonical form* of that stack:  there are many other ways to construct it, but
that is the simplest.  Indeed, every possible stack value can be constructed
just with `empty` and `push`.  Similarly, every possible queue value can
be constructed just with `empty` and `enq`:  if there are `deq` operations
involved, those can be eliminated.

Let's categorize the operations of a data structure as follows:

- **Generators** are those operations involved in creating a canonical form.
  They return a value of the data structure type.  For example,
  `empty`, `push`, `enq`.

- **Manipulators** are operations that create a value of the data structure
  type, but are not needed to create canonical forms.  For example,
  `pop`, `deq`.

- **Queries** do not return a value of the data structure type.  For example,
  `is_empty`, `peek`, `front`.

Given such a categorization, we can design the equational specification of
a data structure by applying non-generators to generators.  For example:
What does `is_empty` return on `empty`? on `push`? What does `front` return
on `enq`? What does `deq` return on `enq`? etc.

So if there are `n` generators and `m` non-generators of a data structure, we
would begin by trying to create `n*m` equations, one for each pair of a
generator and non-generator.  Each equation would show how to simplify an
expression.  In some cases we might need a couple equations, depending on the
result of some comparison.  For example, in the queue specification, we have the
following equations:

1. `is_empty empty = true`:  this is a non-generator `is_empty` applied to a
   generator `empty`.  It reduces just to a Boolean value, which doesn't 
   involve the data structure type (queues) at all.

2. `is_empty (enq x q) = false`:  a non-generator `is_empty` applied to a
   generator `enq`.  Again it reduces simply to a Boolean value.

3. There are two subcases.
   - `front (enq x q) = x`, if `is_empty q = true`.  A non-generator `front`
     applied to a generator `enq`.  It reduces to `x`, which is a smaller
     expression than the original `front (enq x q)`.
   - `front (enq x q) = front q`, `if is_empty q = false`.  This similarly
     reduces to a smaller expression.

4. Again, there are two subcases.
   - `deq (enq x q) = empty`, if `is_empty q = true`.  This simplifies
     the original expression by reducing it to `empty`.
   - `deq (enq x q) = enq x (deq q)`, if `is_empty q = false`.  This simplifies
     the original expression by reducing it to an generator applied to a
     smaller argument, `deq q` instead of `deq (enq x q)`.

We don't usually design equations involving pairs of non-generators.  Sometimes
pairs of generators are needed, though, as we will see in the next example.

## Example: Sets

Here is a small interface for sets:
```
module type Set = sig
  type 'a t
  val empty : 'a t
  val is_empty : 'a t -> bool
  val add : 'a -> 'a t -> 'a t
  val mem : 'a -> 'a t -> bool
  val remove : 'a -> 'a t -> 'a t
end
```

The generators are `empty` and `add`.  The only manipulator is `remove`.
Finally, `is_empty` and `mem` are queries.  So we should expect at least 2 * 3 =
6 equations, one for each pair of generator and non-generator. Here is an
equational specification:

```
1.  is_empty empty = true
2.  is_empty (add x s) = false
3.  mem x empty = false
4a. mem y (add x s) = true                    if x = y
4b. mem y (add x s) = mem y s                 if x <> y
5.  remove x empty = empty
6a. remove y (add x s) = remove y s           if x = y
6b. remove y (add x s) = add x (remove y s)   if x <> y
```

Consider, though, these two sets:
- `add 0 (add 1 empty)`
- `add 1 (add 0 empty)`

They both intuitively represent the set {0,1}.  Yet, we cannot prove
that those two sets are equal using the above specification.  We are
missing an equation involving two generators:

```
7.  add x (add y s) = add y (add x s)
```
