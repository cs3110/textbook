# Filter

Here are two functions we might want to write:
```
let rec evens = function
  | [] -> []
  | h::t -> if even h then h::(evens t) else evens t
  
let rec odds = function  
  | [] -> []
  | h::t -> if odd h then h::(odds t) else odds t
```
Those two functions rely on a couple simple helper functions:
```
let even n = 
  n mod 2 = 0

let odd n = 
  n mod 2 <> 0
```

When applied, `evens` and `odds` return the even or odd integers in a list:
```
# evens [1;2;3;4] 
- : int list = [2;4]
# odds [1;2;3;4] 
- : int list = [1;3]
```

Those functions once again share some common structure:  the only essential
difference is the test they apply to the head element.  So let's factor out
that test as a function, and parameterize a unified version of the functions 
on it:

```
(* [filter p l] is the list of elements of [l] that satisfy the predicate [p]. 
 * The order of the elements in the input list is preserved. *)
let rec filter f = function
  | [] -> []
  | h::t -> if f h then h::(filter f t) else filter f t
```

And now we can reimplement our original two functions:
```
let evens = filter even
let odds  = filter odd
```
How simple these are!  How clear!  (At least to the reader who is
familiar with `filter`.)

Again, the idea of filter exists in many programming languages.  It's
`List.filter` in OCaml.  It's in Python 3.5:
```
>>> print(list(filter(lambda x: x%2 == 0, [1,2,3,4])))
[2, 4]
```
Java 8 recently added [filter][java8filter] too.

[java8filter]: https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html#filter-java.util.function.Predicate-
