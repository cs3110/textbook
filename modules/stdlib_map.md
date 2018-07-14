# Example: Standard Library Map

The standard library's Map module, which implements a dictionary data
structure using balanced binary trees, is based on functors.
In this section, we study how to use it.  You can see the [implementation
of that module on GitHub][mapimplsrc] as well as its [interface][mapintsrc].

[mapintsrc]: https://github.com/ocaml/ocaml/blob/trunk/stdlib/map.mli
[mapimplsrc]: https://github.com/ocaml/ocaml/blob/trunk/stdlib/map.ml

The Map module defines a functor `Make` that creates a structure implementing
a map over a particular type of keys.  That type is the input structure
to `Make`.  The type of that input structure is `Map.OrderedType`, which are types that
support a `compare` operation:
```
module type OrderedType = sig
  type t
  val compare : t -> t -> int
end
```
The Map module needs ordering because balanced binary trees need to be able
to compare keys to determine whether one is greater than another.
According to the library's documentation, `compare` must satisfy this
specification:
```
(* This is a two-argument function [f] such that
 * [f e1 e2] is zero if the keys [e1] and [e2] are equal,
 * [f e1 e2] is strictly negative if [e1] is smaller than [e2],
 * and [f e1 e2] is strictly positive if [e1] is greater than [e2].
 * Example: a suitable ordering function is the generic structural
 * comparison function [Pervasives.compare]. *)
val compare : t -> t -> int
```
Arguably this specification is a missed opportunity for good design:  the library
designers could instead have defined a variant:
```
type order = LT | EQ | GT
```
and required the output type of `compare` to be `order`.  But historically many
languages have used comparison functions with similar specifications, such
as the C standard library's [`strcmp` function][strcmp].

[strcmp]: http://www.gnu.org/software/libc/manual/html_node/String_002fArray-Comparison.html

The output of `Map.Make` is a structure whose type is (almost) `Map.S` and supports
all the usual operations we would expect from a dictionary:
```
module type S =
  sig
    type key
    type 'a t

    val empty: 'a t
    val mem:   key -> 'a t -> bool
    val add:   key -> 'a -> 'a t -> 'a t
    val find:  key -> 'a t -> 'a
	...
  end
```
There are two reasons why we say that the output is "almost" that type:

1. The Map module actually
   specifies a *sharing constraint* (which we covered in the previous notes):
   `type key = Ord.t`.  That is, the output of `Map.Make` shares its `key` type
   with the type `Ord.t`.  That enables keys to be compared with `Ord.compare`.
   The way that sharing constraint is specified is in the type of `Make` (which
   can be found in `map.mli`, the interface file for the map compilation unit):
   ```
   module Make : functor (Ord : OrderedType) -> (S with type key = Ord.t)
   ```

2. The Map module actually specifies something called a *variance* on the
   representation type, writing `+'a t` instead of `'a t` as we did above.
   We won't concern ourselves with what this means; it's [related to subtyping
   and polymorphic variants][variance].

[variance]: https://blogs.janestreet.com/a-and-a/

The functor `Map.Make` itself (which can be found in `map.ml`, the implementation
file for the map compilation unit) is currently defined as follows, though of course
the library is free to change its internals in the future:
```
module Make(Ord: OrderedType) = struct
  type key = Ord.t
  
  type 'a t =
    | Empty
    | Node of 'a t * key * 'a * 'a t * int
      (* left subtree * key * value * right subtree * height of node *)
      
  let empty = Empty
  
  let rec mem x = function
    | Empty -> false
    | Node(l, v, _, r, _) ->
        let c = Ord.compare x v in
        c = 0 || mem x (if c < 0 then l else r)
  ...
```
The `key` type is defined to be a synonym for the type `t` inside `Ord`, so 
`key` values are comparable using `Ord.compare`.  The `mem` function uses
that to compare keys and decide whether to recurse on the left subtree or right
subtree.

## Using the Map Module

**A map for integer keys.**
To create a map, we have to pass a structure into `Map.Make`, and that structure
has to define a type `t` and `compare` function.  The simplest way to do 
that is to pass an anonymous structure into the functor:
```
# module IntMap = Map.Make(struct type t = int let compare = Pervasives.compare end);;
module IntMap : 
  sig
    type key = int                                                              
    type 'a t
    val empty : 'a t
    ...
  end

# open IntMap;;

# let m1 = add 1 "one" empty;;
val m1 : string t = <abstr>

# find 1 m1;;
- : string = "one"

# mem 42 m1;;
- : bool = false

# find 42 m1;;
Exception: Not_found.

# bindings m1;;
- : (int * string) list = [(1, "one")]

# let m2 = add 1 1. empty;;
val m2 : float t = <abstr>

# bindings m2;;
- : (int * float) list = [(1, 1.)]


```
Here are some things to note about the utop transcript above:

