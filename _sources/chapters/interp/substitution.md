# Substitution Model

After lexing and parsing, the next phase is type checking (and other semantic
analysis). We will skip that phase for now and return to it at the end of this
chapter.

Instead, let's turn our attention to evaluation. In a compiler, the next phase
after semantic analysis would be rewriting the AST into an intermediate
representation (IR), in preparation for translating the program into machine
code. An interpreter might also rewrite the AST into an IR, or it might directly
begin evaluating the AST. One reason to rewrite the AST would be to simplify it:
sometimes, certain language features can be implemented in terms of others, and
it makes sense to reduce the language to a small core to keep the interpreter
implementation shorter. Syntactic sugar is a great example of that idea.

Eliminating syntactic sugar is called *desugaring.* As an example, we know that
`let x = e1 in e2` and `(fun x -> e2) e1` are equivalent. So, we could regard
let expressions as syntactic sugar.

Suppose we had a language whose AST corresponded to this BNF:

```text
e ::= x | fun x -> e | e1 e2
    | let x = e1 in e2
```

Then the interpreter could desugar that into a simpler AST&mdash;in
a sense, an IR&mdash;by transforming all occurrences of
`let x = e1 in e2` into `(fun x -> e2) e1`.  Then the interpreter
would need to evaluate only this smaller language:

```text
e ::= x | fun x -> e | e1 e2
```

After having simplified the AST, it's time to evaluate it. *Evaluation* is the
process of continuing to simplify the AST until it's just a value. In other
words, evaluation is the implementation of the language's dynamic semantics.
Recall that a *value* is an expression for which there is no computation
remaining to be done. Typically, we think of values as a strict syntactic subset
of expressions, though we'll see some exceptions to that later.

**Big vs. small step evaluation.** We'll define evaluation with a mathematical
relation, just as we did with type checking. Actually, we're going to define
three relations for evaluation:

* The first, `-->`, will represent how a program takes one single step of
  execution.

* The second, `-->*`, is the reflexive transitive closure of `-->`, and it
  represents how a program takes multiple steps of execution.

* The third, `==>`, abstracts away from all the details of single steps and
  represents how a program reduces directly to a value.

The style in which we are defining evaluation with these relations is known as
*operational semantics*, because we're using the relations to specify how the
machine "operates" as it evaluates programs. There are two other major styles,
known as *denotational semantics* and *axiomatic semantics*, but we won't cover
those here.

We can further divide operational semantics into two separate sub-styles of
defining evaluation: *small step* vs. *big step* semantics. The first relation,
`-->`, is in the small-step style, because it represents execution in terms of
individual small steps. The third, `==>`, is in the big-step style, because it
represents execution in terms of a big step from an expression directly to a
value. The second relation, `-->*`, blends the two. Indeed, our desire is for it
to bridge the gap in the following sense:

**Relating big and small steps:** For all expressions `e` and values `v`, it
holds that `e -->* v` if and only if `e ==> v`.

In other words, if an expression takes many small steps and eventually reaches a
value, e.g., `e --> e1 --> .... --> en --> v`, then it ought to be the case that
`e ==> v`. So the big step relation is a faithful abstraction of the small step
relation: it just forgets about all the intermediate steps.

Why have two different styles, big and small? Each is a little easier to use
than the other in certain circumstances, so it helps to have both in our
toolkit. The small-step semantics tends to be easier to work with when it comes
to modeling complicated language features, but the big-step semantics tends to
be more similar to how an interpreter would actually be implemented.

**Substitution vs. environment models.** There's another choice we have to make,
and it's orthogonal to the choice of small vs. big step. There are two different
ways to think about the implementation of variables:

* We could eagerly *substitute* the value of a variable for its name throughout
  the scope of that name, as soon as we finding a binding of the variable.

* We could lazily record the substitution in a dictionary, which is usually
  called an *environment* when used for this purpose, and we could look up the
  variable's value in that environment whenever we find its name mentioned in a
  scope.

Those ideas lead to the *substitution model* of evaluation and the *environment
model* of evaluation. As with small step vs. big step, the substitution model
tends to be nicer to work with mathematically, whereas the environment model
tends to be more similar to how an interpreter is implemented.

Some examples will help to make sense of all this. Let's look, next, at how to
define the relations for SimPL.

## Evaluating SimPL in the Substitution Model

Let's begin by defining a small-step substitution-model semantics for SimPL.
That is, we're going to define a relation `-->` that represents how an
expression take a single step at a time, and we'll implement variables using
substitution of values for names.

