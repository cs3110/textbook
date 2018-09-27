# Laziness

The example with the Fibonacci sequence demonstrates that it would
be useful if the computation of a thunk happened only once:  when it is
forced, the resulting value could be remembered, and if the thunk is ever
forced again, that value could immediately be returned instead of
recomputing it.  That's the idea behind the OCaml `Lazy` module:
```
module Lazy :
  sig
    type 'a t = 'a lazy_t
    val force : 'a t -> 'a
  end
```
A value of type `'a Lazy.t` is a value of type `'a` whose computation
has been delayed.  Intuitively, the language is being *lazy* about
evaluating it: it won't be computed until specifically demanded.  The
way that demand is expressed with by *forcing* the evaluation with
`Lazy.force`, which takes the `'a Lazy.t` and causes the `'a` inside it
to finally be produced.  The first time a lazy value is forced, the
computation might take a long time.  But the result is *cached*
aka *memoized*, and any subsequent time that lazy value is forced,
the memoized result will be returned immediately.

(By the way, "memoized" really is the correct spelling of this term.
We didn't misspell "memorized", though it might look that way.)

The `Lazy` module doesn't contain a function that produces a
`'a Lazy.t`.  Instead, there is a keyword built-in to the OCaml
syntax that does it:  `lazy e`.

* **Syntax:**  `lazy e`

* **Static semantics:**  If `e:u`, then `lazy e : u Lazy.t`.

* **Dynamic semantics:**  `lazy e` does not evaluate `e` to a value.
  Instead it produced a *delayed value* aka *lazy value* that,
  when later forced, will evaluate `e` to a value `v` and return `v`.
  Moreover, that delayed value remembers that `v` is its forced
  value.  And if the delayed value is ever forced again, it immediately
  returns `v` instead of recomputing it.

To illustrate the use of lazy values, let's try computing the 30th
Fibonacci number using the definition of `fibs`, which we repeat
here for convenience:
```
let rec fibs =
  Cons(1, fun () ->
    Cons(1, fun () ->
      sum fibs (tl fibs)))
```

If we try to get the 30th Fibonacci number, it will take a long
time to compute:
```
let fib30long = take 30 fibs |> List.rev |> List.hd
```

But if we wrap evaluation of that with `lazy`, it will return
immediately, because the evaluation of that number has been
delayed:

```
let fib30lazy = lazy (take 30 fibs |> List.rev |> List.hd)
```

Later on we could force the evaluation of that lazy value,
and that will take a long time to compute, as did `fib30long`:
```
let fib30 = Lazy.force fib30lazy
```

But if we ever try to recompute that same lazy value, it will
return immediately, because the result has been memoized:
```
let fib30fast = Lazy.force fib30lazy
```

(The above examples will make much more sense if you try them
in utop rather than just reading these notes.)

Nonetheless, we still haven't totally succeeded.  That particular
computation of the 30th Fibonacci number has been memoized,
but if we later define some other computation of another
it won't be sped up the first time it's computed:
```
(* slow, even if [fib30lazy] was already forced *)
let fib29 = take 29 fibs |> List.rev |> List.hd
```
What we really want is to change the representation of streams itself
to make use of lazy values.

## Lazy Lists

Here's a representation for infinite lists using lazy values:
```
type 'a lazylist =
  Cons of 'a * 'a lazylist Lazy.t
```
We've gotten rid of the thunk, and instead are using a lazy value
as the tail of the lazy list.  If we ever want that tail to be computed,
we force it.

Now, assuming appropriate definitions for `hd`, `tl`, `sum`, and `take`
(left as an exercise for the reader),
we can define the Fibonacci sequence as a lazy list:
```
let rec fibs =
  Cons(1, lazy (
    Cons(1, lazy (
      sum (tl fibs) fibs))))

(* both fast *)
let fib30lazyfast = take 30 fibs
let fib29lazyfast = take 29 fibs
```

## Lazy vs. Eager 

OCaml's usual evaluation strategy is *eager* aka *strict*:
it always evaluate an argument before function application.
If you want a value to be computed lazily, you must specifically
request that with the `lazy` keyword.  Other function languages,
notably Haskell, are lazy by default.  Laziness can be
pleasant when programming with infinite data structures.
But lazy evaluation makes it harder to reason about space and time,
and it has bad interactions with side effects.  That's one reason
we use OCaml rather than Haskell in this course.
