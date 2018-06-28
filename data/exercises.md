# Exercises

##### Exercise: list expressions [&#10029;] 

* Construct a list that has the integers 1 through 5 in it.  Use the square bracket 
  notation for lists.
  
* Construct the same list, but do not use the square bracket notation.  Instead use
  `::` and `[]`.

* Construct the same list again.  This time, the following expression must appear
  in your answer:  `[2;3;4]`.  Use the `@` operator, and do not use `::`.

&square;

##### Exercise: product [&#10029;&#10029;] 

Write a function that returns the product of all the elements in a list.  The 
product of all the elements of an empty list is `1`.  *Hint: recall the `sum`
function we defined in lecture.*  Put your code in a file named `lab03.ml`.
Use the toplevel to test your code.

&square;

##### Exercise: concat [&#10029;&#10029;, optional]

Write a function that concatenates all the strings in a list.
The concatenation of all the strings in an empty list is the empty string `""`.
*Hint: this function is really not much different than `sum` or `product`.*
Put your code in a file named `lab03.ml`.
Use the toplevel to test your code.

&square;


##### Exercise: bad add [&#10029;&#10029;] 

Create a file named `add.ml`, and in it put the following buggy version of an
addition function:
```
let add x y = 
  if x mod 7 = 0 then 0   (* bug *)
  else x+y
```

Now create a file named `add_test.ml`.  Create and run an OUnit test suite for
`add` in that file.  Make sure to write some test cases that will pass 
(e.g., `add 1 2`) and some test cases that will fail (e.g., `add 7 1`).

&square;

##### Exercise: product test [&#10029;&#10029;, optional] 

Unit test the function `product` that you wrote in an exercise above.

&square;

##### Exercise: patterns [&#10029;&#10029;&#10029;] 

Using pattern matching, write three functions, one for each of the following
properties.  Your functions should return `true` if the input list
has the property and `false` otherwise.

* the list's first element is `"bigred"`
* the list has exactly two or four elements; do not use the `length` function
* the first two elements of the list are equal

&square;

##### Exercise: library [&#10029;&#10029;&#10029;] 

Consult the [`List` standard library][listdoc] to solve these exercises:

* Write a function that takes an `int list` and returns the fifth element of that list, if such an element
  exists.  If the list has fewer than five elements, return `0`.  *Hint:  `List.length` and
  `List.nth`.*
  
* Write a function that takes an `int list` and returns the list sorted in descending order.
  *Hint: `List.sort` with `Pervasives.compare` as its first argument, and `List.rev`.*

[listdoc]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/List.html

&square;

##### Exercise: library test [&#10029;&#10029;&#10029;, optional] 

Write a couple OUnit unit tests for each of the functions you wrote in the 
previous exercise.

&square;

##### Exercise: library puzzle [&#10029;&#10029;&#10029;] 

* Write a function that returns the last element of a list. Your
function may assume that the list is non-empty.  *Hint: Use two library functions, 
and do not write any pattern matching code of your own.* 

* Write a function `any_zeroes : int list -> bool` that returns `true`
if and only if the input list contains at least one `0`. *Hint: use one library function, 
and do not write any pattern matching code of your own.* 

Your solutions will be only one or two lines of code each.

&square;

##### Exercise: take drop [&#10029;&#10029;&#10029;] 

* Write a function `take : int -> 'a list -> 'a list` such that `take n lst` returns
the first `n` elements of `lst`.  If `lst` has fewer than `n` elements, return all
of them.  

* Write a function `drop : int -> 'a list -> 'a list` such that `drop n lst` 
returns all but the first `n` elements of `lst`.  If `lst` has fewer than `n` elements,
return the empty list.

&square;

##### Exercise: take drop tail [&#10029;&#10029;&#10029;&#10029;, recommended] 

Revise your solutions for `take` and `drop` to be tail recursive, if
they aren't already.  Test them on long lists with large values of `n`
to see whether they run out of stack space. Here is (tail-recursive) 
code to produce a long list:
```
(* returns:  [from i j l] is the list containing the integers from
 *   [i] to [j], inclusive, followed by the list [l].
 * example:  [from 1 3 [0] = [1;2;3;0]] *)
let rec from i j l =
  if i>j then l
  else from i (j-1) (j::l)

(* returns:  [i -- j] is the list containing the integers from
 *   [i] to [j], inclusive.
 *) 
let (--) i j =
  from i j []

let longlist = 0 -- 1_000_000
```
It would be worthwhile to study the definition of `--` to convince yourself
that you understand (i) how it works and (ii) why it is tail recursive.

