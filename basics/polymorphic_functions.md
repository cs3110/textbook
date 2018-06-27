# Polymorphic functions

The syntactically simplest function is the *identity* function `let id x = x`.  
What is its type?  We can enter it into the toplevel to find out:

```
# let id x = x;;
id : 'a -> 'a = <fun>
```

The `'a` is a *type variable*:  it stands for an unknown type, just like
a regular variable stands for an unknown value.  Type variables always
begin with a single quote.  Commonly used type variables include `'a`, `'b`, and `'c`,
which OCaml programmers typically pronounce in Greek:  alpha, beta, and gamma.

We can apply that identity function to any type of value we like:

```
# id 42;;
- : int = 42

# id true;;
- : bool = true

# id "bigred";;
- : string = "bigred"
```

Because you can apply that function to many types of values, it is a *polymorphic*
function.  (*poly* = many, *morph* = form)
