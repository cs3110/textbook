# Advanced Patterns

Here are some additional pattern forms that are useful:

* `p1 | ... | pn`:  an "or" pattern; matching against it succeeds if
  a match succeeds against any of the individual patterns `pi`, which
  are tried in order from left to right.  All the patterns must bind
  the same variables.
* `(p : t)`:  a pattern with an explicit type annotation.
* `c`:  here, `c` means any constant, such as integer literals, 
  string literals, and booleans.
* `'ch1'..'ch2'`:  here, `ch` means a character literal.  For example,
  `'A'..'Z'` matches any uppercase letter.
* `p when e`:  matches `p` but only if `e` evaluates to `true`.

You can read about [all the pattern forms][patterns] in the manual.

[patterns]: http://caml.inria.fr/pub/docs/manual-ocaml/patterns.html
