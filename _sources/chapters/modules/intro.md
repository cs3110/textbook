# Modular Programming

When a program is small enough, we can keep all of the details of the program in
our heads at once. But real-world applications can be many order of magnitude
larger than those we write in college classes. They are simply too large and
complex to hold all their details in our heads. They are also written by many
programmers. To build large software systems requires techniques we haven't
talked about so far.

One key solution to managing complexity of large software is *modular
programming*: the code is composed of many different code modules that are
developed separately. This allows different developers to take on discrete
pieces of the system and design and implement them without having to understand
all the rest. But to build large programs out of modules effectively, we need to
be able to write modules that we can convince ourselves are correct *in
isolation* from the rest of the program. Rather than have to think about every
other part of the program when developing a code module, we need to be able to
use *local reasoning*: that is, reasoning about just the module and the contract
it needs to satisfy with respect to the rest of the program. If everyone has
done their job, separately developed code modules can be plugged together to
form a working program without every developer needing to understand everything
done by every other developer in the team. This is the key idea of modular
programming.

Therefore, to build large programs that work, we must use *abstraction* to make
it manageable to think about the program. Abstraction is simply the removal of
detail. A well-written program has the property that we can think about its
components (such as functions) abstractly, without concerning ourselves with all
the details of how those components are implemented.

Modules are abstracted by giving *specifications* of what they are supposed to
do. A good module specification is clear, understandable, and gives just enough
information about what the module does for clients to successfully use it. This
abstraction makes the programmer's job much easier; it is helpful even when
there is only one programmer working on a moderately large program, and it is
crucial when there is more than one programmer.

Industrial-strength languages contain mechanisms that support modular
programming. In general (i.e. across programming languages), a module
specification is known as an *interface*, which provides information to clients
about the module's functionality while hiding the *implementation*.
Object-oriented languages support modular programming with *classes*. The Java
`interface` construct is one example of a mechanism for specifying the interface
to a class. A Java `interface` informs clients of the available functionality in
any class that implements it without revealing the details of the
implementation. But even just the public methods of a class constitute an
interface in the more general sense&mdash;an abstract description of what the
module can do.

Developers working with a module take on distinct roles. Most developers are
usually *clients* of the module who understand the interface but do not need to
understand the implementation of the module. A developer who works on the module
implementation is naturally called an *implementer*. The module interface is a
*contract* between the client and the implementer, defining the responsibilities
of both. Contracts are very important because they help us to isolate the source
of the problem when something goes wrong&mdash;and to know who to blame!

It is good practice to involve both clients and implementers in the design of a
module's interface. Interfaces designed solely by one or the other can be
seriously deficient. Each side will have its own view of what the final product
should look like, and these may not align! So mutual agreement on the contract
is essential. It is also important to think hard about global module structure
and interfaces *early*, because changing an interface becomes more and more
difficult as the development proceeds and more of the code comes to depend on
it.

Modules should be used only through their declared interfaces, which the
language should help to enforce. This is true even when the client and the
implementer are the same person. Modules decouple the system design and
implementation problem into separate tasks that can be carried out largely
independently. When a module is used only through its interface, the implementer
has the flexibility to change the module as long as the module still satisfies
its interface.