# Network Programming with Lwt

At the beginning of this chapter, we used servers as an example of why
concurrency is useful. A server might communicate with many clients, each
taking a different amount of time to send or receive data. While one client's
I/O is pending, the server can make progress on another client's work. We now
know enough about promises and callbacks to build a server of our own.

Our example will be a numbering service: each client that connects receives a
number, much like taking a ticket at a deli counter. The service is simple,
but it gives us a chance to see how the ideas in this chapter fit together.
Let's start with how programs find each other and communicate over a network.

## Clients and Servers

A running program is called a *process*. Running the same program in two
terminal windows creates two processes. Each has its own memory, so a reference
created by one process is not automatically accessible to the other. To
communicate, the processes need some way to exchange data.

In the *client-server model*, a *server* listens for incoming connections, and
a *client* initiates a connection to it. Your web browser, for example, acts
as a client when it connects to a web server to retrieve a page. After a
connection is established, data can flow in both directions. The terms
"client" and "server" describe their roles in establishing the connection;
they do not mean that only the client can send data or that only the server
can receive it.

You don't need two computers to experiment with clients and servers. We can
run both processes on your own computer, in separate terminals. The client
still needs to know where to find the server, though. We'll give it two pieces
of information: an IP address and a port.

## IP Addresses and Domain Names

An *Internet Protocol* (IP) address identifies a network interface, such as a
computer's WiFi connection. An *IPv4* address is a 32-bit number, commonly
written as four numbers separated by dots. Each number is between 0 and 255;
for example, `132.236.207.53`. A computer can have several addresses, and its
addresses can change when it joins a different network. There is also a newer
address format, IPv6, but we will use IPv4 in our examples.

An address written that way is easier to read than a 32-bit binary number,
but you probably wouldn't want to memorize the addresses of all your favorite
websites. Instead, we use names such as `www.ocaml.org`. The *Domain Name
System* (DNS) translates these domain names into IP addresses. Think of it as
a directory that translates a person's name into a phone number. A name can
have more than one address, and the answers can change over time.

We can see that translation for ourselves with the command-line tool
`nslookup`, which makes a DNS query:

```console
$ nslookup www.ocaml.org
```

Among the output, you might see something like this:

```text
Name:	www.ocaml.org
Address: 51.159.83.169
```

Near
the beginning of the output, `nslookup` also reports the DNS server it
consulted; that server's address is distinct from the address being looked up.

The special address `127.0.0.1` is a *loopback address*: it refers to the
computer on which the program is running. Traffic to that address stays on
that computer. Two processes on your computer can communicate using loopback
even without a WiFi connection. But a process on someone else's computer
cannot use `127.0.0.1` to reach yours: on their computer, it refers to their
own machine. The name `localhost` commonly resolves to a loopback address;
we will use the numeric IPv4 address to be explicit.

## Ports and Socket Addresses

Now we know how to address a computer, but there could be many programs
running on it. Imagine that your computer runs a web server, an email server,
and our numbering server at the same time. We need a way to specify which
service we want to reach. A *port* distinguishes network services at an
address. Continuing the phone analogy, a port is like an extension number
that reaches a particular
department after you call a business.

Port numbers are 16-bit numbers, ranging from 0 to 65535. Some have conventional
uses: for example, HTTP web servers commonly use port 80, and HTTPS web servers
use port 443. Binding to ports below 1024 can require special privileges,
depending on the OS configuration. We will use port 5000. It has no special
significance to our program, and another application might already be using
it; in that case, choose another available port above 1023.

An IP address together with a port is a *socket address*. For IPv4, we usually
write it as `address:port`, such as `127.0.0.1:5000`. Both ends of a connection
have a socket address. The server chooses a port on which to listen. When a
client connects, the OS ordinarily assigns it an available temporary port,
such as 49170. The client does not need to use the server's port as its own.

