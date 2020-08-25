# Module Systems

Any language's module system will usually provide support for these
concerns:

**Namespaces.** A *namespace* provides a set of names that are grouped
together, are usually logically related, and are distinct from other
namespaces. That enables the name `foo` in one namespace to have a
distinct meaning from `foo` in another namespace.  A namespace is a
scoping mechanism. Namespaces are essential for modularity, because
without them, the names one programmer in a large team chooses could
collide with the names another programmer chooses.  In Java, packages
and classes provide namespaces. In OCaml, there is a language feature
called *structures* that is used to group names.

**Abstraction.** An *abstraction* hides some information while revealing
other information.  Abstraction thus enables *encapsulation*, aka 
*information hiding*.  Usually, abstraction mechanisms for modules allow
revealing some names that exist inside the module, but hiding some
others.  Abstractions therefore describe relationships among modules:
there might be many modules that could considered to satisfy a given
abstraction. Abstraction is essential for modularity, because it enables
implementers of a module to hide the details of the implementation from
clients, thus preventing the clients from abusing those details.  In a
large team, the modules one programmer designs are thereby protected
from abuse by another programmer. It also enables clients to be
blissfully unaware of those details.  In a large team, no programmer has
to be aware of all the details of all the modules. In Java, interfaces
and abstract classes provide abstraction.  In OCaml, there is a language
feature called a *signature* that is used to abstract structures by
hiding some of the structure's names.

**Code reuse.** A module system enables *code reuse* by providing features
that enable code from one module to be used as part of another module without
having to copy that code.  Code reuse thereby enables programmers to build on
the work of others in a way that is maintainable:  when the implementer of
one module makes an improvement in that module, all the programmers who are
reusing that code automatically get the benefit of that improvement. 
Code reuse is essential for modularity, because it enables "building blocks"
that can be assembled and reassembled to form complex pieces of software.
In Java, subtyping and inheritance provide code reuse.  In OCaml, there
are language features called *functors* and *includes* that are used to
reuse code by producing new code out of old code.  We will cover those
features in the next lecture.
