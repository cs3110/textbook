# Example: A Front-End for SimPL

As a demonstration of lexing and parsing, we'll now develop a front end
for SimPL using ocamllex and menhir.

Earlier, we already developed an AST type:
```
type bop = 
  | Add
  | Mult
  | Leq

type expr =
  | Var of string
  | Int of int
  | Bool of bool  
  | Binop of bop * expr * expr
  | Let of string * expr * expr
  | If of expr * expr * expr
```
Let's assume that code is in a file named `ast.ml`.

## Parsing with Menhir

Let's start with parsing, then return to lexing later.  We'll assume
all the Menhir code we write below is in a file named `parser.mly`.  The
`.mly` extension indicates that this file is intended as input
to Menhir.  (The 'y' alludes to yacc.)  This file contains
the *grammar definition* for the language we want to parse.
The syntax of grammar definitions is described by example below.
Be warned that it's maybe a little weird, but that's because
it's based on tools (like yacc) that were developed quite awhile ago.

Menhir will process that file and produce a file named `parser.ml`
as output; it contains an OCaml program that parses the language.
(There's nothing special about the name `parser` here; it's just
descriptive.)

There are four parts to a grammar definition: header, declarations, 
rules, and trailer.

**Header.** The *header* appears between `%{` and `%}`.  It is code that
will be copied literally into the generated `parser.ml`. Here we use it
just to open the `Ast` module so that, later on in the grammar
definition, we can write expressions like `Int i` instead of `Ast.Int
i`.  If we wanted we could also define some OCaml functions in the
header.

```
%{
open Ast
%}
```

**Declarations.** The *declarations* section begins by saying what the lexical
*tokens* of the language are. Here are the token declarations for SimPL:
```
%token <int> INT
%token <string> ID
%token TRUE
%token FALSE
%token LEQ
%token TIMES  
%token PLUS
%token LPAREN
%token RPAREN
%token LET
%token EQUALS
%token IN
%token IF
%token THEN
%token ELSE
%token EOF
```

Each of these is just a descriptive name for the token.  Nothing so far
says that `LPAREN` really corresponds to `(`, for example.  We'll take
care of that when we define the lexer.

The `EOF` token is a special *end-of-file* token that the lexer will
return when it comes to the end of the character stream.  At that point
we know the complete program has been read.

The tokens that have a `<type>` annotation appearing in them are
declaring that they will carry some additional data along with them.  In
the case of `INT`, that's an OCaml `int`.  In the case of `ID`, that's
an OCaml `string`.

After declaring the tokens, we have to provide some additional information
about *precedence* and *associativity*.  The following declarations say that
`PLUS` is left associative, `IN` is not associative, and `PLUS`
has higher precedence than `IN` (because `PLUS` appears on a line after `IN`).  

```
%nonassoc IN
%nonassoc ELSE
%left LEQ
%left PLUS
%left TIMES 
```

Because `PLUS` is left associative, `1 + 2 + 3` will parse as `(1 + 2) + 3` and
not as `1 + (2 + 3)`. Because `PLUS` has higher precedence than `IN`, the
expression `let x = 1 in x + 2` will parse as `let x = 1 in (x + 2)` 
and not as `(let x = 1 in x) + 2`.  The other declarations have similar effects.

Getting the precedence and associativity declarations correct is one 
of the trickier parts of developing a grammar definition.  It helps
to develop the grammar definition incrementally, adding just a couple
tokens (and their associated rules, discussed below) at a time to the language.
Menhir will let you know when you've added a token (and rule) for which
it is confused about what you intend the precedence and associativity 
should be.  Then you can add declarations and test to make sure you've
got them right.

After declaring associativity and precedence, we need to declare what
the starting point is for parsing the language.  The following
declaration says to start with a rule (defined below) named `prog`.
The declaration also says that parsing a `prog` will return an OCaml
value of type `Ast.expr`.

```
%start <Ast.expr> prog
```

Finally, `%%` ends the declarations section.

```
%%
```

**Rules.**
The *rules* section contains production rules that resemble BNF, 
although where in BNF we would write "::=" these rules simply write ":".
The format of a rule is
```
name:
    | production1 { action1 }
    | production2 { action2 }
    | ...
    ;
```	

The *production* is the sequence of *symbols* that the rule matches. 
A symbol is either a token or the name of another rule. 
The *action* is the OCaml value to return if a *match* occurs. 
Each production can *bind* the value carried by a symbol and use
that value in its action.  This is perhaps best understood by example,
so let's dive in.
   
The first rule, named `prog`, has just a single production.  It says
that a `prog` is an `expr` followed by `EOF`.
The first part of the production, `e=expr`, says to match an `expr` and bind
the resulting value to `e`.  The action simply says to return that value `e`.

```
prog:
	| e = expr; EOF { e }
	;
```


The second and final rule, named `expr`, has productions for all the expressions
in SimPL.

```
expr:
	| i = INT { Int i }
	| x = ID { Var x }
	| TRUE { Bool true }
	| FALSE { Bool false }
	| e1 = expr; LEQ; e2 = expr { Binop (Leq, e1, e2) }
	| e1 = expr; TIMES; e2 = expr { Binop (Mult, e1, e2) } 
	| e1 = expr; PLUS; e2 = expr { Binop (Add, e1, e2) }
	| LET; x = ID; EQUALS; e1 = expr; IN; e2 = expr { Let (x, e1, e2) }
	| IF; e1 = expr; THEN; e2 = expr; ELSE; e3 = expr { If (e1, e2, e3) }
	| LPAREN; e=expr; RPAREN {e} 
	;
```

