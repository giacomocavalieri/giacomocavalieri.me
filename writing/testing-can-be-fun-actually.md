---
id = "testing-can-be-fun-actually"
title = "Testing can be fun, actually"
abstract = "Writing and maintaining tests is boring. But they're also some of the most valuable code we can write. With this blog post you'll learn a criminally underrated testing technique to add to your testing toolbox that can make tests a whole lot more pleasant."
tags = ["gleam", "testing"]
date = 2026-02-06
status = "show"
---

Writing tests is boring.
Even worse, maintaining tests is boring _and_ error prone.
The tragedy is they're also some of the most valuable code we can write.

So let me show you a fun and criminally underrated technique to add to your
testing toolbox that can make writing and maintaining tests a whole lot more
pleasant: _snapshot testing._
This technique is applicable everywhere and to prove it we'll go through
real-world examples ranging from CLIs, to compilers written in Rust, to...
web animations!

## The problem

Say you're writing a command line application (CLI), maybe it's just a little
internal tool for your company to be used to automate some tedious chores, or
maybe it's a cool open source project.
What's the most important part of this application?
_The help text!_
That's what users will look at when they're lost, so it's crucial to get it
right.
Does this ring a bell?
Since it's so important we should be testing it:

```gleam
pub fn help_text_test() {
  assert cli.help_text() == "
usage: lucysay [-m message] [-f file]

  -m, --message  the message to be printed
  -f, --file     a file to read the message from
  -h, --help     show this help text
"
}
```

We're checking the help text string conforms to an expected message.
Since we're writing a regular unit test assertion there's no escaping it:
we have to type that in full.

What's worse is, if the help text changes (say we're shipping a v2 with more
flags and features) we'll have to go through that literal string and manually
edit it to make sure the test goes back to passing.
This is quite the tedious chore.
Writing and maintaining these kind of tests, with wordy assertions, is never
fun: it's a boring, repetitive, and error-prone process.

## Snapshot testing to the rescue

Here's where snapshot testing comes into play.
The elevator pitch is simple: _you can focus on writing tests, and the snapshot
testing library will take care of the expected values automatically._

What does this look like in practice? Here's a snapshot test:

```gleam
// In these examples we'll use the birdie library.
// You can add it to a gleam project by running
// `gleam add birdie --dev`
import birdie

pub fn help_text_test() {
  cli.help_text()
  |> birdie.snap(title: "testing the help text")
}
```