That distinction enables many clients to connect to the same server address.
For example, connections from `127.0.0.1:49170` and `127.0.0.1:49171` can both
reach `127.0.0.1:5000`. The OS keeps track of the endpoints so that data reaches
the appropriate connection.

## A Conversation with Netcat

We have enough terminology now to make two processes talk to each other.
Let's do that at the command line before writing any OCaml. The *netcat*
utility, whose command is `nc`, sends standard input across a network
connection and prints received data on standard output. That lets us type
messages in one terminal and receive them in another.

````{note}
The commands here use the netcat supplied with macOS or the OpenBSD version
available on Linux. On Ubuntu, including Ubuntu in Windows Subsystem for
Linux (WSL), missing tools can be installed with:

```console
$ sudo apt install netcat-openbsd dnsutils lsof
```

Run the commands inside the Ubuntu terminal if using WSL. Other netcat
implementations can have different command-line options.
````

In one terminal, start a listener:

```console
$ nc -l 127.0.0.1 5000
```

The `-l` means "listen." This process is our server. It produces no output
while waiting for a connection, and the shell prompt does not return. In a
second terminal, connect a client:

```console
$ nc 127.0.0.1 5000
```

Now type `Hello from the client` in the second terminal and press Enter. The
line appears in the first terminal. Type `Hello from the server` in the first
terminal and press Enter; it appears in the second. The two terminals will
look like this:

| Server terminal | Client terminal |
| --- | --- |
| `$ nc -l 127.0.0.1 5000` | `$ nc 127.0.0.1 5000` |
| `Hello from the client` (received) | `Hello from the client` (typed) |
| `Hello from the server` (typed) | `Hello from the server` (received) |

The parenthesized annotations are explanatory, not part of the terminal output.
Pressing Enter supplies a newline and, with the usual terminal settings,
makes the typed line available to `nc`.

We now have two processes talking to each other, without having written any
networking code ourselves. Each process sends what we type and displays what
it receives. Press Control-C in each terminal that is still running `nc` to
finish.

If starting the listener reports that the address is already in use, another
process is probably listening on that port. This command helps identify it:

```console
$ lsof -nP -iTCP:5000 -sTCP:LISTEN
```

The name `lsof` stands for "list open files"; in Unix, sockets are among the
resources represented by file descriptors. Here we select TCP listeners on
port 5000. The `-nP` options display numeric addresses and ports. The output
includes the process's command name and process ID (PID). Look for `nc` as the command name. Stop an earlier copy
of your own server if one is still running, or choose a different port in
both commands. A client connecting before a server is listening will typically
get a "connection refused" error; `nc -v 127.0.0.1 5000` enables diagnostics.

````{note}
To communicate between two computers on the same local network, the server
must listen on its local network address, and the client must connect to that
address. On macOS, `ifconfig` displays interface addresses; on Linux,
`ip -4 addr` displays IPv4 addresses. A WiFi address might look like
`192.168.1.23`. Replace `127.0.0.1` in both netcat commands with the server's
address. A loopback-only listener cannot accept these connections.

Firewalls, WiFi client isolation, and WSL networking can prevent connections
between machines even when the commands are correct. All the examples in
this section work on one machine using loopback, so they do not require
configuring a network to allow such connections.
````

## Connections and Channels

Let's connect what we just observed to the I/O operations we already know.
By default, those netcat commands use the *Transmission Control Protocol*
(TCP). TCP provides an ordered stream of bytes in each direction over a
connection. A *socket* is an endpoint of communication; a socket address
specifies where an endpoint is located.

Lwt lets us use a connected socket through a pair of channels. An input
channel receives data, and an output channel sends it. The names are relative
to the process using them:

| Sending channel | Receiving channel |
| --- | --- |
| Client's output channel | Server's input channel |
| Server's output channel | Client's input channel |

These channels work much like the channels for keyboard input and terminal
output that we have already used. The difference is where the data comes
from or goes to.

