# Unit Testing with OUnit

```{note}
This section is a bit of a detour from our study of data types, but it's a good
place to take the detour: we now know just enough to understand how unit testing
can be done in OCaml, and there's no good reason to wait any longer to learn
about it.
```

Using the toplevel to test functions will only work for very small programs.
Larger programs need *test suites* that contain many *unit tests* and can be
re-run every time we update our code base. A unit test is a test of one small
piece of functionality in a program, such as an individual function.

We've now learned enough features of OCaml to see how to do unit testing with a
library called OUnit. It is a unit testing framework similar to JUnit in Java,
HUnit in Haskell, etc. The basic workflow for using OUnit is as follows:

* Write a function in a file `f.ml`. There could be many other functions in that
  file too.

* Write unit tests for that function in a separate file `test.ml`. That exact
  name is not actually essential.

* Build and run `test` to execute the unit tests.

The [OUnit documentation][ounitdoc] is available on Github.

[ounitdoc]: https://gildor478.github.io/ounit/ounit2/index.html

## An Example of OUnit

The following example shows you how to create an OUnit test suite. There are
some things in the example that might at first seem mysterious; they are
discussed in the next section.

Create a new directory. In that directory, create a file named `sum.ml`, and put
the following code into it:
```ocaml
let rec sum = function
  | [] -> 0
  | x :: xs -> x + sum xs
```

Now create a second file named `test.ml`, and put this code into it:
```ocaml
open OUnit2
open Sum

let tests = "test suite for sum" >::: [
  "empty" >:: (fun _ -> assert_equal 0 (sum []));
  "singleton" >:: (fun _ -> assert_equal 1 (sum [1]));
  "two_elements" >:: (fun _ -> assert_equal 3 (sum [1; 2]));
]

let _ = run_test_tt_main tests
```

Depending on your editor and its configuration, you probably now see some
"Unbound module" errors about OUnit2 and Sum. Don't worry; the code is actually
correct. We just need to set up dune and tell it to link OUnit. Create a `dune`
file and put this in it:

```text
(executable
 (name test)
 (libraries ounit2))
```

Now build the test suite:

```console
$ dune build test.exe
```

Go back to your editor and do anything that will cause it to revisit `test.ml`.
You can close and re-open the window, or make a trivial change in the file
(e.g., add then delete a space). Now the errors should all disappear.

Finally, you can run the test suite:

```console
$ dune exec ./test.exe
```

You will get a response something like this:

```text
...
Ran: 3 tests in: 0.12 seconds.
OK
```

Now suppose we modify `sum.ml` to introduce a bug by changing the code
in it to the following:
```ocaml
let rec sum = function
  | [] -> 1 (* bug *)
  | x :: xs -> x + sum xs
```

If rebuild and re-execute the test suite, all test cases now fail. The output
tells us the names of the failing cases. Here's the beginning of the output, in
which we've replaced some strings that will be dependent on your own local
computer with `...`:
```
FFF
==============================================================================
Error: test suite for sum:2:two_elements.

File ".../_build/oUnit-test suite for sum-...#01.log", line 9, characters 1-1:
Error: test suite for sum:2:two_elements (in the log).

Raised at OUnitAssert.assert_failure in file "src/lib/ounit2/advanced/oUnitAssert.ml", line 45, characters 2-27
Called from OUnitRunner.run_one_test.(fun) in file "src/lib/ounit2/advanced/oUnitRunner.ml", line 83, characters 13-26

not equal
------------------------------------------------------------------------------
```

The first line of that output
```
FFF
```
tells us that OUnit ran three test cases and all three <u>f</u>ailed.

The next interesting line
```
Error: test suite for sum:2:two_elements.
```
tells us that in the test suite named `test suite for sum` the test case at
index 2 named `two_elements` failed. The rest of the output for that test case
is not particularly interesting; let's ignore it for now.

## Explanation of the OUnit Example

Let's study more carefully what we just did in the previous section. In the test
file, `open OUnit2` brings into scope the many definitions in OUnit2, which is
version 2 of the OUnit framework. And `open Sum` brings into scope the
definitions from `sum.ml`. We'll learn more about scope and the `open` keyword
later in a later chapter.

