---
id = "01-intro"
title = "Look! I made this with Lustre ✨"
abstract = "I still have to decide for an abstract"
tags = ["gleam", "fp"]
date = "2023-10-25"
---

# Look! I made this with Gleam ✨

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

Even though I never actually completed my project, I've fell in love with the
language and I'm really enjoing my time spent around the Gleam community.

## Gleam: get in for the language...

Gleam is a statically-typed functional language that can compile both to the
Erlang virtual machine and to JavaScript.
If I had to describe it with a single word it would be _friendly_; I know this
can sound kind of handwavy, but bear with me.

### Simple and productive

Gleam is a remarkably simple: if you're already familiar with some
functional programming concepts, you'll be able to pick it up in no time.
A couple of evenings could be enough for you to learn all there is to the core
language and start hacking on your own projects.

> _"But what if you've never tried functional programming before?_
> _Will I find it easy?"_
>
> Getting into functional programming can be a bit daunting.
> I remember when I first got started with it - almost four years ago - I
> gave up twice before it finally clicked.
> That's totally normal! FP has its own way of doing things and it can require a
> bit of a mindset shift and a lot of head scratching you get used to it.
>
> If you've never tried functional programming or - just like me - you've tried
> and where discouraged, I can recommend you the
> [Gleam's Exercism track](https://exercism.org/tracks/gleam/concepts): it will
> guide you through the language and gently help you get in the "functional"
> mindset!

But what does simple actually mean? To me it's the ability to _concisely put my_
_ideas into code without having to trudge through loads of bells and whistles,_
having to painstakingly decide which is the right fit for the problem at
hand.
The language offers you a _small number of features_ that are _useful and cohesive,_
there's no two ways to do the same thing.
Everything is carefully though out, and something gets added to the
language only if it is clear that it will add a lot of value to it!

Coming from languages with a huge surface - like Java, C# or Kotlin, just to
name a few - it feels almost exhilarating: the language only allows you to
follow a single, well-defined path instead of leaving you in the middle of a
maze of choices
(_"Wait, should I use an interface here? Or is a class enough?"_,
_"Maybe a record class is the better choice for this problem, or should I stick with a normal one?"_,
_"Shoot, I can't remember how delegates work"_,
_"For the love of me, I can't understand lambdas with receivers!"_).

### Your first Gleam program

Enough talking, let's have a look at a Gleam program.

### What if best practices were actually the norm?

During my second year at university I had to learn Java, there was even an entire
course dedicated to object oriented languages! It really was a great course
and it was held by one of the best professors I've ever had the pleasure to meet.

It focused not only on the language in itself, but also on the "best practices"
to follow that would make code easier to refactor and reason about: favour
immutability, avoid exceptions as a control flow mechanism,
_never_ return `null`, and the list goes on.

The problem is, these are just _practices_, nothing is enforced by the language
itself: you'll always be able to throw an exception or sneakily return a null.
Since a code snippet is worth a thousand words let me show you an example:

```java
interface User {
  String name()
}

class Users {
  // Returns the user with the given id
  public static User load(int id) {
    // The implementation is not important, it may fetch
    // the user from a DB or somewhere else entirely
  }
}

// We can define the main function like this since
// Java 21 with unamed classes (yet another feature)!
void main() {
  var user = Users.load(1)
  System.out.println(user.name())
}
```

A season Java developer will immediately notice all the little ways in which
this seemingly harmless snippet of code could fail. The `load` function is
actually lying to us: it sais it will return a `User`, but in reality it may
throw an exception or even return a sneaky `null` resulting in a much dreaded
`NullPointerException`.

The problem is that someone has to always be on the lookout and remember to add
all kind of checks to ensure the program is never going to unexpectedly fail at
runtime: check that objects are not null, wrap function calls in `try-catch`
blocks, make defensive copies of data structures.

As programmers we're _incredibly good at ignoring the milion possible ways in_
_which our software could fail_ and focus only on the happy path. Sooner or
later, even the best programmer will forget a null check or a try catch,
allowing sneaky bugs to enter in the codebase.

### What if best practices were actually the norm?

```gleam
pub type User

// Returns the user with the given id
pub fn load_user(id: Int) -> Result(User, Nil) {
  // The implementation is not important, it may fetch
  // the user from a DB or somewhere else entirely
}

pub fn main() {
  let user = load_user(1)
  io.println(user.name)
}
```

On the surface, this Gleam snippet may look almost identical to the Java one I
showed you earlier.

Here something truly remarkable is happening, the Gleam compiler lifts this load
from the developer and takes care of it: the language.

### Outstanding developer experience

Gleam as a whole is a pleasure to work with and it provides a lot of 

## ...stay for the amazing community

What really sealed the deal for me was the incredible community that has formed
around the language.

People in the official Discord are welcoming and incredibly nice.
Even after the worst disheartening days at work, chatting with everyone always
managed to lighten my mood.
I've learnt loads of new things just by hanging around and it's just a pleasure
to chat and share things with everyone.
