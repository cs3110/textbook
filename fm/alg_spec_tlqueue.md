# Example: Two-list Queues

Here is our old friend, the two-list queue:
```
module TwoListQueue = struct
  (* AF: (f, b) represents the queue f @ (List.rev b).
     RI: given (f, b), if f is empty then b is empty. *)
  type 'a t = 'a list * 'a list

  let empty = [], []

  let is_empty (f, _) = 
    f = []

  let enq x (f, b) =
    if f = [] then [x], []
    else f, x :: b

  let front (f, _) = 
    List.hd f 

  let deq (f, b) =
    match List.tl f with
    | [] -> List.rev b, []
    | t -> t, b
end
```
This implementation is superficially different from the previous implementation
we gave, in that it uses pairs instead of records, and it in-lines the `norm`
function.  These changes will make our proofs a little easier.

Is this implementation correct?  We need only verify the equations to find out.
Here they are again, for reference.

```
1.  is_empty empty = true
2.  is_empty (enq x q) = false
3a. front (enq x q) = x            if is_empty q = true
3b. front (enq x q) = front q      if is_empty q = false
4a. deq (enq x q) = empty          if is_empty q = true
4b. deq (enq x q) = enq x (deq q)  if is_empty q = false
```

First, a lemma:
```
Lemma:  if is_empty q = true, then q = empty.
Proof:  Since is_empty q = true, it must be that q = (f, b) and f = [].
By the RI, it must also be that b = [].  Thus q = ([], []) = empty.
QED
```

Verifying 1:
```
  is_empty empty
=   { eval empty }
  is_empty ([], [])
=   { eval is_empty }
  [] = []
=   { eval = }
  true
```

Verifying 2:
```
  is_empty (enq x q) = false
=   { eval enq }
  is_empty (if f = [] then [x], [] else f, x :: b)

case analysis: f = []

  is_empty (if f = [] then [x], [] else f, x :: b)
=   { eval if, f = [] }
  is_empty ([x], [])
=   { eval is_empty }
  [x] = []
=   { eval = }
  false

case analysis: f = h :: t

  is_empty (if f = [] then [x], [] else f, x :: b)
=   { eval if, f = h :: t }
  is_empty (h :: t, x :: b)
=   { eval is_empty }
  h :: t = []
=   { eval = }
  false
```

Verifying 3a:
```
  front (enq x q) = x
=   { emptiness lemma }
  front (enq x ([], []))
=   { eval enq }
  front ([x], [])
=   { eval front }
  x
```

Verifying 3b:
```
  front (enq x q)
=   { rewrite q as (h :: t, b), because q is not empty }
  front (enq x (h :: t, b))
=   { eval enq }
  front (h :: t, x :: b)
=   { eval front }
  h

  front q
=   { rewrite q as (h :: t, b), because q is not empty }
  front (h :: t, b)
=   { eval front }
  h
```

Verifying 4a:
```
  deq (enq x q)
=   { emptiness lemma }
  deq (enq x ([], []))
=   { eval enq }
  deq ([x], [])
=   { eval deq }
  List.rev [], []
=   { eval rev }
  [], []
=   { eval empty }
  empty
```

Verifying 4b:
```
Show: deq (enq x q) = enq x (deq q)  assuming is_empty q = false.
Proof: Since is_empty q = false, q must be (h :: t, b).

Case analysis:  t = [], b = []

  deq (enq x q)
=   { rewriting q as ([h], []) }
  deq (enq x ([h], []))
=   { eval enq }
  deq ([h], [x])
=   { eval deq }
  List.rev [x], []
=   { eval rev }
  [x], []

  enq x (deq q)
=   { rewriting q as ([h], []) }
  enq x (deq ([h], []))
=   { eval deq }
  enq x (List.rev [], [])
=   { eval rev }
  enq x ([], [])
=   { eval enq }
  [x], []

Case analysis:  t = [], b = h' :: t'

  deq (enq x q) 
=   { rewriting q as ([h], h' :: t') }
  deq (enq x ([h], h' :: t'))
=   { eval enq }
  deq ([h], x :: h' :: t')
=   { eval deq }
  List.rev (x :: h' :: t'), []

  enq x (deq q)
=   { rewriting q as ([h], h' :: t') }
  enq x (deq ([h], h' :: t'))
=   { eval deq }
  enq x (List.rev (h' :: t'), [])
=   { eval enq }
  (List.rev (h' :: t'), [x])

STUCK
```

Wait, we just got stuck!  `List.rev (x :: h' :: t'), []` and 
`(List.rev (h' :: t'), [x])` are not the same.  But, abstractly, they do
represent the same queue: `(List.rev t') @ [h'; x]`.  We need to allow
an additional equation for the representation type:
```
e = e'   if  AF(e) = AF(e')
```

Using that additional equation, we can continue:
```
  (List.rev (h' :: t'), [x])
=   { AF equation }
  List.rev (x :: h' :: t'), []


The AF equation holds because:

  List.rev (h' :: t') @ [x]
=   { eval rev }
  List.rev (h' :: t') @ List.rev [x]
=   { rev distributes over @, an exercise in the previous lecture }
  List.rev ([x] @ (h' :: t'))
=   { eval @ }
  List.rev (x :: h' :: t'))
=   { lst @ [] = lst, an exercise in the previous lecture }
  List.rev (x :: h' :: t') @ []

Case analysis:  t = h' :: t'

  deq (enq x q)
=   { rewriting q as (h :: h' :: t', b) }
  deq (enq x (h :: h' :: t', b))
=   { eval enq }
  deq (h :: h' :: t, x :: b)
=   { eval deq }
  h' :: t, x :: b

  enq x (deq q)
=   { rewriting q as (h :: h' :: t', b) }
  enq x (deq (h :: h' :: t', b))
=   { eval deq }
  enq x (h' :: t', b)
=   { eval enq }
  h' :: t', x :: b

QED
```

That concludes our verification of the two-list queue.  Note that
we had to add the extra equation involving the abstraction function
to get the proofs to go through:
```
e = e'   if  AF(e) = AF(e')
```
and that we made use of the RI during the proof.  The AF and RI
really are important!
