# \*Type Inference

Java and OCaml are *statically typed* languages, meaning every binding has
a type that is determined at *compile time*&mdash;that is, before any part of
the program is executed. The type-checker is a compile-time procedure
that either accepts or rejects a program. By contrast, JavaScript and
Ruby are dynamically-typed languages; the type of a binding is not
determined ahead of time and computations like binding 42 to `x` and
then treating `x` as a string result in run-time errors. 

Unlike Java, OCaml is *implicitly typed*, meaning programmers rarely need
to write down the types of bindings. This is often convenient,
especially with higher-order functions. (Although some people disagree
as to whether it makes code easier or harder to read). But implicit
typing in no way changes the fact that OCaml is statically typed. Rather,
the type-checker has to be more sophisticated because it must infer what
the *type annotations* "would have been" had the programmers written all
of them. In principle, type inference and type checking could be
separate procedures (the inferencer could figure out the types then the
checker could determine whether the program is well-typed), but in
practice they are often merged into a single procedure called
*type reconstruction*.

## OCaml type reconstruction

OCaml was rather cleverly designed so that type reconstruction is a
straightforward algorithm. At a very high level, that algorithm works as
follows:

-   Determine the types of definitions in order, using the types of earlier
    definitions to infer the types of later ones. (Which is one reason you 
    may not use a name before it is bound in an OCaml program.)

-   For each `let` definition, analyze the definition to determine
    *constraints* about its type. For example, if the inferencer sees
    `x+1`, it concludes that `x` must have type `int`. It gathers
    similar constraints for function applications, pattern matches, etc.
    Think of these constraints as a system of equations like you might
    have in algebra.

-   Use that system of equations to solve for the type of the name 
    begin defined.

The OCaml type reconstruction algorithm attempts to never reject a
program that could type-check, if the programmer had written down types.
It also attempts never to accept a program that cannot possibly type
check. Some more obscure parts of the language can sometimes make type
annotations either necessary or at least helpful (see RWO chapter 22,
"Type inference", for examples).  But for most code you write, type
annotations really are completely optional. 

Since it would be verbose to keep writing "the OCaml type reconstruction
algorithm," we'll call the algorithm HM. That name is used throughout
the programming languages literature, because the algorithm was
independently invented by Roger <u>H</u>indley and Robin <u>M</u>ilner.
In the next few sections, we'll see how HM works.

## The history of HM

HM has been rediscovered many times by many people. Curry used it
informally in the 1950's (perhaps even the 1930's). He wrote it up
formally in 1967 (published 1969). Hindley discovered it independently
in 1969; Morris in 1968; and Milner in 1978. In the realm of logic,
similar ideas go back perhaps as far as Tarski in the 1920's. Commenting
on this history, Hindley wrote,

> There must be a moral to this story of continual re-discovery;
> perhaps someone along the line should have learned to read. Or someone
> else learn to write.


## Efficiency of HM

Although we haven't seen the HM algorithm yet, you probably won't be
surprised to learn that it's usually very efficient&mdash;you've
probably never had to wait for the REPL to print the inferred types of
your programs. In practice, it runs in approximately linear time. But in
theory, there are some very strange programs that can cause its
running-time to blow up. (Technically, it's DEXPTIME-complete.) For fun,
try typing the following code in utop:

```
# let b = true;;
# let f0 = fun x -> x+1;;
# let f = fun x -> if b then f0 else fun y -> x y;;
# let f = fun x -> if b then f else fun y -> x y;;
# let f = fun x -> if b then f else fun y -> x y;;
(* keep repeating that last line *)
```

You'll see the types get longer and longer, and eventually (around
20 repetitions or so) type inference will cause a notable delay.
