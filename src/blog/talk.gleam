import gleam/list
import gleam/option.{type Option}
import gleam/string
import gleam/time/calendar.{type Date, Date}
import lustre/attribute as attr
import lustre/element.{type Element}
import lustre/element/html

pub type Talk {
  Talk(title: String, place: String, youtube_link: Option(String), date: Date)
}

pub const talks = [
  Talk(
    title: "A Code Centric Journey Into the Gleam Language",
    place: "Func Prog Conf",
    youtube_link: option.Some(
      "https://youtu.be/LMrKEaAi4RI?si=zHCEcjWnh6TtDB_-",
    ),
    date: Date(day: 15, month: calendar.October, year: 2025),
  ),
  Talk(
    title: "You Don't Need an ORM",
    place: "Code BEAM Europe",
    youtube_link: option.None,
    date: Date(day: 4, month: calendar.November, year: 2025),
  ),
  Talk(
    title: "Snapshot Tests in Gleam: Smarter Testing, Less Work",
    place: "Squiggle Conf",
    youtube_link: option.None,
    date: Date(day: 17, month: calendar.September, year: 2025),
  ),
  Talk(
    title: "You Don't Need an ORM",
    place: "Lambda Days",
    youtube_link: option.Some(
      "https://youtu.be/XEJxk5VUSTs?si=dhQxiURSFbT39Gik",
    ),
    date: Date(day: 13, month: calendar.June, year: 2025),
  ),
  Talk(
    title: "What's new in Gleam 1.11",
    place: "Lambda Days",
    youtube_link: option.Some(
      "https://youtu.be/AKIZG0Dq3Bc?si=hlv9pCjhqA9CYh7l",
    ),
    date: Date(day: 13, month: calendar.June, year: 2025),
  ),
  Talk(
    title: "A Code Centric Journey Into the Gleam Language",
    place: "GOTO Copenhagen",
    youtube_link: option.Some(
      "https://youtu.be/yHe_wzFg4W8?si=wr8z8emwd33YrdNl",
    ),
    date: Date(day: 4, month: calendar.October, year: 2024),
  ),
  Talk(
    title: "Supercharge Your Tests With Snapshot Testing",
    place: "Lambda Days",
    youtube_link: option.Some(
      "https://youtu.be/s1pZN1kSiLA?si=E0UcooEkw44fzqai",
    ),
    date: Date(day: 12, month: calendar.June, year: 2024),
  ),
  Talk(
    title: "Supercharge Your Tests With Snapshot Testing",
    place: "Code BEAM Europe",
    youtube_link: option.Some(
      "https://youtu.be/DpakV96jeRk?si=ODqE_geVaMIR0Qoa",
    ),
    date: Date(day: 4, month: calendar.November, year: 2024),
  ),
  Talk(
    title: "A Code Centric Journey Into the Gleam Language",
    place: "YOW!",
    youtube_link: option.Some(
      "https://youtu.be/PfPIiHCId0s?si=qITD81lVVJiKSuW0",
    ),
    date: Date(day: 6, month: calendar.December, year: 2024),
  ),
]

pub fn to_preview_list(talks: List(Talk)) -> Element(a) {
  html.ol(
    [attr.class("stack-s")],
    list.sort(talks, fn(one, other) {
      calendar.naive_date_compare(one.date, other.date)
    })
      |> list.reverse
      |> list.map(to_preview),
  )
}

fn to_preview(talk: Talk) -> Element(a) {
  let text = html.text(talk.title)
  let text = case talk.youtube_link {
    option.Some(link) -> html.a([attr.href(link)], [text])
    option.None -> html.span([], [text])
  }

  html.li([], [
    html.article([attr.class("preview sidebar")], [
      html.div([attr.class("info")], [
        html.time([], [html.text(month(talk.date))]),
        html.span([], [html.text(" - " <> talk.place)]),
      ]),
      text,
    ]),
  ])
}

fn month(date: Date) -> String {
  let Date(year: _, month:, day: _) = date

  calendar.month_to_string(month)
  |> string.slice(at_index: 0, length: 3)
  |> string.capitalise
}