- The first production, `i = INT`, says to match an `INT` token, bind the
  resulting OCaml `int` value to `i`, and return AST node `Int i`.

- The second production, `x = ID`, says to match an `ID` token, bind the
  resulting OCaml `string` value to `x`, and return AST node `Var x`.	
  
- The third and fourth productions match a `TRUE` or `FALSE` token
  and return the corresponding AST node.

- The fifth, sixth, and seventh productions handle binary operators.
  For example, `e1 = expr; PLUS; e2 = expr` says to match
  an `expr` followed by a `PLUS` token followed by another `expr`.
  The first `expr` is bound to `e1` and the second to `e2`.  The AST
  node returned is `Binop (Add, e1, e2)`.

- The eighth production, `LET; x = ID; EQUALS; e1 = expr; IN; e2 = expr`,
  says to match a `LET` token followed by an `ID` token followed by
  an `EQUALS` token followed by an `expr` followed by an `IN` token
  followed by another `expr`.  The string carried by the `ID` is bound
  to `x`, and the two expressions are bound to `e1` and `e2`.  The AST
  node returned is `Let (x, e1, e2)`.
  
- The last production, `LPAREN; e = expr; RPAREN` says to match an
  `LPAREN` token followed by an `expr` followed by an `RPAREN`.  The
  expression is bound to `e` and returned.
  
The final production might be surprising, because it was
not included in the BNF we wrote for SimPL.  That BNF was intended
to describe the *abstract syntax* of the language, so it did not
include the concrete details of how expressions can be grouped
with parentheses.  But the grammer definition we've been writing
does have to describe the *concrete syntax*, including details
like parentheses.
	
There can also be a *trailer* section after the rules, which like the header
is OCaml code that is copied directly into the output `parser.ml` file.

## Lexing with Ocamllex

Now let's see how the lexer generator is used.  A lot of it will feel
familiar from our discussion of the parser generator.

We'll assume all the ocamllex code we write below is in a file named
`lexer.mll`.  The `.mll` extension indicates that this file is intended
as input to ocamllex.  (The 'l' alludes to lexing.)  This file contains
the *lexer definition* for the language we want to lex.

Menhir will process that file and produce a file named `lexer.ml`
as output; it contains an OCaml program that lexes the language.
(There's nothing special about the name `lexer` here; it's just
descriptive.)

There are four parts to a lexer definition: header, identifiers, rules, and trailer.

**Header.**
The *header* appears between `{` and `}`.  It is code
that will simply be copied literally into the generated `lexer.ml`.

```
{
open Parser
}
```

Here, we've opened the `Parser` module, which is the code in `parser.ml`
that was produced by Menhir out of `parser.mly`.  The reason we open it
is so that we can use the token names declared in it, e.g., `TRUE`,
`LET`, and `INT`, inside our lexer definition.  Otherwise, we'd
have to write `Parser.TRUE`, etc.

**Identifiers.**
The next section of the lexer definition contains *identifiers*,
which are named regular expressions.  These will be used in the rules section, next.

Here are the identifiers we'll use with SimPL:
```
let white = [' ' '\t']+
let digit = ['0'-'9']
let int = '-'? digit+
let letter = ['a'-'z' 'A'-'Z']
let id = letter+
```

The regular expressions above are for whitespace (spaces and tabs),
digits (0 through 9), integers (nonempty sequences of digits, optionally
preceded by a minus sign), letters (a through z, and A through Z), and
SimPL variable names (nonempty sequences of letters) aka ids or
"identifiers"&mdash;though we're now using that word in two different
senses.

FYI, these aren't exactly the same as the OCaml definitions of integers
and identifiers.

The identifiers section actually isn't required; instead of writing
`white` in the rules we could just directly write the regular expression
for it.  But the identifiers help make the lexer definition more
self-documenting.

**Rules.**
The rules section of a lexer definition is written in a notation
that also resembles BNF.  A rule has the form
```
rule name =
  parse
  | regexp1 { action1 }
  | regexp2 { action2 }
  | ...  
```
Here, `rule` and `parse` are keywords. The lexer that is generated will
attempt to match against regular expressions in the order they are
listed. When a regular expression matches, the lexer produces the token
specified by its `action`.

Here is the (only) rule for the SimPL lexer:

```
rule read = 
  parse
  | white { read lexbuf }
  | "true" { TRUE }
  | "false" { FALSE }
  | "<=" { LEQ }
  | "*" { TIMES }
  | "+" { PLUS }
  | "(" { LPAREN }
  | ")" { RPAREN }
  | "let" { LET }
  | "=" { EQUALS }
  | "in" { IN }
  | "if" { IF }
  | "then" { THEN }
  | "else" { ELSE }
  | id { ID (Lexing.lexeme lexbuf) }
  | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | eof { EOF }
```

Most of the regular expressions and actions are self-explanatory, but a couple are not:

* The first, `white { read lexbuf }`, means that if whitespace is matched,
  instead of returning a token the lexer should just call the `read` rule
  again and return whatever token results.  In other words, whitespace
  will be skipped.
  
* The two for ids and ints use the expression `Lexing.lexeme lexbuf`.
  This calls a function `lexeme` defined in the `Lexing` module,
  and returns the string that matched the regular expression.  For example,
  in the `id` rule, it would return the sequence of upper and lower case
  letters that form the variable name.
  
* The `eof` regular expression is a special one that matches the end of
  the file (or string) being lexed.
  
Note that it's important that the `id` regular expression occur nearly
last in the list.  Otherwise, keywords like `true` and `if` would be lexed
as variable names rather than the `TRUE` and `IF` tokens.

## Generating the Parser and Lexer

## The Driver

```
(* Parse a string into an ast *)
let parse s =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast
```