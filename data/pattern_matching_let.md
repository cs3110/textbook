# Pattern Matching with Let

The syntax we've been using so far for let expressions
is, in fact, a special case of the full syntax that OCaml permits.
That syntax is:
```
let p = e1 in e2 
```
That is, the left-hand side of the binding may in fact be a pattern,
not just an identifier.  Of course, variable identifiers are on our
list of valid patterns, so that's why the syntax we've studied so
far is just a special case.

Given this syntax, we revisit the semantics of let expressions.

**Dynamic semantics.**

To evaluate `let p = e1 in e2`:

1. Evaluate `e1` to a value `v1`.

2. Match `v1` against pattern `p`.  If it doesn't match, raise
  the exception `Match_failure`.  Otherwise, if it does match,
  it produces a set $$b$$ of bindings.  

3. Substitute those bindings $$b$$ in `e2`, yielding a new expression `e2'`.

4. Evaluate `e2'` to a value `v2`.

5. The result of evaluating the let expression is `v2`.

**Static semantics.**

* If all the following hold:

  - `e1:t1` 
  - the pattern variables in `p` are `x1..xn`
  - `e2:t2` under the assumption that for all `i` in `1..n` it holds that
    `xi:ti`,
    
  then `(let p = e1 in e2) : t2`.
  
**Let definitions.**

As before, let definitions can be understood as let expression whose
body has not yet been given.  So their syntax can be generalized
to
```
let p = e
```
and their semantics follow from the semantics of let expressions, as before.
