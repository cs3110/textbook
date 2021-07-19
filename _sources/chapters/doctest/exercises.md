# Exercises

{{ solutions }}

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "spec game")}}

Pair up with another programmer and play the specification game with them. Take
turns being the specifier and the devious programmer. Here are some suggested
functions you could use:

 - `num_vowels : string -> int`
 - `is_sorted : 'a list -> bool`
 - `sort : 'a list -> 'a list`
 - `max : 'a list -> 'a`
 - `is_prime : int -> bool`
 - `is_palindrome : string -> bool`
 - `second_largest : int list -> int`
 - `depth : 'a tree -> int`

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "poly spec")}}

Let's create a data abstraction for single-variable integer polynomials of the
form

$$
c_n x^n + \ldots + c_1 x + c_0.
$$

Let's assume that the polynomials are *dense*, meaning that they contain very
few coefficients that are zero. Here is an incomplete interface for polynomials:

```ocaml
(** [Poly] represents immutable polynomials with integer coefficients. *)
module type Poly = sig
  (** [t] is the type of polynomials *)
  type t

  (** [eval x p] is [p] evaluated at [x]. Example: if [p] represents
      $3x^3 + x^2 + x$, then [eval 10 p] is [3110]. *)
  val eval : int -> t -> int
end
```

Finish the design of `Poly` by adding more operations to the interface. Consider
what operations would be useful to a client of the abstraction:

* How would they create polynomials?
* How would they combine polynomials to get new polynomials?
* How would they query a polynomial to find out what
  it represents?

Write specification comments for the operations that you invent. Keep in mind
the spec game as you write them: could a devious programmer subvert your
intentions?

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "poly impl")}}

Implement your specification of `Poly`. As part of your implementation, you will
need to choose a representation type `t`. *Hint: recalling that our polynomials
are dense might guide you in choosing a representation type that makes for an
easier implementation.*

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "interval arithmetic")}}

Specify and implement a data abstraction for [interval arithmetic][int-arith].
Be sure to include the abstraction function, representation invariant, and
`rep_ok`. Also implement a `to_string` function and a `format` that can be
installed in the top level with `#install_printer`.

[int-arith]: http://web.mit.edu/hyperbook/Patrikalakis-Maekawa-Cho/node45.html

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "function maps")}}

Implement a map (aka dictionary) data structure with abstract type `('k, 'v) t`.
As the representation type, use `'k -> 'v`. That is, a map is represented as an
OCaml function from keys to values. Document the AF. You do not need an RI. Your
solution will make heavy use of higher-order functions. Provide at least these
values and operations: `empty`, `mem`, `find`, `add`, `remove`.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "set black box")}}

Go back to the implementation of sets with lists in the previous chapter.
Based on the specification comments of `Set`, write an OUnit test suite
for `ListSet` that does black-box testing of all its operations.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "set glass box")}}

Achieve as close to 100% code coverage with Bisect as you can for `ListSet`
and `UniqListSet`.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "random lists")}}

Use `QCheck.Gen.generate1` to generate a list whose length is between 5 and 10,
and whose elements are integers between 0 and 100. Then use
`QCheck.Gen.generate` to generate a 3-element list, each element of which is a
list of the kind you just created with `generate1`.

Then use `QCheck.make` to create an arbitrary that represents a list whose
length is between 5 and 10, and whose elements are integers between 0 and 100.
The type of your arbitrary should be `int list QCheck.arbitrary`.

Finally create and run a QCheck test that checks whether at least one element of
an arbitrary list (of 5 to 10 elements, each between 0 and 100) is even. You'll
need to "upgrade" the `is_even` property to work on a list of integers rather
than a single integer.

Each time you run the test, recall that it will generate 100 lists and check the
property of them. If you run the test many times, you'll likely see some
successes and some failures.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "qcheck odd divisor")}}

Here is a buggy function:

```ocaml
(** [odd_divisor x] is an odd divisor of [x].
    Requires: [x >= 0]. *)
let odd_divisor x =
  if x < 3 then 1 else
    let rec search y =
      if y >= x then y  (* exceeded upper bound *)
      else if x mod y = 0 then y  (* found a divisor! *)
      else search (y + 2) (* skip evens *)
    in search 3
```

Write a QCheck test to determine whether the output of that function (on a
positive integer, per its precondition; *hint: there is an arbitrary that
generates positive integers*) is both odd and is a divisor of the input. You
will discover that there is a bug in the function. What is the smallest integer
that triggers that bug?

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "qcheck avg")}}

Here is a buggy function:

```ocaml
(** [avg [x1; ...; xn]] is [(x1 + ... + xn) / n].
     Requires: the input list is not empty. *)
let avg lst =
  let rec loop (s, n) = function
    | [] -> (s, n)
    | [ h ] -> (s + h, n + 1)
    | h1 :: h2 :: t -> if h1 = h2 then loop (s + h1, n + 1) t
      else loop (s + h1 + h2, n + 2) t
  in
  let (s, n) = loop (0, 0) lst
  in float_of_int s /. float_of_int n
```
Write a QCheck test that detects the bug. For the property that you check,
construct your own *reference implementation* of average&mdash;that is,
a less optimized version of `avg` that is obviously correct.
