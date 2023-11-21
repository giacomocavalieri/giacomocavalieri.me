---
id = "what-if-best-practices-were-the-norm"
title = "What if best practices were the norm?"
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

_What if best practices were the norm?_

## Lies, lies, lies

Java is a powerful language that gives us a lot of room to write clean,
expressive code.
However, with great power comes great responsibility and we have to learn that
even some of the core "features" of the language can turn into a footgun if not
used with great care.
That's why we need some rules to constrain ourselves and make sure our programs
will be well-behaved under all circumstances.

Take for example null references, the bane of every Java programmer's
existence. Every time we return `null` from a method we are condemning another
programmer — or our future selves — to deal with a much dreaded
`NullPointerException`.

The problem is that `null`s are a sneaky way for our methods to _lie_ about
their actual behaviour. To see what I mean by that, let's look at an example:

```java
class User {
  // For this super simple example a User just has an id and a name
  public final int id;
  public final String name;

  public User(final int id, final String name) {
    this.id = id;
    this.name = name;
  }

  public static User find(int id) {
    // ...
  }
}
```

The implementation of `find` is not important, and it shouldn't be!
This method may fetch a user from a database, an in-memory store, or somewhere
else entirely.
The point is we don't want to go and dive into the implementation of every
method we use.
To me, that's where the beauty of static types lies: just by reading the
signature of a method we can get a pretty good hunch of what to expect.

So, what is `find`'s signature telling us?
_"Give me an int and I'll get you a `User`"_. Great! Let's put it to good use
and do something useful:

```java
class Main {
  public static void main(String[] args) {
    User user = User.load(1);
    System.out.println("The user with id 1 has name " + user.name);
  }
}
```

A seasoned Java developer might already have spotted the myriad of ways in
which this seemingly harmless snippet of code could fail: if `load` returns a
null reference or throws a runtime exception our code will crash at runtime.
But how am I expected to know that when the method is lying about its behaviour?
It says that it returns a `User` when in fact it might return a null reference
or just crash with an exception and return nothing at all!

We have to _remember_ to check for null references and catch possible
exceptions:

```java
class Main {
  public static void main(String[] args) {
    try {
      User user = User.load(1);
      if (user != null) {
        System.out.println("The user with id 1 has name " + user.name);
      } else {
        System.out.println("There's no user with id 1");
      }
    } catch {
      System.out.println("Error loading the user with id 1");
    }
  }
}
```

The crux of the problem is that _nothing forced me to add any check!_ I had to
be diligent and remember to add those. The easy thing to do — simply accessing
the name property of the user, disregarding any possible check — is not the
correct one!
It follows that forgetting to add a null check or a try-catch is bound to
happen; it's not a matter of _if_, but _when_: developers can be in a rush,
have tight deadlines, or simply be tired after many hours in front of a screen!

### Gleam to the rescue

What if, instead of having to be always on the lookout, the language could
make sure that no function failure could go undetected? That sounds almost too
good to be true but as it turns out, not only is this possible, but it's also
easier than you might expect!

Enters Gleam: a friendly, simple, and pragmatic programming language that, among
other things, has no runtime exceptions or null pointers! Let's see how the
example I showed you earlier in Java might look in Gleam:

```gleam
type User {
  // For this super simple example a User just has an id and a name
  User(id: Int, name: String)
}
```

With this definition we're creating a `User` type and saying that users only
have two fields called "id" and "name" with types `Int` and `String`.
We could define a couple of users like this:

```gleam
pub fn main() {
  let rob = User(1, "Rob")
  let ben = User(2, "Ben")
}
```

> As you might have noticed, keywords aside, this is not extremely different
> from the Java version, there's no `new` keyword to create things and you might
> be wondering where all the getters and setters have gone.
> Bear with me, we'll get to that later.

And now onto the most important piece: the function to load users; as usual
we don't care about its implementation, with a quick look at its type we can
already discover what matters most.

```gleam
pub fn load(id: Int) -> Result(User, Nil) {
  //                 ^^ the return type of the function
  //                    comes after this arrow
  // ...
}
```

The function doesn't simply return a `User` but a special type: a `Result`.
What does it mean? In case everything goes right the function is going to return
a user, as expected. However, in case something goes wrong we're getting a `Nil`
instead. So the function can still fail (and it will) but it's impossible to
forget about it! A `Result` acts as a glaring and _unmistakable sign_ that
things might not turn out as expected.

The invaluable advantage this approach gives us is that we're no longer on our
own when performing error checking. The compiler can now point out every single
piece of code where things might fail that we forgot to check.
It's like having _a friendly programmer by our side who never gets tired_; they
can point to all of our pieces of code that, if not taken care of, might turn
into runtime exceptions. Let's see what happens if we're not careful with the
`load` function:

```gleam
// This is how you define the main in Gleam
pub fn main() {
  let user = load(1)
  io.println("The user with id 1 has name " <> user.name)
  //                                            ^^^^^
  // This field does not exist.
  // The value being accessed has this type:
  //
  //     Result(User, Nil)
  //
  // It does not have any fields.
}
```

The code won't even compile! We're trying to treat a `Result` like a `User` but
that's not possible, since a call to `load` might have failed. Compare this with
the Java example I showed you earlier, where the compiler would gladly accept
our code even though it could result in a runtime exception.

### Pattern matching, or the superpower of functional programming

