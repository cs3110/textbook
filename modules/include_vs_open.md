# Include vs. Open

The `include` and `open` statements are quite similar, but they have
a subtly different effect on a structure.  Consider this code:
```
module M = struct
  let x = 0
end

module N = struct
  include M
  let y = x + 1
end

module O = struct
  open M
  let y = x + 1
end
```
If we enter that in the toplevel, we get the following response:
```
module M : sig val x : int end
module N : sig val x : int val y : int end
module O : sig val y : int end 
```
Look closely at the values contained in each structure.  `N` has both
an `x` and `y`, whereas `O` has only a `y`.  The reason is that
`include M` causes all the definitions of `M` to also be included in
`N`, so the definition of `x` from `M` is present in `N`.  But `open M`
only made those definitions available in the *scope* of `O`; it doesn't
actually make them part of the *structure*.  So `O` does not contain
a definition of `x`, even though `x` is in scope during the evaluation
of `O`'s definition of `y`.

A metaphor for understanding this difference might be:  `open M`
imports definitions from `M` and makes them available for local
consumption, but they aren't exported to the outside world.
Whereas `include M` imports definitions from `M`, makes them
available for local consumption, and additionally exports
them to the outside world.
