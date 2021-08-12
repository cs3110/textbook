# Compiling OCaml Programs

Using OCaml as a kind of interactive calculator can be fun, but we won't get
very far with writing large programs that way. We instead need to store code in
files and compile them.

## Storing code in files

Open a terminal and use a text editor to create a file called
`hello.ml`.  Enter the following code into the file:

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

In larger projects, we don't want to run the compiler or clean up manually.
Instead, we want to use a *build system* to automatically find and link in
libraries. OCaml has a legacy build system called ocamlbuild, and a newer build
system called dune. Let's try using the latter. In the same directory as
`hello.ml`, create a file named `dune` and put the following in it:

```text
(executable
 (name hello))
```

That declares an *executable* (a program that can be executed) whose main file
is `hello.ml`. Then run this command from the terminal:

```console
$ dune build hello.exe
```

Note that the `.exe` extension is used on all platforms by dune, not just on
Windows. That causes dune to build a *native* executable rather than a bytecode
executable. The first time you run that command, dune will automatically create
another file `dune-project` that marks the root directory of the project. You
don't need to do anything more with that file.

Dune will create a directory `_build` and compile our program inside it. That's
one benefit of the build system over directly running the compiler: instead of
polluting your source directory with a bunch of generated files, they get
cleanly created in a separate directory. Inside `_build` there are many files
that get created by dune. Our executable is buried rather deep:

```console
$ _build/default/hello.exe
Hello world!
```

But dune provides a shortcut to having to remember and type all of that.
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
When dune compiles your program, it caches a copy of your source files in
`_build/default`. If you ever accidentally make a mistake that results in loss
of a source file, you might be able to recover it from inside `_build`. Of
course, using source control like git is also advisable.
```

## What about Main?

Unlike C or Java, OCaml programs do not need to have a special function named
`main` that is invoked to start the program. The usual idiom is just to have the
very last definition in a file serve as the main function that kicks off
whatever computation is to be done.
