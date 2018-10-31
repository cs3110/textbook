# SimPL

As a running example for the next few sections, we'll use a very
simple programming language that we call SimPL.  Here is its
syntax in BNF:

```
e ::= x | i | b | e1 bop e2                
    | if e1 then e2 else e3
    | let x = e1 in e2     

bop ::= + | * | <=

x ::= <identifiers>

i ::= <integers>
 
b ::= true | false      

v ::= i | b
```

Obviously there's a lot missing from this language, especially functions.
But there's enough in it for us to study the important concepts
of interpreters, without getting too distracted by lots of language
features.  Later, we will consider a larger fragment of OCaml.