How can we get a user out of a `Result`, then? That can be achieved with
_pattern matching._ So to get our example to compile we can do something like
this:

```gleam
pub fn main() {
  case load(1) {
    Ok(user) -> io.println("The user with id 1 has name " <> user.name)
    Error(Nil) -> io.println("There's no user with id 1")
  }
}
```

Pattern matching allows you to check the shape of data; in this case, we can
take different actions based on the result of the loading function: if
everything went smoothly we will have a user in the `Ok` branch.
Once again, we will never forget that a user can be missing because we're forced
to deal with the `Error` branch as well.
But what if we wanted to deal with more complex errors? A user might be missing, or
there could be problems with the connection to the database (if we're fetching
users from there)... just getting a generic `Error(Nil)` won't cut it.

Luckily it's extremly easy to change the code, first of all we need a new type
to describe the possible errors that may take place:

```gleam
pub type LoadError {
  UserNotFound
  ConnectionError
}
```

Now the function can return a specific error in case something goes wrong.

```gleam
pub fn load(id: Int) -> Result(User, LoadError) {
  // ...
}
```

Notice how the function is now saying that it will return a more specific
`LoadError` in case something goes wrong; that can be fundamental to deal with
different failures in different ways.
After this refactor we will be forced by the compiler to deal with every single
error that may occur in the function, luckily that's as simple as adding a new
branch to our previous pattern matching:

```gleam
pub fn main() {
  case load(1) {
    Ok(user) -> io.println("The user with id 1 has name " <> user.name)
    Error(UserNotFound) -> io.println("There's no user with id 1")
    Error(ConnectionError) -> io.println("There was a connection error!")
  }
}
```

> Being able to deal with errors like this is incredibly powerful, we do not
> have to add new ad-hoc contructs to the languaguage like try-catch blocks.
> One of the design goals of Gleam is to be simple, it doesn't even have if
> statements, it does everything through pattern matching!
> If you're curious to learn more about Gleam's syntax Erika Rowland wrote a
> great blog post about it,
> [do check it out!](https://erikarow.land/notes/gleam-syntax)

### Correct made easy

Let's take a second to appreciate this: by forcing a function to be explicit
about the fact that it can fail we no longer have to rely on "best practices"
(never return null references, don't use exceptions as a control flow mechanism,
remember to check if objects coming from other functions are null, etc.).
_The easy thing to do is also the right one_ because that's the only way to
write code!

A beginner who's just started to learn Gleam won't see mysterious
runtime exceptions popping up in their fun learning project just because they
didn't know a slew of unwritten rules people are expected to know.
An experienced Java developer won't have to waste time trying to trace back
where that pesky `null` came from because a `NullPointerException` was reported
in production.

A program won't crash at runtime because it's impossible for an error to go
undetected.
And, as I hope you might have noticed, the language doesn't have to be complex
to give you these guarantees! On the contrary, it makes things easier: there's
only one control flow mechanism — pattern matching — and you don't have to
juggle between if statements and try-catch blocks to deal with all the possible
ways a method might lie.

## WIP: Be scared by mutable data

When learning Java our teacher really drilled into us a rule of thumb to always
follow: _always remember to make every single field of a class `final`,_
_removing the `final` annotation should only ever be used as a last resort._

The rationale behind this practice is that having immutable data structures can
help us be more productive by making it easier to refactor and reason about
code.

It makes it incredibly harder to refactor our code and move things around: all
of a sudden we find ourselves caught in a web of invisible dependencies threaded
throughout every method call. The order of every single method call that takes
as input a mutable object is important! We only have two ways out: fuck around
and find out, hoping our tests will catch any error; painstakingly check every
method call and make sure it doesn't change the object.

This is another great example of turning a best practice into the only possible
way to write code. If making things immutable has so many advantages let's make
it the only possible way to do things! Gleam does exactly that: every data
structure defined in Gleam is immutable by default.

## TODO

- Rivedere la parte del pattern matching, non sono convintissimo di come è
  scritta

- What are best practices
  - Give an idea
  - Provide a running example
    - User with some field (birthday, ID and name so I can also drill down on
      immutability)
    - It should start dumb and then improve it to show some best practices!
      - favour immutability (gives us peace of mind)
      - no null
        - a function can lie!
        - the bane of every Java programmer
        - we have to do a lot of defensive programming
        - the compiler is not helping us, so we have to always be on the lookout
      - no runtime exceptions as a control flow mechanism
        - a lot of similarities with null
        - yet another distinct mechanism to deal with control flow
      - As programmers, we're incredibly good at ignoring the million possible
        ways in which our software could fail and focus only on the happy path
  - The problem with best practices
    - Those are... _practices_! They can be completely ignored, I'll never have
      the guarantee that the code I'm using, or my colleagues are writing will
      follow those
    - Having rules that can be ignored is like having none at all, we're always
      on the lookout
    - Even the most skilled Java programmer will eventually forget a null check
      and allow some sneaky bug to enter the codebase
    - We have to be welcoming to new developers, if to be a good Java developer
      you have to be aware of a dozen unwritten rules you're doing a horrible
      job at making beginners productive in your language
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
    - A beginner is immediately productive and won't be able to mess up as
      easily
      - The language shows you a single, well-defined path: it gently pushes you
        into a "pit of success", instead of dropping you in the middle of a maze
        of choices you have to painfully and carefully evaluate
