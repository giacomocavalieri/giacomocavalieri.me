import lustre/element.{Element, text}
import lustre/element/html.{a, nav}
import lustre/attribute.{class, href, rel}

pub fn home() -> Element(a) {
  let home_link = a([rel("author"), href("/")], [text("← home")])
  nav([class("breadcrumbs")], [home_link])
}
