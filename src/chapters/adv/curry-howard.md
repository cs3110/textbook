---
jupytext:
  cell_metadata_filter: -all
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.10.3
kernelspec:
  display_name: OCaml
  language: OCaml
  name: ocaml-jupyter
---

# The Curry-Howard Correspondence

```{note}
A *lagniappe* is a small and unexpected gift &mdash; a little "something extra".
Please enjoy this little chapter, which contains one of the most beautiful
results in the entire book. It is based on the paper
[Propositions as Types][pat] by Philip Wadler. You can watch an entertaining
[recorded lecture][pat-lambda-days] by Prof. Wadler on it, in addition
to our lecture below.
```

{{ video_embed | replace("%%VID%%", "GdcOy6zVFC4")}}

As we observed long ago, OCaml is a language in the ML family, and ML was
originally designed as the <u>m</u>eta <u>l</u>anguage for a theorem
prover&mdash;that is, a computer program designed to help prove and check the
proofs of logical formulas. When constructing proofs, it's desirable to make
sure that you can only prove true formulas, to make sure that you don't make
incorrect arguments, etc.

The dream would be to have a computer program that can determine the truth or
falsity of any logical formula. For some formulas, that is possible. But, one of
the groundbreaking results in the early 20th century was that it is *not*
possible, in general, for a computer program to do this. Alonzo Church and Alan
Turing independently showed this in 1936. Church used the *lambda calculus* as a
model for computers; Turing used what we now call *Turing machines*. The
*Church-Turing thesis* is a hypothesis that says the lambda calculus and Turing
machines both formalize what "computation" informally means.

Instead of focusing on that impossible task, we're going to focus on the
relationship between proofs and programs. It turns out the two are deeply
connected in a surprising way.

## Computing with Evidence

We're accustomed to OCaml programs that manipulate data, such as integers and
variants and functions. Those data values are always typed: at compile time,
OCaml infers (or the programmer annotates) the types of expressions. For
example, `3110 : int`, and `[] : 'a list`. We long ago learned to read those as
"`3110` has type `int`", and "`[]` has type `'a list`".

Let's try a different reading now. Instead of "has type", let's read "is
evidence for". So, `3110` is evidence for `int`. What does that mean? Think of a
type as a set of values. So, `3110` is evidence that type is not empty.
Likewise, `[]` is evidence that the type `'a list` is not empty. We say that the
type is *inhabited* if it is not empty.

Are there empty types? There actually is one in OCaml, though we've never had
reason to mention it before. It's possible to define a variant type that has no
constructors:

```{code-cell} ocaml
type empty = |
```

We could have called that type anything we wanted instead of `empty`; the
special syntax there is just writing `|` instead of actual constructors. (Note,
that syntax might give some editors some trouble. You might need to put
double-semicolon after it to get the formatting right.) It is impossible to
construct a value of type `empty`, exactly because it has no constructors. So,
`empty` is not inhabited.

Under our new reading based on evidence, we could think about functions as ways
to manipulate and transform evidence&mdash;just as we are already accustomed to
thinking about functions as ways to manipulate and transform data. For example,
the following functions construct and destruct pairs:

```{code-cell} ocaml
let pair x y = (x, y)
let fst (x, y) = x
let snd (x, y) = y
```

We could think of `pair` as a function that takes in evidence for `'a` and
evidence for `'b`, and gives us back evidence for `'a * 'b`. That latter piece
of evidence is the pair `(x, y)` containing the individual pieces of evidence,
`x` and `y`. Similarly, `fst` and `snd` extract the individual pieces of
evidence from the pair. Thus,

- If you have evidence for `'a` and evidence for `'b`, you can produce evidence
  for `'a` and `'b`.
- If you have evidence for `'a` and `'b`, then you can produce evidence for
  `'a`.
- If you have evidence for `'a` and `'b`, then you can produce evidence for
  `'b`.

