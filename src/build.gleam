import gleam/list
import lustre/element
import simplifile
import blog/page
import blog/post.{Post}
import blog/posts

pub fn main() {
  let _ = simplifile.create_directory("./site")
  let _ = simplifile.create_directory("./site/posts")
  let posts = [posts.intro()]

  let _ =
    page.home(posts)
    |> element.to_string
    |> simplifile.write("./site/index.html")

  list.each(posts, write_post)
}

fn write_post(post: Post) -> Nil {
  let _ =
    page.from_post(post)
    |> element.to_string
    |> simplifile.write("./site/posts/" <> post.id <> ".html")
  Nil
}
