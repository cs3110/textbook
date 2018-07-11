# Modules and the Toplevel

TODO: turn this into a section.

*There are several pragmatics with modules and the toplevel that you need
to understand to use them together effectively.  The following sequence
of exercises, which should be done in order, is designed to help you 
navigate some of the common pitfalls and confusions that come up.*

Compiling an OCaml file produces a module having the same name as the file (but
with the first letter capitalized). These compiled modules can be loaded into 
the toplevel using `#load`.  

##### Exercise: load [&#10029;] 

Create a file called `mods.ml`.  Inside that file, put the following code:
```
let b = "bigred"
let inc x = x+1
module M = struct
  let y = 42
end
```

At the command line, type `ocamlbuild mods.byte` to compile it.  Type
`ls _build` to see the files that `ocamlbuild` produced.  One of them
is `mods.cmo`:  this is a <u>c</u>ompiled <u>m</u>odule <u>o</u>bject file,
aka bytecode.  

Now run `utop`, and give it this directive (recall that the `#` character is
required in front of a directive, it is not part of the prompt):
```
# #directory "_build";;
```
That tells utop to add the `_build` directory to the path in which it
looks for compiled (and source) files.

Now give utop this directive: 
```
# #load "mods.cmo";;
```

There is now a module named `Mods` available to be used.  Try these
expressions in utop:
```
# Mods.b;;
# Mods.M.y;;
```
Now try these:
```
# inc;;  (* will fail *)
# open Mods;;
# inc;;
```
Finish by exiting utop.

&square;

If you are doing a lot of testing of a particular module, it can be
annoying to have to type those directives (`#directory` and `#load`)
every time you start utop.  The solution is to create a file
in the working directory and call that file `.ocamlinit`.  Note
that the `.` at the front of that filename is required and makes
it a [hidden file][hidden] that won't appear in directory listings
unless explicitly requested (e.g., with `ls -a`).  Everything
in `.ocamlinit` will be processed by utop when it loads.

##### Exercise: ocamlinit [&#10029;] 

Using your text editor, create a file named `.ocamlinit` in the same
directory as `mods.ml`.  In that file, put the following:
```
#directory "_build";;
#load "mods.cmo";;
open Mods
```
Now restart utop.  All the names defined in `Mods` will already be in scope.
For example, these will both succeed:
```
# inc;;
# M.y;;
```

[hidden]: https://en.wikipedia.org/wiki/Hidden_file_and_hidden_directory

&square;

If you are building code that depends on third-party libraries,
you can load those libraries with another directive:

##### Exercise: require [&#10029;] 

Add the following lines to the end of `mods.ml`:
```
open OUnit2
let test = "testb" >:: (fun _ -> assert_equal "bigred" b)
```
Try to recompile the module with `ocamlbuild mods.byte`.  That
will fail, because you need to tell the build system to include
the third-party library OUnit.  So try to recompile with
`ocamlbuild -pkg oUnit mods.byte`.  That will succeed.

Now try to restart utop.  If you look closely, there will be an
error message:  
```
File ".ocamlinit", line 1:
Error: Reference to undefined global `OUnit2'
```

The problem is that the OUnit library hasn't been loaded into utop yet.
Type the following directive:
```
#require "oUnit";;
```
Now you can successfully load your own module without getting an error.
```
#load "mods.cmo";;
```
Quit utop.  Add the `#require` directive to `.ocamlinit` anywhere before the 
`#load` directive.  Restart utop.  Verify that `inc` is in scope.

&square;

When compiling a file, the build system automatically figures out which
other files it depends on, and recompiles those as necessary.  The toplevel,
however, is not as sophisticated:  you have to make sure to load all
the dependencies of a file, as we'll see in the next exercise.

##### Exercise: loads [&#10029;] 

Create a file `mods2.ml`.  In it, put this code:
```
open Mods
let x = inc 0
```
Run `ocamlbuild -pkg oUnit mods2.byte`.  Notice that you don't have to 
name `mods.byte`, even though `mods2.ml` depends on the module `Mod`.
The build system is smart that way.

Go back to `.ocamlinit` and change it be to just the following:
```
#directory "_build";;
#require "oUnit";;
```

Restart utop.  Try this directive:
```
# #load "mods2.cmo";;
Error: Reference to undefined global `Mods' 
```

The toplevel did not automatically load the modules that `Mods2` depends upon.
You can do that manually:
```
# #load "mods.cmo";;
# #load "mods2.cmo";;
```
Or you can tell the toplevel to load `Mods2` and recursively to load everything
depends on:
```
# #load_rec "mods2.cmo";;
```

&square;

There is a big difference between `#load`-ing a compiled module file and `#use`-ing
an uncompiled source file.  The former loads bytecode and makes it available for use.
For example, loading `mods.cmo` caused the `Mod` module to be available,
and we could access its members with expressions like `Mod.b`.
The latter (`#use`) is *textual inclusion*:  it's like typing the contents of
the file directly into the toplevel.  So using `mods.ml` does **not** cause
a `Mod` module to be available, and the definitions in the file 
can be accessed directly, e.g., `b`.  Let's try that out...

##### Exercise: load vs. use [&#10029;] 

Start a new toplevel, first making sure your `.ocamlinit` does not contain any
`#load` directives.  We already know from the previous exercise that
we could load first `mods.cmo` then `mods2.cmo`.  Let's try using the source
code:
```
# #use "mods.ml" (* will succeed *)

# b;;
val b : string = "bigred"

# #use "mods2.ml" (* will fail *)
Error: Reference to undefined global `Mods'   
```

The problem is that `#use`-ing `mods.ml` did not introduce a module into scope.
Rather it directly put the definitions found in that source file into scope.

&square;

So when you're using the toplevel to experiment with your code, it's often
better to work with `#load`, because this accurately reflects how your modules
interact with each other and with the outside world, rather than `#use` them.


