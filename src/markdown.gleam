import gleam/result
import gleam/string
import lustre/element.{type Element}

pub type Error {
  MissingMetadata
  MalformedMetadata
}

pub fn parse_no_metadata(markdown: String) -> List(Element(a)) {
  parse_body(markdown)
}

pub fn parse(markdown: String) -> Result(#(String, List(Element(a))), Error) {
  use #(metadata, body) <- result.try(extract_metadata(markdown))
  Ok(#(metadata, parse_body(body)))
}

/// If there's no metadata I want it to be an error, the same goes for
/// malformed metadata.
///
/// This parsing strategy is super bare bones and probably horrible for a
/// general case (no +++ heading is supported, for example). However it just
/// works perfectly for my case, so I'm not overcomplicating it :)
///
fn extract_metadata(markdown: String) -> Result(#(String, String), Error) {
  let markdown = string.trim(markdown)
  case markdown {
    "---\n" <> rest -> {
      case string.split_once(rest, on: "\n---") {
        Ok(result) -> Ok(result)
        _ -> Error(MalformedMetadata)
      }
    }
    _ -> Error(MissingMetadata)
  }
}

@external(javascript, "./markdown.ffi.mjs", "parse")
fn parse_body(content: String) -> List(Element(a))
