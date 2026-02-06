import gleam/bool
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre
import lustre/attribute.{attribute}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/svg
import lustre/event

pub fn main() {
  let app = lustre.application(init:, update:, view:)
  let assert Ok(_) = lustre.start(app, onto: "#curve", with: Nil)
  Nil
}

type Model {
  Model(
    current_value: Float,
    delta: Float,
    snap_every: Int,
    since_last_snap: Int,
    snaps: List(Float),
    direction: Direction,
    status: Status,
    restart_timer: Option(Timer),
  )
}

type Timer

type Status {
  Paused
  Playing
}

type Message {
  TimerTicked
  UserMovedSlider(value: String)
  RestartTimerStarted(timer: Timer)
  UserReleasedSlider
  RestartTimerEnded
}

type Direction {
  Increasing
  Decreasing
}

fn init(_: Nil) -> #(Model, Effect(Message)) {
  let model =
    Model(
      current_value: 0.0,
      delta: 0.01,
      snap_every: 3,
      since_last_snap: 0,
      snaps: [],
      direction: Increasing,
      status: Playing,
      restart_timer: None,
    )

  #(model, start_timer())
}

fn start_timer() -> Effect(Message) {
  use dispatch <- effect.from
  after(ms: 30, do: fn() { dispatch(TimerTicked) })
  Nil
}

fn start_restart_timer() -> Effect(Message) {
  use dispatch <- effect.from
  let timer = after(ms: 1000, do: fn() { dispatch(RestartTimerEnded) })
  dispatch(RestartTimerStarted(timer))
  Nil
}

fn stop_restart_timer(timer: Option(Timer)) -> Effect(Message) {
  case timer {
    None -> effect.none()
    Some(timer) -> {
      use _dispatch <- effect.from
      stop_timer(timer)
    }
  }
}

@external(javascript, "./interactive_ffi.mjs", "after")
fn after(ms _ms: Int, do _fun: fn() -> Nil) -> Timer {
  panic as "not supported on the Erlang target"
}

@external(javascript, "./interactive_ffi.mjs", "stop_timer")
fn stop_timer(_timer: Timer) -> Nil {
  Nil
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  let Model(current_value:, delta:, status:, direction:, restart_timer:, ..) =
    model

  case message {
    TimerTicked -> {
      use <- bool.guard(when: status == Paused, return: #(model, effect.none()))
      let new_value = case direction {
        Increasing -> float.clamp(current_value +. delta, min: 0.0, max: 1.0)
        Decreasing -> float.clamp(current_value -. delta, min: 0.0, max: 1.0)
      }
      let direction = case new_value <=. 0.0 {
        True -> Increasing
        False ->
          case new_value >=. 1.0 {
            True -> Decreasing
            False -> direction
          }
      }
      let model =
        Model(..model, direction:, current_value: new_value)
        |> update_snaps(current_value)
      #(model, start_timer())
    }

    UserMovedSlider(value) ->
      case float.parse(value) {
        Error(_) -> #(model, effect.none())
        Ok(value) -> {
          let direction = case value >=. current_value {
            True -> Increasing
            False -> Decreasing
          }

          let model =
            Model(
              ..model,
              status: Paused,
              current_value: value,
              restart_timer: None,
              direction:,
            )
            |> update_snaps(current_value)

          #(model, stop_restart_timer(restart_timer))
        }
      }

    UserReleasedSlider -> #(model, start_restart_timer())

    RestartTimerStarted(timer:) -> {
      #(Model(..model, restart_timer: Some(timer)), effect.none())
    }

    RestartTimerEnded -> {
      #(Model(..model, restart_timer: None, status: Playing), start_timer())
    }
  }
}

fn update_snaps(model: Model, new_value: Float) {
  let Model(snap_every:, since_last_snap:, snaps:, ..) = model
  let #(snaps, since_last_snap) = case since_last_snap >= snap_every {
    False -> #(snaps, since_last_snap + 1)
    True ->
      case snaps {
        [_, b, c, d, e] -> #([b, c, d, e, new_value], 0)
        [a, b, c, d] -> #([a, b, c, d, new_value], 0)
        [a, b, c] -> #([a, b, c, new_value], 0)
        [a, b] -> #([a, b, new_value], 0)
        [a] -> #([a, new_value], 0)
        [] -> #([new_value], 0)
        _ -> panic
      }
  }
  Model(..model, snaps:, since_last_snap:)
}

