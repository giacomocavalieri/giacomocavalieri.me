import gleeunit
import jot_extra

pub fn main() {
  gleeunit.main()
}

pub fn safe_id_test() {
  assert jot_extra.to_safe_id("Wibble") == "wibble"
  assert jot_extra.to_safe_id("wibble and wobble") == "wibble-and-wobble"
  assert jot_extra.to_safe_id("wibble (and) `wobble`") == "wibble-and-wobble"
}