Recall the syntax of SimPL:

```text
e ::= x | i | b | e1 bop e2
    | if e1 then e2 else e3
    | let x = e1 in e2

bop ::= + | * | <=
```

We're going to need to know when expressions are done evaluating, that is, when
they are considered to be values. For SimPL, we'll define the values as follows:

```text
v ::= i | b
```

That is, a value is either an integer constant or a Boolean constant.

For each of the syntactic forms that a SimPL expression could have, we'll now
define some *evaluation rules*, which constitute an inductive definition of the
`-->` relation. Each rule will have the form `e --> e'`, meaning that `e` takes
a single step to `e'`.

Although variables are given first in the BNF, let's pass over them for now, and
come back to them after all the other forms.

**Constants.** Integer and Boolean constants are already values, so they cannot
take a step. That might at first seem surprising, but remember that we are
intending to also define a `-->*` relation that will permit zero or more steps;
whereas, the `-->` relation represents *exactly* one step.

Technically, all we have to do to accomplish this is to just not write any rules
of the form `i --> e` or `b --> e` for some `e`. So we're already done,
actually: we haven't defined any rules yet.

Let's introduce another notation written `e -/->`, which is meant to look like
an arrow with a slash through it, to mean "there does not exist an `e'` such
that `e --> e'`. Using that we could write:

* `i -/->`
* `b -/->`

Though not strictly speaking part of the definition of `-->`, those propositions
help us remember that constants do not step. In fact, we could more generally
write, "for all `v`, it holds that `v -/->`."

**Binary operators.** A binary operator application `e1 bop e2` has two
subexpressions, `e1` and `e2`. That leads to some choices about how to evaluate
the expression:

* We could first evaluate the left-hand side `e1`, then the right-hand side
  `e2`, then apply the operator.

* Or we could do the right-hand side first, then the left-hand side.

* Or we could interleave the evaluation, first doing a step of `e1`, then of
  `e2`, then `e1`, then `e2`, etc.

* Or maybe the operator is a *short-circuit* operator, in which case one of the
  subexpressions might never be evaluated.

And there are many other strategies you might be able to invent.

It turns out that the OCaml language definition says that (for non-short-circuit
operators) it is unspecified which side is evaluated first. The current
implementation happens to evaluate the right-hand side first, but that's not
something any programmer should rely upon.

Many people would expect left-to-right evaluation, so let's define the `-->`
relation for that. We start by saying that the left-hand side can take a step:

```text
e1 bop e2 --> e1' bop e2
  if e1 --> e1'
```

Similarly to the type system for SimPL, this rule says that two expressions are
in the `-->` relation if two other (simpler) subexpressions are also in the
`-->` relation. That's what makes it an inductive definition.

If the left-hand side is finished evaluating, then the right-hand side may begin
stepping:

```text
v1 bop e2 --> v1 bop e2'
  if e2 --> e2'
```

Finally, when both sides have reached a value, the binary operator
may be applied:

```text
v1 bop v2 --> v
  if v is the result of primitive operation v1 bop v2
```

By *primitive operation*, we mean that there is some underlying notion of what
`bop` actually means. For example, the character `+` is just a piece of syntax,
but we are conditioned to understand its meaning as an arithmetic addition
operation. The primitive operation typically is something implemented by
hardware (e.g., an `ADD` opcode), or by a run-time library (e.g., a `pow`
function).

For SimPL, let's delegate all primitive operations to OCaml. That is, the SimPL
`+` operator will be the same as the OCaml `+` operator, as will `*` and `<=`.

Here's an example of using the binary operator rule:

```text
    (3*1000) + ((1*100) + ((1*10) + 0))
--> 3000 + ((1*100) + ((1*10) + 0))
--> 3000 + (100 + ((1*10) + 0))
--> 3000 + (100 + (10 + 0))
--> 3000 + (100 + 10)
--> 3000 + 110
--> 3110
```

**If expressions.** As with binary operators, there are many choices of how to
evaluate the subexpressions of an if expression. Nonetheless, most programmers
would expect the guard to be evaluated first, then only one of the branches to
be evaluated, because that's how most languages work. So let's write evaluation
rules for that semantics.

First, the guard is evaluated to a value:

```text
if e1 then e2 else e3 --> if e1' then e2 else e3
  if e1 --> e1'
```

Then, based on the guard, the if expression is simplified
to just one of the branches:

```text
if true then e2 else e3 --> e2

if false then e2 else e3 --> e3
```

**Let expressions.** Let's make SimPL let expressions evaluate in the same way
as OCaml let expressions: first the binding expression, then the body.

