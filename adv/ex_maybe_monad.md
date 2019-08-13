# Example: The Maybe Monad

As we've seen before, sometimes functions are partial:  there is no
good output they can produce for some inputs.  For example,
the function `max_list : int list -> int` doesn't necessarily have
a good output value to return for the empty list.  One possibility
is to raise an exception.  Another possibility is to change the 
return type to be `int option`, and use `None` to represent the 
function's inability to produce an output.  In other words,
*maybe* the function produces an output, or *maybe* it is unable
to do so hence returns `None`.

As another example, consider the built-in OCaml integer division
function `(/) : int -> int -> int`.  If its second argument is zero, it
raises an exception.  Another possibility, though, would be to change
its type to be `(/) : int -> int -> int option`, and return `None`
whenever the divisor is zero.

Both of those examples involved changing the output type of a partial function
to be an option, thus making the function total.  That's a nice way to
program, until you start trying to combine many functions together.
For example, because all the integer operations&mdash;addition, subtraction,
division, multiplication, negation, etc.&mdash;expect an `int` (or two) as
input, you can form large expressions out of them.  But as soon as you change
the output type of division to be an option, you lose that *compositionality*.

Here's some code to make that idea concrete:
```
(* this works fine and evaluates to 3 *)
let x = 1 + (4 / 2)

let div (x:int) (y:int) : int option =
  if y=0 then None
  else Some (x / y)
  
let ( / ) = div

(* this won't type check *)
let x = 1 + (4 / 2)
```

The problem is that we can't add an `int` to an `int option`:  the addition
operator expects its second input to be of type `int`, but the new division
operator returns a value of type `int option`.

One possibility would be to re-code all the existing operators to
accept `int option` as input.  For example,
```
let plus_opt (x:int option) (y:int option) : int option =
  match x,y with
  | None, _ | _, None -> None
  | Some a, Some b -> Some (Pervasives.( + ) a b)
  
let ( + ) = plus_opt

let minus_opt (x:int option) (y:int option) : int option =
  match x,y with
  | None, _ | _, None -> None
  | Some a, Some b -> Some (Pervasives.( - ) a b)

let ( - ) = minus_opt

let mult_opt (x:int option) (y:int option) : int option =
  match x,y with
  | None, _ | _, None -> None
  | Some a, Some b -> Some (Pervasives.( * ) a b)

let ( * ) = mult_opt

let div_opt (x:int option) (y:int option) : int option =
  match x,y with
  | None, _ | _, None -> None
  | Some a, Some b -> 
    if b=0 then None else Some (Pervasives.( / ) a b)

let ( / ) = div_opt

(* does type check *)
let x = Some 1 + (Some 4 / Some 2)
```

But that's a tremendous amount of code duplication.  We ought to apply
the Abstraction Principle and deduplicate.  Three of the four operators
can be handled by abstracting a function that just does some pattern
matching to propagate `None`:

```
let propagate_none (op : int -> int -> int) (x : int option) (y : int option) =
  match x, y with
  | None, _ | _, None -> None
  | Some a, Some b -> Some (op a b)

let ( + ) = propagate_none Pervasives.( + )
let ( - ) = propagate_none Pervasives.( - )
let ( * ) = propagate_none Pervasives.( * )
```

Unfortunately, division is harder to deduplicate.  We can't just
pass `Pervasives.( / )` to `propagate_none`, because neither of those
functions will check to see whether the divisor is zero.
It would be nice if we could pass our function `div : int -> int -> int option` 
to `propagate_none`, but the return type of `div` makes that impossible.

So, let's rewrite `propagate_none` to accept an operator of the same type 
as `div`, which makes it easy to implement division:

```
let propagate_none 
  (op : int -> int -> int option) (x : int option) (y : int option)
=
  match x, y with
  | None, _ | _, None -> None
  | Some a, Some b -> op a b
  
let ( / ) = propagate_none div
```

Implementing the other three operations requires a little more work, because 
their return type is `int` not `int option`.  We need to wrap their
return value with `Some`:

```
let wrap_output (op : int -> int -> int) (x : int) (y : int) : int option =
  Some (op x y)
  
let ( + ) = propagate_none (wrap_output Pervasives.( + ))
let ( - ) = propagate_none (wrap_output Pervasives.( - ))
let ( * ) = propagate_none (wrap_output Pervasives.( * ))
```

Finally, we could re-implement `div` to use `wrap_output`:
```
let div (x:int) (y:int) : int option =
  if y = 0 then None
  else wrap_output Pervasives.( / ) x y

let ( / ) = propagate_none div
```