* We can write a structure on one line, even though until now we've always
  used line breaks to keep them readable.  When writing a structure on
  on line (which we'll only do for really short structures) it can
  be useful to use the double semicolon between definitions to enhance readability:
  
  ```
  # module IntMap = Map.Make(struct type t = int;; let compare = Pervasives.compare end);;
  ```
  
  This is an exception to the general style rule of avoiding double semicolon inside 
  source code.
  
  If we didn't want to pass an anonymous structure, we could instead define a
  module and pass it:
  
  ```
  module Int = struct
    type t = int
    let compare = Pervasives.compare
  end
  module IntMap = Map.Make(Int)
  ```
  
* The signature of the structure returned by `Map.Make` records the fact that 
  keys are of type `int`.  The type `'a t` is the name of the representation
  type of an `IntMap`.  The `'a` type variable in it is the type of values in
  the map.  Although in general the map could have any value type, once we
  add a single value to a map, that "pins down" the value type of that
  particular map.  When we add the binding from key `1` to string `"one` above,
  notice that the map value returned is of type `string t`.

* The `bindings` function of a map returns an association list of all the bindings
  in the map.  Association lists are, of course, another data structure
  that implements a dictionary.  But they are less efficient than the balanced
  binary search tree implementation used by `Map`.

* The `mem` function tests whether a key is a <u>mem</u>ber of a map.
  The `find` function finds the value associated with a key, and raises
  the `Not_found` exception if the key is not bound in the map.  That's
  the same exception that `List.assoc` raises if a key is not bound
  in an association list.
  
**A map for string keys.**
If a module already provides a type `t` that can be compared, we can
immediately use that module as an argument to `Map.Make`.  Several
standard library modules are designed to be used in that way.
For example, the `String` module defines a type `t` and a `compare` function
that meet the specification of `Map.OrderedType`.  So we can easily
create maps whose key type is `string`:
```
# module StringMap = Map.Make(String);;
module StringMap :
  sig
    type key = string                                                           
    ...
  end
```

Now we could use the string map like we used the int map.  This time, for sake
of example, let's not open the `StringMap` module:
```
# let m = StringMap.(add "one" 1 empty);;
# let m' = StringMap.(add "two" 2 m);;
# StringMap.bindings m';;
- : (string * int) list = [("one", 1); ("two", 2)] 
# StringMap.bindings m;;
- : (string * int) list = [("one", 1)] 
#
```
Note that maps are a functional data structure:  adding a mapping to `m`
did not mutate `m`; rather, it produced a new map that we bound
to `m'`, and both the new map and old map remain available for use.

**A map for record keys.**
When the type of a key becomes more complicated than a built-in primitive
type, we might want to write our own custom comparison function.  For 
example, suppose we want a map in which keys are records representing names,
and in which names are sorted alphabetically by last name then by first name.
In the code below, we provide a module `Name` that can compare records that way:
```
type name = {first:string; last:string}
 
module Name = struct
  type t = name
  let compare {first=first1;last=last1}
              {first=first2;last=last2} =
    match Pervasives.compare last1 last2 with
    | 0 -> Pervasives.compare first1 first2
    | c -> c
end
```

The `Name` module can be used as input to `Map.Make` because it matches
the `Map.OrderedType` signature:
```
module NameMap = Map.Make(Name)
```

And now we could add some names to a map.  Below, for sake of example,
we map some names to birth years, and we use the pipeline operator
to easily add multiple bindings one after another:
```
let k1 = {last="Kardashian"; first="Kourtney"}
let k2 = {last="Kardashian"; first="Kimberly"}
let k3 = {last="Kardashian"; first="Khloe"}
let k4 = {last="West"; first="Kanye"}

let nm = NameMap.(
  empty |> add k1 1979 |> add k2 1980 
        |> add k3 1984 |> add k4 1977)

let lst = NameMap.bindings nm
```
The value of `lst` will be
```
[({first = "Khloe"; last = "Kardashian"}, 1984);
 ({first = "Kimberly"; last = "Kardashian"}, 1980);
 ({first = "Kourtney"; last = "Kardashian"}, 1979);
 ({first = "Kanye"; last = "West"}, 1977)]
```
Note how the order of keys in that list is not the same as the order in which
we added them.  The list is sorted according to the `Name.compare` function we wrote.
Several of the other functions in the `Map.S` signature will also process map bindings
in that sorted order&mdash;for example, `map`, `fold`, and `iter`.

## Code Reuse with Map

Stepping back from the mechanics of how to use `Map`, let's think about 
how it achieves code reuse.  The implementor of `Map` had a tricky problem
to solve:  balanced binary search trees require a way to compare keys, but
the implementor can't know in advance all the different types of keys
that a client of the data structure will want to use.  And each type of
key might need its own comparison function.  Although the standard library's
`Pervasives.compare` *can* be used to compare any two values of the same
type, the result it returns isn't necessarily what a client will want.  For 
example, it's not guaranteed to sort names in the way we wanted above.

So the implementor of `Map` parameterized it on a structure that bundles
together the type of keys with a function that can be used to compare them.
It's the client's responsibility to implement that structure. Given it,
all the code in `Map` can be re-used by the client.  

The Java Collections Framework solves a similar problem in the TreeMap class,
which has a [constructor that takes a Comparator][treemapcomparator].  There, the client has the
responsibility of implementing a class for comparisons, rather than a structure.
Though the language features are different, the idea is the same.

[treemapcomparator]: https://docs.oracle.com/javase/8/docs/api/java/util/TreeMap.html#TreeMap-java.util.Comparator-
