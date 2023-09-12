import lustre/element.{Element, text}
import lustre/element/html.{
  a, body, br, div, h1, h2, head, header, html, i, img, li, link, main, meta, p,
  span, title, ul,
}
import lustre/attribute.{alt, attribute, class, href, id, name, rel, src}

pub fn home() -> Element(a) {
  html(
    [attribute("lang", "en")],
    [
      head(
        [],
        [
          title([], "Giacomo Cavalieri"),
          meta([
            name("theme-color"),
            attribute("content", "#cceac3"),
            attribute("media", "(prefers-color-scheme: light)"),
          ]),
          meta([attribute("charset", "utf-8")]),
          meta([
            name("viewport"),
            attribute("content", "width=device-width, initial-scale=1.0"),
          ]),
          link([rel("stylesheet"), href("/styles/common.css")]),
          link([rel("stylesheet"), href("/styles/homepage-header.css")]),
          link([rel("stylesheet"), href("/styles/post.css")]),
        ],
      ),
      body([], [home_header(), main([], [posts()])]),
    ],
  )
}

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

fn posts() -> Element(a) {
  ul([id("posts")], [post()])
}

fn post() -> Element(a) {
  li(
    [class("post")],
    [
      a([href("#")], [h2([], [text("Look! I made this with Lustre ✨")])]),
      div(
        [class("subtitle")],
        [
          span([class("date")], [text("12 september 2023")]),
          ul(
            [class("tags")],
            [
              li([class("tag")], [text("Gleam")]),
              li([class("tag")], [text("Lustre")]),
            ],
          ),
        ],
      ),
      p(
        [class("description")],
        [
          text("This is just an example post, "),
          text("things are still very much a work in progress."),
          br([]),
          text("In the meantime do check out "),
          a([href("https://pkg.hayleigh.dev/lustre/")], [text("Lustre")]),
          text(", it's really cool!"),
        ],
      ),
    ],
  )
}
