# \*QCheck

*This section of the textbook is optional.*

One of the key pieces of functionality provided by QCheck is the ability
to generate pseudorandom values of various types.  Here is some of the
signature of the module that does that:
```
module QCheck : sig
  ...
  module Gen : 
	sig
	  type 'a t = Random.State.t -> 'a
	  val int : int t
	  val generate  : ?rand:Random.State.t -> n:int -> 'a t -> 'a list
	  val generate1 : ?rand:Random.State.t          -> 'a t -> 'a
	  ...
	end
  ...
end
```
An `'a QCheck.Gen.t` is a function that takes in a PRNG state and uses
it to produce a pseudorandom value of type `'a`.  So `QCheck.Gen.int`
produces pseudorandom integers. The function `generate1`
actually does the generation of one pseudorandom value.  It takes an
optional argument that is a PRNG state; if that argument is not
supplied, it uses the default PRNG state.  The function `generate`
produces a list of `n` pseduorandom values.

QCheck implements many producers of pseudorandom values.  Here are a few more of them:
```
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

[qcheckdoc]: https://c-cube.github.io/qcheck/

## Properties and Arbitraries

There are two more ideas we need to understand before we can get to testing with
QCheck:  properties and arbitraries.

**Properties.**
It's tempting to think that QCheck would enable us to test a function by
generating many pseudorandom inputs to the function, running the
function on them, then checking that the outputs are correct.  But
there's immediately a problem: how can QCheck know what the correct
output is for each of those inputs?  Since they're randomly generated,
the test engineer can't hardcode the right outputs, as we've usually
been doing with OUnit test suites this semester.

So instead, QCheck allows us to check whether a *property* of each
output holds.  A property is a function of type `t -> bool`, for some
type `t`, that tells use whether the value of type `t` exhibits some
desired characteristic. Here, for example, here are two properties; one
that determines whether an integer is even, and another that determines
whether a list is sorted in non-decreasing order according to the
built-in `<=` operator:
```
let is_even n = 
  n mod 2 = 0

let rec is_sorted = function
  | [] -> true
  | [h] -> true
  | h1::(h2::t as t') -> h1 <= h2 && is_sorted t'
```

**Arbitraries.**
The way we present to QCheck the outputs to be checked is with a value
of type `'a QCheck.Arbitrary`.  This type represents an "arbitrary"
value of type `'a`&mdash;that is, it has been pseudorandomly chosen as a
value that we want to check, and more specifically, to check whether it
satisfies a property.

We can create *arbitraries* (as we'll call them) out of generators using
the function `QCheck.make : 'a QCheck.Gen.t -> 'a QCheck.arbitrary`.
(Actually that function takes some optional arguments that we elide
here.) This isn't actually the normal way to create arbitraries, but
it's a simple way that will help us understand them; we'll get to the
normal way in a little while.  For example, the following expression
represents an arbitrary integer:
```
QCheck.make QCheck.Gen.int
```

## Testing Properties with QCheck

To construct a QCheck test, we create an arbitrary and a property, and pass them
to `QCheck.Test.make : 'a QCheck.arbitrary -> ('a -> bool) -> QCheck.Test.t`.
(That function also takes some optional arguments that we elide here.) The test
will generate some number of arbitraries and check whether the property holds of
each of them. For example, the following code creates a QCheck test that checks
whether an arbitrary integer is even:
```
let t = QCheck.Test.make (QCheck.make QCheck.Gen.int) is_even
```
If we want to change the number of arbitraries that are checked, we can
pass an optional integer argument `~count` to `QCheck.Test.make`.

We can run that test with `QCheck_runner.run_tests : QCheck.Test.t list -> int`.
(Once more, that function takes some optional arguments that we elide here.)
The integer it returns is 0 if all the tests in the list pass, and 1 otherwise.
For the test above, running it will output 1 with high probability,
because it will generate at least one odd integer.  The output would look
like the following:
```
# QCheck_runner.run_tests [t];;
  test `<test>` failed on >= 1 cases: <instance>                                                                                                                 failure (1 tests failed, ran 1 tests)                                           
- : int = 1
```
Unfortunately, that output isn't very informative; it doesn't tell us what particular
values failed to satisfy the property!  We'll fix that problem in a little while.

If you want to make an OCaml program that runs QCheck tests and prints
the results, there is a function `QCheck_runner.run_tests_main` that works
much like `OUnit2.run_test_tt_main`:  just invoke it as the final
expression in a test file.  For example:
```
let tests = (* code that constructs a [QCheck.Test.t list] *)

let _ = QCheck_runner.run_tests_main tests
```
If that code is in a file `test_x.ml`, you can compile and run it as follows:
```
$ ocamlbuild -pkg qcheck test_x.byte
$ ./test_x.byte
```

QCheck tests can be converted to OUnit tests and included in the usual kind
of OUnit test suite we've been writing all along.  The function
that does this is `QCheck_runner.to_ounit2_test : QCheck.Test.t -> OUnit2.test`.

## Informative Output

We noted above that the output of QCheck so far has told us only *whether*
some arbitraries satisfied a property, but not *which* arbitraries failed
to satisfy it.  Let's fix that problem.

The issue is with how we constructed an arbitrary directly out of a generator.
An arbitrary is properly more than just a generator.  The QCheck library needs 
to know how to print values of the generator, and a few other things as well.
You can see that in the definition of `'a QCheck.arbitrary`:
```
module QCheck :
  ...
  sig 
	type 'a arbitrary = {
	  gen : 'a QCheck.Gen.t;
	  print : ('a -> string) option;                                                
	  small : ('a -> int) option;
	  shrink : 'a QCheck.Shrink.t option;
	  collect : ('a -> string) option;
	}
	...
  end
```
In addition to the generator field `gen`, there is a field containing an optional
function to print values from the generator, and a few other optional fields as well.
Luckily, we don't usually have to find a way to complete those fields ourselves;
the `QCheck` module provides many arbitraries that correspond to the generators
found in `QCheck.Gen`:
```
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
```
# let t = QCheck.Test.make QCheck.int is_even;;
# QCheck_runner.run_tests [t];;
  test `<test>` failed on >= 1 cases: 2227842673298200061                                                                                                        
failure (1 tests failed, ran 1 tests)                                                                                                               failure (1 tests failed, ran 1 tests)                                           
- : int = 1
```

The final piece of less-than-informative output in that message, `<test>`,
is there because we haven't given the test case a name.  We can do that
by passing the optional argument `~name` to `QCheck.Test.make`.

## Testing functions with QCheck

So far we've used QCheck only to test whether a randomly generated value
satisfies some property.  We haven't tried to use that value as input
to a function of interest&mdash;the function we really want to test&mdash;and
see whether the function's output satisfies a property.  Let's do that now.

Here is a QCheck test to see whether the output of `double` is correct:
```
let double x = 2 * x

let t = QCheck.Test.make QCheck.int
         (fun x ->
            let y = double x
            in y = 2*x)
```

Note how the property we pass to `QCheck.Test.make` takes in a value (which 
will be value generated by `QCheck.int`), computes a function of that value
(`double x`), then checks whether that computed output satisfies a property
of interest (equals `2*x`).