fn view(model: Model) -> Element(Message) {
  let Model(current_value:, snaps:, ..) = model
  let interpolated = cubic_in_out(current_value)
  let graph =
    svg.svg(
      [
        attribute.style("width", "50%"),
        attribute.style("aspect-ratio", "1 / 1"),
        attribute.style("padding", "var(--s0)"),
        attribute("viewBox", "0 0 1 1"),
      ],
      [
        svg.line([
          attribute("x1", "0"),
          attribute("y1", "1"),
          attribute("x2", "0.98"),
          attribute("y2", "1"),
          attribute("stroke", "var(--color)"),
          attribute("stroke-width", "0.005"),
        ]),
        svg.line([
          attribute("x1", "0"),
          attribute("y1", "0.02"),
          attribute("x2", "0"),
          attribute("y2", "1"),
          attribute("stroke", "var(--color)"),
          attribute("stroke-width", "0.005"),
        ]),
        svg.line([
          attribute("x1", "0"),
          attribute("y1", "1"),
          attribute("x2", "0.98"),
          attribute("y2", "0.02"),
          attribute.style("opacity", "0.3"),
          attribute("stroke", "var(--color)"),
          attribute.style("stroke-dasharray", "0.015"),
          attribute("stroke-width", "0.005"),
        ]),
        svg.text(
          [
            attribute("x", "1"),
            attribute("y", "1.01"),
            attribute("font-size", "0.06"),
            attribute("fill", "var(--color)"),
          ],
          "t",
        ),
        svg.text(
          [
            attribute("x", "-0.015"),
            attribute("y", "0"),
            attribute("font-size", "0.06"),
            attribute("fill", "var(--color)"),
          ],
          "x",
        ),
        ..{
          use point, i <- list.index_map(snaps)
          let opacity = { 1.0 -. 1.0 /. int.to_float(i + 1) } *. 0.5
          svg.circle([
            attribute("fill", "var(--main-color)"),
            attribute("r", "0.02"),
            attribute.style("opacity", float.to_string(opacity)),
            attribute("cx", float.to_string(point)),
            attribute("cy", float.to_string(1.0 -. cubic_in_out(point))),
          ])
        }
        |> list.append([
          svg.circle([
            attribute("fill", "var(--color)"),
            attribute("r", "0.03"),
            attribute("cx", float.to_string(current_value)),
            attribute("cy", float.to_string(1.0 -. interpolated)),
          ]),
        ])
      ],
    )

  let code =
    html.code([attribute("data-highlighted", "yes")], [
      html.span([attribute.class("hljs-keyword")], [html.text("let")]),
      html.text(" x "),
      html.span([attribute.class("hljs-operator")], [html.text("=")]),
      html.text(" "),
      html.text("\n  tween_cubic_in_out(\n    t: "),
      html.span([attribute.class("hljs-number")], [
        float.to_string(float.to_precision(current_value, 2))
        |> string.pad_end(to: 4, with: "0")
        |> html.text,
      ]),
      html.text(",\n    between: "),
      html.span([attribute.class("hljs-number")], [html.text("0.0")]),
      html.text(",\n    and: "),
      html.span([attribute.class("hljs-number")], [html.text("1.0")]),
      html.text("\n  )\n\n"),
      html.span([attribute.class("hljs-keyword")], [html.text("assert")]),
      html.text(" x "),
      html.span([attribute.class("hljs-operator")], [html.text("==")]),
      html.text(" "),
      html.span([attribute.class("hljs-number")], [
        float.to_string(float.to_precision(interpolated, 2))
        |> string.pad_end(to: 4, with: "0")
        |> html.text,
      ]),
    ])

  let slider =
    html.input([
      attribute.type_("range"),
      attribute.min("0.0"),
      attribute.max("1.0"),
      attribute.step("0.01"),
      attribute.value(float.to_string(current_value)),
      event.on("pointerup", decode.success(UserReleasedSlider)),
      event.on_input(UserMovedSlider)
        |> event.throttle(10),
    ])

  html.div([attribute.class("switcher")], [
    html.div([attribute.class("stack")], [
      slider,
      code,
    ]),
    graph,
  ])
}

fn cubic_in_out(x: Float) -> Float {
  case x <=. 0.5 {
    True -> 4.0 *. x *. x *. x
    False -> {
      let x = -2.0 *. x +. 2.0
      1.0 -. x *. x *. x /. 2.0
    }
  }
}
