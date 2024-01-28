import lustre/attribute.{attribute, class, href, id}
import lustre/element.{type Element}
import lustre/element/html.{a, div}
import blog/id

pub fn code(src: String, lang: String) -> Element(msg) {
  let attributes = [
    attribute("data-lang", lang),
    attribute.class("not-prose language-" <> lang),
  ]
  html.pre([], [html.code(attributes, [element.text(src)])])
}

pub fn emphasis(content: List(Element(msg))) {
  html.em([], content)
}

pub fn linked_heading(depth: Int, content: String) -> Element(msg) {
  let heading = heading(depth, content)
  let clip_id = id.from_string(content)
  let clip =
    a([href("#" <> clip_id), id(clip_id), class("clip")], [text("🔗")])

  div([class("post-heading"), class(depth_to_class(depth))], [clip, heading])
}

fn depth_to_class(depth: Int) -> String {
  case depth {
    1 -> "h1-title"
    2 -> "h2-title"
    3 -> "h3-title"
    4 -> "h4-title"
    5 -> "h5-title"
    _ -> "h6-title"
  }
}

fn heading(depth: Int, content: String) -> Element(msg) {
  case depth {
    1 -> html.h1([], [text(content)])
    2 -> html.h2([], [text(content)])
    3 -> html.h3([], [text(content)])
    4 -> html.h4([], [text(content)])
    5 -> html.h5([], [text(content)])
    _ -> html.h6([], [text(content)])
  }
}

pub fn inline_code(src: String) -> Element(msg) {
  html.code([], [text(src)])
}

pub fn link(url: String, content: List(Element(msg))) -> Element(msg) {
  html.a([attribute.href(url)], content)
}

pub fn list(ordered: Bool, items: List(Element(msg))) -> Element(msg) {
  case ordered {
    True -> html.ol([], items)
    False -> html.ul([], items)
  }
}

pub fn list_item(content: List(Element(msg))) -> Element(msg) {
  html.li([], content)
}

pub fn paragraph(content: List(Element(msg))) -> Element(msg) {
  html.p([], content)
}

pub fn strong(content: List(Element(msg))) -> Element(msg) {
  html.strong([], content)
}

pub fn text(content: String) -> Element(msg) {
  element.text(content)
}

pub fn blockquote(content: List(Element(msg))) -> Element(msg) {
  html.blockquote([], content)
}

pub fn error() -> Element(msg) {
  html.blockquote([], [element.text("There was an unhandled md element!")])
}
