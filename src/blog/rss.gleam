import blog/post

import lustre/element.{type Element, element, text}
import rada/date

fn to_feed_item(post: post.Post) -> Element(msg) {
  element("item", [], [
    element("title", [], [text(post.meta.title)]),
    element("link", [], [text(todo)]),
    element("description", [], [text(post.meta.abstract)]),
    element("author", [], [text("giacomo.cavalieri@icloud.com")]),
    element("pubDate", [], []),
  ])
}

fn to_rss_date_string(date: date.Date) -> String {
  todo
}
