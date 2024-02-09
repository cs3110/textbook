# Exercises

{{ solutions }}

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "list expressions")}}

* Construct a list that has the integers 1 through 5 in it. Use the square
  bracket notation for lists.

* Construct the same list, but do not use the square bracket notation. Instead,
  use `::` and `[]`.

* Construct the same list again. This time, the following expression must appear
  in your answer: `[2; 3; 4]`. Use the `@` operator, and do not use `::`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "product")}}

Write a function `product` that returns the product of all the elements in a
list. The product of all the elements of an empty list is `1`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "concat")}}

Write a function that concatenates all the strings in a list. The concatenation
of all the strings in an empty list is the empty string `""`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "product test")}}

Unit test the function `product` that you wrote in an exercise above.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "patterns")}}

Using pattern matching, write three functions, one for each of the following
properties. Your functions should return `true` if the input list has the
property and `false` otherwise.

* the list's first element is `"bigred"`
* the list has exactly two or four elements; do not use the `length` function
* the first two elements of the list are equal

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "library")}}

Consult the [`List` standard library][listdoc] to solve these exercises:

* Write a function that takes an `int list` and returns the fifth element of
  that list, if such an element exists. If the list has fewer than five
  elements, return `0`. *Hint: `List.length` and `List.nth`.*

* Write a function that takes an `int list` and returns the list sorted in
  descending order. *Hint: `List.sort` with `Stdlib.compare` as its first
  argument, and `List.rev`.*

[listdoc]: https://ocaml.org/api/List.html

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "library test")}}

Write a couple OUnit unit tests for each of the functions you wrote in the
previous exercise.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "library puzzle")}}

* Write a function that returns the last element of a list. Your function may
  assume that the list is non-empty. *Hint: Use two library functions, and do
  not write any pattern matching code of your own.*

* Write a function `any_zeros : int list -> bool` that returns `true` if and
  only if the input list contains at least one `0`. *Hint: use one library
  function, and do not write any pattern matching code of your own.*

Your solutions will be only one or two lines of code each.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "take drop")}}

* Write a function `take : int -> 'a list -> 'a list` such that `take n lst`
  returns the first `n` elements of `lst`. If `lst` has fewer than `n` elements,
  return all of them.

* Write a function `drop : int -> 'a list -> 'a list` such that `drop n lst`
  returns all but the first `n` elements of `lst`. If `lst` has fewer than `n`
  elements, return the empty list.


<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "take drop tail")}}

Revise your solutions for `take` and `drop` to be tail recursive, if they aren't
already. Test them on long lists with large values of `n` to see whether they
run out of stack space. To construct long lists, use the `--` operator from
the [lists](lists) section.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "unimodal")}}

Write a function `is_unimodal : int list -> bool` that takes an integer list and
returns whether that list is unimodal. A *unimodal list* is a list that
monotonically increases to some maximum value then monotonically decreases after
that value. Either or both segments (increasing or decreasing) may be empty. A
constant list is unimodal, as is the empty list.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "powerset")}}

Write a function `powerset : int list -> int list list` that takes a set *S*
represented as a list and returns the set of all subsets of *S*. The order of
subsets in the powerset and the order of elements in the subsets do not matter.

*Hint:* Consider the recursive structure of this problem. Suppose you already
have `p`, such that `p = powerset s`. How could you use `p` to compute
`powerset (x :: s)`?

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "print int list rec")}}

Write a function `print_int_list : int list -> unit` that prints its input list,
one number per line. For example, `print_int_list [1; 2; 3]` should result in
this output:
```
1
2
3
```
Here is some code to get you started:
```ocaml
let rec print_int_list = function
| [] -> ()
| h :: t -> (* fill in here *); print_int_list t
```

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "print int list iter")}}

Write a function `print_int_list' : int list -> unit` whose specification is the
same as `print_int_list`. Do not use the keyword `rec` in your solution, but
instead to use the [List module][list] function `List.iter`. Here is some code
to get you started:
```ocaml
let print_int_list' lst =
  List.iter (fun x -> (* fill in here *)) lst
```

