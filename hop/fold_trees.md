# Fold with Trees

Speaking of recursing other data structures, here's how we could program
a fold over a binary tree.  Here's our tree data structure:
```
type 'a tree = 
| Leaf 
| Node of 'a * 'a tree * 'a tree
```

Let's develop a fold functional for `'a tree` similar to our
`fold_right` over `'a list`. Recall what we said above: <i>"One way to
think of `fold_right` would be that the `[]` value in the list gets
replaced by `init`, and each `::` constructor gets replaced by `op`. For
example, `[a;b;c]` is just syntactic sugar for `a::(b::(c::[]))`. So if
we replace `[]` with `0` and `::` with `(+)`, we get `a+(b+(c+0))`."</i>
Here's a way we could rewrite `fold_right` that will help us think a little
more clearly:
```
type 'a list =
  | Nil 
  | Cons of 'a * 'a list

let rec foldlist init op = function
  | Nil -> init
  | Cons (h,t) -> op h (foldlist init op t) 
```
All we've done is to change the definition of lists to use constructors written
with alphabetic characters instead of punctuation, and to change the argument order 
of the fold function.

For trees, we'll want the initial value to replace each `Leaf`
constructor, just like it replaced `[]` in lists.  And we'll want each
`Node` constructor to be replaced by the operator.  But now the operator
will need to be *ternary* instead of *binary*&mdash;that is, it will
need to take three arguments instead of two&mdash;because a tree node
has a value, a left child, and a right child, whereas a list cons had
only a head and a tail.

Inspired by those observations, here is the fold function on trees:
```
let rec foldtree init op = function
  | Leaf -> init
  | Node (v,l,r) -> op v (foldtree init op l) (foldtree init op r)
```
If you compare that function to `foldlist`, you'll note it very nearly identical.
There's just one more recursive call in the second pattern-matching branch,
corresponding to the one more occurrence of `'a tree` in the definition of that type.

We can then use `foldtree` to implement some of the tree functions we've previously seen:
```
let size t = foldtree 0 (fun _ l r -> 1 + l + r) t
let depth t = foldtree 0 (fun _ l r -> 1 + max l r) t
let preorder t = foldtree [] (fun x l r -> [x] @ l @ r) t
```

