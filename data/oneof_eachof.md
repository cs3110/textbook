# One-of vs. Each-of

The big difference between variants and tuples/records is that a value of
a variant type is *one of* a set of possibilities, whereas a value
of a tuple/record type provides *each of* a set of possibilities.
Going back to our examples, a value of type `day` is **one of**
`Sun` or `Mon` or etc.  But a value of type `mon` provides **each of**
a `string` and an `int` and `ptype`.  Note how, in those previous two sentences,
the word "or" is associated with variant types, and the word "and" is associated 
with tuple/record types.  That's a good clue if you're ever trying to decide
whether you want to use a variant or a tuple/record:  if you need one piece
of data *or* another, you want a variant; if you need one piece of data
*and* another, you want a tuple/record.

One-of types are more commonly known as *sum types*, and each-of types
as *product types*.  Those names come from set theory.  Variants are
like [disjoint union][disjun], because each value of a variant comes
from one of many underlying sets (and thus far each of those sets is
just a single constructor hence has cardinality one).  And disjoint
union is sometimes written with a summation operator $$\Sigma$$.
Tuples/records are like [Cartesian product][cartprod], because each
value of a tuple/record contains a value from each of many underlying
sets.  And Cartesian product is usually written with a product operator
$$\times$$.

[disjun]: https://en.wikipedia.org/wiki/Disjoint_union
[cartprod]: https://en.wikipedia.org/wiki/Cartesian_product
