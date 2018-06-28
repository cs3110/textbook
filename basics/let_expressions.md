# Let Expressions

In our use of the word `let` thus far, we've been making definitions
in the toplevel and in `.ml` files.  For example,
```
# let x = 42;;
val x : int = 42
```
defines `x` to be 42, after which we can use `x` in future definitions
at the toplevel.  We'll call this use of `let` a *let definition*.

There's another use of `let` which is as an expression:
```
# let x = 42 in x+1
- : int = 43
```
Here we're *binding* a value to the name `x` then using that binding
inside another expression, `x+1`.  We'll call this use of `let` a
*let expression*.  Since it's an expression it evaluates to a value.
That's different than definitions, which themselves do not evaluate
to any value.  You can see that if you try putting a let definition
in place of where an expression is expected:
```
# (let x = 42) + 1
Error: Syntax error: operator expected. 
```
Syntactically, a let definition is not permitted on the left-hand side
of the `+` operator, because a value is needed there, and definitions
do not evaluate to values.  On the other hand, a let expression
would work fine:
```
# (let x = 42 in x) + 1
- : int = 43
```

Another way to understand let definitions at the toplevel is that they 
are like let expression where we just haven't provided the body expression
yet.  Implicitly, that body expression is whatever else we type 
in the future.  For example,
```
# let a = "big";;
# let b = "red";;
# let c = a^b;;
# ...
```
is understand by OCaml in the same way as
```
let a = "big" in
let b = "red" in
let c = a^b in
...
```
That latter series of `let` bindings is idiomatically how several variables
can be bound inside a given block of code.

**Syntax.**

```
let x = e1 in e2
```

As usual `x` is an identifier.  We call `e1` the *binding expression*, because
it's what's being bound to `x`; and we call `e2` the *body expression*,
because that's the body of code in which the binding will be in scope.

**Dynamic semantics.**

To evaluate `let x = e1 in e2`:

* Evaluate `e1` to a value `v1`.

* Substitute `v1` for `x` in `e2`, yielding a new expression `e2'`.

* Evaluate `e2'` to a value `v2`.

* The result of evaluating the let expression is `v2`.

Here's an example:
```
    let x = 1+4 in x*3
-->   (evaluate e1 to a value v1)
    let x = 5 in x*3
-->   (substitute v1 for x in e2, yielding e2')
    5*3
-->   (evaluate e2' to v2)
    15
      (result of evaluation is v2)
```

If you compare these evaluation rules to the rules for function application,
you will notice they both involve substitution.  This is not an accident.
In fact, anywhere `let x = e1 in e2` appears in a program, we could replace
it with `(fun x -> e2) e1`.  They are syntactically different but semantically
equivalent.  So let expressions are really syntactic
sugar for anonymous function application. 

**Static semantics.**

* If `e1:t1` and if under the assumption that `x:t1` it holds that `e2:t2`,
  then `(let x = e1 in e2) : t2`.
  
We use the parentheses above just for clarity.  As usual, the compiler's 
type inferencer determines what the type of the variable is, or the programmer
could explicitly annotate it with this syntax:
```
let x : t = e1 in e2
```
