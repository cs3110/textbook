# Exercises

##### Exercise: list expressions [&#10029;] 

* Construct a list that has the integers 1 through 5 in it.  Use the square bracket 
  notation for lists.
  
* Construct the same list, but do not use the square bracket notation.  Instead use
  `::` and `[]`.

* Construct the same list again.  This time, the following expression must appear
  in your answer:  `[2;3;4]`.  Use the `@` operator, and do not use `::`.


TODO


# Exercises Part 1

### Exercise 1

Prove that `exp x (m + n) = exp x m * exp x n`, where
```
let rec exp x n =
  if n = 0 then 1
  else x * exp x (n - 1)
```
Proceed by induction on `m`.

### Exercise 2

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

### Exercise 3

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

## Solutions to Exercises

### Exercise 1

```
Claim: exp x (m + n) = exp x m * exp x n

Proof: by induction on m.
P(m) = exp x (m + n) = exp x m * exp x n

Base case: m = 0
Show: exp x (0 + n) = exp x 0 * exp x n

  exp x (0 + n)
=   { evaluation }
  exp x n

  exp x 0 * exp x n
=   { evaluation }
  1 * exp x n
=   { evaluation }
  exp x n

Inductive case: m = k + 1
Show: exp x ((k + 1) + n) = exp x (k + 1) * exp x n
IH: exp x (k + n) = exp x k * exp x n

  exp x ((k + 1) + n)
=   { evaluation }
  x * exp x (k + n)
=   { IH }
  x * exp x k * exp x n

  exp x (k + 1) * exp x n
=   { evaluation }
  x * exp x k * exp x n

QED
```

### Exercise 2

```

Claim: forall n >= 1, fib n = fibi n (0, 1)

We need to strengthen the hypothesis for the induction to go through. 

    Lemma: forall n >= 1, forall m >= 1, fib (n + m) = fibi n (fib m, fib (m + 1))
    Proof: by induction on n.

    Base case: n = 1
    Show: forall m >= 1, fib (1 + m) = fibi 1 (fib m, fib (m + 1))

        fibi 1 (fib m, fib (m + 1))
    =    { evaluation }
        fib (m + 1)
    =    { algebra }
        fib (1 + m)

    Inductive case: n = k + 1
    Show: forall m >= 1, fib ((k + 1) + m) = fibi (k + 1) (fib m, fib (m + 1))
    IH: forall m >= 1, fib (k + m) = fibi k (fib m, fib (m + 1))

                fib ((k + 1) + m)
            =      { algebra }
                fib (k + (m + 1))
            =      { IH with m := m + 1 }
                fibi k (fib (m + 1), fib (m + 2))
            =      { evaluation }
                fibi k (fib (m + 1), fib m + fib (m + 1))

                fibi (k + 1) (fib m, fib (m + 1))
            =      { evaluation }
                fibi k (fib (m + 1), fib m + fib (m + 1))

    QED

We cannot apply the lemma directly because (fib m) is not equal
to 0 for any m. We proceed by breaking `n` into two cases.

Case 1: n = 1.
Show: fib 1 = fibi 1 (0, 1)

    fib 1
=    { evaluation }
    1

    fibi 1 (0, 1)
=    { evaluation }
    1

Case 2: n = k + 1, k >= 1.
Show: fib (k + 1) = fibi (k + 1) (0, 1)

    fib (k + 1)
=    { Lemma with n := k, m := 1 } 
    fibi k (fib 1, fib 2)
=    { evaluation }
    fibi k (1, 1)

    fibi (k + 1) (0, 1)
=    { evaluation }
    fibi k (1, 1)

QED
```

### Exercise 3