The rule that steps the binding expression is:

```text
let x = e1 in e2 --> let x = e1' in e2
  if e1 --> e1'
```

Next, if the binding expression has reached a value, we want to substitute that
value for the name of the variable in the body expression:

```text
let x = v1 in e2 --> e2 with v1 substituted for x
```

For example, `let x = 42 in x + 1` should step to `42 + 1`, because substituting
`42` for `x` in `x + 1` yields `42 + 1`.

Of course, the right hand side of that rule isn't really an expression. It's
just giving an intuition for the expression that we really want. We need to
formally define what "substitute" means. It turns out to be rather tricky. So,
rather then getting side-tracked by it right now, let's assume a new notation:
`e'{e/x}`, which means, "the expression `e'` with `e` substituted for `x`."
We'll come back to that notation in the next section and give it a careful
definition.

For now, we can add this rule:

```text
let x = v1 in e2 --> e2{v1/x}
```

**Variables.** Note how the let expression rule eliminates a variable from
showing up in the body expression: the variable's name is replaced by the value
that variable should have. So, we should *never* reach the point of attempting
to step a variable name&mdash;assuming that the program was well typed.

Consider OCaml: if we try to evaluate an expression with an unbound variable,
what happens? Let's check utop:

```text
# x;;
Error: Unbound value x

# let y = x in y;;
Error: Unbound value x
```

It's an error &mdash;a type-checking error&mdash; for an expression to contain
an unbound variable. Thus, any well-typed expression `e` will never reach the
point of attempting to step a variable name.

As with constants, we therefore don't need to add any rules for variables. But,
for clarity, we could state that `x -/->`.

## Implementing the Single-Step Relation

It's easy to turn the above definitions of `-->` into an OCaml function that
pattern matches against AST nodes. In the code below, recall that we have yet
finished defining substitution (i.e., `subst`); we'll return to that in the next
section.

```ocaml
(** [is_value e] is whether [e] is a value. *)
let is_value : expr -> bool = function
  | Int _ | Bool _ -> true
  | Var _ | Let _ | Binop _ | If _ -> false

(** [subst e v x] is [e{v/x}]. *)
let subst e v x =
  failwith "See next section"

(** [step] is the [-->] relation, that is, a single step of
    evaluation. *)
let rec step : expr -> expr = function
  | Int _ | Bool _ -> failwith "Does not step"
  | Var _ -> failwith "Unbound variable"
  | Binop (bop, e1, e2) when is_value e1 && is_value e2 ->
    step_bop bop e1 e2
  | Binop (bop, e1, e2) when is_value e1 ->
    Binop (bop, e1, step e2)
  | Binop (bop, e1, e2) -> Binop (bop, step e1, e2)
  | Let (x, e1, e2) when is_value e1 -> subst e2 e1 x
  | Let (x, e1, e2) -> Let (x, step e1, e2)
  | If (Bool true, e2, _) -> e2
  | If (Bool false, _, e3) -> e3
  | If (Int _, _, _) -> failwith "Guard of if must have type bool"
  | If (e1, e2, e3) -> If (step e1, e2, e3)

(** [step_bop bop v1 v2] implements the primitive operation
    [v1 bop v2].  Requires: [v1] and [v2] are both values. *)
and step_bop bop e1 e2 = match bop, e1, e2 with
  | Add, Int a, Int b -> Int (a + b)
  | Mult, Int a, Int b -> Int (a * b)
  | Leq, Int a, Int b -> Bool (a <= b)
  | _ -> failwith "Operator and operand type mismatch"
```

The only new thing we had to deal with in that implementation was the two places
where a run-time type error is discovered, namely, in the evaluation of
`If (Int _, _, _)` and in the very last line, in which we discover that a binary
operator is being applied to arguments of the wrong type. Type checking will
guarantee that an exception never gets raised here, but OCaml's exhaustiveness
analysis of pattern matching forces us to write a branch nonetheless. Moreover,
if it ever turned out that we had a bug in our type checker that caused
ill-typed binary operator applications to be evaluated, this exception would
help us discover what was going wrong.

## The Multistep Relation

Now that we've defined `-->`, there's really nothing left to do to define
`-->*`. It's just the reflexive transitive closure of `-->`. In other words, it
can be defined with just these two rules:

```text
e -->* e

e -->* e''
  if e --> e' and e' -->* e''
```

Of course, in implementing an interpreter, what we really want is to take
multiple steps until the expression reaches a value. That is, we want to take as
many steps as possible. So, we're interested in the sub-relation `e -->* v` in
which the right-hand side is a value. That's easy to implement:

