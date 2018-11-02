# Example: SimPL

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
```

Obviously there's a lot missing from this language, especially functions.
But there's enough in it for us to study the important concepts
of interpreters without getting too distracted by lots of language
features.  Later, we will consider a larger fragment of OCaml.

## The AST

Since the AST is the most important data structure in an interpreter,
let's design it first:
```
type bop = 
  | Add
  | Mult
  | Leq

type expr =
  | Var of string
  | Int of int
  | Bool of bool  
  | Binop of bop * expr * expr
  | Let of string * expr * expr
  | If of expr * expr * expr
```
There is one constructor for each of the syntactic forms of expressions in the BNF.
For the underlying primitive syntactic classes of identifiers, integers, and booleans,
we're using OCaml's own `string`, `int`, and `bool` types.  

Instead of defining the `bop` type and a single `Binop` constructor,
we could have defined three separate constructors for the three binary operators: 
```
type expr =
  ...
  | Add of expr * expr
  | Mult of expr * expr 
  | Leq of expr * expr
  ...
```
But by factoring out the `bop` type we will be able to avoid a lot of code duplication
later in our implementation.
