import lustre/element.{Element, text}
import lustre/element/html.{
  a, article, div, h1, h2, header, li, main, p, time, ul,
}
import lustre/attribute.{attribute, class, href, id}
import blog/date
import gleam/list

/// A blog post, the abstract and body may be generics are generic so that they
/// can hold data of different kinds in the future (for example they could
/// start with a file path, then markdown, then elements).
/// 
pub type Post {
  Post(
    id: String,
    title: String,
    abstract: String,
    date: date.Date,
    tags: List(String),
    body: Element(Nil),
  )
}

/// Turns a post (with html body) into an `<article>` element that can be used
/// for a full post page.
/// 
pub fn to_full(post: Post) -> Element(Nil) {
  let header =
    [to_title, to_subtitle]
    |> list.map(fn(gen) { gen(post) })
    |> header([], _)

  article([class("post")], [header, to_body(post)])
}

/// Turns a list of posts (with html body) into a `<ul>` with all their
/// previews.
/// 
pub fn to_previews(posts: List(Post)) -> Element(a) {
  ul([id("posts-previews")], list.map(posts, to_preview))
}

fn to_preview(post: Post) -> Element(a) {
  [to_preview_title, to_subtitle, to_preview_abstract]
  |> list.map(fn(gen) { gen(post) })
  |> li([class("post-preview")], _)
}

fn to_title(post: Post) -> Element(a) {
  h1([class("post-title")], [text(post.title)])
}

fn to_preview_title(post: Post) -> Element(a) {
  let attributes = [
    class("post-preview-title"),
    href("/posts/" <> post.id <> ".html"),
  ]
  a(attributes, [h2([], [text(post.title)])])
}

fn to_subtitle(post: Post) -> Element(a) {
  div([class("post-subtitle")], [to_date(post), to_tags(post)])
}

fn to_date(post: Post) -> Element(a) {
  let datetime = attribute("datetime", date.to_datetime(post.date))
  let time_attributes = [class("post-date"), datetime]
  time(time_attributes, [text(date.to_string(post.date))])
}

fn to_tags(post: Post) -> Element(a) {
  list.map(post.tags, to_pill)
  |> ul([class("post-tags")], _)
}

fn to_preview_abstract(post: Post) -> Element(a) {
  p([class("post-preview-abstract")], [text(post.abstract)])
}

fn to_body(post: Post) -> Element(Nil) {
  main([class("post-body")], [post.body])
}

fn to_pill(tag: String) -> Element(a) {
  // TODO: actually send to a tag page
  let link = a([href("#")], [text(tag)])
  li([class("post-tag")], [link])
}