```ocaml
(** [eval_small e] is the [e -->* v] relation.  That is,
    keep applying [step] until a value is produced.  *)
let rec eval_small (e : expr) : expr =
  if is_value e then e
  else e |> step |> eval_small
```

## Defining the Big-Step Relation

Recall that our goal in defining the big-step relation `==>` is to make sure it
agrees with the multistep relation `-->*`.

Constants are easy, because they big-step to themselves:

```text
i ==> i

b ==> b
```

Binary operators just big-step both of their subexpressions,
then apply whatever the primitive operator is:

```text
e1 bop e2 ==> v
  if e1 ==> v1
  and e2 ==> v2
  and v is the result of primitive operation v1 bop v2
```

If expressions big step the guard, then big step one
of the branches:

```text
if e1 then e2 else e3 ==> v2
  if e1 ==> true
  and e2 ==> v2

if e1 then e2 else e3 ==> v3
  if e1 ==> false
  and e3 ==> v3
```

Let expressions big step the binding expression, do a substitution, and big step
the result of the substitution:

```text
let x = e1 in e2 ==> v2
  if e1 ==> v1
  and e2{v1/x} ==> v2
```

Finally, variables do not big step, for the same reason as with the small step
semantics&mdash;a well-typed program will never reach the point of attempting to
evaluate a variable name:

```text
x =/=>
```

## Implementing the Big-Step Relation

The big-step evaluation relation is, if anything, even easier to implement than
the small-step relation. It just recurses over the tree, evaluating
subexpressions as required by the definition of `==>`:

```ocaml
(** [eval_big e] is the [e ==> v] relation. *)
let rec eval_big (e : expr) : expr = match e with
  | Int _ | Bool _ -> e
  | Var _ -> failwith "Unbound variable"
  | Binop (bop, e1, e2) -> eval_bop bop e1 e2
  | Let (x, e1, e2) -> subst e2 (eval_big e1) x |> eval_big
  | If (e1, e2, e3) -> eval_if e1 e2 e3

(** [eval_bop bop e1 e2] is the [e] such that [e1 bop e2 ==> e]. *)
and eval_bop bop e1 e2 = match bop, eval_big e1, eval_big e2 with
  | Add, Int a, Int b -> Int (a + b)
  | Mult, Int a, Int b -> Int (a * b)
  | Leq, Int a, Int b -> Bool (a <= b)
  | _ -> failwith "Operator and operand type mismatch"

(** [eval_if e1 e2 e3] is the [e] such that [if e1 then e2 else e3 ==> e]. *)
and eval_if e1 e2 e3 = match eval_big e1 with
  | Bool true -> eval_big e2
  | Bool false -> eval_big e3
  | _ -> failwith "Guard of if must have type bool"
```

It's good engineering practice to factor out functions for each of the pieces of
syntax, as we did above, unless the implementation can fit on just a single line
in the main pattern match inside `eval_big`.

## Substitution in SimPL

In the previous section, we posited a new notation `e'{e/x}`, meaning
"the expression `e'` with `e` substituted for `x`." The intuition is
that anywhere `x` appears in `e'`, we should replace `x` with `e`.

Let's give a careful definition of substitution for SimPL. For the most part,
it's not too hard.

**Constants** have no variables appearing in them (e.g., `x` cannot
syntactically occur in `42`), so substitution leaves them unchanged:

```text
i{e/x} = i
b{e/x} = b
```

For **binary operators and if expressions**, all that substitution needs to do
is to recurse inside the subexpressions:

```text
(e1 bop e2){e/x} = e1{e/x} bop e2{e/x}
(if e1 then e2 else e3){e/x} = if e1{e/x} then e2{e/x} else e3{e/x}
```

**Variables** start to get a little trickier. There are two possibilities:
either we encounter the variable `x`, which means we should do the substitution,
or we encounter some other variable with a different name, say `y`, in which
case we should not do the substitution:

```text
x{e/x} = e
y{e/x} = y
```

The first of those cases, `x{e/x} = e`, is important to note: it's where the
substitution operation finally takes place. Suppose, for example, we were trying
to figure out the result of `(x + 42){1/x}`. Using the definitions from above,

```text
  (x + 42){1/x}
= x{1/x} + 42{1/x}   by the bop case
= 1 + 42{1/x}        by the first variable case
= 1 + 42             by the integer case
```

