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

# Randomized Testing with QCheck

{{ video_embed | replace("%%VID%%", "62SYeSlSCNM")}}

*Randomized testing* aka *fuzz testing* is the process of generating random
inputs and feeding them to a program or a function to see whether the program
behaves correctly. The immediate issue is how to determine what the correct
output is for a given input. If a *reference implementation* is
available&mdash;that is, an implementation that is believed to be correct but in
some other way does not suffice (e.g., its performance is too slow, or it is in
a different language)&mdash;then the outputs of the two implementations can be
compared. Otherwise, perhaps some *property* of the output could be checked. For
example,

* "not crashing" is a property of interest in user interfaces;

* adding $n$ elements to a data collection then removing those elements, and
  ending up with an empty collection, is a property of interest in data
  structures; and

* encrypting a string under a key then decrypting it under that key and getting
  back the original string is a property of interest in an encryption scheme
  like Enigma.

Randomized testing is an incredibly powerful technique. It is often used in
testing programs for security vulnerabilities. The [`qcheck` package][qcheck]
for OCaml supports randomized testing. We'll look at it, next, after we discuss
random number generation.

[qcheck]: https://github.com/c-cube/qcheck

## Random Number Generation

To understand randomized testing, we need to take a brief digression into random
number generation.

Most languages provide the facility to generate random numbers. In truth, these
generators are usually not truly random (in the sense that they are completely
unpredictable) but in fact are [*pseudorandom*][prng]: the sequence of numbers
they generate pass good statistical tests to ensure there is no discernible
pattern in them, but the sequence itself is a deterministic function of an
initial *seed* value. (Recall that the prefix *pseudo* is from the Greek
*pseud&emacr;s* meaning "false".) [Java][java-random] and
[Python][python-random] both provide pseudorandom number generators (PRNGs). So
does OCaml in the standard library's [`Random` module][random].

[prng]: https://en.wikipedia.org/wiki/Pseudorandom_number_generator
[java-random]: https://docs.oracle.com/javase/8/docs/api/java/util/Random.html
[python-random]: https://docs.python.org/3/library/random.html
[random]: https://ocaml.org/api/Random.html

**An Experiment.** Start a new session of utop and enter the following:

```ocaml
# Random.int 100;;
# Random.int 100;;
# Random.int 100;;
```

Each response will be an integer $i$ such that $0 \leq i < 100$.

Now quit utop and start another new session. Enter the same phrases again. You
will get the same responses as last time. In fact, unless your OCaml
installation is somehow different than that used to produce this book, you will
get the same numbers as those below:

```{code-cell} ocaml
Random.int 100;;
Random.int 100;;
Random.int 100;;
```

Not exactly unpredictable, eh?

**PRNGs.** Although for purposes of security and cryptography a PRNG leads to
terrible vulnerabilities, for other purposes&mdash;including testing and
simulation&mdash;PRNGs are just fine. Their predictability can even be useful:
given the same initial seed, a PRNG will always produce the same sequence of
pseudorandom numbers, leading to the ability to repeat a particular sequence of
tests or a particular simulation.

The way a PRNG works in general is that it initializes a *state* that it keeps
internally from the initial seed. From then on, each time the PRNG generates a
new value, it imperatively updates that state. The `Random` module makes it
possible to manipulate that state in limited ways. For example, you can

* get the current state with `Random.get_state`,

* duplicate the current state with `Random.State.copy`,

* request a random int generated from a particular state with
  `Random.State.int`, and

* initialize the state yourself. The functions `Random.self_init` and
  `Random.State.make_self_init` will choose a "random" seed to initialize the
  state. They do so by sampling from a special Unix file named
  [`/dev/urandom`][urandom], which is meant to provide as close to true
  randomness as a computer can.

[urandom]: https://en.wikipedia.org/wiki//dev/random

**Repeating the Experiment.** Start a new session of utop. Enter the following:

```ocaml
# Random.self_init ();;
# Random.int 100;;
# Random.int 100;;
# Random.int 100;;
```

Now do that a second time (it doesn't matter whether you exit utop
or not in between).  You will notice that you get a different
sequence of values.  With high probability, what you get will be different
than the values below:

```{code-cell} ocaml
Random.self_init ();;
Random.int 100;;
Random.int 100;;
Random.int 100;;
```

## QCheck Abstractions

QCheck has three abstractions we need to cover before using it for testing:
generators, properties, and arbitraries.  If you want to follow along in
utop, load QCheck with this directive:

```{code-cell} ocaml
:tags: ["remove-cell"]
#use "topfind";;
```

```{code-cell} ocaml
:tags: ["remove-output"]
#require "qcheck";;
```

**Generators.** One of the key pieces of functionality provided by QCheck is the
ability to generate pseudorandom values of various types. Here is some of the
signature of the module that does that:

```ocaml
module QCheck : sig
  ...
  module Gen :
  sig
    type 'a t = Random.State.t -> 'a
    val int : int t
    val generate : ?rand:Random.State.t -> n:int -> 'a t -> 'a list
    val generate1 : ?rand:Random.State.t -> 'a t -> 'a
    ...
  end
  ...
end
```
An `'a QCheck.Gen.t` is a function that takes in a PRNG state and uses it to
produce a pseudorandom value of type `'a`. So `QCheck.Gen.int` produces
pseudorandom integers. The function `generate1` actually does the generation of
one pseudorandom value. It takes an optional argument that is a PRNG state; if
that argument is not supplied, it uses the default PRNG state. The function
`generate` produces a list of `n` pseudorandom values.

QCheck implements many producers of pseudorandom values. Here are a few more of
them:

```ocaml
module QCheck : sig
  ...
  module Gen :
  sig
    val int : int t
    val small_int : int t
    val int_range : int -> int -> int t
    val list : 'a t -> 'a list t
    val list_size : int t -> 'a t -> 'a list t
    val string : ?gen:char t -> string t
    val small_string : ?gen:char t -> string t
    ...
  end
  ...
end
```
You can [read the documentation][qcheckdoc] of those and many others.

[qcheckdoc]: https://c-cube.github.io/qcheck/0.17/qcheck-core/QCheck/Gen/index.html

**Properties.** It's tempting to think that QCheck would enable us to test a
function by generating many pseudorandom inputs to the function, running the
function on them, then checking that the outputs are correct. But there's
immediately a problem: how can QCheck know what the correct output is for each
of those inputs? Since they're randomly generated, the test engineer can't
hardcode the right outputs.

So instead, QCheck allows us to check whether a *property* of each output holds.
A property is a function of type `t -> bool`, for some type `t`, that tells use
whether the value of type `t` exhibits some desired characteristic. Here, for
example, are two properties; one that determines whether an integer is
even, and another that determines whether a list is sorted in non-decreasing
order according to the built-in `<=` operator:

```{code-cell} ocaml
let is_even n = n mod 2 = 0

let rec is_sorted = function
  | [] -> true
  | [ h ] -> true
  | h1 :: (h2 :: t as t') -> h1 <= h2 && is_sorted t'
```

**Arbitraries.** The way we present to QCheck the outputs to be checked is with
a value of type `'a QCheck.arbitrary`. This type represents an "arbitrary" value
of type `'a`&mdash;that is, it has been pseudorandomly chosen as a value that we
want to check, and more specifically, to check whether it satisfies a property.

We can create *arbitraries* out of generators using the function
`QCheck.make : 'a QCheck.Gen.t -> 'a QCheck.arbitrary`. (Actually that function
takes some optional arguments that we elide here.) This isn't actually the
normal way to create arbitraries, but it's a simple way that will help us
understand them; we'll get to the normal way in a little while. For example, the
following expression represents an arbitrary integer:

```{code-cell} ocaml
:tags: ["hide-output"]
QCheck.make QCheck.Gen.int
```

## Testing Properties

To construct a QCheck test, we create an arbitrary and a property, and pass them
to `QCheck.Test.make`, whose type can be simplified to:

```ocaml
QCheck.Test.make : 'a QCheck.arbitrary -> ('a -> bool) -> QCheck.Test.t
```

In reality, that function also takes several optional arguments that we elide
here. The test will generate some number of arbitraries and check whether the
property holds of each of them. For example, the following code creates a QCheck
test that checks whether an arbitrary integer is even:

```{code-cell} ocaml
let t = QCheck.Test.make (QCheck.make QCheck.Gen.int) is_even
```

If we want to change the number of arbitraries that are checked, we can
pass an optional integer argument `~count` to `QCheck.Test.make`.

We can run that test with `QCheck_runner.run_tests : QCheck.Test.t list -> int`.
(Once more, that function takes some optional arguments that we elide here.) The
integer it returns is 0 if all the tests in the list pass, and 1 otherwise. For
the test above, running it will output 1 with high probability, because it will
generate at least one odd integer.

```{code-cell} ocaml
QCheck_runner.run_tests [t]
```

