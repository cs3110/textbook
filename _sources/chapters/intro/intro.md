# Better Programming Through OCaml

Do you already know how to program in a mainstream language like Python or Java?
Good. This book is for you. It's time to learn how to program better. It's time
to learn a functional language, OCaml.

```{Note}
This textbook has about 200 videos embedded in it. The first one is below. The
videos usually provide an introduction to material, upon which the textbook then
expands.

These videos were produced during pandemic when the Cornell course that uses
this textbook had to be asynchronous. The student response to them was
overwhelmingly positive, so they are now being made public as part of the
textbook. But just so you know, they were not produced by a professional A/V
team&mdash;just a guy in his basement who was learning as he went. 😀

The videos mostly use the versions of OCaml and its ecosystem that were current
in Fall 2020. Current versions you are using are likely to look different from
the videos, but don't be alarmed: the underlying ideas are the same. The most
visible difference is likely to be the VS Code plugin for OCaml. In Fall 2020
the badly-aging "OCaml and Reason IDE" plugin was still being used. It has since
been superceded by the "OCaml Platform" plugin.
```

{{ video_embed | replace("%%VID%%", "MUcka_SvhLw")}}

Functional programming provides a different perspective on programming than what
you have experienced so far. Adapating to that perspective requires letting go
of old ideas: assignment statements, loops, classes and objects, among others.
That won't be easy.

> <i>Nan-in, a Japanese master during the Meiji era (1868-1912), received a
> university professor who came to inquire about Zen. Nan-in served tea. He
> poured his visitor's cup full, and then kept on pouring. The professor watched
> the overflow until he no longer could restrain himself. "It is overfull. No
> more will go in!" "Like this cup," Nan-in said, "you are full of your own
> opinions and speculations. How can I show you Zen unless you first empty your
> cup?"</i>

I believe that learning OCaml will make you a better programmer. Here's why:

- You will experience the freedom of *immutability*, in which the values of
  so-called "variables" cannot change. Goodbye, debugging.

- You will improve at *abstraction*, which is the practice of avoiding
  repetition by factoring out commonality. Goodbye, bloated code.

- You will be exposed to a *type system* that you will at first hate because it
  rejects programs you think are correct. But you will come to love it, because
  you will humbly realize it was right and your programs were wrong. Goodbye,
  failing tests.

- You will be exposed to some of the *theory and implementation of programming
  languages*, helping you to understand the foundations of what you are saying
  to the computer when you write code. Goodbye, mysterious and magic
  incantations.

All of those ideas can be learned in other contexts and languages. But OCaml
provides an incredible opportunity to bundle them all together. **OCaml will
change the way you think about programming.**

```{epigraph}
"A language that doesn't affect the way you think about programming is not worth
knowing."

-- Alan J. Perlis (1922-1990), first recipient of the Turing Award
```

Moreover, OCaml is beautiful. OCaml is elegant, simple, and graceful. Aesthetics
do matter. Code isn't written just to be executed by machines. It's also written
to communicate to humans. Elegant code is easier to read and maintain. It isn't
necessarily easier to write.

The OCaml code you write can be stylish and tasteful. At first, this might not
be apparent. You are learning a new language after all&mdash;you wouldn't expect
to appreciate Sanskrit poetry on day 1 of Introductory Sanskrit. In fact, you'll
likely feel frustrated for awhile as you struggle to express yourself in a new
language. So give it some time. After you've mastered OCaml, you might be
surprised at how ugly those other languages you already know end up feeling when
you return to them.
