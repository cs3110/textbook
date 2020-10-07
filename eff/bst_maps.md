# Maps and Sets from BSTs

It's easy to use a BST to implement either a map or a set ADT:

- For a map, just store a binding at each node.  The nodes are ordered
  by the keys.  The values are irrelevant to the ordering.
  
- For a set, just store an element at each node. The nodes are ordered by
  the elements.

The OCaml standard library does this for the `Map` and `Set` modules. It uses a
balanced BST that is a variant of an AVL tree. AVL trees are balanced BSTs in
which the height of paths is allowed to vary by at most 1. The OCaml standard
library modifies that to allow the height to vary by at most 2. Like red-black
trees, they achieve worst-case logarithmic performance.

Now that we have a functional map data structure, how does it compare
to our imperative version, the hash table?

- **Persistence:** Our red-black trees are persistent, but hash tables are
  ephemeral.

- **Performance:** We get guaranteed worst-case logarithmic performance with
  red-black trees, but amortized, expected constant-time with hash tables.
  That's somewhat hard to compare given all the modifiers involved. It's also an
  example of a general phenomenon that persistent data structures often have to
  pay an extra logarithmic cost over the equivalent ephemeral data structures.

- **Convenience:** We have to provide an ordering function for balanced binary
  trees, and a hash function for hash tables. Most libraries provide a default
  hash function for convenience. But the performance of the hash table does
  depend on that hash function truly distributing keys randomly over buckets. If
  it doesn't, the "expected" part of the performance guarantee for hash tables
  is violated. So the convenience is a double-edged sword.

There isn't a clear winner here.  Since the OCaml library provides both
`Map` and `Hashtbl`, you get to choose.
