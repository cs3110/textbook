# Random Number Generation

To understand randomized testing, we need to take a brief digression
into random number generation.

Most languages provide the facility to generate random numbers.  In
truth, these generators are usually not truly random (in the sense that
they are completely unpredictable) but in fact are
[*pseudorandom*][prng]:  the sequence of numbers they generate pass good
statistical tests to ensure there is no discernible pattern in them, but the
sequence itself is a deterministic function of an initial *seed* value. 
(Recall that the prefix *pseudo* is from the Greek *pseud&emacr;s* meaning "false".)
[Java][java-random] and [Python][python-random] both provide
pseudorandom number generators (PRNGs). So does OCaml in the standard library's
[`Random` module][random]. 

[prng]: https://en.wikipedia.org/wiki/Pseudorandom_number_generator
[java-random]: https://docs.oracle.com/javase/8/docs/api/java/util/Random.html
[python-random]: https://docs.python.org/3/library/random.html
[random]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Random.html

## An Experiment

Start a new session of utop and enter the following:
```
# Random.int 100;;
# Random.int 100;;
# Random.int 100;;
```
Write down the responses that you get.  Each is a pseudorandom integer \\(i\\) such that
\\(0 \leq i \lt 100\\).

Now quit utop and start another new session.  Enter the same phrases as above again.
You will get the same responses as last time.  Unless your OCaml installation is
different from the VM's, they will be:  44, 85, 82.  Chances are that everyone in
the class will get those same numbers.  Not exactly unpredictable, eh?

## Pseudorandom Generators

Although for purposes of security and cryptography a PRNG leads to terrible vulnerabilities,
for other purposes&mdash;including testing and simulation&mdash;PRNGs are just fine.
In fact their predictability can even be useful:  given the same initial seed, a PRNG
will always produce the same sequence of pseudorandom numbers, leading to the ability
to repeat a particular sequence of tests or a particular simulation.  

The way a PRNG works in general is that it initializes a *state* that it keeps internally
from the initial seed.  From then on, each time the PRNG generates a new value, it
imperatively updates that state.  The `Random` module in fact makes it possible to 
manipulate that state in limited ways.  For example, you can

* get the current state with `Random.get_state`, 
* duplicate the current state with `Random.State.copy`,
* request a random int generated from a particular state with
  `Random.State.int`, and
* initialize the state yourself.  The functions `Random.self_init` and
  `Random.State.make_self_init` will choose a "random" seed to initialize
  the state.  They do so by sampling from a special Unix file named
  [`/dev/urandom`][urandom], which is meant to provide as close to true
  randomness as a computer can.

[urandom]: https://en.wikipedia.org/wiki//dev/random

## Repeating the Experiment 

Start a new session of utop.  Enter the following:
```
# Random.self_init ();;
# Random.int 100;;
# Random.int 100;;
# Random.int 100;;
```

Now do that a second time (it doesn't matter whether you exit utop
or not in between).  You will notice that you get a different 
sequence of values.
