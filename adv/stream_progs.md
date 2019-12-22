# Programming with Streams

Let's write some functions that manipulate streams.  It will help to have
a notation for streams to use as part of documentation.  Let's use
`<a; b; c; ...>` to denote the stream that has elements `a`, `b`, and `c`
at its head, followed by infinitely many other elements.

Here are functions to square a stream, and to sum two streams:
```
(* [square <a;b;c;...>] is [<a*a;b*b;c*c;...]. *)
let rec square (Cons (h, tf)) =
  Cons (h*h, fun () -> square (tf ()))

(* [sum <a1; a2; a3; ...> <b1; b2; b3; ...>] is
 * [<a1+b1; a2+b2; a3+b3; ...>] *)
let rec sum (Cons (h1, tf1)) (Cons (h2, tf2)) =
  Cons (h1+h2, fun () -> sum (tf1 ()) (tf2 ()))
```

Their types are:
```
val square : int stream -> int stream
val sum : int stream -> int stream -> int stream
```

Note how the basic template for defining both functions is the same:

* Pattern match against the input stream(s), which must be `Cons`
  of a head and a tail function (a thunk).

* Construct a stream as the output, which must be `Cons` of a new
  head and a new tail function (a thunk).

* In constructing the new tail function, delay the evaluation of the
  tail by immediately starting with `fun () -> ...`.

* Inside the body of that thunk, recursively apply the function
  being defined (square or sum) to the result of forcing a thunk (or
  thunks) to evaluate.

Of course, squaring and summing are just two possible ways of mapping
a function across a stream or streams.  That suggests we could write
a higher-order map function, much like for lists:

```
(* [map f <a;b;c;...>] is [<f a; f b; f c; ...>] *)
let rec map f (Cons (h, tf)) =
  Cons (f h, fun () -> map f (tf ()))

(* [map2 f <a1;b1;c1;...> <a2;b2;c2;...>] is
 * [<f a1 b1; f a2 b2; f a3 b3; ...>] *)
let rec map2 f (Cons (h1, tf1)) (Cons (h2, tf2)) =
  Cons (f h1 h2, fun () -> map2 f (tf1 ()) (tf2 ()))

let square' = map (fun n -> n*n)
let sum' = map2 (+)
```

And their types are as we would expect:
```
val map : ('a -> 'b) -> 'a stream -> 'b stream
val map2 : ('a -> 'b -> 'c) -> 'a stream -> 'b stream -> 'c stream
val square' : int stream -> int stream
val sum' : int stream -> int stream -> int stream
```

Now that we have a map function for streams, we can successfully define `nats`
in one of the clever ways we originally attempted:
```
# let rec nats = Cons(0, fun () -> map (fun x -> x+1) nats);;
val nats : int stream = Cons (0, <fun>)

# take 10 nats;;
- : int list = [0; 1; 2; 3; 4; 5; 6; 7; 8; 9]
```

Why does this work?  Intuitively, `nats` is `<0; 1; 2; 3; ...>`, so
mapping the increment function over `nats` is `<1; 2; 3; 4; ...>`.
If we cons `0` onto the beginning of `<1; 2; 3; 4; ...>`, we get
`<0; 1; 2; 3; ...>`, as desired.  The recursive value definition is
permitted, because we never attempt to use `nats` until after its definition
is finished.  In particular, the thunk delays `nats` from being
evaluated on the right-hand side of the definition.

Here's another clever definition.  Consider the Fibonacci sequence
`<1; 1; 2; 3; 5; 8; ...>`.  If we take the tail of it, we get
`<1; 2; 3; 5; 8; 13; ...>`.  If we sum those two streams, we get
`<2; 3; 5; 8; 13; 21; ...>`.  That's nothing other than the tail
of the tail of the Fibonacci sequence.  So if we were to prepend
`[1; 1]` to it, we'd have the actual Fibonacci sequence.  That's
the intuition behind this definition:
```
let rec fibs =
  Cons(1, fun () ->
    Cons(1, fun () ->
      sum fibs (tl fibs)))
```

And it works!
```
# take 10 fibs;;
- : int list = [1; 1; 2; 3; 5; 8; 13; 21; 34; 55]
```

Unfortunately, it's highly inefficient.  Every time we force the computation
of the next element, it required recomputing all the previous elements, twice:
once for `fibs` and once for `tl fibs` in the last line of the definition.
By the time we get up to the 30th number, the computation is noticeably slow;
by the time of the 100th, it seems to last forever.

Could we do better?  Yes, with a little help from a new language feature: laziness.
We discuss it, next.

