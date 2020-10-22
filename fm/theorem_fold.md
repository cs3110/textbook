# A Theorem about Folding

When we studied `List.fold_left` and `List.fold_right`, we discussed how they
sometimes compute the same function, but in general do not.  For example,

```
  List.fold_left (+) 0 [1; 2; 3]  
= (((0 + 1) + 2) + 3
= 6
= 1 + (2 + (3 + 0))
= List.fold_right (+) lst [1;2;3]
```

but

```
  List.fold_left (-) 0 [1;2;3]
= (((0 - 1) - 2) - 3
= -6
<> 2
= 1 - (2 - (3 - 0))
= List.fold_right (-) lst [1;2;3]
```

Based on the equations above, it looks like the fact that `+` is commutative and
associative, whereas `-` is not, explains this difference between when the two
fold functions get the same answer.  Let's prove it!

First, recall the definitions of the fold functions:
```
let rec fold_left f acc lst =
  match lst with
  | [] -> acc
  | h :: t -> fold_left f (f acc h) t

let rec fold_right f lst acc =
  match lst with
  | [] -> acc
  | h :: t -> f h (fold_right f t acc)
```

Second, recall what it means for a function `f : 'a -> 'a` to be commutative
and associative:
```
Commutative:  forall x y, f x y = f y x  
Associative:  forall x y z, f x (f y z) = f (f x y) z
```
Those might look a little different than the normal formulations of those
properties, because we are using `f` as a prefix operator.  If we were to write
`f` instead as an infix operator `op`, they would look more familiar:
```
Commutative:  forall x y, x op y = y op x  
Associative:  forall x y z, x op (y op z) = (x op y) op z
```
When `f` is both commutative and associative we have this little interchange
lemma that lets us swap two arguments around:
```
Lemma (interchange): f x (f y z) = f y (f x z)

Proof:

  f x (f y z)
=   { associativity }
  f (f x y) z
=   { commutativity }
  f (f y x) z
=   { associativity }
  f y (f z x) 

QED
```

Now we're ready to state and prove the theorem.
```
Theorem: If f is commutative and associative, then
  forall lst acc, 
    fold_left f acc lst = fold_right f lst acc.

Proof: by induction on lst.
P(lst) = forall acc, 
  fold_left f acc lst = fold_right f lst acc

Base case: lst = []
Show: forall acc, 
  fold_left f acc [] = fold_right f [] acc

  fold_left f acc []
=   { evaluation }
  acc
=   { evaluation }
  fold_right f [] acc

Inductive case: lst = h :: t
IH: forall acc, 
  fold_left f acc t = fold_right f t acc
Show: forall acc, 
  fold_left f acc (h :: t) = fold_right f (h :: t) acc

  fold_left f acc (h :: t)
=   { evaluation }
  fold_left f (f acc h) t
=   { IH with acc := f acc h }
  fold_right f t (f acc h)

  fold_right f (h :: t) acc
=   { evaluation }
  f h (fold_right f t acc)
```

Now, it might seem as though we are stuck: the left and right sides of the
equality we want to show have failed to "meet in the middle."  But we're
actually in a similar situation to when we proved the correctness of `facti`
earlier: there's something (applying `f` to `h` and another argument) that we
want to push into the accumulator of that last line (so that we have `f acc h`).

Let's try proving that with its own lemma:
```
Lemma: forall lst acc x, 
  f x (fold_right f lst acc) = fold_right f lst (f acc x)

Proof: by induction on lst.
P(lst) = forall acc x, 
  f x (fold_right f lst acc) = fold_right f lst (f acc x)

Base case: lst = []
Show: forall acc x, 
  f x (fold_right f [] acc) = fold_right f [] (f acc x)

  f x (fold_right f [] acc)
=   { evaluation }
  f x acc

  fold_right f [] (f acc x)
=   { evaluation }
  f acc x
=   { commutativity of f }
  f x acc

Inductive case: lst = h :: t
IH: forall acc x, 
  f x (fold_right f t acc) = fold_right f t (f acc x)
Show: forall acc x, 
  f x (fold_right f (h :: t) acc) = fold_right f (h :: t) (f acc x)

  f x (fold_right f (h :: t) acc)
=  { evaluation }
  f x (f h (fold_right f t acc))
=  { interchange lemma }
  f h (f x (fold_right f t acc))
=  { IH }
  f h (fold_right f t (f acc x))

  fold_right f (h :: t) (f acc x)
=   { evaluation }
  f h (fold_right f t (f acc x))

QED
```

Now that the lemma is completed, we can resume the proof of the theorem.
We'll restart at the beginning of the inductive case:
```
Inductive case: lst = h :: t
IH: forall acc, 
  fold_left f acc t = fold_right f t acc
Show: forall acc, 
  fold_left f acc (h :: t) = fold_right f (h :: t) acc

  fold_left f acc (h :: t)
=   { evaluation }
  fold_left f (f acc h) t
=   { IH with acc := f acc h }
  fold_right f t (f acc h)

  fold_right f (h :: t) acc
=   { evaluation }
  f h (fold_right f t acc)
=   { lemma with x := h and lst := t }
  fold_right f t (f acc h)

QED
```

It took two inductions to prove the theorem, but we succeeded!  Now we know that
the behavior we observed with `+` wasn't a fluke: any commutative and
associative operator causes `fold_left` and `fold_right` to get the same answer.
