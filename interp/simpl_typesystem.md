# Example: A Type System for SimPL

Recall the syntax of SimPL:
```
e ::= x | i | b | e1 bop e2                
    | if e1 then e2 else e3
    | let x = e1 in e2     

bop ::= + | * | <=
```

Let's define a type system `ctx |- e : t` for SimPL.
The only types in SimPL are integers and booleans:
```
t ::= int | bool
```

To define `|-`, we'll invent a set of *typing rules* that specify what
the type of an expression is based on the types of its subexpressions.
In other words, `|-` is an *inductively-defined relation*, as you
learned about in CS 2800.  So, it has some base cases, and some
inductive cases.

## Base Cases

An integer constant has type `int` in any context whatsoever,
a Boolean constant likewise always has type `bool`, and a 
variable has whatever type the context says it 
should have.  Here are the typing rules that express those ideas:

```
ctx |- i : int
ctx |- b : bool
{x : t, ...} |- x : t
```

## Inductive Cases

**Let.**
As we already know from OCaml, we type check the body of 
a let expression using a scope 
that is extended with a new binding. 
```
ctx |- let x = e1 in e2 : t2
  if ctx |- e1 : t1
  and ctx[x -> t1] |- e2 : t2
```
The rule says that `let x = e1 in e2` has type `t` in context `ctx`, but
only if certain conditions hold.  The first condition is that
`e1` has type `t1` in `ctx`.  The second is that `e2` has type `t2`
in a new context, which is `ctx` extended to bind `x` to `t1`.

**Binary operators.**
We'll need a couple different rules for binary operators.
```
ctx |- e1 bop e2 : int
  if bop is + or *
  and ctx |- e1 : int
  and ctx |- e2 : int
  
ctx |- e1 <= e2 : bool
  if ctx |- e1 : int
  and ctx |- e2 : int
```

**If.** 
Just like OCaml, an if expression must have a Boolean guard,
and its two branches must have the same type.
```
ctx |- if e1 then e2 else e3 : t
  if ctx |- e1 : bool
  and ctx |- e2 : t
  and ctx |- e3 : t
```
