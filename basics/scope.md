# Scope

`Let` bindings are in effect only in the block of code in which they occur.
This is exactly what you're used to from nearly any modern programming
language.  For example:
```
let x=42 in 
  (* y is not meaningful here *)  
  x + (let y="3110" in
         (* y is meaningful here *)
         int_of_string y)
```
The *scope* of a variable is where its name is meaningful.  Variable `y`
is in scope only inside of the `let` expression that binds it above.

It's possible to have overlapping bindings of the same name.  For example:
```
let x = 5 in 
  ((let x = 6 in x) + x)
```
But this is darn confusing, and for that reason, it is strongly discouraged 
style&mdash;much like ambiguous pronouns are discouraged in natural language.
Nonetheless, let's consider what that code means.

To what value does that code evaluate?  The answer comes down to how `x`
is replaced by a value each time it occurs.  Here are a few possibilities
for such *substitution*:
```
(* possibility 1 *)
let x = 5 in 
  ((let x = 6 in 6) + 5)
  
(* possibility 2 *)
let x = 5 in 
  ((let x = 6 in 5) + 5)

(* possibility 3 *)
let x = 5 in 
  ((let x = 6 in 6) + 6)
```
The first one is what nearly any reasonable language would do.  And most likely
it's what you would guess But, **why?**

The answer is something we'll call the *Principle of Name Irrelevance*:  the
name of a variable shouldn't intrinsically matter.  You're used to this from
math.  For example, the following two functions are the same:

$$
f(x) = x^2
$$

$$
f(y) = y^2
$$

It doesn't intrinsically matter whether we call the argument to the function
$$x$$ or $$y$$; either way, it's still the squaring function.
Therefore, in programs, these two functions should be identical:
```
let f x = x*x
let f y = y*y
```
This principle is more commonly known as *alpha equivalence*: the two functions
are equivalent up to renaming of variables, which is also called *alpha
conversion* for historical reasons that are unimportant here.

According to the Principle of Name Irrelevance, these two expressions should
be identical:
```
let x = 6 in x
let y = 6 in y
```
Therefore, the following two expressions, which have the above expressions 
embedded in them, should also be identical:
```
let x = 5 in (let x = 6 in x) + x
let x = 5 in (let y = 6 in y) + x
```
But for those to be identical, we **must** choose the first of the three
possibilities above. It is the only one that makes the name of the variable be
irrelevant.

There is a term commonly used for this phenomenon:  a new binding of a 
variable *shadows* any old binding of the variable name.  Metaphorically,
it's as if the new binding temporarily casts a shadow over the old binding.
But eventually the old binding could reappear as the shadow recedes.

Shadowing is not mutable assignment.  For example, both of the following
expressions evaluate to 11:
```
let x = 5 in ((let x = 6 in x) + x)
let x = 5 in (x + (let x = 6 in x))
```
Likewise, the following utop transcript is not mutable assignment, though 
at first it could seem like it is:
```
# let x = 42;;
val x : int = 42
# let x = 22;;
val x : int = 22
```
Recall that every `let` definition in the toplevel is effectively a nested `let`
expression.  So the above is effectively the following:
```
let x = 42 in
  let x = 22 in 
    ... (* whatever else is typed in the toplevel *)
```
The right way to think about this is that the second `let` binds an entirely
new variable that just happens to have the same name as the first `let`.

Here is another utop transcript that is well worth studying:
```
# let x=42;;
val x : int = 42
# let f y = x+y;;
val f : int -> int = <fun>
# f 0;;
: int = 42
# let x=22;;
val x : int = 22
# f 0;;
- : int = 42  (* x did not mutate! *)
```

To summarize, each let definition binds an entirely new variable. If that new
variable happens to have the same name as an old variable, the new variable
temporarily shadows the old one. But the old variable is still around, and its
value is immutable: it never, ever changes. So even though `let` expressions
might superficially look like assignment statements from imperative languages,
they are actually quite different.
