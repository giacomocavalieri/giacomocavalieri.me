import blog/breadcrumbs
import blog/post.{type Post}
import glevatar
import jot_extra
import lustre/attribute.{type Attribute, attribute} as attr
import lustre/element.{type Element}
import lustre/element/html

// --- HOME PAGE ---------------------------------------------------------------

pub fn homepage(posts: List(Post)) -> Element(a) {
  with_body(
    "Giacomo Cavalieri",
    "A personal blog where I share my thoughts as I jump from one obsession to the other",
    [homepage_header(), html.main([], [post.to_preview_list(posts)])],
  )
}

fn profile_picture_source() -> String {
  glevatar.new("giacomo.cavalieri@icloud.com")
  |> glevatar.set_size(440)
  |> glevatar.to_string
}

fn profile_picture() -> Element(a) {
  html.img([
    attr.id("homepage-profile-picture"),
    attr.class("u-photo"),
    attr.alt(""),
    attr.src(profile_picture_source()),
  ])
}

fn homepage_header() -> Element(a) {
  let me_link = fn(link, name) {
    html.a([attr.href(link), attr.rel("me"), attr.class("u-url")], [
      html.text(name),
    ])
  }

  html.header([attr.id("homepage-header"), attr.class("h-card p-author")], [
    profile_picture(),
    html.h2([attr.id("homepage-subtitle")], [html.text("Hello 👋")]),
    html.h1([attr.id("homepage-title")], [
      html.text("I'm "),
      html.span([attr.class("p-given-name")], [html.text("Giacomo")]),
    ]),
    html.p([attr.id("homepage-description"), attr.class("p-note")], [
      html.i([], [html.text("He/Him")]),
      html.text(" • I love functional programming and learning new things"),
      html.br([]),
      html.text("Sharing my thoughts as I hop from one obsession to the other"),
      html.br([]),
      html.text("You can also find me on "),
      me_link("https://github.com/giacomocavalieri", "GitHub"),
      html.text(" and "),
      me_link("https://bsky.app/profile/giacomocavalieri.me", "Bluesky"),
      html.text("!"),
    ]),
  ])
}

// --- 404 PAGE ---------------------------------------------------------------

pub fn not_found() -> Element(a) {
  with_body("Not found", "There's nothing here", [
    html.main([], [
      html.h1([], [html.text("There's nothing here!")]),
      html.p([], [
        html.text("Go back to the "),
        html.a([attr.href("/")], [html.text("home page")]),
      ]),
    ]),
  ])
}

// --- POST PAGE ---------------------------------------------------------------

pub fn from_post(post: Post) -> Element(Nil) {
  with_body(post.meta.title, jot_extra.to_string(post.meta.abstract), [
    post.to_article(post),
  ])
}

// --- TAG PAGE ----------------------------------------------------------------

pub fn from_tag(tag: String, posts: List(Post)) -> Element(Nil) {
  with_body(tag, "posts tagged \"" <> tag <> "\"", [
    html.h1([attr.class("tag-title")], [
      html.text("Posts tagged "),
      html.i([], [html.text("\"" <> tag <> "\"")]),
    ]),
    breadcrumbs.home(),
    html.main([], [post.to_preview_list(posts)]),
  ])
}

// --- CV PAGE -----------------------------------------------------------------

pub fn cv() -> Element(nothing) {
  with_body("cv", "my curriculum vitae", [])
}

// --- HELPERS -----------------------------------------------------------------

fn with_body(
  title: String,
  description: String,
  elements: List(Element(a)),
) -> Element(a) {
  html.html([lang("en")], [
    default_head(title, description),
    html.body([], [
      html.div([attr.class("limit-max-width-and-center")], elements),
    ]),
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
    html.meta([property("og:site_name"), content("Giacomo Cavalieri's blog")]),
    html.meta([property("og:title"), content(page_title)]),
    html.meta([property("og:type"), content("website")]),
    html.meta([property("og:description"), content(description)]),
    html.meta([attr.name("description"), content(description)]),
    html.meta([property("twitter:card"), content("summary")]),
    html.meta([property("twitter:title"), content(page_title)]),
    html.meta([property("twitter:description"), content(description)]),
    html.meta([property("twitter:creator"), content("@giacomo_cava")]),
    html.link([
      attr.rel("payload"),
      attr.href("Mona-Sans.woff2"),
      as_("font"),
      attr.type_("font/woff2"),
      crossorigin(),
    ]),
    theme_color([content("#cceac3"), media("(prefers-color-scheme: light)")]),
    stylesheet("/style.css"),
    html.script([attr.src(hljs_script_url)], ""),
    html.script([attr.src(hljs_diff_url)], ""),
    html.script([attr.src(gleam_hljs_script_url)], ""),
    html.script([], "hljs.highlightAll();"),
  ])
}

// --- META BUILDERS ---

fn meta_named(meta_name: String, attributes: List(Attribute(a))) -> Element(a) {
  html.meta([attr.name(meta_name), ..attributes])
}

fn viewport(attributes: List(Attribute(a))) -> Element(a) {
  meta_named("viewport", attributes)
}

fn theme_color(attributes: List(Attribute(a))) -> Element(a) {
  meta_named("theme-color", attributes)
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

fn media(value: String) -> Attribute(a) {
  attribute("media", value)
}

fn lang(value: String) -> Attribute(a) {
  attribute("lang", value)
}

fn property(value: String) -> Attribute(a) {
  attribute("property", value)
}

fn as_(value: String) -> Attribute(a) {
  attribute("as", value)
}

fn crossorigin() -> Attribute(a) {
  attribute("crossorigin", "true")
}
