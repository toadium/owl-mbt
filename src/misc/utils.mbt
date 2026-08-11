///|
/// Find the longest string in an array.
pub fn longest_string(arr : Array[String]) -> Int {
  let mut max_len = 0
  for s in arr {
    if s.length() > max_len {
      max_len = s.length()
    }
  }
  max_len
}

///|
/// Pad strings to a given length.
pub enum PaddingSide {
  Left
  Right
  Center
}

///|
/// Public constructors for PaddingSide.
pub fn pad_left() -> PaddingSide {
  Left
}

///|
pub fn pad_right() -> PaddingSide {
  Right
}

///|
pub fn pad_center() -> PaddingSide {
  Center
}

///|
fn _repeat_str(s : String, n : Int) -> String {
  Array::make(n, s).join("")
}

///|
/// Pad a string to the given length.
pub fn pad_string(s : String, len : Int, side : PaddingSide) -> String {
  let s_len = s.length()
  if s_len >= len {
    s
  } else {
    let total_pad = len - s_len
    match side {
      Left => {
        let padding = _repeat_str(" ", total_pad)
        "\{padding}\{s}"
      }
      Right => {
        let padding = _repeat_str(" ", total_pad)
        "\{s}\{padding}"
      }
      Center => {
        let left_pad = total_pad / 2
        let right_pad = total_pad - left_pad
        let left = _repeat_str(" ", left_pad)
        let right = _repeat_str(" ", right_pad)
        "\{left}\{s}\{right}"
      }
    }
  }
}

///|
/// Pad an array of strings to the same length.
pub fn pad_strings(
  arr : Array[String],
  len : Int,
  side : PaddingSide,
) -> Array[String] {
  Array::makei(arr.length(), fn(i) { pad_string(arr[i], len, side) })
}

///|
/// Compare two floats with absolute tolerance: `|a - b| < eps`.
/// Suitable for values near zero. For large-magnitude values, prefer
/// `approx_equal_rel` which uses relative tolerance.
pub fn approx_equal(a : Double, b : Double, eps : Double) -> Bool {
  (a - b).abs() < eps
}

///|
/// Compare two floats with relative tolerance:
/// `|a - b| / (1 + max(|a|, |b|)) < eps`.
/// Works well for both large and small magnitudes. The `1 +` in the
/// denominator gracefully handles the case where both values are near zero.
pub fn approx_equal_rel(a : Double, b : Double, eps : Double) -> Bool {
  let max_abs = if a.abs() > b.abs() { a.abs() } else { b.abs() }
  (a - b).abs() / (1.0 + max_abs) < eps
}

///|
/// Repeat a string n times.
pub fn repeat_string(s : String, n : Int) -> String {
  _repeat_str(s, n)
}
