# Specification

A *specification* is a contract between a *client* of some unit of code
and the *implementer* of that code.  The most common place we find
specifications is as comments in the interface (`.mli`) files for a
module.  There, the implementer of the module spells out what the client
may and may not assume about the module's behavior.  This contract makes
it clear who to blame if something goes wrong:  Did the client misuse
the module?  Or did the implementer fail to deliver the promised
functionality?

Specifications usually involve preconditions and postconditions.
The preconditions inform what the client must guarantee about inputs
they pass in, and what the implementer may assume about those inputs.
The postconditions inform what they client may assume about outputs
they receive, and what the implementer must guarantee about those outputs.

An implementation *satisfies* a specification if it provides the behavior
described by the specification.  There may be many possible implementations
of a given specification that are feasible.  The client may not assume anything
about which of those implementations is actually provided.  The implementer,
on the other hand, gets to provide one of their choice.

Good specifications have to balance two conflicting goals; they must be

* **sufficiently restrictive**, ruling out implementations that 
  would be useless to clients, as well as

* **sufficiently general**, not ruling out implementations that 
  would be useful to clients.

Some common mistakes include not stating enough in preconditions, failing to 
identify when exceptions will be thrown, failing to specify behavior at 
boundary cases, writing operational specifications instead of definitional 
and stating too much in postconditions.

Writing good specifications is a skill that you will work to master the
rest of your career.  It's hard because the language and compiler do
nothing to check the correctness of a specification: there's no type
system for them, no warnings, etc.  (Though there is ongoing research on
how to improve specifications and the writing of them.)  The
specifications you write will be read by other people, and with that
reading can come misunderstanding. Reading specifications requires close
attention to detail.

Specifications should be written quite early.  As soon as a design decision 
is made, document it in a specification.  Specifications should continue
to be updated throughout implementation.  A specification becomes obsolete 
only when the code it specifies becomes obsolete and is removed from the
code base.

Clear specifications serve many important functions in software
development teams. One important one is when something goes wrong,
everyone can agree on whose job it is to fix the problem: either the
implementer has not met the specification and needs to fix the
implementation, or the client has written code that assumes something
not guaranteed by the spec, and therefore needs to fix the using code.
Or, perhaps the spec is wrong, and then the client and implementer need
to decide on a new spec. This ability to decide whose problem a bug is
prevents problems from slipping through the cracks.
