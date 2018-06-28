# Variants

A *variant* is a data type representing a value that is one of 
several possibilities.  At their simplest, variants are like
enums from C or Java:
```
type day = Sun | Mon | Tue | Wed | Thu | Fri | Sat 
let d:day = Tue
```
The individual names of the values of a variant are called
*constructors* in OCaml.  In the example above, the constructors
are `Sun`, `Mon`, etc.  This is a somewhat different use of
the word constructor than in C++ or Java.

For each kind of data type in OCaml, we've been discussing how
to build and access it.  For variants, building is 
easy:  just write the name of the constructor.  For accessing,
we use pattern matching.  For example:
```
let int_of_day d =
  match d with
  | Sun -> 1 
  | Mon -> 2
  | Tue -> 3
  | Wed -> 4
  | Thu -> 5
  | Fri -> 6
  | Sat -> 7
```
There isn't any kind of automatic way of mapping a constructor name
to an `int`, like you might expect from languages with enums.

**Syntax.**

Defining a variant type:
```
type t = C1 | ... | Cn
```

The constructor names must begin with an uppercase letter.  OCaml
uses that to distinguish constructors from variable identifiers.

The syntax for writing a constructor value is simply its name, e.g., `C`.

**Dynamic semantics.**

* A constructor is already a value.  There is no computation to perform.

**Static semantics.**

* if `t` is a type defined as `type t = ... | C | ...`, 
  then `C : t`.

Suppose there are two types defined with overlapping constructor names,
for example,
```
type t1 = C | D
type t2 = D | E
let x = D
```
When `D` appears after these definitions, to which type does it refer?
That is, what is the type of `x` above?  The answer is that the type defined 
later wins.  So `x : t2`.  That is potentially surprising to programmers,
so within any given scope (e.g., a file or a module, though we haven't
covered modules yet) it's idiomatic whenever overlapping constructor names
might occur to prefix them with some distinguishing character.
For example, suppose we're defining types to represent Pok&eacute;mon:
```
type ptype = 
  TNormal | TFire | TWater

type peff = 
  ENormal | ENotVery | ESuper
```
Because "Normal" would naturally be a constructor name for both the type
of a Pok&eacute;mon and the effectiveness of a Pok&eacute;mon attack,
we add an extra character in front of each constructor name to indicate
whether it's a type or an effectiveness.

**Pattern matching.** 

As we said in the last lecture, each time we introduced a new kind of
data type, we need to introduce the new patterns associated with it.
For variants, this is easy.  We add the following new pattern form
to the list of legal patterns:

* a constructor name `C`

And we extend the definition of when a pattern matches a value and produces
a binding as follows:

* The pattern `C` matches the value `C` and produces no bindings.

**Note.**
Variants are considerably more powerful than what
we have seen here.  We'll return to them again soon.