## Where's the Monad?

The work we just did was to take functions on
integers and tranform them into functions on values that maybe are
integers, but maybe are not&mdash;that is, values that are either
`Some i` where `i` is an integer, or are `None`.  We can think of these
"upgraded" functions as computations that *may have the effect of producing
nothing*.  They produce metaphorical boxes, and those boxes may be full of
something, or contain nothing.

There were two fundamental ideas in the code we just
wrote, which correspond to the monad operations of `return` and `bind`.

The first (which admittedly seems trivial) was upgrading a
value from `int` to `int option` by wrapping it with `Some`.  That's
what the body of `wrap_output` does.  We could expose that idea even
more clearly by defining the following function:
```
let return (x : int) : int option =
  Some x
```
This function has the *trivial effect* of putting a value into the metaphorical box.

The second idea was factoring out code to handle all the pattern matching against
`None`.  We had to upgrade functions whose inputs were of type `int` to instead 
accept inputs of type `int option`.  Here's that idea expressed as its own function:
```
let bind (x : int option) (op : int -> int option) : int option =
  match x with
  | None -> None
  | Some a -> op a

let (>>=) = bind
```
The `bind` function can be understood as doing the core work of upgrading `op`
from a function that accepts an `int` as input to a function that
accepts an `int option` as input. In fact, we could even write a function
that does that upgrading for us using `bind`:
```
let upgrade : (int -> int option) -> (int option -> int option) =
  fun (op : int -> int option) (x : int option) -> (x >>= op)
```
All those type annotations are intended to help the reader understand
the function.  Of course, it could be written much more simply as:
```
let upgrade op x = 
  x >>= op
```

Using just the `return` and `>>=` functions, we could re-implement the 
arithmetic operations from above.  For example, here are addition
and division:
```
let ( + ) (x : int option) (y : int option) : int option = 
  x >>= fun a ->
  y >>= fun b ->
  return (Pervasives.( + ) a b)

let ( - ) (x : int option) (y : int option) : int option = 
  x >>= fun a ->
  y >>= fun b ->
  return (Pervasives.( - ) a b)  

let ( * ) (x : int option) (y : int option) : int option = 
  x >>= fun a ->
  y >>= fun b ->
  return (Pervasives.( * ) a b)    
  
let ( / ) (x : int option) (y : int option) : int option = 
  x >>= fun a ->
  y >>= fun b ->
  if b = 0 then None else return (Pervasives.( / ) a b)  
```

Recall, from our discussion of the bind operator in Lwt, that
the syntax above should be parsed by your eye as

* take `x` and extract from it the value `a`,
* then take `y` and extract from it `b`,
* then use `a` and `b` to construct a return value.

Of course, there's still a fair amount of duplication going on there.
We can de-duplicate by using the same techniques as we did before:

```
let upgrade_binary op x y =
  x >>= fun a ->
  y >>= fun b ->
  op a b

let return_binary op x y = 
  return (op x y)

let ( + ) = upgrade_binary (return_binary Pervasives.( + ))
let ( - ) = upgrade_binary (return_binary Pervasives.( - ))
let ( * ) = upgrade_binary (return_binary Pervasives.( * ))
let ( / ) = upgrade_binary div
```

## The Maybe Monad

The monad we just discovered goes by several names:  the *maybe monad* (as in,
"maybe there's a value, maybe not"), the *error monad* (as in, "either there's a value
or an error", and error is represented by `None`&mdash;though some authors
would want an error monad to be able to represent multiple kinds of errors
rather than just collapse them all to `None`), and the *option monad*
(which is obvious).  

Here's an implementation of the monad signature for the maybe monad:

```
module Maybe : Monad = struct
  type 'a t = 'a option
  
  let return x = Some x
  
  let (>>=) m f = 
    match m with
    | None -> None
    | Some x -> f x
end 
```

These are the same implementations of `return` and `>>=` as we invented
above, but without the type annotations to force them to work only on integers.
Indeed, we never needed those annotations; they just helped make the 
code above a little clearer.

In practice the `return` function here is quite trivial and not really
necessary.  But the `>>=` operator can be used to replace a lot of boilerplate
pattern matching, as we saw in the final implementation of the arithmetic
operators above.  There's just a single pattern match, which is inside of `>>=`.
Compare that to the original implementations of `plus_opt`, etc., which 
had many pattern matches.

The result is we get code that (once you understand how to read the bind operator)
is easier to read and easier to maintain.