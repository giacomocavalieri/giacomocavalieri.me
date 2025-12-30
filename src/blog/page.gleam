import blog/breadcrumbs
import blog/post.{type Post}
import blog/talk.{type Talk}
import gleam/dict
import gleam/int
import gleam/list
import jot_extra
import lustre/attribute.{type Attribute, attribute} as attr
import lustre/element.{type Element}
import lustre/element/html

// --- HOME PAGE ---------------------------------------------------------------

const description = "Italy-based developer, Gleam core team member"

pub fn home() -> Element(a) {
  page("Giacomo Cavalieri", description, [attr.class("stack-l jak-cover")], [
    html.h1([], [html.text("Giacomo Cavalieri")]),
    html.main([attr.class("stack-s")], [
      html.p([], [html.text("Italy-based developer.")]),
      html.p([], [
        html.a([attr.href("https://gleam.run")], [html.text("Gleam")]),
        html.text(" core team member."),
      ]),
      html.p([], [
        html.text("Appreciate my work? Support me on "),
        html.a([attr.href("https://github.com/sponsors/giacomocavalieri")], [
          html.text("GitHub Sponsors."),
        ]),
      ]),
    ]),
    navbar(
      html.li([], [
        html.a([attr.href("contact.html")], [html.text("contact")]),
      ]),
    ),
  ])
}

pub fn contact() -> Element(a) {
  page("Giacomo Cavalieri", description, [attr.class("stack-l jak-cover")], [
    html.h1([], [html.text("Giacomo Cavalieri")]),
    html.address([attr.class("stack-s")], [
      html.p([], [
        html.text("For any inquiry "),
        html.a([attr.href("mailto:info@giacomocavalieri.me")], [
          html.text("info@giacomocavalieri.me"),
        ]),
      ]),
      html.p([], [
        html.text("My open source work is on GitHub "),
        html.a([attr.href("https://github.com/giacomocavalieri")], [
          html.text("@giacomocavalieri"),
        ]),
      ]),
      html.p([], [
        html.text("Find me on Bluesky "),
        html.a([attr.href("https://bsky.app/profile/giacomocavalieri.me")], [
          html.text("@giacomocavalieri"),
        ]),
      ]),
    ]),
    navbar(
      html.li([], [
        html.a([attr.href("index.html")], [html.text("home")]),
      ]),
    ),
  ])
}

fn navbar(last_item: Element(a)) -> Element(a) {
  html.nav([], [
    html.ul([attr.class("switcher nav-switcher")], [
      html.li([], [
        html.a([attr.href("writing.html"), animate("writing")], [
          html.text("writing"),
        ]),
      ]),
      html.li([], [
        html.a([attr.href("speaking.html"), animate("speaking")], [
          html.text("speaking"),
        ]),
      ]),
      last_item,
    ]),
  ])
}

fn animate(name: String) -> Attribute(a) {
  attr.style("view-transition-name", name <> "-animation")
}

// --- 404 PAGE ---------------------------------------------------------------

pub fn not_found() -> Element(a) {
  page("Not found", "There's nothing here", [attr.class("stack-l")], [
    html.h1([], [html.text("There's nothing here!")]),
    html.p([], [
      html.text("Go back "),
      html.a([attr.href("index.html")], [html.text("home")]),
    ]),
  ])
}

// --- POST PAGE ---------------------------------------------------------------

pub fn writing(posts: List(Post)) -> Element(Nil) {
  let posts_by_year =
    list.group(posts, fn(post) { post.meta.date.year })
    |> dict.to_list
    |> list.sort(fn(one, other) { int.compare(other.0, one.0) })

  page("writing", description, [attr.class("stack-l")], [
    breadcrumbs.new([
      breadcrumbs.link("home", to: "/"),
      breadcrumbs.animated_link("writing", to: "/writing.html"),
    ]),
    html.main([], [
      html.ol([attr.class("stack")], {
        use #(year, posts) <- list.map(posts_by_year)
        html.li([attr.class("stack-s")], [
          html.h2([], [html.text(int.to_string(year))]),
          post.to_preview_list(posts),
        ])
      }),
    ]),
  ])
}

pub fn speaking(talks: List(Talk)) -> Element(Nil) {
  let talks_by_year =
    list.group(talks, fn(talk) { talk.date.year })
    |> dict.to_list
    |> list.sort(fn(one, other) { int.compare(other.0, one.0) })

  page("speaking", description, [attr.class("stack-l")], [
    breadcrumbs.new([
      breadcrumbs.link("home", to: "/"),
      breadcrumbs.animated_link("speaking", to: "/speaking.html"),
    ]),
    html.main([], [
      html.ol([attr.class("stack")], {
        use #(year, talks) <- list.map(talks_by_year)
        html.li([attr.class("stack-s")], [
          html.h2([], [html.text(int.to_string(year))]),
          talk.to_preview_list(talks),
        ])
      }),
    ]),
  ])
}

pub fn from_post(post: Post) -> Element(Nil) {
  page(
    post.meta.title,
    jot_extra.to_string(post.meta.abstract),
    [attr.class("stack-l")],
    post.to_article(post),
  )
}

// --- HELPERS -----------------------------------------------------------------

fn page(
  title: String,
  description: String,
  attributes: List(Attribute(a)),
  elements: List(Element(a)),
) -> Element(a) {
  html.html([lang("en")], [
    default_head(title, description),
    html.body(attributes, elements),
  ])
}

const hljs_script_url = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"

const hljs_diff_url = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/languages/diff.min.js"

const gleam_hljs_script_url = "/highlightjs-gleam.js"

fn default_head(page_title: String, description: String) -> Element(a) {
  html.head([], [
    html.title([], page_title),
    charset("utf-8"),
    viewport([
      content("width=device-width, initial-scale=1.0, viewport-fit=cover"),
    ]),
    html.link([
      attr.rel("alternate"),
      attr.type_("application/rss+xml"),
      attr.title("giacomocavalieri.me posts feed"),
      attr.href("https://giacomocavalieri.me/feed.xml"),
    ]),
    html.meta([property("og:site_name"), content("Giacomo Cavalieri")]),
    html.meta([property("og:title"), content(page_title)]),
    html.meta([property("og:type"), content("website")]),
    html.meta([property("og:description"), content(description)]),
    html.meta([attr.name("description"), content(description)]),
    stylesheet("/style.css"),
    html.script([attr.src(hljs_script_url)], ""),
    html.script([attr.src(hljs_diff_url)], ""),
    html.script([attr.src(gleam_hljs_script_url)], ""),
    html.script([], "hljs.highlightAll();"),
  ])
}

// --- META BUILDERS -----------------------------------------------------------

fn meta_named(meta_name: String, attributes: List(Attribute(a))) -> Element(a) {
  html.meta([attr.name(meta_name), ..attributes])
}

fn viewport(attributes: List(Attribute(a))) -> Element(a) {
  meta_named("viewport", attributes)
}

fn stylesheet(file: String) -> Element(a) {
  html.link([attr.rel("stylesheet"), attr.href(file)])
}

fn charset(value: String) -> Element(a) {
  html.meta([attribute("charset", value)])
}

fn content(value: String) -> Attribute(a) {
  attribute("content", value)
}

fn lang(value: String) -> Attribute(a) {
  attribute("lang", value)
}

fn property(value: String) -> Attribute(a) {
  attribute("property", value)
}
