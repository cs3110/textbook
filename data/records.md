# Records

A *record* is a kind of type in OCaml that programmers can define.
It is a composite of other types of data, each of which is named.
OCaml records are much like structs in C.  Here's an example
of a record type definition for a Pok&eacute;<u>mon</u>:
```
type mon = {name: string; hp : int; ptype: ptype}
```
This type defines a record with three *fields* named `name`, 
`hp` (hit points), and `ptype` (defined above).  The type
of each of those fields is also given.  Note that `ptype`
can be used as both a type name and a field name; the *namespace*
for those is distinct in OCaml.

To build a value of a record type, we write a record expression,
which looks like this:
```
{name = "Charmander"; hp = 39; ptype = TFire}
```
So in a type definition we write a colon between the name and the type
of a field, but in an expression we write an equals sign.

To access a record and get a field from it, we use the dot notation
that you would expect from many other languages.  For example:
```
# let c = {name = "Charmander"; hp = 39; ptype = TFire};;
# c.hp;;
- : int = 39
```

It's also possible to use pattern matching to access record fields:
```
match c with 
| {name=n; hp=h; ptype=t} -> h
```
The `n`, `h`, and `t` here are pattern variables.  There is a syntactic
sugar provided if you want to use the same name for both the field
and a pattern variable:
```
match c with 
| {name; hp; ptype} -> hp
```
Here, the pattern `{name; hp; ptype}` is sugar for `{name=name; hp=hp; ptype=ptype}`.
In each of those subexpressions, the identifier appearing on the left-hand side
of the equals is a field name, and the identifier appearing on the right-hand
side is a pattern variable.

**Syntax.**

A record expression is written:
```
{f1 = e1; ...; fn = en}
```
The order of the `fi=ei` inside a record expression is irrelevant. 
For example, `{f=e1;g=e2}` is entirely equivalent to `{g=e2;f=e1}`.

A field access is written:
```
e.f
```
where `f` is an identifier of a field name, not an expression.

**Dynamic semantics.**

* If for all `i` in `1..n`, it holds that `ei ==> vi`, then
  `{f1=e1; ...; fn=en} ==> {f1=v1; ...; fn=vn}`.
  
* If `e ==> {...; f=v; ...}` then `e.f ==> v`.
  
**Static semantics.**

A record type is written:
```
{f1 : t1; ...; fn : tn}
```
The order of the `fi:ti` inside a record type is irrelevant. 
For example, `{f:t1;g:t2}` is entirely equivalent to `{g:t2;f:t1}`.

Note that record types must be defined before they can be used.  This
enables OCaml to do better type inference than would be possible if
record types could be used without definition.

The type checking rules are:

* If for all `i` in `1..n`, it holds that `ei : ti`, and if
  `t` is defined to be `{f1:t1; ...; fn:tn}`, then
  `{f1=e1; ...; fn=en} : t`.  Note that the set of fields provided in a 
   record expression must be the full set of fields defined as part of the 
   record's type.
  
* If `e : t1` and if `t1` is defined to be `{...; f:t2; ...}`, then
  `e.f : t2`.
  
**Record copy.**

Another syntax is also provided to construct a new record out of an old record:
```
{e with f1 = e1; ...; fn = en}
```
This doesn't mutate the old record; it constructs a new one with new values.
The set of fields provided after the `with` does not have to be the full
set of fields defined as part of the record's type.  In the newly copied
record, any field not provided as part of the `with` is copied
from the old record.

The dynamic and static semantics of this are what you might expect, though
they are tedious to write down mathematically.  

**Pattern matching.**

We add the following new pattern form to the list of legal patterns:

* `{f1=p1; ...; fn=pn}`

And we extend the definition of when a pattern matches a value and produces
a binding as follows:

* If for all `i` in `1..n`, it holds that `pi` matches `vi` and produces
  bindings $$b_i$$, then the record pattern `{f1=p1; ...; fn=pn}` matches the 
  record value `{f1=v1; ...; fn=vn; ...}` and produces the set 
  $$\bigcup_i b_i$$ of bindings.
  Note that the record value may have more fields than the record pattern does.

As a syntactic sugar, another form of record pattern is provided:  `{f1; ...; fn}`.
It is desugared to `{f1=f1; ...; fn=fn}`.
