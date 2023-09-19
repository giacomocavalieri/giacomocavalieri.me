import gleam/list
import gleam/map
import blog/page
import blog/posts
import blog/date
import lustre/ssg

const out_dir = "site"

const assets_dir = "assets"

pub fn main() {
  let sorted_posts =
    [posts.intro()]
    |> list.sort(by: fn(one, other) { date.compare(one.date, other.date) })

  let posts =
    sorted_posts
    |> list.map(fn(post) { #(post.id, post) })
    |> map.from_list

  ssg.new(out_dir)
  |> ssg.add_static_route("/", page.home(sorted_posts))
  |> ssg.add_static_route("/404", page.not_found())
  |> ssg.add_dynamic_route("/posts", posts, page.from_post)
  |> ssg.add_static_dir(assets_dir)
  |> ssg.build
}
