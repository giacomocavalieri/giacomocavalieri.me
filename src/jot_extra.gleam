import gleam/dict
import gleam/dynamic/decode.{type Decoder}
import gleam/json
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
  list.map(blocks(containers), fn(groups) {
    html.section([attr.class("stack")], list.map(groups, container_to_element))
  })
}

fn blocks(content: List(jot.Container)) -> List(List(jot.Container)) {
  blocks_loop(content, [], [])
}

fn blocks_loop(
  content: List(jot.Container),
  group: List(jot.Container),
  groups: List(List(jot.Container)),
) -> List(List(jot.Container)) {
  case content {
    [] ->
      case group {
        [_, ..] -> list.reverse([list.reverse(group), ..groups])
        [] -> list.reverse(groups)
      }

    [jot.Heading(..) as elem, ..rest] ->
      case group {
        [_, ..] -> blocks_loop(rest, [elem], [list.reverse(group), ..groups])
        [] -> blocks_loop(rest, [elem], groups)
      }

    [elem, ..rest] -> blocks_loop(rest, [elem, ..group], groups)
  }
}

fn container_to_element(container: jot.Container) -> Element(msg) {
  case container {
    jot.ThematicBreak -> html.hr([])

    jot.RawBlock(content:) ->
      case json.parse(content, extra_decoder()) {
        Ok(extra) -> extra_to_element(extra)
        Error(_) -> element.unsafe_raw_html("", "div", [], content)
      }

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
        [attr.class("stack"), ..djot_attributes(attributes)],
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

// RAW BLOCKS WITH EXTRA DATA --------------------------------------------------

type Extra {
  BlueskySocialEmbed(
    display_name: String,
    account: String,
    link: String,
    content: String,
  )
}

fn extra_decoder() -> Decoder(Extra) {
  use kind <- decode.field("kind", decode.string)
  case kind {
    "Bluesky" -> bluesky_social_embed_decoder()
    _ -> panic as "unsupported"
  }
}

fn bluesky_social_embed_decoder() -> Decoder(Extra) {
  use display_name <- decode.field("display_name", decode.string)
  use account <- decode.field("account", decode.string)
  use link <- decode.field("link", decode.string)
  use lines <- decode.field("content", decode.list(decode.string))
  decode.success(BlueskySocialEmbed(
    display_name:,
    account:,
    link:,
    content: string.join(lines, with: "\n"),
  ))
}

const bluesky_logo = "data:image/svg+xml,%3csvg%20xmlns='http://www.w3.org/2000/svg'%20fill='none'%20viewBox='0%200%20320%20286'%3e%3cpath%20fill='rgb(10,122,255)'%20d='M69.364%2019.146c36.687%2027.806%2076.147%2084.186%2090.636%20114.439%2014.489-30.253%2053.948-86.633%2090.636-114.439C277.107-.917%20320-16.44%20320%2032.957c0%209.865-5.603%2082.875-8.889%2094.729-11.423%2041.208-53.045%2051.719-90.071%2045.357%2064.719%2011.12%2081.182%2047.953%2045.627%2084.785-80%2082.874-106.667-44.333-106.667-44.333s-26.667%20127.207-106.667%2044.333c-35.555-36.832-19.092-73.665%2045.627-84.785-37.026%206.362-78.648-4.149-90.071-45.357C5.603%20115.832%200%2042.822%200%2032.957%200-16.44%2042.893-.917%2069.364%2019.147Z'/%3e%3c/svg%3e"

fn extra_to_element(extra: Extra) -> Element(msg) {
  case extra {
    BlueskySocialEmbed(display_name:, account:, content:, link:) ->
      html.figure([attr.class("stack-s bluesky-embed")], [
        html.div([attr.class("sidebar")], [
          html.img([attr.class("social-logo"), attr.src(bluesky_logo)]),
          html.div([attr.class("stack-xs")], [
            html.p([], [html.text(display_name)]),
            html.a([attr.href("https://bsky.app/profile/" <> account)], [
              html.text("@" <> account),
            ]),
          ]),
        ]),
        element.unsafe_raw_html("", "div", [attr.class("stack-s")], content),
        html.a([attr.href(link)], [html.text("Read on Bluesky")]),
      ])
  }
}
