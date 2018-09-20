# Glass-box Testing

Black-box testing is a good place to start when writing test cases, but
ultimately it is not enough.  In particular, it's not possible to
determine how much coverage of the implementation a black-box test suite
actually achieves&mdash;we actually need to know the implementation
source code.  Testing based on that code is known as *glass box* or
*white box* testing. Glass-box testing can improve on black-box by
testing *execution paths* through the implementation code:  the series
of expressions that is conditionally evaluated based on if-expressions,
match-expressions, and function applications. Test cases that
collectively exercise all paths are said to be *path-complete*. At a
minimum, path-completeness requires that for every line of code, and
even for every expression in the program, there should be a test case
that causes it to be executed. Any unexecuted code could contain a bug
if has never been tested.

For true path completeness we must consider all possible execution paths
from start to finish of each function, and try to exercise every
distinct path. In general this is infeasible, because there are too many
paths.  A good approach is to think of the set of paths as
the space that we are trying to explore, and to identify boundary cases
within this space that are worth testing. 

For example, consider the following implementation of a function that
finds the maximum of its three arguments:
```
let max3 x y z = 
  if x>y then 
    if x>z then x else z 
  else 
    if y>z then y else z
```
Black-box testing might lead us to invent many tests, but looking
at the implementation reveals that there are only four paths through
the code&mdash;the paths that return `x`, `z`, `y`, or `z` (again).
We could test each of those paths with representative inputs such as:
3,2,1; 3,2,4; 1,2,1; 1,2,3.

When doing glass box testing, we should include test cases for each 
branch of each (nested) if expression, and each branch of each 
(nested) pattern match.  If there are recursive functions,
we should include test cases for the base cases as well as each
recursive call.  Also, we should include test cases to trigger
each place where an exception might be raised.

Of course, path complete testing does not guarantee an absence of
errors.  We still need to test against the specification, i.e.,
do black-box testing.  For example, here is a broken implementation
of `max3`:
```
let max3 x y z =
  x
```
The test `max 2 1 1` is path complete, but doesn't reveal the error.

