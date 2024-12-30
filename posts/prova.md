---
id = ""
title = ""
abstract = ""
tags = []
date = ""
status = "hide"
---

# asd

For the last five months I've been working on a really cool project called
[squirrel](https://github.com/giacomocavalieri/squirrel): a package to do type
safe SQL in Gleam.

## Type safe?

Gleam is a statically typed language, everything must have a type and the
compiler, like a tireless and very thorough pair programmer, will make sure we
don't mix things up when coding.

Data that comes from the outside world, untyped by nature, is usually given the
`Dynamic` type. The only thing you can do with `Dynamic` data is decode it
turning it into something with a known shape your application can actually work
with.

This really nicely draws a clear dividing line ...

As a small example:

> Mandatory "parse, don't validate" recommendation

> `decode` is a really nice package that exposes a nice API to write decoders,
> at the time of writing it's just an exploration that might make its way into
> stdlib.

This has quite some problems:

1. The experience of writing the SQL is really bad. That is just a plain Gleam
   String, so no syntax highlight, no suggestions, no auto completions, no auto
   formatting, no nothing!
2. What if I want to inspect the query? What if I want to tune the query
   performance? What if I want to use the query somewhere else?
   What I'll have to do is copy paste the content of this Gleam string and feed
   it to my dbms of choice.
3. What it the shape of my data changes? What if I realise I need to also fetch
   another field (make an example a field to the select list).
   I add it to the query and... nothing happens
4. What if I add a new query parameter?
5. What if I change the type of a query parameter? ... my code breaks at runtime

How do we fix this? How can we make the developer experience better here?

### Non solution: ORM

I don't particularly like ORMs

### Non solution: query builders

Query builders are way cooler but I really

## Enter Squirrel

So what now?

### It just works™️

- It's just SQL, I love this
- You get all the niceties of proper SQL tools
- You can reuse your queries, no awkard copy-pasting
- It's type safe and easy to keep in sync with your database
- The DBMS knows best!! It has all the reliable type information about your
  database

> Ok I know, I know

## How does it do its magic

Making Squirrel was a real challenge

- Reading through sqlx, Rust is really hard for me, folks on Discord were really
  helpful
- Reading the Postgres docs, those are _excellent_ but it can still be quite
  challenging to get the protocol right
- Just fuck around and find out

And there's also loads of other things that are super interesting to me: how do
I generate pretty printed Gleam code, how can I make the error messages as nice
as possible, ...

I want to share some of the gory details I learned, one because I think it's a
lot of fun. Two because this is the kind of material I'd have absolutely loved
to have when I started implementing Squirrel. Hopefully someone in the future
might have a head start when they'll try to implement the same thing in their
favourite language of choice.

### How does one talk to Postgres?

### The frontend/backend protocol

### Code generation

Generating rubbish code is simple enough, but I wanted the generated Gleam code
to be as nice as possible, indistinguishable from carefully hand crafted code.
So the file is organised in neat sections, different functions reuse the same
code helpers that are neatly grouped at the end of the file.

Code is commented and most of all _formatted._
A pretty printer is your best ally here.

### Error messages

One of the thing I love most about languages like Gleam, Elm and Rust are the
lovely error messages. So one of the first things I started pondering was, how
can I make the error messages the best they can be?
Just like with code generation, a pretty printer is a real life saver here.
(Show the nice tooltips and wrapping text...)
