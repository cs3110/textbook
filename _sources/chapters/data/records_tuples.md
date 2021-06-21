---
jupytext:
  cell_metadata_filter: -all
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.10.3
kernelspec:
  display_name: OCaml
  language: OCaml
  name: ocaml-jupyter
---

# Records and Tuples

Singly-linked lists are a great data structure, but what if you want a fixed
number of elements, instead of an unbounded number? Or what if you want the
elements to have distinct types? Or what if you want to access the elements by
name instead of by number? Lists don't make any of those possibilities easy.
Instead, OCaml programmers use records and tuples.

## Records

A *record* is a composite of other types of data, each of which is named. OCaml
records are much like structs in C. Here's an example of a record type
definition `mon` for a Pok&eacute;<u>mon</u>, re-using the `ptype` definition
from the [variants](variants) section:
```{code-cell} ocaml
type ptype = TNormal | TFire | TWater
type mon = {name : string; hp : int; ptype : ptype}
```
This type defines a record with three *fields* named `name`, `hp` (hit points),
and `ptype`. The type of each of those fields is also given. Note that `ptype`
can be used as both a type name and a field name; the *namespace* for those is
distinct in OCaml.

To build a value of a record type, we write a record expression, which looks
like this:
```{code-cell} ocaml
{name = "Charmander"; hp = 39; ptype = TFire}
```
So in a type definition we write a colon between the name and the type of a
field, but in an expression we write an equals sign.

To access a record and get a field from it, we use the dot notation that you
would expect from many other languages. For example:
```{code-cell} ocaml
let c = {name = "Charmander"; hp = 39; ptype = TFire};;
c.hp
```

It's also possible to use pattern matching to access record fields:
```{code-cell} ocaml
match c with {name = n; hp = h; ptype = t} -> h
```
The `n`, `h`, and `t` here are pattern variables. There is a syntactic sugar
provided if you want to use the same name for both the field and a pattern
variable:
```{code-cell} ocaml
match c with {name; hp; ptype} -> hp
```
Here, the pattern `{name; hp; ptype}` is sugar for
`{name = name; hp = hp; ptype = ptype}`. In each of those subexpressions, the
identifier appearing on the left-hand side of the equals is a field name, and
the identifier appearing on the right-hand side is a pattern variable.

**Syntax.**

A record expression is written:
```ocaml
{f1 = e1; ...; fn = en}
```
The order of the `fi=ei` inside a record expression is irrelevant.
For example, `{f = e1; g = e2}` is entirely equivalent to `{g = e2; f = e1}`.

A field access is written:
```ocaml
e.f
```
where `f` must be an identifier of a field name, not an expression. That
restriction is the same as in any other language with similar
features---&mdash;for example, Java field names. If you really do want to
*compute* which identifier to access, then actually you want a different data
structure: a *map* (also known by many other names: a *dictionary* or
*association list* or *hash table* etc., though there are subtle differences
implied by each of those terms.)

**Dynamic semantics.**

* If for all `i` in `1..n`, it holds that `ei ==> vi`, then
  `{f1 = e1; ...; fn = en} ==> {f1 = v1; ...; fn = vn}`.

* If `e ==> {...; f = v; ...}` then `e.f ==> v`.

**Static semantics.**

A record type is written:
```ocaml
{f1 : t1; ...; fn : tn}
```
The order of the `fi:ti` inside a record type is irrelevant. For example,
`{f : t1; g : t2}` is entirely equivalent to `{g:t2;f:t1}`.

Note that record types must be defined before they can be used.  This
enables OCaml to do better type inference than would be possible if
record types could be used without definition.

The type checking rules are:

* If for all `i` in `1..n`, it holds that `ei : ti`, and if `t` is defined to be
  `{f1 : t1; ...; fn : tn}`, then `{f1 = e1; ...; fn = en} : t`. Note that the
  set of fields provided in a record expression must be the full set of fields
  defined as part of the record's type (but see below regarding *record copy*).

* If `e : t1` and if `t1` is defined to be `{...; f : t2; ...}`, then
  `e.f : t2`.

**Record copy.**

Another syntax is also provided to construct a new record out of an old record:
```ocaml
{e with f1 = e1; ...; fn = en}
```
This doesn't mutate the old record. Rather, it constructs a new record with new
values. The set of fields provided after the `with` does not have to be the full
set of fields defined as part of the record's type. In the newly-copied record,
any field not provided as part of the `with` is copied from the old record.