[list]: https://ocaml.org/api/List.html

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "student")}}

Assume the following type definition:
```ocaml
type student = {first_name : string; last_name : string; gpa : float}
```
Give OCaml expressions that have the following types:

* `student`
* `student -> string * string` (a function that extracts the student's name)
* `string -> string -> float -> student` (a function that creates a student
  record)

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "pokerecord")}}

Here is a variant that represents a few Pok&eacute;mon types:
```ocaml
type poketype = Normal | Fire | Water
```
* Define the type `pokemon` to be a record with fields `name` (a string), `hp`
  (an integer), and `ptype` (a `poketype`).

* Create a record named `charizard` of type `pokemon` that represents a
  Pok&eacute;mon with 78 HP and Fire type.

* Create a record named `squirtle` of type `pokemon` that represents a
  Pok&eacute;mon with 44 HP and Water type.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "safe hd and tl")}}

Write a function `safe_hd : 'a list -> 'a option` that returns `Some x` if the
head of the input list is `x`, and `None` if the input list is empty.

Also write a function `safe_tl : 'a list -> 'a list option` that returns the
tail of the list, or `None` if the list is empty.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "pokefun")}}

Write a function `max_hp : pokemon list -> pokemon option` that, given a list of
`pokemon`, finds the Pok&eacute;mon with the highest HP.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "date before")}}

Define a *date-like triple* to be a value of type `int * int * int`. Examples of
date-like triples include `(2013, 2, 1)` and `(0, 0, 1000)`. A *date* is a
date-like triple whose first part is a positive year (i.e., a year in the common
era), second part is a month between 1 and 12, and third part is a day between 1
and 31 (or 30, 29, or 28, depending on the month and year). `(2013, 2, 1)` is a
date; `(0, 0, 1000)` is not.

Write a function `is_before` that takes two dates as input and evaluates to
`true` or `false`. It evaluates to `true` if the first argument is a date that
comes before the second argument. (If the two dates are the same, the result is
`false`.)

Your function needs to work correctly only for dates, not for arbitrary
date-like triples. However, you will probably find it easier to write your
solution if you think about making it work for arbitrary date-like triples. For
example, it's easier to forget about whether the input is truly a date, and
simply write a function that claims (for example) that January 100, 2013 comes
before February 34, 2013&mdash;because any date in January comes before any date
in February, but a function that says that January 100, 2013 comes after
February 34, 2013 is also valid. You may ignore leap years.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "earliest date")}}

Write a function `earliest : (int*int*int) list -> (int * int * int) option`. It
evaluates to `None` if the input list is empty, and to `Some d` if date `d` is
the earliest date in the list. *Hint: use `is_before`.*

As in the previous exercise, your function needs to work correctly
only for dates, not for arbitrary date-like triples.

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "assoc list")}}

Use the functions `insert` and `lookup` from the
[section on association lists](assoc_list) to construct an association list that
maps the integer 1 to the string "one", 2 to "two", and 3 to "three". Lookup the
key 2. Lookup the key 4.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "cards")}}

* Define a variant type `suit` that represents the four suits, &clubs; &diams;
  &hearts; &spades;, in a [standard 52-card deck][cards]. All the constructors
  of your type should be constant.

* Define a type `rank` that represents the possible ranks of a card: 2, 3, ...,
  10, Jack, Queen, King, or Ace. There are many possible solutions; you are free
  to choose whatever works for you. One is to make `rank` be a synonym of `int`,
  and to assume that Jack=11, Queen=12, King=13, and Ace=1 or 14. Another is to
  use variants.

* Define a type `card` that represents the suit and rank of a single card. Make
  it a record with two fields.

* Define a few values of type `card`: the Ace of Clubs, the Queen of Hearts, the
  Two of Diamonds, the Seven of Spades.

