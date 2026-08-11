///|
pub fn exists(f : (Double) -> Bool, x : Ndarray) -> Bool {
  for i in 0..<x.data.length() {
    if f(x.data[i]) {
      return true
    }
  }
  false
}

///|
pub fn not_exists(f : (Double) -> Bool, x : Ndarray) -> Bool {
  !exists(f, x)
}

///|
pub fn for_all(f : (Double) -> Bool, x : Ndarray) -> Bool {
  for i in 0..<x.data.length() {
    if !f(x.data[i]) {
      return false
    }
  }
  true
}

///|
pub fn is_zero(x : Ndarray) -> Bool {
  for_all(fn(v) { v == 0.0 }, x)
}

///|
pub fn is_positive(x : Ndarray) -> Bool {
  for_all(fn(v) { v > 0.0 }, x)
}

///|
pub fn is_negative(x : Ndarray) -> Bool {
  for_all(fn(v) { v < 0.0 }, x)
}

///|
pub fn is_nonpositive(x : Ndarray) -> Bool {
  for_all(fn(v) { v <= 0.0 }, x)
}

///|
pub fn is_nonnegative(x : Ndarray) -> Bool {
  for_all(fn(v) { v >= 0.0 }, x)
}

///|
pub fn is_normal(x : Ndarray) -> Bool {
  for_all(fn(v) { @maths.is_normal(v) }, x)
}

///|
pub fn not_nan(x : Ndarray) -> Bool {
  for_all(fn(v) { !v.is_nan() }, x)
}

///|
pub fn not_inf(x : Ndarray) -> Bool {
  for_all(fn(v) { !v.is_inf() }, x)
}

///|
pub fn equal(x : Ndarray, y : Ndarray) -> Bool {
  if x.shape.length() != y.shape.length() {
    return false
  }
  for i in 0..<x.shape.length() {
    if x.shape[i] != y.shape[i] {
      return false
    }
  }
  for i in 0..<x.data.length() {
    if x.data[i] != y.data[i] {
      return false
    }
  }
  true
}

///|
pub fn not_equal(x : Ndarray, y : Ndarray) -> Bool {
  !equal(x, y)
}

///|
pub fn greater(x : Ndarray, y : Ndarray) -> Bool {
  let n = x.data.length()
  for i in 0..<n {
    if x.data[i] <= y.data[i] {
      return false
    }
  }
  true
}

///|
pub fn less(x : Ndarray, y : Ndarray) -> Bool {
  let n = x.data.length()
  for i in 0..<n {
    if x.data[i] >= y.data[i] {
      return false
    }
  }
  true
}

///|
pub fn greater_equal(x : Ndarray, y : Ndarray) -> Bool {
  let n = x.data.length()
  for i in 0..<n {
    if x.data[i] < y.data[i] {
      return false
    }
  }
  true
}

///|
pub fn less_equal(x : Ndarray, y : Ndarray) -> Bool {
  let n = x.data.length()
  for i in 0..<n {
    if x.data[i] > y.data[i] {
      return false
    }
  }
  true
}

///|
pub fn elt_equal(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { if a == b { 1.0 } else { 0.0 } })
}

///|
pub fn elt_not_equal(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { if a != b { 1.0 } else { 0.0 } })
}

///|
pub fn elt_less(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { if a < b { 1.0 } else { 0.0 } })
}

///|
pub fn elt_greater(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { if a > b { 1.0 } else { 0.0 } })
}

///|
pub fn elt_less_equal(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { if a <= b { 1.0 } else { 0.0 } })
}

///|
pub fn elt_greater_equal(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { if a >= b { 1.0 } else { 0.0 } })
}

///|
pub fn equal_scalar(x : Ndarray, s : Double) -> Bool {
  for_all(fn(v) { v == s }, x)
}

///|
pub fn not_equal_scalar(x : Ndarray, s : Double) -> Bool {
  !equal_scalar(x, s)
}

///|
pub fn less_scalar(x : Ndarray, s : Double) -> Bool {
  for_all(fn(v) { v < s }, x)
}

///|
pub fn greater_scalar(x : Ndarray, s : Double) -> Bool {
  for_all(fn(v) { v > s }, x)
}

///|
pub fn less_equal_scalar(x : Ndarray, s : Double) -> Bool {
  for_all(fn(v) { v <= s }, x)
}

///|
pub fn greater_equal_scalar(x : Ndarray, s : Double) -> Bool {
  for_all(fn(v) { v >= s }, x)
}

///|
pub fn elt_equal_scalar(x : Ndarray, s : Double) -> Ndarray {
  _map_elem(x, fn(v) { if v == s { 1.0 } else { 0.0 } })
}

///|
pub fn elt_not_equal_scalar(x : Ndarray, s : Double) -> Ndarray {
  _map_elem(x, fn(v) { if v != s { 1.0 } else { 0.0 } })
}

///|
pub fn elt_less_scalar(x : Ndarray, s : Double) -> Ndarray {
  _map_elem(x, fn(v) { if v < s { 1.0 } else { 0.0 } })
}

///|
pub fn elt_greater_scalar(x : Ndarray, s : Double) -> Ndarray {
  _map_elem(x, fn(v) { if v > s { 1.0 } else { 0.0 } })
}

///|
pub fn elt_less_equal_scalar(x : Ndarray, s : Double) -> Ndarray {
  _map_elem(x, fn(v) { if v <= s { 1.0 } else { 0.0 } })
}

///|
pub fn elt_greater_equal_scalar(x : Ndarray, s : Double) -> Ndarray {
  _map_elem(x, fn(v) { if v >= s { 1.0 } else { 0.0 } })
}

///|
pub fn approx_equal(x : Ndarray, y : Ndarray, eps? : Double = 1.0e-6) -> Bool {
  let n = x.data.length()
  if n != y.data.length() {
    return false
  }
  for i in 0..<n {
    if (x.data[i] - y.data[i]).abs() > eps {
      return false
    }
  }
  true
}
