# Semantics of Includes

Includes can be used inside of structures and inside of signatures.
Of course, when we include inside a signature, we must be including another
signature.  And when we include inside a structure, we must be including
another structure.

## Including a Structure

Including a structure is like writing a local definition for each name defined
in the module.  Writing `include ListSetDups` as we did above, 
for example, has an effect similar to writing exactly the following: 
```
module ListSetDupsExtended = struct
  (* BEGIN all the includes *)
  type 'a t = 'a ListSetDups.t
  let empty = ListSetDups.empty
  let mem   = ListSetDups.mem
  let add   = ListSetDups.add
  let elts  = ListSetDups.elts
  (* END all the includes *)
  let of_list lst = List.fold_right add lst empty
end
```
But if the set of names defined inside `ListSetDups` ever changed, 
the `include` would reflect that change, whereas the static code
we wrote above would not.

## Including a Signature 

Signatures also support includes.  For example, we could write:
```
module type SetExtended = sig
  include Set
  val of_list : 'a list -> 'a t
end
```
Which would have an effect similar to writing the following:
```
module type SetExtended = sig
  (* BEGIN all the includes *)
  type 'a t
  val empty : 'a t
  val mem   : 'a -> 'a t -> bool
  val add   : 'a -> 'a t -> 'a t
  val elts  : 'a t -> 'a list
  (* END all the includes *)
  val of_list : 'a list -> 'a t
end
```
And that module type would be suitable for `ListSetDupsExtended`:
```
module ListSetDupsExtended : SetExtended = struct
  include ListSetDupsImpl
  let of_list lst = lst 
end
``` 
By sealing the module, we've again made `'a t` abstract, so no one outside
that module gets to know that its representation type is actually `'a list`.
