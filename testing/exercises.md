# Exercises

##### Exercise: black box test [&#10029;&#10029;] 

Download [`sets.ml`](sets.ml)  It implements sets with a list.
Read the `Set` signature at the top of it; **do not** read down
to the end of the file where that signature is implemented 
as `ListSet`.

Based on the specification comments of `Set`, write an OUnit test suite
for `ListSet` that does black-box testing of `size` and `insert`.  We've
already got you started in the provided file `test_sets.ml`.  Write
enough tests to detect at least one bug in both `size` and `insert`
without ever reading their implementations.  *Hint: `empty` and
`to_list` are both correctly implemented, so you can rely on those.*

&square;

##### Exercise: black box test rest [&#10029;&#10029;&#10029;] 

Finish writing a black-box OUnit test suite for the rest of the
functions in `ListSet`.  Find at least one bug in every function 
except `empty` and `to_list`.

&square;

##### Exercise: fix ListSet [&#10029;&#10029;&#10029;] 

After you have found at least one bug in each function, go read the
implementation of `ListSet`.  Fix all the bugs in it and make your test
suite pass.

&square;

##### Exercise: set glass box [&#10029;&#10029;&#10029;, optional] 

Achieve as close to 100% code coverage as you can for `ListSet`.

&square;

##### Exercise: Enigma glass box [&#10029;&#10029;&#10029;&#10029;] 

Go back to your A1 solution.  Find out what your code coverage was
from your test suite.  If it wasn't 100%, add more unit tests!

&square;

## QCheck

The exercises in this section are all optional.

##### Exercise: generate list [&#10029;&#10029;, optional] 

Use `QCheck.Gen.generate1` to generate a list whose length is between 5 and 10, and whose
elements are integers between 0 and 100.  Then use `QCheck.Gen.generate` to generate
a 3-element list, each element of which is a list of the kind you just created with
`generate1`.

&square;

##### Exercise: arbitrary list [&#10029;&#10029;, optional] 

Use `QCheck.make` and part of your solution to **generate list** from
above to create an arbitrary that represents a list whose length is
between 5 and 10, and whose elements are integers between 0 and 100. 
The type of your arbitrary should be `int list QCheck.arbitrary`.

&square;

##### Exercise: even arbitrary list [&#10029;&#10029;, optional] 

Use your solution to **arbitrary list** from above to create and run a
QCheck test that checks whether at least one element of an arbitrary
list (of 5 to 10 elements, each between 0 and 100) is even.  You'll need
to "upgrade" the `is_even` property to work on a list of integers rather
than a single integer.  

Each time you run the test, recall that it will generate 100 lists and
check the property of them.  If you run the test many times, you'll
likely see some successes and some failures.

&square;

##### Exercise: even arbitrary list QCheck test driver [&#10029;&#10029;, optional] 

Transform your solution to **even arbitrary list** to a file
`test_list.ml` that, when compiled an executed from the command line,
runs that test and prints the result.

&square;

##### Exercise: even arbitrary list OUnit test driver [&#10029;&#10029;, optional] 

Convert your test driver `test_list.ml` from using the QCheck runner to using
the OUnit test runner (that is, the final line of the file should
invoke `OUnit2.run_test_tt_main`).

&square;

##### Exercise: arbitrary list [&#10029;&#10029;, optional] 

Use `QCheck.make` and part of your solution to **generate list** from
above to create an arbitrary that represents a list whose length is
between 5 and 10, and whose elements are integers between 0 and 100. 
The type of your arbitrary should be `int list QCheck.arbitrary`.

&square;

##### Exercise: even arbitrary list improved [&#10029;&#10029;, optional] 

Upgrade your solution to **even arbitrary list** to use `QCheck.list_of_size`
and its friends instead of `QCheck.Gen.list_size`.  When finished, you'll be
able to see lists that violate the property.

You'll likely notice after finishing that exercise that there's only one
list that is ever reported as violating the property, which is the empty
list.  That's because when QCheck finds a value that violates the
property, QCheck attempts to *shrink* that value down to the smallest
input it can find that also violates the property. The `shrink` field of
`arbitrary` is part of that functionality. Shrinking an int involves
making it closer to 0; shrinking a list involves shrinking its elements
individually as well as omitting elements from the list; and so forth.

&square;

##### Exercise: odd_divisor [&#10029;&#10029;, optional] 

Download [`qchecks.ml`](qchecks.ml)  In it there
is a function `odd_divisor`. Write a QCheck test to determine whether
the output of that function (on a positive integer, per its
precondition; *hint: there is an arbitrary that generates positive
integers*) is both odd and is a divisor of the input.  You will discover
that there is a bug in the function.  What is the smallest integer that
triggers that bug?

&square;

##### Exercise: qcheck max [&#10029;&#10029;&#10029;, optional] 

The file `qchecks.ml` contains a function `max` that is buggy. Write a
QCheck test that detects the bug.  You will have to figure out how to
make an arbitrary that can generate two integers as inputs.  *Hint:
`QCheck.pair` has type*
`'a arbitrary -> 'b arbitrary -> ('a * 'b) arbitrary`.
You will also have to devise an appropriate property to check. *Hint:
the maximum of two numbers must be at least as big as each of them, and
must be equal to one of them.*

&square;

##### Exercise: qcheck avg [&#10029;&#10029;&#10029;&#10029;, optional] 

The file `qchecks.ml` contains a function `avg` that is buggy. Write a
QCheck test that detects the bug. For the property that you check,
construct your own *reference implementation* of average, such as the
following:
```
let ref_avg lst =
  (float_of_int (List.fold_left (+) 0 lst)) 
    /. (float_of_int (List.length lst))
```
Compare the output of `avg` to the output of `ref_avg` to determine correctness.

 *Hint: this bug is harder to find and might require coming up with good
 inputs to check based on glass-box inspection of the source code.* 

&square;



