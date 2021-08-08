# Data Structures

Efficient data structures are important building blocks for large programs.
In this chapter, we'll discuss what it means to be efficient, how to
implement some efficient data structures using both imperative and
functional programming, and learn about the technique of *amortized analysis*.

Of course, we've already covered quite a few simple data structures, especially
in the [modules chapter][fds], where we used lists to implement stacks, queues,
maps, and sets. For stacks and (batched) queues, those implementations were
already efficient. But we can do much better for maps (and sets). In this
chapter we'll see efficient implementations of maps using hash tables and
red-black trees.

[fds]: ../modules/functional_data_structures

We'll also take a look at some cool functional data structures that appear less
often in imperative languages: *sequences*, which are infinite lists implemented
with functions called *thunks*; *lazy lists*, which are implemented with a
language feature (aptly called "laziness") that suspends evaluation; *promises*,
which are a way of organizing concurrent computations that has recently become
popular in imperative web programming; and *monads*, which are a way of
organizing any kind of computation that has (side) effects.