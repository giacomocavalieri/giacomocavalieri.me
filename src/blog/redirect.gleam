import blog/post.{type Post}
import blog/talk.{type Talk, Talk}
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/time/calendar

pub fn generate(posts: List(Post), talks: List(Talk)) -> String {
  let assert Ok(latest_post) =
    list.max(posts, fn(one, other) {
      calendar.naive_date_compare(one.meta.date, other.meta.date)
    })

  let assert Ok(Talk(youtube_link: Some(talk_path), ..)) =
    list.max(talks, fn(one, other) {
      case one.youtube_link, other.youtube_link {
        None, _ -> order.Lt
        _, None -> order.Gt
        Some(_), Some(_) -> calendar.naive_date_compare(one.date, other.date)
      }
    })

  "/latest/post /writing/" <> latest_post.meta.id <> " 302
/latest/talk " <> talk_path <> " 302"
}
