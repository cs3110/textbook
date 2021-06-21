# Data

In this chapter, we'll examine some of OCaml's built-in data types, including
lists, variants, records, tuples, and options. Many of those are likely to feel
familiar from other programming languages. In particular,

- **lists** and **tuples**, might feel similar to Python; and

- **records** and **variants**, might feel similar to `struct` and `enum` types
  from C or Java.

Because of that familiarity, we call these *standard* data types. We'll learn
about *pattern matching*, which is a feature that's less likely to be familiar.

Almost immediately after we learn about lists, we'll pause our study of standard
data types to learn about unit testing in OCaml with OUnit, a unit testing
framework similar to those you might have used in other languages. OUnit relies
on lists, which is why we couldn't cover it before now.

Later in the chapter, we study some OCaml data types that are unlikely to be as
familiar from other languages. They include:

- **options**, which are loosely related to `null` in Java;

- **association lists**, which are an amazingly simple implementation
  of maps (aka dictionaries) based on lists and tuples;

- **algebraic data types**, which are arguably the most important
  kind of type in OCaml, and indeed are the power behind many
  of the other built-in types; and

- **exceptions**, which are a special kind of algebraic data type.
