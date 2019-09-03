# Improving OUnit Output

In our example with the buggy implementation of `sum`,
we got the following output:

```
==============================================================================
Error: test suite for sum:2:onetwo.

File ".../_build/oUnit-test suite for sum-...#01.log", line 8, characters 1-1:
Error: test suite for sum:2:onetwo (in the log).

Called from unknown location

not equal
------------------------------------------------------------------------------
```

Let's see how to improve that output to be a little more informative.

## Stack traces

The `Called from an unknown location` indicates OCaml was unable
to provide a stack trace.  That happened because, by default,
stack traces are disabled.  We can enable them by compiling
the code with the debug tag:

```
$ ocamlbuild -pkgs oUnit -tag debug sum_test.byte
$ ./sum_test.byte

==============================================================================
Error: test suite for sum:2:onetwo.

File "/Users/clarkson/tmp/sum/_build/oUnit-test suite for sum-...#01.log", line 9, characters 1-1:
Error: test suite for sum:2:onetwo (in the log).

Raised at file "src/oUnitAssert.ml", line 45, characters 8-27
Called from file "src/oUnitRunner.ml", line 46, characters 13-26

not equal
------------------------------------------------------------------------------
```

Now we see the stack trace that resulted from `assert_equal` raising an
exception.  You'll probably agree that stack trace isn't very
informative though:  what matters is which test case fails, not which
files in the implementation of OUnit were involved in raising the
exception.  And we could already identify the failing test case from the
first line of output.  (It's the test case named `onetwo`, which at
position 2 in the test suite named `test suite for sum`.)

So we don't usually bother enabling stack traces for OUnit test suites. 
Nonetheless, it could occasionally be useful if your *own* code is
raising exceptions that you want to track down.

## Output values

The `not equal` in the OUnit output means that `assert_equal` discovered
the two values passed to it in that test case were not equal.  That's
not so informative:  we'd like to know *why* they're not equal. 
In particular, we'd like to know what the actual output
produced by `sum` was for that test case.  To find out,
we need to pass an additional argument to `assert_equal`.
That argument, whose label is `printer`, should be a function
that can transform the outputs to strings.  In this case, the
outputs are integers, so `string_of_int` from the Stdlib
module will suffice.  We modify the test suite as follows:

```
let tests = "test suite for sum" >::: [
  "empty"  >:: (fun _ -> assert_equal 0 (sum []) ~printer:string_of_int);
  "one"    >:: (fun _ -> assert_equal 1 (sum [1]) ~printer:string_of_int);
  "onetwo" >:: (fun _ -> assert_equal 3 (sum [1; 2]) ~printer:string_of_int);
]
```

And now we get more informative output:
```
==============================================================================
Error: test suite for sum:2:onetwo.

File "/Users/clarkson/tmp/sum/_build/oUnit-test suite for sum-sauternes#01.log", line 8, characters 1-1:
Error: test suite for sum:2:onetwo (in the log).

Called from unknown location

expected: 3 but got: 4
------------------------------------------------------------------------------
```

That output means that the test named `onetwo` asserted the equality
of `3` and `4`.  The expected output was `3` because that was the
first input to `assert_equal`, and that function's specification
says that in `assert_equal x y`, the output you (as the tester)
are expecting to get should be `x`, and the output the function
being tested actually produces should be `y`.

Notice how our test suite is accumulating a lot of redundant code.
In particular, we had to add the `printer` argument to several
lines.  Let's improve that code by factoring out a function
that constructs test cases:

```
let make_sum_test name expected_output input =
  name >:: (fun _ -> assert_equal expected_output (sum input) ~printer:string_of_int)
  
let tests = "test suite for sum" >::: [
  make_sum_test "empty" 0 [];
  make_sum_test "one" 1 [1];
  make_sum_test "onetwo" 3 [1; 2];
]
```

For output types that are more complicated than integers, you will
end up needing to write your own functions to pass to `printer`.
This is similar to writing `toString()` methods in Java: for
complicated types you invent yourself, the language doesn't know 
how to render them as strings.  You have to provide the code
that does it.
