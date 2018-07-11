# Dictionaries

A *dictionary* maps *keys* to *values*.  This data structure typically
supports at least a lookup operation that allows you to find the value
with a corresponding key, an insert operation that lets you create a new
dictionary with an extra key included.  And there needs to be a way of
creating an empty dictionary.

We might represent this in a `Dictionary` module type as follows:

```
module type Dictionary = sig
  type ('k, 'v) t

  (* The empty dictionary *)
  val empty  : ('k, 'v) t

  (* [insert k v d] produces a new dictionary [d'] with the same mappings 
   * as [d] and also a mapping from [k] to [v], even if [k] was already 
   * mapped in [d]. *)
  val insert : 'k -> 'v -> ('k,'v) t -> ('k,'v) t

  (* [lookup k d] returns the value associated with [k] in [d].  
   * raises:  [Not_found] if [k] is not mapped to any value in [d]. *)
  val lookup  : 'k -> ('k,'v) t -> 'v
end
```

Note how the type `Dictionary.t` is parameterized on two types, `'k` and `'v`,
which are written in parentheses and separated by commas.  Although `('k,'v)`
might look like a pair of values, it is not: it is a syntax for writing
multiple type variables.

We have seen already in this class that an association list can be used
as a simple implementation of a dictionary.  For example, here is an 
association list that maps some well-known names to an approximation of 
their numeric value:

```
[("pi", 3.14); ("e", 2.718); ("phi", 1.618)]
```

Let's try implementing the `Dictionary` module type with a module
called `AssocListDict`.

```
module AssocListDict = struct
  type ('k, 'v) t = ('k * 'v) list
  
  let empty = []
  
  let insert k v d = (k,v)::d
  
  let lookup k d = List.assoc k d
end
```

If we put that code in a file named `dict.ml`, launch utop, and type:
```
# #use "dict.ml";;
# open AssocListDict;;
# let d = insert 1 "one" empty;;
```
The response we get is:
```
val d : (int * string) list = [(1, "one")] 
```

But if we change the first line of the implementation of
`AssocListDict` in `dict.ml` to the following:
```
module AssocListDict : Dictionary = struct
```
And if we restart utop and repeat the three phrases above (use,open,let), 
we get a different response:
```
val d : (int, string) t = <abstr>
```

That's because by indicating that the module has type `Dictionary`, the
type `AssocListDict.t` has become abstract.  Clients of the module
are no longer permitted to know that it is implemented with a list.
That provides encapsulation, so that if we later wanted to change
the representation, we could safely do so.
