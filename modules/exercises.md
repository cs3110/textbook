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

##### Exercise: complex synonym [&#10029;]

Here is a signature and a structure for complex numbers, which
have a real and imaginary component:
```
module type ComplexSig = sig
  val zero : float*float
  val add : float*float -> float*float -> float*float
end

module Complex = struct
  let zero = 0., 0.
  let add (r1,i1) (r2,i2) = r1 +. r2, i1 +. i2
end

```
  
Improve that code by adding `type t = float*float` to **both** the structure
and signature.  Show how the signature can be written more tersely because
of the type synonym.

##### Exercise: complex encapsulation [&#10029;&#10029;]
  
Change the first line of the `Complex` module above 
to be 
```
module Complex : ComplexSig = struct
  ...
```
Investigate what happens if you make the following changes (each
independently) to the code, and explain why any errors arise:

- remove `zero` from the structure
- remove `add` from the signature
- change `zero` in the structure to `let zero = 0, 0`
    

##### Exercise: fraction [&#10029;&#10029;&#10029;] 

Write a module that implements the `Fraction` module type below:
```
module type Fraction = sig
  (* A fraction is a rational number p/q, where q != 0.*)
  type t
  
  (* [make n d] is n/d. Requires d != 0. *)
  val make : int -> int -> t
  
  val numerator   : t -> int
  val denominator : t -> int
  val toString    : t -> string
  val toReal      : t -> float
  
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