[cards]: https://en.wikipedia.org/wiki/Standard_52-card_deck

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "matching")}}

For each pattern in the list below, give a value of type `int option list` that
does *not* match the pattern and is not the empty list, or explain why that's
impossible.

 - `Some x :: tl`
 - `[Some 3110; None]`
 - `[Some x; _]`
 - `h1 :: h2 :: tl`
 - `h :: tl`

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "quadrant")}}

<image style="float: right;"
       src="https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Cartesian_coordinates_2D.svg/300px-Cartesian_coordinates_2D.svg.png"
       alt="Quadrant 1: x, and y both positive.  Quadrant 2: x negative, y positive.  Quadrant 3: both x and y negative.  Quadrant 4: x positive, y negative."
       />

Complete the `quadrant` function below, which should return the quadrant of the
given `x, y` point according to the diagram on the right (borrowed from
[Wikipedia](https://en.wikipedia.org/wiki/File:Cartesian_coordinates_2D.svg)).
Points that lie on an axis do not belong to any quadrant. *Hints: (a) define a
helper function for the sign of an integer, (b) match against a pair.*

```ocaml
type quad = I | II | III | IV
type sign = Neg | Zero | Pos

let sign (x:int) : sign =
  ...

let quadrant : int*int -> quad option = fun (x,y) ->
  match ... with
    | ... -> Some I
    | ... -> Some II
    | ... -> Some III
    | ... -> Some IV
    | ... -> None
```

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "quadrant when")}}

Rewrite the quadrant function to use the `when` syntax. You won't need your
helper function from before.

```ocaml
let quadrant_when : int*int -> quad option = function
    | ... when ... -> Some I
    | ... when ... -> Some II
    | ... when ... -> Some III
    | ... when ... -> Some IV
    | ... -> None
```

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "depth")}}

Write a function `depth : 'a tree -> int` that returns the number of nodes in
any longest path from the root to a leaf. For example, the depth of an empty
tree (simply `Leaf`) is `0`, and the depth of tree `t` above is `3`. *Hint:
there is a library function `max : 'a -> 'a -> 'a` that returns the maximum of
any two values of the same type.*

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "shape")}}

Write a function `same_shape : 'a tree -> 'b tree -> bool` that determines
whether two trees have the same shape, regardless of whether the values they
carry at each node are the same. *Hint: use a pattern match with three branches,
where the expression being matched is a pair of trees.*

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "list max exn")}}

Write a function `list_max : int list -> int` that returns the maximum integer
in a list, or raises `Failure "list_max"` if the list is empty.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "list max exn string")}}

Write a function `list_max_string : int list -> string` that returns a string
containing the maximum integer in a list, or the string `"empty"` (note, not the
exception `Failure "empty"` but just the string `"empty"`) if the list is empty.
*Hint: `string_of_int` in the standard library will do what its name suggests.*

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "list max exn ounit")}}

Write two OUnit tests to determine whether your solution to **list max exn**,
above, correctly raises an exception when its input is the empty list, and
whether it correctly returns the max value of the input list when that list is
non-empty.

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "is_bst")}}

Write a function `is_bst : ('a*'b) tree -> bool` that returns `true` if and only
if the given tree satisfies the binary search tree invariant. An efficient
version of this function that visits each node at most once is somewhat tricky
to write. *Hint: write a recursive helper function that takes a tree and either
gives you (i) the minimum and maximum value in the tree, or (ii) tells you that
the tree is empty, or (iii) tells you that the tree does not satisfy the
invariant. Your `is_bst` function will not be recursive, but will call your
helper function and pattern match on the result. You will need to define a new
variant type for the return type of your helper function.*


<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "quadrant poly")}}

Modify your definition of quadrant to use polymorphic variants.  The
types of your functions should become these:
```ocaml
val sign : int -> [> `Neg | `Pos | `Zero ]
val quadrant : int * int -> [> `I | `II | `III | `IV ] option
```
