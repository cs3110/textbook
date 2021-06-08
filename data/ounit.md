# Unit Testing with OUnit

*This section is a bit of a detour from our study of data types,
but it's a good place to take the detour:  we now know just
enough to understand how unit testing can be done in OCaml,
and there's no good reason to wait any longer to learn about it.*

Using the toplevel to test functions will only work for very small programs.
Larger programs need *test suites* that contain many *unit tests* and can be re-run
every time we update our code base.  A unit test is a test of one small piece
of functionality in a program, such as an individual function.

We've now learned enough features of OCaml to see how to do unit testing with a
library called OUnit. It is a unit testing framework similar to JUnit in Java,
HUnit in Haskell, etc. The basic workflow for using OUnit is as follows:

* Write a function in a file `f.ml`.  There could be many other functions in that file too.
* Write unit tests for that function in a separate file `f_test.ml`.  That exact name, 
  with an underscore and "test" is not actually essential, but is a convention we'll 
  often follow in 3110.
* Build and run `f_test.byte` to execute the unit tests.

The [OUnit documentation][ounitdoc] is available on Github.

[ounitdoc]: https://gildor478.github.io/ounit/ounit2/index.html
