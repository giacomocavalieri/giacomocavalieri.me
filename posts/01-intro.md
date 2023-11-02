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
What gave me the push I needed to get started was an awesome programming
language I run into almost a year ago: [Gleam](https://gleam.run).

When I start learning a new language, I usually try to pick up a small-ish
project to help keep me motivated; the idea of writing a personal blog was
already in the back of my mind, so when I approached Gleam I decided to write...
you guessed it: a static site generator!

Long story short, I never actually completed my side project; but during this
journey I fell in love with Gleam and its community and I decided to stick
around and set up this blog to share my thoughts.

> If you're wondering, this blog is still written using Gleam; I ended up
> using a brilliant package called [lustre](https://lustre.build).
> Do check it out!

## Simple and productive

The first thing that amazed me is how easy it is to pick up Gleam and be
productive with it, even from day one.
That's because Gleam is a remarkably simple language: a couple of evenings could
be enough for you to learn all there is to its core and start hacking on your
own projects.

> _"But what if I've never tried functional programming before?_
> _Will I find it easy anyways?"_
>
> Getting into functional programming can be a bit daunting.
> I remember when I first got started with it — almost four years ago — I
> gave up twice before it finally clicked.
> That's totally normal! FP has its own way of doing things and it can require
> quite the mindset shift and a lot of head scratching to get used to it.
>
> If you've never tried functional programming or — just like me — you've tried
> and were discouraged, I can recommend the
> [Gleam's Exercism track](https://exercism.org/tracks/gleam/concepts): it will
> guide you through the language and gently help you get in the "functional"
> mindset!

But what does simple actually mean? To me it's the ability to _concisely put my_
_ideas into code without having to trudge through loads of bells and whistles,_
having to painstakingly decide which is the right fit for the problem at
hand.

The language offers you a _small number of features_ that are
_useful and cohesive,_ there's no two ways to do the same thing.
Coming from languages with a huge surface — like Scala, Kotlin or C#, just to
name a few — it feels almost exhilarating: the language only allows you to
follow a single, well-defined path instead of dropping you in the middle of a
maze of choices.

### Ok, but what does Gleam look like?

Enough talk, let's have a look at a Gleam program:

```gleam
import gleam/io

/// A pet can either be a cat or a dog,
/// in either case they have a name
///
pub type Pet {
  Cat(name: String)
  Dog(name: String)
}

pub fn speak(pet: Pet) -> String {
  case pet {
    Cat(..) -> "meow"
    Dog(..) -> "woof"
  }
}

pub fn describe(pet: Pet) -> String {
  pet.name <> " goes " <> speak(pet) <> "!"
}

pub fn main() {
  Dog(name: "James")
  |> describe
  |> io.println
  // -> "James goes woof!"
}
```

## An outstanding developer experience

When you start using Gleam, it's impossible not to notice the great
amount of love and work that went into making sure the language has a lovely
developer experience.

Let me show you how straightforward it is to get started and the many niceties
you get out of the box.

### Dead simple setup

Getting started with a new project is incredibly straightforward: just type
`gleam new` and the name of your project and you're ready to start hacking!

```text
> gleam new my_project

Your Gleam project my_project has been successfully created.
The project can be compiled and tested by running these commands:

    cd my_project
    gleam test
```

The CLI tool takes care of all the scaffolding you need; and you also get some
additional niceties out of the box: a `.gitignore` tailored for Gleam projects
and a GitHub workflow to run your tests when you push to a repo. For me this
was the cherry on top since I hate writing those!

It's these little details that really show the attention that went into making
sure the developer experience is as smooth as possible.

### No bikeshedding allowed here

The language also ships with a zero configuration code formatter.
I can't stress enough how much I love this zero configuration approach: first,
it ensures a consistent look across all Gleam projects; it's a great quality of
life improvement, especially if you're trying to approach a codebase written by
someone else.

This also gets rid of the problem of endless bikeshedding around the look a
program should have. I once spent a good couple of hours reading through the
documentation and countless options of the Scala formatter, not considering the
time it took me and my team to agree on a single style.

I've been so scarred by this experience that I'll always gladly take the zero
configuration approach over any configurable code formatter, even if the style
is not 100% to my liking.

### The compiler is your friend

Another thing I love about Gleam is how nice its error messages are. The
compiler goes out of its way to display concise and helpful messages. Take for
example this little code snippet:

```gleam
pub type User {
  User(id: Int, name: String)
}

pub fn main() {
  let user = User(id: 1, name: "Rob")
  io.println(user.nam) // <- uh oh, we've made a typo! 
}
```

Let's have a look at the resulting error message:

```text
error: Unknown record field

  ┌─ ./src/app.gleam:6:19
  │
4 │ io.println(user.nam)
  │                ^^^^ Did you mean `name`?

The value being accessed has this type:
    User

It has these fields:
    .id
    .name
```

The compiler highlights the piece of code were something's wrong and tries to be
extra helpful; in this case it is smart enough to guess we've made a typo and
meant to access the `name` property... how nice is that? I personally love the
friendly and helpful attitude of the compiler, it really feels like you have a
buddy constantly helping you and looking out for potential bugs in your code.

## Get in for the language, stay for the amazing community

What really sealed the deal for me was the incredible community that has formed
around the language.

People in the official Discord are welcoming and incredibly nice.
Even after the worst disheartening days at work, chatting with everyone always
managed to lighten my mood.
I've learnt loads of new things just by hanging around and it's just a pleasure
to chat and share things with everyone.
