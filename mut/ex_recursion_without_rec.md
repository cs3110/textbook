# Example: Recursion Without Rec

Here's a neat trick that's possible with refs:  we can build recursive functions
without ever using the keyword `rec`.  Suppose we want to define a recursive
function such as `fact`:

```
let rec fact n = 
  if n = 0 then 1 else n * fact (n-1)
```

Abstracting a little, that function has the following form:

```
let rec f x = 
  ... some code including a recursive call [f y] from some argument [y] ...
```

We can instead write the following:

```
let f0 = 
  ref (fun x -> x)
  
let f x = 
  ... replace [f y] with [!f0 y] ...
  
let () = f0 := f
```

Now `f` will compute the same result as it did in the version where we defined it
with `rec`.  What's happening here is sometimes called "tying the recursive knot":
we update the reference to `f0` to point to `f`, such that when `f` dereferences `f0`,
it gets itself back!  The initial function to which we made `f0` point (in this case
the identity function) doesn't really matter; it's just there as a placeholder until we 
tie the knot.

Here's an example of that with the factorial function:

```
let fact0 =
  ref (fun x -> x)
  
let fact n =  (* note: no [rec] *)
  if n = 0 then 1 else n * (!fact0) (n-1)
  
let () = fact0 := fact

let x = fact 5 (* ==> 120 *)
```
