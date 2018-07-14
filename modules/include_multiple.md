# Including Code in Multiple Modules

Suppose we wanted to write a function that could add a bunch of elements
to a set, something like:
```
(* [add_all l s] is the set [s] unioned with all the elements of [l] *)
let rec add_all lst set = match lst with
  | [] -> set
  | h::t -> add_all t (add h set)
```
(Of course, we could code that up more tersely with a fold function.)

One possibility would be to copy that code into both structures.  That would
compile, but it's poor software engineering.  If ever an improvement
needs to be made to that code (e.g., replacing it with a fold function), 
we have to remember to do it in two places.  So let's rule that out right
away as a non-solution.

So instead, after defining both set implementations above, suppose we try to enter
that code into utop outside of either implementation.  We'll get an error:
```
# let rec add_all lst set = match lst with
    | [] -> set
    | h::t -> add_all t (add h set)
Error: Unbound value add
```
The problem is we either need to choose `ListSetDups.add` or `ListSetNoDups.add`.
If we pick the former, the code will compile, but it will be useful only
with that one implementation:
```
# let rec add_all lst set = match lst with
    | [] -> set
    | h::t -> add_all t (ListSetNoDups.add h set)
- : 'a list -> 'a ListSetNoDups.t -> 'a ListSetNoDups.t = <fun>   
```
We could make the code parametric with respect to the `add` function:
```
let rec add_all' add lst set = match lst with
  | [] -> set
  | h::t -> add_all' add t (add h set)
  
let add_all_dups lst set = add_all' ListSetDups.add lst set
let add_all_nodups lst set = add_all' ListSetNoDups.add lst set
```
But this is annoying in a couple ways.  First, we have to remember which
function name to call, whereas all the other operations that are part of
those modules have the same name, regardless of which module they're in.
Second, the `add_all` functions live outside either module, so clients
who open one of the modules won't automatically get the ability to name
those functions.  

Let's try to use includes to solve this problem.  First, 
we write a module that contains the parameterized implementation
of `add_all'`:
```
module AddAll = struct
  let rec add_all' add lst set = match lst with
    | [] -> set
    | h::t -> add_all' add t (add h set)
end

module ListSetNoDupsExtended : SetExtended = struct
  include ListSetNoDups
  include AddAll
  let add_all lst set = add_all' add lst set
end

module ListSetDupsExtended : SetExtended = struct
  include ListSetDups
  include AddAll
  let add_all lst set = add_all' add lst set
end
```

We've succeeded, partially, in achieving code reuse. The code that
implements `add_all'` has been factored out into a single location and
reused in the two structures.  So we could now replace it with an
improved (?) version using a fold function:
```
module AddAll = struct
  let add_all' add lst set =
    let add' s x = add x s in
    List.fold_left add' set lst
end
```

But we've partially failed.  We still have to write an implementation
of `add_all` in both modules, and worse yet, those implementations
are identical.  So there's still code duplication occurring.

Could we do better?  Yes.  And that leads us to functors.
