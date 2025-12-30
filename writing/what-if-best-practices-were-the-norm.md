---
id = "what-if-best-practices-were-the-norm"
title = "What if best practices were the norm?"
abstract = "During my second year of university I followed a course dedicated to object-oriented programming and quickly fell in love with Java. My honeymoon phase with it is long over and I've come to dislike a lot of the ceremonies and self-imposed restrictions that can come with good object-oriented code. So _what if the best practices I'm forcing myself to follow were easier to adopt and put into practice?_"
tags = ["gleam", "fp"]
date = 2024-02-26
status = "show"
---

> For my Italian speakers, there's also a
> [video recording](https://youtu.be/PpasgrDsKis?si=Tq_zt3jJ_KGH1lsv)
> of a talk I did about the same topic.
> If you prefer listening to stuff you might enjoy it!

During my second year of university I followed an amazing course dedicated to
object-oriented programming, held by one of the best professors I've
ever had the pleasure to meet. It focused not only on the language in itself
-- Java, in this case -- but also on the _best practices_ we ought to follow to
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
even some of the core features of the language can turn into a footgun if not
used with great care.
That's why we need some rules to constrain ourselves and make sure our programs
will be well-behaved under all circumstances.

Take for example null references, the bane of every Java programmer's
existence. Every time we return `null` from a method we are condemning another
programmer -- or our future selves -- to deal with a much dreaded
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

  public static User load(int id) {
    // ...
  }
}
```

The implementation of `load` is not important, and it shouldn't be!
This method may fetch a user from a database, an in-memory store, or somewhere
else entirely.
The point is we don't want to go and dive into the implementation of every
method we use.
To me, that's where the beauty of static types lies: just by reading the
signature of a method we can get a pretty good hunch of what to expect.

So, what is `load`'s signature telling us?
"Give me an int and I'll get you a `User`"
Great! Let's put it to good use and do something useful:

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

The crux of the problem is that _nothing forced me to add any checks!_ I had to
be diligent and remember to add those. The easy thing to do -- simply accessing
the name property of the user, disregarding any possible check -- is not the
correct one!
It follows that forgetting to add a null check or a try-catch is bound to
happen; it's not a matter of _if_, but _when:_ developers can be in a rush,
have tight deadlines, or simply be tired after many hours in front of a screen!

### Gleam to the rescue

What if, instead of having to be always on the lookout, the language could
make sure that no function failure could go undetected? That sounds almost too
good to be true but as it turns out, not only is this possible, but it's also
easier than you might expect!

Enters [Gleam](https://gleam.run): a friendly, simple, and pragmatic programming
language that, among other things, has no runtime exceptions or null pointers!
Let's see how the example I showed you earlier in Java might look in Gleam:

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
  //                                               ^^^^^
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
_pattern matching._ To get the previous broken code snippet to compile we can do
something like this:

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
But what if we wanted to deal with more complex errors?
A user might be missing, or there could be problems with the connection to the
database (if we're fetching users from there)...
just getting a generic `Error(Nil)` won't cut it.

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
remember to check if objects coming from other functions are null, so on and so
forth).
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
only one control flow mechanism -- pattern matching -- and you don't have to
juggle between if statements and try-catch blocks to deal with all the possible
ways a method might lie.

> _Addendum: what about Optional?_
>
> After posting this online I received some great feedback: people pointed that
> one could use Java's `Optional` to help avoid `null`s. That's a good point!
> `Optional` is a life saver and I always rely on it when writing Java code.
> My point still stands: _deciding to use it is a best practice_,
> it's not the only possible way to write Java code that deals with missing
> values.
>
> It can only give us some safety if we're diligent and use it properly,
> remember this is still perfectly valid Java code:
>
> ```java
> public static Optional<User> load(int id) {
>   return null;
>   // Optional is an object after all!
> }
> ```
>
> To add to the point, it's not that beginner friendly: I've been a teaching
> assistant for a couple of years now, and I've lost count of the number of
> students trying to do this:
>
> ```java
> Optional.of(someObject)
> ```
>
> Can you spot the bug? If `someObject` is `null` this will still result in a
> `NullPointerException`! These are bright students and have been taught that
> the proper way to do that is using `Optional.ofNullable`, they've even been
> shown examples doing it.
> But _there's only so many rules that one can remember to apply off the top their head_
> and this is such an easy mistake that I see it regularly in students' code.

## Beware of mutable data

When learning Java our teacher really drilled into us a rule of thumb to always
follow: _always favour immutable data structures,_ when defining a class
always make its fields `final`.

This is great advice! Removing the final annotation should only be used as a
last resort. The rationale behind this practice is that having immutable data
structures can make it easier to refactor and reason about code.

Over-relying on mutable state can quickly turn into an headache. Imagine users
can now store their own birthday:

```java
class User {
  public final int id;
  public final String name;
  public final Date birthday;

