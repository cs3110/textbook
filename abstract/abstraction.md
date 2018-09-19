# Abstraction by Specification

Abstraction enables modular programming
by hiding the details of implementations.  Specifications are a part
of that kind of abstraction:  they reveal certain information about
the behavior of a module without disclosing all the details of the
module's implementation.

*Locality* is one of the benefits of abstraction by specification.
A module can be understood without needing to examine its implementation.
This locality is critical in implementing large programs, and even in
in implementing smaller programs in teams.  No one person can keep the entire
system in their head at a time.

*Modifiability* is another benefit.  Modules can be reimplemented
without changing the implementation of other modules or functions. 
Software libraries depend upon this to improve their functionality
without forcing all their clients to rewrite code every time the library
is upgraded.  Modifiability also enables performance enhancements:  we
can write simple, slow implementations first, then improve bottlenecks
as necessary.

The client should not assume more about the implementation than is given
in the spec because that allows the implementation to change. The
specification forms an *abstraction barrier* that protects the
implementer from the client and vice versa. Making assumptions about the
implementation that are not guaranteed by the specification is known as
*violating the abstraction barrier*. The abstraction barrier enforces
local reasoning. Further, it promotes *loose coupling* between
different code modules. If one module changes, other modules are less
likely to have to change to match.