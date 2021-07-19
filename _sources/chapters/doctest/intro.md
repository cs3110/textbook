# Documentation and Testing

Let's be honest: we all at one time or another have thought that documentation
or testing was a boring, tedious, and altogether postponable task. But with
maturity programmers come to realize that both are essential to writing correct
code.  Both get at the *truth* of what code really does.

**Documentation** is the ground truth of what a programmer intended, as opposed
to what they actually wrote. It communicates to other humans the ideas the
author had in their head. No small amount of the time (even in this book!), we
fail at communicating ideas as we intended. Maybe the failure occurs in the
code, or maybe in the documentation. But writing documentation forces us to
think a second (er, *hopefully* second) time about our intentions. The cognitive
task of explaining our ideas to other humans is certainly different than
explaining our ideas to the computer. That can expose failures in our thinking.

More importantly, documentation is a message in a time capsule. Imagine this:
someone far away and now unreachable has sent that message to you, the
programmer. You need that message to interpret the archeological evidence now in
front of you&mdash;i.e., the otherwise unintelligible source code you have
inherited. Your only hope is that the original author, long ago, had enough
empathy to commit their thoughts to the written word.

And now imagine this: that author from the distant past? **What if they were
YOU?** It might be you from two weeks ago, two months ago, or two years ago.
Human memory is fleeting. If you've only been programming for a couple of years
yourself, this can be difficult to understand, but give it a generous try:
Someday, you're going to come back to the code you're writing today and have no
clue what it means. Your only hope is to leave yourself some breadcrumbs at the
time you write it. Otherwise, you'll be lost when you circle back.

**Testing** is the ground truth of what a program actually does, as opposed to
what the programmer intended. It provides evidence that the programmer got it
right. Good scientists demand evidence. That demand comes not out of arrogance
but humility. We human beings are so amazingly good at deluding ourselves.
(Consider the echo chamber of modern social media.) You can write a piece of
code that you *think* is right. But then you can write a test case that
*demonstrates* it's right. Then you can write ten more. The evidence
accumulates, and eventually it's enough to be convincing. Is it absolute? Of
course not. Maybe there's some test case you weren't clever enough to invent.
That's science: new ideas come along to challenge the old.

Even more importantly, testing is *repeatable* science. The ability to replicate
experiments is crucial to the truth they establish. By capturing tests as
automatically repeatable experiments as unit test suites, we can demonstrate to
ourselves and other, now and in the future, that our code is correct.

**The challenge** of documentation and testing is discipline. It's so tempting,
so easy, to care only about writing the code. "That's the fun part", right? But
it's like leaving out a third of the letter we intended to write. One part of
the letter is to the machine, regarding how to compute. But another part is to
other humans, about what we wanted to compute. And another part is to both
machines and humans, about what we really did manage to compute. Your job isn't
done until all three parts have been written.

If you're not yet convinced about the importance of documentation and testing,
no worries. You will be in the future, if you stick with the craft of
programming long enough. Meanwhile, let's proceed with learning about how to do
it better. In this chapter, we're going to learn about some successful (and
hopefully new-to-you) techniques for both.