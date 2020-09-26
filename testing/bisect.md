# Bisect

Glass-box testing can be aided by *code-coverage tools* that assess
how much of the code has been exercised by a test suite.  The 
[bisect_ppx][] tool for OCaml can tell you which expressions in your
program have been tested, and which have not.
Here's how it works:

[bisect_ppx]: https://github.com/aantron/bisect_ppx

- You compile your code using Bisect\_ppx (henceforth, just Bisect for short)
  as part of the compilation process. It *instruments* your code, mainly by
  inserting additional expressions to be evaluated.
  
- You run your code.  The instrumentation that Bisect inserted causes
  your program to do something in addition to whatever functionality
  you programmed yourself:  the program will now record which
  expressions from the source code actually get executed at run time,
  and which do not.  Also, the program will now produce an output
  file that contains that information.
  
- You run a tool called `bisect-ppx-report` on that output file.  It
  produces HTML showing you which parts of your code got executed,
  and which did not.
  
How does that help with computing coverage of a test suite?  If you
run your OUnit test suite, the test cases in it will cause the code in
whatever functions they test to be executed.  If you don't have 
enough test cases, some code in your functions will never be
executed.  The report produced by Bisect will show you exactly
what code that is.  You can then design new glass-box test cases
to cause that code to execute, add them to your OUnit suite,
and create a new Bisect report to confirm that the code really
did get executed.

## Bisect Tutorial

Download the file [`sorts.ml`](sorts.ml).  You will
find an implementation of insertion sort and merge sort.

Create a file in the same directory called
`myocamlbuild.ml`.  That file name is actually mandatory,
despite the customary use of "my" in CS demos to indicate
a name that you could choose yourself.  Put this code in it:
```
open Ocamlbuild_plugin
let () = dispatch Bisect_ppx_plugin.dispatch
```

Create a `_tags` file in the same directory, and put the following
in it:
```
<sorts.ml>: coverage
<test_sorts.{byte,native}>: coverage
true: package(ounit2), package(bisect_ppx)
```

Download the file [`test_sorts.ml`](test_sorts.ml).  It has the skeleton
for an OUnit test suite.  

Run 
```
$ BISECT_COVERAGE=YES ocamlbuild -use-ocamlfind -plugin-tag 'package(bisect_ppx-ocamlbuild)' test_sorts.byte
``` 
to build the test suite, and 
```
$ ./test_sorts.byte -runner sequential
```
to run it. Note the additional flag `-runner sequential` that we don't normally
have to supply when running the test suite.  It causes OUnit to run all the
tests sequentially, instead of trying to run many of them in parallel.  The latter
is good for speeding up large test suites, but it seems (at least as of 
Fall 2018) Bisect isn't designed to handle that kind of parallelism.

Running the suite will cause a file named `bisectNNNN.coverage` to be produced.  
Next run 
```
$ bisect-ppx-report html
``` 
to generate the Bisect report from your test suite execution.  

Open the file `_coverage/index.html` in a web browser.  Look at the
per-file coverage; you'll see we've managed to test only 10% of
`sorts.ml` with our test suite so far. Click on the link in that report
for `sorts.ml`. You'll see that we've managed to cover a couple lines of the
source code so far with our test suite.

There are some additional tests in the test file. Try uncommenting those, as
documented in the test file, and increasing your code coverage. Between each
run, you will need to delete the report file, recompile, rerun OUnit, and rerun
the Bisect report tool. (Obviously, a Makefile would be a good thing to
construct.)

By the time you're done uncommenting the provided tests, you should be at 30%
coverage, including all of the insertion sort implementation.  For fun, try
adding more tests to get 100% coverage of merge sort.
