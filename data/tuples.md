# Tuples

A *tuple* is another kind of type in OCaml that programmers can define.
Like records, it is a composite of other types of data.  But instead of
naming the *components*, they are identified by position.  Here are some
examples of tuples:
```
(1,2,10)
1,2,10
(true, "Hello")
([1;2;3], (0.5,'X'))
```
A tuple with two components is called a *pair*.  A tuple with three
components is called a *triple*.  Beyond that, we usually just use
the word *tuple* instead of continuing a naming scheme based on numbers.
Also, beyond that, it's arguably better to use records instead of tuples,
because it becomes hard for a programmer to remember which component
was supposed to represent what information.

Building of tuples is easy:  just write the tuple, as above.
Accessing again involves pattern matching, for example:
```
match (1,2,3) with
| (x,y,z) -> x+y+z
```

**Syntax.**

A tuple is written
```
(e1, e2, ..., en)
```
The parentheses are optional but might sometimes be necessary
to ensure the compiler parses your code the way you intended.  One place
where it is somewhat idiomatic to omit them is in a match expression
between the `match` and `with` keywords (and also in the patterns
in the following branches).

**Dynamic semantics.**

* if for all `i` in `1..n` it holds that `ei ==> vi`, 
  then `(e1, ..., en) ==> (v1, ..., vn)`.

**Static semantics.**

Tuple types are written using a new type constructor `*`, which is
different than the multiplication operator.  The type `t1 * ... * tn`
is the type of tuples whose first component has type `t1`, ..., and
nth component has type `tn`.

* if for all `i` in `1..n` it holds that `ei : ti`, 
  then `(e1, ..., en) : t1 * ... * tn`.

**Pattern matching.**

We add the following new pattern form to the list of legal patterns:

* `(p1, ..., pn)`

The parentheses are optional but might sometimes be necessary
to ensure the compiler parses your code the way you intended. 

And we extend the definition of when a pattern matches a value and produces
a binding as follows:

* If for all `i` in `1..n`, it holds that `pi` matches `vi` and produces
  bindings \\(b_i\\), then the tuple pattern `(p1, ..., pn)` matches the 
  tuple value `(v1, ..., vn)` and produces the set 
  \\(\bigcup_i b_i\\) of bindings.
  Note that the tuple value must have exactly the same number
  of components as the tuple pattern does.
  