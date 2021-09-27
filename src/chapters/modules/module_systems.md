# Module Systems

A programming language's *module system* is the set of features it provides in
support of modular programming. Below are some common concerns of module
systems. We focus on Java and OCaml in this discussion, mentioning some of the
most related features in the two languages.

**Namespaces.** A *namespace* provides a set of names that are grouped together,
are usually logically related, and are distinct from other namespaces. That
enables a name `foo` in one namespace to have a distinct meaning from `foo` in
another namespace. A namespace is thus a scoping mechanism. Namespaces are
essential for modularity. Without them, the names that one programmer chooses
could collide with the names another programmer chooses. In Java, classes (and
packages) group names. In OCaml, *structures* (which we will soon study) are
similar to classes in that they group names &mdash; but without any of the added
complexity of object-oriented programming that usually accompanies classes
(constructors, static vs. instance members, inheritance, overriding, `this`,
etc.) Structures are the core of the OCaml module system; in fact, we've been
using them all along without thinking too much about them.

**Abstraction.** An *abstraction* hides some information while revealing other
information. Abstraction thus enables *encapsulation*, aka *information hiding*.
Usually, abstraction mechanisms for modules allow revealing some names that
exist inside the module, but hiding some others. Abstractions therefore describe
relationships among modules: there might be many modules that could considered
to satisfy a given abstraction. Abstraction is essential for modularity, because
it enables implementers of a module to hide the details of the implementation
from clients, thus preventing the clients from abusing those details. In a large
team, the modules one programmer designs are thereby protected from abuse by
another programmer. It also enables clients to be blissfully unaware of those
details. So, in a large team, no programmer has to be aware of all the details
of all the modules. In Java, interfaces and abstract classes provide
abstraction. In OCaml, *signatures* are used to abstract structures by hiding
some of the structure's names and definitions. Signatures are essentially the
types of structures.

**Code reuse.** A module system enables *code reuse* by providing features that
enable code from one module to be used as part of another module without having
to copy that code. Code reuse thereby enables programmers to build on the work
of others in a way that is maintainable: when the implementer of one module
makes an improvement in that module, all the programmers who are reusing that
code automatically get the benefit of that improvement. Code reuse is essential
for modularity, because it enables "building blocks" that can be assembled and
reassembled to form complex pieces of software. In Java, subtyping and
inheritance provide code reuse. In OCaml, *functors* and *includes* enable code
reuse. Functors are like functions, in that they produce new modules out of old
modules. Includes are like an intelligent form of copy-paste: they include code
from one part of a program in another.

```{warning}
These analogies between Java and OCaml are necessarily imperfect. You might
naturally come away from the above discussion thinking either of the following:

- "Structures are like Java classes, and signatures are like interfaces."

- "Structures are like Java objects, and signatures are like classes."

Both are helpful to a degree, yet both are ultimately wrong. So it might be best
to let go of object-oriented programming at this point and come to terms with
the OCaml module system in and of itself. Compared to Java, it's just built
different.
```
