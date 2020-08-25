# Backus-Naur Form

The standard way to describe the syntax of a language is with a
mathematical notation called *Backus-Naur form* (BNF), named for its
inventors, John Backus and Peter Naur. There are many variants of BNF. 
Here, we won't be too picky about adhering to one variant or another. 
Our goal is just to have a reasonably good notation for describing
language syntax.

BNF uses a set of *derivation rules* to describe the syntax of
a language.  Let's start with an example.  Here's the BNF
description of a tiny language of expressions that include just
the integers and addition:
```
e ::= i | e + e
i ::= <integers>
```
These rules say that an expression `e` is either an integer `i`,
or two expressions with the symbol `+` appearing between them.
The syntax of "integers" is left unspecified by these rules.

Each rule has the form
```
metavariable ::= symbols | ... | symbols
```
A *metavariable* is variable used in the BNF rules, rather than
a variable in the language being described.  The `::=` and `|`
that appear in the rules are *metasyntax*: BNF syntax used
to describe the language's syntax.  *Symbols* are sequences
that can include metavariables (such as `i` and `e`) as well as
tokens of the language (such as `+`).  Whitespace is not
relevant in these rules.

Sometimes we might want to easily refer to individual occurrences
of metavariables.  We do that by appending some distinguishing
mark to the metavariable(s).  For example, we could rewrite the 
first rule above as
```
e ::= i | e1 + e2
```
or as
```
e ::= i | e + e'
```
Now we can talk about `e2` or `e'` rather than having to say "the `e`
on the right-hand side of `+`".  

If the language itself contains either of the tokens `::=` or
`|`&mdash;and OCaml does contain the latter&mdash;then writing BNF can
become a little confusing.  Some BNF notations attempt to deal with that
by using additional delimiters to distinguish syntax from metasyntax. 
We will be more relaxed and assume that the reader can distinguish
them.

 
