---
id = "my-go-to-testing-technique"
title = "My go-to testing technique"
abstract = "Unit tests are a fundamental defense line to avoid subtle bugs from sneaking into our code bases. The problem is that writing them can sometimes feel like a tedious, repetitive and error prone chore. That's when snapshot testing —my favourite testing technique— comes into play. It makes an alluring promise: rid the developer of the boring task of having to manually write and manage unit tests' assertions!"
tags = ["gleam", "birdie", "tests"]
date = "2024-02-26"
status = "show"
---

I think we can all agree that unit tests are important.

A thorough test suite can give us pretty good confidence (not certainty!) that
our code behaves the way we want it to.
But I'd argue that what's even more valuable is the _trust_ we gain to make big,
sweeping changes to our codebase because we know that errors introduced by a
refactoring won't go undetected.

The problem is that writing and maintaining tests can become a boring and
repetitive chore... but it doesn't have to be!

---

## Wibble wobble

```gleam
function_under_test()
|> should.equal("my expected output I have to spell out")
```

But it doesn't have to be! There must be a better way, right?
After all, we're developers, it's out job to make our code-writing easier and
easier.
Why make an exception for tests and accept to