Then we created a list of test cases:
```ocaml
[
  "empty"  >:: (fun _ -> assert_equal 0 (sum []));
  "one"    >:: (fun _ -> assert_equal 1 (sum [1]));
  "onetwo" >:: (fun _ -> assert_equal 3 (sum [1; 2]));
]
```
Each line of code is a separate test case.  A test case has a string giving it a
descriptive name, and a function to run as the test case.  In between the name
and the function we write `>::`, which is a custom operator defined by the OUnit
framework.  Let's look at the first function from above:
```
fun _ -> assert_equal 0 (sum [])
```
Every test case function receives as input a parameter that OUnit calls a *test
context*. Here (and in many of the test cases we write) we don't actually need
to worry about the context, so we use the underscore to indicate that the
function ignores its input. The function then calls `assert_equal`, which is a
function provided by OUnit that checks to see whether its two arguments are
equal. If so the test case succeeds. If not, the test case fails.

Then we created a test suite:
```ocaml
let tests = "test suite for sum" >::: [
  "empty" >:: (fun _ -> assert_equal 0 (sum []));
  "singleton" >:: (fun _ -> assert_equal 1 (sum [1]));
  "two_elements" >:: (fun _ -> assert_equal 3 (sum [1; 2]));
]
```

The `>:::` operator is another custom OUnit operator. It goes between the name
of the test suite and the list of test cases in that suite.

Then we ran the test suite:
```ocaml
let _ = run_test_tt_main tests
```

The function `run_test_tt_main` is provided by OUnit. It runs a test suite and
prints the results of which test cases passed vs. which failed to standard
output. The use of `let _ = ` here indicates that we don't care what value the
function returns; it just gets discarded.

## Improving OUnit Output

In our example with the buggy implementation of `sum`, we got the following
output:

```
==============================================================================
Error: test suite for sum:2:two_elements.
...
not equal
------------------------------------------------------------------------------
```

The `not equal` in the OUnit output means that `assert_equal` discovered the two
values passed to it in that test case were not equal. That's not so informative:
we'd like to know *why* they're not equal. In particular, we'd like to know what
the actual output produced by `sum` was for that test case. To find out, we need
to pass an additional argument to `assert_equal`. That argument, whose label is
`printer`, should be a function that can transform the outputs to strings. In
this case, the outputs are integers, so `string_of_int` from the Stdlib module
will suffice. We modify the test suite as follows:

```ocaml
let tests = "test suite for sum" >::: [
  "empty" >:: (fun _ -> assert_equal 0 (sum []) ~printer:string_of_int);
  "singleton" >:: (fun _ -> assert_equal 1 (sum [1]) ~printer:string_of_int);
  "two_elements" >:: (fun _ -> assert_equal 3 (sum [1; 2]) ~printer:string_of_int);
]
```

And now we get more informative output:
```
==============================================================================
Error: test suite for sum:2:two_elements.
...
expected: 3 but got: 4
------------------------------------------------------------------------------
```

That output means that the test named `two_elements` asserted the equality of
`3` and `4`. The expected output was `3` because that was the first input to
`assert_equal`, and that function's specification says that in
`assert_equal x y`, the output you (as the tester) are expecting to get should
be `x`, and the output the function being tested actually produces should be
`y`.

Notice how our test suite is accumulating a lot of redundant code. In
particular, we had to add the `printer` argument to several lines. Let's improve
that code by factoring out a function that constructs test cases:

```ocaml
let make_sum_test name expected_output input =
  name >:: (fun _ -> assert_equal expected_output (sum input) ~printer:string_of_int)

let tests = "test suite for sum" >::: [
  make_sum_test "empty" 0 [];
  make_sum_test "singleton" 1 [1];
  make_sum_test "two_elements" 3 [1; 2];
]
```

For output types that are more complicated than integers, you will end up
needing to write your own functions to pass to `printer`. This is similar to
writing `toString()` methods in Java: for complicated types you invent yourself,
the language doesn't know how to render them as strings. You have to provide the
code that does it.

## Testing for Exceptions

We have a little more of OCaml to learn before we can see how to test for
exceptions. You can peek ahead to [the section on exceptions](exceptions) if you
want to know now.

## Test-Driven Development

Testing doesn't have to happen strictly after you write code. In *test-driven
development* (TDD), testing comes first! It emphasizes *incremental* development
of code: there is always something that can be tested. Testing is not something
that happens after implementation; instead, *continuous testing* is used to
catch errors early. Thus, it is important to develop unit tests immediately when
the code is written. Automating test suites is crucial so that continuous
testing requires essentially no effort.

