# Asynchronous I/O

Now that we understand promises as a data abstraction, let's turn
to how they can be used for concurrency.  The typical way they're used
with Lwt is for concurrent input and output (I/O).

## Synchronous I/O

The I/O functions that are part of the OCaml standard library
are *synchronous* aka *blocking*:  when you call such a function,
it does not return until the I/O has been completed.  "Synchronous" here
refers to the synchronization between your code and the I/O function:
your code does not get to execute again until the I/O code is done.
"Blocking" refers to the fact that your code has to 
wait&mdash;it is blocked&mdash;until the I/O completes.

For example, the `Pervasives.input_line : in_channel -> string` function
reads characters from an *input channel* until it reaches a newline
character, then returns the characters it read.  The type `in_channel`
is abstract; it represents a source of data that can be read, such 
as a file, or the network, or the keyboard.  The value
`Pervasives.stdin : in_channel` represents the *standard input* channel,
which is the channel which usually, by default, provides keyboard input.

If you run the following code, you will observe the blocking behavior:
```
# ignore(input_line stdin); print_endline "done";;
<type your own input here>
done
- : unit = ()
```
The string `"done"` is not printed until after the input operation
completes, which happens after you type Enter.

Synchronous I/O makes it impossible for a program to carry on
other computations while it is waiting for the I/O operation to 
complete.  For some programs that's just fine.  A text adventure game,
for example, doesn't have any background computations it needs 
to perform.  But other programs, like spreadsheets or servers,
would be improved by being able to carry on computations
in the background rather than having to completely block while
waiting for input.

## Asynchronous I/O

*Asynchronous* aka *non-blocking* I/O is the opposite style of I/O.
Asynchronous I/O operations return immediately, regardless of whether the input
or output has been completed.  That enables a program to launch
an I/O operation, carry on doing other computations, and later 
come back to make use of the completed operation.

The Lwt library provides its own I/O functions in the `Lwt_io` module,
which is in the `lwt.unix` package.
The function `Lwt_io.read_line : Lwt_io.input_channel -> string Lwt.t` 
is the asynchronous equivalent of `Pervasives.input_line`.  Similarly, 
`Lwt_io.input_channel` is the equivalent of the OCaml standard
library's `in_channel`, and `Lwt_io.stdin` represents the standard
input channel.

Run this code to observe the non-blocking behavior:
```
# #require "lwt.unix";;
# open Lwt_io;;
# ignore(read_line stdin); printl "done";;
done
- : unit = ()
# <type your own input here>
```

The string `"done"` is printed immediately by `Lwt_io.printl`, which is
Lwt's equivalent of `Pervasives.print_endline`, before you even type.
Note that it's best to use just one library's I/O functions, rather than mix
them together.

When you do type your input, you don't see it echoed to the screen,
because it's happening in the background. Utop is still
executing&mdash;it is not blocked&mdash;but your input is being sent to
that `read_line` function instead of to utop.  When you finally type
Enter, the input operation completes, and you are back to interacting
with utop.

Now imagine that instead of reading a line asynchronously, the program was
a web server reading a file to be served to a client.  And instead
of printing a string, the server was delivering the contents of a different
file that had completed reading to a different client.  That's why asynchronous
I/O can be so useful:  it helps to *hide latency*.  Here, "latency" means
waiting for data to be transfered from one place to another, e.g., from
disk to memory.  Latency hiding is an excellent use for concurrency.

Note that all the concurrency here is really coming from the operating system,
which is what provides the underlying asynchronous I/O infrastructure.
Lwt is just exposing that infrastructure to you through a library.

## Promises and Asynchronous I/O

The output type of `Lwt_io.read_line` is `string Lwt.t`, meaning that
the function returns a `string` promise.  Let's investigate how
the state of that promise evolves.

When the promise is returned from `read_line`, it is pending:
```
# let p = read_line stdin in Lwt.state p;;
- : string Lwt.state = Lwt.Sleep
# <now you have to type input and Enter to regain control of utop>
```

When the Enter key is pressed and input is completed, the
promise returned from `read_line` should become resolved.
For example, suppose you enter "Camels are bae":
```
# let p = read_line stdin;;
val p : string Lwt.t = <abstr>
<now you type Camels are bae followed by Enter>
# p;;
- : string = "Camels are bae"
```

But, if you study that output carefully, you'll notice something
very strange just happened!  After the `let` statement, `p` had
type `string Lwt.t`, as expected.  But when we evaluated `p`,
it came back as type `string`.  It's as if the promise disappeared.

What's actually happening is that utop has some special&mdash;and
potentially confusing&mdash;functionality built into it that
is related to Lwt.  Specifically, whenever you try to directly
evaluate a promise at the top level, *utop will give you the contents 
of the promise, rather than the promise itself, and if the promise
is not yet resolved, utop will block until the promise becomes resolved
so that the contents can be returned.*  

So the output `- : string = "Camels are bae"`
really means that `p` contains a resolved `string` whose value is
`"Camels are bae"`, not that `p` itself is a `string`.  Indeed,
the `#show_val` directive will show us that `p` is a promise:

```
# #show_val p;;
val p : string Lwt.t
```

To disable that feature of utop, or to reenable it, call 
the function `UTop.set_auto_run_lwt : bool -> unit`, which
changes how utop evaluates Lwt promises at the top level.
You can see the behavior change in the following code:
```
# UTop.set_auto_run_lwt false;;
- : unit = ()
<now you type Camels are bae followed by Enter>
# p;;
- : string Lwt.state = <abstr>
# Lwt.state p;;
- : string Lwt.state = Lwt.Return "Camels are bae"
```

If you reenable this "auto run" feature, and directly
try to evaluate the promise returned by `read_line`,
you'll see that it behaves exactly like synchronous I/O, i.e.,
`Pervasives.input_line`:
```
# UTop.set_auto_run_lwt true;;
- : unit = ()
# read_line stdin;;
Camels are bae
- : string = "Camels are bae"
```

Because of the potential confusion, we will henceforth
assume that auto running is disabled.  A good way to make
that happen is to put the following line in your `.ocamlinit` file:

```
UTop.set_auto_run_lwt false;;
```

