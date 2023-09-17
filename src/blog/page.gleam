import lustre/element.{Element, text}
import lustre/element/html.{
  a, body, br, h1, h2, head, header, html, i, img, link, main, meta, p, title,
}
import lustre/attribute.{Attribute, alt, attribute, href, id, name, rel, src}
import blog/post.{Post}

// --- HOME PAGE GENERATION ---

/// Creates the home page displaying a header and the posts' previews.
///
pub fn home(posts: List(Post(List(Element(a))))) -> Element(a) {
  let main_content = main([], [post.to_previews(posts)])
  with_body("Giacomo", [home_header(), main_content])
}

/// The homepage header with profile picture, title and short description.
///
fn home_header() -> Element(a) {
  let profile_picture_source =
    "https://www.gravatar.com/avatar/87534ab912fd65fd02da6b2e93f5d55b?s=440"

  header(
    [id("homepage-header")],
    [
      img([id("homepage-profile-picture"), alt(""), src(profile_picture_source)]),
      h2([id("homepage-subtitle")], [text("Hello 👋")]),
      h1([id("homepage-title")], [text("I'm Giacomo")]),
      p(
        [id("homepage-description")],
        [
          i([], [text("He/Him")]),
          text(" • I love functional programming and learning new things"),
          br([]),
          text("Sharing my thoughts as I hop from one obsession to the other"),
          br([]),
          text("You can also find me on "),
          a([href("https://github.com/giacomocavalieri")], [text("GitHub")]),
          text(" and "),
          a([href("https://twitter.com/giacomo_cava")], [text("Twitter")]),
          text("!"),
        ],
      ),
    ],
  )
}

// --- POST PAGE GENERATION ---

/// Creates the page of a post.
///
pub fn from_post(post: Post(List(Element(a)))) -> Element(a) {
  with_body(post.title, [post.to_full(post)])
}

// --- HELPERS ---

/// Wraps a list of elements in an html page with a given title and default
/// head.
/// 
fn with_body(title: String, elements: List(Element(a))) -> Element(a) {
  html([lang("en")], [heading(title), body([], elements)])
}

/// The default head used by all the pages of the site, the only changing piece
/// is the title.
/// 
fn heading(page_title: String) -> Element(a) {
  head(
    [],
    [
      title([], page_title),
      charset("utf-8"),
      viewport([content("width=device-width, initial-scale=1.0")]),
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