  public User(final int id, final String name, final Date birthday) {
    this.id = id;
    this.name = name;
    this.birthday = birthday;
  }

  // ...
}
```

Since all the user's fields are `final` we can be sure that whoever is going to
get a hold of a reference to a user is not going to be able to modify it:

```java
User user = User.load(1);
user.id = 12;
// This is a compile time error, nice!
```

Beware! We're still not completely safe from some mutability-related bugs.
We have to remember that `Date` is a _mutable_ data structure: whoever gets a
hold of a user might not be able to change its id or name, but can do whathever
they want with their birthday.

```java
User user = User.load(1);
user.birthday.setYear(1900);
```

And now, all of a sudden, we have a really old user! Since mutation can happen
anywhere, it can be incredibly hard to trace back to the source of the problem
and might require quite the debugging ability -- and I, for one, don't have it.

### A web of dependencies

An even hairier problem arise when we start sharing mutable data:

```java
Date birthday = new Date(1998, 10, 11)
User jak = new User(1, "Jak", birthday)
User tom = new User(1, "Tom", birthday)
//   ^^^ That's my twin!
```

We're passing around two references to a single heap-allocated object.
Now if one of the two users tries and change its birthday the same change will
reflect on the other one, that's some spooky action at a distance!

And now since there's more places that rely and can change that same value, the
order with which we call our functions becomes crucial:

```java
jak.isOver18() // -> true
tom.birthday.setYear(2010);
jak.isOver18() // -> false
```

We might end up breaking some invariants by simply moving a line of code
around, talk about fiddly! We are caught in a web of invisible dependencies
threaded throughout every method call: the order of every single method call
that takes as input a mutable object is important!
A strong testing suite can really help us giving confidence that our
innocent-looking refactoring didn't actually break some important properties --
easier said than done!

Is there a way out? Sort of. We can make our best to encapsulate the state of
objects and never leak references to objects we don't want others to change:

```java
class User {
  private final Date birthday;

  public User(final int id, final String name, final Date birthday) {
    this.id = id;
    this.name = name;
    this.birthday = new Date(birthday);
    //              ^^^^^^^^^^^^^^^^^^ Here we're making a defensive copy
  }

  public Date getBirthday() {
    return new Date(this.birthday);
    //     ^^^^^^^^^^^^^^^^^^^^^^^^ We return a copy of the user's birthday
  }

