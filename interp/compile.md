# Compilation

A skilled artisan must understand the tools with which they work.
A carpenter needs to understand saws and planes.  A chef needs
to understand knives and pots.  A programmer, among other tools,
needs to understand the compilers that implement the programming
languages they use.

A full understanding of compilation requires a full course or two.
CS 4120 covers compilers at the undergrad level, and we used to
have a grad-level course (CS 612) on *optimizing compilers*, 
which produce high performance code.

In 3110, we're going to take a brief look at how to implement
programming languages.  The goal is to understand some of the
basic implementation techniques, so as to demystify the
tools you're using.  Although you might never need to implement
a full general-purpose programming language, it's highly likely
that at some point in your career you will want to design and 
implement some small, special-purpose language.  Sometimes
those are called *domain-specific languages* (DSLs).  What
we cover here should help you with that task.

## Compilers and Interpreters

A *compiler* is a program that implements a programming language.
So is an *interpreter*.  But they differ in their implementation 
strategy.

A compiler's primary task is *translation*.  It takes as input 
a *source program* and produces as output a *target program*.
The source program is typically expressed in a high-level language,
such as Java or OCaml.  The target program is typically expressed 
in a low-level language, such as MIPS or x86 assembly.  Then
the compiler's job is done, and it is no longer needed.  Later
the OS helps to load and execute the target program. Typically,
a compiler results in higher-performance implementations.
  
An interpreter's primary task is *execution*.  It takes as input
a source program and directly executes that program without
producing any target program.  The OS actually loads and
executes the interpreter, and the interpreter is then responsible
for executing the program.  Typically, an interpreter is easier
to implement than a compiler.

It's also possible to implement a language using a mixture of 
compilation and interpretation.  The most common example of that
involves *virtual machines* that execute *bytecode*, such as the 
Java Virtual Machine (JVM) or the OCaml virtual machine (which 
used to be called the Zinc Machine).  With this strategy,
a compiler translates the source language into bytecode, and the virtual
machine interprets the bytecode.  

High-performance virtual machines, such as Java's HotSpot, take this a
step further and embed a compiler inside the virtual machine.  When the
machine notices that a piece of bytecode is being interpreted
frequently, it uses the compiler to translate that bytecode into the
language of the machine (e.g., x86) on which the machine is running. 
This is called *just-in-time compilation* (JIT), because code is being
compiled just before it is executed.

## Compilation Phases

A compiler goes through several phases as it translates a program:

**Lexing.** During lexing, the compiler transforms the original source code
of the program from a sequence of characters to a sequence of
*tokens*.  Tokens are adjacent characters that have some meaning
when grouped together.  You might think of them analogously to
words in a natural language.  Indeed, keywords such as `if` and 
`match` would be tokens in OCaml.  So would constants such as
`42` and `"hello"`, variable names such as `x` and `lst`, and 
punctuation such as `(`, `)`, and `->`.  Lexing typically removes
whitespace, because it is no longer needed once the tokens
have been identified.  (Though in a whitespace-sensitive language
like Python, it would need to be preserved.)
  
**Parsing.** During parsing, the compiler transforms the sequence of tokens
into a tree called the *abstract syntax tree* (AST).  As the name
suggests, this tree abstracts from the *concrete syntax* of the
language.  Recall that abstraction can mean "forgetting about details."
The AST typically forgets about concrete details. For example:

* In `1 + (2 + 3)` the parentheses group the right-hand addition operation,
  indicating it should be evaluated first.  A tree can represent that
  as follows:
  ```
     +
    / \
   1   +
      / \
     2   3
  ```
  Parentheses are no longer needed, because the structure of the tree encodes them.

* In `[1; 2; 3]`, the square brackets delineate the beginning and end of the
  list, and the semicolons separate the list elements.   A tree could represent
  that as a node with several children:
  ```
     list
    /  |  \
   1   2   3
  ```
  The brackets and semicolons are no longer needed.
  
* In `fun x -> 42`, the `fun` keyword and `->` punctuation mark separate the
  arguments and body of the function from the surrounding code.  A tree
  can represent that as a node with two children:
  ```
    function
    /     \
   x       42
  ```
  The keyword and punctuation are no longer needed.

An AST thus represents the structure of a program at a level that is easier
for the compiler writer to manipulate.  

