import lustre/element.{text}
import lustre/element/html.{a, br, p}
import lustre/attribute.{href}
import blog/post.{Post}
import blog/date.{Sep}

/// The introductory placeholder post!
/// 
pub fn intro() -> Post {
  Post(
    id: "01-intro",
    title: "Look! I made this with Lustre ✨",
    date: date.new(11, Sep, 2023),
    tags: ["Gleam", "Lustre", "Test", "FP"],
    abstract: "This is just an example post, things are still very much a work in progress!",
    body: p(
      [],
      [
        text("This is just an example post, "),
        text("things are still very much a work in progress."),
        br([]),
        text("In the meantime do check out "),
        a([href("https://pkg.hayleigh.dev/lustre/")], [text("Lustre")]),
        text(", it's really cool!"),
      ],
    ),
  )
}
