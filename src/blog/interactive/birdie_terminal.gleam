import gleam/int
import gleam/list
import gleam/string
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

type Model {
  Model(
    state: State,
    command: String,
    ran_commands: List(#(Command, Element(Message))),
    tests_timing: Int,
  )
}

type State {
  WaitingForTest
  WaitingForReview
  Reviewing
  Accepted
  Done
}

type Message {
  UserTypedCommand(command: String)
  UserPressedKey(String)
  GleamFinishedRunning(tests_timing: Int)
}

type Command {
  GleamTest
  BirdieReview
  Accept
  Reject
  Unknown(value: String)
}

pub fn main() {
  let app = lustre.application(init:, update:, view:)
  let assert Ok(_) =
    lustre.start(app, onto: "#terminal", with: int.random(6) + 1)
  Nil
}

fn init(tests_timing: Int) -> #(Model, Effect(Message)) {
  #(
    Model(state: WaitingForTest, command: "", ran_commands: [], tests_timing:),
    effect.none(),
  )
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    UserTypedCommand(command) -> #(
      Model(..model, command: string.lowercase(command)),
      effect.none(),
    )
    UserPressedKey("Enter") -> {
      let command = parse_command(model.command)
      let #(state, result) = run_command(model, command)
      let ran_commands = [#(command, result), ..model.ran_commands]
      let model = Model(..model, command: "", state:, ran_commands:)
      let effect = case command {
        GleamTest -> new_random_timing()
        _ -> effect.none()
      }
      #(
        model,
        effect.batch([
          scroll_to("terminal-prompt-field"),
          focus_no_scroll("terminal-prompt-field"),
          effect,
        ]),
      )
    }
    UserPressedKey(_) -> #(model, effect.none())
    GleamFinishedRunning(tests_timing:) -> {
      #(Model(..model, tests_timing:), effect.none())
    }
  }
}

fn new_random_timing() -> Effect(Message) {
  use dispatch <- effect.from
  dispatch(GleamFinishedRunning(1 + int.random(6)))
}

fn scroll_to(id: String) -> Effect(Message) {
  use _dispatch, _ <- effect.after_paint
  do_scroll_to(id)
}

fn focus_no_scroll(id: String) -> Effect(Message) {
  use _dispatch, _ <- effect.after_paint
  do_focus_no_scroll(id)
}

@external(javascript, "./interactive_ffi.mjs", "do_focus_no_scroll")
fn do_focus_no_scroll(_id: String) -> Nil {
  Nil
}

@external(javascript, "./interactive_ffi.mjs", "do_scroll_to")
fn do_scroll_to(_id: String) -> Nil {
  Nil
}

