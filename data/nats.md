# Natural Numbers

We can define a recursive variant that acts like numbers, demonstrating
that we don't really have to have numbers built into OCaml!  (For sake
of efficiency, though, it's a good thing they are.)

A *natural number* is either *zero* or the *successor* of some other
natural number. This is how you might define the natural numbers in a
mathematical logic course, and it leads naturally to the
following OCaml type `nat`:
```
type nat = Zero | Succ of nat
```
We have defined a new type `nat`, and `Zero` and `Succ` are
constructors for values of this type. This allows us to
build expressions that have an arbitrary number of nested `Succ`
constructors. Such values act like natural numbers:

```
let zero  = Zero
let one   = Succ zero
let two   = Succ one
let three = Succ two
let four  = Succ three
```

When we ask the compiler what `four` is, we get

```
# four;;
- : nat = Succ (Succ (Succ (Succ Zero)))
```

Now we can write functions to manipulate values of this type.
We'll write a lot of type annotations in the code below to help the reader
keep track of which values are `nat` versus `int`; the compiler, of course,
doesn't need our help.

```
let iszero (n : nat) : bool = 
  match n with
    | Zero   -> true
    | Succ m -> false

let pred (n : nat) : nat = 
  match n with
    | Zero   -> failwith "pred Zero is undefined"
    | Succ m -> m
```

Similarly we can define a function to add two numbers: 

```
let rec add (n1:nat) (n2:nat) : nat = 
  match n1 with
    | Zero -> n2
    | Succ n_minus_1 -> add n_minus_1 (Succ n2)
```

We can convert `nat` values to type `int` and vice-versa:
```
let rec int_of_nat (n:nat) : int = 
  match n with
    | Zero   -> 0
    | Succ m -> 1 + int_of_nat m
    
let rec nat_of_int(i:int) : nat =
  if i < 0 then failwith "nat_of_int is undefined on negative ints"
  else if i = 0 then Zero
  else Succ (nat_of_int (i-1))
```

To determine whether a natural number is even or odd, we can write a
pair of *mutually recursive* functions:

```
let rec 
  even (n:nat) : bool =
    match n with
      | Zero   -> true
      | Succ m -> odd m
and 
  odd (n:nat) : bool =
    match n with
      | Zero   -> false
      | Succ m -> even m
```

You have to use the keyword `and` to combine mutually recursive
functions like this. Otherwise the compiler would flag an error when you
refer to `odd` before it has been defined.