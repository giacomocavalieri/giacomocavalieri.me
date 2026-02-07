import blog/breadcrumbs
import frontmatter.{Extracted}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/time/calendar.{type Date, Date}
import jot
import jot_extra
import lustre/attribute as attr
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
    preview_image: Option(String),
  )
}

pub type Error {
  CannotReadFile(error: simplifile.FileError)
  MissingFrontmatter
  WrongMetadata
  WrongMetadataField(field: String)
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

  use preview_image <- result.try(case tom.get_string(toml, ["preview-image"]) {
    Ok(preview_image) -> Ok(Some(preview_image))
    Error(tom.NotFound(..)) -> Ok(None)
    Error(tom.WrongType(..)) -> Error(WrongMetadataField("preview-image"))
  })

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

  Ok(Metadata(id:, title:, abstract:, date:, tags:, status:, preview_image:))
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
pub fn to_article(post: Post) -> List(Element(a)) {
  [
    breadcrumbs.new([
      breadcrumbs.link("home", to: "/"),
      breadcrumbs.animated_link("writing", to: "/writing.html"),
      breadcrumbs.block_link(post.meta.title),
    ]),

    html.main([attr.class("stack article")], [
      jot_extra.to_element(post.body),
    ]),
  ]
}

pub fn to_preview_list(posts: List(Post)) -> Element(a) {
  html.ol(
    [attr.class("stack-s")],
    list.sort(posts, fn(one, other) {
      calendar.naive_date_compare(one.meta.date, other.meta.date)
    })
      |> list.reverse
      |> list.map(to_preview),
  )
}

fn to_preview(post: Post) -> Element(a) {
  let post_link = "writing/" <> post.meta.id <> ".html"
  html.li([], [
    html.article([attr.class("preview sidebar")], [
      html.time([attr.class("info")], [html.text(month_day(post.meta.date))]),
      html.a([attr.href(post_link)], [html.text(post.meta.title)]),
    ]),
  ])
}

fn month_day(date: Date) -> String {
  let Date(year: _, month:, day:) = date
  let day = int.to_string(day) |> string.pad_start(to: 2, with: "0")

  calendar.month_to_string(month)
  |> string.slice(at_index: 0, length: 3)
  |> string.capitalise
  |> string.append(" " <> day)
}

// UTILITIES -------------------------------------------------------------------

pub fn is_shown(post: Post) -> Bool {
  case post.meta.status {
    Hide -> False
    Show -> True
  }
}
