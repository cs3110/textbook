# Summary

Concurrent programming is challenging, which perhaps explains why there are so many different libraries and language features that support it.
Promises are elegant and useful both in functional and imperative programming.
Our implementation used handlers to remember work until a promise resolves,
and proxy promises to share an outcome between the result of `bind` and the
result of its callback.
Our numbering server illustrated how promises let a program serve several
clients concurrently, with sequential dependencies within each client's
interaction. Capturing each client's number before yielding also showed how
to reason about shared mutable state under cooperative scheduling.
But promises are not the last word:
OCaml 5 recently added new mechanisms for parallelism and concurrency based on *domains* and threads.
You might find it interesting to read more about those in the OCaml manual.

## Terms and Concepts

* asynchronous
* bind
* blocking
* callback
* channel
* client
* computations
* concurrent
* concurrent composition
* cooperative
* deterministic
* DNS
* domain name
* effects
* handler
* interleaving
* IP address
* latency hiding
* left identity
* loopback address
* Lwt monad
* maybe monad
* monads
* monad laws
* non-blocking
* nondeterministic
* parallelism
* pending
* port
* preemptive
* process
* promises
* protocol
* proxy promise
* race conditions
* rejected
* resolution loop
* resolved
* resolver
* right identity
* sequential
* sequential composition
* server
* socket
* socket address
* standard input
* standard output
* synchronous
* TCP
* threads
* writer monad

## Further Reading

* *Real World OCaml*, chapter 16

* The [Lwt Manual](https://ocsigen.org/lwt/latest/manual/manual)

* [OCaml 5 Manual, "Parallel Programming"](https://ocaml.org/manual/latest/parallelism.html)