Here's an example of TDD. We deliberately choose an exceedingly simple function
to implement, so that the process is clear. Suppose we are working with a
datatype for days:

```ocaml
type day = Sunday | Monday | Tuesday | Wednesday | Thursday | Friday | Saturday
```
And we want to write a function `next_weekday : day -> day` that returns
the next weekday after a given day. We start by writing the most basic,
broken version of that function we can:
```ocaml
let next_weekday d = failwith "Unimplemented"
```

```{note}
The built-in function `failwith` raises an exception along with the error
message passed to the function.
```

Then we write the simplest unit test we can imagine. For example, we know that
the next weekday after Monday is Tuesday. So we add a test:

```ocaml
let tests = "test suite for next_weekday" >::: [
  "tue_after_mon"  >:: (fun _ -> assert_equal (next_weekday Monday) Tuesday);
]
```

Then we run the OUnit test suite. It fails, as expected. That's good! Now we
have a concrete goal, to make that unit test pass. We revise `next_weekday` to
make that happen:

```ocaml
let next_weekday d =
  match d with
  | Monday -> Tuesday
  | _ -> failwith "Unimplemented"
```

We compile and run the test; it passes. Time to add some more tests. The
simplest remaining possibilities are tests involving just weekdays, rather than
weekends. So let's add tests for weekdays.
```ocaml
let tests = "test suite for next_weekday" >::: [
  "tue_after_mon"  >:: (fun _ -> assert_equal (next_weekday Monday) Tuesday);
  "wed_after_tue"  >:: (fun _ -> assert_equal (next_weekday Tuesday) Wednesday);
  "thu_after_wed"  >:: (fun _ -> assert_equal (next_weekday Wednesday) Thursday);
  "fri_after_thu"  >:: (fun _ -> assert_equal (next_weekday Thursday) Friday);
]
```

We compile and run the tests; many fail. That's good! We add new
functionality:

```ocaml
  let next_weekday d =
    match d with
    | Monday -> Tuesday
    | Tuesday -> Wednesday
    | Wednesday -> Thursday
    | Thursday -> Friday
    | _ -> failwith "Unimplemented"
```

We compile and run the tests; they pass. At this point we could move on to
handling weekends, but we should first notice something about the tests we've
written: they involve repeating a lot of code. In fact, we probably wrote them
by copying-and-pasting the first test, then modifying it for the next three.
That's a sign that we should *refactor* the code. (As we did before with the
`sum` function we were testing.)

Let's abstract a function that creates test cases for `next_weekday`:
```ocaml
let make_next_weekday_test name expected_output input=
  name >:: (fun _ -> assert_equal expected_output (next_weekday input))

let tests = "test suite for next_weekday" >::: [
  make_next_weekday_test "tue_after_mon" Tuesday Monday;
  make_next_weekday_test "wed_after_tue" Wednesday Tuesday;
  make_next_weekday_test "thu_after_wed" Thursday Wednesday;
  make_next_weekday_test "fri_after_thu" Friday Thursday;
]
```

Now we finish the testing and implementation by handling weekends. First we add
some test cases:
```ocaml
  ...
  make_next_weekday_test "mon_after_fri" Monday Friday;
  make_next_weekday_test "mon_after_sat" Monday Saturday;
  make_next_weekday_test "mon_after_sun" Monday Sunday;
  ...
```

Then we finish the function:

```ocaml
let next_weekday d =
  match d with
  | Monday -> Tuesday
  | Tuesday -> Wednesday
  | Wednesday -> Thursday
  | Thursday -> Friday
  | Friday -> Monday
  | Saturday -> Monday
  | Sunday -> Monday
```

Of course, most people could write that function without errors even if they
didn't use TDD. But rarely do we implement functions that are so simple.

**Process.** Let's review the process of TDD:

- Write a failing unit test case. Run the test suite to prove that the test case
  fails.

- Implement just enough functionality to make the test case pass. Run the test
  suite to prove that the test case passes.

- Improve code as needed. In the example above we refactored the test suite, but
  often we'll need to refactor the functionality being implemented.

- Repeat until you are satisfied that the test suite provides evidence that your
  implementation is correct.