The function under test is still the same, but this time we're passing its
result to the `birdie.snap` function (don't worry about the title for now,
we'll get to that later).

This looks a bit magical: the expected value is nowhere to be seen, so how can
the library know when the test should fail? What happens if we run the test?
Let's try it!

```=html
<pre><code data-highlighted='yes' class='not-prose language-shell'><span class='hljs-comment'>> gleam test</span>

<span class='hljs-shell-error'>panic</span> test/example_test.gleam:9
 <span class='hljs-shell-info'>test</span>: example_test.usage_text_test
 <span class='hljs-shell-info'>info</span>: Birdie snapshot test failed

Finished in 0.006 seconds
<span class='hljs-shell-error'>1 tests, 1 failures</span></code>
</pre>
```

Not that exciting, the test is failing.
But we'll also see some new output along the failing test, this is where the
magic happens:

```=html
<pre><code data-highlighted='yes' class='not-prose language-shell'>── new snapshot ────────────────────────────────────────────
  <span class='hljs-shell-info'>title</span>: testing the help text
  <span class='hljs-shell-info'>hint</span>: <span class='hljs-shell-warning'>run `gleam run -m birdie` to review the snapshots</span>
────────┬───────────────────────────────────────────────────
      <span class='hljs-shell-new'>1 + usage: lucysay [-m message] [-f file]
      2 +
      3 +  -m, --message  the message to be printed
      4 +  -f, --file     a file to read the message from
      5 +  -h, --help     show this help text</span>
────────┴───────────────────────────────────────────────────</code></pre>
```

As the test fails it shows us the actual output produced by the function.
If we read the hint we realise that a human needs to be in the loop: we have to
_review_ the snapshot.
Let's follow the library's hint and review it:

```=html
<pre><code data-highlighted='yes' class='not-prose language-shell'><span class='hljs-comment'>> gleam run -m birdie</span>

Reviewing <span class='hljs-shell-warning'>1st</span> out of <span class='hljs-shell-warning'>1</span>

── new snapshot ────────────────────────────────────────────
  <span class='hljs-shell-info'>title</span>: testing the help text
  <span class='hljs-shell-info'>file</span>: ./test/cli.gleam
────────┬───────────────────────────────────────────────────
       <span class='hljs-comment'>... here you'll see the snapshot from earlier</span>
────────┴───────────────────────────────────────────────────

  <span class='hljs-shell-new'>a</span> accept     accept the new snapshot
  <span class='hljs-shell-error'>r</span> reject     reject the new snapshot
  <span class='hljs-shell-warning'>s</span> skip       skip the snapshot for now
  <span class='hljs-shell-info'>d</span> hide diff  toggle snapshot diff</code></pre>
```

We can read the content and see that it is exactly what we want, listing all the
options, and with no typos.
We accept the snapshot.
Now every time we run the tests, they will succeed... given the output of the
function doesn't change.

What's happening under the hood is remarkably simple: the snapshot testing
library, once we accept the snapshot, saves its content to a file and checks
that the function will always produce that value.
If the output changes, the test will fail and we'll have to review the snapshot
again.

Try it for yourself! You can really type at the prompt below.

```=html
<div id="terminal"></div>
<script src="/js/birdie_terminal.js" type="module"></script>
```

### It's like VCS for your tests

The nice upside about dealing with changing assertions is that the snapshot
testing library can be incredibly helpful when something changes.
For example, [`birdie`](https://github.com/giacomocavalieri/birdie) (the library
I'm using here) will show you an informative diff view, much like a version
control system:

```=html
<pre><code data-highlighted='yes' class='not-prose language-shell'>── mismatched snapshot ─────────────────────────────────────
  <span class='hljs-shell-info'>title</span>: testing the help text
  <span class='hljs-shell-info'>hint</span>: <span class='hljs-shell-warning'>run `gleam run -m birdie` to review the snapshots</span>
────────┬───────────────────────────────────────────────────
 <span class='hljs-shell-error'>1      - usage: lucysay [-m message] [-f file]</span>
      <span class='hljs-shell-new'>1 + usage: lucysay [-m message]</span>
      <span class='hljs-shell-new'>2 +   prints a cute message to standard output</span>
      <span class='hljs-comment'>3</span> │
      <span class='hljs-comment'>4</span> |  <span class='hljs-comment'>-m, --message  the message to be printed</span>
 <span class='hljs-shell-error'>4      -  -f, --file     a file to read the message from</span>
      <span class='hljs-comment'>5</span> |  <span class='hljs-comment'>-h, --help     show this help text</span>
────────┴───────────────────────────────────────────────────</code></pre>
```

This is a really nice developer experience: we can see at a glance what has
changed and review it. And the best thing is we've already been successfully
using this workflow for years with version control systems like `git` and
[`jj`](https://www.jj-vcs.dev/latest/).
We know how all of this works, it feels familiar:

- Something has changed, so it needs a review
- It looks ok, we can accept it and go on with our day
- It looks bad, we have to figure out if the change is wanted at all, or what
  the cause of the bug might be

We never need to go through the assertions and update them manually.
We can finally start focusing on our tests without being slowed down by managing
explicit assertions.

## But what about non-strings?

I hear you. With my first example I have cheated a bit: the function we were
testing already produces a string that can be easily snapshotted and diffed.
But the functions we want to test in the real world rarely do that!
We might have to deal with lists, dictionaries, complex objects, strange
collections of data.
What then?

_Turn them into strings._

Do we have to come up with a `to_string` function for each piece of data we want
to test?

_Yes! And that's good actually!_

It's easy to fall victim to the idea of turning each piece of data into a string
using some magic one-size-fit-all `to_string` function.
But being intentional about each snapshot's content is what actually makes or
breaks this testing technique.
Working with the [Gleam compiler](https://github.com/gleam-lang/gleam) I ran
into a great example of how much of a difference a good snapshot test can
actually make.

The Gleam compiler is a big piece of software written in Rust.
It's also quite thoroughly tested with over 5000 unit tests.
More than 3000 are actually snapshot tests (so if you're wondering if snapshot
testing can actually work at scale... it absolutely can)!

The piece of the Gleam codebase I will be focusing on is the Language Server
implementation.
I was looking at some snapshot tests intended to check that hovering tooltips
actually worked.

> The Language Server Protocol allows the IDE to display little tooltips when
> hovering over specific portions of code.
> It's what shows you the documentation of a function once you go over it with
> your cursor; or what shows you the inferred type of a variable.
>
> ```gleam
> pub fn main() -> Nil {
>   let a_variable = 11
>   //  ^^^ If I put my cursor over here I'm expecting
>   //      a helpful tooltip to tell me the type of
>   //      the variable, an `Int` in this case.
> }
> ```
>
> It's really useful, so we have to make sure we're displaying the correct
> information and, crucially, that it is positioned correctly over the hovered
> element.

The Language Server produces some complex data structure with all the
information needed to render the tooltip by the IDE.
That's what we will be testing.
What we ended up doing at first, for lack of better ideas, was snapshotting the
entire data structure by turning it into a string using a default display
function.
This is the test:

```gleam
pub fn hovering_variable_test() {
  hover(over: find_position_of("a_variable"), code: "
    pub fn main() -> Nil {
      let a_variable = 11
      Nil
    }
  ")
  |> hover_data_to_string
  |> birdie.snap(title: "hovering over a variable shows its type")
}
```

And here's what the snapshot would look like:

````=html
<pre><code data-highlighted='yes' class='not-prose language-shell'>── new snapshot ────────────────────────────────────────────
  <span class='hljs-shell-info'>title</span>: hovering over a variable shows its type
  <span class='hljs-shell-info'>hint</span>: <span class='hljs-shell-warning'>run `gleam run -m birdie` to review the snapshots</span>
────────┬───────────────────────────────────────────────────
      <span class='hljs-shell-new'>1 + Hover(
      2 +   range: Some(Range(start: 24, end: 33)),
      3 +   contents: Scalar(
      4 +     String("```gleam\nInt\n```"),
      5 +   ),
      6 + )</span>
────────┴───────────────────────────────────────────────────</code></pre>
````

Let me ask you: is this a good snapshot test?
It certainly contains all the information we care about, and it's plenty enough
to figure out if the implementation is correct.

_But does it make it easy to see the implementation is correct?_

The range over which we display the tooltip might be wrong, and I wouldn't be
any wiser!
What I need to do is to painfully go and count the bytes in the original string
to make sure it is actually hovering the whole variable.
We've replaced a painful unit test assertion with a painful-to-review snapshot!

When figuring out how to produce a snapshot, putting care into its string format
is crucial to make testing simple and fun.
In this example, this is the look I ended up implementing:

````=html
<pre><code data-highlighted='yes' class='not-prose language-shell'>── new snapshot ────────────────────────────────────────────
  <span class='hljs-shell-info'>title</span>: hovering over a variable shows its type
  <span class='hljs-shell-info'>hint</span>: <span class='hljs-shell-warning'>run `gleam run -m birdie` to review the snapshots</span>
────────┬───────────────────────────────────────────────────
      <span class='hljs-shell-new'>1 + pub fn main() -> Nil {
      2 +   let a_variable = 11
      3 +       ↑▔▔▔▔▔▔▔▔▔
      4 +   Nil
      6 + }
      5 +
      6 + ----- Hover content:
      7 + ```gleam
      8 + Int
      9 + ```</span>
────────┴───────────────────────────────────────────────────</code></pre>
````

This is what I call a fun snapshot.
Looking at it we can see at a glance that the tooltip is perfectly aligned with
the variable being hovered over, and its content is also rendered nicely below.

I cannot overstate how much time having nice-to-read snapshots like this one
has saved me, Louis, and Surya when reviewing new code being contributed to the
Gleam compiler.
Heck, I'd go so far to say it's actually fun to write tests and be confronted
with such nice and visual output!

## Your imagination's the limit

Hopefully, now you can get a sense for how powerful and malleable this can
actually be.
Ever since publishing my own snapshot testing library, I've been amazed by the
creativity with which people have used it.

### Testing tricky math made easy

This last example was shown to me by Hayleigh, a dear friend working on a
[cool frontend framework](https://lustre.build).
As part of a component library, Hayleigh also implemented some
[tweening functions](https://en.wikipedia.org/wiki/Inbetweening#Digital_animation).
A tweening function is what underpins all kind of animations, and based on the
specific function we're using we can get all sorts of movements: linear,
with ease-in and ease-out, cubic, and so on...

At its core a tweening function is pretty straightforward (even though the math
involved is certainly not): you take a value as input, the minimum and maximum
ranges for that value, and return a new interpolated value:

```gleam
fn tween_cubic_in_out(
  t value: Float,
  between min: Float,
  and max: Float
) -> Float {
  todo as "some tricky math in here..."
}
```

If you've already done some frontend development you might already have an
intuition for what kind of movement this interpolation function will result in.
But you can also play around with it and see for yourself down here.
Try and move the slider to see how the interpolated value changes:

```=html
<pre id="curve"></pre>
<script src="/js/curve_in_out.js" type="module"></script>
```

The math in there can be quite tricky and easy to get wrong, so of course we
have to test that the implementation is correct.
If we were to write a regular unit test we might check the expected output for
some known values:

```gleam
pub fn tween_cubic_in_out_test() {
  assert tween_cubic_in_out(0.0, between: 0.0, and: 1.0) == 0.0
  assert tween_cubic_in_out(0.5, between: 0.0, and: 1.0) == 0.5
  assert tween_cubic_in_out(0.7, between: 0.0, and: 1.0) == 0.89
}
```

But is this a good test? Imagine someone saw your cool library and decided to
contribute with a new animation `tween_sine_in_out`, they also added new tests,
how nice of them!

```gleam
pub fn tween_sine_in_out_test() {
  assert tween_sine_in_out(0.0, between: 0.0, and: 1.0) == 0.0
  assert tween_sine_in_out(0.5, between: 0.0, and: 1.0) == 0.7
  assert tween_sine_in_out(0.7, between: 0.0, and: 1.0) == 0.9
}
```

Does looking at this test give you confidence that the implementation of this
new function is correct? Not really. You'd have to:

- Carefully check the implementation is right
- Or carefully do the math yourself and verify the asserted values are actually
  correct

At a glance, this test is _not telling me much_ about the correctness of the
tested function. Reviewing it is tedious work.
So how can snapshot tests help us here?
Can we really use them for something this abstract?
_You kind of already have!_
Playing around with a slider and _looking_ at the described shape easily gives
us a good idea of how the tweening function will behave, so why not do that for
our tests?
What Hayleigh came up with looks like this:

```gleam
pub fn tween_cubic_in_out_test() {
  tween_cubic_in_out
  |> plot_function
  |> birdie.snap(title: "cubic tween with in and out easing")
}
```

What does the snapshot look like?

```=html
<pre><code data-highlighted='yes' class='not-prose language-shell'>── new snapshot ────────────────────────────────────────────
  <span class='hljs-shell-info'>title</span>: cubic tween with in and out easing
  <span class='hljs-shell-info'>hint</span>: <span class='hljs-shell-warning'>run `gleam run -m birdie` to review the snapshots</span>
────────┬───────────────────────────────────────────────────
      <span class='hljs-shell-new'>1 +                               ◍◍◍◍◍◍
      2 +                             ◍◍
      3 +                           ◍◍
      4 +                          ◍
      5 +                         ◍
      6 +
      7 +                       ◍
      8 +
      9 +                      ◍
     10 +
     11 +                     ◍
     12 +
     13 +                    ◍
     14 +
     15 +                   ◍
     16 +
     17 +
     18 +                  ◍
     19 +
     20 +                 ◍
     21 +
     22 +                ◍
     23 +
     24 +               ◍
     25 +
     26 +              ◍
     27 +
     28 +            ◍
     29 +           ◍
     30 +         ◍◍
     31 +       ◍◍
     32 + ◍◍◍◍◍◍</span>
────────┴───────────────────────────────────────────────────</code></pre>
```

How brilliant is that?
You can easily see at a glance that this is a cubic curve that eases in and out
of its extremes.
I don't know about you but this test gives me much more confidence in the
correct working of the function, rather than having a bunch of random-looking
`Float`s scattered through my test suite.

## Effective snapshot testing

Now, before you start trying to converting all your tests into snapshots I'd
like to share some insights on how to use this tool _effectively._

### Use long descriptive titles

Notice how snapshots require a title which is shown you when you're reviewing
them.
And it's actually an important piece of the equation: it's telling you what to
look for.
If your snapshot is called `"some test"` it's not really easy to figure out what
you're looking at, is it?
On the other hand, if your snapshot title is
`"the 'wibble' variable is underlined"`, you know exactly what should be
happening in the snapshot body and if the `wibble` variable is not underlined
you'll reject it.

### Keep your snapshots small

Unit tests have it easy.
It's in their name: they should be a self-contained, small unit.
The same goes for snapshot tests: _don't try and cram too much into a single snapshot._

That's for the same reason that we feel a sense of dread when someone asks our
review on a `+10293/-5011` pull request: it's a lot simpler to review many small
and well-defined snapshots rather than a single huge one... your colleagues will
thank you!

The exact size will vary, but a good rule of thumb is if your snapshot is 10/50
lines long it's probably fine.
If it starts getting longer it might be a sign you have to refactor your test
(yes, tests need refactoring and love too): maybe you're trying to _assert way
too many things at once_ and you could replace a single snapshot with a couple
of more focused ones.

### Don't overdo it

This is the most important one.
When we learn some new cool and shiny tool we think it's the next best thing
and want to use it everywhere.
But it's even more important knowing when _not_ to use something.
As for snapshot testing:

- If your assertions are simple
- If the tested data rarely ever changes
- If maintaining and evolving the test is not all that painful

Then it might be the case that a regular unit test assertion is perfectly fine.

## Conclusions

Hopefully you now have a new tool to level up your testing game.
I think snapshot testing is criminally underused and has a kind of bad rep
because of how badly misused it is in browser integration tests (by the way if
you want to learn more about UI testing,
[this might be the talk for you](https://www.youtube.com/watch?v=lnvmbzwIt94)).

In my experience snapshot testing has been a life saver.
I now default to snapshot testing first and only in the cases mentioned above
I switch back to unit testing... and I'll never look back!

---

Thank you so much for reading through this, and thanks to all the amazing people
who shared their feedback.
A shoutout to [Cian Synnott](https://emauton.org/) for taking the time to
proofread this and sharing his suggestions, you're the best!

This has been lovingly written and coded entirely by a human: me!
It takes quite some time, and if you want to support me you can on
[GitHub Sponsors.](https://github.com/sponsors/giacomocavalieri)