In learning to do proofs (say, in a discrete mathematics class), you will
have learned that in order to prove two statements hold, you individually
have to prove that each holds.  That is, to prove the conjunction of A and B,
you must prove A as well as prove B.  Likewise, if you have a proof of the
conjunction of A and B, then you can conclude A holds, and you can conclude B
holds.  We can write those patterns of reasoning as logical formulas, using
`/\` to denote conjunction and `->` to denote implication:

```text
A -> B -> A /\ B
A /\ B -> A
A /\ B -> B
```

Proofs are a form of evidence:  they are logical arguments about the truth
of a statement.  So another reading of those formulas would be:

- If you have evidence for A and evidence for B, you can produce evidence
  for A and B.
- If you have evidence for A and B, then you can produce evidence for A.
- If you have evidence for A and B, then you can produce evidence for B.

Notice how we now have given the same reading for programs and for proofs. They
are both ways of manipulating and transforming evidence. In fact, take a close
look at the types for `pair`, `fst`, and `snd` compared to the logical formulas
that describe valid patterns of reasoning:

```text
val pair : 'a -> 'b -> 'a * 'b         A -> B -> A /\ B
val fst : 'a * 'b -> 'a                A /\ B -> A
val snd : 'a * 'b -> 'b                A /\ B -> B
```

If you replace `'a` with A, and `'b` with B, and `*` with `/\`, **the types of
the programs are identical to the formulas!**

## The Correspondence

What we have just discovered is that computing with evidence corresponds to
constructing valid logical proofs. This correspondence is not just an accident
that occurs with these three specific programs. Rather, it is a deep phenomenon
that links the fields of programming and logic. Aspects of it have been
discovered by many people working in many areas. So, it goes by many names. One
common name is *the Curry-Howard correspondence*, named for logicians Haskell
Curry (for whom the functional programming language Haskell is named) and
William Howard. This correspondence links ideas from programming to ideas from
logic:

- Types correspond to logical formulas (aka *propositions*).
- Programs correspond to logical proofs.
- Evaluation corresponds to simplification of proofs.

We've already seen the first two of those correspondences. The types of our
three little programs corresponded to formulas, and the programs themselves
corresponded to the reasoning done in proofs involving conjunctions. We haven't
seen the third yet; we will later.

Let's dig into each of the correspondences to appreciate them more fully.

## Types Correspond to Propositions

In *propositional logic*, formulas are created with atomic propositions,
negation, conjunction, disjunction, and implication. The following BNF describes
propositional logic formulas:

```text
p ::= atom
    | ~ p      (* negation *)
    | p /\ p   (* conjunction *)
    | p \/ p   (* disjunction *)
    | p -> p   (* implication *)

atom ::= <identifiers>
```

For example, `raining /\ snowing /\ cold` is a proposition stating that it is
simultaneously raining and snowing and cold (a weather condition known as
[*Ithacating*][ithacating]). An atomic proposition might hold of the world, or
not. There are two distinguished atomic propositions, written `true` and
`false`, which are always hold and never hold, respectively.

[ithacating]: https://www.urbandictionary.com/define.php?term=Ithacating

All these *connectives* (so-called because they connect formulas together) have
correspondences in the types of functional programs.

**Conjunction.** We have already seen that the `/\` connective corresponds to
the `*` type constructor. Proposition `A /\ B` asserts the truth of both `A` and
`B`. An OCaml value of type `a * b` contains values both of type `a` and `b`.
Both `/\` and `*` thus correspond to the idea of pairing or products.

**Implication.** The implication connective `->` corresponds to the function
type constructor `->`. Proposition `A -> B` asserts that if you can show that
`A` holds, then you can show that `B` holds. In other words, by assuming `A`,
you can conclude `B`. In a sense, that means you can transform `A` into `B`. An
OCaml value of type `a -> b` expresses that idea even more clearly. Such a value
is a function that transforms a value of type `a` into a value of type `b`.
Thus, if you can show that `a` is inhabited (by exhibiting a value of that
type), you can show that `b` is inhabited (by applying the function of type
`a -> b` to it). So, `->` corresponds to the idea of transformation.

**Disjunction.** The disjunction connective `\/` corresponds to something a
little more difficult to express concisely in OCaml. Proposition `A \/ B`
asserts that either you can show `A` holds or `B` holds. Let's strengthen that
to further assert that in addition to showing *one* of them holds, you have to
specify *which one* you are showing. Why would that matter?

Suppose we were working on a proof of the *twin prime conjecture*, an unsolved
problem that states there are infinitely many twin primes (primes of the form
$n$ and $n+2$, such as 3 and 5, or 5 and 7). Let the atomic proposition `TP`
denote that there are infinitely many twin primes. Then the proposition
`TP \/ ~ TP` seems reasonable: either there are infinitely many twin primes, or
there aren't. We wouldn't even have to figure out how to prove the conjecture!
But if we strengthen the meaning of `\/` to be that we have to state *which one*
of the sides, left or right, holds, then we would either have to give a proof or
disproof of the conjecture. No one knows how to do that currently. So we could
not prove `TP \/ ~ TP`.

Henceforth we will use `\/` in that stronger sense of having to identify whether
we are giving a proof of the left or the right side proposition. Thus, we can't
necessarily conclude `p \/ ~ p` for any proposition `p`: it will matter whether
we can prove `p` or `~ p` on their own. Technically, this makes our
propositional logic *constructive* rather than *classical*. In constructive
logic we must construct the proof of the individual propositions. Classical
logic (the traditional way `\/` is understood) does not require that.

Returning to the correspondence between disjunction and variants, consider this
variant type:

```{code-cell} ocaml
type ('a, 'b) disj = Left of 'a | Right of 'b
```

A value `v` of that type is either `Left a`, where `a : 'a`; or `Right b`, where
`b : 'b`. That is, `v` identifies (i) whether it is tagged with the left
constructor or the right constructor, and (ii) carries within it exactly one
sub-value of type either `'a` or `'b`&mdash;not two subvalues of both types,
which is what `'a * 'b` would be.

