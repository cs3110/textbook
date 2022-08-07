# Compiling OCaml Programs

Using OCaml as a kind of interactive calculator can be fun, but we won't get
very far with writing large programs that way. We instead need to store code in
files and compile them.

## Storing code in files

Open a terminal, create a new directory, and open VS Code in that directory.
For example, you could use the following commands:

```console
$ mkdir hello-world
$ cd hello-world
```

```{warning}
Do not use the root of your Unix home directory as the place you store the file.
The build system we are going to use very soon, dune, might not work right in
the root of your home directory. Instead, you need to use a subdirectory of your
home directory.
```

Use VS Code to create a new file named `hello.ml`. Enter the following code into
the file:

```ocaml
let _ = print_endline "Hello world!"
```

```{note}
There is no double semicolon `;;` at the end of that line of code. The double
semicolon is intended for interactive sessions in the toplevel, so that the
toplevel knows you are done entering a piece of code. There's usually no reason
to write it in a .ml file.
```

The `let _ =` above means that we don't care to give a name (hence the "blank"
or underscore) to code on the right-hand side of the `=`.

Save the file and return to the command line.  Compile the code:

```console
$ ocamlc -o hello.byte hello.ml
```

The compiler is named `ocamlc`. The `-o hello.byte` option says to name the
output executable `hello.byte`. The executable contains compiled OCaml bytecode.
In addition, two other files are produced, `hello.cmi` and `hello.cmo`. We don't
need to be concerned with those files for now. Run the executable:

```console
$ ./hello.byte
```

It should print `Hello world!` and terminate.

Now change the string that is printed to something of your choice. Save the
file, recompile, and rerun. Try making the code print multiple lines.

This edit-compile-run cycle between the editor and the command line is something
that might feel unfamiliar if you're used to working inside IDEs like Eclipse.
Don't worry; it will soon become second nature.

Now let's clean up all those generated files:

```console
$ rm hello.byte hello.cmi hello.cmo
```

## What about Main?

Unlike C or Java, OCaml programs do not need to have a special function named
`main` that is invoked to start the program. The usual idiom is just to have the
very last definition in a file serve as the main function that kicks off
whatever computation is to be done.

## Dune

In larger projects, we don't want to run the compiler or clean up manually.
Instead, we want to use a *build system* to automatically find and link in
libraries. OCaml has a legacy build system called ocamlbuild, and a newer build
system called Dune. Similar systems include `make`, which has long been used in
the Unix world for C and other languages; and Gradle, Maven, and Ant, which are
used with Java.

A Dune *project* is a directory (and its subdirectories) that contain OCaml code
you want to compile. The *root* of a project is the highest directory in its
hierarchy. A project might rely on external *packages* providing additional code
that is already compiled. Usually, packages are installed with OPAM, the OCaml
Package Manager.

Each directory in your project can contain a file named `dune`. That file
describes to Dune how you want the code in that directory (and subdirectories)
to be compiled. Dune files use a functional-programming syntax descended from
LISP called *s-expressions*, in which parentheses are used to show nested data
that form a tree, much like HTML tags do. The syntax of Dune files is documented
in the [Dune manual][dune-man].

[dune-man]: https://dune.readthedocs.io/en/stable/dune-files.html

Here is a small example of how to use Dune. In the same directory as `hello.ml`,
create a file named `dune` and put the following in it:

```text
(executable
 (name hello))
```

That declares an *executable* (a program that can be executed) whose main file
is `hello.ml`.

Also create a file named `dune-project` and put the following in it:

```text
(lang dune 3.4)
```

That tells Dune that this project uses Dune version 3.4, which was current at
the time this version of the textbook was released. This *project* file is
needed in the root directory of every source tree that you want to compile with
Dune. In general, you'll have a `dune` file in every subdirectory of the source
tree but only one `dune-project` file at the root.

Then run this command from the terminal:

```console
$ dune build hello.exe
```

Note that the `.exe` extension is used on all platforms by Dune, not just on
Windows. That causes Dune to build a *native* executable rather than a bytecode
executable.

Dune will create a directory `_build` and compile our program inside it. That's
one benefit of the build system over directly running the compiler: instead of
polluting your source directory with a bunch of generated files, they get
cleanly created in a separate directory. Inside `_build` there are many files
that get created by Dune. Our executable is buried a couple of levels down:

```console
$ _build/default/hello.exe
Hello world!
```

But Dune provides a shortcut to having to remember and type all of that.
To build and execute the program in one step, we can simply run:

```console
$ dune exec ./hello.exe
Hello world!
```

Finally, to clean up all the compiled code we just run:

```console
$ dune clean
```

That removes the `_build` directory, leaving just your source code.

```{tip}
When Dune compiles your program, it caches a copy of your source files in
`_build/default`. If you ever accidentally make a mistake that results in loss
of a source file, you might be able to recover it from inside `_build`. Of
course, using source control like git is also advisable.
```