```
Claim: forall n x, expsq x n  = exp x n

Proof: by induction on n.
P(n) = forall x, expsq x n  = exp x n

Base case 0:  n = 0
Show: forall x, expsq x 0  = exp x 0

  expsq x 0 
=   { evaluation }
  1
  
  exp x 0 
=   { evaluation }
  1

Base case 1:  n = 1
Show: forall x, expsq x 1  = exp x 1

  expsq x 1 
=   { evaluation }
  x

  exp x 1
=   { evaluation }
  x * exp x 0
=   { evaluation and algebra }
  x 

Inductive case for even n: n = 2k
Show: forall x, expsq x 2k  = exp x 2k
IH: forall x, forall j < 2k, expsq x j  = exp x j

  expsq x 2k
=   { evaluation }
  1 * expsq (x * x) (2k / 2)
=   { IH, instantiating its x as (x * x)
      and j as (2k / 2) }
  exp (x * x) k
=   { evaluation }
  (x * x) * exp (x * x) (k - 1)

  exp x 2k
=   { evaluation }
  x * exp x (2k - 1)
=   { evaluation }
  (x * x) exp x (2k - 2)
=   { IH, instantiating its x as x and j as (2k - 2) }
  (x * x) * expsq x (2k - 2)
=   { evaluation and algebra }
  (x * x) * expsq (x * x) (k - 1)
=   { IH, instantiating its x as (x * x) and j as (k - 1) }
  (x * x) * exp (x * x) (k - 1)

Inductive case for odd n: n = 2k + 1
Show: forall x, expsq x (2k + 1) = exp x (2k + 1)
IH: forall x, forall j < 2k, expsq x j  = exp x j

  expsq x (2k + 1)
=   { evaluation }
  x * expsq (x * x) ((2k + 1) / 2)
=   { by the properties of integer division }
  x * expsq (x * x) k

  exp x (2k + 1)
=   { evaluation }
  x * exp x 2k
=   { IH, instantiating its x as x, and j as 2k) }
  x * expsq x 2k
=   { evaluation and algebra }
  x * expsq (x * x) k

QED
```




# Exercises Part 2

### Exercise 1

Prove that `forall n, mult n Z = Z` by induction on `n`, where:
```
let rec mult a b =
  match a with
  | Z -> Z
  | S k -> plus b (mult k b)
```

### Exercise 2

Prove that `forall lst, lst @ [] = lst` by induction on `lst`.

### Exercise 3

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

### Exercise 4

Prove that reverse is an involution, i.e., that 
  `forall lst, rev (rev lst) = lst`.
Proceed by induction on `lst`. You will the previous exercise as a lemma.

### Exercise 5

Prove that `forall t, size (reflect t) = size t` by induction on `t`, where:
```
let rec size = function
  | Leaf -> 0
  | Node (l, v, r) -> 1 + size l + size r
```

### Exercise 6

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

## Solutions

### Exercise 1

```
Claim: forall n, mult n Z = Z
Proof: by induction on n
P(n) = mult n Z = Z

Base case: n = Z
Show: mult Z Z = Z

  mult Z Z
=   { eval mult }
  Z
  
Inductive case: n = S k
Show: mult (S k) Z = Z
IH: mult k Z = Z

  mult (S k) Z
=   { eval mult }
  plus Z (mult k Z)
=   { IH }
  plus Z Z
=   { eval plus }
  Z
  
QED
```

### Exercise 2

```
Claim:  forall lst, lst @ [] = lst
Proof: by induction on lst
P(lst) = lst @ [] = lst

Base case: lst = []
Show: [] @ [] = []

  [] @ []
=   { eval @ }
  []

Inductive case: lst = h :: t
Show: (h :: t) @ [] = h :: t
IH: t @ [] = t

  (h :: t) @ []
=   { eval @ }
  h :: (t @ [])
=   { IH }
  h :: t

QED
```

### Exercise 3

```
Claim: forall lst1 lst2, rev (lst1 @ lst2) = rev lst2 @ rev lst1
Proof: by induction on lst1
P(lst1) = forall lst2, rev (lst1 @ lst2) = rev lst2 @ rev lst1

Base case: lst1 = []
Show: forall lst2, rev ([] @ lst2) = rev lst2 @ rev []

  rev ([] @ lst2)
=   { eval @ }
  rev lst2

  rev lst2 @ rev []
=   { eval rev }
  rev lst2 @ []
=   { exercise 2 }
  rev lst2
  
Inductive case: lst1 = h :: t
Show: forall lst2, rev ((h :: t) @ lst2) = rev lst2 @ rev (h :: t)
IH: forall lst2, rev (t @ lst2) = rev lst2 @ rev t

  rev ((h :: t) @ lst2)
=   { eval @ }
  rev (h :: (t @ lst2))
=   { eval rev }
  rev (t @ lst2) @ [h]
=   { IH }
  (rev lst2 @ rev t) @ [h]
  
  rev lst2 @ rev (h :: t)
=   { eval rev }
  rev lst2 @ (rev t @ [h])
=   { associativity of @, proved in notes above }
  (rev lst2 @ rev t) @ [h]
  
QED
```

