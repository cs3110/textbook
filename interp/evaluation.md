# Evaluation

After type checking (and other semantic analysis), the next phase
of compilation is to rewrite the AST into an intermediate representation
(IR), in preparation for translating the program into machine code.

An interpreter might also rewrite the AST into an IR, or it might
directly begin evaluating the AST.  One reason to rewrite the AST
would be to simplify it:  sometimes, certain language features
can be implemented in terms of others, and it makes sense to reduce
the language to a small core to keep the interpreter implementation
shorter.  Syntactic sugar is a great example of that idea.

## Desugaring

Eliminating syntactic sugar is called *desugaring.*
As an example, we know that `let x = e1 in e2` and
`(fun x -> e2) e1` are equivalent.  So, we could regard
let expressions as syntactic sugar.  

Suppose we had a language whose AST corresponded to this BNF:
```
e ::= x | fun x -> e | e1 e2
    | let x = e1 in e2
```
Then the interpreter could desugar that into a simpler AST&mdash;in
a sense, an IR&mdash;by transforming all occurrences of 
`let x = e1 in e2` into `(fun x -> e2) e1`.  Then the interpreter
would need to evaluate only this smaller language:
```
e ::= x | fun x -> e | e1 e2
```

## Evaluating the AST

Let's assume we've now reached the point of having simplified the AST,
if desired, so it's time to evaluate it.  *Evaluation* is the process of
continuing to simplify the AST until it's just a value.  In other words,
evaluation is the implementation of the language's dynamic semantics.

Recall that a *value* is an expression for which there is no computation
remaining to be done.  Typically, we think of values as a strict
syntactic subset of expressions, though we'll see some exceptions to
that later.

We'll define evaluation with a mathematical relation, just as we did 
with type checking.  Actually, we're going to define three
relations for evaluation:

* The first, `-->`, will represent how a program takes one single step
  of execution.
  
* The second, `-->*`, is the reflexive transitive closure of `-->`,
  and it represents how a program takes multiple steps of execution.
  
* The third, `==>`, abstracts away from all the details of single
  steps and represents how a program reduces directly to a value.
  
The style in which we are defining evaluation with these relations
is known as *operational semantics*, because we're using the relations
to specify how the machine "operates" as it evaluates programs.
There are two other major styles, known as *denotational semantics*
and *axiomatic semantics*, but we won't cover those here.  Take
CS 4110 if you want to learn more!

## Small Steps vs. Big Steps

We can further divide operational semantics into two separate sub-styles
of defining evaluation: *small step* vs. *big step* semantics. The first
relation, `-->`, is in the small-step style, because it represents
execution in terms of individual small steps.  The third, `==>`, is in
the big-step style, because it represents execution in terms of a big
step from an expression directly to a value. The second relation,
`-->*`, blends the two.  Indeed, our desire is for it to bridge the gap
in the following sense:

**Relating big and small steps:**
For all expressions `e` and values `v`, it holds that `e -->* v`
if and only if `e ==> v`.

In other words, if an expression takes many small steps and eventually
reaches a value, e.g., `e --> e1 --> .... --> en --> v`,
then it ought to be the case that `e ==> v`.  So the big step
relation is a faithful abstraction of the small step relation:
it just forgets about all the intermediate steps.

Why have two different styles, big and small?  Each is a little
easier to use than the other in certain circumstances, so it
helps to have both in our toolkit.  The small-step semantics
tends to be easier to work with when it comes to modeling
complicated language features, but the big-step semantics
tends to be more similar to how an interpreter would actually
be implemented.

## Variables

There's another choice we have to make, and it's orthogonal
to the choice of small vs. big step.  There are two different
ways to think about the implementation of variables:

* We could eagerly *substitute* the value of a variable for its name
  throughout the scope of that name, as soon as we finding a binding 
  of the variable.
  
* We could lazily record the substitution in a dictionary, which
  is usually called an *environment* when used for this purpose,
  and we could look up the variable's value in that environment whenever
  we find its name mentioned in a scope.
  
Those ideas lead to the *substitution model* of evaluation and
the *environment model* of evaluation.  As with small step
vs. big step, the substitution model tends to be nicer to work
with mathematically, whereas the environment model tends
to be more similar to how an interpreter is implemented.

Some examples will help to make sense of all this.  Let's
look, next, at how to define the relations for SimPL.
