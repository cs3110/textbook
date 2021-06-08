# Scope

After a module `M` has been defined, you can access the names within it
using the `.` operator.  For example:
```
# module M = struct let x = 42 end;;
module M : sig val x : int end 

# M.x;;
- : int = 42
```

You can also bring all of the definitions of a module into the current scope using
`open`.  Continuing our example above:
```
# x;;
Error: Unbound value x

# open M;;

# x;;
- : int = 42
```

Opening a module is like writing a local definition for each name defined
in the module.  `open String`, for example, brings all the definitions
from the [String module][string] into scope, and has an effect similar to the
following on the local namespace:
```
let length = String.length
let get = String.get
let lowercase_ascii = String.lowercase_ascii
...
```

[string]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/String.html

If there are types, exceptions, or modules defined in a module, those also are
brought into scope with `open`.  For example, if we're given this module:
```
module M = struct
  let x = 42
  type t = bool
  exception E
  module N = struct
    let y = 0
  end
end
```
then `open M` would have an effect similar to the following:
```
let x = M.x
type t = M.t
type exn += E = M.E
module N = M.N
```

(If the line with `exn` is mysterious, don't worry about it; it makes use
of extensible variants, which we aren't covering.  It might help to know
that `exception E` is syntactic sugar for `type exn += E`, which is to say
that it extends the type `exn`, which is an extensible variant, with
a new constructor `E`.)

**Stdlib.** 
There is a [special module called `Stdlib`][stdlib] that is
automatically opened in every OCaml program.  It contains the "built-in"
functions and operators, as we've seen before.  You therefore never need
to prefix any of the names it defines with `Stdlib.`, though you
could do so if you ever needed to unambiguously identify a name from it.
 
[stdlib]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Stdlib.html

## Opening a module in a limited scope

If two modules both define the same name, and you open both of them, what does that
name mean?  For example:
```
module M = struct let x = 42 end
module N = struct let x = "bigred" end
open M
open N
(* what is [x]?  an [int] or a [string]? *)
```
The answer is that any names defined later *shadow* names defined earlier.  So in 
the local namespace above, `x` is a `string`.  

If you're using many third-party modules inside your code, chances are you'll have at least
one collision like this.  Often it will be with a standard higher-order function like
`map` that is defined in many library modules. So it's generally good practice not to 
`open` all the modules you're going to use at the top of a `.ml` file. 
(This is perhaps different than how you're used to working with (e.g.) Java, 
where you might `import` many packages with `*`.)  

Instead, it's good to restrict the scope in which you open modules.  There are
a couple ways of doing that.

1.  Inside any expression you can locally open a module, such that the module's names
    are in scope only in the rest of that expression.  The syntax for this is
    `let open M in e`; inside `e` all the names from `M` are in scope.  This is useful for
    (e.g.) opening a module in the body of a function:
    
    ```
    (* without [open] *)
    let f x = 
      let y = List.filter ((>) 0) x in  
      ...  (* many more lines of code that use [List.] a lot *)

    (* with [open] *)
    let f x = 
      let open List in (* [filter] is now bound to [List.filter] *)
      let y = filter ((>) 0) x in  
      ...  (* many more lines of code that now can omit [List.] *)
    ```
    
2.  There is a syntactic sugar for the above:  `M.(e)`.  Again, inside `e` all the names
    from `M` are in scope.  This is useful for briefly using `M` in a short expression:
    ```
    (* remove surrounding whitespace from [s] and convert it to lower case *)
    let s = "BigRed " 
    let s' = s |> String.trim |> String.lowercase_ascii (*long way*)
    let s' = String.(s |> trim |> lowercase_ascii)      (*shorter way*)
    ```
