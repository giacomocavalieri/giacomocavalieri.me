import gleam/io
import blog
import lustre/element
import simplifile

pub fn main() {
  blog.home()
  |> element.to_string
  |> simplifile.write("./index.html")
}
