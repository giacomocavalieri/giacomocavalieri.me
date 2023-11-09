---
id = "what-if-best-practices-were-the-norm"
title = "What if best practices were actually the norm?"
abstract = "No abstract yet"
tags = ["gleam", "fp"]
date = "2023-10-25"
status = "show"
---


During my second year of university I followed a course dedicated to
object-oriented programming. It was an amazing course, held by one of the best
professors I've ever had the pleasure to meet: it focused not only on the
language in itself — Java, in this case — but also on the _best practices_
we ought to follow to make code easier to refactor and reason about.
To me — a freshman who only knew C — that felt almost like magic, and I fell
in love with Java.

Quite a few years have passed since then, and my honeymoon phase with Java is
long over. As I learned new languages and grew as a developer, I've come to
dislike a lot of the ceremonies and self-imposed restrictions that can come with
good object-oriented code.

What if the best practices I'm forcing myself to follow (with good reason, don't
get me wrong!) were easier to adopt and put into practice? Heck, what if they
actually were _the only way_ to write code and not some rule that could be
ignored?

_What if best practices were actually the norm?_

---

## What are best practices?

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

class Main {
  public static void main(String[] args) {
    var user = Users.load(1);
    System.out.println(user.name());
  }
}
```

A seasoned Java developer will immediately notice all the little ways in which
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

pub type Prova {
  Prova(prova: Int)
}

pub fn main() {
  let user = load_user(1)
  io.println(user.name)

  case user {
    Ok(foo) -> "baz" == 1
    Error(bar) -> "boo" <> "ben"
  }

  use <- prova(1, 2, 3)
  result.try(foo) |> result.then(1)
}
```

On the surface, this Gleam snippet may look almost identical to the Java one I
showed you earlier.

Here something truly remarkable is happening, the Gleam compiler lifts this load
from the developer and takes care of it: the language.
