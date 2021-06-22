# The Basics of OCaml

This chapter will cover some of the basic features of OCaml. But before we dive
in to learning OCaml, let's first talk about a bigger idea: learning languages
in general.

One of the secondary goals of this course is not just for you to learn a new
programming language, but to improve your skills at learning *how to learn* new
languages.

{{ video_embed | replace("%%VID%%", "A5IHFZtRfBs")}}

There are five essential components to learning a language: syntax, semantics,
idioms, libraries, and tools.

**Syntax.** By *syntax*, we mean the rules that define what constitutes a
textually well-formed program in the language, including the keywords,
restrictions on whitespace and formatting, punctuation, operators, etc. One of
the more annoying aspects of learning a new language can be that the syntax
feels odd compared to languages you already know. But the more languages you
learn, the more you'll become used to accepting the syntax of the language for
what it is, rather than wishing it were different. (If you want to see some
languages with really unusual syntax, take a look at [APL][tryapl], which needs
its own extended keyboard, and [Whitespace][whitespace], in which programs
consist entirely of spaces, tabs, and newlines.) You need to understand syntax
just to be able to speak to the computer at all.

**Semantics.** By *semantics*, we mean the rules that define the behavior of
programs. In other words, semantics is about the meaning of a program&mdash;what
computation a particular piece of syntax represents. Note that although
"semantics" is plural in form, we use it as singular. That's similar to
"mathematics" or "physics".

There are two pieces to semantics, the *dynamic* semantics of a language and the
*static* semantics of a language. The dynamic semantics define the run-time
behavior of a program as it is executed or evaluated. The static semantics
define the compile-time checking that is done to ensure that a program is legal,
beyond any syntactic requirements. The most important kind of static semantics
is probably *type checking*: the rules that define whether a program is well
typed or not. Learning the semantics of a new language is usually the real
challenge, even though the syntax might be the first hurdle you have to
overcome. You need to understand semantics to say what you mean to the computer,
and you need to say what you mean so that your program performs the right
computation.

**Idioms.** By *idioms*, we mean the common approaches to using language
features to express computations. Given that you might express one computation
in many ways inside a language, which one do you choose? Some will be more
natural than others. Programmers who are fluent in the language will prefer
certain modes of expression over others. We could think of this in terms of
using the dominant paradigms in the language effectively, whether they are
imperative, functional, object oriented, etc. You need to understand idioms to
say what you mean not just to the computer, but to other programmers. When you
write code idiomatically, other programmers will understand your code better.

**Libraries.** *Libraries* are bundles of code that have already been written
for you and can make you a more productive programmer, since you won't have to
write the code yourself. (It's been said that [laziness is a virtue for a
programmer][lazy].) Part of learning a new language is discovering what
libraries are available and how to make use of them. A language usually provides
a *standard library* that gives you access to a core set of functionality, much
of which you would be unable to code up in the language yourself, such as file
I/O.

**Tools.** At the very least any language implementation provides either a
compiler or interpreter as a tool for interacting with the computer using the
language. But there are other kinds of tools: debuggers; integrated development
environments (IDE); and analysis tools for things like performance, memory
usage, and correctness. Learning to use tools that are associated with a
language can also make you a more productive programmer. Sometimes it's easy to
confuse the tool itself for the language; if you've only ever used Eclipse and
Java together for example, it might not be apparent that Eclipse is an IDE that
works with many languages, and that Java can be used without Eclipse.

[tryapl]: http://tryapl.org/
[whitespace]: https://web.archive.org/web/20151108084710/http://compsoc.dur.ac.uk/whitespace/tutorial.html
[lazy]: http://threevirtues.com/

When it comes to learning OCaml in this book, our focus is primarily on
semantics and idioms. We'll have to learn syntax along the way, of course, but
it's not the interesting part of our studies. We'll get some exposure to the
OCaml standard library and a couple other libraries, notably OUnit (a unit
testing framework similar to JUnit, HUnit, etc.). Besides the OCaml compiler and
build system, the main tool we'll use is the toplevel, which provides the
ability to interactively experiment with code.
