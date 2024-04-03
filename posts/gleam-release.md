---
id = "working-on-gleam-1-1"
title = "Working on Gleam 1.1"
abstract = "something something"
tags = ["gleam", "rust"]
date = "2024-04-08"
status = "show"
---

Gleam 1.1 is out! I did a lot of work on this release and that made me think I'd
like to share what was it like working on the Gleam compiler.
This is hopefully going to be the first of a lot of short — or long, depending
how much I manage to contribute to each new release — blog posts sharing what
I did in Gleam, what I think is neat and what I learned.

## Better error messages and warnings!

The release of Gleam v1 had so many people trying it out and showing a lot of
love for the language.
It was incredible to see literally hundreds of new folks joining Gleam's
Discord and sharing their first impressions.
This also meant we got a lot of feedback and a chance to make Gleam's error
messages better and more helpful!

### Appending to a list

Gleam has special syntax for working with lists, for example if we need to
prepend an item to a list we can use the spread syntax:

```gleam
let ns = [1, 2, 3]
let assert [0, 1, 2, 3] = [0, ..ns]
```

However, we'll find out there's no special syntax for appending and we have to
use a function call:

```gleam
let ns = [1, 2, 3]
let assert [1, 2, 3, 4] = list.append(ns, [4])
```

How come we can do `[1, ..ns]` but something like `[..ns, 4]` is not allowed?
The way lists are implemented in a functional language like Gleam makes it so
appending is an expensive operation that needs to traverse the whole list!
So, to avoid people writing inefficient code, Gleam doesn't encourage appending
by not providing a special syntax.

