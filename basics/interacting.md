# Interacting with OCaml

The *toplevel* is like a calculator or command-line interface to
OCaml. It's similar to DrJava, if you used that in CS 2110, or to the
interactive Python interpreter, if you used that in CS 1110.  It's
handy for trying out small pieces of code without going to the trouble
of launching the OCaml compiler. But don't get too reliant on it,
because creating, compiling, and testing large programs will require
more powerful tools. Some other languages would call the toplevel a
*REPL*, which stands for read-eval-print-loop: it reads programmer
input, evaluates it, prints the result, and then repeats.

In a terminal window, type `utop` to start the toplevel. Press
Control-D to exit the toplevel. You can also enter `#quit;;` and press
return.  Note that you must type the `#` there: it is in addition to
the `#` prompt you already see.


## Types and values

You can enter expressions into the OCaml toplevel.  End an expression with
a double semi-colon `;;` and press the return key.  OCaml will then evaluate
the expression, tell you the resulting value, and the value's type.  For example:

```
# 42;;
- : int = 42
```

Let's dissect that response from utop, reading right to left:

* `42` is the value.
* `int` is the type of the value.
* The value was not given a name, hence the symbol `-`.

You can bind values to names with a `let` definition, as follows:

```
# let x = 42;;
val x : int = 42
```

Again, let's dissect that response, this time reading left to right:

* A value was bound to a name, hence the `val` keyword.
* `x` is the name to which the value was bound.
* `int` is the type of the value.
* `42` is the value.

You can pronounce the entire output as "`x` has type `int` and equals `42`."

## Functions

A function can be defined at the toplevel using syntax like this:

```
# let increment x = x+1;;
val increment : int -> int = <fun>
```

Let's dissect that response:

* `increment` is the identifier to which the value was bound.
* `int -> int` is the type of the value.  This is the type of functions
  that take an `int` as input and produce an `int` as output.  Think of the
  arrow `->` as a kind of visual metaphor for the transformation of one value
  into another value&mdash;which is what functions do.
* The value is a function, which the toplevel chooses not to print (because
  it has now been compiled and has a representation in memory that isn't
  easily amenable to pretty printing).  Instead, the toplevel prints
  `<fun>`, which is just a placeholder to indicate that there is some
  unprintable function value.  **Important note: `<fun>` itself is not a value.**

You can "call" functions with syntax like this:

```
# increment 0;;
- : int = 1
# increment(21);;
- : int = 22
# increment (increment 5);;
- : int = 7
```

But in OCaml the usual vocabulary is that we "apply" the function rather than "call" it.

Note how OCaml is flexible about whether you write the parentheses or not, and
whether you write whitespace or not.  One of the challenges of first
learning OCaml can be figuring out when parentheses are actually required.
So if you find yourself having problems with syntax errors, one strategy
is to try adding some parentheses.

## Storing code in files

Using OCaml as a kind of interactive calculator can be fun, but we won't get
very far with writing large programs that way.  We need to store code in files instead.

Open a terminal and use a text editor to create a file called
`hello.ml`.  Enter the following code into the file:

```
let _ = print_endline "Hello world!"
```

**Important note: there is no double semicolon `;;` at the end of that line
of code.** The double semicolon is strictly for interactive sessions in
the toplevel, so that the toplevel knows you are done entering a piece
of code.  There's no reason to write it in a .ml file, and
we consider it mildly bad style to do so.  

The `let _ =` above means that we don't care to give a name (hence
the "blank" or underscore) to code on the right-hand side of the
`=`.

Save the file and return to the command line.  Compile the code:

```
$ ocamlc -o hello.byte hello.ml
```

The compiler is named `ocamlc`.  The `-o hello.byte` option says to name the
output executable `hello.byte`.  The executable contains compiled OCaml
bytecode. In addition, two other files are produced, `hello.cmi` and
`hello.cmo`.  We don't need to be concerned with those files for now.
Run the executable:

```
$ ./hello.byte
```

It should print `Hello world!` and terminate.

Now change the string that is printed to something of your choice.  Save the file,
recompile, and rerun.  Try making the code print multiple lines.

This edit-compile-run cycle between the editor and the command line is something that
might feel unfamiliar if you're used to working inside IDEs like Eclipse.  Don't worry;
it will soon become second nature.

Running the compiler directly is good to know how to do, but in larger projects,
we want to use the OCaml build system to automatically find and link in libraries.
Let's try using it:

```
$ ocamlbuild hello.byte
```

You will get an error from that command.  Don't worry; just keep reading this
exercise.

The build system is named `ocamlbuild`.  The file we are asking it to
build is the compiled bytecode `hello.byte`.  The build system will
automatically figure out that `hello.ml` is the source code for that
desired bytecode.

However, the build system likes to be in charge of the whole compilation
process. When it sees leftover files generated by a direct call to the
compiler, as we did in the previous exercise, it rightly gets nervous
and refuses to proceed.  If you look at the error message, it says that
a script has been generated to clean up from the old compilation.
Run that script, and also remove the compiled file:

```
$ _build/sanitize.sh
$ rm hello.byte
```

After that, try building again:

```
$ ocamlbuild hello.byte
```

That should now succeed.  There will be a directory `_build` that is
created; it contains all the compiled code.  That's one benefit of the
build system over directly running the compiler:  instead of polluting
your source directory with a bunch of generated files, they get cleanly created
in a separate directory.  There's also a file `hello.byte` that is created,
and it is actually just a link to "real" file of that name, which is in the
`_build` directory.

Now run the executable:

```
$ ./hello.byte
```

You can now easily clean up all the compiled code:

```
$ ocamlbuild -clean
```

That removes the `_build` directory and `hello.byte` link, leaving just your source code.

## What about Main?

Unlike C or Java, OCaml programs do not need to have a special function
named `main` that is invoked to start the program. The usual idiom is
just to have the very last definition in a file serve as the main
function that kicks off whatever computation is to be done.

## Loading code in the toplevel

In addition to allowing you to define functions, the toplevel will
also accept *directives* that are not OCaml code but rather tell the
toplevel itself to do something. All directives begin with the `#`
character.  Perhaps the most common directive is `#use`, which loads
all the code from a file into the toplevel, just as if you had typed
the code from that file into the toplevel.

For example, suppose you create a file named `mycode.ml`.  
In that file put the following code:

```
let inc x = x + 1
```

Start the toplevel.  Try entering the following expression, 
and observe the error:

```
# inc 3;;
Error: Unbound value inc
Hint: Did you mean incr?
```

The error is because the toplevel does not yet know anything about
a function named `inc`.  Now issue the following directive to the toplevel:

```
# #use "mycode.ml";;
```

Note that the first `#` character above indicates the toplevel prompt to you.
The second `#` character is one that you type to tell the toplevel that you
are issuing a directive.  Without that character, the toplevel would think
that you are trying to apply a function named `use`.

Now try again:

```
# inc 3;;
- : int = 4
```

## Workflow in the toplevel

The best workflow when using the toplevel with code stored in files is:

* Edit the code in the file.
* Load the code in the toplevel with `#use`.
* Interactively test the code.
* Exit the toplevel.  **Warning:** do not skip this step.

Suppose you wanted to fix a bug in your code:  it's tempting to not exit
the toplevel, edit the file, and re-issue the `#use` directive into the
same toplevel session. Resist that temptation.  The "stale code" that
was loaded from an earlier `#use` directive in the same session can
cause surprising things to happen&mdash;surprising when you're first
learning the language, anyway. So **always exit the toplevel
before re-using a file.**

