# Semantics

The semantics of the OCaml module system is sufficiently complex that
it's better left to a course like CS 6110 or even 7110. Here we'll just
sketch a couple of the relevant facts.

**Dynamic semantics.**  To evaluate a structure `struct D1; ...; Dn end` where
each of the `Di` is a definition, evaluate each definition in order.

**Static semantics.**  If a module is given a module type, as in 
`module M : T = struct ... end`, then there are two checks the compiler
must perform:

  1.  *Signature matching:*  every name declared in `T` must 
      be defined in `M`.  
      
  2.  *Encapsulation:*  any name defined in `M` that does not appear
      in `T` is not visible to code outside of `M`.