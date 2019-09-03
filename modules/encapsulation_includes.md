# Encapsulation and Includes

We mentioned above that you might wonder why we didn't write this simpler definition 
of `of_list`:
```
  let of_list lst = lst
```
The reason is that includes must obey encapsulation, just like the rest
of the module system.  `ListSetDups` was sealed with the module type
`Set`, thus making `'a t` abstract.  So even `ListSetDupsExtended` is
forbidden from knowing that `'a t` and `'a list` are synonyms.  

A standard way to solve this problem is to rewrite the definitions as
folllows:
```
module ListSetDupsImpl = struct
  type 'a t   = 'a list
  let empty   = []
  let mem     = List.mem
  let add x s = x::s
  let elts s  = List.sort_uniq Stdlib.compare s
end

module ListSetDups : Set = ListSetDupsImpl

module ListSetDupsExtended = struct
  include ListSetDupsImpl
  let of_list lst = lst
end
```
The important change is that `ListSetDupsImpl` is not sealed, so its type `'a t`
is not abstract.  When we include it in `ListSetDupsExtended`, we can therefore
exploit the fact that it's a synonym for `'a list`. 

What we just did is effectively the same as what Java does to handle the
visibility modifiers `public`, `private`, etc.  The "private version" of
a class is like the `Impl` version above: anyone who can see that
version gets to see all the exposed "things" (fields in Java, types in
OCaml), without any encapsulation.  The "public version" of a class is
like the sealed version above:  anyone who can see that version is
forced to treat the "things" (fields in Java, types in OCaml) as abstract,
hence encapsulated.