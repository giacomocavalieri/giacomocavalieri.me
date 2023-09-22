import lustre/attribute.{class, href, rel}
import lustre/element.{Element, text}
import lustre/element/html.{a, nav}

pub fn home() -> Element(a) {
  let home_link = a([rel("author"), href("/")], [text("← home")])
  nav([class("breadcrumbs")], [home_link])
}
