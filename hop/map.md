# Map

Here are two functions we might want to write:
```
(* add 1 to each element of list *)
let rec add1 = function
  | [] -> []
  | h::t -> (h+1)::(add1 t)
  
(* concatenate "3110" to each element of list *)
let rec concat3110 = function
  | [] -> []
  | h::t -> (h^"3110")::(concat3110 t)
```

When given input `[a; b; c]` they produce these results:
```
add1:       [a+1;      b+1;      c+1]
concat3110: [a^"3110"; b^"3110"; c^"3110"]
```
Let's introduce these definitions:
```
let f = fun x -> x+1
let g = fun x -> x^"3110"
```
Then we can rewrite the previous results as:
```
add1:       [f a; f b; f c]
concat3110: [g a; g b; g c]
```

Once again we notice some common structure that could be factored out.
The only real difference between these two functions is that they
apply a different function when transforming the head element.

So let's *abstract* that function from the definitions of `add1` and
`concat3110`, and make it an argument.  Call the unified version of the two
`map`, because it *maps* each element of the list through a function:
```
(* [map f [x1; x2; ...; xn]] is [f x1; f x2; ...; f xn] *)
let rec map f = function
  | [] -> []
  | h::t -> (f h)::(map f t)
```
Now we can implement our original two functions quite simply:
```
let add1 lst = map (fun x -> x+1) lst
let concat3110 lst = map (fun x -> x^"3110") lst
```
And we can even remove the `lst` everywhere it appears, relying 
on the fact that `map f` will return a function that expects an input list:
```
let add1 = map (fun x -> x+1) 
let concat3110 = map (fun x -> x^"3110") 
```
It's worthwhile putting both those version of the functions, with and without
`lst`, into the toplevel so that you can observe that the types do not change.

We have now successfully applied the Abstraction Principle: the common structure
has been factored out.  What's left clearly expresses the computation, at
least to the reader who is familiar with `map`, in a way that the original
versions do not as quickly make apparent.

The idea of map exists in many programming languages.  It's called
`List.map` in the OCaml standard library.  Python 3.5 also has it:
```
>>> print(list(map(lambda x: x+1, [1,2,3])))
[2, 3, 4]
```
Java 8 recently added [map][java8map] too.

[java8map]: https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html#map-java.util.function.Function-
