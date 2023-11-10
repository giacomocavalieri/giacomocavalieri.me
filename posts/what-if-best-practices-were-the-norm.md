---
id = "what-if-best-practices-were-the-norm"
title = "What if best practices were actually the norm?"
abstract = "No abstract yet"
tags = ["gleam", "fp"]
date = "2023-10-25"
status = "show"
---

During my second year of university I followed an amazing course dedicated to
object-oriented programming, held by one of the best professors I've
ever had the pleasure to meet. It focused not only on the language in itself
— Java, in this case — but also on the _best practices_ we ought to follow to
make code easier to refactor and reason about.
To me, a freshman who only knew C, that felt almost like magic and I quickly
fell in love with Java.

Quite a few years have passed since then, and my honeymoon phase with Java is
long over. As I learned new languages and grew as a developer, I've come to
dislike a lot of the ceremonies and self-imposed restrictions that can come with
good object-oriented code.

What if the best practices I'm forcing myself to follow (with good reason, don't
get me wrong!) were easier to adopt and put into practice? Heck, what if they
were _the only way_ to write code and not some rule that could be ignored?

_What if best practices were actually the norm?_

## What's a best practice?

Java is a powerful language and gives us a lot of room to write clean,
expressive code.
However, with great powers comes great responsibility and we have to learn that
even some of the core "features" of the language can turn into a footgun if not
used with great care.

The best practices I'm going to cover are mostly unwritten rules that we need to
_constrain_ Java and make sure our code will be well-behaved.

### A running example

Imagine you're tasked to write a class to describe the users of an application,
for now we're just focused on storing a user's name and birthday.

> I know this example may sound a bit simplistic, a user will surely be way
> more complicated in a real-world scenario.
> Bear with me, we'll be able to learn a lot of things even from such a
> bare-bones example.

Now, a programmer who's just getting started with Java might intuitively write
something dead simple that looks like this:

```java
class User {
  String name;
  Date birthday;

  User(String name, Date birthday) {
    this.name = name;
    this.birthday = birthday;
  }
}
```

A seasoned Java developer will probably be horrified by this small code snippet:
a lot of subtle sources of bugs and runtime exceptions hide in this seemingly
harmless piece of code. We'll come to this later, but you can already start to
notice how the simple and immediate thing is not the best one!

### `null`, or the bane of every Java programmer

## TODO

- What are best practices
  - Give an idea
  - Provide a running example
    - User with some field (birthday, ID and name so I can also drill down on
      immutability)
    - It should start dumb and then improve it to show some best practices!
      - favour immutability (gives us peace of mind)
      - no null
        - a function can lie!
        - the bane of every java programmer
        - we have to do a lot of defensive programming
        - the compiler is not helping us, so we have to always be on the lookout
      - no runtime exceptions as a control flow mechanism
        - a lot of similarities with null
        - yet another distinct mechanism to deal with control flow
      - As programmers we're incredibly good at ignoring the milion possible
        ways in which our software could fail and focus only on the happy path
  - The problem with best practices
    - Those are... _practices_! They can be completely ignored, I'll never have
      the guarantee that the code I'm using, or my colleagues are writing will
      follow those
    - Having rules that can be ignored is like having none at all, we're always
      on the lookout
    - Even the most skilled Java programmer will eventually forget a null check
      and allow some sneaky bug to enter the codebase
    - We have to be welcoming to new developers, if to be a good java developer
      you have to be aware of a dozen of unwritten rules you're doing a horrible
      job at making begginers productive in your language
  - Enters Gleam
    - Best practices become the rule of the game, the only way to write software
      is the "good" way
    - No need to do null checking, there's no null
    - No exceptions, a function has to be explicit about possible failures
      - We do everything with pattern matching, no need for special mechanisms
        like exceptions
    - The compiler is our greatest ally, I like to think of it as if I'm pair
      programming with someone way smarter than me who can pinpoint every
      possible piece of code where things could go wrong
      - It reminds me where my code could fail and forces me to handle it,
        so there's no way I'm forgetting to check if loading a user failed, even
        after 20 hours in front of a screen
    - A begginer is immediately productive and won't be able to mess up as
      easily
      - The language shows you a single, well-defined path: it gently pushes you
        in a "pit of success", instead of dropping you in the middle of a maze
        of choices you have to painfully and carefully evaluate
