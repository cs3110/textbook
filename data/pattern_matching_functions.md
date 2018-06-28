# Pattern Matching with Functions

The syntax we've been using so far for functions is also 
a special case of the full syntax that OCaml permits.
That syntax is:
```
let f p1 ... pn = e1 in e2   (* function as part of let expression *)
let f p1 ... pn = e          (* function definition at toplevel *)
fun p1 ... pn -> e           (* anonymous function *)
```

The truly primitive syntactic form we need to care about is
`fun p -> e`.  Let's revisit the semantics of anonymous functions
and their application with that form; the changes to the other forms
follow from those below:

**Static semantics.**

* Let `x1..xn` be the pattern variables appearing in `p`. If by assuming that 
  `x1:t1` and `x2:t2` and ... and `xn:tn`, we can conclude that `p:t` and `e:u`, 
  then `fun p -> e : t -> u`.

* The type checking rule for application is unchanged.
  
**Dynamic semantics.**

* The evaluation rule for anonymous functions is unchanged.

* To evaluate `e0 e1`:

  1. Evaluate `e0` to an anonymous function `fun p -> e`, and
     evaluate `e1` to value `v1`.

  3. Match `v1` against pattern `p`.  If it doesn't match, raise
	the exception `Match_failure`.  Otherwise, if it does match,
	it produces a set \\(b\\) of bindings.  

  4. Substitute those bindings \\(b\\) in `e`, yielding a new expression `e'`.
   
  5. Evaluate `e'` to a value `v`, which is the result of evaluating `e0 e1`.