# Exercises

##### Exercise: spec game [&#10029;&#10029;&#10029;] 

Pair up with another programmer and play the specification
game with them.  Take turns being the specifier and
the devious programmer.  Here are some suggested functions
you could use:

 - `num_vowels : string -> int`
 - `is_sorted : 'a list -> bool`
 - `sort : 'a list -> 'a list`
 - `max : 'a list -> 'a`
 - `is_prime : int -> bool`
 
&square;

##### Exercise: poly spec [&#10029;&#10029;&#10029;] 

Let's create a *data abstraction* (a module that represents some kind
of data) for single-variable integer polynomials of the form 
\\[c_n x^n + \ldots + c_1 x + c_0.\\]  Let's assume that the polynomials
are *dense*, meaning that they contain very few coefficients that are zero.
Here is an incomplete interface for polynomials:
```
(** [Poly] represents immutable polynomials with integer coefficients. *)
module type Poly = sig
  (** [t] is the type of polynomials *)
  type t
  
  (** [eval x p] is [p] evaluated at [x].  
      Example:  if [p] represents $3x^3 + x^2 + x$, then 
      [eval 10 p] is [3110]. *)
  val eval : int -> t -> int
end
```

(The use of `$` above comes from LaTeX, in which mathematical formulas are
surrounded by dollar signs.  Similarly, `^` represents exponentiation 
in LaTeX.)

Finish the design of `Poly` by adding more operations to the interface.
Consider what operations would be useful to a client of the abstraction:

* How would they create polynomials?  
* How would they combine polynomials to get new polynomials?
* How would they query a polynomial to find out what
  it represents?
  
Write specification comments for the operations that you invent.  Keep
in mind the spec game as you write them:  could a devious programmer
subvert your intentions?
 
&square;

##### Exercise: poly impl [&#10029;&#10029;&#10029;] 

Implement your specification of `Poly`. As part of your implementation,
you will need to choose a representation type `t`.  *Hint: recalling
that our polynomials are dense might guide you in choosing a
representation type that makes for an easier implementation.*
 
&square;

##### Exercise: int set rep [&#10029;&#10029;&#10029;] 

Consider [this interface for integer sets](intset.mli). 
Suppose that you wanted the `to_list` implementation to 
run in constant time, perhaps at the expense of other
operations being less efficient.  Implement the interface in a file
named `intset.ml`.  First choose a representation type,
then document its abstraction function and representation
invariant.  Inside the implementation, define a `rep_ok`
function.  Insert applications of it in the appropriate
places of your implementation to guarantee that all
input and output values satisfy the representation invariant.

&square;

##### Exercise: interval arithmetic [&#10029;&#10029;&#10029;&#10029;] 

Specify and implement a data abstraction for [interval arithmetic][int-arith].
Be sure to include the abstraction function, representation invariant,
and `rep_ok`.  Also implement a `to_string` function, or a `format` function
as seen in the notes on functors.

[int-arith]: http://web.mit.edu/hyperbook/Patrikalakis-Maekawa-Cho/node45.html

##### Exercise: association list maps [&#10029;&#10029;&#10029;] 

Consider the `MyMap` signature in [maps.ml](maps.ml). Create **two**
implementations of it, both with the representation type `('k * 'v)
list`. The functions in the interface should mostly be trivially
implementable with the association list functions in the standard
library `List` module. Your first implementation should prohibit any key
from appearing twice in the list; and your second should allow it. Start
each implementation by documenting the AF and RI for `t`, and only after
you do that, implement the functions.
  
##### Exercise: function maps [&#10029;&#10029;&#10029;&#10029;]   

Implement the `MyMap` signature using the representation type `'k -> 'v`.
That is, a map is represented as an OCaml function from keys to values.
Your solution will make heavy use of higher-order functions.

## A Buggy Queue

Download [`buggy_queues.ml`](buggy_queues.ml), which efficiently implements queues
with two lists&mdash;**but with a couple bugs deliberately injected**.

##### Exercise: AF and RI [&#10029;] 

The `TwoListQueue` module documents an abstraction function
and a representation invariant, but they are not clearly identified 
as such.  Modify the comments to explicitly identify the abstraction 
function and representation invariant.

&square;

##### Exercise: rep ok [&#10029;&#10029;] 

Write a `rep_ok` function for `TwoListQueue`.  Its type should be `t
-> t`.  It should raise an exception whenever the representation
invariant does not hold. Modify the other functions exposed by the
`Queue` signature to (i) check that `rep_ok` holds for any queues passed
in, and (ii) check that `rep_ok` also holds for any queues passed out. 
*Hint: you will need to add nine applications of `rep_ok`.*

&square;

##### Exercise: test with rep ok [&#10029;&#10029;&#10029;] 

There are two bugs we deliberately injected into `TwoListQueue`. Both
are places where we failed to apply `norm` to ensure that a queue is in
normal form.  Figure out where those are by testing each operation of
`TwoListQueue` in the toplevel to see where your `rep_ok` raises an
exception. Fix each bug by adding an application of `norm`. 

*Hint:  to find one of the bugs, you will need to build a queue of
length at least 2.*

&square;