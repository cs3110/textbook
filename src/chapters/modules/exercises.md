# Exercises

{{ solutions }}

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "complex synonym")}}

Here is a module type for complex numbers, which have a real and imaginary
component:

```ocaml
module type ComplexSig = sig
  val zero : float * float
  val add : float * float -> float * float -> float * float
end
```

Improve that code by adding `type t = float * float`. Show how the signature can
be written more tersely because of the type synonym.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "complex encapsulation")}}

Here is a module for the module type from the previous exercise:

```ocaml
module Complex : ComplexSig = struct
  type t = float * float
  let zero = (0., 0.)
  let add (r1, i1) (r2, i2) = r1 +. r2, i1 +. i2
end
```

Investigate what happens if you make the following changes (each
independently), and explain why any errors arise:

- remove `zero` from the structure
- remove `add` from the signature
- change `zero` in the structure to `let zero = 0, 0`

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "big list queue")}}

Use the following code to create `ListQueue` of exponentially increasing length:
10, 100, 1000, etc. How big of a queue can you create before there is a
noticeable delay? How big until there's a delay of at least 10 seconds? (Note:
you can abort utop computations with Ctrl-C.)

```ocaml
(** Creates a ListQueue filled with [n] elements. *)
let fill_listqueue n =
  let rec loop n q =
    if n = 0 then q
    else loop (n - 1) (ListQueue.enqueue n q) in
  loop n ListQueue.empty
```

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "big batched queue")}}

Use the following function to create `BatchedQueue` of exponentially increasing
length:

```ocaml
let fill_batchedqueue n =
  let rec loop n q =
    if n = 0 then q
    else loop (n - 1) (BatchedQueue.enqueue n q) in
  loop n BatchedQueue.empty
```

Now how big of a queue can you create before there's a delay of at least 10
seconds?

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "queue efficiency")}}

Compare the implementations of `enqueue` in `ListQueue` vs. `BatchedQueue`.
Explain in your own words why the efficiency of `ListQueue.enqueue` is linear
time in the length of the queue. *Hint: consider the `@` operator.* Then explain
why adding $n$ elements to the queue takes time that is quadratic in $n$.

Now consider `BatchedQueue.enqueue`. Suppose that the queue is in a state where
it has never had any elements dequeued. Explain in your own words why
`BatchedQueue.enqueue` is constant time. Then explain why adding $n$ elements
to the queue takes time that is linear in $n$.

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "binary search tree map")}}

Write a module `BstMap` that implements the `Map` module type using a binary
search tree type. *Binary trees* were covered earlier when we discussed
algebraic data types. A binary *search* tree (BST) is a binary tree that obeys
the following *BST Invariant*:

> For any node *n*, every node in the left subtree of *n* has a value less than
> *n*'s value, and every node in the right subtree of *n* has a value greater
> than *n*'s value.

Your nodes should store pairs of keys and values. The keys should be ordered by
the BST Invariant. Based on that invariant, you will always know whether to look
left or right in a tree to find a particular key.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "fraction")}}

Write a module that implements the `Fraction` module type below:

```ocaml
module type Fraction = sig
  (* A fraction is a rational number p/q, where q != 0. *)
  type t

  (** [make n d] is n/d. Requires d != 0. *)
  val make : int -> int -> t

  val numerator : t -> int
  val denominator : t -> int
  val to_string : t -> string
  val to_float : t -> float

  val add : t -> t -> t
  val mul : t -> t -> t
end
```

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "fraction reduced")}}

Modify your implementation of `Fraction` to ensure these invariants hold for
every value `v` of type `t` that is returned from `make`, `add`, and `mul`:

1. `v` is in *[reduced form][irreducible]*

2. the denominator of `v` is positive

For the first invariant, you might find this implementation of Euclid's
algorithm to be helpful:

```ocaml
(** [gcd x y] is the greatest common divisor of [x] and [y].
    Requires: [x] and [y] are positive. *)
let rec gcd x y =
  if x = 0 then y
  else if (x < y) then gcd (y - x) x
  else gcd y (x - y)
```

[irreducible]: https://en.wikipedia.org/wiki/Irreducible_fraction

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "make char map")}}

To create a standard library map, we first have to use the `Map.Make` functor to
produce a module that is specialized for the type of keys we want. Type the
following in utop:

```ocaml
# module CharMap = Map.Make(Char);;
```

The output tells you that a new module named `CharMap` has been defined, and it
gives you a signature for it. Find the values `empty`, `add`, and `remove` in
that signature. Explain their types in your own words.

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "char ordered")}}

The `Map.Make` functor requires its input module to match the `Map.OrderedType`
signature. Look at [that signature][ord] as well as the
[signature for the `Char` module][char]. Explain in your own words why we are
allowed to pass `Char` as an argument to `Map.Make`.

