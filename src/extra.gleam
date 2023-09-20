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
