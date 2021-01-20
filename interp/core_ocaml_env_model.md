# Evaluating Core OCaml in the Environment Model

There isn't anything new in the (big step) environment model semantics
of Core OCaml, now that we know about closures, but for sake
of completeness let's state it anyway.

## Syntax

Recall the syntax of Core OCaml:
```
e ::= x | e1 e2 | fun x -> e
    | i | b | e1 + e2
    | (e1,e2) | fst e1 | snd e2
    | Left e | Right e
    | match e with Left x1 -> e1 | Right x2 -> e2
    | if e1 then e2 else e3
    | let x = e1 in e2
```

## Semantics

We've already seen the semantics of the lambda calculus
fragment of Core OCaml:
```
<env, x> ==> v
  if env(x) = v

<env, e1 e2> ==> v
  if  <env, e1> ==> (| fun x -> e, defenv |)
  and <env, e2> ==> v2
  and <defenv[x -> v2], e> ==> v

<env, fun x -> e> ==> (|fun x -> e, env|)
```

Evaluation of constants ignores the environment:
```
<env, i> ==> i

<env, b> ==> b
```

Evaluation of most other language features just uses
the environment without changing it:

```
<env, e1 + e2> ==> n
  if  <env,e1> ==> n1
  and <env,e2> ==> n2
  and n is the result of applying the primitive operation + to n1 and n2

<env, (e1, e2)> ==> (v1, v2)
  if  <env, e1> ==> v1
  and <env, e2> ==> v2

<env, fst e> ==> v1
  if <env, e> ==> (v1, v2)

<env, snd e> ==> v2
  if <env, e> ==> (v1, v2)

<env, Left e> ==> Left v
  if <env, e> ==> v

<env, Right e> ==> Right v
  if <env, e> ==> v

<env, if e1 then e2 else e3> ==> v2
  if <env, e1> ==> true
  and <env, e2> ==> v2

<env, if e1 then e2 else e3> ==> v3
  if <env, e1> ==> false
  and <env, e3> ==> v3
```

Finally, evaluation of binding constructs (i.e., match
and let expression) extends the environment with a new binding:

```
<env, match e with Left x1 -> e1 | Right x2 -> e2> ==> v1
  if  <env, e> ==> Left v
  and <env[x1 -> v], e1> ==> v1

<env, match e with Left x1 -> e1 | Right x2 -> e2> ==> v2
  if  <env, e> ==> Right v
  and <env[x2 -> v], e2> ==> v2
  
<env, let x = e1 in e2> ==> v2
  if  <env, e1> ==> v1
  and <env[x -> v1], e2> ==> v2
```
