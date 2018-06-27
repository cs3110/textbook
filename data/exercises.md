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