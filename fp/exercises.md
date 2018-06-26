# Exercises

### Exercise: values [&#10029;]

What is the type and value of each of the following OCaml expressions?

* `7  * (1+2+3)`
* `"CS " ^ string_of_int 3110`

*Hint:  type each expression into the toplevel and it will tell you the answer.
Note:  `^` is not exponentiation.*

&#9608;

### Exercise: operators [&#10029;&#10029;]

Examine the [table of all operators in the OCaml manual][ops].

* Write an expression that multiplies `42` by `10`.
* Write an expression that divides `3.14` by `2.0`.  *Hint: integer and floating-point
  operators are written differently in OCaml.*
* Write an expression that computes `4.2` raised to the seventh power.  *Note:
  there is no built-in integer exponentiation operator in OCaml
  (nor is there in C, by the way), in part because it is not an
  operation provided by most CPUs.*

&#9608;

[ops]: http://caml.inria.fr/pub/docs/manual-ocaml/expr.html#sec139

### Exercise: equality [&#10029;]

* Write an expression that compares `42` to `42` using structural equality.
* Write an expression that compares `"hi"` to `"hi"` using structural equality.  What is
  the result?
* Write an expression that compares `"hi"` to `"hi"` using physical equality.  What is
  the result?

&#9608;

### Exercise: assert [&#10029;]

* Enter `assert true;;` into utop and see what happens.
* Enter `assert false;;` into utop and see what happens.
* Write an expression that asserts 2110 is not (structurally) equal to 3110.

&#9608;

### Exercise: if [&#10029;]

Write an if expression that evaluates to `42` if `2` is greater than `1` and otherwise
evaluates to `7`.

&#9608;

### Exercise: double fun [&#10029;]

Using the increment function from above as a guide, define a function
`double` that multiplies its input by 2.  For example, `double 7` would be `14`.
Test your function by applying it to a few inputs.  Turn those test
cases into assertions.

&#9608;

### Exercise: more fun [&#10029;&#10029;]

* Define a function that computes the cube of a floating-point number.
  Test your function by applying it to a few inputs.
* Define a function that computes the sign (1, 0, or -1) of an integer.
  Use a nested if expression. Test your function by applying it to a few inputs.
* Define a function that computes the area of a circle given its radius.
  Test your function with `assert`.
  
For the latter, bear in mind that floating-point arithmetic is not exact.
Instead of asserting an exact value, you should assert that the result
is "close enough", e.g., within 1e-5.  If that's unfamiliar to you,
it would be worthwhile to read up on [floating-point arithmetic][fparith].

[fparith]: https://floating-point-gui.de/

&#9608;

A function that take multiple inputs can be defined just by providing
additional names for those inputs as part of the let definition.  For
example, the following function computes the average of three arguments:

```
let avg3 x y z =
  (x +. y +. z) /. 3.
```

### Exercise: RMS [&#10029;&#10029;]

Define a function that computes the root-mean-square of two numbers&mdash;i.e., 
\\(\\sqrt{(x^2 + y^2) / 2}\\).  Test your function with `assert`.

&#9608;

### Exercise: date fun [&#10029;&#10029;&#10029;]

Define a function that takes an integer `d` and string `m` as input and returns
`true` just when `d` and `m` form a *valid date*.  Here, a valid date has a
month that is one of the following abbreviations: Jan, Feb, Mar, Apr, May, Jun,
Jul, Aug, Sept, Oct, Nov, Dec.  And the day must be a number that is between 1
and the minimum number of days in that month, inclusive.  For example, if the
month is Jan, then the day is between 1 and 31, inclusive, whereas if the month
is Feb, then the day is between 1 and 28, inclusive.

How terse (i.e., few and short lines of code) can you make your function?
You can definitely do this in fewer than 12 lines.

&#9608;

### Exercise: editor tutorial [&#10029;&#10029;&#10029;]

Which editor you use is largely a matter of personal preference.  Atom, Sublime,
and Komodo all provide a modern GUI.  Emacs and Vim are more text-based.
If you've never tried Emacs or Vim, why not spend 10 minutes with each?
There are good reasons why they are beloved by many programmers.

* To get started with learning Vim, run `vimtutor -g`.
* To get started with learning Emacs, run `emacs` then press `C-h t`, that is,
  Control+H followed by t.

&#9608;

### Exercise: master an editor [&#10029;&#10029;&#10029;&#10029;&#10029;, advanced]

You'll be working on this exercise for the rest of your career!
Try not to get caught up in any [editor wars][xkcd].

[xkcd]: https://xkcd.com/378/

&#9608;