fn run_command(model: Model, command: Command) -> #(State, Element(Message)) {
  let Model(state:, ..) = model
  case state, command {
    WaitingForTest, GleamTest | WaitingForReview, GleamTest -> #(
      WaitingForReview,
      element.unsafe_raw_html(
        "",
        "code",
        [],
        "<span class='hljs-shell-error'>panic</span> test/example_test.gleam:9
 <span class='hljs-shell-info'>test</span>: example_test.usage_text_test
 <span class='hljs-shell-info'>info</span>: Birdie snapshot test failed

── new snapshot ────────────────────────────────────────────
  <span class='hljs-shell-info'>title</span>: testing the help text
  <span class='hljs-shell-info'>hint</span>: <span class='hljs-shell-warning'>run `gleam run -m birdie` to review the snapshots</span>
────────┬───────────────────────────────────────────────────
      <span class='hljs-shell-new'>1 + usage: lucysay [-m message] [-f file]
      2 +
      3 +  -m, --message  the message to be printed
      4 +  -f, --file     a file to read the message from
      5 +  -h, --help     show this help text</span>
────────┴───────────────────────────────────────────────────

Finished in 0.00" <> int.to_string(model.tests_timing) <> " seconds
<span class='hljs-shell-error'>1 tests, 1 failures</span>",
      ),
    )

    WaitingForReview, BirdieReview -> #(
      Reviewing,
      element.unsafe_raw_html(
        "",
        "code",
        [],
        "Reviewing <span class='hljs-shell-warning'>1st</span> out of <span class='hljs-shell-warning'>1</span>

── new snapshot ────────────────────────────────────────────
  <span class='hljs-shell-info'>title</span>: testing the help text
  <span class='hljs-shell-info'>file</span>: ./test/cli.gleam
────────┬───────────────────────────────────────────────────
      <span class='hljs-shell-new'>1 + usage: lucysay [-m message] [-f file]
      2 +
      3 +  -m, --message  the message to be printed
      4 +  -f, --file     a file to read the message from
      5 +  -h, --help     show this help text</span>
────────┴───────────────────────────────────────────────────

  <span class='hljs-shell-new'>a</span> accept     accept the new snapshot
  <span class='hljs-shell-error'>r</span> reject     reject the new snapshot",
      ),
    )

    Reviewing, Accept -> #(
      Accepted,
      html.div([], [
        html.text("🐦‍⬛ "),
        html.span([attribute.class("hljs-shell-new")], [
          html.text("Accepted one snapshot"),
        ]),
      ]),
    )

    Reviewing, Reject -> #(
      WaitingForTest,
      html.div([], [
        html.text("🐦‍⬛ "),
        html.span([attribute.class("hljs-shell-error")], [
          html.text("Rejected one snapshot"),
        ]),
      ]),
    )

    Reviewing, GleamTest | Reviewing, BirdieReview | Reviewing, Unknown(_) -> #(
      Reviewing,
      html.div([], [html.text("the options are [a]ccept or [r]eject")]),
    )

    Accepted, GleamTest -> #(
      Done,
      html.code([], [
        html.span([attribute.class("hljs-shell-new")], [
          html.text(".\n1 passed, no failures"),
        ]),
      ]),
    )

    WaitingForTest, BirdieReview | Accepted, BirdieReview -> #(
      state,
      html.code([], [
        html.text("🐦‍⬛ No new snapshots to review\n"),
        html.span([attribute.class("hljs-shell-info")], [html.text("Hint")]),
        html.text(": "),
        html.span([attribute.class("hljs-shell-warning")], [
          html.text("did you forget to run `gleam test`?"),
        ]),
      ]),
    )

    WaitingForReview, Accept
    | WaitingForReview, Reject
    | WaitingForReview, Unknown(_)
    | WaitingForTest, Accept
    | WaitingForTest, Reject
    | WaitingForTest, Unknown(_)
    | Accepted, Accept
    | Accepted, Reject
    | Accepted, Unknown(_)
    -> #(
      state,
      html.div([], [
        html.text("unknown command: " <> command_to_string(command)),
      ]),
    )

    Done, _ -> #(Done, element.none())
  }
}

fn command_to_string(command: Command) -> String {
  case command {
    GleamTest -> "gleam test"
    BirdieReview -> "gleam run -m birdie"
    Accept -> "a"
    Reject -> "r"
    Unknown(value) -> value
  }
}

fn parse_command(command: String) -> Command {
  case string.trim(command) {
    "gleam test" -> GleamTest
    "gleam run -m birdie" -> BirdieReview
    "a" -> Accept
    "r" -> Reject
    command -> Unknown(command)
  }
}

fn view(model: Model) -> Element(Message) {
  let children = {
    use #(command, outcome) <- list.map(list.reverse(model.ran_commands))
    html.div([attribute.class("stack-xs")], [
      html.div([attribute.class("with-icon")], [
        html.span([attribute.class("icon hljs-comment")], [html.text(">")]),
        html.span([attribute.class("hljs-comment")], [
          html.text(command_to_string(command)),
        ]),
      ]),
      outcome,
    ])
  }

  element.fragment([
    html.pre(
      [attribute.class("stack-s")],
      list.append(children, [
        html.div([attribute.class("with-icon")], [
          html.span(
            [
              attribute.class("icon"),
              case model.state {
                WaitingForTest | WaitingForReview | Reviewing | Accepted ->
                  attribute.none()
                Done -> attribute.class("hljs-comment")
              },
            ],
            [html.text(">")],
          ),
          html.input([
            attribute.disabled(model.state == Done),
            attribute.type_("text"),
            attribute.spellcheck(False),
            attribute.autocapitalize("off"),
            attribute.autocomplete("off"),
            attribute.value(model.command),
            attribute.placeholder(next_step_hint(model.state)),
            attribute.id("terminal-prompt-field"),
            event.on_keyup(UserPressedKey),
            event.on_input(UserTypedCommand),
          ]),
        ]),
      ]),
    ),
    html.style(
      [],
      "#terminal-prompt-field {
        background-color: transparent;
        font-size: inherit;
        width: 100%;
      }

      #terminal-prompt-field:focus {
        outline: none;
      }
    ",
    ),
  ])
}

fn next_step_hint(state: State) -> String {
  case state {
    WaitingForTest -> "try running `gleam test`..."
    WaitingForReview -> "try running `gleam run -m birdie`"
    Reviewing -> "try accepting the snapshot with `a`"
    Accepted -> "try running `gleam test` again now..."
    Done -> "the demo is over!"
  }
}