### Exercise 4

```
Claim: forall lst, rev (rev lst) = lst
Proof: by induction on lst
P(lst) = rev (rev lst) = lst

Base case: lst = []
Show: rev (rev []) = []

  rev (rev []) 
=   { eval rev, twice }
  []
  
Inductive case: lst = h :: t
Show: rev (rev (h :: t)) = h :: t
IH: rev (rev t) = t

  rev (rev (h :: t))
=   { eval rev }
  rev (rev t @ [h])
=   { exercise 3 }
  rev [h] @ rev (rev t)
=   { IH }
  rev [h] @ t
=   { eval rev }
  [h] @ t
=   { eval @ }
  h :: t
  
QED
```

## Exercise 5 

```
Claim: forall t, size (reflect t) = size t
Proof: by induction on t
P(t) = size (reflect t) = size t

Base case: t = Leaf
Show: size (reflect Leaf) = size Leaf

  size (reflect Leaf)
=   { eval reflect }
  size Leaf

Inductive case: t = Node (l, v, r)
Show: size (reflect (Node (l, v, r))) = size (Node (l, v, r))
IH1: size (reflect l) = size l
IH2: size (reflect r) = size r

  size (reflect (Node (l, v, r)))
=   { eval reflect }
  size (Node (reflect r, v, reflect l))
=   { eval size }
  1 + size (reflect r) + size (reflect l)
=   { IH1 and IH2 }
  1 + size r + size l

  size (Node (l, v, r))
=   { eval size }
  1 + size l + size r
=   { algebra }
  1 + size r + size l

QED
```

## Exercise 6

```
type prop = (* propositions *)
  | Atom of string
  | Neg of prop
  | Conj of prop * prop
  | Disj of prop * prop
  | Imp of prop * prop

Induction principle for prop:

forall properties P,
  if forall x, P(Atom x)
  and forall q, P(q) implies P(Neg q)
  and forall q r, (P(q) and P(r)) implies P(Conj (q,r))
  and forall q r, (P(q) and P(r)) implies P(Disj (q,r))
  and forall q r, (P(q) and P(r)) implies P(Imp (q,r))
  then forall q, P(q)
```




## Exercises Part 3

### Exercise 1

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

### Exercise 2

Design an OCaml interface for lists that has `nil`, `cons`, `append`,
and `length` operations.  Design the equational specification. Hint:
the equations will look strikingly like the OCaml implementations of
`@` and `List.length`.

## Solutions

### Exercise 1

Generators: `empty`, `insert`.  Manipulator: `remove`.  Queries: `is_empty`, 
`mult`.

Specification:
```
1.  is_empty empty = true
2.  is_empty (insert x b) = false
3.  mult x empty = 0
4a. mult y (insert x b) = 1 + mult y b              if x = y
4b. mult y (insert x b) = mult y b                  if x <> y
5.  remove x empty = empty
6a. remove y (insert x b) = b                       if x = y
6b. remove y (insert x b) = insert x (remove y b)   if x <> y
7.  insert x (insert y b) = insert y (insert x b)
```

### Exercise 2

Operations:
```
module type List = sig
  type 'a t
  val nil : 'a t
  val cons : 'a -> 'a t -> 'a t
  val append : 'a t -> 'a t -> 'a t
  val length : 'a t -> int
end
```

Equations:
```
1. append nil lst = lst
2. append (cons h t) lst = cons h (append t lst)
3. length nil = 0
4. length (cons h t) = 1 + length t
```