Note that we are not defining the `-->` relation right now. That is, none of
these equalities represents a step of evaluation. To make that concrete, suppose
we were evaluating `let x = 1 in x + 42`:

```text
    let x = 1 in x + 42
--> (x + 42){1/x}
  = 1 + 42
--> 43
```

There are two single steps here, one for the `let` and the other for `+`. But we
consider the substitution to happen all at once, as part of the step that `let`
takes. That's why we write `(x + 42){1/x} = 1 + 42`, not
`(x + 42){1/x} --> 1 + 42`.

Finally, **let expressions** also have two cases, depending on the name of the
bound variable:

```text
(let x = e1 in e2){e/x}  =  let x = e1{e/x} in e2
(let y = e1 in e2){e/x}  =  let y = e1{e/x} in e2{e/x}
```

Both of those cases substitute `e` for `x` inside the binding expression `e1`.
That's to ensure that expressions like `let x = 42 in let y = x in y` would
evaluate correctly: `x` needs to be in scope inside the binding `y = x`, so we
have to do a substitution there regardless of the name being bound.

But the first case does not do a substitution inside `e2`, whereas the second
case does. That's so we *stop* substituting when we reach a shadowed name.
Consider `let x = 5 in let x = 6 in x`. We know it would evaluate to `6` in
OCaml because of shadowing. Here's how it would evaluate with our definitions of
SimPL:

```text
    let x = 5 in let x = 6 in x
--> (let x = 6 in x){5/x}
  = let x = 6{5/x} in x      ***
  = let x = 6 in x
--> x{6/x}
  = 6
```

On the line tagged `***` above, we've stopped substituting inside the body
expression, because we reached a shadowed variable name. If we had instead kept
going inside the body, we'd get a different result:

```text
    let x = 5 in let x = 6 in x
--> (let x = 6 in x){5/x}
  = let x = 6{5/x} in x{5/x}      ***WRONG***
  = let x = 6 in 5
--> 5{6/x}
  = 5
```

**Example 1:**

```text
let x = 2 in x + 1
--> (x + 1){2/x}
  = 2 + 1
--> 3
```

**Example 2:**

```text
    let x = 0 in (let x = 1 in x)
--> (let x = 1 in x){0/x}
  = (let x = 1{0/x} in x)
  = (let x = 1 in x)
--> x{1/x}
  = 1
```

**Example 3:**

```text
    let x = 0 in x + (let x = 1 in x)
--> (x + (let x = 1 in x)){0/x}
  = x{0/x} + (let x = 1 in x){0/x}
  = 0 + (let x = 1{0/x} in x)
  = 0 + (let x = 1 in x)
--> 0 + x{1/x}
  = 0 + 1
--> 1
```

## Implementing Substitution

The definitions above are easy to turn into OCaml code. Note that, although we
write `v` below, the function is actually able to substitute any expression for
a variable, not just a value. The interpreter will only ever call this function
on a value, though.

```ocaml
(** [subst e v x] is [e] with [v] substituted for [x], that
    is, [e{v/x}]. *)
let rec subst e v x = match e with
  | Var y -> if x = y then v else e
  | Bool _ -> e
  | Int _ -> e
  | Binop (bop, e1, e2) -> Binop (bop, subst e1 v x, subst e2 v x)
  | Let (y, e1, e2) ->
    let e1' = subst e1 v x in
    if x = y
    then Let (y, e1', e2)
    else Let (y, e1', subst e2 v x)
  | If (e1, e2, e3) ->
    If (subst e1 v x, subst e2 v x, subst e3 v x)
```

## The SimPL Interpreter is Done!

We've completed developing our SimPL interpreter. Recall that the finished
interpreter can be downloaded here: {{ code_link | replace("%%NAME%%",
"simpl.zip") }}. It includes some rudimentary test cases, as well as makefile
targets that you will find helpful.

## Capture-Avoiding Substitution

The definition of substitution for SimPL was a little tricky but not too
complicated. It turns out, though, that for other languages, the definition gets
more complicated.

Let's consider this tiny language:

```text
e ::= x | e1 e2 | fun x -> e
v ::= fun x -> e
```

It is known as the *lambda calculus*. There are only three kinds of expressions
in it: variables, function application, and anonymous functions. The only values
are anonymous functions. The language isn't even typed. Yet, one of its most
remarkable properties is that it *computationally universal:* it can express any
computable function. (To learn more about that, read about the *Church-Turing
Hypothesis*.)

Defining a big-step evaluation relation for the lambda calculus is
straightforward. In fact, there's only one rule required:

```text
e1 e2 ==> v
  if e1 ==> fun x -> e
  and e2 ==> v2
  and e{v2/x} ==> v
```

That rule is named *call by value*, because it requires arguments to be reduced
to a value before a function can be applied. If that seems obvious, it's because
you're used to it from OCaml. Other languages use other rules. For example,
Haskell uses a variant on *call by name*, which is this rule:

```text
e1 e2 ==> v
  if e1 ==> fun x -> e
  and e{e2/x} ==> v
```

With call by name, `e2` does not have to be reduced to a value; that can lead to
greater efficiency if the value of `e2` is never needed.

Now we need to define the substitution operation for the lambda calculus. We'd
like a definition that works for either call by name or call by value. Inspired
by our definition for SimPL, here's the beginning of a definition:

```text
x{e/x} = e
y{e/x} = y
(e1 e2){e/x} = e1{e/x} e2{e/x}
```

The first two lines are exactly how we defined variable substitution in SimPL.
The next line resembles how we defined binary operator substitution; we just
recurse into the subexpressions.

What about substitution in a function? In SimPL, we stopped substituting when we
reached a bound variable of the same name; otherwise, we proceeded. In the
lambda calculus, that idea would be stated as follows:

```text
(fun x -> e'){e/x} = fun x -> e'
(fun y -> e'){e/x} = fun y -> e'{e/x}
```

Perhaps surprisingly, that definition turns out to be incorrect. Here's why: it
violates the Principle of Name Irrelevance. Suppose we were attempting this
substitution:

```text
(fun z -> x){z/x}
```

The result would be:

```text
  fun z -> x{z/x}
= fun z -> z
```

And, suddenly, a function that was *not* the identity function becomes the
identity function. Whereas, if we had attempted this substitution:

```text
(fun y -> x){z/x}
```

The result would be:

```text
  fun y -> x{z/x}
= fun y -> z
```

Which is not the identity function. So our definition of substitution inside
anonymous functions is incorrect, because it *captures* variables. A variable
name being substituted inside an anonymous function can accidentally be
"captured" by the function's argument name.

Note that we never had this problem in SimPL, in part because SimPL was typed.
The function `fun y -> z` if applied to any argument would just return `z`,
which is an unbound variable. But the lambda calculus is untyped, so we can't
rely on typing to rule out this possibility here. Moreover, with rules such as
call by name, we might well end up needing to evaluate such expressions.

So the question becomes, how do we define substitution so that it gets the right
answer, without capturing variables? The answer is called *capture-avoiding
substitution*, and a correct definition of it eluded mathematicians for
centuries.

A correct definition is as follows:

```text
(fun x -> e'){e/x} = fun x -> e'
(fun y -> e'){e/x} = fun y -> e'{e/x}  if y is not in FV(e)
```

where `FV(e)` means the "free variables" of `e`, i.e., the variables
that are not bound in it, and is defined as follows:

```text
FV(x) = {x}
FV(e1 e2) = FV(e1) + FV(e2)
FV(fun x -> e) = FV(e) - {x}
```

and `+` means set union, and `-` means set difference.

That definition prevents the substitution `(fun z -> x){z/x}` from occurring,
because `z` is in `FV(z)`.

Unfortunately, because of the side-condition `y is not in FV(e)`, the
substitution operation is now *partial*: there are times, like the example we
just gave, where it cannot be applied.

That problem can be solved by changing the names of variables: if we detect that
a partiality has been encountered, we can change the name of the function's
argument. For example, when `(fun z -> x){z/x}` is encountered, the function's
argument could be replaced with a new name `w` that doesn't occur anywhere else,
yielding `(fun w -> x){z/x}`. (And if `z` occurred anywhere in the body, it
would be replaced by `w`, too.) This is *replacement*, not substitution:
absolutely anywhere we see `z`, we replace it with `w`. Then the substitution
may proceed and correctly produce `fun w -> z`.

The tricky part of that is how to pick a new name that doesn't occur anywhere
else, that is, how to pick a *fresh* name. Here are three strategies:

1. Pick a new variable name, check whether is fresh or not, and if not, try
   again, until that succeeds. For example, if trying to replace `z`, you might
   first try `z'`, then `z''`, etc.

1. Augment the evaluation relation to maintain a stream (i.e., infinite list) of
   unused variable names. Each time you need a new one, take the head of the
   stream. But you have to be careful to use the tail of the stream anytime
   after that. To guarantee that they are unused, reserve some variable names
   for use by the interpreter alone, and make them illegal as variable names
   chosen by the programmer. For example, you might decide that programmer
   variable names may never start with the character `$`, then have a stream
   `<$x1, $x2, $x3, ...>` of fresh names.

