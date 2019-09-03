# Mutable Fields

The fields of a record can be declared as mutable, meaning their contents can be 
updated without constructing a new record.  For example, here is a record type
for two-dimensional colored points whose color field `c` is mutable:
```
# type point = {x:int; y:int; mutable c:string};;
type point = {x:int; y:int; mutable c:string; }
```
Note that `mutable` is a property of the field, rather than the type of the field.
In particular, we write `mutable field : type`, not `field : mutable type`.

The operator to update a mutable field is `<-`:
```
# let p = {x=0; y=0; c="red"};;
val p : point = {x=0; y=0; c="red"}

# p.c <- "white";;
- : unit = ()

# p;;
val p : point = {x=0; y=0; c="white"}

# p.x <- 3;;
Error: The record field x is not mutable
```

## Syntax and Semantics

The syntax and semantics of `<-` is similar to `:=` but complicated by fields:

* **Syntax:** `e1.f <- e2`

* **Dynamic semantics:**  To evaluate `e1.f <- e2`, evaluate `e2` to a value `v2`,
  and `e1` to a value `v1`, which must have a field named `f`.  Update `v1.f`
  to `v2`.  Return `()`.
  
* **Static semantics:** `e1.f <- e2 : unit` if `e1 : t1` and 
  `t1 = {...; mutable f : t2; ...}`, and `e2 : t2`.
  
## Refs and Mutable Fields

It turns out that refs are actually implemented as mutable fields.  In 
[`Stdlib`][stdlib] we find the following declaration:
```
type 'a ref = { mutable contents : 'a; }
```
And that's why when we create a ref it does in fact looks like a record: 
it *is* a record!
```
# let r = ref 3110;;
val r : int ref = {contents = 3110}
```

The other syntax we've seen for records is in fact equivalent to simple OCaml functions:
```
(* Equivalent to [fun v -> {contents=e}]. *)
val ref : 'a -> 'a ref

(* Equivalent to [fun r -> r.contents]. *)
val (!) : 'a ref -> 'a

(* Equivalent to [fun r v -> r.contents <- v]. *)
val (:=) : 'a ref -> 'a -> unit
```
The reason we say "equivalent" is that those functions are actually
implemented not in OCaml but in the OCaml run-time, which is implemented
mostly in C. But the functions do behave the same as the OCaml source
given above in comments.

[stdlib]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Stdlib.html