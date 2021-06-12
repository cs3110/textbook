# The Past of OCaml

Genealogically, OCaml comes from the line of programming languages whose
grandfather is Lisp and includes other modern languages such as Clojure, F#,
Haskell, and Racket.

OCaml originates from work done by Robin Milner and others at the Edinburgh
Laboratory for Computer Science in Scotland. They were working on theorem
provers in the late 1970s and early 1980s. Traditionally, theorem provers were
implemented in languages such as Lisp. Milner kept running into the problem that
the theorem provers would sometimes put incorrect "proofs" (i.e., non-proofs)
together and claim that they were valid. So he tried to develop a language that
only allowed you to construct valid proofs. ML, which stands for "Meta
Language", was the result of that work. The type system of ML was carefully
constructed so that you could only construct valid proofs in the language. A
theorem prover was then written as a program that constructed a proof.
Eventually, this "Classic ML" evolved into a full-fledged programming language.

In the early '80s, there was a schism in the ML community with the French on one
side and the British and US on another. The French went on to develop CAML and
later Objective CAML (OCaml) while the Brits and Americans developed Standard
ML. The two dialects are quite similar. Microsoft introduced its own variant of
OCaml called F# in 2005.

Milner received the Turing Award in 1991 in large part for his work on ML.
The [ACM website for his award][turing-milner] includes this praise:

> ML was way ahead of its time. It is built on clean and well-articulated
> mathematical ideas, teased apart so that they can be studied
> independently and relatively easily remixed and reused. ML has
> influenced many practical languages, including Java, Scala, and
> Microsoft's F#. Indeed, no serious language designer should ignore this
> example of good design.

[turing-milner]: https://amturing.acm.org/award_winners/milner_1569367.cfm
