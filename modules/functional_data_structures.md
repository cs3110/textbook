# Functional Data Structures

A *functional data structure* is one that does not make use of any imperative
features.  That is, no operations of the data structure have any side effects.
It's possible to build functional data structures both in functional languages
and in imperative languages.

Functional data structures have the property of being *persistent*:  updating
the data structure with one of its operations does not change the existing
version of the data structure but instead produces a new version.  Both exist
and both can still be accessed.  A good language implementation will ensure
that any parts of the data structure that are not changed by an operation will
be *shared* between the old version and the new version.  Any parts that do
change will be *copied* so that the old version may persist.  The opposite
of a persistent data structure is an *ephemeral* data structure:  changes
are destructive, so that only one version exists at any time.  Both persistent
and ephemeral data structures can be built in both functional and imperative languages.

The `ListStack` module above is functional:  the `push` and `pop` operations
do not mutate the underlying list, but instead return a new list.  We can
see that in the following utop session (in which we assume the `ListStack` module
has been defined as `module ListStack = struct ...`, without the module type annotation
`: Stack` we added above):
```
# open ListStack;;

# let s = push 1 (push 2 empty);;
val s : int list = [1; 2] 

# let s' = pop s;;
val s' : int list = [2]  

# s;;
- : int list = [1; 2] 
```
The value `s` is unchanged by the `pop` operation; both versions of the stack coexist.

The `Stack` module type gives us a strong hint that the data structure is functional
in the types is provides for `push` and `pop`:
```
val push : 'a -> 'a stack -> 'a stack
val pop : 'a stack -> 'a stack
```
Both of those take a stack as an argument and return a new stack as a result.
An ephemeral data structure usually would not bother to return a stack. 
In Java, for example, similar methods might return `void`; the equivalent
in OCaml would be returning `unit`.
