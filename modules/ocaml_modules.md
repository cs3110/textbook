# OCaml Modules

The OCaml module system is based on *structures* and *signatures*.
Structures are the core of the module system; in fact, we've been using
them all along without thinking too much about them. Signatures are the
types of structures.

It's tempting to make an analogy to object-oriented languages you might
know.  For example, we might say that structures are like Java classes,
and that signatures are like interfaces.  Or, we might say that
structures are like objects, and that signatures are like classes.  Both
analogies are imperfect.  So, to begin, it might be best to put any
analogies out of your mind, and just treat OCaml modules as a completely
new idea.
