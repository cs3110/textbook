# Exercises

{{ solutions }}

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "mutable fields")}}

Define an OCaml record type to represent student names and GPAs. It should be
possible to mutate the value of a student's GPA. Write an expression defining a
student with name `"Alice"` and GPA `3.7`. Then write an expression to mutate
Alice's GPA to `4.0`.

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "refs")}}

Give OCaml expressions that have the following types.  Use utop to check
your answers.

* `bool ref`
* `int list ref`
* `int ref list`

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "inc fun")}}

Define a reference to a function as follows:

```ocaml
let inc = ref (fun x -> x + 1)
```

Write code that uses `inc` to produce the value `3110`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "addition assignment")}}

The C language and many languages derived from it, such as Java, has an
*addition assignment* operator written `a += b` and meaning `a = a + b`.
Implement such an operator in OCaml; its type should be
`int ref -> int -> unit`. Here's some code to get you started:

```ocaml
let ( +:= ) x y = ...
```

And here's an example usage:

```ocaml
# let x = ref 0;;
# x +:= 3110;;
# !x;;
- : int = 3110
```

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "physical equality")}}

Define `x`, `y`, and `z` as follows:
```ocaml
let x = ref 0
let y = x
let z = ref 0
```

Predict the value of the following series of expressions:
```ocaml
# x == y;;
# x == z;;
# x = y;;
# x = z;;
# x := 1;;
# x = y;;
# x = z;;
```

Check your answers in utop.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "norm")}}

The [Euclidean norm][norm] of an $n$-dimensional vector
$x = (x_1, \ldots, x_n)$ is written $|x|$ and is defined to be

$$\sqrt{x_1^2 + \cdots + x_n^2}.$$

[norm]: https://en.wikipedia.org/wiki/Norm_(mathematics)#Euclidean_norm

Write a function `norm : vector -> float` that computes the
Euclidean norm of a vector, where `vector` is defined as follows:

```
(* AF: the float array [| x1; ...; xn |] represents the
 *     vector (x1, ..., xn)
 * RI: the array is non-empty *)
type vector = float array
```

Your function should not mutate the input array. *Hint: although your first
instinct might be to reach for a loop, instead try to use `Array.map` and
`Array.fold_left` or `Array.fold_right`.*

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "normalize")}}

Every vector can be *normalized* by dividing each component by
$|x|$; this yields a vector with norm 1:

$$
\left(\frac{x_1}{|x|}, \ldots, \frac{x_n}{|x|}\right)
$$

Write a function `normalize : vector -> unit` that normalizes a vector "in
place" by mutating the input array. Here's a sample usage:

```ocaml
# let a = [|1.; 1.|];;
val a : float array = [|1.; 1.|]

# normalize a;;
- : unit = ()

# a;;
- : float array = [|0.7071...; 0.7071...|]
```

*Hint:  `Array.iteri`.*

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "norm loop")}}

Modify your implementation of `norm` to use a loop. Here is pseudocode for what
you should do:

```text
initialize norm to 0.0
loop through array
  add to norm the square of the current array component
return sqrt of norm
```

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "normalize loop")}}

Modify your implementation of `normalize` to use a loop.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "init matrix")}}

The `Array` module contains two functions for creating an array: `make` and
`init`. `make` creates an array and fills it with a default value, while `init`
creates an array and uses a provided function to fill it in. The library also
contains a function `make_matrix` for creating a two-dimensional array, but it
does not contain an analogous `init_matrix` to create a matrix using a function
for initialization.

Write a function `init_matrix : int -> int -> (int -> int -> 'a) -> 'a array
array` such that `init_matrix n o f` creates and returns an `n` by `o` matrix
`m` with `m.(i).(j) = f i j` for all `i` and `j` in bounds.

See the documentation for [`make_matrix`](https://v2.ocaml.org/api/Array.html#VALmake_matrix) for more information on the
representation of matrices as arrays.

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "doubly linked list")}}

Implement a data abstraction for a mutable doubly-linked list. Here is a
representation type to get you started:

```ocaml
(** An ['a node] is a node of a mutable doubly-linked list.
    It contains a value of type ['a] and optionally has
    pointers to previous and/or next nodes. *)
type 'a node = {
  mutable prev : 'a node option;
  mutable next : 'a node option;
  value : 'a
}

(** An ['a dlist] is a mutable doubly-linked list with elements
    of type ['a].  It is possible to access the first and
    last elements in constant time.
    RI: The list does not contain any cycles. *)
type 'a dlist = {
  mutable first : 'a node option;
  mutable last : 'a node option;
}
```

Implement at least these operations:

- create an empty list
- insert a new first value
- insert a new last value
- insert a new node after a given node
- insert a new node before a given node
- remove a node
- iterate forward through the list applying a function
- iterate backward through the list applying a function

*Hint: draw pictures! Reasoning about mutable data structures is typically
easier if you draw a picture.*