1. Use an imperative counter to simulate the stream from the previous strategy.
   For example, the following function is guaranteed to return a fresh variable
   name each time it is called:
   ```ocaml
   let gensym =
     let counter = ref 0 in
     fun () -> incr counter; "$x" ^ string_of_int !counter
   ```
   The name `gensym` is traditional for this kind of function. It comes from
   LISP, and shows up throughout compiler implementations. It means
   <u>gen</u>erate a fresh <u>sym</u>bol.

There is a complete implementation of an interpreter for the lambda calculus,
including capture-avoiding substitution, that you can download: {{ code_link |
replace("%%NAME%%", "lambda-subst.zip") }}. It uses the `gensym` strategy from
above the generate fresh names. There is a definition named `strategy` in
`main.ml` that you can use to switch between call-by-value and call-by-name.

## Core OCaml

Let's now upgrade from SimPL and the lambda calculus to a larger language that
we call *core OCaml*. Here is its syntax in BNF:

```text
e ::= x | e1 e2 | fun x -> e
    | i | b | e1 bop e2
    | (e1, e2) | fst e | snd e
    | Left e | Right e
    | match e with Left x1 -> e1 | Right x2 -> e2
    | if e1 then e2 else e3
    | let x = e1 in e2

bop ::= + | * | < | =

x ::= <identifiers>

i ::= <integers>

b ::= true | false

v ::= fun x -> e | i | b | (v1, v2) | Left v | Right v
```

To keep tuples simple in this core model, we represent them with only two
components (i.e., they are pairs). A longer tuple could be coded up with nested
pairs. For example, `(1, 2, 3)` in OCaml could be `(1, (2, 3))` in this core
language.

Also to keep variant types simple in this core model, we represent them with
only two constructors, which we name `Left` and `Right`. A variant with more
constructors could be coded up with nested applications of those two
constructors. Since we have only two constructors, match expressions need only
two branches. One caution in reading the BNF above: the occurrence of `|` in the
match expression just before the `Right` constructor denotes syntax, not
metasyntax.

There are a few important OCaml constructs omitted from this core language,
including recursive functions, exceptions, mutability, and modules. Types are
also missing; core OCaml does not have any type checking. Nonetheless, there is
enough in this core language to keep us entertained.

## Evaluating Core OCaml in the Substitution Model

Let's define the small and big step relations for Core OCaml. To be honest,
there won't be much that's surprising at this point; we've seen just about
everything already in SimPL and in the lambda calculus.

**Small-Step Relation.** Here is the fragment of Core OCaml we already know from
SimPL:

```text
e1 + e2 --> e1' + e2
	if e1 --> e1'

v1 + e2 --> v1 + e2'
	if e2 --> e2'

i1 + i2 --> i3
	where i3 is the result of applying primitive operation +
	to i1 and i2

if e1 then e2 else e3 --> if e1' then e2 else e3
	if e1 --> e1'

if true then e2 else e3 --> e2

if false then e2 else e3 --> e3

let x = e1 in e2 --> let x = e1' in e2
	if e1 --> e1'

let x = v in e2 --> e2{v/x}
```

Here's the fragment of Core OCaml that corresponds to the lambda calculus:

```text
e1 e2 --> e1' e2
	if e1 --> e1'

v1 e2 --> v1 e2'
	if e2 --> e2'

(fun x -> e) v2 --> e{v2/x}
```

And here are the new parts of Core OCaml. First, **pairs** evaluate their first
component, then their second component:

```text
(e1, e2) --> (e1', e2)
	if e1 --> e1'

(v1, e2) --> (v1, e2')
	if e2 --> e2'

fst (v1,v2) --> v1

snd (v1,v2) --> v2
```

**Constructors** evaluate the expression they carry:

```text
Left e --> Left e'
	if e --> e'

Right e --> Right e'
	if e --> e'
```

**Pattern matching** evaluates the expression being matched, then reduces to one
of the branches:

```text
match e with Left x1 -> e1 | Right x2 -> e2
--> match e' with Left x1 -> e1 | Right x2 -> e2
	if e --> e'

match Left v with Left x1 -> e1 | Right x2 -> e2
--> e1{v/x1}

match Right v with Left x1 -> e1 | Right x2 -> e2
--> e2{v/x2}
```

**Substitution.** We also need to define the substitution operation for Core
OCaml. Here is what we already know from SimPL and the lambda calculus:

