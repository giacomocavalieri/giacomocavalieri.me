import gleam/list
import lustre/attribute.{type Attribute} as attr
import lustre/element.{type Element}
import lustre/element/html

pub opaque type Item {
  Link(name: String, href: String)
  AnimatedLink(name: String, href: String)
  BlockLink(name: String)
}

pub fn new(items: List(Item)) -> Element(a) {
  let items_count = list.length(items)
  html.ol([attr.class("breadcrumb"), attr.aria_label("Breadcrumb")], {
    use item, index <- list.index_map(items)
    html.li([], [item_to_element(item, index == items_count - 1)])
  })
}

fn item_to_element(item: Item, is_last: Bool) -> Element(a) {
  case item, is_last {
    // Any element that is last will not produce a link but a title.
    Link(name:, ..), True ->
      html.h3([attr.aria_current("page")], [html.text(name)])
    AnimatedLink(name:, ..), True ->
      html.h3([attr.aria_current("page"), animate(name)], [html.text(name)])
    BlockLink(name:), True ->
      html.h2([attr.aria_current("page"), attr.data("crumb", "block")], [
        html.text(name),
      ])

    Link(name:, href:), False -> html.a([attr.href(href)], [html.text(name)])
    AnimatedLink(name:, href:), False ->
      html.a([attr.href(href), animate(name)], [html.text(name)])
    BlockLink(name: _), False -> panic as "block link should be last"
  }
}

fn animate(name: String) -> Attribute(a) {
  attr.style("view-transition-name", name <> "-animation")
}

pub fn link(name: String, to page: String) -> Item {
  Link(name:, href: page)
}

pub fn animated_link(name: String, to page: String) -> Item {
  AnimatedLink(name:, href: page)
}

pub fn block_link(name: String) -> Item {
  BlockLink(name:)
}
