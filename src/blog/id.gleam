import gleam/string

pub fn from_string(string: String) -> String {
  string.lowercase(string)
  |> string.replace(each: " ", with: "-")
  |> string.replace(each: "\t", with: "-")
  |> string.replace(each: "\n", with: "-")
  |> string.replace(each: "\r\n", with: "-")
  |> string.replace(each: ",", with: "")
}
