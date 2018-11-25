# Type Constraints

To gather the constraints for a definition, HM does the following:

-   Assign a preliminary type to every subexpression in the definition.
    For known operations and constants, such as `+` and `3`, use the
    type that is already known for it. For anything else, use a new type
    variable that hasn't been used anywhere else.

-   Use the "shape" of the expressions to generate constraints. For
    example, if an expression involves applying a function to an
    argument, then generate a constraint requiring the type of the
    argument to be the same as the function's input type.
    
We'll give some examples of this first, then we'll give the algorithms
for doing it.

#### Example 1. 

Here's an example utop interaction:
```
# let g x = 5 + x;;
val g : int -> int = <fun>
```
How did OCaml infer the type of `g` here?  Let's work it out.

First, let's rewrite `g` syntactically to make our work a little easier:
```
let g = fun x -> ((+) 5) x
```
We've made the anonymous function explicit, and we've made the
binary infix operator a prefix function application.

**1. Assign preliminary types.**

For each subexpression of `fun x -> (+) 5 x`, including the entire
expression itself, we assign a preliminary type. We already know the
types of `(+)` and `5`, because those are baked into the language
itself, but for everything else we "play dumb" and just invent a new
type variable for it. For now we will use uppercase letters to represent
those type variables, rather than the OCaml syntax for type variables
(e.g., `'a`).
```
Subexpression         Preliminary type
------------------    --------------------
fun x -> ((+) 5) x    R
    x                 U
         ((+) 5) x    S
         ((+) 5)      T
          (+)         int -> (int -> int)
              5       int
                 x    V
```

**2. Collect constraints.**

Here are some observations we could make about the "shape" of subexpressions
and some relationships among them:

* Since function argument `x` has type `U` and function body `((+) 5) x` 
  has type `S`, it must be the case that `R`, the type of the anonymous
  function expression, satisfies the constraint `R = U -> S`.
  That is, *the type of the anonymous function* is *the type of its argument*
  arrow *the type of its body*.
  
* Since function `((+) 5)` has type `T` and function
  application `((+) 5) x` has type `S`, and since the argument `x` has
  type `V`, it must be the case that `T = V -> S`.  That is,
  *the type of the function being applied* is *the type of the argument it's
  being applied to* arrow *the type of the function application expression*.
    
* Since function `(+)` has type `int -> (int -> int)` and function
  application `(+) 5` has type `T`, and since the argument `5` 
  has type `int`, it must be the case that `int -> (int->int) = int -> T`.
  Once again,
  *the type of the function being applied* is *the type of the argument it's
  being applied to* arrow *the type of the function application expression*.
  
* Since `x` occurs with both type `U` and `V`, it must be the case that `U = V`.

The set of constraints thus generated is:
```
                  U = V
                  R = U -> S
                  T = V -> S
int -> (int -> int) = int -> T
```

**3. Solve constraints.**

You can solve that system of equations easily. Starting from the last
constraint, we know `T` must be `int -> int`. Substituting that into the
second constraint, we get that `int -> int` must equal `V -> S`, hence
`V = S = int`. Since `U=V`, `U` must also be `int`. Substituting for `S`
and `U` in the first constraint, we get that `R = int -> int`. So the
inferred type of `g` is `int -> int`.

#### Example 2. 

```
# let apply f x = f x;;
val apply : ('a -> 'b) -> 'a -> 'b = <fun>
```

Again we rewrite:
```
let apply = fun f -> (fun x -> f x)
```

**1. Assign preliminary types.**

```
Subexpression              Preliminary type
-----------------------    ------------------
fun f -> (fun x -> f x)    R
    f                      S 
         (fun x -> f x)    T 
              x            U 
                   f x     V 
                   f       S
                     x     U
```

**2. Collect constraints.**

- `R = S -> T`, because of the anonymous function expression.
- `T = U -> V`, because of the nested anonymous function expression.
- `S = U -> V`, because of the function application.

**3. Solve constraints.**

Using the third constraint, and substituting for `S` in the first
constraint, we have that `R = (U -> V) -> T`.  Using the second
constraint, and substituting for `T` in the first constraint,
we have that `R = (U -> V) -> (U -> V)`.  There are no further
substitutions that can be made, so we're done solving the constraints.
If we now replace the preliminary type variables with actual OCaml
type variables, specifically `U` with `'a` and `V` with `'b`, we get that
the type of `apply` is `('a -> 'b) -> ('a -> 'b)`, which is the same as 
`('a -> 'b) -> 'a -> 'b`.

#### Example 3. 

```
# apply g 3;;
- : int = 8
```

We rewrite that as `(apply g) 3`.

**1. Assign preliminary types.**

In this running example, the inference for `g` and `apply` has already
been done, so we can fill in their types as known, much like the type
of `+` is already known.

```
Subexpression     Preliminary type
-------------     ------------------------------------------
(apply g) 3       R 
(apply g)         S  
 apply            (U -> V) -> (U -> V)
       g          int -> int
          3       int
```

**2. Collect constraints.**

- `S = int -> R`
- `(U -> V) -> (U -> V) = (int -> int) -> S

**3. Solve constraints.**

Breaking down the last constraint, we have that `U = V = int`, and
that `S = U -> V`, hence `S = int -> int`.  Substituting that into
the first constraint, we have that `int -> int = int -> R`.  Therefore
`R = int`, so the type of `apply g 3` is `int`.

#### Example 4. 

```
# apply not false;;
- : bool = true
```

By essentially the same reasoning as in example 3, HM can infer that the
type of this expression is `bool`. This illustrates the polymorphism of
`apply`: because the type `(U -> V) -> (U -> V)` of
`apply` contains type variables, the function can be applied to any
arguments, so long as those arguments' types can be consistently
substituted for the type variables.

