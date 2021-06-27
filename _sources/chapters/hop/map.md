---
jupytext:
  cell_metadata_filter: -all
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.10.3
kernelspec:
  display_name: OCaml
  language: OCaml
  name: ocaml-jupyter
---

# Map

Here are two functions we might want to write:
```{code-cell} ocaml
(** [add1 lst] adds 1 to each element of [lst] *)
let rec add1 = function
  | [] -> []
  | h :: t -> (h + 1) :: add1 t

let lst1 = add1 [1; 2; 3]
```

```{code-cell} ocaml
(** [concat_bang lst] concatenates "!" to each element of [lst] *)
let rec concat_bang = function
  | [] -> []
  | h :: t -> (h ^ "!") :: concat_bang t

let lst2 = concat_bang ["sweet"; "salty"]
```

There's a lot of similarity between those two functions:

- They both pattern match against a list.
- They both return the same value for the base case of the empty list.
- They both recurse on the tail in the case of a non-empty list.

In fact the only difference (other than their names) is what they do for the
head element: add versus concatenate. Let's rewrite the two functions to make
that difference even more explicit:

```{code-cell} ocaml
(** [add1 lst] adds 1 to each element of [lst] *)
let rec add1 = function
  | [] -> []
  | h :: t ->
    let f = fun x -> x + 1 in
    f h :: add1 t

(** [concat_bang lst] concatenates "!" to each element of [lst] *)
let rec concat_bang = function
  | [] -> []
  | h :: t ->
    let f = fun x -> x ^ "!" in
    f h :: concat_bang t
```

Now the only difference between the two functions (again, other than their
names) is the body of helper function `f`. Why repeat all that code when there's
such a small difference between the functions? We might as well *abstract* that
one helper function out from each main function and make it an argument:

```{code-cell} ocaml
let rec add1' f = function
  | [] -> []
  | h :: t -> f h :: add1' f t

(** [add1 lst] adds 1 to each element of [lst] *)
let add1 = add1' (fun x -> x + 1)

let rec concat_bang' f = function
  | [] -> []
  | h :: t -> f h :: concat_bang' f t

(** [concat_bang lst] concatenates "!" to each element of [lst] *)
let concat_bang = concat_bang' (fun x -> x ^ "3110")
```

But now there really is no difference at all between `add1'` and `concat_bang'`
except for their names. They are totally duplicated code. Even their types are
now the same, because nothing about them mentions integers or strings. We might
as well just keep only one of them and come up with a good new name for it. One
possibility could be `transform`, because they tranform a list by applying a
function to each element of the list:

```{code-cell} ocaml
let rec transform f = function
  | [] -> []
  | h :: t -> f h :: transform f t

(** [add1 lst] adds 1 to each element of [lst] *)
let add1 = transform (fun x -> x + 1)

(** [concat_bang lst] concatenates "!" to each element of [lst] *)
let concat_bang = transform (fun x -> x ^ "3110")
```

````{note}
Instead of
```ocaml
let add1 lst = transform (fun x -> x + 1) lst
```
above we wrote
```ocaml
let add1 = transform (fun x -> x + 1)
```
This is another way of being higher order, but it's one we already learned
about under the guise of partial application.  The latter way of writing
the function partially applies `transform` to just one of its two
arguments, thus returning a function.  That function is bound to the
name `add1`.
````

Indeed, the C++ library does call the equivalent function `transform`. But OCaml
and many other languages (including Java and Python) use the shorter word *map*,
in the mathematical sense of how a function maps an input to an output. So let's
make one final change to that name:

```{code-cell} ocaml
let rec map f = function
  | [] -> []
  | h :: t -> f h :: map f t

(** [add1 lst] adds 1 to each element of [lst] *)
let add1 = map (fun x -> x + 1)

(** [concat_bang lst] concatenates "!" to each element of [lst] *)
let concat_bang = map (fun x -> x ^ "3110")
```

We have now successfully applied the Abstraction Principle: the common structure
has been factored out. What's left clearly expresses the computation, at least
to the reader who is familiar with `map`, in a way that the original versions do
not as quickly make apparent.

## Side Effects

The `map` function exists already in OCaml's standard library as `List.map`, but
with one small difference from the implementation we discovered above.  First,
let's see what's potentially wrong with our own implementation, then we'll look
at the standard library's implementation.

We've seen before in our discussion of [exceptions](../data/exceptions) that the
OCaml language specification does not generally specify evaluation order of
subexpressions, and that the current language implementation generally evaluates
right-to-left. Because of that, the following (rather contrived) code actually
causes the list elements to be printed in what might seem like reverse order:

```{code-cell} ocaml
let p x = print_int x; print_newline(); x + 1

let lst = map p [1; 2]
```

Here's why:

- Expression `map p [1; 2]` evaluates to `p 1 :: map p [2]`.
- The right-hand side of that expression is then evaluated to
  `p 1 :: (p 2 :: map p [])`. The application of `p` to `1` has not
  yet occurred.
- The right-hand side of `::` is again evaluated next, yielding
  `p 1 :: (p 2 :: [])`.
- Then `p` is applied to `2`, and finally to `1`.

That is likely surprising to anyone who is predisposed to thinking that
evaluation would occur left-to-right.  The solution is to use a `let`
expression to cause the evaluation of the function application to occur
before the recursive call:

```{code-cell} ocaml
let rec map f = function
  | [] -> []
  | h :: t -> let h' = f h in h' :: map f t

let lst2 = map p [1; 2]
```

