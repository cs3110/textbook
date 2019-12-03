# Exercises

##### Exercise: complex synonym [&#10029;]

Here is a signature for complex numbers, which have a real and imaginary
component:
```
module type ComplexSig = sig
  val zero : float * float
  val add : float * float -> float * float -> float * float
end
```

Improve that code by adding `type t = float * float` to the signature. Show how
the signature can be written more tersely because of the type synonym.

##### Exercise: complex encapsulation [&#10029;&#10029;]
  
Here is a structure that matches the signature from the previous exercise:
```
module Complex : ComplexSig = struct
  type t = float * float
  let zero = (0., 0.)
  let add (r1,i1) (r2,i2) = r1 +. r2, i1 +. i2
end
```
Investigate what happens if you make the following changes (each
independently), and explain why any errors arise:

- remove `zero` from the structure
- remove `add` from the signature
- change `zero` in the structure to `let zero = 0, 0`

##### Exercise: big list queue [&#10029;&#10029;] 

Use the following code to create `ListQueue`'s of exponentially
increasing length:  10, 100, 1000, etc.  How big of a queue can you create before
there is a noticeable delay?  How big until there's a delay of at least 10 seconds?
(Note: you can abort utop computations with Ctrl-C.)

```
(* Creates a ListQueue filled with [n] elements. *)
let fill_listqueue n =
  let rec loop n q =
    if n=0 then q
    else loop (n-1) (ListQueue.enqueue n q) in
  loop n ListQueue.empty
```

&square;

##### Exercise: big two-list queue [&#10029;&#10029;] 

Use the following function to create `TwoListQueue`'s of exponentially
increasing length:
```
let fill_twolistqueue n =
  let rec loop n q =
    if n=0 then q
    else loop (n-1) (TwoListQueue.enqueue n q) in
  loop n TwoListQueue.empty
```
Now how big of a queue can you create before there's a delay of at least 10 seconds?

&square;

##### Exercise: queue efficiency [&#10029;&#10029;&#10029;] 

Compare the implementations of `enqueue` in `ListQueue` vs.
`TwoListQueue`. Explain in your own words why the efficiency of
`ListQueue.enqueue` is linear time in the length of the queue. *Hint:
consider the `@` operator.*  Then explain why adding \\(n\\) elements to
the queue takes time that is quadratic in \\(n\\).

Now consider `TwoListQueue.enqueue`.  Suppose that the queue is in a
state where it has never had any elements dequeued.  Explain in your own
words why `TwoListQueue.enqueue` is constant time. Then explain why
adding \\(n\\) elements to the queue takes time that is linear in
\\(n\\).

*(Note: the enqueue and dequeue operations for `TwoListQueue` remain
constant time even after interleaving them, but showing why that is so
require the study of *amortized analysis*, which we will not cover here.)*

&square;

##### Exercise: binary search tree dictionary [&#10029;&#10029;&#10029;] 

Write a module `BstDict` that implements the `Dictionary`
module type using the `tree` type.

&square;

##### Exercise: fraction [&#10029;&#10029;&#10029;] 

Write a module that implements the `Fraction` module type below:
```
module type Fraction = sig
  (* A fraction is a rational number p/q, where q != 0.*)
  type t
  
  (* [make n d] is n/d. Requires d != 0. *)
  val make : int -> int -> t
  
  val numerator : t -> int
  val denominator : t -> int
  val to_string : t -> string
  val to_float : t -> float
  
  val add : t -> t -> t
  val mul : t -> t -> t
end
```

##### Exercise: fraction reduced [&#10029;&#10029;&#10029;] 

Modify your implementation of `Fraction` to ensure these invariants 
hold of every value `v` of type `t` that is returned from `make`, `add`, 
and `mul`:

1. `v` is in *[reduced form][irreducible]*

2. the denominator of `v` is positive

For the first invariant, you might find this implementation of Euclid's 
algorithm to be helpful:
```
(* [gcd x y] is the greatest common divisor of [x] and [y].
 * requires: [x] and [y] are positive.
 *)
let rec gcd (x:int) (y:int) : int =
  if x = 0 then y
  else if (x < y) then gcd (y - x) x
  else gcd y (x - y)
```

[irreducible]: https://en.wikipedia.org/wiki/Irreducible_fraction

## Map

The next few exercises explore the [Map module][map] in the OCaml
standard library.  It is an implementation of a dictionary data
structure. Recall that dictionaries map *keys* to *values*. If a key
\\(k\\) maps to a value \\(v\\), we say that \\(v\\) is *bound* to
\\(k\\).

[map]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Map.html

##### Exercise: make char map [&#10029;] 