There's one detail we need to settle before writing our programs. TCP carries
bytes, but it doesn't tell us where one message ends and the next begins.
Sending two strings does not guarantee that the receiver gets them in two
separate reads. Our programs need a *protocol*: an agreement about how to
interpret the bytes. For the numbering service, a single line will be enough:

1. The client connects to the server.
2. The server assigns a number and sends a line such as
   `You are connection number 1.`, terminated by a newline.
3. The server closes the connection after sending the line. The client reads
   the line, displays it, and closes its end of the connection.

The client does not need to send a request message: connecting is enough to
request a number. The newline tells the client where the response ends.

## Accepting Connections with Lwt

We're ready to write some OCaml. First, let's give our server the same address
we used with netcat:

```ocaml
let address = Unix.ADDR_INET (Unix.inet_addr_loopback, 5000)
```

Its type is `Unix.sockaddr`. The `ADDR_INET` constructor takes an IP address
and a port. The module also provides `inet_addr_of_string`, so we could write
`Unix.inet_addr_of_string "127.0.0.1"` instead of `Unix.inet_addr_loopback`.
Despite its name, the `Unix` module is available on Windows too.

The function that starts a server is
`Lwt_io.establish_server_with_client_address`. Omitting optional arguments,
its type is:

```ocaml
Unix.sockaddr ->
(Unix.sockaddr ->
 (Lwt_io.input_channel * Lwt_io.output_channel) -> unit Lwt.t) ->
Lwt_io.server Lwt.t
```

That's a long name, and its type takes a little work to read. Let's break it
down. The first argument tells Lwt where to listen. The second tells Lwt what
to do when a client connects. It's a function called a *connection handler*,
which receives the client's address and the channels for communicating with
it. Finally, the result is a promise for a server handle.

To start, let's have our handler print a message on the server's terminal
each time a client connects:

```ocaml
let string_of_address = function
  | Unix.ADDR_UNIX path -> path
  | Unix.ADDR_INET (ip, port) ->
      Printf.sprintf "%s:%d" (Unix.string_of_inet_addr ip) port

let handle_client client_address (_client_in, _client_out) =
  Lwt_io.printlf "Connection from %s." (string_of_address client_address)
```

The `ADDR_UNIX` case makes the pattern match exhaustive; it describes a
different kind of socket used for local communication, which we will not use
here. `Printf.sprintf` constructs a string without performing I/O. The I/O is
performed by `Lwt_io.printlf`: the `l` adds a newline, and the `f` indicates a
format string. With no channel argument, it writes to standard output.

The handler returns a `unit Lwt.t`. Its promise describes the completion of
this client's interaction. With the default settings, Lwt closes the client's
channels when that promise resolves. Our logging handler therefore closes
the connection after logging it, without sending anything to the client.

## Keeping the Server Running

We have an address and a handler. All that seems to be left is to start the
server and run the resolution loop. Here is a first attempt:

```ocaml
let main () =
  let%lwt _server =
    Lwt_io.establish_server_with_client_address address handle_client
  in
  let%lwt () = Lwt_io.printl "Listening on 127.0.0.1:5000" in
  Lwt.return ()

let () = Lwt_main.run (main ())
```

Assuming the address is available, this program prints its startup message
and then immediately exits. That seems surprising: we just started a server,
and we even called `Lwt_main.run`!

Recall, though, what `run` promises to do. It runs the resolution loop until
*its input promise* resolves. The promise returned by
`establish_server_with_client_address` is fulfilled as soon as the server
starts listening. We then print a message and return a fulfilled promise for
`()`. As far as `run` is concerned, the work is finished. It returns, and the
program exits.

We want the server to keep accepting connections until we stop it with
Control-C. So the promise we pass to `run` needs to stay pending. We already
know how to create such a promise: call `Lwt.wait`, then leave its resolver
unused. Replace the final `Lwt.return ()` in `main` with:

```ocaml
let (forever : unit Lwt.t), _resolver = Lwt.wait () in
forever
```

