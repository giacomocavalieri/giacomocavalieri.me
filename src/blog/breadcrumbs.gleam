import lustre/attribute as attr
import lustre/element.{type Element}
import lustre/element/html

pub fn home() -> Element(a) {
  html.nav([attr.class("breadcrumbs")], [
    html.a([attr.rel("author"), attr.href("/"), attr.class("breadcrumb-link")], [
      html.text("← home"),
    ]),
  ])
}
