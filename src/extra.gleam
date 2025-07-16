import gleam/int
import gleam/order.{type Order}
import gleam/time/calendar.{type Date, Date}

pub fn try_map_error(
  result: Result(a, e),
  map_error: fn(e) -> e1,
  fun: fn(a) -> Result(b, e1),
) -> Result(b, e1) {
  case result {
    Ok(a) -> fun(a)
    Error(e) -> Error(map_error(e))
  }
}

pub fn date_compare(one: Date, other: Date) -> Order {
  let Date(year:, month:, day:) = one
  let Date(year: year_other, month: month_other, day: day_other) = other

  use <- order.lazy_break_tie(int.compare(year, year_other))
  let month = calendar.month_to_int(month)
  let month_other = calendar.month_to_int(month_other)
  use <- order.lazy_break_tie(int.compare(month, month_other))
  int.compare(day, day_other)
}
