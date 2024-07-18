import blog/page
import blog/post.{type Post}
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import lustre/element.{type Element}
import lustre/ssg
import simplifile

const out_dir = "site"

const assets_dir = "assets"

const posts_dir = "posts"

pub fn main() {
  let all_posts = read_posts()
  let posts = list.filter(all_posts, keeping: post.is_shown)
  let chronological_posts = list.sort(posts, by: post.compare)

  let uses_post = read_post("uses.md")
  let tag_to_posts = group_by_tags(posts)
  let id_to_post =
    list.map(posts, fn(post) { #(post.meta.id, post) })
    |> dict.from_list

  ssg.new(out_dir)
  |> ssg.add_static_route("/", page.homepage(chronological_posts))
  |> ssg.add_static_route("/404", page.not_found())
  |> ssg.add_static_route("/cv", page.cv())
  |> ssg.add_static_route("/uses", page.from_post(uses_post))
  |> add_dynamic_route("/posts", id_to_post, fn(_id, p) { page.from_post(p) })
  |> add_dynamic_route("/tags", tag_to_posts, page.from_tag)
  |> ssg.add_static_dir(assets_dir)
  |> ssg.build
}

fn read_post(named name: String) -> Post {
  let assert Ok(post) = post.read(from: posts_dir <> "/" <> name)
  post
}

fn read_posts() -> List(Post) {
  let assert Ok(paths) = simplifile.read_directory(posts_dir)
  use file <- list.map(paths)
  let assert Ok(post) = post.read(from: posts_dir <> "/" <> file)
  post
}

fn group_by_tags(posts: List(Post)) -> Dict(String, List(Post)) {
  use tagged_posts, post <- list.fold(over: posts, from: dict.new())
  use tagged_posts, tag <- list.fold(over: post.meta.tags, from: tagged_posts)
  use posts <- dict.update(in: tagged_posts, update: tag)
  case posts {
    Some(posts) -> [post, ..posts]
    None -> [post]
  }
}

/// The same as `ssg.add_dynamic_route` but the callback also accepts the
/// route's name.
///
fn add_dynamic_route(
  config: ssg.Config(a, b, c),
  route_name: String,
  routes: Dict(String, d),
  generate: fn(String, d) -> Element(e),
) -> ssg.Config(a, b, c) {
  let named_routes = dict.map_values(routes, fn(name, route) { #(name, route) })
  ssg.add_dynamic_route(config, route_name, named_routes, fn(named_route) {
    let #(name, route) = named_route
    generate(name, route)
  })
}
