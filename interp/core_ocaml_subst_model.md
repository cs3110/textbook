# Evaluating Core OCaml in the Substitution Model

Let's define the small and big step relations for Core OCaml.
To be honest, there won't be much that's surprising at this
point; we've seen just about everything already in SimPL
and in the lambda calculus.

## Small-Step Relation

Here is the fragment of Core OCaml we already know from SimPL:
```
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

Here's the fragment of Core OCaml that corresponds to the
lambda calculus:

```
e1 e2 --> e1' e2
	if e1 --> e1'

v1 e2 --> v1 e2'
	if e2 --> e2'

(fun x -> e) v2 --> e{v2/x}
```

And here are the new parts of Core OCaml.  First, **pairs**
evaluate their first component, then their second component:
```
(e1, e2) --> (e1', e2)
	if e1 --> e1'
	
(v1, e2) --> (v1, e2')
	if e2 --> e2'
	
fst (v1,v2) --> v1

snd (v1,v2) --> v2
```

**Constructors** evaluate the expression they carry:

```
Left e --> Left e'
	if e --> e'
	
Right e --> Right e'
	if e --> e'
```

**Pattern matching** evaluates the expression being matched,
then reduces to one of the branches:
```
match e with Left x1 -> e1 | Right x2 -> e2 
--> match e' with Left x1 -> e1 | Right x2 -> e2
	if e --> e'
	
match Left v with Left x1 -> e1 | Right x2 -> e2
--> e1{v/x1}	

match Right v with Left x1 -> e1 | Right x2 -> e2
--> e2{v/x2}	
```

## Substitution

We also need to define the substitution operation for Core OCaml.
Here is what we already know from SimPL and the lambda calculus:

```
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

Note that we've now added the requirement of capture-avoiding
substitution to the definitions for `let` and `fun`:  they
both require `y` not to be in the free variables of `v`.
We therefore need to define the free variables of an expression:

```
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

Finally, we define substitution for the new syntactic forms
in Core OCaml.  Expressions that do not bind variables are
easy to handle:
```
(e1,e2){v/x} = (e1{v/x}, e2{v/x})

(fst e){v/x} = fst (e{v/x})

(snd e){v/x} = snd (e{v/x})

(Left e){v/x} = Left (e{v/x})

(Right e){v/x} = Right (e{v/x})
```

Match expressions take a little more work, just like let expressions
and anonymous functions, to make sure we get capture-avoidance
correct:
```
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

We wouldn't actually have to worry about capture-avoiding
substitution in all the above rules as long as we are content
with call-by-value semantics.  But if we ever wanted call-by-name,
we'd need all the extra conditions about free variables that we 
gave above.

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