Now the server stays running. Whenever a client connects, Lwt calls our
handler to log the connection, then closes the connection when the handler's
promise resolves. Meanwhile, the main promise stays pending, so the resolution
loop keeps running. When there is no work ready to do, the loop can sleep
until the OS reports an event.

We have now encountered three promises, each with a different purpose:

| Promise | What fulfillment means |
| --- | --- |
| Returned by `establish_server_with_client_address` | The server has started listening. |
| Returned by `handle_client` | One client's interaction has finished. |
| Passed to `Lwt_main.run` | The program's main computation has finished. |

The server handle itself is the contents of the first promise. We name it
`_server` because this program does not use it again, though it could be used
later to stop the server from listening.

## Sending a Number

Our server can now accept connections, but it doesn't yet send anything to
its clients. Let's give it a counter and have the handler send each client
its number. Here is the complete `server.ml`, with the corrected `main`:

```ocaml
(* Listen on port 5000 on this computer. *)
let address = Unix.ADDR_INET (Unix.inet_addr_loopback, 5000)

(* Format a client's address for the server's log messages. *)
let string_of_address = function
  | Unix.ADDR_UNIX path -> path
  | Unix.ADDR_INET (ip, port) ->
      Printf.sprintf "%s:%d" (Unix.string_of_inet_addr ip) port

(* All clients share this counter. *)
let counter = ref 0

(* Lwt calls this for each connection and closes its channels when
   the returned promise resolves. We only send data, so input is unused. *)
let handle_client client_address (_client_in, client_out) =
  (* Assign this client a number before any operation could yield. *)
  incr counter;
  let number = !counter in
  (* Log the connection on the server's terminal. *)
  let%lwt () =
    Lwt_io.printlf "Connection %d from %s."
      number (string_of_address client_address)
  in
  (* Send the client its number as a line of text. *)
  let%lwt () =
    Lwt_io.fprintlf client_out "You are connection number %d." number
  in
  (* Finish writing buffered output before the handler finishes. *)
  Lwt_io.flush client_out

let main () =
  (* Start listening, using handle_client for each new connection. *)
  let%lwt _server =
    Lwt_io.establish_server_with_client_address address handle_client
  in
  let%lwt () = Lwt_io.printl "Listening on 127.0.0.1:5000" in
  (* Keep the main promise pending so the server keeps running. *)
  let (forever : unit Lwt.t), _resolver = Lwt.wait () in
  forever

(* Run the resolution loop until we stop the process with Control-C. *)
let () = Lwt_main.run (main ())
```

The counter is initialized once when the server starts. Each invocation of
the handler increments it and captures the result as `number`. That local
binding preserves this client's number even if another invocation later
increments the counter. Restarting the server resets the counter to zero.

There are two destinations for output. `printlf` logs a message on the
server's terminal. `fprintlf` takes an output channel as its first argument;
here it sends the response toward the client. The handler never reads from
the client, so `_client_in` is deliberately unused.

The final call to `flush` needs a little explanation. Output channels are
*buffered*: writing can initially copy bytes into a memory buffer instead of
sending them immediately. We want to finish sending our response before the
handler finishes and its channels are closed. The call to `flush` performs
the pending writes, passing the buffered output onward to the OS. By returning
its promise, we make those writes part of the handler's work.

```{note}
Lwt also flushes output automatically when idle. We use an explicit flush to
make the ordering clear. Finishing a flush means the buffered output has been
passed onward to the OS; it does not establish that the client application
has read the message.
```

## Receiving a Number

Our server can now hand out numbers. Let's write a client that connects,
reads its number, and prints it. Here is the complete `client.ml`:

```ocaml
(* Connect to the address where our server is listening. *)
let address = Unix.ADDR_INET (Unix.inet_addr_loopback, 5000)

let main () =
  (* Connect, then use the channels in this callback. Lwt closes them
     when the callback's promise resolves. We only receive data. *)
  Lwt_io.with_connection address (fun (server_in, _server_out) ->
      (* Continue once a complete response line is available. *)
      let%lwt line = Lwt_io.read_line server_in in
      (* Display the response on the client's terminal. *)
      Lwt_io.printlf "The server says: %S" line)

(* Run until the response is displayed and the connection is closed. *)
let () = Lwt_main.run (main ())
```

The function `Lwt_io.with_connection` connects to the given address and passes
the resulting channels to its callback. The callback reads one line and
prints it. `read_line` removes the newline terminator; the `%S` format
specifier displays the resulting string with quotes. The client has no data
to send, so `_server_out` is unused.

Once the callback's promise resolves, `with_connection` closes the channels,
including if the callback fails. It returns a promise representing the
overall operation, including cleanup. So we can concentrate on what to do
with the connection, and let `with_connection` take care of closing it.

```{note}
The lower-level `Lwt_io.open_connection` instead returns a promise for the
pair of channels and leaves their cleanup to the caller. For this example,
`with_connection` conveniently keeps the connection's lifetime tied to the
computation that uses it.
```

This time, we *want* the main promise to become fulfilled. The client has
finished its job once it has displayed the response and cleaned up the
connection. At that point, `Lwt_main.run` returns, and the process exits.

## Running the Numbering Service

Let's put the two programs together and see the numbering service in action.
Put `server.ml` and `client.ml` in a new directory. If you haven't already
installed the required packages, run:

```console
$ opam install dune lwt lwt_ppx
```

In that directory, create `dune-project` containing:

```text
(lang dune 3.0)
```

And create `dune` containing:

```text
(executables
 (names server client)
 (libraries lwt.unix)
 (preprocess (pps lwt_ppx)))
```

The library `lwt.unix` supplies the networking functions, and `lwt_ppx`
supplies `let%lwt`. Build both programs and start the server:

```console
$ dune build
$ dune exec ./server.exe
Listening on 127.0.0.1:5000
```

In another terminal, in the same directory, run the client twice:

```console
$ dune exec ./client.exe
The server says: "You are connection number 1."
$ dune exec ./client.exe
The server says: "You are connection number 2."
```

The server remains running and logs each connection. Its output might be:

```text
Listening on 127.0.0.1:5000
Connection 1 from 127.0.0.1:49170.
Connection 2 from 127.0.0.1:49171.
```

Notice that both clients reached the same server, but each had its own port
number. Those ports are chosen by the OS, so yours will differ. We can even
use our old netcat client with the new OCaml server:

```console
$ nc 127.0.0.1 5000
You are connection number 3.
```

It works because netcat can receive and display the line our server sends.
The client and server don't have to be written in the same language; they
just need to agree on how to communicate.

Stop the server with Control-C when finished. If startup fails with
`EADDRINUSE`, use the earlier `lsof` command to check for another listener,
including the netcat listener. If you change the port, change it in both
OCaml files and in the server's startup message. A client reporting
`ECONNREFUSED` usually means that no server is listening at the requested
address and port.

## Where Is the Concurrency?

We've used `let%lwt` to sequence the operations in each handler, and we
haven't written a single call to `Lwt.join`. Yet this server can handle
clients concurrently. The server-creation function does the work of accepting
further connections while earlier handlers' promises are still pending.
Each handler describes a sequential chain of operations, and the server can
have many such chains in progress.

Our server responds so quickly that it's hard to see the concurrency. Let's
slow it down. Here is a replacement for `handle_client` in `server.ml` that
adds a three-second delay before sending the response:

```ocaml
let handle_client client_address (_client_in, client_out) =
  incr counter;
  let number = !counter in
  let%lwt () =
    Lwt_io.printlf "Connection %d from %s."
      number (string_of_address client_address)
  in
  let%lwt () = Lwt_unix.sleep 3.0 in
  let%lwt () =
    Lwt_io.fprintlf client_out "You are connection number %d." number
  in
  Lwt_io.flush client_out
```

