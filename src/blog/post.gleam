import blog/breadcrumbs
import blog/id
import frontmatter.{Extracted}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/order.{type Order}
import gleam/result
import gleam/string
import gleam/time/calendar.{type Date, Date}
import jot
import jot_extra
import lustre/attribute.{type Attribute, attribute} as attr
import lustre/element.{type Element}
import lustre/element/html
import simplifile
import tom

pub type Post {
  Post(meta: Metadata, body: jot.Document)
}

pub type Status {
  Hide
  Show
}

pub type Metadata {
  Metadata(
    id: String,
    title: String,
    abstract: jot.Document,
    date: Date,
    tags: List(String),
    status: Status,
  )
}

pub type Error {
  CannotReadFile(error: simplifile.FileError)
  MissingFrontmatter
  WrongMetadata
  WrongMetadataField(field: String)
}

pub fn compare(one: Post, other: Post) -> Order {
  let Date(year:, month:, day:) = one.meta.date
  let Date(year: year_other, month: month_other, day: day_other) =
    other.meta.date

  use <- order.lazy_break_tie(int.compare(year, year_other))
  let month = calendar.month_to_int(month)
  let month_other = calendar.month_to_int(month_other)
  use <- order.lazy_break_tie(int.compare(month, month_other))
  int.compare(day, day_other)
}

// PARSING ---------------------------------------------------------------------

pub fn read(from file: String) -> Result(Post, Error) {
  use raw <- result.try(
    simplifile.read(file)
    |> result.map_error(CannotReadFile),
  )

  case frontmatter.extract(raw) {
    Extracted(frontmatter: None, content: _) -> Error(MissingFrontmatter)
    Extracted(frontmatter: Some(frontmatter), content:) -> {
      use meta <- result.try(parse_metadata(frontmatter))
      Ok(Post(meta:, body: jot.parse(content)))
    }
  }
}

fn parse_metadata(metadata: String) -> Result(Metadata, Error) {
  use toml <- result.try(
    tom.parse(metadata)
    |> result.replace_error(WrongMetadata),
  )

  use id <- toml_field(toml, tom.get_string, "id")
  use title <- toml_field(toml, tom.get_string, "title")
  use abstract <- toml_field(toml, tom.get_string, "abstract")
  let abstract = jot.parse(abstract)

  use date <- toml_field(toml, tom.get_date, "date")
  use tags <- toml_field(toml, tom.get_array, "tags")
  use status <- toml_field(toml, tom.get_string, "status")

  use tags <- result.try(
    list.try_map(tags, fn(tag) {
      case tag {
        tom.String(string) -> Ok(string)
        _ -> Error(WrongMetadataField("tags"))
      }
    }),
  )

  use status <- result.try(case status {
    "show" -> Ok(Show)
    "hide" -> Ok(Hide)
    _ -> Error(WrongMetadataField("status"))
  })

  Ok(Metadata(id:, title:, abstract:, date:, tags:, status:))
}

fn toml_field(
  toml: b,
  get: fn(b, List(String)) -> Result(c, d),
  field: String,
  then: fn(c) -> Result(e, Error),
) -> Result(e, Error) {
  get(toml, [field])
  |> result.replace_error(WrongMetadataField(field))
  |> result.try(then)
}

// HTML AND TEXT RENDERING -----------------------------------------------------

/// Turns a post (with html body) into an `<article>` element that can be used
/// for a full post page.
///
pub fn to_article(post: Post) -> Element(Nil) {
  html.article([classes(["post", "h-entry"])], [
    html.header([], [
      html.h1([classes(["post-title", "p-name"])], [html.text(post.meta.title)]),
      breadcrumbs.home(),
      to_subtitle(post),
    ]),
    html.main([classes(["post-body", "e-content"])], [
      jot_extra.to_element(post.body),
    ]),
  ])
}

pub fn to_preview_list(posts: List(Post)) -> Element(a) {
  html.ul([attr.id("posts-previews")], list.map(posts, to_preview))
}

fn to_preview(post: Post) -> Element(a) {
  let title_classes = classes(["post-preview-title", "p-name", "u-url"])
  let post_link = "/posts/" <> post.meta.id <> ".html"

  html.li([classes(["post-preview", "h-entry"])], [
    html.a([title_classes, attr.href(post_link)], [
      html.h2([], [html.text(post.meta.title)]),
    ]),
    to_subtitle(post),
    html.p([classes(["post-preview-abstract", "p-summary"])], [
      jot_extra.to_element(post.meta.abstract),
      html.a([attr.class("breadcrumb-link"), attr.href(post_link)], [
        html.text("read more →"),
      ]),
    ]),
  ])
}

fn to_subtitle(post: Post) -> Element(a) {
  html.div([attr.class("post-subtitle")], [
    to_date(post),
    html.ul([attr.class("post-tags")], {
      list.sort(post.meta.tags, by: string.compare)
      |> list.map(to_pill)
    }),
  ])
}

fn to_date(post: Post) -> Element(a) {
  let datetime = attribute("datetime", shorthand_date(post.meta.date))
  html.time([classes(["post-date", "dt-published"]), datetime], [
    html.text(human_readable_date(post.meta.date)),
  ])
}

fn shorthand_date(date: Date) -> String {
  let Date(year:, month:, day:) = date

  int.to_string(year)
  <> "-"
  <> string.pad_start(
    int.to_string(calendar.month_to_int(month)),
    to: 2,
    with: "0",
  )
  <> "-"
  <> string.pad_start(int.to_string(day), to: 2, with: "0")
}

fn human_readable_date(date: Date) -> String {
  let Date(year:, month:, day:) = date

  int.to_string(day)
  <> " "
  <> calendar.month_to_string(month)
  <> " "
  <> int.to_string(year)
}

fn to_pill(tag: String) -> Element(a) {
  html.li([classes(["post-tag", "p-category"])], [
    html.a([attr.href("/tags/" <> id.from_string(tag) <> ".html")], [
      html.text(tag),
    ]),
  ])
}

// UTILITIES -------------------------------------------------------------------

fn classes(classes: List(String)) -> Attribute(a) {
  classes
  |> list.map(fn(class) { #(class, True) })
  |> attr.classes
}

pub fn is_shown(post: Post) -> Bool {
  case post.meta.status {
    Hide -> False
    Show -> True
  }
}
