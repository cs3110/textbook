# Parameterized Variants

Variant types may be *parameterized* on other types.  For example,
the `intlist` type above could be generalized to provide lists (coded
up ourselves) over any type:
```
type 'a mylist = Nil | Cons of 'a * 'a mylist

let lst3 = Cons (3, Nil)  (* similar to [3] *)
let lst_hi = Cons ("hi", Nil)  (* similar to ["hi"] *)
```
Here, `mylist` is a *type constructor* but not a type:  there is no
way to write a value of type `mylist`.  But we can write value of 
type `int mylist` (e.g., `lst3`) and `string mylist` (e.g., `lst_hi`).
Think of a type constructor as being like a function, but one that
maps types to types, rather than values to value.  

Here are some functions over `'a mylist`:
```
let rec length : 'a mylist -> int = function
  | Nil -> 0
  | Cons (_,t) -> 1 + length t

let empty : 'a mylist -> bool = function
  | Nil -> true
  | Cons _ -> false
```
Notice that the body of each function is unchanged from its previous
definition for `intlist`.  All that we changed was the type annotation.
And that could even be omitted safely:
```
let rec length = function
  | Nil -> 0
  | Cons (_,t) -> 1 + length t

let empty = function
  | Nil -> true
  | Cons _ -> false
```

The functions we just wrote are an example of a language feature
called **parametric polymorphism**.  The functions don't care what the `'a` 
is in `'a mylist`, hence they are perfectly happy to work
on `int mylist` or `string mylist` or any other `(whatever) mylist`.
The word "polymorphism" is based on the Greek roots "poly" (many) and
"morph" (form).  A value of type `'a mylist` could have many forms,
depending on the actual type `'a`.

As soon, though, as you place a constraint on what the type `'a` might be,
you give up some polymorphism.  For example,
```
# let rec sum = function
  | Nil -> 0
  | Cons(h,t) -> h + sum t;;
val sum : int mylist -> int 
```
The fact that we use the `(+)` operator with the head of the list
constrains that head element to be an `int`, hence all elements
must be `int`.   That means `sum` must take in an `int mylist`, not any other
kind of `'a mylist`.

It is also possible to have multiple type parameters for a parameterized
type, in which case parentheses are needed:

```
# type ('a,'b) pair = {first: 'a; second: 'b};;
# let x = {first=2; second="hello"};;
val x : (int, string) pair = {first = 2; second = "hello"} 
```	