The call to `Lwt_unix.sleep` immediately returns a promise that will be
fulfilled after about three seconds. Binding on that promise postpones this
handler's response. It does not block the server process for three seconds.
After rebuilding and restarting the server, two clients started about a
second apart could produce this sequence:

| Approximate time | Event |
| --- | --- |
| 0 seconds | A connects, is assigned number 1, and its handler begins the delay. |
| 1 second | B connects, is assigned number 2, and its handler begins the delay. |
| 3 seconds | A's delay promise is fulfilled; its handler sends number 1. |
| 4 seconds | B's delay promise is fulfilled; its handler sends number 2. |

Notice that each client waits about three seconds. B's delay begins while
A's delay is still in progress. That's the overlap we wanted to see. Pending
network operations permit the same kind of overlap as these pending timers.

Recall that Lwt uses cooperative scheduling. In this program, only one
OCaml callback executes at a time. When a computation needs the result of
a pending operation, it registers a callback and returns control so that
other work can proceed. This is concurrency, but it is not parallel execution
of the handlers on multiple cores. A long computation that never yields, or
a blocking call such as `Unix.sleep`, would delay the other handlers too.

### Why the Counter Is Safe

You might be concerned about that shared counter. Earlier in this chapter,
we warned that shared mutable state can lead to race conditions. Now we have
several handlers all reading and writing the same reference!

The important detail is where those reads and writes occur. Our handler
increments the counter and immediately saves its value:

```ocaml
incr counter;
let number = !counter in
```

Neither operation yields control, so another handler cannot run between
them in this program. Afterward, `number` is an immutable local binding.
Other handlers can change `counter` while this handler's I/O or timer is
pending, but they cannot change its captured `number`.

Suppose instead that the delayed handler read `!counter` only when sending
the response. In the trace above, both clients could receive number 2:
B's handler has incremented the shared counter before A's delay ends. Saving
the number before the delay is what lets each handler remember its own
client's number. Cooperative scheduling makes it easier to identify where
such interleavings can occur, but we still have to reason about them.

```{note}
A `let%lwt` does not necessarily yield: its input promise might already be
fulfilled. Our reasoning relies on the uninterrupted increment and capture,
rather than on an assumption that every bind switches to another handler.
```

### When Communication Fails

So far we've assumed that the server successfully sends a response. But a
connection can fail, or the server could close it before sending anything.
Promises give us a way to describe those outcomes too: the I/O promise is
rejected. For example, if the server closes the connection without sending
any response bytes, the client's `read_line` promise is rejected with
`End_of_file`. In our client that rejection propagates to `Lwt_main.run`,
which raises the exception and ends the program.

We can give the user a more helpful message by handling that rejection. A
`try%lwt` expression handles both an exception raised while starting an
operation and a later rejection of its promise. Here is an alternative
client `main` that reports an early end of input:

```ocaml
let main () =
  try%lwt
    Lwt_io.with_connection address (fun (server_in, _server_out) ->
        let%lwt line = Lwt_io.read_line server_in in
        Lwt_io.printlf "The server says: %S" line)
  with End_of_file ->
    Lwt_io.eprintlf "The server closed the connection without a response."
```

An ordinary `try` around the same expression would only catch an exception
raised while evaluating it, not a rejection that occurs later. The `e`
prefix on `eprintlf` directs the message to standard error.

```{note}
Our small server leaves handler failures unhandled. Lwt forwards unhandled
handler failures, and errors from automatic channel cleanup, to
`Lwt.async_exception_hook`, whose default behavior terminates the process.
A production service would handle these failures and cleanup deliberately.
It would also arrange a controlled shutdown: `Lwt_io.shutdown_server` stops
accepting new connections, but does not close connections already accepted.
The [`Lwt_io` documentation][lwt-io] describes those facilities in more detail.
```

[lwt-io]: https://ocsigen.org/lwt/latest/lwt/Lwt_io/index.html
