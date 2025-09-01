import blog/post
import gleam/int
import gleam/list
import gleam/order
import gleam/string
import gleam/time/calendar
import jot_extra
import lustre/attribute as attr
import lustre/element.{type Element, element}
import lustre/element/html

pub fn feed_from_posts(posts: List(post.Post)) -> Element(msg) {
  let assert Ok(latest_post) =
    list.reduce(posts, fn(one, other) {
      case post.compare(one, other) {
        order.Gt | order.Eq -> one
        order.Lt -> other
      }
    })

  element("rss", [attr.attribute("version", "2.0")], [
    element("channel", [], [
      element("title", [], [html.text("giacomocavalieri.me posts feed")]),
      link("https://giacomocavalieri.me"),
      element("description", [], [
        html.text("All the posts from my personal blog about programming."),
      ]),
      element("language", [], [html.text("en")]),
      element("pubDate", [], [
        html.text(to_rss_date_string(latest_post.meta.date)),
      ]),
      ..list.map(posts, to_feed_item)
    ]),
  ])
}

fn to_feed_item(post: post.Post) -> Element(msg) {
  element("item", [], [
    element("title", [], [html.text(post.meta.title)]),
    link("https://giacomocavalieri.me/posts/" <> post.meta.id <> ".html"),
    element("description", [], [
      html.text(jot_extra.to_string(post.meta.abstract)),
    ]),
    element("author", [], [html.text("giacomo.cavalieri@icloud.com")]),
    element("pubDate", [], [html.text(to_rss_date_string(post.meta.date))]),
  ])
}

fn to_rss_date_string(date: calendar.Date) -> String {
  let calendar.Date(year:, month:, day:) = date

  let day = int.to_string(day) |> string.pad_start(to: 2, with: "0")
  let year = int.to_string(year)

  let month = case month {
    calendar.April -> "Apr"
    calendar.August -> "Aug"
    calendar.December -> "Dec"
    calendar.February -> "Feb"
    calendar.January -> "Jan"
    calendar.July -> "Jul"
    calendar.June -> "Jun"
    calendar.March -> "Mar"
    calendar.May -> "May"
    calendar.November -> "Nov"
    calendar.October -> "Oct"
    calendar.September -> "Sep"
  }

  day <> " " <> month <> " " <> year <> " 00:00:00 GMT"
}

fn link(url: String) -> Element(msg) {
  element.unsafe_raw_html("", "link", [], url)
}
