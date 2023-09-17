pub const base = "https://giacomocavalieri.me"

pub fn for_tag(tag: String) -> String {
  base <> "/tags/" <> tag
}
