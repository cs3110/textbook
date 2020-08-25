# Pipelining

Suppose we wanted to compute the sum of squares of the numbers from 0 up to $$n$$.
How might we go about it?  Of course (math being the best form of optimization),
the most efficient way would be a closed-form formula: 

$$
\frac{n (n+1) (2n+1)}{6}
$$

But let's imagine you've forgotten that formula.
In an imperative language you might use a for loop:
```
# Python
def sum_sq(n):
	sum = 0
	for i in range(0,n):
		sum += i*i
	return sum
```
The equivalent recursive code in OCaml would be:
```
let sum_sq n =
  let rec loop i sum =
    if i>n then sum
    else loop (i+1) (sum + i*i)
  in loop 0 0
```

Another, clearer way of producing the same result in OCaml uses higher-order
functions and the pipeline operator:
```
let square x = x*x
let sum = List.fold_left (+) 0
       
let sum_sq n =
  0--n                (* [0;1;2;...;n]   *)
  |> List.map square  (* [0;1;4;...;n*n] *)
  |> sum              (*  0+1+4+...+n*n  *)
```
The function `sum_sq` first constructs a list containing all the numbers `0..n`.
Then it uses the pipeline operator `|>` to pass that list through `List.map square`,
which squares every element.  Then the resulting list is pipelined through
`sum`, which adds all the elements together. 

Pipelining with lists and other data structures is quite idiomatic.  The other
alternatives that you might consider are somewhat uglier:
```
(* worse: a lot of extra let..in syntax *)
let sum_sq n =
  let l = 0--n in
  let sq_l = List.map square l in
  sum sq_l
  
(* maybe worse:  have to read the function applications from right to left
 * rather than top to bottom *)
let sum_sq n =
  sum (List.map square (0--n))
```

We could improve our code a little further by using `List.rev_map` instead
of `List.map`.  `List.rev_map` is a tail-recursive version of `map` that
reverses the order of the list.  Since `(+)` is associative and commutative, we don't
mind the list being reversed.
```
let sum_sq n =
  0--n                    (* [0;1;2;...;n]   *)
  |> List.rev_map square  (* [n*n;...;4;1;0] *)
  |> sum                  (*  n*n+...+4+1+0  *)
```
