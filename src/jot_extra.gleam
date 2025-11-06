import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import jot
import lustre/attribute.{type Attribute} as attr
import lustre/element.{type Element}
import lustre/element/html

pub fn to_element(document: jot.Document) -> Element(a) {
  let jot.Document(content:, references: _, footnotes: _) = document
  element.fragment(containers_to_elements(content))
}

fn containers_to_elements(containers: List(jot.Container)) -> List(Element(msg)) {
  list.map(containers, container_to_element)
}

fn container_to_element(container: jot.Container) -> Element(msg) {
  case container {
    jot.ThematicBreak -> html.hr([])

    jot.RawBlock(content:) -> element.unsafe_raw_html("", "div", [], content)

    jot.Paragraph(attributes:, content:) ->
      html.p(djot_attributes(attributes), list.map(content, inline_to_element))

    jot.Codeblock(attributes:, language:, content:) -> {
      let language = case language {
        Some(language) -> language
        None -> "text"
      }

      html.pre(djot_attributes(attributes), [
        html.code(
          [
            attr.class("not-prose language-" <> language <> " hljs"),
            attr.data("lang", language),
          ],
          [html.text(content)],
        ),
      ])
    }

    jot.BulletList(layout: _, style: _, items:) ->
      html.ul([], {
        use item <- list.map(items)
        html.li([], containers_to_elements(item))
      })

    jot.Heading(attributes:, level:, content:) -> {
      let attributes = djot_attributes(attributes)
      let content = list.map(content, inline_to_element)
      case level {
        1 -> html.h1(attributes, content)
        2 -> html.h2(attributes, content)
        3 -> html.h3(attributes, content)
        4 -> html.h4(attributes, content)
        5 -> html.h5(attributes, content)
        _ -> html.h6(attributes, content)
      }
    }

    jot.Div(attributes:, items:) ->
      html.div(
        djot_attributes(attributes),
        list.map(items, container_to_element),
      )

    jot.BlockQuote(attributes:, items:) ->
      html.blockquote(
        djot_attributes(attributes),
        list.map(items, container_to_element),
      )
  }
}

fn djot_attributes(
  attributes: dict.Dict(String, String),
) -> List(Attribute(msg)) {
  dict.to_list(attributes)
  |> list.sort(fn(one, other) { string.compare(one.0, other.0) })
  |> list.map(fn(tuple) { attr.attribute(tuple.0, tuple.1) })
}

fn inline_to_element(inline: jot.Inline) -> Element(msg) {
  case inline {
    jot.Footnote(reference: _) -> panic as "footnotes not supported"
    jot.Linebreak -> html.br([])
    jot.Text(string) -> html.text(string)
    jot.NonBreakingSpace -> html.text(" ")
    jot.Link(content:, destination:) ->
      case destination {
        jot.Reference(_) -> panic as "references not supported"
        jot.Url(url) ->
          html.a([attr.href(url)], list.map(content, inline_to_element))
      }
    jot.Image(content: _, destination:) ->
      case destination {
        jot.Reference(_) -> panic as "references not supported"
        jot.Url(url) -> html.img([attr.src(url)])
      }
    jot.Emphasis(content:) -> html.em([], list.map(content, inline_to_element))
    jot.Strong(content:) ->
      html.strong([], list.map(content, inline_to_element))
    jot.Code(content:) -> html.code([], [html.text(content)])
    jot.MathDisplay(content: _) -> panic as "math display not supported"
    jot.MathInline(content: _) -> panic as "math inline not supported"
  }
}

// TO STRING -------------------------------------------------------------------

pub fn to_string(document: jot.Document) -> String {
  let jot.Document(content:, references: _, footnotes: _) = document
  containers_to_string(content)
}

fn containers_to_string(containers: List(jot.Container)) -> String {
  list.map(containers, container_to_string)
  |> string.join(with: "\n")
}

fn container_to_string(container: jot.Container) -> String {
  case container {
    jot.ThematicBreak -> ""
    jot.Paragraph(attributes: _, content:) -> inlines_to_string(content)
    jot.Heading(attributes: _, level: _, content:) -> inlines_to_string(content)
    jot.Codeblock(attributes: _, language: _, content:) -> content
    jot.BlockQuote(attributes: _, items:) -> containers_to_string(items)
    jot.Div(attributes: _, items:) -> containers_to_string(items)
    jot.RawBlock(content:) -> content
    jot.BulletList(layout: _, style: _, items:) ->
      list.map(items, containers_to_string)
      |> string.join(with: "\n")
  }
}

fn inlines_to_string(inlines: List(jot.Inline)) -> String {
  list.map(inlines, inline_to_string) |> string.join(with: " ")
}

fn inline_to_string(inline: jot.Inline) -> String {
  case inline {
    jot.Linebreak -> "\n"
    jot.NonBreakingSpace -> " "
    jot.Text(string) -> string
    jot.Footnote(reference:) -> reference

    jot.Code(content:) | jot.MathDisplay(content:) | jot.MathInline(content:) ->
      content

    jot.Link(content:, destination: _)
    | jot.Image(content:, destination: _)
    | jot.Emphasis(content:)
    | jot.Strong(content:) -> inlines_to_string(content)
  }
}
