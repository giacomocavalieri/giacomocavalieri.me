import blog/breadcrumbs
import blog/icon
import blog/interactive/carrier_pigeon
import blog/post.{type Post}
import blog/talk.{type Talk}
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import jot_extra
import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html

// --- HOME PAGE ---------------------------------------------------------------

const description = "Italy-based developer, Gleam core team member, and functional programming enthusiast"

pub fn home() -> Element(a) {
  let title = "Giacomo Cavalieri"
  page(title, description, None, [attribute.class("stack-l jak-cover")], [
    html.h1([], [html.text("Giacomo Cavalieri")]),
    html.main([attribute.class("stack-s")], [
      html.p([], [html.text("Italy-based developer")]),
      html.p([], [
        html.a([attribute.href("https://gleam.run")], [html.text("Gleam")]),
        html.text(" core team member"),
      ]),
      html.p([], [
        html.text("Appreciate my work? Support me on "),
        html.a(
          [attribute.href("https://github.com/sponsors/giacomocavalieri")],
          [
            html.text("GitHub Sponsors"),
          ],
        ),
      ]),
    ]),
    navbar(
      html.li([], [
        html.a([attribute.href("contact.html")], [html.text("contact")]),
      ]),
    ),
  ])
}

pub fn contact() -> Element(a) {
  let title = "Contact | Giacomo Cavalieri"
  page(title, description, None, [attribute.class("stack-l jak-cover")], [
    html.h1([], [html.text("Giacomo Cavalieri")]),
    html.address([attribute.class("stack-s")], [
      html.p([], [
        html.text("For any inquiry "),
        html.a(
          [
            attribute.href("mailto:info@giacomocavalieri.me"),
            attribute.rel("me"),
          ],
          [
            html.text("info@giacomocavalieri.me"),
          ],
        ),
      ]),
      html.p([], [
        html.text("My open source work is on GitHub "),
        html.a(
          [
            attribute.href("https://github.com/giacomocavalieri"),
            attribute.rel("me"),
          ],
          [html.text("@giacomocavalieri")],
        ),
      ]),
      html.p([], [
        html.text("Connect with me on my "),
        html.a([attribute.href("/socials.html"), animate("socials")], [
          html.text("socials"),
        ]),
      ]),
    ]),
    navbar(
      html.li([], [
        html.a([attribute.href("index.html")], [html.text("home")]),
      ]),
    ),
  ])
}

fn navbar(last_item: Element(a)) -> Element(a) {
  html.nav([], [
    html.ul([attribute.class("nav-switcher")], [
      html.li([], [
        html.a([attribute.href("writing.html"), animate("writing")], [
          html.text("writing"),
        ]),
      ]),
      html.li([], [
        html.a([attribute.href("speaking.html"), animate("speaking")], [
          html.text("speaking"),
        ]),
      ]),
      last_item,
    ]),
  ])
}

fn animate(name: String) -> Attribute(a) {
  attribute.style("view-transition-name", name <> "-animation")
}

// --- 404 PAGE ---------------------------------------------------------------

pub fn not_found() -> Element(a) {
  let title = "Not found"
  let description = "There's nothing here"
  page(title, description, None, [attribute.class("stack-l")], [
    html.h1([], [html.text("There's nothing here!")]),
    html.p([], [
      html.text("Go back "),
      html.a([attribute.href("index.html")], [html.text("home")]),
    ]),
  ])
}

// --- POST PAGE ---------------------------------------------------------------

pub fn writing(posts: List(Post)) -> Element(a) {
  let posts_by_year =
    list.group(posts, fn(post) { post.meta.date.year })
    |> dict.to_list
    |> list.sort(fn(one, other) { int.compare(other.0, one.0) })

  let title = "Writing | Giacomo Cavalieri"
  page(title, description, None, [attribute.class("stack-l")], [
    breadcrumbs.new([
      breadcrumbs.link("home", to: "/"),
      breadcrumbs.animated_link("writing", to: "/writing.html"),
    ]),
    html.main([], [
      html.ol([attribute.class("stack")], {
        use #(year, posts) <- list.map(posts_by_year)
        html.li([attribute.class("stack-s")], [
          html.h2([], [html.text(int.to_string(year))]),
          post.to_preview_list(posts),
        ])
      }),
    ]),
  ])
}

pub fn speaking(talks: List(Talk)) -> Element(a) {
  let talks_by_year =
    list.group(talks, fn(talk) { talk.date.year })
    |> dict.to_list
    |> list.sort(fn(one, other) { int.compare(other.0, one.0) })

  let title = "Speaking | Giacomo Cavalieri"
  page(title, description, None, [attribute.class("stack-l")], [
    breadcrumbs.new([
      breadcrumbs.link("home", to: "/"),
      breadcrumbs.animated_link("speaking", to: "/speaking.html"),
    ]),
    html.main([], [
      html.ol([attribute.class("stack")], {
        use #(year, talks) <- list.map(talks_by_year)
        html.li([attribute.class("stack-s")], [
          html.h2([], [html.text(int.to_string(year))]),
          talk.to_preview_list(talks),
        ])
      }),
    ]),
  ])
}

