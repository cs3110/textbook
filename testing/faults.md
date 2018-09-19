## Faults

The word "bug" suggests something that wandered into a program.
Better terminology would be that there are 

* *faults*, which are the result of human errors in software systems, and

* *failures*, which are violations of requirements.

Some faults might never appear to an end user of a system, but failures
are those faults that do.  A fault might result because an implementation 
doesn't match design, or a design doesn't match the requirements.

*Debugging* is the process of discovering and fixing faults.  Testing
clearly is the "discovery" part, but fixing can be more complicated.
Debugging can be a task that takes even more time than an original
implementation itself!  So you would do well to make it easy to debug
your programs from the start.  Write good specifications for each function.
Document the AF and RI for each data abstraction.  Keep modules small,
and test them independently.  Utilize both black box and glass box
testing.

Inevitably, though, you will discover faults in your programs.  When
you do, approach them as a scientist by employing the *scientific method:*

* evaluate the data that are available;

* formula a hypothesis that might explain the data; 

* design a repeatable experiment to test that hypothesis; and

* use the result of that experiment to refine or refute your hypothesis.

Often the crux of this process is finding the simplest, smallest input
that triggers a fault.  That's not usually the original input for
which we discover a fault.  So some initial experimentation might be needed
to find a *minimal test case*.

Never be afraid to write additional code, even a lot of additional code,
to help you find faults.  Functions like `to_string` or `format` can
be invaluable in understanding computations, so writing them up front
before any faults are detected is completely worthwhile.  

When you do discover the source of a fault, be extra careful in fixing
it. It is tempting to slap a quick fix into the code and move on. This
is quite dangerous. Far too often, fixing a fault just introduces a new
(and unknown) fault! If a bug is difficult to find, it is often because
the program logic is complex and hard to reason about. You should think
carefully about why the bug happened in the first place and what the
right solution to the problem is. *Regression testing* (i.e., recording
only test cases that originally failed but now pass) is important
whenever a bug fix is introduced, but nothing can replace careful
thinking about the code.