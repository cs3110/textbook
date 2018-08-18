# Debugging

Debugging is a last resort when everything else has failed. Let's take a
step back and think about everything that comes *before* debugging.

## Defenses against bugs

According to [Rob Miller](https://stellar.mit.edu/S/course/6/fa08/6.005/courseMaterial/topics/topic3/lectureNotes/Debugging/Debugging.pdf),
there are four defenses against bugs:

1.  **The first defense against bugs is to make them impossible.**

    Entire classes of bugs can be eradicated by choosing to program in
    languages that guarantee *[memory
    safety](http://www.pl-enthusiast.net/2014/07/21/memory-safety/)*
    (that no part of memory can be accessed except through a *pointer*
    (or reference) that is valid for that region of memory) and *[type
    safety](http://www.pl-enthusiast.net/2014/08/05/type-safety/)* (that
    no value can be used in a way inconsistent with its type). The OCaml
    type system, for example, prevents programs from buffer overflows
    and meaningless operations (like adding a boolean to a float),
    whereas the C type system does not.

2.  **The second defense against bugs is to use tools that find them.**

    There are automated source-code analysis tools, like
    [FindBugs](http://findbugs.sourceforge.net/), which can find many
    common kinds of bugs in Java programs, and
    [SLAM](http://research.microsoft.com/en-us/projects/slam/), which is
    used to find bugs in device drivers. The subfield of CS known as
    *formal methods* studies how to use mathematics to specify and
    verify programs, that is, how to prove that programs have no bugs.
    We'll study verification later in this course. 
    
    *Social methods* such as code reviews and pair programming are also
    useful tools for finding bugs. Studies at IBM in the 1970s-1990s
    suggested that code reviews can be remarkably effective. In one
    study (Jones, 1991), code inspection found 65% of the known coding
    errors and 25% of the known documentation errors, whereas testing
    found only 20% of the coding errors and none of the documentation
    errors.

3.  **The third defense against bugs is to make them immediately
    visible.**

    The earlier a bug appears, the easier it is to diagnose and fix. If
    computation instead proceeds past the point of the bug, then that
    further computation might obscure where the failure really occurred.
    *Assertions* in the source code make programs "fail fast" and "fail
    loudly", so that bugs appear immediately, and the programmer knows
    exactly where in the source code to look.

4.  **The fourth defense against bugs is extensive testing.**

    How can you know whether a piece of code has a particular bug? Write
    tests that would expose the bug, then confirm that your code doesn't
    fail those tests. *Unit test* for a relatively small piece of code,
    such as an individual function or module, are especially important
    to write at the same time as you develop that code. Running of those
    tests should be automated, so that if you ever break the code, you
    find out as soon as possible. (That's really Defense 3 again.)

After all those defenses have failed, a programmer is forced
to resort to debugging.

## How to debug 

So you've discovered a bug. What next?

1.  **Distill the bug into a small test case.** Debugging is hard work,
    but the smaller the test case, the more likely you are to focus your
    attention of the piece of code where the bug lurks. Time spent on
    this distillation can therefore be time saved, because you won't
    have to re-read lots of code. Don't continue debugging until you
    have a small test case!
    
2.  **Employ the scientific method.** Formulate a hypothesis as to why
    the bug is occurring. You might even write down that hypothesis in a
    notebook, as if you were in a Chemistry lab, to clarify it in your
    own mind and keep track of what hypotheses you've already
    considered. Next, design an experiment to affirm or deny that
    hypothesis. Run your experiment and record the result. Based on what
    you've learned, reformulate your hypothesis. Continue until you have
    rationally, scientifically determined the cause of the bug.
    
3.  **Fix the bug.** The fix might be a simple correction of a typo. Or
    it might reveal a design flaw that causes you to make major changes.
    Consider whether you might need to apply the fix to other locations
    in your code based—for example, was it a copy and paste error? If
    so, do you need to refactor your code?
    
4.  **Permanently add the small test case to your test suite.** You
    wouldn't want the bug to creep back into your code base. So keep
    track of that small test case by keeping it as part of your unit
    tests. That way, any time you make future changes, you will
    automatically be guarding against that same bug. Repeatedly running
    tests distilled from previous bugs is called *regression testing*.

## Debugging in OCaml

Here are a couple tips on how to debug&mdash;if you are forced into it&mdash;in
OCaml.

-   **Print statements.** Insert a print statement to ascertain the
    value of a variable. Suppose you want to know what the value of `x`
    is in the following function:

        let inc x = 
          x+1

    Just add the line below to print that value:

        let inc x = 
          let () = print_int(x) in
    	  x+1

    The [Pervasives](http://caml.inria.fr/pub/docs/manual-ocaml/libref/Pervasives.html)
    module contains many other printing statements you can use.

-   **Function traces.** Suppose you want to see the *trace* of
    recursive calls and returns for a function. Use the `#trace`
    directive:

        let rec fib x = if x<=1 then 1 else fib(x-1) + fib(x-2)
        #trace fib;;

    If you evaluate `fib 2`, you will now see the following output:

        fib <-- 2
        fib <-- 0
        fib --> 1                                                                       
        fib <-- 1
        fib --> 1
        fib --> 2

    To stop tracing, use the `#untrace` directive.

-   **Debugger.** OCaml does have a debugging tool `ocamldebug`.
    You can find a [tutorial](https://ocaml.org/learn/tutorials/debug.html#The-OCaml-debugger)
    on the OCaml website.  Unless you are using Emacs as your editor,
    you will probably find this tool to be harder to use than just
    inserting print statements.
