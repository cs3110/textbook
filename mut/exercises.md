# Exercises

## Mutable fields and refs

##### Exercise: mutable fields [&#10029;] 

Define an OCaml record type to represent student names and GPAs.  It
should be possible to mutate the value of a student's GPA.
Write an expression defining a student with name `"Alice"` and GPA
`3.7`. Then write an expression to mutate Alice's GPA to `4.0`.

&square;

##### Exercise: refs [&#10029;] 

Give OCaml expressions that have the following types.  Use utop to check
your answers.

* `bool ref`
* `int list ref`
* `int ref list`

&square;

##### Exercise: inc fun [&#10029;] 

Define a reference to a function as follows:
```
# let inc = ref (fun x -> x+1);;
```
Write code that uses `inc` to produce the value `3110`.

&square;

##### Exercise: addition assignment [&#10029;&#10029;] 

The C language and many languages derived from it, such as Java, has an 
*addition assignment* operator written `a += b` and meaning
`a = a + b`.  Implement such an operator in OCaml; its type should be
`int ref -> int -> unit`.  Here's some code to get you started:
```
let (+:=) x y = ...
```
And here's an example usage:
```
# let x = ref 0;;
# x +:= 3110;;
# !x
- : int = 3110
```

&square;

##### Exercise: physical equality [&#10029;&#10029;] 
Define `x`, `y`, and `z` as follows:
```
let x = ref 0
let y = x
let z = ref 0
```

Predict the value of the following series of expressions:
```
# x == y;;
# x == z;;
# x = y;;
# x = z;;
# x := 1;
# x = y;;
# x = z;;
```

Check your answers in utop.

&square;

## Arrays

For the next couple exercises, let's use the following type:

```
(* AF: the float array [| x1; ...; xn |] represents the 
 *     vector (x1, ..., xn) 
 * RI: the array is non-empty *)
type vector = float array
```

##### Exercise: norm [&#10029;&#10029;] 

The [Euclidean norm][norm] of an \\(n\\)-dimensional vector 
\\(x = (x_1, \ldots, x_n)\\) is written \\(|x|\\) and is defined to be

$$\sqrt{x_1^2 + \cdots + x_n^2}.$$

[norm]: https://en.wikipedia.org/wiki/Norm_(mathematics)#Euclidean_norm

Write a function `norm : vector -> float` that computes the
Euclidean norm of a vector.  Your function should not mutate
the input array. *Hint: although your first instinct is
likely to reach for a loop, instead try to use `Array.map` 
and `Array.fold_left` or `Array.fold_right`.*

&square;

Every vector can be *normalized* by dividing each component by
\\(|x|\\); this yields a vector with norm 1:

\\[\left(\frac{x_1}{|x|}, \ldots, \frac{x_n}{|x|}\right)\\]

##### Exercise: normalize [&#10029;&#10029;] 

Write a function `normalize : vector -> unit` that normalizes a vector "in place"
by mutating the input array.  Here's a sample usage:
```
# let a = [|1.; 1.|];;
val a : float array = [|1.; 1.|]
# normalize a;;
- : unit = ()
# a;;
- : float array = [|0.7071...; 0.7071...|]
```
*Hint:  `Array.iteri`.*

&square;

##### Exercise: normalize loop [&#10029;&#10029;] 

Modify your implementation of `normalize` to use one of the looping expressions.

&square;

##### Exercise: norm loop [&#10029;&#10029;] 

Modify your implementation of `norm` to use one of the looping expressions.
Here is pseudocode for what you should do:
```
initialize norm to 0.0
loop through array
  add to norm the square of the current array component
return sqrt of norm
```

&square;

##### Exercise: init matrix [&#10029;&#10029;&#10029;] 

The array module contains two functions for creating an array: `make`
and `init`.  `make` creates an array and fills it with a default value,
while `init` creates an array and uses a provided function to fill it
in.  The library also contains a function `make_matrix` for creating a
two-dimensional array, but it does not contain an analogous
`init_matrix` to create a matrix using a function for initialization.
Write a function `init_matrix : int -> int -> (int -> int -> 'a) -> 'a
array array` such that `init_matrix n o f` creates and returns an `n` by
`o` matrix `m` with `m.(i).(j) = f i j` for all `i` and `j` in bounds. 
See the documentation for `make_matrix` for more information on the
representation of matrices as arrays.

&square;

## Challenge: Doubly-linked lists

##### Exercise: doubly linked list [&#10029;&#10029;&#10029;&#10029;] 

[Here is an OCaml file](dll.ml) with types and functions for 
mutable [*doubly-linked lists*][dll].
Complete the implementations in that file.  Test your code.

[dll]: https://en.wikipedia.org/wiki/Doubly_linked_list
  
*Hint: draw pictures!  Reasoning about mutable data structures is typically
easier if you draw a picture.*

&square;
