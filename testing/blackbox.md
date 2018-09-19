# Black-box Testing

In selecting our test cases for good coverage, we might want to consider
both the specification and the implementation of the program or 
module being tested. It turns out that we can often do a pretty good job
of picking test cases by just looking at the specification and ignoring
the implementation. This is known as **black-box testing**. The idea is
that we think of the code as a black box about which all we can see is
its surface: its specification. We pick test cases by looking at how the
specification implicitly introduces boundaries that divide the space of
possible inputs into different regions.

When writing black-box test cases, we ask ourselves what set of test
cases that will produce distinctive behavior as predicted by the
specification. It is important to try out both *typical inputs* and
inputs that are *boundary cases* aka *corner cases* or *edge cases*. A
common error is to only test typical inputs, with the result that the
program usually works but fails in less frequent situations. It's
also important to identify ways in which the specification creates
classes of inputs that should elicit similar behavior from the 
function, and to test on those *paths through the specification*.
Here are some examples.

## Example 1

Here are some ideas for how to test the `create` function:

-   Looking at the square above, we see that it has boundaries at
    `min_int` and `max_int`. We want to
    try to construct rationals at the corners and along the sides of the
    square, e.g. `create min_int min_int`, `create max_int 2`, etc.

-   The line p=0 is important because p/q is zero all along it. We
    should try (0,q) for various values of q.

-   We should try some typical (p,q) pairs in all four quadrants of the
    space.

-   We should try both (p,q) pairs in which q divides evenly into p, and
    pairs in which q does not divide into p.

-   Pairs of the form (1,q),(-1,q),(p,1),(p,-1) for various p and q also
    may be interesting given the properties of rational numbers.

The specification also says that the code will check that q is not zero.
We should construct some test cases to ensure this checking is done as
advertised. Trying (1,0), (maxint,0), (minint,0), (-1,0), (0,0) to
see that they all raise the specified exception would
probably be an adequate set of black-box tests.

## Example 2

Consider the function `list_max`:

```
(* Return the maximum element in the list. *)
val list_max: int list -> int
```

What is a good set of black-box test cases? Here the input space is the
set of all possible lists of ints. We need to try some typical inputs
and also consider boundary cases. Based on this spec, boundary cases
include the following:

-   A list containing one element. In fact, an empty list is probably
    the first boundary case we think of. Looking at the spec above, we
    realize that it doesn't specify what happens in the case of an empty
    list. Thus, thinking about boundary cases is also useful in
    identifying errors in the specification.

-   A list containing two elements.

-   A list in which the maximum is the first element. Or the last
    element. Or somewhere in the middle of the list.

-   A list in which every element is equal.

-   A list in which the elements are arranged in ascending sorted order,
    and one in which they are arranged in descending sorted order.

-   A list in which the maximum element is `max_int`, and a list in which
    the maximum element is `min_int`.
    
## Example 3

Consider the function `sqrt`:

```
(* [sqrt x n] is the square root of [x] computed to an accuracy of [n]
 * significant digits.
 * requires: [x >= 0] and [n >= 1] *)
val sqrt : float -> int -> float 
```

The precondition identifies two possibilities for `x` (either it is zero
or greater) and two possibilities for `n` (either it is one or greater).
That leads to four "paths through the specification", i.e., representative
and boundary cases for satisfying the precondition, which we should test:

- `x` is zero and `n` is 1

- `x` is greater than zero and `n` is 1

- `x` is zero and `n` is greater than 1

- `x` is greater than zero and `n` is greater than 1.