Unfortunately, that output isn't very informative; it doesn't tell us what
particular values failed to satisfy the property! We'll fix that problem in a
little while.

If you want to make an OCaml program that runs QCheck tests and prints the
results, there is a function `QCheck_runner.run_tests_main` that works much like
`OUnit2.run_test_tt_main`: just invoke it as the final expression in a test
file. For example:

```ocaml
let tests = (* code that constructs a [QCheck.Test.t list] *)
let _ = QCheck_runner.run_tests_main tests
```

To compile QCheck code, just add the `qcheck` library to your `dune` file:

```console
(executable
 ...
 (libraries ... qcheck))
```

QCheck tests can be converted to OUnit tests and included in the usual kind of
OUnit test suite we've been writing all along. The function that does this is:

```{code-cell} ocaml
QCheck_runner.to_ounit2_test
```

## Informative Output from QCheck

We noted above that the output of QCheck so far has told us only *whether* some
arbitraries satisfied a property, but not *which* arbitraries failed to satisfy
it. Let's fix that problem.

The issue is with how we constructed an arbitrary directly out of a generator.
An arbitrary is properly more than just a generator. The QCheck library needs to
know how to print values of the generator, and a few other things as well. You
can see that in the definition of `'a QCheck.arbitrary`:

```{code-cell} ocaml
#show QCheck.arbitrary;;
```

In addition to the generator field `gen`, there is a field containing an
optional function to print values from the generator, and a few other optional
fields as well. Luckily, we don't usually have to find a way to complete those
fields ourselves; the `QCheck` module provides many arbitraries that correspond
to the generators found in `QCheck.Gen`:

```ocaml
module QCheck :
  sig
    ...
  val int : int arbitrary
  val small_int : int arbitrary
  val int_range : int -> int -> int arbitrary
  val list : 'a arbitrary -> 'a list arbitrary
  val list_of_size : int Gen.t -> 'a arbitrary -> 'a list arbitrary
  val string : string arbitrary
  val small_string : string arbitrary
    ...
  end
```

Using those arbitraries, we can get improved error messages:

```{code-cell} ocaml
let t = QCheck.Test.make ~name:"my_test" QCheck.int is_even;;
QCheck_runner.run_tests [t];;
```

The output tells us the `my_test` failed, and shows us the input that
caused the failure.

## Testing Functions with QCheck

The final piece of the QCheck puzzle is to use a randomly generated input to
test whether a function's output satisfies some property. For example, here is a
QCheck test to see whether the output of `double` is correct:

```{code-cell} ocaml
let double x = 2 * x;;
let double_check x = double x = x + x;;
let t = QCheck.Test.make ~count:1000 QCheck.int double_check;;
QCheck_runner.run_tests [t];;
```

Above, `double` is the function we are testing. The property we're testing
`double_check`, is that `double x` is always `x + x`. We do that by having
QCheck create 1000 arbitrary integers and test that the property holds of each
of them.

Here are a couple more examples, drawn from QCheck's own documentation.  The
first checks that `List.rev` is an *involution*, meaning that applying it
twice brings you back to the original list.  That is a property that should
hold of a correct implementation of list reversal.

```{code-cell} ocaml
let rev_involutive lst = List.(lst |> rev |> rev = lst);;
let t = QCheck.(Test.make ~count:1000 (list int) rev_involutive);;
QCheck_runner.run_tests [t];;
```

Indeed, running 1000 random tests reveals that none of them fails. The `int`
generator used above generates integers uniformly over the entire range of OCaml
integers. The `list` generator creates lists whose elements are individual
generated by `int`. According to the documentation of `list`, the length of each
list is randomly generated by another generator `nat`, which generates "small
natural numbers." What does that mean? It isn't specified. But if we read the
[current source code][src-nat], we see that those are integers from 0 to 10,000,
and biased toward being smaller numbers in that range.

[src-nat]: https://github.com/c-cube/qcheck/blob/18247cf40af4272f7a2f93e273724b962db61b01/src/core/QCheck2.ml#L276


The second example checks that all lists are sorted.  Of course, not all lists
*are* sorted!  So we should expect this test to fail.

```{code-cell} ocaml
let is_sorted lst = lst = List.sort Stdlib.compare lst;;
let t = QCheck.(Test.make ~count:1000 (list small_nat) is_sorted);;
QCheck_runner.run_tests [t];;
```

The output shows an example of a list that is not sorted, hence violates the
property. Generator `small_nat` is like `nat` but ranges from 0 to 100.