[ord]: https://ocaml.org/api/Map.OrderedType.html
[char]: https://ocaml.org/api/Char.html

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "use char map")}}

Using the `CharMap` you just made, create a map that contains the following
bindings:

* `'A'` maps to `"Alpha"`
* `'E'` maps to `"Echo"`
* `'S'` maps to `"Sierra"`
* `'V'` maps to `"Victor"`

Use `CharMap.find` to find the binding for `'E'`.

Now remove the binding for `'A'`. Use `CharMap.mem` to find whether `'A'` is
still bound.

Use the function `CharMap.bindings` to convert your map into an association
list.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "bindings")}}

Investigate the [documentation of the `Map.S`][map.s] signature to find the
specification of `bindings`. Which of these expressions will return the same
association list?

1. `CharMap.(empty |> add 'x' 0 |> add 'y' 1 |> bindings)`

2. `CharMap.(empty |> add 'y' 1 |> add 'x' 0 |> bindings)`

3. `CharMap.(empty |> add 'x' 2 |> add 'y' 1 |> remove 'x' |> add 'x' 0 |> bindings)`

Check your answer in utop.

[map.s]: https://ocaml.org/api/Map.S.html


<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "date order")}}

Here is a type for dates:

```ocaml
type date = {month : int; day : int}
```

For example, March 31st would be represented as `{month = 3; day = 31}`. Our
goal in the next few exercises is to implement a map whose keys have type
`date`.

Obviously it's possible to represent invalid dates with type `date`&mdash;for
example, `{ month=6; day=50 }` would be June 50th, which is
[not a real date][parksandrec]. The behavior of your code in the exercises below
is unspecified for invalid dates.

[parksandrec]: http://nbcparksandrec.tumblr.com/post/46760908046/march-31st-is-a-day

To create a map over dates, we need a module that we can pass as input to
`Map.Make`. That module will need to match the `Map.OrderedType` signature.
Create such a module. Here is some code to get you started:

```ocaml
module Date = struct
  type t = date
  let compare ...
end
```

Recall the [specification of `compare`][ord] in `Map.OrderedType` as you write
your `Date.compare` function.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "calendar")}}

Use the `Map.Make` functor with your `Date` module to create a `DateMap` module.
Then define a `calendar` type as follows:

```ocaml
type calendar = string DateMap.t
```

The idea is that `calendar` maps a `date` to the name of an event occurring on
that date.

Using the functions in the `DateMap` module, create a calendar with a few
entries in it, such as birthdays or anniversaries.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "print calendar")}}

Write a function `print_calendar : calendar -> unit` that prints each entry in a
calendar in a format similar to the inspiring examples in the previous exercise.
*Hint: use `DateMap.iter`, which is documented in the
[`Map.S` signature][map.s].*

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "is for")}}

Write a function `is_for : string CharMap.t -> string CharMap.t` that given an
input map with bindings from $k_1$ to $v_1$, ..., $k_n$ to $v_n$, produces an
output map with the same keys, but where each key $k_i$ is now bound to the
string "$k_i$ is for $v_i$". For example, if `m` maps `'a'` to `"apple"`, then
`is_for m` would map `'a'` to `"a is for apple"`. *Hint: there is a one-line
solution that uses a function from the `Map.S` signature. To convert a character
to a string, you could use `String.make`. An even fancier way would be to use
`Printf.sprintf`.*

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "first after")}}

Write a function `first_after : calendar -> Date.t -> string` that returns the
name of the first event that occurs strictly after the given date. If there is
no such event, the function should raise `Not_found`, which is an exception
already defined in the standard library. *Hint: you can do this in one-line by using a function or two from the `Map.S` signature.*

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "sets")}}

The standard library `Set` module is quite similar to the `Map` module. Use it
to create a module that represents sets of *case-insensitive strings*. Strings
that differ only in their case should be considered equal by the set. For
example, the sets {"grr", "argh"} and {"aRgh", "GRR"} should be considered the
same, and adding "gRr" to either set should not change the set.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "ToString")}}

Write a module type `ToString` that specifies a signature with an abstract type
`t` and a function `to_string : t -> string`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "Print")}}

Write a functor `Print` that takes as input a module named `M` of type
`ToString`. The module returned by your functor should have exactly one value in
it, `print`, which is a function that takes a value of type `M.t` and prints a
string representation of that value.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "Print Int")}}

Create a module named `PrintInt` that is the result of applying the functor
`Print` to a new module `Int`. You will need to write `Int` yourself. The type
`Int.t` should be `int`. *Hint: do not seal `Int`.*

Experiment with `PrintInt` in utop. Use it to print the value of an integer.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "Print String")}}

Create a module named `PrintString` that is the result of applying the functor
`Print` to a new module `MyString`. You will need to write `MyString` yourself.
*Hint: do not seal `MyString`.*

