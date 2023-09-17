import lustre/element.{Element, text}
import lustre/element/html.{
  a, article, div, h1, h2, header, li, main, p, time, ul,
}
import lustre/attribute.{attribute, class, classes, href, id, rel}
import blog/date
import gleam/list
import gleam/function
import blog/route

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
  let post_classes = [#("post", True), #("h-entry", True)]
  let home_link = a([rel("author"), href("/")], [text("← home")])

  let header =
    [to_title, function.constant(home_link), to_subtitle]
    |> list.map(fn(gen) { gen(post) })
    |> header([], _)

  article([classes(post_classes)], [header, to_body(post)])
}

/// Turns a list of posts (with html body) into a `<ul>` with all their
/// previews.
/// 
pub fn to_previews(posts: List(Post)) -> Element(a) {
  ul([id("posts-previews")], list.map(posts, to_preview))
}

pub fn to_route(post: Post) -> String {
  "/posts/" <> post.id <> ".html"
}

fn to_preview(post: Post) -> Element(a) {
  let preview_classes = [#("post-preview", True), #("h-entry", True)]
  [to_preview_title, to_subtitle, to_preview_abstract]
  |> list.map(fn(gen) { gen(post) })
  |> li([classes(preview_classes)], _)
}

fn to_title(post: Post) -> Element(a) {
  let title_classes = [#("post-title", True), #("p-name", True)]
  h1([classes(title_classes)], [text(post.title)])
}

fn to_preview_title(post: Post) -> Element(a) {
  let attributes = [
    classes([#("post-preview-title", True), #("p-name", True), #("u-url", True)]),
    href(to_route(post)),
  ]
  a(attributes, [h2([], [text(post.title)])])
}

fn to_subtitle(post: Post) -> Element(a) {
  div([class("post-subtitle")], [to_date(post), to_tags(post)])
}

fn to_date(post: Post) -> Element(a) {
  let datetime = attribute("datetime", date.to_datetime(post.date))
  let date_classes = [#("post-date", True), #("dt-published", True)]
  let time_attributes = [classes(date_classes), datetime]
  time(time_attributes, [text(date.to_string(post.date))])
}

fn to_tags(post: Post) -> Element(a) {
  list.map(post.tags, to_pill)
  |> ul([class("post-tags")], _)
}

fn to_preview_abstract(post: Post) -> Element(a) {
  let abstract_classes = [
    #("post-preview-abstract", True),
    #("p-summary", True),
  ]
  p([classes(abstract_classes)], [text(post.abstract)])
}

fn to_body(post: Post) -> Element(Nil) {
  let body_classes = [#("post-body", True), #("e-content", True)]
  main([classes(body_classes)], [post.body])
}

fn to_pill(tag: String) -> Element(a) {
  // TODO: actually send to a tag page
  let link = a([href("#")], [text(tag)])
  let pill_classes = [#("post-tag", True), #("p-category", True)]
  li([classes(pill_classes)], [link])
}
