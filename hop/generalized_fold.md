# Generalized Folds

The technique we used to derive `foldtree` works for any OCaml variant type `t`:

* Write a recursive `fold` function that takes in one argument for each 
  constructor of `t`.

* That `fold` function matches against the constructors, calling itself 
  recursively on any value of type `t` that it encounters.

* Use the appropriate argument of `fold` to combine the results of all recursive
  calls as well as all data not of type `t` at each constructor.
  
This technique constructs something called a *catamorphism*, aka a *generalized fold
operation*.  To learn more about catamorphisms, take a course on category theory,
such as CS 6117.
