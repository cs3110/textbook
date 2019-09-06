# Accessing Lists

There are really only two ways to build a list, with nil and cons.
So if we want to take apart a list into its component pieces, we 
have to say what to do with the list if it's empty, and what to do if
it's non-empty (that is, a cons of one element onto some other list). 
We do that with a language feature called *pattern matching*.

Here's an example of using pattern matching to compute the sum of
a list:
```
let rec sum lst = 
  match lst with
  | [] -> 0
  | h::t -> h + sum t
```
This function says to take the input `lst` and see whether it has the
same shape as the empty list.  If so, return 0.  Otherwise, if
it has the same shape as the list `h::t`, then let `h` be the first
element of `lst`, and let `t` be the rest of the elements of `lst`,
and return `h + sum t`.  The choice of variable names here is
meant to suggest "head" and "tail" and is a common idiom, but we could 
use other names if we wanted.  Another common idiom is:
```
let rec sum xs = 
  match xs with
  | [] -> 0
  | x::xs' -> x + sum xs'
```
That is, the input list is a list of xs (pronounced EX-uhs), 
the head element is an x, and the tail is xs' (pronounced EX-uhs prime).

Here's another example of using pattern matching to compute the
length of a list:
```
let rec length lst = 
  match lst with
  | [] -> 0
  | h::t -> 1 + length t
```
Note how we didn't actually need the variable `h` in the right-hand side of
the pattern match.
When we want to indicate the presence of some value in a pattern without
actually giving it a name, we can write `_` (the underscore character):
```
let rec length lst = 
  match lst with
  | [] -> 0
  | _::t -> 1 + length t
```

And here's a third example that appends one list onto the beginning of
another list:
```
let rec append lst1 lst2 = 
  match lst1 with
  | [] -> lst2
  | h::t -> h::(append t lst2)
```
For example, `append [1;2] [3;4]` is `[1;2;3;4]`.
That function is actually available as a built-in operator `@`, so
we could instead write `[1;2] @ [3;4]`.

As a final example, we could write a function to determine whether
a list is empty:
```
let empty lst = 
  match lst with
  | [] -> true
  | h::t -> false
```
But there a much easier way to write the same function without pattern 
matching:
```
let empty lst = 
  lst = []
```

Note how all the recursive functions above are similar to doing proofs
by induction on the natural numbers:  every natural number is either 0
or is 1 greater than some other natural number \\(n\\), and so a proof
by induction has a base case for 0 and an inductive case for \\(n+1\\).
Likewise all our functions have a base case for the empty list and a
recursive case for the list that has one more element than another list.
This similarity is no accident. There is a deep relationship between
induction and recursion; we'll explore that relationship in more detail
later in the course.

By the way, there are two library functions `List.hd` and `List.tl`
that return the head and tail of a list.  It is not good, idiomatic
OCaml to apply these directly to a list.  The problem is that they
will raise an exception when applied to the empty list, and you will
have to remember to handle that exception.  Instead, you should use
pattern matching:  you'll then be forced to match against both
the empty list and the non-empty list (at least), which will prevent
exceptions from being raised, thus making your program more robust.
