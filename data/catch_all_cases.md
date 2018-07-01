# Catch-all Cases

One thing to beware of when pattern matching against variants is what
*Real World OCaml* calls "catch-all cases".  Here's a simple example of
what can go wrong.  Let's suppose you write this variant and function:
```
type color = Blue | Red
(* a thousand lines of code in between *)
let string_of_color = function
  | Blue -> "blue"
  | _    -> "red"
```
Seems fine, right?  But then one day you realize there are more colors
in the world.  You need to represent green.  So you go back and add green
to your variant:
``` 
type color = Blue | Red | Green
```
But because of the thousand lines of code in between, you forget that 
`string_of_color` needs updating.  And now, all the sudden, you are
red-green color blind:
```
# string_of_color Green
- : string = "red"
```
The problem is the *catch-all* case in the pattern match inside `string_of_color`:
the final case that uses the wildcard pattern to match anything.  Such code
is not robust against future changes to the variant type.

If, instead, you had originally coded the function as follows, life would be better:
```
let string_of_color = function
  | Blue -> "blue"
  | Red  -> "red"
```
Now, when you change `color` to add the `Green` constructor, the OCaml type checker
will discover and alert you that you haven't yet updated `string_of_color` to
account for the new constructor:
```
Warning 8: this pattern-matching is not exhaustive.
Here is an example of a value that is not matched:                              
Green
```

The moral of the story is:  catch-all cases lead to buggy code.  Avoid using them.
