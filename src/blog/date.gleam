import gleam/dynamic.{Dynamic}
import gleam/int
import gleam/order.{Eq, Gt, Lt, Order}
import gleam/result
import gleam/string

pub opaque type Date {
  Date(day: Int, month: Month, year: Int)
}

pub type Month {
  Gen
  Feb
  Mar
  Apr
  May
  Jun
  Jul
  Aug
  Sep
  Oct
  Nov
  Dec
}

pub fn new(day: Int, month: Month, year: Int) -> Date {
  Date(day, month, year)
}

pub fn to_string(date: Date) -> String {
  let Date(day, month, year) = date

  [int.to_string(day), month_to_string(month), int.to_string(year)]
  |> string.join(with: " ")
}

pub fn to_datetime(date: Date) -> String {
  let Date(day, month, year) = date
  [
    int.to_string(year),
    month_to_int(month)
    |> int.to_string
    |> string.pad_left(to: 2, with: "0"),
    int.to_string(day)
    |> string.pad_left(to: 2, with: "0"),
  ]
  |> string.join("-")
}

fn month_to_string(month: Month) -> String {
  case month {
    Gen -> "genuary"
    Feb -> "february"
    Mar -> "march"
    Apr -> "april"
    May -> "may"
    Jun -> "june"
    Jul -> "july"
    Aug -> "august"
    Sep -> "september"
    Oct -> "october"
    Nov -> "november"
    Dec -> "december"
  }
}

pub fn compare(one: Date, other: Date) -> Order {
  case int.compare(one.year, other.year) {
    Lt -> Lt
    Gt -> Gt
    Eq ->
      case month_compare(one.month, other.month) {
        Lt -> Lt
        Gt -> Gt
        Eq -> int.compare(one.day, other.day)
      }
  }
}

fn month_compare(one: Month, other: Month) -> Order {
  int.compare(month_to_int(one), month_to_int(other))
}

fn month_to_int(month: Month) -> Int {
  case month {
    Gen -> 1
    Feb -> 2
    Mar -> 3
    Apr -> 4
    May -> 5
    Jun -> 6
    Jul -> 7
    Aug -> 8
    Sep -> 9
    Oct -> 10
    Nov -> 11
    Dec -> 12
  }
}

fn month_from_int(value: Int) -> Result(Month, Nil) {
  case value {
    1 -> Ok(Gen)
    2 -> Ok(Feb)
    3 -> Ok(Mar)
    4 -> Ok(Apr)
    5 -> Ok(May)
    6 -> Ok(Jun)
    7 -> Ok(Jul)
    8 -> Ok(Aug)
    9 -> Ok(Sep)
    10 -> Ok(Oct)
    11 -> Ok(Nov)
    12 -> Ok(Dec)
    _ -> Error(Nil)
  }
}

pub fn decoder(from value: Dynamic) -> Result(Date, List(dynamic.DecodeError)) {
  use string <- result.try(dynamic.string(value))
  case string.split(string, on: "-") {
    [year, month, day] -> {
      use year <- result.try(int.parse(year))
      use month <- result.try(int.parse(month))
      use month <- result.try(month_from_int(month))
      use day <- result.try(int.parse(day))
      Ok(Date(year, month, day))
    }
    _ -> Error(Nil)
  }
  |> result.replace_error([
    dynamic.DecodeError(expected: "A date", found: "", path: []),
  ])
}
