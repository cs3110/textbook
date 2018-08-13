# A Brief History of CS 3110

This course originated at MIT as 6.001 *Structure and Interpretation of
Computer Programs* (SICP), which was the name of the course as well as
the name of its textbook.  It's possible that Tim Teitelbaum was the
first to bring that course to Cornell.  

The earliest digital record at Cornell seems to be [CS 212 Fall
1999][cs212-1999fa], which was taught by Ramin Zabih in Scheme and
mostly followed the SICP material.  The SICP textbook itself wasn't
required; CS 212 already had its own lecture notes.  As CS 3110 still
does, CS 212 covered functional programming, the substitution and
environment models, some data structures and algorithms, and programming
language implementation.

In the late 1990s and early 2000s, there was an upper level course known
as CS 410 Data Structures.  A copy of the syllabus from [Spring
1998][cs410-1998sp] is still online.  It covered many data structures
and algorithms not covered by CS 212, including balanced trees and
graphs.  CS 410 used C as the programming language. CS 410 was
eliminated from the curriculum and its contents merged with CS 212. 
(Alas, C remains in the curriculum today.)

The resulting course was known as CS 312 Data Structures and Functional
Programming.  A syllabus from [Fall 2002][cs312-2002fa] is the earliest
example online.  It covered a large subset of the material from the
union of CS 212 and CS 410.  But to cover nearly two courses worth of
material in the same number of lectures is not possible.  CS 312 appears
to have attempted to solve that problem by introducing recitations,
effectively doubling the number of class meetings.  The language was
Standard ML (SML), which Greg Morrisett had introduced
at least by [Spring 2001][cs312-2001sp].

In [Fall 2002] Andrew Myers started teaching CS 312.  He began to
gradually incorporate material on modular programming from another MIT
textbook, *Program Development in Java: Abstraction, Specification, and
Object-Oriented Design* by Barbara Liskov and John Guttag.

In [Fall 2008][cs3110-2008fa] two big changes came.  First, the
university switched to four-digit course numbers, and CS 312 became 
CS 3110.  The syllabus shows the same lecture and recitation structure,
with new material incorporated on modular programming and formal
methods. Second, the language switched to OCaml.  

Michael Clarkson (Cornell PhD 2010) first taught the course in [Fall
2014][cs3110-2014fa], after having first TA'd the course as a PhD
student back in [Spring 2008][cs312-2008sp].  He began to revise the
presentation of the OCaml programming material to incorporate ideas by
Dan Grossman (Cornell PhD 2003) about a principled approach to
learning a programming language by decomposing it into syntax, dynamic,
and static semantics.  Grossman uses that approach in CSE 341
Programming Languages at the University of Washington and in his popular
[Programming Languages MOOC][pl-mooc].

In Spring 2008 the course had two recitation sections, a dozen course
staff, and about 60 students. As of Fall 2018, a decade later, the
course has thirteen recitation sections, about 50 course staff, and
about 330 students.  The material covered in the course continues to
evolve.  In [Fall 2015][cs3110-2015fa] the "recitations as second
lectures" model was eliminated, causing the course to focus on a smaller
number of core topics.  At the same time an increased emphasis on
software engineering began, including an open-ended software development
project.

In [Fall 2018][cs3110-2018fa] the development of this textbook began.
It synthesizes the work of two decades of programming instruction at
Cornell.  In the words of the Cornell [Evening Song][eveningsong],

>'Tis an echo from the walls<br/>
>Of our own, our fair Cornell.


[cs212-1999fa]: http://www.cs.cornell.edu/courses/cs212/1999FA/Materials.html
[cs410-1998sp]: http://www.cs.cornell.edu/courses/cs410/1998sp/schedule.html
[cs312-2002fa]: http://www.cs.cornell.edu/courses/cs312/2002fa/lectures.htm
[cs312-2001sp]: http://www.cs.cornell.edu/courses/cs312/2001sp/overview.html
[cs312-2008sp]: http://www.cs.cornell.edu/courses/cs312/2008sp/overview.html
[cs3110-2008fa]: http://www.cs.cornell.edu/courses/cs3110/2008fa/schedule.html
[cs3110-2014fa]: http://www.cs.cornell.edu/courses/cs3110/2014fa/course_info.php
[cs3110-2015fa]: http://www.cs.cornell.edu/courses/cs3110/2015fa/
[cs3110-2018fa]: https://www.cs.cornell.edu/courses/cs3110/2018fa/textbook
[eveningsong]: https://alumni.cornell.edu/download/3542/
[pl-mooc]: https://www.coursera.org/learn/programming-languages