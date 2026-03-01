import gleam/http
import gleam/http/request
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import rsvp

pub fn main() {
  let app = lustre.application(init:, update:, view:)
  let assert Ok(_) = lustre.start(app, onto: "#carrier-pigeon", with: Nil)
  Nil
}

pub type Model {
  Model(
    message: String,
    sending_message: Bool,
    previous_outcome: Option(Outcome),
  )
}

pub fn init(_: Nil) -> #(Model, Effect(Message)) {
  let model = Model(message: "", sending_message: False, previous_outcome: None)
  #(model, effect.none())
}

pub type Message {
  UserTypedMessage(message: String)
  UserSubmittedMessage
  ApiReplied(Outcome)
}

pub type Outcome {
  Success
  MessageTooHeavy
  Unreachable
  UnknownCode(code: Int)
  RsvpErrored(error: rsvp.Error)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    UserTypedMessage(message:) -> #(Model(..model, message:), effect.none())
    UserSubmittedMessage -> {
      let model = Model(..model, sending_message: True, previous_outcome: None)
      #(model, send_message(model.message))
    }

    ApiReplied(outcome) -> {
      let message = case outcome {
        MessageTooHeavy | Unreachable | UnknownCode(..) | RsvpErrored(..) ->
          model.message
        Success -> ""
      }
      let model =
        Model(message:, sending_message: False, previous_outcome: Some(outcome))
      #(model, effect.none())
    }
  }
}

fn send_message(message: String) -> Effect(Message) {
  let request =
    request.new()
    |> request.set_scheme(http.Https)
    |> request.set_method(http.Post)
    |> request.set_host("pigeon.giacomocavalieri.me")
    |> request.set_body(message)

  rsvp.send(request, {
    use outcome <- rsvp.expect_any_response
    case outcome {
      Error(error) -> ApiReplied(RsvpErrored(error:))
      Ok(response) ->
        case response.status {
          200 -> ApiReplied(Success)
          413 -> ApiReplied(MessageTooHeavy)
          502 -> ApiReplied(Unreachable)
          status_code -> ApiReplied(UnknownCode(status_code))
        }
    }
  })
}

pub fn view(model: Model) -> Element(Message) {
  let message_is_empty = string.trim(model.message) == ""

  html.div([attribute.class("stack")], [
    html.p([], [
      html.text(
        "Anything that you submit with this form will be printed anonymously by
        a thermal printer sitting on my desk!
        I affectionately call her my carrier pigeon.",
      ),
    ]),
    message_form(model, message_is_empty),
    outcome(model.previous_outcome),
  ])
}

fn message_form(model: Model, message_is_empty: Bool) -> Element(Message) {
  html.form(
    [
      attribute.class("stack-s"),
      event.on_submit(fn(_) { UserSubmittedMessage })
        |> event.prevent_default,
    ],
    [
      html.input([
        attribute.name("message"),
        attribute.value(model.message),
        attribute.autofocus(True),
        attribute.placeholder("Type your message in here..."),
        attribute.disabled(model.sending_message),
        event.on_input(UserTypedMessage)
          |> event.debounce(50),
      ]),
      html.button(
        [attribute.disabled(message_is_empty || model.sending_message)],
        [
          case model.sending_message {
            True -> html.text("The message is on its way...")
            False -> html.text("Send!")
          },
        ],
      ),
    ],
  )
}

fn outcome(previous_outcome: Option(Outcome)) -> Element(Message) {
  case previous_outcome {
    None -> element.none()
    Some(outcome) -> {
      let #(img, text) = case outcome {
        Success -> #(
          "imgs/pigeon-done.png",
          html.p([], [
            html.text(
              "Thank you!! The message has been delivered and printed,
              I'll read it once I'm at my desk. Pigeons are way cooler than we
              give them credit for, check some ",
            ),
            html.a(
              [attribute.href("https://en.wikipedia.org/wiki/Homing_pigeon")],
              [html.text("homing pigeon facts.")],
            ),
          ]),
        )
        MessageTooHeavy -> #(
          "imgs/pigeon-too-big.png",
          html.p([], [
            html.text(
              "I love the energy but the message is a bit too big for the
              pigeon to carry, try one under 100 characters.",
            ),
          ]),
        )
        Unreachable | UnknownCode(_) | RsvpErrored(_) -> #(
          "imgs/pigeon-sleeping.png",
          html.p([], [
            html.text(
              "Looks like the printer is not reachable at the moment.
          The thermal printer is connected to a tiny Raspberry Pi Zero next to
          my desk and sometimes I turn it off... the pigeon is resting!",
            ),
          ]),
        )
      }

      html.div([attribute.class("switcher")], [
        html.img([attribute.src(img), attribute.style("max-width", "20ch")]),
        html.div([], [text]),
      ])
    }
  }
}
