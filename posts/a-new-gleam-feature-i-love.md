---
id = "a-new-gleam-feature-i-love"
title = "A new Gleam feature I love"
abstract = "A new Gleam release is right around the corner and it will come with a new feature I absolutely love: _label shorthands._ It might not be as flashy as other features but I wanted to implement it for the longest time and think it will really help me write better code. Here's what it's all about."
tags = ["gleam", "dx", "fp"]
date = "2024-07-26"
status = "show"
---

[Gleam](https://gleam.run) is a functional "friendly language for building
systems that scale". But if I had to describe it with a single word it would be
_simple._
Given the small number of features, one could probably go through the entire
[language tour](https://tour.gleam.run) in a couple of days and learn all there
is to the language.
This is intentional! Gleam's simplicity is also one of its key features;
as clichè as it may sound, sometimes less is more.
As [Rob Pike puts it](https://www.youtube.com/watch?v=rFejpH_tAHM)
_"Simplicity is complicated but the clarity is worth the fight."_

Here's what Gleam looks like:

```gleam
import gleam/io

pub type Month {
  Jan
  Feb
  Mar
//^^^ These are called _constructors_ because you can
//    use them to create values of the `Month` type.
//    I'll be omitting the other ones for brevity...
}

pub fn month_to_string(month: Month) -> String {
  case month {
    Jan -> "January"
    Feb -> "February"
    Mar -> "March"
  }
}

pub fn main() {
  Jan
  |> month_to_string
  |> io.println
}
```

If you already know other programming languages like Java, C# or Rust, this
example might have a familiar look to it: a
[type](https://tour.gleam.run/data-types/custom-types/) looks like an `enum`,
[case](https://tour.gleam.run/flow-control/case-expressions/) is a lot like a
`switch` statement (albeit more powerful), and that pipe operator
[|>](https://tour.gleam.run/functions/pipelines/) is a nifty piece of syntax
sugar to make chains of function calls less clunky.

> What would the code above look like without `|>`?
>
> ```gleam
> Jan |> month_to_string |> io.println
> // Is the same as writing:
> io.println(month_to_string(Jan))
> ```

The cool thing about constructors is that they can also hold arbitrary data,
so you can use types to define data structures that are more complex than simple
enumerations of things:

```gleam
pub type Date {
  Date(year: Int, month: Month, day: Int)
//^^^^ The Date type has a single constructor
//     that is also called date.
}

pub fn my_birthday() -> Date {
  // Now when you use a constructor you have to
  // supply all of its arguments.
  Date(1998, Oct, 11)

  // You can even explicitly use labels:
  Date(year: 1998, month: Oct, day: 11)

  // When using labels, you can supply arguments in
  // the order that makes the most sense to you:
  Date(day: 11, month: Oct, year: 1998)
}
```

## New features? What are those?

A great deal of care is needed to keep Gleam small: a new feature must solve
some real pain points we're currently facing without overlapping with existing
ones.
The most glaring example for people who are getting started with their Gleam
journey is the absence of `if` expressions.
To control the flow of execution Gleam uses `case`, so there's no need to
introduce _a different way to do the same thing:_

```gleam
case is_admin(user) {
  True -> admin_page()
  False -> error_401()
}
```

> This also has the nice side effect of making it easier to refactor your code
> once you inevitably want to stop using booleans:
>
> ```gleam
> // Imagine we want to start dealing with
> // kinds of user instead of just admins...
> case user_role(user) {
>   Admin -> admin_page()
>   Moderator -> moderator_page()
>   _ -> error_401()
> }
> ```

So now we get to my new favourite feature being added to the language: in the
upcoming 1.4 release Gleam is going to support a new _label shorthand syntax._

## The problem

Consider the `Date` type I showed you earlier.
I actually use that for my own personal blog
(yeah [it's written in Gleam!](https://giacomocavalieri.me/posts/look-i-made-this-with-gleam))
to sort posts based on their date.
Posts are just markdown files with an additional header, so what I did to parse
dates looked like this:

```gleam
pub fn read_date(date_string: String) -> Date {
  case string.split(date_string, on: "-") {
    [day_string, month_string, year_string] -> {
      let day = to_int(day_string)
      let month = to_month(month_string)
      let year = to_int(year_string)
      Date(day, month, year)
    }
    _ -> panic as "The post has an invalid date, go fix it!"
  }
}
```

Can you spot the bug? Me neither!
I just noticed it when a couple of weeks ago I wrote a new blog post and it was
not properly sorted.
The problem is that I've inadvertenly got the position of the `Date` arguments
wrong:

```gleam
pub type Date {
  Date(year: Int, month: Month, day: Int)
}

pub fn read_date(date_string: String) -> Date {
  // ...
      let day = string_to_int(day_string)
      let month = string_to_month(month_string)
      let year = string_to_int(year_string)
      Date(day, month, year)
  //       ^^^         ^^^^
  //       I've passed the day and year arguments
  //       in the wrong order.
  // ...
}
```

This could have been avoided by using explicit labels to pass in arguments:

```gleam
pub fn read_date(date_string: String) -> Date {
  // ...
      let day = string_to_int(day_string)
      let month = string_to_month(month_string)
      let year = string_to_int(year_string)
      Date(day: day, month: month, year: year)
  //       ^^^^^^^^                ^^^^^^^^^^
  //       Since I'm using labels the order doesn't
  //       really matter, I could have sorted the arguments
  //       in any order without running into any issue.
  // ...
}
```

Why didn't I do it in the first place then? Short answer is I'm lazy and
couldn't be bothered writing the labels explicitly, and the labelled code
doesn't look particularly nice.
_"I don't really need labels here, I know I'm passing arguments in the right order"_
are the last famous words.

## The solution

The label shorthand syntax aims to solve this exact problem by making it easier
to use labelled arguments.
The code I showed you earlier could be written like this:

```gleam
pub fn read_date(date_string: String) -> Date {
  // ...
  let day = string_to_int(day_string)
  let month = string_to_month(month_string)
  let year = string_to_int(year_string)
  Date(day:, month:, year:)
  // This is the same as writing:
  //   Day(day: day, month: month, year: year)
}
```

This syntax trick helps you pass variables with the same name as a labelled
argument, so you don't have to write the same thing twice while still getting
all the benefits of explicitly using labels.

Using the shorthand syntax is pretty nice when building records, but I think it
really shines when destructuring them.
In my codebase I also have a small function to turn a `Date` back into a string
to display it in the blog post page:

```gleam
pub fn format_date(date: Date) -> String {
  let Date(d, m, y) = date

  int_to_string(y)
  <> "-" <> month_to_string(m)
  <> "-" <> int_to_string(d)
  // <> is used to join strings together!
}
```

The line `Day(d, m, y) = date` creates three variables `d`, `m` and `y` binding
them to the first, second and third argument used to build the given date.

Once again, we're relying on the order of the `Date`'s arguments, assuming the
day is the first one, followed by month and year. However, I've made the same
mistake twice: the first field of a date is the year and not the day!

> If you're wondering why I'm always getting the order of arguments of `Date`
> wrong, it's because in Italy the standard format I'm used to is `dd-mm-yyyy`.

Once again, this problem could have been solved by using labels:

```gleam
pub fn format_date(date: Date) -> String {
  let Date(day: d, month: m, year: y) = date
  // ...
}
```

Now the variable `d` is going to have the value of the `day` field, no matter
the order of the arguments.

> I used single letter variables just to show you an example, in reality what
> I'd write is even more repetitive as I don't really like abbreviations and
> want my variables to have the same name as the labels they correspond to:
>
> ```gleam
> pub fn format_date(date: Date) -> String {
>   let Date(day: day, month: month, year: year) = date
>   // ...
> }
> ```
>
> Doing the right thing, that is using labels, is not really pleasant as I have
> to type the same thing twice all the times.

Label shorthands once again come in handy here:

```gleam
pub fn format_date(date: Date) -> String {
  let Date(day:, month:, year:) = date
  // This is the same as writing
  //   Date(day: day, month: month, year: year)

  int_to_string(day)
  <> "-" <> month_to_string(month)
  <> "-" <> int_to_string(year)
}
```

So now you can get the best of both worlds: use labels to avoid inadvertently
swapping arguments, and still use nice descriptive names for your variables.

---

This might not be a flashy feature that gets people talking about a language,
but it's a great way to make labelled arguments easier to use and to help me
(and hopefully others) avoid hours of head-scratching due to pesky
position-related bugs.