To create a map, we first have to use the
`Map.Make` functor to produce a module that is specialized for the type
of keys we want. Type the following in utop:
```
# module CharMap = Map.Make(Char);;
```
The output tells you that a new module named `CharMap` has been
defined, and it gives you a signature for it.  Find the values
`empty`, `add`, and `remove` in that signature.  Explain
their types in your own words.

&square;

##### Exercise: char ordered [&#10029;] 

The `Map.Make` functor requires its input module to match the
`Map.OrderedType` signature.  Look at [that signature][ord] as well
as the [signature for the `Char` module][char].  Explain in your own
words why we are allowed to pass `Char` as an argument to `Map.Make`.

[ord]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Map.OrderedType.html
[char]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Char.html

&square;

##### Exercise: use char map [&#10029;&#10029;] 

Using the `CharMap` you just made, create a map that contains
the following bindings:  

* `'A'` maps to `"Alpha"`
* `'E'` maps to `"Echo"`
* `'S'` maps to `"Sierra"`
* `'V'` maps to `"Victor"`

Use `CharMap.find` to find the binding for `'E'`.

Now remove the binding for `'A'`.  Use `CharMap.mem` to find whether
`'A'` is still bound.  

Use the function `CharMap.bindings` to convert your map 
into an association list.  Are the correct three bindings active in it?

&square;

##### Exercise: bindings [&#10029;&#10029;] 

Investigate the [documentation of the `Map.S`][map.s] signature to find
the specification of `bindings`.  Which of these expressions will
return the same association list?

1. `CharMap.(empty |> add 'x' 0 |> add 'y' 1 |> bindings)`

2. `CharMap.(empty |> add 'y' 1 |> add 'x' 0 |> bindings)`

3. `CharMap.(empty |> add 'x' 2 |> add 'y' 1 |> remove 'x' |> add 'x' 0 |> bindings)`

Check your answer in utop.

[map.s]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Map.S.html


##### Exercise: date order [&#10029;&#10029;] 

Here is a type for dates:
```
type date = { month:int; day:int }
```
For example, March 31st would be represented as `{month=3; day=31}`.
Our goal in the next few exercises is to implement a map whose keys
have type `date`. 

Obviously it's possible to represent invalid
dates with type `date`&mdash;for example, `{ month=6; day=50 }`
would be June 50th, which is [not a real date][parksandrec].
The behavior of your code in the exercises below is unspecified
for invalid dates.

[parksandrec]: http://nbcparksandrec.tumblr.com/post/46760908046/march-31st-is-a-day

To create a map over dates, we need a module that we can pass
as input to `Map.Make`.  That module will need to match
the `Map.OrderedType` signature.  Create such a module.
Here is some code to get you started:
```
module Date = struct
  type t = date
  let compare ...
end
```
Recall the [specification of `compare`][ord] in `Map.OrderedType` as you write
your `Date.compare` function.

##### Exercise: calendar [&#10029;&#10029;] 

Use the `Map.Make` functor with your `Date` module to create a
`DateMap` module.  Then define a `calendar` type as follows:

```
type calendar = string DateMap.t
```

The idea is that `calendar` maps a `date` to the name of an 
event occurring on that date.

Using the functions in the `DateMap` module, create a calendar
with a few entries in it, such as birthdays or anniversaries.

&square;

##### Exercise: print calendar [&#10029;&#10029;] 

Write a function `print_calendar : calendar -> unit`
that prints each entry in a calendar in a format similar
the inspiring examples in the previous exercise.
*Hint: use `DateMap.iter`, which is documented
in the [`Map.S` signature][map.s].*  

&square;

##### Exercise: is for [&#10029;&#10029;&#10029;] 

Write a function `is_for : string CharMap.t -> string CharMap.t`
that given an input map with bindings from \\(k_1\\) to \\(v_1\\),
..., \\(k_n\\) to \\(v_n\\), produces an output map with the same
keys, but where each key \\(k_i\\) is now bound to the string
"\\(k_i\\) is for \\(v_i\\)".  For example, if `m` maps
`'a'` to `"apple"`, then `is_for m` would map `'a'` to `"a is for apple"`.
*Hint: there is a one-line solution that uses a function from 
the `Map.S` signature.  To convert a character to a string,
you could use `String.make`.  An even fancier way would be
to use `Printf.sprintf`.* <!--bigger hint: mapi -->

&square;

##### Exercise: first after [&#10029;&#10029;&#10029;] 

Write a function `first_after : calendar -> Date.t -> string` that
returns the name of the first event that occurs strictly
after the given date.  If there is no such event, the function
should raise `Not_found`, which is an exception already defined
in the standard library.
*Hint: there is a one-line solution that uses two functions
from the `Map.S` signature.* <!--bigger hint: split -->

