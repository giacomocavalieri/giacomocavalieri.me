import gleam/list
import gleam/map.{Map}
import gleam/pair
import blog/page
import blog/posts
import blog/post.{Post}
import lustre/ssg

const out_dir = "site"

const assets_dir = "assets"

pub fn main() {
  let posts = [posts.intro()]
  let chronological_posts = list.sort(posts, by: post.compare)
  let tagged_posts = group_by_tags(posts)
  let indexed_posts =
    map.from_list(list.map(posts, fn(post) { #(post.id, post) }))

  ssg.new(out_dir)
  |> ssg.add_static_route("/", page.homepage(chronological_posts))
  |> ssg.add_static_route("/404", page.not_found())
  |> ssg.add_dynamic_route("/posts", indexed_posts, page.from_post)
  |> ssg.add_dynamic_route("/tags", tagged_posts, uncurry(page.from_tag))
  |> ssg.add_static_dir(assets_dir)
  |> ssg.build
}

fn group_by_tags(posts: List(Post)) -> Map(String, #(String, List(Post))) {
  let flatten_tags = fn(post: Post) { list.map(post.tags, pair.new(_, post)) }
  list.flat_map(posts, flatten_tags)
  |> list.group(by: pair.first)
  |> map.map_values(with: fn(tag, tagged_posts) {
    #(tag, list.map(tagged_posts, pair.second))
  })
}

fn uncurry(fun: fn(a, b) -> c) -> fn(#(a, b)) -> c {
  fn(pair: #(a, b)) { fun(pair.0, pair.1) }
}
