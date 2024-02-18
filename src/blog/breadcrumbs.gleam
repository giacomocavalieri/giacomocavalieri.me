import lustre/attribute.{class, href, rel}
import lustre/element.{type Element, text}
import lustre/element/html.{a, nav}

pub fn home() -> Element(a) {
  let home_link =
    a([rel("author"), href("/"), class("breadcrumb-link")], [text("← home")])
  nav([class("breadcrumbs")], [home_link])
}
