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

# Advanced Pattern Matching

Here are some additional pattern forms that are useful:

* `p1 | ... | pn`: an "or" pattern; matching against it succeeds if a match
  succeeds against any of the individual patterns `pi`, which are tried in order
  from left to right. All the patterns must bind the same variables.

* `(p : t)`: a pattern with an explicit type annotation.

* `c`: here, `c` means any constant, such as integer literals, string literals,
  and booleans.

* `'ch1'..'ch2'`: here, `ch` means a character literal. For example, `'A'..'Z'`
  matches any uppercase letter.

* `p when e`: matches `p` but only if `e` evaluates to `true`.

You can read about [all the pattern forms][patterns] in the manual.

[patterns]: https://ocaml.org/manual/patterns.html

## Pattern Matching with Let

The syntax we've been using so far for let expressions is, in fact, a special
case of the full syntax that OCaml permits. That syntax is:
```ocaml
let p = e1 in e2
```
That is, the left-hand side of the binding may in fact be a pattern, not just an
identifier. Of course, variable identifiers are on our list of valid patterns,
so that's why the syntax we've studied so far is just a special case.

Given this syntax, we revisit the semantics of let expressions.

**Dynamic semantics.**

To evaluate `let p = e1 in e2`:

1. Evaluate `e1` to a value `v1`.

2. Match `v1` against pattern `p`. If it doesn't match, raise the exception
   `Match_failure`. Otherwise, if it does match, it produces a set $b$ of
   bindings.

3. Substitute those bindings $b$ in `e2`, yielding a new expression `e2'`.

4. Evaluate `e2'` to a value `v2`.

5. The result of evaluating the let expression is `v2`.

**Static semantics.**

* If all the following hold then `(let p = e1 in e2) : t2`:

  - `e1 : t1`

  - the pattern variables in `p` are `x1..xn`

  - `e2 : t2` under the assumption that for all `i` in `1..n` it holds that
    `xi : ti`,

**Let definitions.**

As before, a let definition can be understood as a let expression whose body has
not yet been given. So their syntax can be generalized to
```ocaml
let p = e
```
and their semantics follow from the semantics of let expressions, as before.

## Pattern Matching with Functions

The syntax we've been using so far for functions is also a special case of the
full syntax that OCaml permits. That syntax is:
```ocaml
let f p1 ... pn = e1 in e2   (* function as part of let expression *)
let f p1 ... pn = e          (* function definition at toplevel *)
fun p1 ... pn -> e           (* anonymous function *)
```

The truly primitive syntactic form we need to care about is `fun p -> e`. Let's
revisit the semantics of anonymous functions and their application with that
form; the changes to the other forms follow from those below:

**Static semantics.**

* Let `x1..xn` be the pattern variables appearing in `p`. If by assuming that
  `x1 : t1` and `x2 : t2` and ... and `xn : tn`, we can conclude that `p : t`
  and ` e :u`, then `fun p -> e : t -> u`.

* The type checking rule for application is unchanged.

**Dynamic semantics.**

* The evaluation rule for anonymous functions is unchanged.

* To evaluate `e0 e1`:

  1. Evaluate `e0` to an anonymous function `fun p -> e`, and
     evaluate `e1` to value `v1`.

  2. Match `v1` against pattern `p`. If it doesn't match, raise the exception
     `Match_failure`. Otherwise, if it does match, it produces a set $b$ of
     bindings.

  3. Substitute those bindings $b$ in `e`, yielding a new expression `e'`.

  4. Evaluate `e'` to a value `v`, which is the result of evaluating `e0 e1`.

## Pattern Matching Examples

{{ video_embed | replace("%%VID%%", "3ExRHHqfWm4")}}

Here are several ways to get a Pok&eacute;mon's hit points:
```{code-cell} ocaml
(* Pokemon types *)
type ptype = TNormal | TFire | TWater

(* A record to represent Pokemon *)
type mon = { name : string; hp : int; ptype : ptype }

(* OK *)
let get_hp m = match m with { name = n; hp = h; ptype = t } -> h

(* better *)
let get_hp m = match m with { name = _; hp = h; ptype = _ } -> h

(* better *)
let get_hp m = match m with { name; hp; ptype } -> hp

(* better *)
let get_hp m = match m with { hp } -> hp

(* best *)
let get_hp m = m.hp
```

Here's how to get the first and second components of a pair:
```{code-cell} ocaml
let fst (x, _) = x

let snd (_, y) = y
```
Both `fst` and `snd` are actually already defined for you in the standard
library.

Finally, here are several ways to get the 3rd component of a triple:
```{code-cell} ocaml
(* OK *)
let thrd t = match t with x, y, z -> z

(* good *)
let thrd t =
  let x, y, z = t in
  z

(* better *)
let thrd t =
  let _, _, z = t in
  z

(* best *)
let thrd (_, _, z) = z
```
The standard library does not define any functions for triples, quadruples, etc.
