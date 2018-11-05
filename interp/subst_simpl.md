# Substitution in SimPL

In the previous section, we posited a new notation `e'{e/x}`, meaning
"the expression `e'` with `e` substituted for `x`." The intuition is
that anywhere `x` appears in `e'`, we should replace `x` with `e`. 

## Defining Substitution

Let's give a careful definition of substitution for SimPL.  For the most
part, it's not too hard.  

**Constants** have no variables appearing in them (e.g., `x` cannot
syntactically occur in `42`), so substitution leaves them unchanged:
```
i{e/x} = i
b{e/x} = b
```

For **binary operators and if expressions**, all that substitution
needs to do is to recurse inside the subexpressions:
```
(e1 bop e2){e/x} = e1{e/x} bop e2{e/x}
(if e1 then e2 else e3){e/x} = if e1{e/x} then e2{e/x} else e3{e/x}
```

**Variables** start to get a little trickier.  There are two possibilities:
either we encounter the variable `x`, which means we should do the
substitution, or we encounter some other variable with a different
name, say `y`, in which case we should not do the substitution:
```
x{e/x} = e
y{e/x} = y
```

The first of those cases, `x{e/x} = e`, is important to note:
it's where the substitution operation finally takes place.  Suppose,
for example, we were trying to figure out the result of
`(x + 42){1/x}`.  Using the definitions from above,
```
  (x + 42){1/x}
= x{1/x} + 42{1/x}   by the bop case
= 1 + 42{1/x}        by the first variable case
= 1 + 42             by the integer case
```

Note that we are not defining the `-->` relation right now.  That is,
none of these equalities represents a step of evaluation.  To make
that concrete, suppose we were evaluating `let x = 1 in x + 42`:
```
    let x = 1 in x + 42
--> (x + 42){1/x}
  = 1 + 42
--> 43
```
There are two single steps here, one for the `let` and the other for
`+`.  But we consider the substitution to happen all at once, as part
of the step that `let` takes.  That's why we write 
`(x + 42){1/x} = 1 + 42`, not `(x + 42){1/x} --> 1 + 42`.

Finally, **let expression** also have two cases, depending on the name
of the bound variable:
```
(let x = e1 in e2){e/x}  =  let x = e1{e/x} in e2
(let y = e1 in e2){e/x}  =  let x = e1{e/x} in e2{e/x}
```

Both of those cases substitute `e` for `x` inside the binding
expression `e1`.  That's to ensure that expressions like
`let x = 42 in let y = x in y` would evaluate correctly:
`x` needs to be in scope inside the binding `y = x`, so we
have to do a substitution there regardless of the name being
bound.

But the first case does not do a substitution inside `e2`, whereas
the second case does.  That's so we *stop* substituting when
we reach a shadowed name.  Consider `let x = 5 in let x = 6 in x`.
We know it would evaluate to `6` in OCaml because of shadowing.
Here's how it would evaluate with our definitions of SimPL:
```
    let x = 5 in let x = 6 in x
--> (let x = 6 in x){5/x}
  = let x = 6{5/x} in x      ***
  = let x = 6 in x
--> x{6/x}
  = 6
```
On the line tagged `***` above, we've stopped substituting inside
the body expression, because we reached a shadowed variable name.
If we had instead kept going inside the body, we'd get a different
result:
```
    let x = 5 in let x = 6 in x
--> (let x = 6 in x){5/x}
  = let x = 6{5/x} in x{5/x}      ***WRONG***
  = let x = 6 in 5
--> 5{6/x}
  = 5
```

## Implementing Substitution

The definitions above are easy to turn into OCaml code.
Note that, although we write `v` below, the function is
actually able to substitute any expression for a variable,
not just a value.  The interpreter will only ever call
this function on a value, though.

```
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

## The SimPL Interpreter is Done

We've completed developing our SimPL interpreter!
[The finished interpreter can be downloaded here.](simpl.zip)
It includes some rudimentary test cases, as well as 
makefile targets that you will find helpful.
