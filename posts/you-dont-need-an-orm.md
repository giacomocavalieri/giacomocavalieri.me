---
id = "you-do-not-need-an-orm"
title = "You don't need an ORM"
abstract = ""
tags = ["gleam", "orm", "squirrel", "sql"]
date = "2025-01-03"
status = "show"
---

As developers I'm sure we've all read iterations of this saying many times:
_"a developer should be a polyglot"._ That is, when faced with a problem, we
should strive to use the right tool for the job at hand — after all
[not everything is a nail to hit on the head!](https://en.wikipedia.org/wiki/Law_of_the_instrument)

We really like this kind of advice because it allows us to push for the tools
and programming languages we know and love, instead of settling for the status
quo.
But there's one place where people seem a bit too quick to dismiss this
piece of advice, and that's when it comes to talking to a Database.
In this case, we feel the need to reach for complex abstractions, frameworks,
query builders, and ORMs to shield us from ever having to think about SQL.

I'd argue that when it comes to talking to a database, our best bet to build
fast, predictable, and easy-to-debug applications is using SQL directly. So let
me show you why you do not need an ORM.

## The right tool for the job

SQL

## Where has all the SQL gone

If SQL is so nice, why isn't everyone using it?
Surely we're not reaching for other alternatives just for the sake of it!
As powerful as SQL is, when it comes to actually using it in a real application,
leaves a lot to be desired.
Let's have a look at what it could look like if we wanted to stick to plain old
SQL:

```gleam
import pog.{type Connection}

pub type Book {
  Book(title: String, pages_count: Int)
}

pub fn read_books(db: Connection, from year: Int) {
  "
  select
    book.title,
    book.pages_count
  from book
  where book.year > $1
  "
  |> pog.query
  |> pog.parameter(pog.int(year))
  |> pog.returning({
    use title <- decode.field(0, decode.string)
    use pages_count <- decode.field(1, decode.int)
    decode.success(Book(title, pages_count))
  })
  |> pog.execute(db)
}
```

> This example is written in [Gleam](https://gleam.run), a friendly language for
> building type-safe systems that scale!
> However, it'd look similar — at least in spirit — if you were to write it in
> Java using a driver like JDBC. You'd still have to go over the rows returned
> by the query and write some glue code to turn those into some object.

First of all, we have to embed the query into our code. That's just a literal
string that could also contain parameter placeholders to be filled in later.
Then we have to write some glue code to tell our program how to bridge the gap
between the database and our application. In Gleam we do that defining a
[`Decoder`](https://hexdocs.pm/gleam_stdlib/gleam/dynamic/decode.html#Decoder)
that describes how to turn a row into a Gleam type:

```gleam
// The first column should be a String, that's the title.
use title <- decode.field(0, decode.string)
// The second column should be an Int, that's the number of pages.
use pages_count <- decode.field(1, decode.int)
// With those two values we build a `Book`
decode.success(Book(title, pages_count))
```

This might look totally good and reasonable, and it actually is for such a
simple example!
But as one starts building real software, dealing with loads of queries and
ever-evolving schemas, all kind of annoyances will start popping up.

### Stringly typed queries

With this approach a SQL query inevitably has to be embedded as a string into
the host programming language.
That means we're missing out on syntax highlighting, autocompletions, errors and
lints that we would have had if we were to write our SQL query in a
`.sql` file using some nice editor like [DataGrip](https://www.jetbrains.com/datagrip/)
or [DBeaver](https://dbeaver.io) — those are the right tools for the job of
writing SQL after all!

Like any other piece of code, queries have to change over time to accomodate new
requirements. As a query changes, we have to be diligent and remember to update
the glue code accordingly, otherwise runtime errors would start appearing as the
outdated decoder is no longer right for the new data the database is sending our
way.
Those are the worst kind of bugs! You change a query, push your code, and after
CI spins up you notice tests are failing.
You go back to your code and realise you just made a typo, or added a trailing
comma (yeah SQL doesn't support those, and I constantly make this mistake), or
forgot to update a decoder.
Now you have to go back to your glue code and fix it.
Rinse and repeat, and soon enough you'll die by a thousand paper cuts.

If this wasn't enough, having your SQL query as a plain string also makes it
really easy to fall victim of SQL injection! Since your query is a string it is
very tempting to start joining strings to build parametric queries:

```gleam
pub fn extremly_dangerous_find_students_by_name(first_name: String) {
  let query =
    "
    select student.last_name, student.grades
    from student
    where student.first_name = " <> first_name
  //                        ^^^^^^^^^^^ We're joining two strings here!

  pog.query(query)
  |> pog.returning({
    use last_name <- decode.field(0, decode.string)
    use grades <- decode.field(1, decode.list(decode.float))
    decode.success(Student(first_name, last_name, grades))
  })
  |> pog.run(db)
}
```

That's the easiest way to expose your database to SQL injection, never build
parametric queries by joining untrusted data. One should always use query
parameters, or end up victim of the exploits of a mom.

[![Exploits of a Mom](https://imgs.xkcd.com/comics/exploits_of_a_mom.png)](https://xkcd.com/327)

The problem is that since your query is just a string it's really easy to
commit this mistake, not everyone working on the codebase might be aware of the
security implications.