Thus, the (constructive) disjunction connective `\/` corresponds to the `disj`
type constructor. Proposition `A \/ B` asserts that either `A` or `B` holds as
well as which one, left or right, it is. An OCaml value of type `('a, 'b) disj`
similarly contains a value of type either `'a` or `'b` as well as identifying
(with the `Left` or `Right` constructor) which one it is. Both `\/` and `disj`
therefore correspond to the idea of unions.

**Truth and Falsity** The atomic proposition `true` is the only proposition that
is guaranteed to always hold. There are many types in OCaml that are always
inhabited, but the simplest of all of them is `unit`: there is one value `()` of
type `unit`. So the proposition `true` (best) corresponds to the type `unit`.

Likewise, the atomic proposition `false` is the only proposition that is
guaranteed to never hold. That corresponds to the `empty` type we introduced
earlier, which has no constructors. (Other names for that type could include
`zero` or `void`, but we'll stick with `empty`.)

There is a subtlety with `empty` that we should address. The type has no
constructors, but it is nonetheless possible to write expressions that have type
`empty`. Here is one way:

```{code-cell} ocaml
let rec loop x = loop x
```

Now if you enter this code in utop you will get no response:

```ocaml
let e : empty = loop ()
```

That expression type checks successfully, then enters an infinite loop. So,
there is never any value of type `empty` that is produced, even though the
expression has that type.

Here is another way:

```{code-cell} ocaml
:tags: ["raises-exception"]
let e : empty = failwith ""
```

Again, the expression type checks, but it never produces an actual value of type
`empty`. Instead, this time an exception is produced.

So the type `empty` is not inhabited, even though there are some expressions of
that type. But, **if we require programs to be total**, we can rule out those
expressions. That means eliminating programs that raise exceptions or go into an
infinite loop. We did in fact make that requirement when we started discussing
formal methods, and we will continue to assume it.

**Negation.** This connective is the trickiest. Let's consider negation to
actually be syntactic sugar. In particular, let's say that the propositional
formula `~ p` actually means this formula instead: `p -> false`. Why? The
formula `~ p` should mean that `p` does not hold. So if `p` *did* hold, then it
would lead to a contradiction. Thus, given `p`, we could conclude `false`. This
is the standard way of understanding negation in constructive logic.

Given that syntactic sugar, `~ p` therefore corresponds to a function type whose
return type is `empty`. Such a function could never actually return. Given our
ongoing assumption that programs are total, that must mean it's impossible to
even call that function. So, it must be impossible to construct a value of the
function's input type. Negation therefore corresponds to the idea of
impossibility, or contradiction.

**Propositions as types.** We have now created the following correspondence that
enables us to read propositions as types:

- `/\` and `*`
- `->` and `->`
- `\/` and `disj`
- `true` and `unit`
- `false` and `empty`
- `~` and `... -> false`

But that is only the first level of the Curry-Howard correspondence. It goes
deeper...

## Programs Correspond to Proofs

We have seen that programs and proofs are both ways to manipulate and transform
evidence. In fact, every program **is** a proof that the type of the program is
inhabited, since the type checker must verify that the program is well typed.

The details of type checking, though, lead to an even more compelling
correspondence between programs and proofs. Let's restrict our attention to
programs and proofs involving just conjunction and implication, or equivalently,
pairs and functions. (The other propositional connectives could be included as
well, but require additional work.)

**Type checking rules.** For type checking, we gave many *rules* to define when
a program is well typed. Here are rules for variables, functions, and pairs:

```text
{x : t, ...} |- x : t
```
A variable has whatever type the environment says it has.

```text
env |- fun x -> e : t -> t'
if env[x -> t] |- e : t'
```

An anonymous function `fun x -> e` has type `t -> t'` if `e` has type `t'` in a
static environment extended to bind `x` to type `t`.

```text
env |- e1 e2 : t'
if env |- e1 : t -> t'
and env |- e2 : t
```

An application `e1 e2` has type `t'` if `e1` has type `t -> t'` and `e2` has
type `t`.

```text
env |- (e1, e2) : t1 * t2
if env |- e1 : t1
and env |- e2 : t2
```

The pair `(e1, e2)` has type `t1 * t2` if `e1` has type `t1` and `e2` has
type `t2`.

```text
env |- fst e : t1
if env |- e : t1 * t2

env |- snd e : t2
if env |- e : t1 * t2
```

If `e` has type `t1 * t2`, then `fst e` has type `t1`, and `snd e` has type
`t2`.

**Proof trees.** Another way of expressing those rules would be to draw *proof
trees* that show the recursive application of rules. Here are those proof trees:

```text

---------------------
{x : t, ...} |- x : t


   env[x -> t1] |- e2 : t2
-----------------------------
env |- fun x -> e2 : t1 -> t2


env |- fun x -> e2 : t1 -> t2        env |- e1 : t1
---------------------------------------------------
          env |- (fun x -> e2) e1 : t2


env |- e1 : t1         env |- e2 : t2
-------------------------------------
     env |- (e1, e2) : t1 * t2


env |- e : t1 * t2
------------------
env |- fst e : t1


env |- e : t1 * t2
------------------
env |- snd e : t2
```

**Proof trees, logically.** Let's rewrite each of those proof trees to eliminate
the programs, leaving only the types. At the same time, let's use the
propositions-as-types correspondence to re-write the types as propositions:

```text

-----------
env, p |- p


 env, p1 |- p2
---------------
env |- p1 -> p2


env |- p1 -> p2     env |- p1
-----------------------------
        env |- p2


env |- p1      env |- p2
------------------------
    env |- p1 /\ p2


env |- p1 /\ p2
---------------
   env |- p1


env |- p1 /\ p2
---------------
   env |- p2
```

Each rule can now be read as a valid form of logical reasoning. Whenever we
write `env |- t`, it means that "from the assumptions in `env`, we can conclude
`p` holds". A rule, as usual, means that from all the premisses above the line,
the conclusion below the line holds.

**Proofs and programs.** Now consider the following proof tree, showing the
derivation of the type of a program:

```text
------------------------           ------------------------
{p : a * b} |- p : a * b           {p : a * b} |- p : a * b
------------------------           ------------------------
{p : a * b} |- snd p : b           {p : a * b} |- fst p : a
-----------------------------------------------------------
        {p : a * b} |- (snd p, fst p) : b * a
     ----------------------------------------------
     {} |- fun p -> (snd p, fst p) : a * b -> b * a
```

That program shows that you can swap the components of a pair, thus
swapping the types involved.

If we erase the program, leaving only the types, and re-write those
as propositions, we get this proof tree:

```text
----------------           ----------------
a /\ b |- a /\ b           a /\ b |- a /\ b
----------------           ----------------
  a /\ b |- b                a /\ b |- a
-------------------------------------------
              a /\ b |- b /\ a
           ----------------------
           {} |- a /\ b -> b /\ a
```

And that is a valid proof tree for propositional logic. It shows that you can
swap the sides of a conjunction.

What we see from those two proof trees is: **a program is a proof**. A
well-typed program corresponds to the proof of a logical proposition. It shows
how to compute with evidence, in this case transforming a proof of `a /\ b` into
a proof of `b /\ a`.

**Programs are proofs.** We have now created the following correspondence that
enables us to read programs as proofs:

- A program `e : t` corresponds to a proof of the logical formula to which `t`
  itself corresponds.
- The proof tree of `|- t` corresponds to the proof tree of `{} |- e : t`.
- The proof rules for typing a program correspond to the rules for proving a
  proposition.

But that is only the second level of the Curry-Howard correspondence. It goes
deeper...

## Evaluation Corresponds to Simplification

We will treat this part of the correspondence only briefly. Consider the
following program:

```ocaml
fst (a, b)
```

That program would of course evaluate to `a`.

Next, consider the typing derivation of that program.  The variables `a` and
`b` must be bound to some types in the static environment for the program
to type check.

```text
------------------------         -------------------------
{a : t, b : t'} |- a : t         {a : t, b : t'} |- b : t'
----------------------------------------------------------
         {a : t, b : t'} |- (a, b) : t * t'
         ----------------------------------
         {a : t, b : t'} |- fst (a, b) : t
```

Erasing that proof tree to just the propositions, per the proofs-as-programs
correspondence, we get this proof tree:
```text
-----------            -----------
t, t' |-  t            t, t' |- t'
----------------------------------
         t, t' |- t /\ t'
         ----------------
            t, t' |- t
```

However, there is a much simpler proof tree with the same conclusion:

```text
----------
t, t' |- t
```

In other words, we don't need the detour through proving `t /\ t'` to prove `t`,
if `t` is already an assumption. We can instead just directly conclude `t`.

Likewise, there is a simpler typing derivation corresponding to that same
simpler proof:

```text
------------------------
{a : t, b : t'} |- a : t
```

Note that typing derivation is for the program `a`, which is exactly what the
bigger program `fst (a, b)` evaluates to.

Thus, evaluation of the program causes the proof tree to simplify, and the
simplified proof tree is actually (through the proofs-as programs
correspondence) a simpler proof of the same proposition. **Evaluation therefore
corresponds to proof simplification.** And that is the final level of the
Curry-Howard correspondence.

## What It All Means

Logic is a fundamental aspect of human inquiry.  It guides us in reasoning about
the world, in drawing valid inferences, in deducing what must be true vs. what
must be false.  Training in logic and argumentation&mdash;in various fields and
disciplines&mdash;is one of the most important parts of a higher education.

The Curry-Howard correspondence shows that logic and computation are
fundamentally linked in a deep and maybe even mysterious way. The basic building
blocks of logic (propositions, proofs) turn out to correspond to the basic
building blocks of computation (types, functional programs). Computation itself,
the evaluation or simplification of expressions, turns out to correspond to
simplification of proofs. The very task that computers do therefore is the same
task that humans do in trying to present a proof in the best possible way.

Computation is thus intrinsically linked to reasoning. And functional
programming is a fundamental part of human inquiry.

Could there *be* a better reason to study functional programming?

[pat]: http://homepages.inf.ed.ac.uk/wadler/papers/propositions-as-types/propositions-as-types.pdf
[pat-lambda-days]: https://www.youtube.com/watch?v=aeRVdYN6fE8

## Exercises

{{ solutions }}

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "propositions as types")}}

For each of the following propositions, write its corresponding type
in OCaml.

- `true -> p`
- `p /\ (q /\ r)`
- `(p \/ q) \/ r`
- `false -> p`

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "programs as proofs")}}

For each of the following propositions, determine its corresponding type in
OCaml, then write an OCaml `let` definition to give a program of that type. Your
program proves that the type is *inhabited*, which means there is a value of
that type. It also proves the proposition holds.

- `p /\ q -> q /\ p`
- `p \/ q -> q \/ p`

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "evaluation as simplification")}}

Consider the following OCaml program:

```ocaml
let f x = snd ((fun x -> x, x) (fst x))
```

- What is the type of that program?
- What is the proposition corresponding to that type?
- How would `f (1,2)` evaluate in the small-step semantics?
- What simplified implementation of `f` does that evaluation suggest? (or
  perhaps there are several, though one is probably the simplest?)
- Does your simplified `f` still have the same type as the original? (It
  should.)

Your simplified `f` and the original `f` are both proofs of the same
proposition, but evaluation has helped you to produce a simpler proof.
