# Recursive Variants

Variant types may mention their own name inside their own body.
For example, here is a variant type that could be used to represent
something similar to `int list`:
```
type intlist = Nil | Cons of int * intlist

let lst3 = Cons (3, Nil)  (* similar to 3::[] or [3]*)
let lst123 = Cons(1, Cons(2, l3)) (* similar to [1;2;3] *)

let rec sum (l:intlist) : int=
  match l with
  | Nil -> 0
  | Cons(h,t) -> h + sum t

let rec length : intlist -> int = function
  | Nil -> 0
  | Cons (_,t) -> 1 + length t

let empty : intlist -> bool = function
  | Nil -> true
  | Cons _ -> false
```
Notice that in the definition of `intlist`, we define the `Cons`
constructor to carry a value that contains an `intlist`.  This makes
the type `intlist` be *recursive*: it is defined in terms of itself.

Record types may also be recursive, but plain old type synonyms may not be:
```
type node = {value:int; next:node}  (* OK *)
type t = t*t  (* Error: The type abbreviation t is cyclic *)
```

Types may be mutually recursive if you use the `and` keyword:
```
type node = {value:int; next:mylist}
and mylist = Nil | Node of node
```
But any such mutual recursion must involve at least one variant or record type
that the recursion "goes through".  For example:
```
type t = u and u = t  (* Error: The type abbreviation t is cyclic *)
type t = U of u and u = T of t  (* OK *)
```