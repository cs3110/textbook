# Functor Syntax

In the functor syntax we've been using:
```
module F (M : S) = struct
  ...
end
```
the type annotation `: S` and the parentheses around it, `(M : S)` are required.
The reason why is that type inference of the signature of a functor input
is not supported.

Much like functions, functors can be written anonymously.  The following
two syntaxes for functors are equivalent:
```
module F (M : S) = struct
  ...
end

module F = functor (M : S) -> struct
  ...
end
```
The second form uses the `functor` keyword to create an anonymous functor,
like how the `fun` keyword creates an anonymous function.

And functors can be parameterized on multiple structures:
```
module F (M1 : S1) ... (Mn : Sn) = struct
  ...
end
```
Of course, that's just syntactic sugar for a *higher-order functor* that takes
a structure as input and returns an anonymous functor:
```
module F = functor (M1 : S1) -> ... -> functor (Mn : Sn) -> struct
  ...
end
```

If you want to specify the output type of a functor, the syntax is again 
similar to functions:
```
module F (M : Si) : So = struct
  ...
end 
```
It's also possible to write the type annotation on the structure:
```
module F (M : Si) = (struct
  ...
end : So)
```
In that case, note that the parentheses around the anonymous structure are
required.  It turns out that syntax parallels a similar syntax for
functions that we just haven't used before:
```
let f x = (x+1 : int)
``` 

The syntax for writing down the type of a functor is also much like the
syntax for writing down the type of a function.  Here is the type of
a functor that takes a structure matching signature `Si` as input
and returns a structure matching `So`:
```
functor (M : Si) -> So
```
If you wanted to annotate a functor definition with a type you can
combine a couple of the syntaxes we've now seen:
```
module F : functor (M : Si) -> So = 
  functor (M : Si) -> struct ... end
```
The first occurrence of `functor` in that code means that what follows
is a functor type, and the second occurrence means that what follows
is an anonymous functor value.