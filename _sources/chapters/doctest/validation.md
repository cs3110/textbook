# Validation

The goal we're after is that programs behave as we intend them to behave.
*Validation* is the process of building our confidence in correct program
behavior. There are many ways to increase that confidence. Social methods,
formal methods, and testing are three. The latter is the main focus of this
chapter, but let's first consider the other two.

**Social methods** involve developing programs with other people, relying on
their assistance to improve correctness. Some good techniques include the
following:

- *Code walkthrough.* In the walkthrough approach, the programmer presents the
  documentation and code to a reviewing team, and the team gives comments. This
  is an informal process. The focus is on the code rather than the coder, so
  hurt feelings are easier to avoid. However, the team may not get as much
  assurance that the code is correct.

- *Code inspection.* Here, the review team drives the code review process. Some,
  though not necessarily very much, team preparation beforehand is useful. They
  define goals for the review process and interact with the coder(s) to
  understand where there may be quality problems. Again, making the process as
  blameless as possible is important.

- *Pair programming.* The most informal approach to code review is through pair
  programming, in which code is developed by a pair of engineers: the driver who
  writes the code, and the observer who watches. The role of the observer is be
  a critic, to think about potential errors, and to help navigate larger design
  issues. It's usually better to have the observer be the engineer with the
  greater experience with the coding task at hand. The observer reviews the
  code, serving as the devil's advocate that the driver must convince. When the
  pair is developing specifications, the observer thinks about how to make specs
  clearer or shorter. Pair programming has other benefits. It is often more fun
  and educational to work with a partner, and it helps focus both partners on
  the task. If you are just starting to work with another programmer, pair
  programming is a good way to understand how your partner thinks and to
  establish common vocabulary. It is a good idea for partners to trade off
  roles, too.

These social techniques for *code review* can be remarkably effective. In one
study conducted at IBM (Jones, 1991), code inspection found 65% of the known
coding errors and 25% of the known documentation errors, whereas testing found
only 20% of the coding errors and none of the documentation errors. The code
inspection process may be more effective than walkthroughs. One study (Fagan,
1976) found that code inspections resulted in code with 38% fewer failures,
compared to code walkthroughs.

Thorough code review can be expensive, however. Jones found that preparing for
code inspection took one hour per 150 lines of code, and the actual inspection
covered 75 lines of code per hour. Having up to three people on the inspection
team improves the quality of inspection; beyond that, more inspectors doesn't
seem to help. Spending a lot of time preparing for inspection did not seem to be
useful, either. Perhaps this is because much of the value of inspection lies in
the interaction with the coders.

**Formal methods** use the power of mathematics and logic to validate program
behavior. *Verification* uses the program code and its specifications to
construct a proof that the program behaves correctly on all possible inputs.
There are research tools available to help with program verification, often
based on automated theorem provers, as well as research languages that are
designed for program verification. Verification tends to be expensive and to
require thinking carefully about and deeply understanding the code to be
verified. So in practice, it tends to be applied to code that is important and
relatively short. Verification is particularly valuable for critical systems
where testing is less effective. Because their execution is not deterministic,
concurrent programs are hard to test, and sometimes subtle bugs can only be
found by attempting to verify the code formally. In fact, tools to help prove
programs correct have been getting increasingly effective and some large systems
have been fully verified, including compilers, processors and processor
emulators, and key pieces of operating systems.

**Testing** involves actually executing the program on sample inputs to see
whether the behavior is as expected. By comparing the actual results of the
program with the expected results, we find out whether the program really works
on the particular inputs we try it on. Testing can never provide the absolute
guarantees that formal methods do, but it is significantly easier and cheaper to
do. It is also the validation methodology with which you are probably most
familiar. Testing is a good, cost-effective way of building confidence in
correct program behavior.
