# Sequencing of Effects

The semicolon operator is used to sequence effects, such as mutating
refs.  We've seen semicolon occur previously with printing.  Now that
we're studying mutability, it's time to treat it formally.

* **Syntax:** `e1; e2`

* **Dynamic semantics:** To evaluate `e1; e2`,

  - First evaluate `e1` to a value `v1`.  
  
  - Then evaluate `e2` to a value `v2`.
  
  - Return `v2`.  (`v1` is not used at all.)
  
  - If there are multiple expressions in a sequence, e.g., `e1; e2; ...; en`,
    then evaluate each one in order from left to right, returning only `vn`.
    Another way to think about this is that semicolon is right associative&mdash;for
    example `e1; e2; e3` is the same as `e1; (e2; e3))`.

* **Static semantics:**
  `e1; e2 : t` if `e1 : unit` and `e2 : t`.  Similarly, `e1; e2; ...; en : t` 
  if `e1 : unit`, `e2 : unit`, ... (i.e., all expressions except `en` have type `unit`), 
  and `en : t`.
  
The typing rule for semicolon is designed to prevent programmer mistakes.  For
example, a programmer who writes `2+3; 7` probably didn't mean to: there's
no reason to evaluate `2+3` then throw away the result and instead return `7`.
The compiler will give you a warning if you violate this particular typing rule.

To get rid of the warning (if you're sure that's what you need to do), 
there's a function `ignore : 'a -> unit` in the standard library. 
Using it, `ignore(2+3); 7` will compile without a warning.  Of course,
you could code up `ignore` yourself:  `let ignore _ = ()`.
