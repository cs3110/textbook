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

# Beyond Lists

Functionals like map and fold are not restricted to lists. They make sense for
nearly any kind of data collection. For example, recall this tree
representation:

```{code-cell} ocaml
type 'a tree =
  | Leaf
  | Node of 'a * 'a tree * 'a tree
```

## Map on Trees

This one is easy.  All we have to do is apply the function `f` to the
value `v` at each node:

```{code-cell} ocaml
let rec map_tree f = function
  | Leaf -> Leaf
  | Node (v, l, r) -> Node (f v, map_tree f l, map_tree f r)
```

## Fold on Trees

This one is only a little harder. Let's develop a fold functional for `'a tree`
similar to our `fold_right` over `'a list`. One way to think of
`List.fold_right` would be that the `[]` value in the list gets replaced by the
`acc` argument, and each `::` constructor gets replaced by an application of the
`f` argument. For example, `[a; b; c]` is syntactic sugar for
`a :: (b :: (c :: []))`. So if we replace `[]` with `0` and `::` with `( + )`,
we get `a + (b + (c + 0))`. Along those lines, here's a way we could rewrite
`fold_right` that will help us think a little more clearly:

```{code-cell} ocaml
type 'a mylist =
  | Nil
  | Cons of 'a * 'a mylist

let rec fold_mylist f acc = function
  | Nil -> acc
  | Cons (h, t) -> f h (fold_mylist f acc t)
```

The algorithm is the same. All we've done is to change the definition of lists
to use constructors written with alphabetic characters instead of punctuation,
and to change the argument order of the fold function.

For trees, we'll want the initial value of `acc` to replace each `Leaf`
constructor, just like it replaced `[]` in lists. And we'll want each `Node`
constructor to be replaced by the operator. But now the operator will need to be
*ternary* instead of *binary*&mdash;that is, it will need to take three
arguments instead of two&mdash;because a tree node has a value, a left child,
and a right child, whereas a list cons had only a head and a tail.

Inspired by those observations, here is the fold function on trees:
```{code-cell} ocaml
let rec fold_tree f acc = function
  | Leaf -> acc
  | Node (v, l, r) -> f v (fold_tree f acc l) (fold_tree f acc r)
```
If you compare that function to `fold_mylist`, you'll note it very nearly
identical. There's just one more recursive call in the second pattern-matching
branch, corresponding to the one more occurrence of `'a tree` in the definition
of that type.

We can then use `fold_tree` to implement some of the tree functions we've
previously seen:
```{code-cell} ocaml
let size t = fold_tree (fun _ l r -> 1 + l + r) 0 t
let depth t = fold_tree (fun _ l r -> 1 + max l r) 0 t
let preorder t = fold_tree (fun x l r -> [x] @ l @ r) [] t
```

Why did we pick `fold_right` and not `fold_left` for this development? Because
`fold_left` is tail recursive, which is something we're never going to achieve
on binary trees. Suppose we process the left branch first; then we still have to
process the right branch before we can return. So there will always be work left
to do after a recursive call on one branch. Thus on trees an equivalent to
`fold_right` is the best which we can hope for.

The technique we used to derive `fold_tree` works for any OCaml variant type
`t`:

* Write a recursive `fold` function that takes in one argument for each
  constructor of `t`.

* That `fold` function matches against the constructors, calling itself
  recursively on any value of type `t` that it encounters.

* Use the appropriate argument of `fold` to combine the results of all recursive
  calls as well as all data not of type `t` at each constructor.

This technique constructs something called a *catamorphism*, aka a *generalized
fold operation*. To learn more about catamorphisms, take a course on category
theory.

## Filter on Trees

This one is perhaps the hardest to design.  The problem is: if we decide
to filter a node, what should we do with its children?

- We could recurse on the children. If after filtering them only one child
  remains, we could promote it in place of its parent. But what if both children
  remain, or neither? Then we'd somehow have to reshape the tree. Without
  knowing more about how the tree is intended to be used&mdash;that is, what
  kind of data it represents&mdash;we are stuck.

- Instead, we could just eliminate the children entirely. So the decision
  to filter a node means pruning the entire subtree rooted at that node.

The latter is easy to implement:

```{code-cell} ocaml
let rec filter_tree p = function
  | Leaf -> Leaf
  | Node (v, l, r) ->
    if p v then Node (v, filter_tree p l, filter_tree p r) else Leaf
```
