# Pattern Matching with Lists

We saw above how to access lists using pattern matching.  Let's 
look more carefully at this feature.

## Syntax and Semantics

**Syntax.**
```
match e with
| p1 -> e1
| p2 -> e2
| ...
| pn -> en
```

Each of the clauses `pi -> ei` is called a *branch* or a *case* of
the pattern match.  The first vertical bar in the entire pattern match 
is optional.

The `p`'s here are a new syntactic form called a *pattern*.  For now,
a pattern may be:

* a variable name, e.g. `x`
* the underscore character `_`, which is called the *wildcard*
* the empty list `[]`
* `p1::p2`
* `[p1; ...; pn]`

No variable name may appear more than once in a pattern.  For example,
the pattern `x::x` is illegal.  The wildcard may occur any number of times.

As we learn more of data structures available in OCaml, we'll expand
the possibilities for what a pattern may be.

**Dynamic semantics.**

In lecture we gave an abbreviated version of the dynamic semantics.
Here we give the full details.

Pattern matching involves two inter-related tasks:  determining whether
a pattern matches a value, and determining what parts of the value
should be associated with which variable names in the pattern. The
former task is intuitively about determining whether a pattern and a
value have the same *shape*.  The latter task is about determining the
*variable bindings* introduced by the pattern.  For example, in
```
match 1::[] with
| [] -> false
| h::t -> (h>=1) && (length t = 0)
```
(which evaluates to `true`)
when evaluating the right-hand side of the second branch, `h=1` and `t=[]`.
Let's write `h->1` to mean the variable binding saying that `h` has value `1`;
this is not a piece of OCaml syntax, but rather a notation we use to
reason about the language.  So the variable bindings produced 
by the second branch would be `h->1,t->[]`.

More carefully, here is a definition of when a pattern matches a value
and the bindings that match produces:

* The pattern `x` matches any value `v` and produces the variable 
  binding `x->v`.
  
* The pattern `_` matches any value and produces no bindings.

* The pattern `[]` matches the value `[]` and produces no bindings.

* If `p1` matches `v1` and produces a set $$b_1$$ of bindings,
  and if `p2` matches `v2` and produces a set $$b_2$$ of bindings,
  then `p1::p2` matches `v1::v2` and produces the set $$b_1 \cup b_2$$
  of bindings. Note that `v2` must be a list (since it's on the
  right-hand side of `::`) and could have any length:  0 elements, 1
  element, or many elements. Note that the union $$b_1 \cup b_2$$ of
  bindings will never have a problem where the same variable is bound
  separately in both $$b_1$$ and $$b_2$$ because of the syntactic
  restriction that no variable name may appear more than once in a
  pattern.

* If for all `i` in `1..n`, it holds that `pi` matches `vi` and produces 
  the set $$b_i$$ of bindings, then `[p1; ...; pn]` matches `[v1; ...;
  vn]` and produces the set $$\bigcup_i b_i$$ of bindings. Note that
  this pattern specifies the exact length the list must be.

Now we can say how to evaluate `match e with p1 -> e1 | ... | pn -> en`:

* Evaluate `e` to a value `v`.

* Match `v` against `p1`, then against `p2`, and so on, in the order they
  appear in the match expression.

* If `v` does not match against any of the patterns, then evaluation of
  the match expression raises a `Match_failure` exception.
  We haven't yet discussed exceptions in OCaml, but you're familiar with
  them from CS 1110 (Python) and CS 2110 (Java).  We'll come back to exceptions
  after we've covered some of the other built-in data structures in OCaml.

* Otherwise, stop trying to match at the first time a match succeeds
  against a pattern.  Let `pi` be that pattern and let $$b$$ be the
  variable bindings produced by matching `v` against `pi`.
  
* Substitute those bindings inside `ei`, producing a new expression `e'`.
  
* Evaluate `e'` to a value `v'`.  

* The result of the entire match expression is `v'`.
  
For example, here's how this match expression would be evaluated:
```
match 1::[] with
| [] -> false
| h::t -> (h=1) && (t=[])
```

* `1::[]` is already a value