> If you feel like you need to add and remove items from both ends of a list
> then the more appropriate data structure to use would be a
> [`Queue`](https://hexdocs.pm/gleam_stdlib/gleam/queue.html).

This came as a surprise to various newcomers and the error message one got for
writing `[..ns, 4]` wasn't quite helpful:

```text
error: Syntax error
  ┌─ /src/main.gleam:5:10
  │
5 │   [..ns, 4]
  │          ^ I was not expecting this

Expected one of:
"]"
```

What's the problem here? The error doesn't actually explain
_why `4` cannot be there_ and doesn't provide any useful insight or actionable
hint. And now to the good part, here's the new error message you get for trying
to append an item to a list using the spread syntax:

```text
error: Syntax error
  ┌─ /src/parse/error.gleam:4:10
  │
4 │   [..ns, 4]
  │    ^^^^ I wasn't expecting elements after this spread

A spread can only be used to prepend elements to lists like
this: `[first, ..rest]`.

Hint: If you need to append elements to a list you can use `list.append`.
See: https://hexdocs.pm/gleam_stdlib/gleam/list.html#append
```

Now the spread is highlighted as the source of the problem and the compiler
tells you _what it wasn't expecting to see:_ items after a spread.
You get a brief explanation of where a spread can actually be used and a hint
to replace it with `list.append`. I do love error messages like this one and
think this is going to save newcomers a lot of head scratching.

### Pattern matching on tuples

Pattern matching is one of my favourite features and I miss it sorely when I'm
working with languages that do not have it. One can also pattern match on
multiple things to concisely express complex conditionals:

```gleam
case #(validation_rule, list) {
  #(NoEmptyList, []) -> Error("Empty list not allowed")
  #(OnlyOneItemAllowed, []) | #(OnlyOneItemAllowed, [_, _, ..]) ->
    Error("List must have exactly one item")
  #(_, list) -> Ok(list)
}
```

Here we're building a tuple and using it as the subject of the case expression
to pattern match on multiple things at once. However, Gleam makes it extra nice
to write this kind of pattern matching because it allows you to provide multiple
subjects without having to wrap those in a tuple!

```gleam
case rule, list {
  NoEmptyList, [] -> Error("Empty list not allowed")
  ...
}
```

A lot less noisy, right? The problem is I've noticed a lot of people writing the
tupled version because that's what most other languages do.
To make this feature easier to discover the compiler will now warn you when you
pattern match on a literal tuple:

```text
warning: Redundant tuple
  ┌─ /src/warning/wrn.gleam:2:14
  │
2 │         case #(rule, list) {
  │              ^^^^^^^^^^^^^ You can remove this tuple wrapper

Case expressions can take multiple subjects directly.
Hint: You can pass the contents of the tuple directly, separated by commas.
```

Once again you get a nice warning and an actionable hint to help you fix it.
If you're like me and love jumping right into writing code when learning a new
language, this kind of help from the compiler can be invaluable for discovering
less shiny features and writing idiomatic code.

### Unused expressions

Now the Gleam compiler is also quite a bit smarter at detecting unused
expressions you shouldn't be ignoring. As of v1 the compiler would warn if you
ignored a `Result` (we don't want any failure to go unhandled) and literal
values (why defined one in the first place if you're ignoring it?):

```gleam
pub fn main() {
  Ok(1)
//^^^^^ Warning: Silently ignored result
  "mmmh"
//^^^^^^ Warning: Ignored String literal
  todo
}
```

The code that allows us to raise these kind of warnings looks something like
this:

```rust
// `discarded` is the discarded expression.
if discarded.is_literal() {
   emit_discarded_literal_warning();
} else if discarded.type_().is_result() {
   emit_discarded_result_warning();
}
```

But there's a lot expressions we could warn if unused! For example a list
definition or a record constructor. We could add a whole lot of conditions to
this `if-else` branch: `discarded.is_list()`, `discarded.is_tuple()` and so on.
The problem is, it can be quite hard to come up with all the different
conditions to check on the AST nodes.

This was exactly what I tried doing at first, then Louis suggested I could
follow a different approach: instead of coming up with all these different
conditions, why not pattern match on the expression so that
_the type system will force me to take into account all possibilities?_
I loved the idea, went with it and discovered there was a lot more things I didn't even think about that now the compiler was forcing me to aknowledge!
The code now looks something like this:

```rust
pub fn should_warn_if_unused(discarded: TypedExpression) -> bool {
  match discarded {
    TypedExpr::Int { .. }
    | TypedExpr::Float { .. }
    | TypedExpr::String { .. }
    | TypedExpr::List { .. }
    | TypedExpr::Tuple { .. }
    | TypedExpr::BinOp { .. }
    | TypedExpr::RecordAccess { .. }
    | TypedExpr::RecordUpdate { .. } => true,
    // ... I've omitted a whole of branches just for brevity!
  }
}
```

Having the Rust compiler yell at me for some match arms I didn't take into
account was crucial to discover what could and could not be ignored.
I'm really happy how it turned out and now the compiler can be even more
helpful.
I'll never stop repeating this: _pattern matching rules!_

## Internal annotation

Ok, this is a big one. The release blog post does a great job at highlighting
this new feature and you can read more about it there.

This is a great example of something that sounds pretty straightforward at first
and then turns out to be a lot of work: on paper it's just another annotation
you can have on your top level definitions, I'd have to update the parser to
accept it and add an `is_internal` flag to the nodes that could have it.

And you're right, it was pretty straightforward! The type system is a great
guide to make these kind of changes: I added a new field to the AST type
definitions, followed the type errors and fixed those:

```rust
struct TypeConstructor {
  internal: bool,
//^^^^^^^^ I added this field here!
  public: bool,
  name: EcoString,
  // A lot more fields...
}
```

So now one can write a type definition like this one:

```gleam
@internal
pub type Wibble {
  Wobble
}
```

However, having both a `public` and `internal` field isn't quite the best way
to go about this: only a public definition can be marked as internal so if
`internal` is `true` then the `public` field must be as well!
Another problem is now wherever we need to check for the publicity of a function
we need to write fiddly and hard-to-read boolean expressions.

Why not get rid of the two fields and replace those with just one?
Once again this was Louis idea, always giving the best feedback!
So the new definition looks like this:

```rust
enum Publicity {
  Public
  Private
  Internal
}

struct TypeConstructor {
  publicity: Publicity,
  name: EcoString,
  // We got rid of `public` and `internal`
}
```

That's way better! Now we can pattern match on the publicity of a definition and
we no longer could find ourselves in an inconsistent state where something is
marked as both internal and private.

The small problem is... this lead to getting more than 800 compilation errors,
at some point I lost count, because fixing one would make ten more pop up.
Many pieces of code used that `public` and relied on it being a boolean, now I
needed to decide how to handle the internal case as well.

This might sound like a headache but it's actually great: I made a seemingly
small change to my data structure and now the Rust compiler was guiding me
through the refactoring process, pointing to all the places I needed to take
care of.
I have no idea how I could have done a huge refactoring like this one without
the aid of a type system.
In other words: I could totally have made that change but I can guarantee you I
would have missed tens if not hundreds of those 800+ places that used that
field I removed.
To me, Rust's biggest selling point so far has been it unlocking
_fearless refactoring_.

## Even prettier code

I do love meddling with Gleam's formatter and always pick up its issues.
This release is going to have loads of improvements: better formatting of long
case branches, of comments and a lot of bug fixing in general.

But what I think people are going to enjoy the most is the auto sorting of
imports. It's something I've wanted Gleam to have for quite some time and
decided I'd finally give it a shot.
Once again: sounds simple, turns out to be quite complex.
We wanted it to respect empty lines and comments so that people could still
organise their imports in groups:

```gleam
// Notice how, with an empty line, we can split iports
// in different groups and each one will get sorted on
// its own!
import gleam/io
import gleam/result
import gleam/string

import lustre
import lustre/element

import a
import a/b
import c
```

The implementation details are not as exciting but I thought it would still be
neat to share this.

---

There's a lot more stuff I could be talking about: bug fixing, subtle
code generation bugs, improving the look of the generated docs and so on.
If you're curious you'll find a log of everything that changed in the project's
changelog!
