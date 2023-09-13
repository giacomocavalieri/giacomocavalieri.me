import blog
import lustre/element
import simplifile

pub fn main() {
  let _ = simplifile.create_directory("/site")

  blog.home()
  |> element.to_string
  |> simplifile.write("./site/index.html")
}
