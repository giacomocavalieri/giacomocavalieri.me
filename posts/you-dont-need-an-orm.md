---
id = "you-do-not-need-an-orm"
title = "You don't need an ORM"
abstract = ""
tags = ["gleam", "orm", "squirrel", "sql"]
date = "2025-01-03"
status = "show"
---

## The right tool for the job

Picture this, you're building ...
Say you're using Postgres, now you'll need to query relational data somehow.
So what now? We're always raving about how a developer should be a polyglot, and
use the right language for the job at hand. When it comes to querying relational
data, I'd argue that there's no better tool than SQL! Don't get me wrong, SQL is
far from perfect; but despite its many flaws it's still a great query language,
so much so it's used for [so](https://www.elastic.co/docs/explore-analyze/query-filter/languages/sql-overview)
[much](https://www.mongodb.com/products/platform/atlas-sql-interface)
[more](https://spark.apache.org/sql/) than simply querying relational databases.

## Why isn't everyone using SQL?

I can sing SQL's praise as much as I want, but this doesn't change the fact that
when it comes to the real world™️ we try and shield the developer from ever
having to write any SQL, using tools like query builders and ORMs. Why is that?
It all comes down to developer experience:
_sticking to plain old SQL can be a royal pain._

Let's have a look at an example in a language I particularly like: Gleam.
For this example I'm using `pog`, a Postgres client library that uses plain old
SQL strings.

```gleam
import pog.{type Connection}

pub type Book {
  Book(title: String, pages_count: Int)
}

pub fn read_books(db: Connection, from year: Int) {
  // A description of how to decode a single query row into a book.
  let book_decoder = {
    use title <- decode.field(0, decode.string)
    use pages_count <- decode.field(1, decode.int)
    decode.success(Book(title, pages_count))
  }

  "
  select
    book.title,
    book.pages_count
  from
    book
  where
    book.year > $1
  "
  |> pog.query
  |> pog.parameter(pog.int(year))
  |> pog.returning(book_decoder)
  |> pog.execute(db)
}
```

Since this might be the first time you read some Gleam code let's go over what
this code is doing:

- In `read_books` we start by describing how to decode a single row coming from
  the query into out own `Book` type: each row should have two columns, the
  first one is a string and is the book's title; while the second one is the
  book's pages count, an int.
- We then type down the SQL query to run, it has a single parameter `$1` that we
  replace with the `year` passed as an argument to `read_books`. Using
  the `pog.parameter` function to fill in the query parameter also makes sure
  we're safe against [SQL injection attacks](https://xkcd.com/327/).
- We then tell pog to use the decoder we've defined earlier to decode all the
  rows returned by the query (`|> pog.returning(book_decoder)`).
- Finally, we run the query against the database we're connected to with
  `pog.execute`.

> This approach would be basically the same in Java if we used something like
> JDBC to run our queries. We'd have to iterate over what is called a
> `ResultSet` (an object representing the rows returned by the query), but this
> core idea of _manually_ decoding a set of rows into our domain types is exactly
> the same.
