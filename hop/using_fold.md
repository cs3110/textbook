# Using Fold to Implement Other Functions

Folding is so powerful that we can write many other
list functions in terms of `fold_left` or `fold_right`. For
example,

```
let length l = List.fold_left (fun a _ -> a+1) 0 l
let rev l = List.fold_left (fun a x -> x::a) [] l
let map f l = List.fold_right (fun x a -> (f x)::a) l []
let filter f l = List.fold_right (fun x a -> if f x then x::a else a) l []
```

At this point it begins to become debatable whether it's better to
express the computations above using folding or using the ways we have
already seen. Even for an experienced functional programmer,
understanding what a fold does can take longer than reading the naive
recursive implementation. If you peruse the standard library, you'll see
that none of the `List` module internally is implemented in terms of
folding, which is perhaps one comment on the readability of fold. On the
other hand, using fold ensures that the programmer doesn't accidentally
program the recursive traversal incorrectly.  And for a data structure
that's more complicated than lists, that robustness might be a win.
