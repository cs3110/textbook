# Summary

Black-box testing has some important advantages:

-   It doesn't require that we see the code we are testing. Sometimes
    code will not be available in source code form, yet we can still
    construct useful test cases without it. The person writing the test
    cases does not need to understand the implementation.
-   The test cases do not depend on the implementation. They can be
    written in parallel with or before the implementation. Further, good
    black-box test cases do not need to be changed, even if the
    implementation is completely rewritten.
-   Constructing black-box test cases causes the programmer to think
    carefully about the specification and its implications. Many
    specification errors are caught this way.

The disadvantage of black box testing is that its coverage may not be as
high as we'd like, because it has to work without the implementation.

## Terms and concepts

* asserting
* black box
* boundary case
* bug
* code inspection
* code review
* code walkthrough
* consumer
* debugging by scientific method
* defensive programming
* failure
* fault
* formal methods
* glass box
* inputs for classes of output
* inputs that satisfy precondition
* inputs that trigger exceptions
* minimal test case
* pair programming
* path coverage
* paths through implementation
* paths through specification
* producer
* randomized testing
* regression testing
* representative inputs
* social methods
* testing
* typical input
* validation

## Further reading

* [*Program Development in Java: Abstraction, Specification, and
  Object-Oriented Design*][liskov-guttag], chapter 10, by Barbara 
  Liskov with John Guttag. 

[liskov-guttag]: https://newcatalog.library.cornell.edu/catalog/4178051

