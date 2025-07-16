import blog/breadcrumbs
import blog/id
import extra
import gleam/int
import gleam/list
import gleam/order.{type Order}
import gleam/result
import gleam/string
import gleam/time/calendar.{type Date, Date}
import lustre/attribute.{type Attribute, attribute} as attr
import lustre/element.{type Element}
import lustre/element/html
import markdown
import simplifile
import tom

pub type Post {
  Post(meta: Metadata, body: List(Element(Nil)))
}

pub type Status {
  Hide
  Show
}

pub type Metadata {
  Metadata(
    id: String,
    title: String,
    abstract: String,
    date: Date,
    tags: List(String),
    status: Status,
  )
}

pub type Error {
  File(error: simplifile.FileError)
  Markdown(error: markdown.Error)
  WrongMetadata
  WrongMetadataField(field: String)
}

pub fn compare(one: Post, other: Post) -> Order {
  extra.date_compare(other.meta.date, one.meta.date)
}

pub fn read(from file: String) -> Result(Post, Error) {
  use raw <- extra.try_map_error(simplifile.read(file), File)
  use #(raw_meta, body) <- extra.try_map_error(markdown.parse(raw), Markdown)
  use meta <- result.try(parse_metadata(raw_meta))
  Ok(Post(meta, body))
}

fn parse_metadata(metadata: String) -> Result(Metadata, Error) {
  use toml <- result.try(
    tom.parse(metadata)
    |> result.replace_error(WrongMetadata),
  )

  use id <- toml_field(toml, tom.get_string, "id")
  use title <- toml_field(toml, tom.get_string, "title")
  use abstract <- toml_field(toml, tom.get_string, "abstract")
  use date <- toml_field(toml, tom.get_date, "date")
  use tags <- toml_field(toml, tom.get_array, "tags")
  use status <- toml_field(toml, tom.get_string, "status")

  use month <- result.try(
    calendar.month_from_int(date.month)
    |> result.replace_error(WrongMetadataField("date")),
  )
  let date = Date(year: date.year, month:, day: date.day)

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

/// Turns a post (with html body) into an `<article>` element that can be used
/// for a full post page.
///
pub fn to_article(post: Post) -> Element(Nil) {
  let title =
    html.h1([classes(["post-title", "p-name"])], [html.text(post.meta.title)])
  let home_link = breadcrumbs.home()
  let subtitle = to_subtitle(post)
  let header = html.header([], [title, home_link, subtitle])
  let body = html.main([classes(["post-body", "e-content"])], post.body)
  html.article([classes(["post", "h-entry"])], [header, body])
}

pub fn to_preview_list(posts: List(Post)) -> Element(a) {
  html.ul([attr.id("posts-previews")], list.map(posts, to_preview))
}

fn to_preview(post: Post) -> Element(a) {
  let title_classes = classes(["post-preview-title", "p-name", "u-url"])
  let post_link = "/posts/" <> post.meta.id <> ".html"
  let title_attributes = [title_classes, attr.href(post_link)]
  let title =
    html.a(title_attributes, [html.h2([], [html.text(post.meta.title)])])
  let subtitle = to_subtitle(post)
  let read_more =
    html.a([attr.class("breadcrumb-link"), attr.href(post_link)], [
      html.text("read more →"),
    ])
  let abstract =
    html.p(
      [classes(["post-preview-abstract", "p-summary"])],
      markdown.parse_no_metadata(post.meta.abstract)
        |> list.append([read_more]),
    )

  html.li([classes(["post-preview", "h-entry"])], [title, subtitle, abstract])
}

fn to_subtitle(post: Post) -> Element(a) {
  let sorted_tags = list.sort(post.meta.tags, by: string.compare)
  let tags = html.ul([attr.class("post-tags")], list.map(sorted_tags, to_pill))
  html.div([attr.class("post-subtitle")], [to_date(post), tags])
}

fn to_date(post: Post) -> Element(a) {
  html.time(
    [
      classes(["post-date", "dt-published"]),
      attribute("datetime", shorthand_date(post.meta.date)),
    ],
    [html.text(human_readable_date(post.meta.date))],
  )
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
  let link =
    html.a([attr.href("/tags/" <> id.from_string(tag) <> ".html")], [
      html.text(tag),
    ])
  html.li([classes(["post-tag", "p-category"])], [link])
}

// --- UTILITIES ---

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
