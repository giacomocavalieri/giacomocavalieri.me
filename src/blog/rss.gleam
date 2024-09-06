import blog/post
import gleam/list
import gleam/order
import lustre/attribute

import lustre/element.{type Element, advanced, element, text}
import rada/date

pub fn feed_from_posts(posts: List(post.Post)) -> Element(msg) {
  let assert Ok(latest_date) =
    list.map(posts, fn(post) { post.meta.date })
    |> list.reduce(fn(one, other) {
      case date.compare(one, other) {
        order.Gt | order.Eq -> one
        order.Lt -> other
      }
    })

  element("rss", [attribute.attribute("version", "2.0")], [
    element("channel", [], [
      element("title", [], [text("giacomocavalieri.me posts feed")]),
      link("https://giacomocavalieri.me"),
      element("description", [], [
        text("All the posts from my personal blog about programming."),
      ]),
      element("language", [], [text("en")]),
      element("pubDate", [], [text(to_rss_date_string(latest_date))]),
      ..list.map(posts, to_feed_item)
    ]),
  ])
}

fn to_feed_item(post: post.Post) -> Element(msg) {
  element("item", [], [
    element("title", [], [text(post.meta.title)]),
    link("https://giacomocavalieri.me/posts/" <> post.meta.id <> ".html"),
    element("description", [], [text(post.meta.abstract)]),
    element("author", [], [text("giacomo.cavalieri@icloud.com")]),
    element("pubDate", [], [text(to_rss_date_string(post.meta.date))]),
  ])
}

fn to_rss_date_string(date: date.Date) -> String {
  date.format(date, "E, dd MMM yyyy") <> " 00:00:00 GMT"
}

fn link(url: String) -> Element(msg) {
  advanced("", "link", [], [text(url)], False, False)
}
