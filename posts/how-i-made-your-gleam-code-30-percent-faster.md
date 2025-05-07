---
id = "how-i-made-your-gleam-code-30-percent-faster"
title = "How I made your Gleam code 30% faster"
abstract = "A new version of Gleam is right around the corner and TODO! . So how did I do this?"
tags = ["gleam", "decision-trees", "pattern-matching", "js"]
date = "2025-05-07"
status = "show"
---

[Gleam](https://gleam.run) is a friendly programming language with a familiar
and modern syntax that can compile to Erlang and JavaScript. This is a pretty
slick feature as it allows one to run it both on the battle-tested Erland
virtual machine and anywhere JavaScript can run: the browser, Node, Deno,
Bun, you name it!
If you're curious you can give Gleam a try in the
[online playground](https://tour.gleam.run); all the code you write there is
compiled locally and runs entirely in your browser, that's why it feels so
snappy and can give you almost instant feedback as you type!

Gleam is a pretty simple language, so much so that an experienced developer
could go over the entire language tour in a couple of afternoons and learn all
there is to know to it. Given that, the JavaScript it gets compiled down to is
pretty regular, run-of-the-mill JS code. Let's have a look at a small example
just to get an idea; this piece of Gleam code:

```gleam
import gleam/io

pub fn greet(name: String) -> Nil {
  let greeting = "Hello, " <> name
  //                       ^^ This operator joins two strings!
  io.println(greeting)
}
```

Is turned into:

```js
import * as $io from "./gleam/io.mjs";

export function greet(name) {
  let greeting = "Hello, " + name;
  return $io.println(greeting);
}
```

Nothing too flashy, but don't worry we're going to move on to more interesting
examples!
In the upcoming Gleam 1.10 release I've tweaked (or rather overhauled) some
crucial pieces of code generation to make the generated JavaScript loads faster,
sometimes reaching a whopping 30% speedup!

## Pattern matching: the best feature any language could have

In order to understand what changed we have to first talk about one of my very
favourite features ever: pattern matching. You can think of a pattern matching
expression as a sort of `switch` but way more capable, in Gleam it looks like
this:

```gleam
pub fn greet(name: String) {
  case name {
    "Lucy" -> io.println("Welcome back Lucy!!")
    "Louis" -> io.println("Hello Louis!")
    _ -> io.println("I don't know you...")
  }
}
```

If you squint hard enough that's quite similar to what one would write in other
languages using a `switch` or an `if-else` conditional. And if you look at the
generated JavaScript code that's exactly what this is!

```js
export function greet(name) {
  if (name === "Lucy") {
    return $io.println("Welcome back Lucy!!");
  } else if (name === "Louis") {
    return $io.println("Hello Louis!");
  } else {
    return $io.println("I don't know you...");
  }
}
```

So what makes pattern matching more powerful? The trick is on the left hand side
you're not limited to using literal values (in our example matching with the
literal strings `"Lucy"` and `"Louis"`), but you also have the ability to
express more complex patterns:

```gleam
pub fn greet(name: String) {
  case name {
    "L" <> _ -> io.println("I like your name!")
    _ -> io.println("Hello " <> name)
  }
}
```

In this piece of code we run the first branch if `name` is any string starting
with an uppercase `L`. We still add a default catch all branch `_` to tell the
function what to do in case the first pattern doesn't match.

What is this compiled down to in Gleam? Again it's pretty regular looking
JavaScript:

```js
export function greet(name) {
  if (name.startsWith("L")) {
    return $io.println("I like your name!");
  } else {
    return $io.println("Hello " + name);
  }
}
```

Pattern matching is not limited to strings and prefixes, it can also help us
working with other data structures like lists:

```gleam
pub fn greet(people: List(String)) {
  case people {
    [] -> io.println("There's no one to greet!")
    [_, ..] -> io.println("Definitely a crowd")
//   ┬  ┬─
//   │  ╰─ The first item might be followed by zero or more items, we don't
//   │     really care how many.
//   │
//   ╰─ The list must have at least one item, but we don't really
//      care what that is, so we use a catch-all pattern `_` for it.
  }
}
```

We will run the first branch if the list is empty `[]`, if it has at least one
item `[_, ..]` then we will run the second branch.
And once again the generated code looks pretty straightforward, translating each
check into a boolean condition:

```js
export function greet(people) {
  if (people.hasLength(0)) {
    return $io.println("There's no one to greet!");
  } else {
    return $io.println("Definitely a crowd");
  }
}
```

Where pattern matching really shines — and after getting the hang of it you'll
wish every language had this feature — is when we start combining patterns
together, expressing pretty complex conditions in a very readable way:

```gleam
pub fn judge(favourite_languages: List(String)) {
  let message = case favourite_languages {
    // The first item is Gleam, we ignore all the other ones the might come
    // after.
    ["Gleam", ..] -> "Good choice!"

    // The second item is Gleam, and we bind the first one to the `lang`
    // variable. We also ignore all other items that might come after.
    [lang, "Gleam", ..] -> "It's ok to like " <> lang <> " more than Gleam"

    // The third item is Gleam, we ignore all the other ones that come before
    // or after.
    [_, _, "Gleam", ..] -> "Gleam made it to the top 3!"

    // A catch-all that will always match in case none of the above matched.
    _ -> "Uh oh Gleam didn't make it to the top 3"
  }
  io.println(message)
}
```

And let's have a look at the generated code one last time. I think at this
point you might have a hunch of what it could look like, once again translating
each pattern into a boolean condition:

```js
export function judge(favourite_languages) {
  let message;
  if (favourite_languages.atLeastLength(1) && favourite_languages.head === "Gleam") {
    message = "Good choice!";
  } else if (favourite_languages.atLeastLength(2) && favourite_languages.tail.head === "Gleam") {
    let lang = favourite_languages.head;
    message = "It's ok to like " + lang + " more than Gleam";
  } else if (favourite_languages.atLeastLength(3) && favourite_languages.tail.tail.head === "Gleam") {
    message = "Gleam made it to the top 3!";
  } else {
    message = "Uh oh Gleam didn't make it to the top 3";
  }
  return $io.println(message);
}
```

> What's that `favourite_languages.head`? Gleam is using a linked list here,
> that's not exactly the same as a JS array: what you can do with a linked list
> is either get the first item with `.head` or get the rest of the list using
> `.tail`.
> So `list.head` is the same as `array[0]`, `list.tail.head` is the same as
> `array[1]` and so on...

## So what's the catch?

The generated code is totally reasonable and works great... the only problem is
it's not as efficient as it could be! Those with a keen eye might have noticed
we're performing some wasteful checks. Say we're calling the `judge`
function passing it an empty list, what pattern is going to match with it?

The first condition checks that is has `.atLeastLength(1)`, this is false and so
we go on checking if it has `.atLeastLength(2)`, this is false again and so we
go on checking if it has `.atLeastLength(3)`, this is false again. Finally we
land on the last catch all pattern that is always going to match (and you can
see that as it is translated to a regular `else` in the JS code).
After learning that the list doesn't have at least 1 item _we can tell for sure_
that the second and third pattern are never going to match — after all they
require the list to have more than one item.
Checking those conditions is just wasting precious CPU cycles because we know
for sure they're going to be false!

It would be so much better if we could generated code that _learned_ from the
checks it has already performed, to avoid wasting time on patterns that it knows
have no chance of matching.
In the particular example above, as soon as we learn that the list doesn't have
`.atLeastLength(1)` we can go straight to the last branch!

## Decision trees to the rescue
