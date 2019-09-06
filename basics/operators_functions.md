# Operators as Functions

The addition operator `+` has type `int->int->int`. It is normally
written *infix*, e.g., `3 + 4`. By putting parentheses around it, we can
make it a *prefix* operator: 

```
# (+);;
- : int -> int -> int = <fun>

# (+) 3 4;;
- : int = 7

# let add3 = (+) 3;;
- : int -> int = <fun>

# add3 2;;
- : int = 5
```

The same technique works for any built-in operator. But be careful of
multiplication, which must be written `( * )` as prefix, because `(*)`
would be parsed as beginning a comment.

We can even define our own new infix operators, for example:

```
let (^^) x y = max x y
```

And now `2 ^^ 3` evaluates to `3`.  The rules for which punctuation can
be used to create infix operators, and the relative precedence that
operator will have, are not necessarily intuitive.  So be careful with
this usage.