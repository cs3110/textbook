# Exercises

##### Exercise: exp [&#10029;&#10029;] 

Prove that `exp x (m + n) = exp x m * exp x n`, where
```
let rec exp x n =
  if n = 0 then 1
  else x * exp x (n - 1)
```
Proceed by induction on `m`.

##### Exercise: fibi [&#10029;&#10029;&#10029;] 

Prove that `forall n >= 1, fib n = fibi n (0, 1)`, where
```
let rec fib n =
  if n = 1 then 1
  else if n = 2 then 1
  else fib (n - 2) + fib (n - 1)

let rec fibi n (prev, curr) =
  if n = 1 then curr
  else fibi (n - 1) (curr, prev + curr)
```
Proceed by induction on `n`, rather than trying to apply the theorem
about converting recursion into iteration.

##### Exercise: expsq [&#10029;&#10029;&#10029;] 

Prove that `expsq x n = exp x n`, where
```
let rec expsq x n =
  if n = 0 then 1
  else if n = 1 then x
  else (if n mod 2 = 0 then 1 else x) * expsq (x * x) (n / 2)
```
Proceed by *strong induction* on `n`.  Function `expsq` implements
*exponentiation by repeated squaring*, which results in more efficient
computation than `exp`.

##### Exercise: mult [&#10029;&#10029;] 

Prove that `forall n, mult n Z = Z` by induction on `n`, where:
```
let rec mult a b =
  match a with
  | Z -> Z
  | S k -> plus b (mult k b)
```

##### Exercise: append nil [&#10029;&#10029;] 

Prove that `forall lst, lst @ [] = lst` by induction on `lst`.

##### Exercise: rev dist append [&#10029;&#10029;&#10029;] 

Prove that reverse distributes over append, i.e., that
`forall lst1 lst2, rev (lst1 @ lst2) = rev lst2 @ rev lst1`, where:
```
let rec rev = function
  | [] -> []
  | h :: t -> rev t @ [h]
```
(That is, of course, an inefficient implemention of `rev`.) You will need
to choose which list to induct over.  You will need the previous exercise
as a lemma, as well as the associativity of `append`, which was proved in the
notes above.

##### Exercise: rev involutive [&#10029;&#10029;&#10029;] 

Prove that reverse is an involution, i.e., that 
  `forall lst, rev (rev lst) = lst`.
Proceed by induction on `lst`. You will need the previous exercise as a lemma.

##### Exercise: reflect size [&#10029;&#10029;&#10029;] 

Prove that `forall t, size (reflect t) = size t` by induction on `t`, where:
```
let rec size = function
  | Leaf -> 0
  | Node (l, v, r) -> 1 + size l + size r
```

##### Exercise: propositions [&#10029;&#10029;&#10029;&#10029;] 

In propositional logic, we have propositions, negation, conjunction,
disjunction, and implication.  The following BNF describes propositional
logic formulas:
```
p ::= atom
    | ~ p      (* negation *)
    | p /\ p   (* conjunction *)
    | p \/ p   (* disjunction *)
    | p -> p   (* implication *)

atom ::= <identifiers>
```
For example, `raining /\ snowing /\ cold` is a proposition stating that it is
simultaneously raining and snowing and cold (a weather condition known 
as *Ithacating*).

Define an OCaml type to represent the AST of propositions.  Then state
the induction principle for that type.

##### Exercise: list spec [&#10029;&#10029;&#10029;] 

Design an OCaml interface for lists that has `nil`, `cons`, `append`,
and `length` operations.  Design the equational specification. Hint:
the equations will look strikingly like the OCaml implementations of
`@` and `List.length`.

##### Exercise: bag spec [&#10029;&#10029;&#10029;&#10029;] 

A *bag* or *multiset* is like a blend of a list and a set:  like a set, order
does not matter; like a list, elements may occur more than once.  The number of
times an element occurs is its *multiplicity*.  An element that does not occur
in the bag has multiplicity 0. Here is an OCaml signature for bags:
```
module type Bag = sig
  type 'a t
  val empty : 'a t
  val is_empty : 'a t -> bool
  val insert : 'a -> 'a t -> 'a t
  val mult : 'a -> 'a t -> int
  val remove : 'a -> 'a t -> 'a t
end
```

Categorize the operations in the `Bag` interface as generators, manipulators,
or queries.  Then design an equational specification for bags.  For the `remove`
operation, your specification should cause at most one occurrence of an element
to be removed.  That is, the multiplicity of that value should decrease
by at most one.