The dynamic and static semantics of this are what you might expect, though they
are tedious to write down mathematically.

**Pattern matching.**

We add the following new pattern form to the list of legal patterns:

* `{f1 = p1; ...; fn = pn}`

And we extend the definition of when a pattern matches a value and produces a
binding as follows:

* If for all `i` in `1..n`, it holds that `pi` matches `vi` and produces
  bindings $b_i$, then the record pattern `{f1 = p1; ...; fn = pn}` matches the
  record value `{f1 = v1; ...; fn = vn; ...}` and produces the set $\bigcup_i
  b_i$ of bindings. Note that the record value may have more fields than the
  record pattern does.

As a syntactic sugar, another form of record pattern is provided:
`{f1; ...; fn}`. It is desugared to `{f1 = f1; ...; fn = fn}`.

## Tuples

Like records, *tuples* are a composite of other types of data. But instead of
naming the *components*, they are identified by position. Here are some examples
of tuples:
```ocaml
(1, 2, 10)
(true, "Hello")
([1; 2; 3], (0.5, 'X'))
```
A tuple with two components is called a *pair*. A tuple with three components is
called a *triple*. Beyond that, we usually just use the word *tuple* instead of
continuing a naming scheme based on numbers.

```{tip}
Beyond about three components, it's arguably better to use records instead of
tuples, because it becomes hard for a programmer to remember which component was
supposed to represent what information.
```

Building of tuples is easy: just write the tuple, as above. Accessing again
involves pattern matching, for example:
```{code-cell} ocaml
match (1, 2, 3) with (x, y, z) -> x + y + z
```

**Syntax.**

A tuple is written
```ocaml
(e1, e2, ..., en)
```
The parentheses are not entirely mandatory &mdash;often your code can
successfully parse without them&mdash; but they are usually considered to be
good style to include.

**Dynamic semantics.**

* If for all `i` in `1..n` it holds that `ei ==> vi`, then
  `(e1, ..., en) ==> (v1, ..., vn)`.

**Static semantics.**

Tuple types are written using a new type constructor `*`, which is different
than the multiplication operator. The type `t1 * ... * tn` is the type of tuples
whose first component has type `t1`, ..., and nth component has type `tn`.

* If for all `i` in `1..n` it holds that `ei : ti`, then
  `(e1, ..., en) : t1 * ... * tn`.

**Pattern matching.**

We add the following new pattern form to the list of legal patterns:

* `(p1, ..., pn)`

The parentheses are again not entirely mandatory but usually are idimoatic to
include.

And we extend the definition of when a pattern matches a value and produces a
binding as follows:

* If for all `i` in `1..n`, it holds that `pi` matches `vi` and produces
  bindings $b_i$, then the tuple pattern `(p1, ..., pn)` matches the tuple value
  `(v1, ..., vn)` and produces the set $\bigcup_i b_i$ of bindings. Note that
  the tuple value must have exactly the same number of components as the tuple
  pattern does.

## Variants vs. Tuples and Records

The big difference between variants and the types we just learned (records and
tuples) is that a value of a variant type is *one of* a set of possibilities,
whereas a value of a tuple or record type provides *each of* a set of
possibilities. Going back to our examples, a value of type `day` is **one of**
`Sun` or `Mon` or etc. But a value of type `mon` provides **each of** a `string`
and an `int` and `ptype`. Note how, in those previous two sentences, the word
"or" is associated with variant types, and the word "and" is associated with
tuple and record types. That's a good clue if you're ever trying to decide
whether you want to use a variant, or a tuple or record: if you need one piece
of data *or* another, you want a variant; if you need one piece of data *and*
another, you want a tuple or record.

One-of types are more commonly known as *sum types*, and each-of types as
*product types*. Those names come from set theory. Variants are like
[disjoint union][disjun], because each value of a variant comes from one of many
underlying sets (and thus far each of those sets is just a single constructor
hence has cardinality one). Disjoint union is indeed sometimes written with a
summation operator $\Sigma$. Tuples/records are like
[Cartesian product][cartprod], because each value of a tuple or record contains
a value from each of many underlying sets. Cartesian product is usually written
with a product operator, $\times$ or $\Pi$.

[disjun]: https://en.wikipedia.org/wiki/Disjoint_union
[cartprod]: https://en.wikipedia.org/wiki/Cartesian_product
