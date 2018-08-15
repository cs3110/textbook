# OUnit and Files

Creating a couple more files can make the use of OUnit more pleasant.

## Tags file
 
We compiled the OUnit test file, we had to specify linking of OUnit:
```
$ ocamlbuild -pkgs oUnit sum_test.byte
```
If you get tired of typing the `pkgs oUnit` part of that, you can instead create
a file named `_tags` (note the underscore) in the same directory and put
the following into it:
```
true: package(oUnit)
```
Now Ocamlbuild will automatically link in OUnit everytime you compile in this
directory, without you having to give the `pkgs` flag. The tradeoff is that
you now have to pass a different flag to Ocamlbuild:
```
$ ocamlbuild -use-ocamlfind sum_test.byte
```
And you will continue having to pass that flag as long as the `_tags` file exists.
Why is this any better?  If there are many packages you want to link, with
the tags file you end up having to pass only one option on the command
line, instead of many.

## Merlin file

If you are using Merlin (e.g., your editor is VS Code or Emacs), you will notice
two things that aren't quite optimal at this point.  First, Merlin doesn't 
understand the OUnit code.  Second, Merlin doesn't understand the code located
in `sum.ml` while you are editing `sum_test.ml`.  To fix both of those problems,
create a file in the same directory and name it `.merlin`.  (Note the leading 
dot in that filename.)  In that file put the following:
```
B _build
PKG oUnit
```
The first line tells Merlin to look for compiled code from other source files
inside the `_build` directory, which is where Ocamlbuild places compiled code.
The second line tells Merlin to look for the oUnit package.  You might need
to restart your editor for these changes to take effect.  After that, you definitely 
have to compile the code with Ocamlbuild, so that the compiled code exists in
the `_build` directory where Merlin now expects to find it.