pub fn carrier_pigeon() -> Element(_) {
  let title = "Carrier pigeon | Giacomo Cavalieri"
  let description =
    "Send me any message, it will be printed anonymously by a thermal printer sitting on my desk."
  page(title, description, Some("pigeon.png"), [attribute.class("stack-l")], [
    breadcrumbs.new([
      breadcrumbs.link("contact", to: "/contact"),
      breadcrumbs.animated_link("socials", to: "/socials"),
      breadcrumbs.animated_link("carrier pigeon", to: "/carrier-pigeon"),
    ]),
    html.main([attribute.id("carrier-pigeon")], [
      // We server side render the main content to make sure we don't get a
      // white flash before Lustre can take control of this element.
      carrier_pigeon.view(carrier_pigeon.init(Nil).0),
    ]),
    html.script(
      [attribute.src("/js/carrier_pigeon.js"), attribute.type_("module")],
      "",
    ),
  ])
}

pub fn from_post(post: Post) -> Element(a) {
  page(
    post.meta.title,
    jot_extra.to_string(post.meta.abstract),
    post.meta.preview_image,
    [attribute.class("stack-l")],
    post.to_article(post),
  )
}

pub fn socials() -> Element(a) {
  let title = "Socials | Giacomo Cavalieri"
  let description =
    "Let's connect on social media! Here's all the places where you can find me."

  page(title, description, None, [attribute.class("stack-l")], [
    breadcrumbs.new([
      breadcrumbs.link("contact", to: "/contact.html"),
      breadcrumbs.animated_link("socials", to: "/socials.html"),
    ]),
    html.main([attribute.class("stack")], [
      html.p([], [html.text(description)]),
      html.ul([attribute.class("stack-s")], [
        social_to_li(
          icon.github(),
          "https://github.com/sponsors/giacomocavalieri",
          "GitHub",
        ),
        social_to_li(icon.discord(), "https://discord.gg/wgm8ssRU5c", "Discord"),
        social_to_li(
          icon.bluesky(),
          "https://bsky.app/profile/giacomocavalieri.me",
          "Bluesky",
        ),
        social_to_li(
          icon.tiktok(),
          "https://www.tiktok.com/@giacomocavalieri.me",
          "TikTok",
        ),
        social_to_li(
          icon.twitch(),
          "https://www.twitch.tv/giacomo_cavalieri",
          "Twitch",
        ),
        social_to_li(
          icon.youtube(),
          "https://www.youtube.com/@giacomo_cavalieri",
          "YouTube",
        ),
        social_to_li(
          icon.linkedin(),
          "https://www.linkedin.com/in/giacomo-cavalieri",
          "LinkedIn",
        ),
        html.li([attribute.class("with-icon")], [
          icon.twitter(),
          html.a(
            [attribute.href("/carrier-pigeon"), animate("carrier pigeon")],
            [
              html.text("Carrier pigeon"),
            ],
          ),
        ]),
      ]),
    ]),
  ])
}

fn social_to_li(
  icon: Element(msg),
  url url: String,
  social name: String,
) -> Element(msg) {
  html.li([attribute.class("with-icon")], [
    icon,
    html.a([attribute.href(url), attribute.rel("me")], [html.text(name)]),
  ])
}

// --- HELPERS -----------------------------------------------------------------

fn page(
  title: String,
  description: String,
  preview_image: Option(String),
  attributes: List(Attribute(a)),
  elements: List(Element(a)),
) -> Element(a) {
  html.html([lang("en")], [
    default_head(title, description, preview_image),
    html.body(attributes, elements),
  ])
}

const hljs_script_url = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"

const hljs_diff_url = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/languages/diff.min.js"

const gleam_hljs_script_url = "/highlightjs-gleam.js"

fn default_head(
  page_title: String,
  description: String,
  preview_image: Option(String),
) -> Element(a) {
  html.head([], [
    html.title([], page_title),
    charset("utf-8"),
    viewport([
      content("width=device-width, initial-scale=1.0, viewport-fit=cover"),
    ]),
    html.script(
      [
        attribute.src("//gc.zgo.at/count.js"),
        attribute("async", ""),
        attribute(
          "data-goatcounter",
          "https://giacomocavalieri.goatcounter.com/count",
        ),
      ],
      "",
    ),
    html.link([
      attribute.rel("alternate"),
      attribute.type_("application/rss+xml"),
      attribute.title("giacomocavalieri.me posts feed"),
      attribute.href("https://giacomocavalieri.me/feed.xml"),
    ]),
    html.link([
      attribute.rel("icon"),
      attribute.type_("image/x-icon"),
      attribute.href("favicon.ico"),
    ]),
    html.meta([property("og:site_name"), content("Giacomo Cavalieri")]),
    html.meta([property("og:title"), content(page_title)]),
    html.meta([property("og:type"), content("website")]),
    html.meta([
      property("og:image"),
      content(case preview_image {
        None -> "https://giacomocavalieri.me/imgs/og-preview-image.jpg"
        Some(image) -> "https://giacomocavalieri.me/imgs/" <> image
      }),
    ]),
    html.meta([property("og:description"), content(description)]),
    html.meta([attribute.name("description"), content(description)]),
    stylesheet("/style-7.css"),
    html.script([attribute.src(hljs_script_url)], ""),
    html.script([attribute.src(hljs_diff_url)], ""),
    html.script([attribute.src(gleam_hljs_script_url)], ""),
    html.script([], "hljs.highlightAll();"),
  ])
}

// --- META BUILDERS -----------------------------------------------------------

fn meta_named(meta_name: String, attributes: List(Attribute(a))) -> Element(a) {
  html.meta([attribute.name(meta_name), ..attributes])
}

fn viewport(attributes: List(Attribute(a))) -> Element(a) {
  meta_named("viewport", attributes)
}

fn stylesheet(file: String) -> Element(a) {
  html.link([attribute.rel("stylesheet"), attribute.href(file)])
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
