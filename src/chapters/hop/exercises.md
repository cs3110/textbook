# Exercises

{{ solutions }}

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "twice, no arguments")}}

Consider the following definitions:
```ocaml
let double x = 2 * x
let square x = x * x
let twice f x = f (f x)
let quad = twice double
let fourth = twice square
```
Use the toplevel to determine what the types of `quad` and `fourth` are. Explain
how it can be that `quad` is not syntactically written as a function that takes
an argument, and yet its type shows that it is in fact a function.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "mystery operator 1")}}

What does the following operator do?
```ocaml
let ( $ ) f x = f x
```

*Hint: investigate `square $ 2 + 2` vs. `square 2 + 2`.*

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "mystery operator 2")}}

What does the following operator do?
```ocaml
let ( @@ ) f g x = x |> g |> f
```

*Hint: investigate `String.length @@ string_of_int` applied to `1`, `10`, `100`,
etc.*

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "repeat")}}

Generalize `twice` to a function `repeat`, such that `repeat f n x` applies `f`
to `x` a total of `n` times. That is,

* `repeat f 0 x` yields `x`
* `repeat f 1 x` yields `f x`
* `repeat f 2 x` yields `f (f x)` (which is the same as `twice f x`)
* `repeat f 3 x` yields `f (f (f x))`
* ...

<!--------------------------------------------------------------------------->
{{ ex1 | replace("%%NAME%%", "product")}}

Use `fold_left` to write a function `product_left` that computes the product of
a list of floats. The product of the empty list is `1.0`. *Hint: recall how we
implemented `sum` in just one line of code in lecture.*

Use `fold_right` to write a function `product_right` that computes the product
of a list of floats. *Same hint applies.*

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "terse product")}}

How terse can you make your solutions to the **product** exercise? *Hints: you
need only one line of code for each, and you do not need the `fun` keyword. For
`fold_left`, your function definition does not even need to explicitly take a
list argument. If you use `ListLabels`, the same is true for `fold_right`.*

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "sum_cube_odd")}}

Write a function `sum_cube_odd n` that computes the sum of the cubes of all the
odd numbers between `0` and `n` inclusive. Do not write any new recursive
functions. Instead, use the functionals map, fold, and filter, and the `( -- )`
operator (defined in the discussion of pipelining).

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "sum_cube_odd pipeline")}}

Rewrite the function `sum_cube_odd` to use the pipeline operator `|>`.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "exists")}}

Consider writing a function `exists: ('a -> bool) -> 'a list -> bool`, such that
`exists p [a1; ...; an]` returns whether at least one element of the list
satisfies the predicate `p`. That is, it evaluates the same as
`(p a1) || (p a2) || ... || (p an)`. When applied to an empty list, it evaluates
to `false`.

Write three solutions to this problem, as we did above:

* `exists_rec`, which must be a recursive function that does not use the `List`
  module,
* `exists_fold`, which uses either `List.fold_left` or `List.fold_right`, but
  not any other `List` module functions nor the `rec` keyword, and
* `exists_lib`, which uses any combination of `List` module functions other than
  `fold_left` or `fold_right`, and does not use the `rec` keyword.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "account balance")}}

Write a function which, given a list of numbers representing debits, deducts
them from an account balance, and finally returns the remaining amount in the
balance. Write three versions: `fold_left`, `fold_right`, and a direct recursive
implementation.

<!--------------------------------------------------------------------------->
{{ ex2 | replace("%%NAME%%", "library uncurried")}}

Here is an uncurried version of `List.nth`:

```ocaml
let uncurried_nth (lst, n) = List.nth lst n
```

In a similar way, write uncurried versions of these library functions:

  - `List.append`
  - `Char.compare`
  - `Stdlib.max`

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "map composition")}}

Show how to replace any expression of the form `List.map f (List.map g lst)`
with an equivalent expression that calls `List.map` only once.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "more list fun")}}

Write functions that perform the following computations. Each function that you
write should use one of `List.fold`, `List.map` or `List.filter`. To choose
which of those to use, think about what the computation is doing: combining,
transforming, or filtering elements.

* Find those elements of a list of strings whose length is strictly greater than
  3.
* Add `1.0` to every element of a list of floats.
* Given a list of strings `strs` and another string `sep`, produce the string
  that contains every element of `strs` separated by `sep`. For example, given
  inputs `["hi";"bye"]` and `","`, produce `"hi,bye"`, being sure not to produce
  an extra comma either at the beginning or end of the result string.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "association list keys")}}

Recall that an association list is an implementation of a dictionary in terms of
a list of pairs, in which we treat the first component of each pair as a key and
the second component as a value.

Write a function `keys: ('a * 'b) list -> 'a list` that returns a list of the
unique keys in an association list. Since they must be unique, no value should
appear more than once in the output list. The order of values output does not
matter. How compact and efficient can you make your solution? Can you do it in
one line and linearithmic space and time? *Hint: `List.sort_uniq`.*

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "valid matrix")}}

A mathematical *matrix* can be represented with lists. In *row-major*
representation, this matrix

$$ \begin{bmatrix} 1 & 1 & 1 \\ 9 & 8 & 7 \end{bmatrix} $$

would be represented as the list `[[1; 1; 1]; [9; 8; 7]]`. Let's represent a
*row vector* as an `int list`. For example, `[9; 8; 7]` is a row vector.

A *valid* matrix is an `int list list` that has at least one row, at least one
column, and in which every column has the same number of rows. There are many
values of type `int list list` that are invalid, for example,

* `[]`
* `[[1; 2]; [3]]`

Implement a function `is_valid_matrix: int list list -> bool` that returns
whether the input matrix is valid. Unit test the function.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "row vector add")}}

Implement a function `add_row_vectors: int list -> int list -> int list` for the
element-wise addition of two row vectors. For example, the addition of
`[1; 1; 1]` and `[9; 8; 7]` is `[10; 9; 8]`. If the two vectors do not have the
same number of entries, the behavior of your function is
*unspecified*&mdash;that is, it may do whatever you like. *Hint: there is an
elegant one-line solution using `List.map2`.* Unit test the function.

<!--------------------------------------------------------------------------->
{{ ex3 | replace("%%NAME%%", "matrix add")}}

Implement a function `add_matrices: int list list -> int list list -> int list
list` for [matrix addition][matadd]. If the two input matrices are not the same
size, the behavior is unspecified. *Hint: there is an elegant one-line solution
using `List.map2` and `add_row_vectors`.* Unit test the function.

[matadd]: http://mathworld.wolfram.com/MatrixAddition.html

<!--------------------------------------------------------------------------->
{{ ex4 | replace("%%NAME%%", "matrix multiply")}}

Implement a function `multiply_matrices: int list list -> int list list -> int
list list` for [matrix multiplication][matmult]. If the two input matrices are
not of sizes that can be multiplied together, the behavior is unspecified. Unit
test the function. *Hint: define functions for matrix transposition and row
vector dot product.*

[matmult]: http://mathworld.wolfram.com/MatrixMultiplication.html
