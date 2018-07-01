# Type Synonyms

A *type synonym* is a new name for an already existing type.  For example,
here are some type synonyms that might be useful in representing some
types from linear algebra:
```
type point  = float * float
type vector = float list
type matrix = float list list
```

Anywhere that a `float*float` is expected, you could use `point`, and vice-versa.
The two are completely exchangeable for one another.  In the following code,
`getx` doesn't care whether you pass it a value that is annotated as
one vs. the other:
```
let getx : point -> float =
  fun (x,_) -> x

let pt : point = (1.,2.)
let floatpair : float*float = (1.,3.)

let one  = getx pt
let one' = getx floatpair
```

Type synonyms are useful because they let us give descriptive names
to complex types.  They are a way of making code more self-documenting.