import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html

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

pub fn heading(depth: Int, content: List(Element(msg))) -> Element(msg) {
  case depth {
    1 -> html.h1([], content)
    2 -> html.h2([], content)
    3 -> html.h3([], content)
    4 -> html.h4([], content)
    5 -> html.h5([], content)
    _ -> html.h6([], content)
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
