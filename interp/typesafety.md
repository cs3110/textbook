# Type Safety

What is the purpose of a type system?  There might be many, but
one of the primary purposes is to ensure that certain run-time
errors don't occur.  Now that we know how to formalize 
type systems with the `|-` relation and evaluation with the
`-->` relation, we can make that idea precise.

The goals of a language designer usually include ensuring that
these two properties, which establish a relationship between
`|-` and `-->`, both hold:

* **Progress:**  If an expression
  is well typed, then either it is already a value, or it can take at
  least one step.  We can formalize that as, "for all `e`, if there
  exists a `t` such that `{} |- e : t`, then `e` is a value, or there
  exists an `e'` such that `e --> e'`."
  
* **Preservation:**  If an expression is well typed,
  then if the expression steps, the new expression has the same type as
  the old expression.  Formally, "for all `e` and `t` such that
  `{} |- e : t`, if there exists an `e'` such that `e --> e'`, then
  `{} |- e' : t`."
  
Put together, progress plus preservation imply that that
evaluation of a well-typed expression can never *get stuck*,
meaning it reaches a non-value that cannot take a step.  This
property is known as *type safety*.

For example, `5 + true` would get stuck using the SimPL evaluation
relation, because the primitive `+` operation cannot accept
a Boolean as an operand.  But the SimPL type system won't accept
that program, thus saving us from ever reaching that situation.

Looking back at the SimPL we wrote, everywhere in the
implementation of `step` where we raised an exception was
a place where evaluation would get stuck.  But the type
system guarantees those exceptions will never occur.


