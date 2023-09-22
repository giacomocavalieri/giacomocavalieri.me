import gleam/list
import gleam/map.{Map}
import gleam/pair
import lustre/ssg
import simplifile
import blog/page
import blog/post.{Post}

const out_dir = "site"

const assets_dir = "assets"

const posts_dir = "posts"

pub fn main() {
  // I don't care about failing gracefully, I'll just let the world burn if
  // something goes wrong :P
  let posts = read_posts()
  let chronological_posts = list.sort(posts, by: post.compare)
  let tagged_posts = group_by_tags(posts)
  let indexed_posts =
    map.from_list(list.map(posts, fn(post) { #(post.meta.id, post) }))

  ssg.new(out_dir)
  |> ssg.add_static_route("/", page.homepage(chronological_posts))
  |> ssg.add_static_route("/404", page.not_found())
  |> ssg.add_dynamic_route("/posts", indexed_posts, page.from_post)
  |> ssg.add_dynamic_route("/tags", tagged_posts, uncurry(page.from_tag))
  |> ssg.add_static_dir(assets_dir)
  |> ssg.build
}

fn read_posts() -> List(Post) {
  let assert Ok(paths) = simplifile.list_contents(of: posts_dir)
  use file <- list.map(paths)
  let assert Ok(post) = post.read(from: posts_dir <> "/" <> file)
  post
}

fn group_by_tags(posts: List(Post)) -> Map(String, #(String, List(Post))) {
  let flat_tags = fn(post: Post) { list.map(post.meta.tags, pair.new(_, post)) }
  list.flat_map(posts, flat_tags)
  |> list.group(by: pair.first)
  |> map.map_values(with: fn(tag, tagged_posts) {
    #(tag, list.map(tagged_posts, pair.second))
  })
}

fn uncurry(fun: fn(a, b) -> c) -> fn(#(a, b)) -> c {
  fn(pair: #(a, b)) { fun(pair.0, pair.1) }
}
