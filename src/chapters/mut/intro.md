# Mutability

OCaml is not a *pure* language: it does admit side effects. We have seen that
already with I/O, especially printing. But up till now we have limited ourselves
to the subset of the language that is *immutable*: values could not change.

Mutability is neither good nor bad. It enables new functionality that we
couldn't implement (at least not easily) before, and it enables us to create
certain data structures that are asymptotically more efficient than their purely
functional analogues. But mutability does make code more difficult to reason
about, hence it is a source of many faults in code. One reason for that might be
that humans are not good at thinking about change. With immutable values, we're
guaranteed that any fact we might establish about them can never change. But
with mutable values, that's no longer true. "Change is hard," as they say.

In this short chapter we'll cover the few mutable features of OCaml we've
omitted so far, and we'll use them for some simple data structures. The real
win, though, will come in later chapters, where we put the features to more
advanced uses.
