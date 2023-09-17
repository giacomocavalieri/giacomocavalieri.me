import lustre/element.{Element, text}
import lustre/element/html.{
  a, body, br, h1, h2, head, header, html, i, img, link, main, meta, p, span,
  title,
}
import lustre/attribute.{
  Attribute, alt, attribute, class, href, id, name, rel, src,
}
import blog/post.{Post}
import blog/route

// --- HOME PAGE GENERATION ---

/// Creates the home page displaying a header and the posts' previews.
///
pub fn home(posts: List(Post)) -> Element(a) {
  let main_content = main([], [post.to_previews(posts)])
  let description =
    "A personal blog where I share my thoughts as I jump from one obsession to the other"
  with_body(
    "Giacomo Cavalieri",
    route.base,
    description,
    [home_header(), main_content],
  )
}

/// Creates the 404 page.
/// 
pub fn not_found() -> Element(a) {
  with_body(
    "Not found",
    route.base <> "/404.html",
    "There's nothing here",
    [
      main(
        [],
        [
          h1([], [text("There's nothing here!")]),
          p([], [text("Go back to the "), a([href("/")], [text("home page")])]),
        ],
      ),
    ],
  )
}

const profile_picture_source = "https://www.gravatar.com/avatar/87534ab912fd65fd02da6b2e93f5d55b?s=440"

/// The homepage header with profile picture, title and short description.
///
fn home_header() -> Element(a) {
  header(
    [id("homepage-header"), class("h-card p-author")],
    [
      img([
        id("homepage-profile-picture"),
        class("u-photo"),
        alt(""),
        src(profile_picture_source),
      ]),
      h2([id("homepage-subtitle")], [text("Hello 👋")]),
      h1(
        [id("homepage-title")],
        [text("I'm "), span([class("p-given-name")], [text("Giacomo")])],
      ),
      p(
        [id("homepage-description"), class("p-note")],
        [
          i([], [text("He/Him")]),
          text(" • I love functional programming and learning new things"),
          br([]),
          text("Sharing my thoughts as I hop from one obsession to the other"),
          br([]),
          text("You can also find me on "),
          a(
            [
              href("https://github.com/giacomocavalieri"),
              rel("me"),
              class("u-url"),
            ],
            [text("GitHub")],
          ),
          text(" and "),
          a(
            [
              href("https://twitter.com/giacomo_cava"),
              rel("me"),
              class("u-url"),
            ],
            [text("Twitter")],
          ),
          text("!"),
        ],
      ),
    ],
  )
}

// --- POST PAGE GENERATION ---

/// Creates the page of a post.
///
pub fn from_post(post: Post) -> Element(Nil) {
  let url = "https://giacomocavalieri.me" <> post.to_route(post)
  with_body(post.title, url, post.abstract, [post.to_full(post)])
}

// --- HELPERS ---

/// Wraps a list of elements in an html page with a given title and default
/// head.
/// 
fn with_body(
  title: String,
  url: String,
  description: String,
  elements: List(Element(a)),
) -> Element(a) {
  html([lang("en")], [heading(title, url, description), body([], elements)])
}

/// The default head used by all the pages of the site, the only changing piece
/// is the title.
/// 
fn heading(page_title: String, url: String, description: String) -> Element(a) {
  head(
    [],
    [
      title([], page_title),
      charset("utf-8"),
      viewport([content("width=device-width, initial-scale=1.0")]),
      meta([property("og:site_name"), content("Giacomo Cavalieri's blog")]),
      meta([property("og:url"), content(url)]),
      meta([property("og:title"), content(page_title)]),
      meta([property("og:type"), content("website")]),
      meta([
        name("image"),
        property("og:image"),
        content(profile_picture_source),
      ]),
      meta([property("og:description"), content(description)]),
      meta([property("twitter:card"), content("summary")]),
      meta([property("twitter:title"), content(page_title)]),
      meta([property("twitter:description"), content(description)]),
      meta([property("twitter:creator"), content("@giacomo_cava")]),
      meta([property("twitter:image"), content(profile_picture_source)]),
      theme_color([content("#cceac3"), media("(prefers-color-scheme: light)")]),
      stylesheet("/style.css"),
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
