import lustre/element.{Element, text}
import lustre/element/html.{
  a, article, div, h1, h2, header, li, main, p, time, ul,
}
import lustre/attribute.{Attribute, attribute, class, href, id}
import blog/date
import blog/breadcrumbs
import gleam/list
import gleam/order.{Order}

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

pub fn compare(one: Post, other: Post) -> Order {
  date.compare(one.date, other.date)
}

/// Turns a post (with html body) into an `<article>` element that can be used
/// for a full post page.
/// 
pub fn to_article(post: Post) -> Element(Nil) {
  let title = h1([classes(["post-title", "p-name"])], [text(post.title)])
  let home_link = breadcrumbs.home()
  let subtitle = to_subtitle(post)
  let header = header([], [title, home_link, subtitle])
  let body = main([classes(["post-body", "e-content"])], [post.body])
  article([classes(["post", "h-entry"])], [header, body])
}

pub fn to_preview_list(posts: List(Post)) -> Element(a) {
  ul([id("posts-previews")], list.map(posts, to_preview))
}

fn to_preview(post: Post) -> Element(a) {
  let title_classes = classes(["post-preview-title", "p-name", "u-url"])
  let title_attributes = [title_classes, href("/posts/" <> post.id <> ".html")]
  let title = a(title_attributes, [h2([], [text(post.title)])])
  let subtitle = to_subtitle(post)
  let abstract =
    p([classes(["post-preview-abstract", "p-summary"])], [text(post.abstract)])

  li([classes(["post-preview", "h-entry"])], [title, subtitle, abstract])
}

fn to_subtitle(post: Post) -> Element(a) {
  let tags = ul([class("post-tags")], list.map(post.tags, to_pill))
  div([class("post-subtitle")], [to_date(post), tags])
}

fn to_date(post: Post) -> Element(a) {
  let datetime = attribute("datetime", date.to_datetime(post.date))
  let time_attributes = [classes(["post-date", "dt-published"]), datetime]
  time(time_attributes, [text(date.to_string(post.date))])
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
