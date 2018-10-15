# Arrays and Loops

Arrays are fixed-length mutable sequences with constant-time access and 
update.  So they are similar in various ways to refs, lists, and tuples. 
Like refs, they are mutable.  Like lists, they are (finite) sequences.
Like tuples, their length is fixed in advance and cannot be resized.

The syntax for arrays is similar to lists:
```
# let v = [|0.; 1.|];;
val v : float array = [|0.; 1.|]
```
That code creates an array whose length is fixed to be 2 and whose
contents are initialized to `0.` and `1.`.  The keyword `array`
is a type constructor, much like `list`.

Later those contents can be changed using the `<-` operator:
```
# v.(0) <- 5.;;
- : unit = ()

# v;;
- : float array = [|5.; 1.|]
```
As you can see in that example, indexing into an array uses the
syntax `array.(index)`, where the parentheses are mandatory.

The [`Array` module][array] has many useful functions on arrays.

[array]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Array.html

## Syntax and Semantics

**Syntax.**

* Array creation: `[|e0; e1; ...; en|]` 

* Array indexing: `e1.(e2)` 

* Array assignment: `e1.(e2) <- e3` 

**Dynamic semantics.**

* To evaluate `[|e0; e1; ...; en|]`, evaluate each `ei` to a value `vi`,
  create a new array of length `n+1`, and store each value in the array
  at its index.
  
* To evaluate `e1.(e2)`, evaluate `e1` to an array value `v1`, and
  `e2` to an integer `v2`.  If `v2` is not within the bounds of the
  array (i.e., `0` to `n-1`, where `n` is the length of the array), 
  raise `Invalid_argument`.  Otherwise, index into `v1` to 
  get the value `v` at index `v2`, and return `v`.
  
* To evaluate `e1.(e2) <- e3`, evaluate each expression `ei` to a value `vi`.
  Check that `v2` is within bounds, as in the semantics of indexing.
  Mutate the element of `v1` at index `v2` to be `v3`.
  
**Static semantics.**

* `[|e0; e1; ...; en|] : t array` if `ei : t` for all the `ei`.

* `e1.(e2) : t` if `e1 : t array` and `e2 : int`.

* `e1.(e2) <- e3 : unit` if `e1 : t array` and `e2 : int` and `e3 : t`.	

## Loops

OCaml has while loops and for loops.  Their
syntax is as follows:
```
while e1 do e2 done
for x=e1 to e2 do e3 done
for x=e1 downto e2 do e3 done
```
Each of these three expressions evaluates the expression between `do`
and `done` for each iteration of the loop; `while` loops terminate when
`e1` becomes false; `for` loops execute once for each integer from `e1`
to `e2`; `for..to` loops evaluate starting at `e1` and incrementing `x`
each iteration; `for..downto` loops evaluate starting at `e1` and
decrementing `x` each iteration.  All three expressions evaluate to `()`
after the termination of the loop. Because they always evaluate to `()`,
they are less general than folds, maps, or recursive functions. 

Loops are themselves not inherently mutable, but they are most often
used in conjunction with mutable features like arrays&mdash;typically, 
`e` causes side effects. We can also use functions like
`Array.iter`, `Array.map`, and `Array.fold_left` instead of loops.

The ["Expressions" page][expr] of
OCaml manual contains the syntax and semantics of loops.

[expr]: http://caml.inria.fr/pub/docs/manual-ocaml/expr.html


