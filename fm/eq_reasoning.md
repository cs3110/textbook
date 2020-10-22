# Equational Reasoning

Consider these functions:
```
let twice f x = f (f x)
let compose f g x = f (g x)
```

We have that `twice h x = h (h x)`, because both sides would evaluate to the
same value.  Indeed, `twice h x -->* h (h x)` in the substitution model, and
from there some value would be produced (given definitions for `h` and `x`).
Likewise, `compose h h x = h (h x)`.  Thus we have:
```
twice h x = h (h x) = compose h h x
```
Therefore can conclude that `twice h x = compose h h x`. And by extensionality
we can simplify that equality:  Since `twice h x = compose h h x` holds for all
`x`, we can conclude `twice h = compose h h`.

As another example, suppose we define an infix operator for function
composition:
```
let (<<) = compose
```

Then we can prove that composition is associative, using equational reasoning:

```
Theorem: (f << g) << h  =  f << (g << h)

Proof: By extensionality, we need to show 
  ((f << g) << h) x  =  (f << (g << h)) x
for an arbitrary x.

  ((f << g) << h) x 
= (f << g) (h x)
= f (g (h x))

and 

  (f << (g << h)) x
= f ((g << h) x)
= f (g (h x))

So ((f << g) << h) x = f (g (h x)) = (f << (g << h)) x.

QED
```

All of the steps in the equational proof above follow from evaluation.
Another format for writing the proof would provide hints as to why
each step is valid:

```
  ((f << g) << h) x 
=   { evaluation of << }
  (f << g) (h x)
=   { evaluation of << }
  f (g (h x))

and

  (f << (g << h)) x
=   { evaluation of << }
  f ((g << h) x)
=   { evaluation of << }
  f (g (h x))
```
