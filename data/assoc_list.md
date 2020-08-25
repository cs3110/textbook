# Association Lists

A *dictionary* is a data structure that maps *keys* to *values*. One
easy implementation of a dictionary is an *association list*, which is a
list of pairs.  Here, for example, is an association list that
maps some shape names to the number of sides they have:
```
let d = [ ("rectangle", 4); ("triangle", 3); ("dodecagon", 12) ];;
val d : (string * int) list =  (* omitted *)
```
Note that association list isn't so much a built-in data type in OCaml
as a combination of two other types:  lists and pairs.

Here are two functions that implement insertion and lookup in
an association list:
```
(* insert a binding from key k to value v in association list d *)
let insert k v d = (k,v)::d

(* find the value v to which key k is bound, if any, in the assocation list *)
let rec lookup k = function
| [] -> None
| (k',v)::t -> if k=k' then Some v else lookup k t
```
The `insert` function simply adds a new map from a key to a value at
the front of the list.  It doesn't bother to check whether the key is
already in the list.  The `lookup` function looks through the list
from left to right.  So if there did happen to be multiple maps
for a given key in the list, only the most recently inserted one
would be returned.

Insertion in an association list is therefore constant time, and lookup
is linear time.  Although there are certainly more efficient
implementations of dictionaries&mdash;and we'll study some later in this
course&mdash;association lists are a very easy and useful implementation for
small dictionaries that aren't performance critical.  The OCaml standard 
library has functions for association lists in the [`List`
module][list]; look for `List.assoc` and the functions below it in the
documentation.

[list]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/List.html