&square;

##### Exercise: sets [&#10029;&#10029;&#10029;] 

The standard library `Set` module is quite similar to the `Map` module.
Use it to create a module that represents sets of *case-insensitive strings*.
Strings that differ only in their case should be considered equal by the set.
For example, the sets {"grr", "argh"} and {"aRgh", "GRR"} should be 
considered the same, and adding "gRr" to either set should not change
the set.  Assuming your module is named `CisSet`, here is some test code:
```
# CisSet.(equal (of_list ["grr"; "argh"]) (of_list ["GRR"; "aRgh"]))
- : bool = true 
```

&square;

## Writing functors

Our goal in the next series of exercises is to write a functor 
that, given a module supporting a `to_string` function, returns
a module supporting a `print` function that prints that string.

##### Exercise: ToString [&#10029;&#10029;] 

Write a module type `ToString` that specifies a signature with
an abstract type `t` and a function `to_string : t -> string`.

&square;

##### Exercise: Print [&#10029;&#10029;] 

Write a functor `Print` that takes as input a module named `M` of type `ToString`.
The structure returned by your functor should have exactly one value
in it, `print`, which is a function that takes a value of type
`M.t` and prints a string representation of that value.

&square;

##### Exercise: Print Int [&#10029;&#10029;] 

Create a module named `PrintInt` that is the result of applying
the functor `Print` to a new module `Int`.
You will need to write `Int` yourself.  The type `Int.t` should be `int`.
*Hint: do not seal `Int`.*

Experiment with `PrintInt` in utop.  Use it to print the value of
an integer.

&square;

##### Exercise: Print String [&#10029;&#10029;] 

Create a module named `PrintString` that is the result of applying
the functor `Print` to a new module `MyString`.
You will need to write `MyString` yourself.  *Hint: do not seal `MyString`.*

Experiment with `PrintString` in utop.  Use it to print the value of
a string.

&square;

##### Exercise: Print reuse [&#10029;] 

Explain in your own words how `Print` has achieved code reuse, albeit
a very small amount.

&square;

##### Exercise: Print String reuse revisited [&#10029;&#10029;] 

The `PrintString` module you created above supports just
one operation: `print`.  It would be great to have a module
that supports all the `String` module functions in addition
to that `print` operation, and it would be super great to derive
such a module without having to copy any code.

Define a module `StringWithPrint`.  It should have all the values
of the built-in `String` module.  It should also have the `print`
operation, which should be derived from the `Print` functor rather
than being copied code.  

*Hint: use two `include` statements.*  
<!-- bigger hint: include String include Print(MyString) -->

&square;

## Compilation Units

The next couple exercises play with compilation units.

##### Exercise: implementation without interface [&#10029;] 

Create a file named `date.ml`.  In it put exactly the following code:
```
type date = { month:int; day:int }
let make_date month day = {month; day}
let get_month d = d.month
let get_day d = d.day
let to_string d = (string_of_int d.month) ^ "/" ^ (string_of_int d.day)
```

Compile that file to bytecode:
```
$ ocamlbuild date.cmo
```

Now start utop and type the following to use the module you've just created:
```
# #directory "_build";;
# #load "date.cmo";;

# let j1 = Date.make_date 1 1;;
val j1 : Date.date = {Date.month = 1; day = 1}    

# j1.day;;
- : int = 1

# Date.to_string j1;;
- : string = "1/1"
```

&square;

##### Exercise: implementation with interface [&#10029;] 

After doing the previous exercise, also create a file named `date.mli`. 
In it put exactly the following code:
```
type date = { month:int; day:int; }
val make_date : int -> int -> date
val get_month : date -> int
val get_day : date -> int
val to_string : date -> string
```

Recompile `date.ml` to bytecode:
```
$ ocamlbuild date.cmo
```

Restart utop and re-issue the same phrases as before:
```
# #directory "_build";;
# #load "date.cmo";;

# let j1 = Date.make_date 1 1;;
val j1 : Date.date = {Date.month = 1; day = 1}    

# j1.day;;
- : int = 1

# Date.to_string j1;;
- : string = "1/1"
```

&square;

##### Exercise: implementation with abstracted interface [&#10029;] 

After doing the previous two exercises, edit `date.mli` and change
the first declaration in it to be exactly the following: 
```
type date
```
The type `date` is now abstract. Recompile `date.ml` to bytecode:
```
$ ocamlbuild date.cmo
```

Restart utop and re-issue the same phrases as before.  The responses
to two of them will change.  Explain in your own words those changes.
```
# #directory "_build";;
# #load "date.cmo";;
# let j1 = Date.make_date 1 1;;
# j1.day;;
# Date.to_string j1;;
```