```text
i{v/x} = i

b{v/x} = b

(e1 + e2) {v/x} = e1{v/x} + e2{v/x}

(if e1 then e2 else e3){v/x}
 = if e1{v/x} then e2{v/x} else e3{v/x}

(let x = e1 in e2){v/x} = let x = e1{v/x} in e2

(let y = e1 in e2){v/x} = let y = e1{v/x} in e2{v/x}
  if y not in FV(v)

x{v/x} = v

y{v/x} = y

(e1 e2){v/x} = e1{v/x} e2{v/x}

(fun x -> e'){v/x} = (fun x -> e')

(fun y -> e'){v/x} = (fun y -> e'{v/x})
  if y not in FV(v)
```

Note that we've now added the requirement of capture-avoiding substitution to
the definitions for `let` and `fun`: they both require `y` not to be in the free
variables of `v`. We therefore need to define the free variables of an
expression:

```text
FV(x) = {x}
FV(e1 e2) = FV(e1) + FV(e2)
FV(fun x -> e) = FV(e) - {x}
FV(i) = {}
FV(b) = {}
FV(e1 bop e2) = FV(e1) + FV(e2)
FV((e1,e2)) = FV(e1) + FV(e2)
FV(fst e1) = FV(e1)
FV(snd e2) = FV(e2)
FV(Left e) = FV(e)
FV(Right e) = FV(e)
FV(match e with Left x1 -> e1 | Right x2 -> e2)
 = FV(e) + (FV(e1) - {x1}) + (FV(e2) - {x2})
FV(if e1 then e2 else e3) = FV(e1) + FV(e2) + FV(e3)
FV(let x = e1 in e2) = FV(e1) + (FV(e2) - {x})
```

Finally, we define substitution for the new syntactic forms in Core OCaml.
Expressions that do not bind variables are easy to handle:

```text
(e1,e2){v/x} = (e1{v/x}, e2{v/x})

(fst e){v/x} = fst (e{v/x})

(snd e){v/x} = snd (e{v/x})

(Left e){v/x} = Left (e{v/x})

(Right e){v/x} = Right (e{v/x})
```

Match expressions take a little more work, just like let expressions and
anonymous functions, to make sure we get capture-avoidance correct:

```text
(match e with Left x1 -> e1 | Right x2 -> e2){v/x}
 = match e{v/x} with Left x1 -> e1{v/x} | Right x2 -> e2{v/x}
     if ({x1,x2} intersect FV(v)) = {}

(match e with Left x -> e1 | Right x2 -> e2){v/x}
 = match e{v/x} with Left x -> e1 | Right x2 -> e2{v/x}
     if ({x2} intersect FV(v)) = {}

(match e with Left x1 -> e1 | Right x -> e2){v/x}
 = match e{v/x} with Left x1 -> e1{v/x} | Right x -> e2
      if ({x1} intersect FV(v)) = {}

(match e with Left x -> e1 | Right x -> e2){v/x}
 = match e{v/x} with Left x -> e1 | Right x -> e2
```

We wouldn't actually have to worry about capture-avoiding substitution in all
the above rules as long as we are content with call-by-value semantics. But if
we ever wanted call-by-name, we'd need all the extra conditions about free
variables that we gave above.

## Big-Step Relation

At this point there aren't any new concepts remaining to introduce.
We can just give the rules:
```
e1 e2 ==> v
  if e1 ==> fun x -> e
  and e2 ==> v2
  and e{v2/x} ==> v

fun x -> e ==> fun x -> e

i ==> i

b ==> b

e1 bop e2 ==> v
  if e1 ==> v1
  and e2 ==> v2
  and v is the result of primitive operation v1 bop v2

(e1, e2) ==> (v1, v2)
  if e1 ==> v1
  and e2 ==> v2

fst e ==> v1
  if e ==> (v1, v2)

snd e ==> v2
  if e ==> (v1, v2)

Left e ==> Left v
  if e ==> v

Right e ==> Right v
  if e ==> v

match e with Left x1 -> e1 | Right x2 -> e2 ==> v
  if e ==> Left v1
  and e1{v1/x1} ==> v

match e with Left x1 -> e1 | Right x2 -> e2 ==> v
  if e ==> Right v2
  and e2{v2/x2} ==> v

if e1 then e2 else e3 ==> v
  if e1 ==> true
  and e2 ==> v

if e1 then e2 else e3 ==> v
  if e1 ==> false
  and e3 ==> v

let x = e1 in e2 ==> v
  if e1 ==> v1
  and e2{v1/x} ==> v
```