* `[]` does not match ``1::[]``

* `h::t` does match `1::[]` and produces variable bindings 
   {`h->1`,`t->[]`}, because:
  
  - `h` matches `1` and produces the variable binding `h->1`
  
  - `t` matches `[]` and produces the variable binding `t->[]`
  
* substituting {`h->1`,`t->[]`} inside `(h=1) && (t=[])`
  produces a new expression `(1=1) && ([]=[])`
  
* evaluating `(1=1) && ([]=[])` yields the value `true` 
  (we omit the justification for that fact here, but it follows from
  other evaluation rules for built-in operators and function application)

* so the result of the entire match expression is `true`.
 
**Static semantics.**

* If `e:ta` and for all `i`, it holds that `pi:ta` and `ei:tb`,
  then `(match e with p1 -> e1 | ... | pn -> en) : tb`.

That rule relies on being able to judge whether a pattern has a
particular type.  As usual, type inference comes into play here. The
OCaml compiler infers the types of any pattern variables as well as all
occurrences of the wildcard pattern.  As for the list patterns, they
have the same type-checking rules as list expressions.

## Additional Static Checking

In addition to that type-checking rule, there are two other checks
the compiler does for each match expression:

* **Exhaustiveness:**  the compiler checks to make sure that there are
  enough patterns to guarantee that at least one of them matches
  the expression `e`, no matter what the value of that expression
  is at run time.  This ensures that the programmer did not forget
  any branches.  For example, the function below will cause
  the compiler to emit a warning:
  
  ```
  # let head lst = match lst with h::_ -> h;;
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a value that is not matched:                              
  []
  ```
 
  By presenting that warning to the programmer, the compiler is helping
  the programmer to defend against the possibility of `Match_failure` 
  exceptions at runtime.
  
* **Unused branches:** the compiler checks to see whether any of the branches
  could never be matched against because one of the previous branches
  is guaranteed to succeed. 
  For example, the function below will cause the compiler to emit a warning:

  ```
  # let rec sum lst = 
      match lst with 
      | h::t -> h + sum t 
      | [h] -> h 
      | [] -> 0;;
  Warning 11: this match case is unused.    
  ```
  
  The second branch is unused because the first branch will match anything
  the second branch matches.
  
  Unused match cases are usually a sign that the programmer wrote something
  other than what they intended.  So by presenting that warning, the compiler 
  is helping the programmer to detect latent bugs in their code.
  
  Here's an example of one of the most common bugs that causes an unused match
  case warning.  Understanding it is also a good way to check your understanding
  of the dynamic semantics of match expressions:

  ```
  let length_is lst n =
	match length lst with
	| n -> true
	| _ -> false
  ```

  The programmer was thinking that if the length of `lst` is equal to `n`,
  then this function will return `true`, and otherwise will return `false`.
  But in fact this function *always* returns `true`.  Why?  Because the
  pattern variable `n` is distinct from the function argument `n`.  
  Suppose that the length of `lst` is 5.  Then the pattern match becomes:
  `match 5 with n -> true | _ -> false`.  Does `n` match 5?  Yes, according
  to the rules above:  a variable pattern matches any value and here produces
  the binding `n->5`.  Then evaluation applies that binding to `true`, 
  substituting all occurrences of `n` inside of `true` with 5.  Well,
  there are no such occurrences.  So we're done, and the result of 
  evaluation is just `true`.

  What the programmer really meant to write was:

  ```
  let length_is lst n =
	match length lst with
	| m -> if m=n then true else false
	| _ -> false
  ``` 

  or better yet:

  ```
  let length_is lst n =
	match length lst with
	| m -> m=n
	| _ -> false
  ``` 

  or even better yet:

  ```
  let length_is lst n =
	length lst = n
  ``` 
  
## Deep Pattern Matching

Patterns can be nested.  Doing so can allow your code to look deeply into the 
structure of a list.  For example:
 
* `_::[]` matches all lists with exactly one element

* `_::_` matches all lists with at least one element

* `_::_::[]` matches all lists with exactly two elements

* `_::_::_::_` matches all lists with at least three elements



 