Experiment with `PrintString` in utop. Use it to print the value of a string.

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "Print Reuse")}}

Explain in your own words how `Print` has achieved code reuse, albeit a very
small amount.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "Print String reuse revisited")}}

The `PrintString` module you created above supports just one operation: `print`.
It would be great to have a module that supports all the `String` module
functions in addition to that `print` operation, and it would be super great to
derive such a module without having to copy any code.

Define a module `StringWithPrint`. It should have all the values of the built-in
`String` module. It should also have the `print` operation, which should be
derived from the `Print` functor rather than being copied code. *Hint: use two
`include` statements.*

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "implementation without interface")}}

Create a file named `date.ml`.  In it put the following code:

```ocaml
type date = {month : int; day : int}
let make_date month day = {month; day}
let get_month d = d.month
let get_day d = d.day
let to_string d = (string_of_int d.month) ^ "/" ^ (string_of_int d.day)
```

Also create a dune file:

```text
(library
 (name date))
```

Load the library into utop:

```console
$ dune utop
```

In utop, open `Date`, create a date, access its day, and convert it to a string.

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "implementation with interface")}}

After doing the previous exercise, also create a file named `date.mli`. In it
put the following code:

```ocaml
type date = {month : int; day : int}
val make_date : int -> int -> date
val get_month : date -> int
val get_day : date -> int
val to_string : date -> string
```

Then re-do the same work as before in utop.

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "implementation with abstracted interface")}}

After doing the previous two exercises, edit `date.mli` and change the first
declaration in it to the following:

```ocaml
type date
```

The type `date` is now abstract. Again re-do the same work in utop. Some of the
responses will change. Explain in your own words those changes.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "printer for date")}}

Add a declaration to `date.mli`:

```ocaml
val format : Format.formatter -> date -> unit
```

And add a definition of `format` to `date.ml`. *Hint: use `Format.fprintf` and
`Date.to_string`.*

Now recompile, load utop, and after loading `date.cmo` install the printer by
issuing the directive

```ocaml
#install_printer Date.format;;
```

Reissue the other phrases to utop as you did in the exercises above. The
response from one phrase will change in a helpful way. Explain why.

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "refactor arith")}}

Download this file: {{ code_link | replace("%%NAME%%", "algebra.ml")}}. It
contains these signatures and structures:

* `Ring` is signature that describes the algebraic structure called a *[ring]*,
  which is an abstraction of the addition and multiplication operators.

* `Field` is a signature that describes the algebraic structure called a
  *[field]*, which is like a ring but also has an abstraction of the division
  operation.

* `IntRing` and `FloatRing` are structures that implement rings in terms of
  `int` and `float`.

* `IntField` and `FloatField` are structures that implement fields in terms of
  `int` and `float`.

* `IntRational` and `FloatRational` are structures that implement fields in
  terms of ratios (aka fractions)&mdash;that is, pairs of `int` and pairs of
  `float`.

```{note}
Dear fans of abstract algebra: of course these representations don't necessarily
obey all the axioms of rings and fields because of the limitations of machine
arithmetic. Also, the division operation in `IntField` is ill-defined on zero.
Try not to worry about that.
```

[ring]: https://en.wikipedia.org/wiki/Ring_(mathematics)
[field]: https://en.wikipedia.org/wiki/Field_(mathematics)

Refactor the code to improve the amount of code reuse it exhibits. To do that,
use `include`, functors, and introduce additional structures and signatures as
needed. There isn't necessarily a right answer here, but here's some advice:

* No name should be *directly declared* in more than one signature. For example,
  `( + )` should not be directly declared in `Field`; it should be reused from
  an earlier signature. By "directly declared" we mean a declaration of the form
  `val name : ...`. An indirect declaration would be one that results from an
  `include`.

* You need only three *direct definitions* of the algebraic operations and
  numbers (plus, minus, times, divide, zero, one): once for `int`, once for
  `float`, and once for ratios. For example, `IntField.( + )` should not be
  directly defined as `Stdlib.( + )`; rather, it should be reused from
  elsewhere. By "directly defined" we mean a definition of the form
  `let name = ...`. An indirect definition would be one that results from an
  `include` or a functor application.

* The rational structures can both be produced by a single functor that is
  applied once to `IntRing` and once to `FloatRing`.

* It's possible to eliminate all duplication of `of_int`, such that it is
  directly defined exactly once, and all structures reuse that definition; and
  such that it is directly declared in only one signature. This will require the
  use of functors. It will also require inventing an algorithm that can convert
  an integer to an arbitrary `Ring` representation, regardless of what the
  representation type of that `Ring` is.

When you're done, the types of all the modules should remain unchanged. You can
easily see those types by running `ocamlc -i algebra.ml`.