Here's why that works:

- Expression `map p [1; 2]` evaluates to `let h' = p 1 in h'' :: map p [2]`.
- The binding expression `p 1` is evaluated, causing `1` to be printed
  and `h'` to be bound to `2`.
- The body expression `h'' :: map p [2]` is then evaluated, which
  leads to `2` being printed next.

So that's how the standard library defines `List.map`. We should use it instead
of re-defining the function ourselves from now on. But it's good that we have
discovered the function "from scratch" as it were, and that if needed we could
quickly re-code it.

The bigger lesson to take away from this discussion is that when evaluation
order matters, we need to use `let` to ensure it. When does it matter? Only when
there are side effects. Printing and exceptions are the two we've seen so far.
Later we'll add mutability.

## Map and Tail Recursion

Astute readers will have noticed that the implementation of `map` is not tail
recursive. That is to some extent unavoidable. Here's a tempting but awful way
to create a tail-recursive version of it:

```{code-cell} ocaml
let rec map_tr_aux f acc = function
  | [] -> acc
  | h :: t -> map_tr_aux f (acc @ [f h]) t

let map_tr f = map_tr_aux f []

let lst = map_tr (fun x -> x + 1) [1; 2; 3]
```

To some extent that works: the output is correct, and `map_tr_aux` is tail
recursive. The subtle flaw is the subexpression `acc @ [f h]`. Recall that
append is a linear-time operation on singly-linked lists. That is, if there are
$n$ list elements then append takes time $O(n)$. So at each recursive call we
perform a $O(n)$ operation. And there will be $n$ recursive calls, one for each
element of the list. That's a total of $n \cdot O(n)$ work, which is $O(n^2)$.
So we achieved tail recursion, but at a high cost: what ought to be a
linear-time operation became quadratic time.

In an attempt to fix that, we could use the constant-time cons operation instead
of the linear-time append operation:

```{code-cell} ocaml
let rec map_tr_aux f acc = function
  | [] -> acc
  | h :: t -> map_tr_aux f (f h :: acc) t

let map_tr f = map_tr_aux f []

let lst = map_tr (fun x -> x + 1) [1; 2; 3]
```

And to some extent that works: it's tail recursive and linear time. The
not-so-subtle flaw this time is that the output is backwards. As we take each
element off the front of the input list, we put it on the front of the output
list, but that reverses their order.

```{note}
To understand why the reversal occurs, it might help to think of the input and
output lists as people standing in a queue:

- Input: Alice, Bob.
- Output: empty.

Then we remove Alice from the input and add her to the output:

- Input: Bob.
- Output: Alice.

Then we remove Bob from the input and add him to the output:

- Input: empty.
- Output: Bob, Alice.

The point is that with singly-linked lists, we can only operate on the head of
the list and still be constant time. We can't move Bob to the back of the output
without making him walk past Alice&mdash;and anyone else who might be standing
in the output.
```

For that reason, the standard library calls this function `List.rev_map`, that
is, a (tail-recursive) map function that returns its output in reverse order.

```{code-cell} ocaml
let rec rev_map_aux f acc = function
  | [] -> acc
  | h :: t -> rev_map_aux f (f h :: acc) t

let rev_map f = rev_map_aux f []

let lst = rev_map (fun x -> x + 1) [1; 2; 3]
```

If you want the output in the "right" order, that's easy: just apply `List.rev`
to it:

```{code-cell} ocaml
let lst = List.rev (List.rev_map (fun x -> x + 1) [1; 2; 3])
```

Since `List.rev` is both linear time and tail recursive, that yields a complete
solution. We get a linear-time and tail-recursive map computation. The expense
is that it requires two passes through the list: one to transform, the other to
reverse. We're not going to do better than this efficiency with a singly-linked
list. Of course, there are other data structures that implement lists, and we'll
come to those eventually. Meanwhile, recall that we generally don't have to
worry about tail recursion (which is to say, about stack space) until lists have
10,000 or more elements.

Why doesn't the standard library provide this all-in-one function? Maybe it will
someday if there's good enough reason. But you might discover in your own
programming there's not a lot of need for it. In many cases, we can either do
without the tail recursion, or be content with a reversed list.

The bigger lesson to take away from this discussion is that there can be a
tradeoff between time and space efficiency for recursive functions. By
attempting to make a function more space efficient (i.e., tail recursive), we
can accidentally make it asympotically less time efficient (i.e., quadratic
instead of linear), or if we're clever keep the asymptotic time efficiency the
same (i.e., linear) at the cost of a constant factor (i.e., processing twice).

## Map in Other Languages

We mentioned above that the idea of map exists in many programming languages.
Here's an example from Python:
```python
>>> print(list(map(lambda x: x + 1, [1, 2, 3])))
[2, 3, 4]
```
We have to use the `list` function to convert the result of the `map` back to a
list, because Python for sake of efficiency produces each element of the `map`
output as needed. Here again we see the theme of "when does it get evaluated?"
returning.

In Java, map is part of the `Stream` abstraction that was added in Java 8. Since
there isn't a built-in Java syntax for lists or streams, it's a little more
verbose to give an example. Here we use a factory method `Stream.of` to create a
stream:
```java
jshell> Stream.of(1, 2, 3).map(x -> x + 1).collect(Collectors.toList())
$1 ==> [2, 3, 4]
```
Like in the Python example, we have to use something to convert the stream back
into a list. In this case it's the `collect` method.