&square;

##### Exercise: printer for date [&#10029;&#10029;&#10029;, recommended] 

Add a declaration to `date.mli`:
```
val format : Format.formatter -> date -> unit
```
And add a definition of `format` to `date.ml`. 
*Hint: use `Format.fprintf` and `Date.to_string`.*

Now recompile, load utop, and install the printer by issuing the directive
```
#install_printer Date.format;;
```
after loading `date.cmo`. 
Reissue the other phrases to utop as you did
in the exercises above.  The response from one phrase
will change in a helpful way.  Explain why.

&square;

## Challenge exercise: Algebra

Download this file:  [algebra.ml](algebra.ml).  It contains two signatures and four structures:

* `Ring` is signature that describes the algebraic structure called a *[ring]*, which is 
an abstraction of the addition and multiplication operators.

* `Field` is a signature that describes the algebraic structure called a *[field]*, which
is like a ring but also has an abstraction of the division operation.

* `IntRing` and `FloatRing` are structures that implement rings in terms of `int` and `float`.

* `IntField` and `FloatField` are structures that implement fields in terms of
  `int` and `float`.  
  
* `IntRational` and `FloatRational` are structures that implement fields in
  terms of ratios (aka fractions)&mdash;that is, pairs of `int` and pairs of `float`.  
  
*(For afficionados of abstract algebra:  of course these representations
don't necessarily obey all the axioms of rings and fields because of the
limitations of machine arithmetic.  Also, the division operation in
`IntField` is ill-defined on zero. Try not to worry about that.)*

Using this code, you can write expressions like the following:
```
# FloatField.(of_int 9 + of_int 3 / of_int 4 |> to_string);;
- : string = "9.75"

# IntRational.(
    let half = one / (one+one) in 
    let quarter = half*half in 
    let three = one+one+one in 
    let nine = three*three in 
    to_string (nine + (three*quarter))
  );;
- : string = "39/4"
```

[ring]: https://en.wikipedia.org/wiki/Ring_(mathematics)
[field]: https://en.wikipedia.org/wiki/Field_(mathematics)

##### Exercise: refactor arith [&#10029;&#10029;&#10029;&#10029;]

The file [algebra.ml](algebra.ml) contains a great deal of duplicated code.
Refactor the code to improve the amount of code reuse it exhibits.
To do that, use `include`, functors, and introduce additional structures 
and signatures as needed.

There isn't necessarily a right answer here, but it is possible to eliminate
all the duplicated code.  Here's some advice to guide you toward a good solution:

* No name should be *directly declared* in more than one signature.  For example,
  `(+)` should not be directly declared in `Field`; it should be reused from an 
  earlier signature.  By "directly declared" we mean a declaration of the form
  `val name : ...`.  An indirect declaration would be one that results from
  an `include`.
  
* You need only three *direct definitions* of the algebraic operations
  and numbers (plus, minus, times, divide, zero, one):  once for `int`,
  once for `float`, and once for ratios.  For example, `IntField.(+)`
  should not be directly defined as `Stdlib.(+)`; rather, it should be
  reused from elsewhere. By "directly defined" we mean a definition of the
  form `let name = ...`.  An indirect definition would be one that results
  from an `include` or a functor application.

* The rational structures can both be produced by a single functor that is applied
  once to `IntField` and once to `FloatField`.
  
* It's possible to eliminate all duplication of `of_int`, such that it
  is directly defined exactly once, and all structures reuse that
  definition; and such that it is directly declared in only one signature.
  This will require the use of functors. 
  It will also require inventing an algorithm that can convert an integer
  to an arbitrary `Ring` representation, regardless of what the representation
  type of that `Ring` is.

[dsub]: http://caml.inria.fr/pub/docs/manual-ocaml/extn.html#sec234  
  
When you're done, the types of all the modules should remain unchanged.  You 
can easily see those types by running `ocamlc -i algebra.ml`, which will originally
output the following:
```
module type Ring =
  sig
    type t
    val zero : t
    val one : t
    val ( + ) : t -> t -> t
    val ( ~- ) : t -> t
    val ( * ) : t -> t -> t
    val to_string : t -> string
    val of_int : int -> t
  end
module type Field =
  sig
    type t
    val zero : t
    val one : t
    val ( + ) : t -> t -> t
    val ( ~- ) : t -> t
    val ( * ) : t -> t -> t
    val ( / ) : t -> t -> t
    val to_string : t -> string
    val of_int : int -> t
  end
module IntRing : Ring
module IntField : Field
module FloatRing : Ring
module FloatField : Field
module IntRational : Field
module FloatRational : Field
```
The final output of that command on your solution might define additional types, but 
the ones above should remain literally identical.

&square;