  // ...
}
```

By storing and returning copies we're making sure that no one can put their
hands on the user's birthday. Mutation can now happen in a single place -- the
`User` class -- and can be tamed much more easily.

### Making best practices the rules of the game

Our naïve attempt at writing a `User` class was riddled with small problems and
endless possible sources of bugs. Once again, we had to
_be careful and remember_ to always store and return copies of potentially
mutable data, effectively making it immutable.

_If making things immutable is desirable why not make it the default?_
This is another great example of turning a best practice into the only possible
way to write code. If making things immutable has so many advantages let's make
it the only possible way to do things! Every data structure defined in Gleam is
immutable by default:

```gleam
let birthday = Date(1998, 10, 11)
let jak = User(1, "Jak", birthday)
let tom = User(1, "Tom", birthday)
```

Is it safe to share the same `birthday` here, or are we bound to run into the
same issues we found in the corresponding Java version? Since everything is
immutable we can answer with peace of mind: _yes, it's safe!_
Let's appreciate how we now have one less thing to constantly worry about.

> _"But how can I do anything useful if I can't mutate data?"_ I hear you cry.
> You're right, you can't write a program the same way you would if you could
> mutate data; you can't even have a `for` loop -- after all, even increasing a
> loop counter counts as mutation and that's not allowed.
>
> It can require some getting used to at first but trust me, it's absolutely
> possible to write useful programs even if you can't mutate stuff.
> For now I'll just focus on the advantages this approach gives us and
> I'm not going to explain _how_ to program with immutable data. That might be
> worthy of a blog post of its own in the future.

## The art of code formatting

Learning a programming language is only a small part of the picture, though.
As developers, we also have to rely on a variety of tool: linters, formatters,
build tools, and the list could go on.
For this blog post I'll focus on my favourite one: formatters.

### Consistency is key

I've never understood people who claim that programming is boring. Personal
taste, creativity and imagination play such an important role in coding that if
you ask a thousand developers to implement the same algorithm you'll probably
get a thousand of different answers.

That's the beauty of programming -- and what made me fall in love with it in the
first place. However, it can also turn into an endless source of teeth grinding
when working with other developers: we all have different tastes and everyone
will push for their own style to be adopted. Take this small snippet of code,
there's probably a million different ways it could be formatted:

```gleam
case user {
  User(_id, "Giacomo", _birthday) -> io.println("Hello, Giacomo")
  User(_) -> io.println("Wait, who are you?")
}
```

What if we want to vertically align the `case`'s arrows?

```gleam
case user {
  User(_id, "Giacomo", _birthday) -> io.println("Hello, Giacomo")
  User(_)                         -> io.println("Wait, who are you?")
}
```

Mmh or maybe we could separate each `case` branch with a newline to make code
breathe a bit better:

```gleam
case user {
  User(_id, "Giacomo", _birthday) -> io.println("Hello, Giacomo")

  User(_) -> io.println("Wait, who are you?")
}
```

We could even decide to put what comes after the arrow on its own line:

```gleam
case user {
  User(_id, "Giacomo", _birthday) ->
    io.println("Hello, Giacomo")

  User(_) ->
    io.println("Wait, who are you?")
}
```

I could go on for days adding small tweaks to the look of this bit of code.
And it can be quite a fun exercise! Finding the best looking possible solution
is really satisfying after all -- and I love doing that from time to time.

The point is that we want to avoid these kind of inconsitencies in style at all
costs when working with other people: imagine having a codebase where sometimes
things get indented with two spaces, and sometimes with four! So, in order to
enforce a single style we rely on formatters: a nifty tool take ingests your
code and spits it out it in a pretty format with consistent style.

> I can't express how much I love formatters, most of my contributions to the
> Gleam compiler are in its formatter and I even wrote a pretty printing package
> in Gleam, if you're curious to learn how formatting works I can recommend
> reading [its docs](https://hexdocs.pm/glam/), it's full of examples!

### Finding the perfect style

Formatters usually come with some levers you can pull to tweak the final look
of your code: decide how many spaces the indentation is, wether to remove
trailing commas, vertically align arrows and variables...
the possibilities are endless.

Back in my university days I remember doing a group project with three friends
in Scala. We decided to use [scalafmt](https://scalameta.org/scalafmt/), a
formatter that comes with more than 70 (I started counting and then got
tired) such levers. I had the greatest fun reading through the documentation
and discovering all choices I could make; needless to say, we spent
_way too much time_ trying to agree on the final style.

### No bikeshedding allowed here

Sometimes having too much freedom can be counter productive. Having a
configurable formatter can have some drawbacks: first of all you'll have to
take your time to decide the formatter configuration, decision fatigue anyone?
And then what happens if the configuration doesn't fit one's tastes? Knowing
that it can be changed will inevitably lead to someone proposing to change it!
What's worse is that different projects will most likely have different styles.

Gleam does something really cool in my opinion: the language comes with a
built-in formatter with _zero configuration._ Loosing the ability to tweak the
output of the formatter has some nice consequences: first of all, it's
impossible to lose time bikeshedding. All choices about the look of Gleam code
are taken by the language, developers won't ever have to worry about it (and
if the formatter is good enough, will probably never feel this is a limitation).

What's most important is that every single Gleam project
_will have a nice and familiar look._ Once again, there's one less thing to
worry about!

## TL;DR

Writing code is hard, _writing good code is even harder._ That's why, when
learning a new programming language like Java, we also have to learn a slew of
"best practices". That might require a lot of effort and discipline, but will
help us avoid a lot of common pitfalls that countless other developers have
fallen into before us.

The problem with best practices is that those are... well, just practices.
Nothing is forcing us to follow those, and having a rule that can be ignored is
like having no rule at all! To cite just one example: null pointers and
unchecked exceptions are the bane of every Java programmer. We know how tricky
those are and strive to avoid using those, yet everyone will have encountered
the dreaded `NullPointerException` at least once in their Java programming
carreer.
As programmers we're _incredibly good at ignoring the million possible ways in which our code can fail_ and will eventually forget a null check or a `try`.

A language like Gleam takes a radically different approach by making best
practices the norm. `null` is bad? _Get rid of it._
Exceptions are a pain to deal with? _Make sure the compiler helps us out._
Mutability leads to brittle code that's harder to refactor? _Make everything immutable._
Having a configurable formatter leads to bikeshedding and decision fatigue? _Get rid of the configuration._

The language only shows you a single, well-defined path: it gently pushes you
into a _pit of succes,_ instead of dropping you in the middle of a maze of
choices and unwritten rules.

A beginner will find a welcoming language where it's harder to mess up simple
stuff while the experienced developer will enjoy the productivity and peace of
mind of not having to worry about a million different pitfalls.

---

Phew, that was quite long! I hope you enjoyed this article as much as I've
enjoyed writing it. I hope you'll be around for the next one!
