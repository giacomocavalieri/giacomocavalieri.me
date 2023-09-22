import gleam/dynamic
import gleam/list
import gleam/order.{Order}
import gleam/result
import gleam/string
import gloml
import lustre/attribute.{Attribute, attribute, class, href, id}
import lustre/element.{Element, text}
import lustre/element/html.{
  a, article, div, h1, h2, header, li, main, p, time, ul,
}
import blog/breadcrumbs
import blog/date.{Date}
import extra
import markdown

pub type Post {
  Post(meta: Metadata, body: List(Element(Nil)))
}

pub type Metadata {
  Metadata(
    id: String,
    title: String,
    abstract: String,
    date: Date,
    tags: List(String),
  )
}

pub type Error {
  File(error: simplifile.FileError)
  Markdown(error: markdown.Error)
  WrongMetadata(error: gloml.DecodeError)
}

pub fn compare(one: Post, other: Post) -> Order {
  date.compare(one.meta.date, other.meta.date)
}

pub fn read(from file: String) -> Result(Post, Error) {
  use raw <- extra.try_map_error(simplifile.read(file), File)
  use #(raw_meta, body) <- extra.try_map_error(markdown.parse(raw), Markdown)
  use meta <- result.try(parse_metadata(raw_meta))
  Ok(Post(meta, body))
}

fn parse_metadata(metadata: String) -> Result(Metadata, Error) {
  let decoder =
    dynamic.decode5(
      Metadata,
      dynamic.field("id", dynamic.string),
      dynamic.field("title", dynamic.string),
      dynamic.field("abstract", dynamic.string),
      dynamic.field("date", date.decoder),
      dynamic.field("tags", dynamic.list(of: dynamic.string)),
    )

  gloml.decode(metadata, decoder)
  |> result.map_error(WrongMetadata)
}

/// Turns a post (with html body) into an `<article>` element that can be used
/// for a full post page.
/// 
pub fn to_article(post: Post) -> Element(Nil) {
  let title = h1([classes(["post-title", "p-name"])], [text(post.meta.title)])
  let home_link = breadcrumbs.home()
  let subtitle = to_subtitle(post)
  let header = header([], [title, home_link, subtitle])
  let body = main([classes(["post-body", "e-content"])], post.body)
  article([classes(["post", "h-entry"])], [header, body])
}

pub fn to_preview_list(posts: List(Post)) -> Element(a) {
  ul([id("posts-previews")], list.map(posts, to_preview))
}

fn to_preview(post: Post) -> Element(a) {
  let title_classes = classes(["post-preview-title", "p-name", "u-url"])
  let title_attributes = [
    title_classes,
    href("/posts/" <> post.meta.id <> ".html"),
  ]
  let title = a(title_attributes, [h2([], [text(post.meta.title)])])
  let subtitle = to_subtitle(post)
  let abstract =
    p(
      [classes(["post-preview-abstract", "p-summary"])],
      [text(post.meta.abstract)],
    )

  li([classes(["post-preview", "h-entry"])], [title, subtitle, abstract])
}

fn to_subtitle(post: Post) -> Element(a) {
  let sorted_tags = list.sort(post.meta.tags, by: string.compare)
  let tags = ul([class("post-tags")], list.map(sorted_tags, to_pill))
  div([class("post-subtitle")], [to_date(post), tags])
}

fn to_date(post: Post) -> Element(a) {
  let datetime = attribute("datetime", date.to_datetime(post.meta.date))
  let time_attributes = [classes(["post-date", "dt-published"]), datetime]
  time(time_attributes, [text(date.to_string(post.meta.date))])
}

fn to_pill(tag: String) -> Element(a) {
  let link = a([href("/tags/" <> tag <> ".html")], [text(tag)])
  li([classes(["post-tag", "p-category"])], [link])
}

// --- UTILITIES ---

fn classes(classes: List(String)) -> Attribute(a) {
  classes
  |> list.map(fn(class) { #(class, True) })
  |> attribute.classes
}
