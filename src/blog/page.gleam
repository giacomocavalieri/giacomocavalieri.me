import lustre/attribute.{
  Attribute, alt, attribute, class, href, id, name, rel, src,
}
import lustre/element.{Element, text}
import lustre/element/html.{
  a, body, br, div, h1, h2, head, header, html, i, img, link, main, meta, p,
  script, span, title,
}
import blog/breadcrumbs
import blog/post.{Post}
import glevatar

/// --- HOME PAGE ---
/// 
pub fn homepage(posts: List(Post)) -> Element(a) {
  with_body(
    "Giacomo Cavalieri",
    "A personal blog where I share my thoughts as I jump from one obsession to the other",
    [homepage_header(), main([], [post.to_preview_list(posts)])],
  )
}

fn profile_picture_source() -> String {
  glevatar.new("giacomo.cavalieri@icloud.com")
  |> glevatar.set_size(440)
  |> glevatar.to_string
}

fn profile_picture() -> Element(a) {
  img([
    id("homepage-profile-picture"),
    class("u-photo"),
    alt(""),
    src(profile_picture_source()),
  ])
}

fn homepage_header() -> Element(a) {
  let subtitle = h2([id("homepage-subtitle")], [text("Hello 👋")])

  let title =
    h1(
      [id("homepage-title")],
      [text("I'm "), span([class("p-given-name")], [text("Giacomo")])],
    )

  let github_link =
    a(
      [href("https://github.com/giacomocavalieri"), rel("me"), class("u-url")],
      [text("GitHub")],
    )

  let twitter_link =
    a(
      [href("https://twitter.com/giacomo_cava"), rel("me"), class("u-url")],
      [text("Twitter")],
    )

  let description =
    p(
      [id("homepage-description"), class("p-note")],
      [
        i([], [text("He/Him")]),
        text(" • I love functional programming and learning new things"),
        br([]),
        text("Sharing my thoughts as I hop from one obsession to the other"),
        br([]),
        text("You can also find me on "),
        github_link,
        text(" and "),
        twitter_link,
        text("!"),
      ],
    )

  header(
    [id("homepage-header"), class("h-card p-author")],
    [profile_picture(), subtitle, title, description],
  )
}

/// --- 404 PAGE ---
/// 
pub fn not_found() -> Element(a) {
  let title = h1([], [text("There's nothing here!")])
  let subtitle =
    p([], [text("Go back to the "), a([href("/")], [text("home page")])])

  with_body("Not found", "There's nothing here", [main([], [title, subtitle])])
}

/// --- POST PAGE ---
/// 
pub fn from_post(post: Post) -> Element(Nil) {
  with_body(post.meta.title, post.meta.abstract, [post.to_article(post)])
}

/// --- TAG PAGE ---
/// 
pub fn from_tag(tag: String, posts: List(Post)) -> Element(Nil) {
  let title =
    h1(
      [class("tag-title")],
      [text("Posts tagged "), i([], [text("\"" <> tag <> "\"")])],
    )
  let home_link = breadcrumbs.home()
  let previews = main([], [post.to_preview_list(posts)])
  let abstract = "posts tagged \"" <> tag <> "\""
  with_body(tag, abstract, [title, home_link, previews])
}

/// --- HELPERS ---
/// 
fn with_body(
  title: String,
  description: String,
  elements: List(Element(a)),
) -> Element(a) {
  let head = default_head(title, description)
  html(
    [lang("en")],
    [head, body([], [div([class("limit-max-width-and-center")], elements)])],
  )
}

const hljs_script_url = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"

const gleam_hljs_script_url = "/highlightjs-gleam.js"

fn default_head(page_title: String, description: String) -> Element(a) {
  head(
    [],
    [
      title([], page_title),
      charset("utf-8"),
      viewport([
        content("width=device-width, initial-scale=1.0, viewport-fit=cover"),
      ]),
      meta([property("og:site_name"), content("Giacomo Cavalieri's blog")]),
      meta([property("og:title"), content(page_title)]),
      meta([property("og:type"), content("website")]),
      meta([
        name("image"),
        property("og:image"),
        content(profile_picture_source()),
      ]),
      meta([property("og:description"), content(description)]),
      meta([name("description"), content(description)]),
      meta([property("twitter:card"), content("summary")]),
      meta([property("twitter:title"), content(page_title)]),
      meta([property("twitter:description"), content(description)]),
      meta([property("twitter:creator"), content("@giacomo_cava")]),
      meta([property("twitter:image"), content(profile_picture_source())]),
      theme_color([content("#cceac3"), media("(prefers-color-scheme: light)")]),
      stylesheet("/style.css"),
      script([src(hljs_script_url)], ""),
      script([src(gleam_hljs_script_url)], ""),
      script([], "hljs.highlightAll();"),
    ],
  )
}

// --- META BUILDERS ---

fn meta_named(meta_name: String, attributes: List(Attribute(a))) -> Element(a) {
  meta([name(meta_name), ..attributes])
}

fn viewport(attributes: List(Attribute(a))) -> Element(a) {
  meta_named("viewport", attributes)
}

fn theme_color(attributes: List(Attribute(a))) -> Element(a) {
  meta_named("theme-color", attributes)
}

fn stylesheet(file: String) -> Element(a) {
  link([rel("stylesheet"), href(file)])
}

fn charset(value: String) -> Element(a) {
  meta([attribute("charset", value)])
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
