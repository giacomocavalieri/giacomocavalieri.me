---
id = "gleam-rust-arenas"
title = "Closing a three-year-old issue using Rust arenas"
abstract = "How I used arenas to make the Gleam formatter faster and less memory hungry"
tags = ["rust", "gleam", "performance"]
preview-image = "arenas-og-preview.png"
date = 2026-07-12
status = "show"
---

I am part of the core team working on [Gleam](https://gleam.run), a small,
friendly functional programming language written in Rust.

A little while ago I ran into a three-year-old
[issue](https://github.com/gleam-lang/gleam/issues/2251) suggesting how we could
start using arenas to make the language's pretty printer faster.
Quite ominously the issue ends with:

> _"This would be quite a long manual job."_

That sounds grand. I find it actually quite fun to tackle those boring and
repetitive jobs where I can turn my brain off and just punch at a keyboard.
[^llms]

After a couple of days of careful find-and-replace and a
[`+2963/-1032` pull request](https://github.com/gleam-lang/gleam/pull/5824)
later, I managed to make the Gleam formatter a lot faster, also cutting its peak
memory usage by a good 10%!

## What's the problem?

As the issue points out, Gleam's pretty printer is based on a recursive data
structure, the `Document`. Here's a slightly simplified version of the one that
Gleam uses:

```rust
pub enum Document<'string> {
    /// A literal string that will be printed
    /// exactly as it is.
    String(&'string str),

    /// A possible point where the rendered
    /// document could be broken if any line
    /// line gets too long.
    Break {
        /// The string to render if this is broken
        broken: &'string str,
        /// The string to render if this in not broken
        unbroken: &'string str
    },

    /// A document that can be broken along its
    /// `Break`s.
    Group(Vec<Self>),

    /// If this document is broken, increase its nesting
    /// by some amount.
    Nest(Box<Self>),

    // ...and many more...
}
```

This allows us to describe how a piece of code should be rendered and how the
pretty printer is allowed to break it if it gets too long for the line limit.
For example, this is how a list is represented:

```rust
  Group(vec![
    String("["),
    Nest(Box::new(Break { broken: "", unbroken: "" })),
    String("1"),
    Nest(Box::new(Break { broken: ",", unbroken: ", " })),
    String("2"),
    Break { broken: ",", unbroken: "" },
    String("]")
  ])
```

This means the formatter is allowed to either render the list without ever
breaking it, or (if it doesn't fit on the current line) to break it along the
given break points:[^how-this-works]

```gleam
// Rendered with none of the `Break`s broken...
[1, 2]

// ...or rendered breaking it along the `Break`s!
[
  1,
  2,
]
```

Since some `Document` variants can hold other documents, like `Nest` does, those
will have to be boxed on the heap.
And quite a good chunk of time could be spent just doing that!

## Arenas

What if instead we could just store references to other documents?
The `Document` enum would need some updating.
We need a new lifetime for those references:

```diff
pub enum Document<'doc, 'string> {
-    Nest(Box<Self>),
+    Nest(&'doc Self),

    // ...and the other variants...
}
```

If you've worked with references in Rust you know it can sometimes be quite a
bit of a pain to deal with lifetimes. But using an arena can make it a lot
nicer.

In our case I've decided to use the
[`typed_arena`](https://docs.rs/typed-arena/latest/typed_arena/) crate.
The API is pretty straightforward: you can `alloc` new things on the arena, and
get a reference back. That's basically it!
As long as the arena is alive, you will be able to use the data in it; and when
the arena gets out of scope and is dropped, all the data will be dropped with
it.

```rust
let arena = Arena::new();

let comma_break = arena.alloc(Break {
    broken: ",", unbroken: ", "
});

let nested_break = arena.alloc(Nest(comma_break));

// ...render the docs or whatever...
```

The borrow checker will make sure that we can't reference data in the arena once
the arena is dropped:

```rust
pub fn alloc(&self, value: T) -> &mut T
//           ^                   ^^^^
// The reference to the value allocated in
// the arena can't outlive it!
```

Another nice benefit is that we can cache a lot of documents that are repeated
throughout the code without having to allocate one every single time.
For example the documents with all the language's keywords `String("fn")`,
`String("pub")`, `String("type")`; or the comma we use to separate list items:
`Break { unbroken: ", ", broken: "," }`.
There's literally [hundreds of little documents](https://github.com/gleam-lang/gleam/pull/5824/changes#diff-fd77bddd869b2a4e981c876948b9c61e195184ef23a2becbc4ac023aed51f920R590)
that are allocated just once rather than being constantly boxed.

## The result

As nice as the arena is to use, changing a big chunk of code to start using it
required a bit of grunt work: all the bits of code that previously were fine
with just `Box::new`, now need to take the arena where the data will be
allocated as an additional argument:

```diff
const comma_break = Break { broken: ",", unbroken: ", ") };

pub fn format_list(
+   arena: &'doc arena : Arena<Document<'doc, 'string>>,
    items: Vec<UntypedEpxression>
) -> Document<'string> {
    let comma =
-        Nest(Box::new(comma_break));
+        arena.alloc(Nest(comma_break));

    Group(vec![
        String("["),
        items
          .iter()
          .map(|item|
-             Nest(Box::new(format_expression(item)))
+             Nest(format_expression(arena, item))
          )
          .intersperse(comma)
          .collect(),
        String("]")
    ])
}
```

In the end, the outcome was much better than I anticipated, the pretty printer
alone got a huge speedup.
The time spent formatting a real Gleam project like
[`squirrel`](https://github.com/giacomocavalieri/squirrel) went from 13ms to
9,8ms. _That's 24% faster!_

The formatting is just a fraction of what goes into running `gleam format`, we
first have to read and parse the source code of a project.
And yet the improvement is actually noticeable, running `gleam format` is 13%
faster.
The peak memory footprint also went down from 8.4MB to 7.6MB.

As it turns out spending less time allocating stuff on the heap can make our
code faster and less memory hungry, and arenas are a really nice way to do that
in Rust.

[^llms]:
    This is also one of the resons why I despise LLMs so much, and you won't see
    me use them: I like typing and thinking for myself, thanks!

[^how-this-works]:
    The pretty printing algorithm itself is quite fascinating, if you're curious
    to learn how this works you can check the
    ["Strictly Pretty"](https://lindig.github.io/papers/strictly-pretty-2000.pdf)
    paper out. I found it a really nice read, and it's what the Gleam pretty
    printer is based on!
