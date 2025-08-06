# Concurrency

So far we have only considered *sequential* programs.
Execution of a sequential program proceeds one step at a time, with no choice about which step to take next.
Sequential programs are limited in that they are not very good at dealing with multiple sources of simultaneous input, and they can only execute on a single processor.
Many modern applications are instead *concurrent*.

In this chapter, we will learn about *promises*, which are a way of organizing concurrent computations that has recently become popular in imperative web programming.
We'll see an OCaml library called Lwt that implements promises.
That library is based in part on the concept of *monads*, which are a way of organizing any kind of computation that has (side) effects, so we'll finish the chapter by examining monads.