**Semantic analysis.**  During semantic analysis, the compiler checks
to see whether the program is meaningful according to the rules of the
language that the compiler is implementing.  The most common kind of
semantic analysis is type checking:  the compiler analyzes the types of
all the expressions that appear in the program to see whether there is a
type error or not.  Type checking typically requires producing a data
structure called a *symbol table* that maps identifiers (e.g., variable
names) to their types.  As a new scope is entered, the symbol table is
extended with new bindings that might shadow old bindings; and as the
scope is exited, the new bindings are removed, thus restoring the old
bindings.  So a symbol table blends features of a dictionary and a stack
data structure.

Besides type checking, there are other kinds of semantic analysis.
Examples include the following:

* checking whether the branches of an OCaml pattern match are exhaustive,
* checking whether a C `break` keyword occurs within the body of a loop, and
* checking whether a Java field marked `final` has been initialized by the
  end of a constructor.
  
You can think of parsing as "checking to see whether a program
is meaningful"&mdash;which is how we just defined semantic analysis.
So the distinction between parsing and semantic analysis is more about
convenience: parsing does enough work to implement the production of an 
AST, and semantic analysis does the rest of the work.  

Sometimes semantic analysis is even necessary to fully determine what the
AST should be!  Consider, for example, the expression
`(foo) - bar` in a C-like language.  It might be:

* the unary negation of a variable `bar`, cast to the type `foo`, or
* the binary subtraction operation with operands `foo` and `bar`, where
  the parentheses were gratuitous.

Until enough semantic analysis has been done to figure out whether `foo`
is a variable name or a type name, the compiler doesn't know which AST
to generate.  In such situations, the parser typically produces an
AST in which some tree nodes represent the ambiguous syntax, then 
the semantic analysis phase rewrites the tree to be unambiguous.

**Translation to intermediate representation.**
After semantic analysis, a compiler *could* immediately translate the
AST (augmented with symbol tables) into the target language.  But
if the same compiler wanted to produce output for multiple targets
(e.g., for x86 and ARM and MIPS), that would require defining
a translation from the AST to each of the targets.  In practice,
compilers typically don't do that.  Instead, they first translate
the AST to an intermediate representation (IR).  Think of the IR
as a kind of abstraction of many assembly languages.  Many source
languages (e.g., C, Java, OCaml) could be translated to the same IR, 
and from that IR, many target language outputs (e.g., x86, ARM, MIPS)
could be produced.

An IR language typically has *abstract machine instructions* that
accomplish conceptually simple tasks:  loading from or storing to memory, 
performing binary operations, calling and returning, and jumping to
other instructions.  The abstract machine typically has an unbounded
number of registers available for use, much like a source program
can have an unbounded number of variables.  Real machines, however,
have a finite number of registers, which is one way in which the IR
is an abstraction.

**Target code generation.**
The final phase of compilation is to generate target code from the IR.
This phase typically involves selecting concrete machine instructions
(such as x86 opcodes), and determining which variables will be stored
in memory (which is slow to access) vs. processor registers (which
are fast to access but limited in number).  As part of code generation,
a compiler therefore attempts to *optimize* the performance of the
target code.  Some examples of optimizations include:

* eliminating array bounds checks, if they are provably guaranteed to succeed;
* eliminating redundant computations;
* replacing a function call with the body of the function itself, suitably
  instantiated on the arguments, to eliminate the overhead of calling and returning;
  and
* re-ordering machine instructions so that (e.g.) slow reads from memory are begun
  before their results are needed, and doing other instructions in the meanwhile
  that do not need the result of the read.

## Groups of Phases

The phases of compilation can be grouped into two or three pieces:

* The *front end* of the compiler does lexing, parsing, and semantic analysis.
  It produces an AST and associated symbol tables.  It tranforms the AST into
  an IR.
  
* The *middle end* (if it exists) of the compiler operates on the IR.  Usually
  this involves performing optimizations that are independent of the target
  language.
  
* The *back end* of the compiler does code generation, including further
  optimization.

## Interpretation Phases

An interpreter works like the front (and possibly middle) end of a compiler.
That is, an interpreter does lexing, parsing, and semantic analysis.  It might
then immediately begin executing the AST, or it might transform the AST into
an IR and begin executing the IR.

In the rest of this chapter, we are going to focus on interpreters.
We'll ignore IRs and code generation, and instead study how to
directly execute the AST.
