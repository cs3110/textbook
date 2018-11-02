# Example:  Evaluating SimPL in the Substitution Model

Let's begin by defining a small-step substitution-model semantics
for SimPL.  That is, we're going to define a relation `-->` that
represents how an expression take a single step at a time, and
we'll implement variables using substitution of values for names.

Recall the syntax of SimPL:
```
e ::= x | i | b | e1 bop e2                
    | if e1 then e2 else e3
    | let x = e1 in e2     

bop ::= + | * | <=
```

We're going to need to know when expressions are done evaluating,
that is, when they are considered to be values.  For SimPL,
we'll define the values as follows:
```
v ::= i | b
```
That is, a value is either an integer constant or a Boolean constant.

## Defining the Single-Step Relation

For each of the syntactic forms that a SimPL expression could have,
we'll now define some *evaluation rules*, which constitute an
inductive definition of the `-->` relation.  Each rule will
have the form `e --> e'`, meaning that `e` takes a single step
to `e'`.

Although variables are given first in the BNF, let's pass over
them for now, and come back to them after all the other forms.

**Constants.**  Integer and Boolean constants are already values,
so they cannot take a step.  That might at first seem surprising,
but remember that we are intending to also define a `-->*` relation
that will permit zero or more steps; whereas, the `-->` relation
represents *exactly* one step.

Technically, all we have to do to accomplish this is to just not
write any rules of the form `i --> e` or `b --> e` for some `e`.
So we're already done, actually:  we haven't defined any rules yet.

Let's introduce another notation written `e -/->`, which is meant
to look like an arrow with a slash through it, to mean "there does
not exist an `e'` such that `e --> e'`.  Using that we could
write:

* `i -/->`
* `b -/->`

Though not strictly speaking part of the definition of `-->`,
those propositions help us remember that constants do not step.
In fact, we could more generally write, "for all `v`, it holds
that `v -/->`."

**Binary operators.** A binary operator application `e1 bop e2` 
has two subexpressions, `e1` and `e2`.  That leads to some choices
about how to evaluate the expression:

* We could first evaluate the left-hand side `e1`, then the right-hand
  side `e2`, then apply the operator.
  
* Or we could do the right-hand side first, then the left-hand side.

* Or we could interleave the evaluation, first doing a step of `e1`,
  then of `e2`, then `e1`, then `e2`, etc.
  
* Or maybe the operator is a *short-circuit* operator, in which case
  one of the subexpressions might never be evaluated.
  
And there are many other strategies you might be able to invent.

It turns out that the OCaml language definition says that (for
non-short-circuit operators) it is unspecified which side is evaluated
first.  The current implementation happens to evaluate the right-hand
side first, but that's not something any programmer should rely upon.

Many people would expect left-to-right evaluation, so let's define
the `-->` relation for that.  We start by saying that the left-hand
side can take a step:
```
e1 bop e2 --> e1' bop e2
  if e1 --> e1'
```
Similarly to the type system for SimPL, this rule says that 
two expressions are in the `-->` relation if two other (simpler)
subexpressions are also in the `-->` relation.  That's what makes
it an inductive definition.

If the left-hand side is finished evaluating, then the right-hand
side may begin stepping:
```
v1 bop e2 --> v1 bop e2'
  if e2 --> e2'
```

Finally, when both sides have reached a value, the binary operator
may be applied:
```
v1 bop v2 --> v
  if v is the result of primitive operation v1 bop v2
```
By *primitive operation*, we mean that there is some underlying
notion of what `bop` actually means.  For example, the character
`+` is just a piece of syntax, but we are conditioned to understand
its meaning as an arithmetic addition operation.  The primitive
operation typically is something implemented by hardware (e.g.,
an `ADD` opcode), or by a run-time library (e.g., a `pow` function).

For SimPL, let's delegate all primitive operations to OCaml.
That is, the SimPL `+` operator will be the same as the OCaml
`+` operator, as will `*` and `<=`.

**If expressions.**  As with binary operators, there are many choices
of how to evaluate the subexpressions of an if expression.  Nonetheless,
most programmers would expect the guard to be evaluated first,
then only one of the branches to be evaluated, because that's how
most languages work.  So let's write evaluation rules for that
semantics.

First, the guard is evaluated to a value:
```
if e1 then e2 else e3 --> if e1' then e2 else e3
  if e1 --> e1'
```
Then, based on the guard, the if expression is simplified
to just one of the branches:
```
if true then e2 else e3 --> e2

if false then e2 else e3 --> e3
```

**Let expressions.** Let's make SimPL let expressions evaluate in the
same way as OCaml let expressions:  first the binding expression,
then the body.

The rule that steps the binding expression is:
```
let x = e1 in e2 --> let x = e1' in e2
  if e1 --> e1'
```

Next, if the binding expression has reached a value, we want to
substitute that value for the name of the variable in the body
expression:
```
let x = v1 in e2 --> e2 with v1 substituted for x
```
For example, `let x = 42 in x+1` should step to `42+1`, because
substituting `42` for `x` in `x+1` yields `42+1`.

Of course, the right hand side of that rule isn't really an expression. 
It's just giving an intuition for the expression that we really want. 
We need to formally define what "substitute" means.  Perhaps
surprisingly, that turns out to be a definition that has vexed
mathematicians for centuries.

So for now, let's assume a new notation:  `e{e'/x}`, which means,
"the expression `e` with `e'` substituted for `x`."  We'll come
back to that notation in the next section and give it a careful 
definition.

For now, we can add this rule:
```
let x = v1 in e2 --> e2{v1/x}
```

**Variables.** Note how the let expression rule eliminates a variable
from showing up in the body expression:  the variable's name is 
replaced by the value that variable should have.  So, we should *never*
reach the point of attempting to step a variable name&mdash;assuming
that the program was well typed.

Consider OCaml:  if we try to evaluate an expression with an unbound
variable, what happens?  Let's check utop:
```
# x;;
Error: Unbound value x

# let y = x in y;;
Error: Unbound value x
```
It's an error (a type-checking error) for an expression to contain
an unbound variable.  Thus, any well-typed expression `e` will
never reach the point of attempting to step a variable name.

As with constants, we therefore don't need to add any rules
for variables.  But, for clarity, we could state that `x -/->`.

## Defining the Multistep Relation

Now that we've defined `-->`, there's really nothing left to do
to define `-->*`.  It's just the reflexive transitive closure
of `-->`.  In other words, it can be defined with just these
two rules:

```
e -->* e

e -->* e''
  if e --> e' and e' -->* e''
```

## Defining the Big-Step Relation

Recall that our goal in defining the big-step relation `==>`
is to make sure it agrees with the multistep relation `-->*`.

Constants are easy, because they big-step to themselves:
```
i ==> i

b ==> b
```

Binary operators just big-step both of their subexpressions,
then apply whatever the primitive operator is:
```
e1 bop e2 ==> v
  if e1 ==> v1
  and e2 ==> v2
  and v is the result of primitive operation v1 bop v2
```

If expressions big step the guard, then big step one
of the branches:
```
if e1 then e2 else e3 ==> v2
  if e1 ==> true
  and e2 ==> v2
  
if e1 then e2 else e3 ==> v3
  if e1 ==> false
  and e3 ==> v3
```

Let expressions big step the binding expression, do a
substitution, and big step the result of the substitution:
```
let x = e1 in e2 ==> v2
  if e1 ==> v1
  and e2{v1/x} ==> v2
```

Finally, variables do not big step, for the same reason
as with the small step semantics&mdash;a well-typed program
will never reach the point of attempting to evaluate
a variable name:
```
x =/=>
```