&square; 

##### Exercise: unimodal [&#10029;&#10029;&#10029;] 

Write a function `is_unimodal : int list -> bool` that takes an integer list and 
returns whether that list is unimodal.   A *unimodal list* is a list that 
monotonically increases to some maximum value then monotonically decreases 
after that value. Either or both segments (increasing or decreasing) may be empty.
A constant list is unimodal, as is the empty list.

&square; 

##### Exercise: powerset [&#10029;&#10029;&#10029;]

Write a function `powerset : int list -> int list list` that takes a set *S* 
represented as a list and returns the set of all subsets of *S*.  The order
of subsets in the powerset and the order of elements in the subsets do not matter.

*Hint:* Consider the recursive structure of this problem. 
Suppose you already have `p`, such
that `p = powerset s`. How could you use `p` to compute `powerset (x::s)`?

&square; 

##### Exercise: student [&#10029;&#10029;] 

Assume the following type definition:

```
type student = { first_name : string ; last_name : string ; gpa : float }
```
Give OCaml expressions that have the following types:

* `student`
* `student -> string * string`  (a function that extracts the student's name)
* `string -> string -> float -> student`  (a function that creates a student record)

&square;

Here is a variant that represents a few Pok&eacute;mon types:
```
type poketype = Normal | Fire | Water
```

##### Exercise: pokerecord [&#10029;&#10029;] 

* Define the type `pokemon` to be a record with fields `name` (a string),
  `hp` (an integer), and `ptype` (a `poketype`).

* Create a record named `charizard` of type `pokemon` that represents
a Pok&eacute;mon with 78 HP and Fire type.

* Create a record named `metapod` of type `pokemon` that represents
a Pok&eacute;mon with 50 HP and Normal type.

&square;

##### Exercise: safe hd and tl [&#10029;&#10029;] 

Write a function `safe_hd : 'a list -> 'a option` that returns
`Some x` if the head of the input list is `x`, and `None` if the input list is
empty.

Also write a function `safe_tl : 'a list -> 'a list option` that returns
the tail of the list, or `None` if the list is empty.

&square;

##### Exercise: pokefun [&#10029;&#10029;&#10029;] 

Write a function `max_hp : pokemon list -> pokemon option` that, given a list of
`pokemon`, finds the Pok&eacute;mon with the highest HP.

&square;

##### Exercise: date before [&#10029;&#10029;] 

Define a *date-like triple* to be a value of type `int*int*int`.
Examples of date-like triples include `(2013, 2, 1)` and `(0,0,1000)`. A
*date* is a date-like triple whose first part is a positive year (i.e.,
a year in the common era), second part is a month between 1 and 12, and
third part is a day between 1 and 31 (or 30, 29, or 28, depending on the
month and year). `(2013, 2, 1)` is a date; `(0,0,1000)` is not.

Write a function `is_before` that takes two dates as input and evaluates
to `true` or `false`. It evaluates to `true` if the first argument is a
date that comes before the second argument. (If the two dates are the
same, the result is `false`.)

Your function needs to work correctly only for dates, not for arbitrary
date-like triples.  However, you will probably find it easier to write
your solution if you think about making it work for arbitrary date-like
triples. For example, it's easier to forget about whether the input is
truly a date, and simply write a function that claims (for example) that
January 100, 2013 comes before February 34, 2013&mdash;because any date
in January comes before any date in February, but a function that says
that January 100, 2013 comes after February 34, 2013 is also valid.  You
may ignore leap years.

&square;

##### Exercise: earliest date [&#10029;&#10029;&#10029;] 

Write a function `earliest : (int*int*int) list -> 
(int*int*int) option`. It evaluates to
`None` if the input list is empty, and to `Some d` if date `d` 
is the earliest date in the list.  *Hint: use `is_before`.*

As in the previous exercise, your function needs to work correctly 
only for dates, not for arbitrary date-like triples.

&square;

##### Exercise: assoc list [&#10029;]

Use the functions `insert` and `lookup` above to construct an 
association list that maps the integer 1 to the string "one", 
2 to "two", and 3 to "three".  Lookup the key 2.  Lookup the key 4.

&square;
