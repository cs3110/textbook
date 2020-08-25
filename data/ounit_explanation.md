# Explanation of the OUnit Example

Let's study more carefully what we just did in the previous section.  
We had a source file named `sum.ml` with this code:
```
let rec sum = function
  | []    -> 0
  | x::xs -> x + sum xs
```

And a test file named `sum_test.ml` with this code:
```
open OUnit2
open Sum

let tests = "test suite for sum" >::: [
  "empty"  >:: (fun _ -> assert_equal 0 (sum []));
  "one"    >:: (fun _ -> assert_equal 1 (sum [1]));
  "onetwo" >:: (fun _ -> assert_equal 3 (sum [1; 2]));
]

let _ = run_test_tt_main tests
```

In the test file,
`open OUnit2` brings into scope the many definitions in OUnit2, which is version 2
of the OUnit framework.  And `open Sum` brings into scope the definitions from
`sum.ml`.  We'll learn more about scope and the `open` keyword later in the course.

Then we created a list of test cases:
```
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
Every test case function receives as input a parameter that OUnit calls a *test context*.
Here (and in many of the test cases we write) we don't actually need to worry about
the context, so we use the underscore to indicate that the function ignores its input.
The function then calls `assert_equal`, which is a function provided by OUnit that
checks to see whether its two arguments are equal.  If so the test case succeeds.
If not, the test case fails.

Then we created a test suite:
```
let tests = "test suite for sum" >::: [
  "empty"  >:: (fun _ -> assert_equal 0 (sum []));
  "one"    >:: (fun _ -> assert_equal 1 (sum [1]));
  "onetwo" >:: (fun _ -> assert_equal 3 (sum [1; 2]));
]
```
The `>:::` operator is another custom OUnit operator.  It goes between the name
of the test suite and the list of test cases in that suite.

Then we ran the test suite:
```
let _ = run_test_tt_main tests
```

The function `run_test_tt_main` is provided by OUnit.  It runs a test suite and
prints the results of which test cases passed vs. which failed to standard output.
The use of underscore here indicates that we don't care what value the function
returns; it just gets discarded.

Finally, when we compiled the test file, we linked in the OUnit package, which
has slightly unusual capitalization (which some platforms care about and others
are agnostic about):
```
$ ocamlbuild -pkgs oUnit sum_test.byte
```
If you get tired of typing the `pkgs oUnit` part of that, you can instead create
a file named `_tags` (note the underscore) in the same directory and put
the following into it:
```
true: package(oUnit)
```
Now Ocamlbuild will automatically link in OUnit everytime you compile in this
directory, without you having to give the `pkgs` flag. The tradeoff is that
you now have to pass a different flag to Ocamlbuild:
```
$ ocamlbuild -use-ocamlfind sum_test.byte
```
And you will continue having to pass that flag as long as the `_tags` file exists.
Why is this any better?  If there are many packages you want to link, with
the tags file you end up having to pass only one option on the command
line, instead of many.
