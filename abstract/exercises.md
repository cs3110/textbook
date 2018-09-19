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
