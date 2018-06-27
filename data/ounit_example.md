# An Example of OUnit

The following example shows you how to create an OUnit test suite.  There are some
things in the example that might at first seem mysterious; they are discussed in the
next section.  

Create a file named `sum.ml`, and put the following code into it:

```
let rec sum = function
  | []    -> 0
  | x::xs -> x + sum xs
```

Now create a second file named `sum_test.ml`, and put this code into it:

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
(Depending on what editor you are using, you might now see
some errors about OUnit2 and Sum. Ignore those for the moment:
your code is correct, but your editor doesn't understand it yet.
We'll fix that later by creating a `.merlin` file.)

Finally, run these commands:

```
$ ocamlbuild -pkgs oUnit sum_test.byte
$ ./sum_test.byte
```

You will get a response something like this:
```
...
Ran: 3 tests in: 0.12 seconds.
OK
```

Now suppose we modify `sum.ml` to introduce a bug by changing the code 
in it to the following:
```
let rec sum = function
  | []    -> 1  (* bug *)
  | x::xs -> x + sum xs
```

If rebuild and re-execute `sum_test.byte`, all test cases now fail.
The output tells us the names of the failing cases.  Here's the 
beginning of the output, in which we've replaced some strings
that will be dependent on your own local computer with `...`:
```
FFF
==============================================================================
Error: test suite for sum:2:onetwo.

File ".../_build/oUnit-test suite for sum-...#01.log", line 8, characters 1-1:
Error: test suite for sum:2:onetwo (in the log).

Called from unknown location

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
Error: test suite for sum:2:onetwo.
```
tells us that in the test suite named `test suite for sum` the test case 
at index 2 named `onetwo` failed.  The rest of the output for
that test case is not particularly interesting; let's ignore it for now.