---
id = "01-look-i-made-this-with-gleam"
title = "Look! I made this with Gleam ✨"
abstract = "I still have to write a good abstract"
tags = ["gleam", "fp"]
date = "2023-10-29"
status = "show"
---

Hello! I'm Giacomo 👋

I love functional programming and getting caught in rabbit holes; the thing I
love most, though, is sharing what I learn with my friends (sorry guys for
nagging you, you're the best for putting up with me)!

What better way to pester even more people than setting up a personal blog?
What gave me the push I needed to get started was an awesome language I run into
almost a year ago: [Gleam](https://gleam.run).

Whenever I start learning a new language I usually try to pick up a small-ish
project to help me get a feeling for the language and keep me motivated
throughout my learning journey.
The idea of writing a personal blog was already in the back of my mind, so when
I approached Gleam I decided to write... you guessed it: a static site
generator!

Long story short, I never actually completed my side project; but during this
journey I fell in love with the language and its community and I decided to
stick around and set up this blog to share my thoughts.

> If you're wondering, this blog is still written using Gleam; I ended up
> using a brilliant package called [lustre](https://lustre.build).
> Do check it out!

## Simple and productive

Gleam is a remarkably simple language: if you're already familiar with some
functional programming concepts, you'll be able to pick it up in no time.
A couple of evenings could be enough for you to learn all there is to the core
language and start hacking on your own projects.

> _"But what if I've never tried functional programming before?_
> _Will I find it easy?"_
>
> Getting into functional programming can be a bit daunting.
> I remember when I first got started with it — almost four years ago — I
> gave up twice before it finally clicked.
> That's totally normal! FP has its own way of doing things and it can require
> quite the mindset shift and a lot of head scratching to get used to it.
>
> If you've never tried functional programming or — just like me — you've tried
> and were discouraged, I can recommend you the
> [Gleam's Exercism track](https://exercism.org/tracks/gleam/concepts): it will
> guide you through the language and gently help you get in the "functional"
> mindset!

But what does simple actually mean? To me it's the ability to _concisely put my_
_ideas into code without having to trudge through loads of bells and whistles,_
having to painstakingly decide which is the right fit for the problem at
hand.

The language offers you a _small number of features_ that are _useful and cohesive,_
there's no two ways to do the same thing.
Coming from languages with a huge surface — like Scala, Kotlin or C#, just to
name a few — it feels almost exhilarating: the language only allows you to
follow a single, well-defined path instead of dropping you in the middle of a
maze of choices.

### Ok, but what does Gleam look like?

Enough talk, let's have a look at a Gleam program:

```gleam
// this is not going to be the code example, I just need it
// to get a sense of how the code will look!

import gleam/io

pub opaque type Foo {
  Bar(bar: Int, baz: String)
}

/// main!!!
///
pub fn main() {
  let bar = Bar(1, "hello")
  use a <- result.try(Ok(1))
  case bar {
    Bar(1, "h" <> _) -> Error("foo")
    Bar(_, _) -> Ok(11_000)
  }
  Nil |> io.debug
}
```

## An outstanding developer experience

When you start using Gleam, it's impossible not to notice the great
amount of love and work that went into making sure the language has a lovely
developer experience.

Let me show you how straightforward it is to get started and the many niceties
you get out of the box.

TODO list:

- getting started with a project is as easy as `gleam new`
  - you get all the scaffolding needed to start hacking
  - and some niceties like a github action to run tests in CI (it just shows
    the great amount of care that went into it)
- zero configuration formatter out of the box
  - no bikeshedding (that's huge!)
    - personal experience with scala
    - hours lost with my friends
- friendly and helpful compiler
  - great error messages
    - some examples!
  - your greatest ally

## Get in for the language, stay for the amazing community

What really sealed the deal for me was the incredible community that has formed
around the language.

People in the official Discord are welcoming and incredibly nice.
Even after the worst disheartening days at work, chatting with everyone always
managed to lighten my mood.
I've learnt loads of new things just by hanging around and it's just a pleasure
to chat and share things with everyone.
