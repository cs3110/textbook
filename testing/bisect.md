# Bisect

*This section of the textbook needs to be rewritten for Fall 2019
to use bisect-ppx instead of bisect.*

Glass-box testing can be aided by *code-coverage tools* that assess
how much of the code has been exercised by a test suite.  The 
[bisect][] tool for OCaml can tell you which expressions in your
program have been tested, and which have not.
Here's how it works:

[bisect]: http://bisect.x9c.fr/

- You compile your code using Bisect as part of the compilation process.
  It *instruments* your code, mainly by inserting additional 
  expressions to be evaluated.
  
- You run your code.  The instrumentation that Bisect inserted causes
  your program to do something in addition to whatever functionality
  you programmed yourself:  the program will now record which
  expressions from the source code actually get executed at run time,
  and which do not.  Also, the program will now produce an output
  file named `bisectNNNN.out` that contains that information.
  A new output file will be created at each invocation, the first
  being `bisect0001.out`, the second being `bisect0002.out`, etc.
  
- You run a tool called `bisect-report` on that output file.  It
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

Create a `_tags` file that includes the following:
```
true: package(oUnit), package(bisect), syntax(camlp4o), syntax(bisect_pp)
```
The latter three tags are what enable compilation with Bisect.

Download the file [`test_sorts.ml`](test_sorts.ml).  It has the skeleton
for a test suite.

Run 
```
$ ocamlbuild -use-ocamlfind test_sorts.byte
``` 
to build the test suite, and 
```
$ ./test_sorts.byte -runner sequential
```
to run it. Note the additional flag `-runner sequential` that we don't normally
have to supply when running the test suite.  It causes OUnit to run all the
tests sequentially, instead of trying to run many of them in parallel.  The latter
is good for speeding up large test suites, but it turns out Bisect isn't designed
to handle that kind of parallelism.

Running the suite will cause `bisect0001.out` (assuming it's your first
run of the suite) to be produced.  
Next run 
```
$ bisect-report -I _build -html report bisect0001.out
``` 
to generate the Bisect report from your test suite
execution.  

Open the file `report/index.html` in a web browser.  Look at the
per-file coverage; you'll see we've managed to test only 4% of
`sorts.ml` with our test suite so far. Click on the link in that report
for `sorts.ml`. You'll see that we've managed to cover one line of the
source code so far with our test suite.  The covered lines are colored
green, and the uncovered lines are red.

If you add more tests to the OUnit test suite, and repeat the above
process of testing with Bisect, you'll discover that more and more
lines have been covered.  How close to 100% coverage can you get?

## Ignoring Code

Sometimes you will want to exclude code from Bisect analysis.  The usual
reason for that is the code can't be unit tested.  For example,
maybe it's code that defensively checks that the `rep_ok` holds
of an input, but unit tests will never be able to construct an input 
that violates `rep_ok`.  Or maybe it's code that is only meaningful
in a GUI or in utop, such as custom utop printers for abstract types.

To ignore code, you can insert special comments that cause Bisect to
omit one or more lines from analysis:

* `(*BISECT-IGNORE*)` will ignore the line on which the comment occurs.

* `(*BISECT-IGNORE-BEGIN*)` and `(*BISECT-IGNORE-END*)` will ignore all
  the code between the two comments.
  
Note that there may not be spaces inside those special comments.
