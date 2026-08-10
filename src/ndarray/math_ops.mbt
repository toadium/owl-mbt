///|
/// Apply a unary function element-wise.
fn _map_elem(x : Ndarray, f : (Double) -> Double) -> Ndarray {
  let data = FixedArray::makei(x.data.length(), fn(i) { f(x.data[i]) })
  { shape: x.shape.copy(), data }
}

///|
pub fn abs(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { v.abs() })
}

///|
pub fn neg(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { -v })
}

///|
pub fn floor(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { v.floor() })
}

///|
pub fn ceil(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { v.ceil() })
}

///|
pub fn round(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { v.round() })
}

///|
pub fn sqr(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { v * v })
}

///|
pub fn sqrt(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { v.sqrt() })
}

///|
pub fn log(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.ln(v) })
}

///|
pub fn log2(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.log2(v) })
}

///|
pub fn log10(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.log10(v) })
}

///|
pub fn exp(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.exp(v) })
}

///|
pub fn sin(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.sin(v) })
}

///|
pub fn cos(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.cos(v) })
}

///|
pub fn tan(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.tan(v) })
}

///|
pub fn sinh(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.sinh(v) })
}

///|
pub fn cosh(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.cosh(v) })
}

///|
pub fn tanh(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.tanh(v) })
}

///|
pub fn asin(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.asin(v) })
}

///|
pub fn acos(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.acos(v) })
}

///|
pub fn atan(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.atan(v) })
}

///|
pub fn asinh(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.asinh(v) })
}

///|
pub fn acosh(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.acosh(v) })
}

///|
pub fn atanh(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.atanh(v) })
}

///|
pub fn signum(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @maths.signum(v) })
}

///|
pub fn sigmoid(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @maths.sigmoid(v) })
}

///|
pub fn relu(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { if v > 0.0 { v } else { 0.0 } })
}

///|
pub fn dawsn(x : Ndarray) -> Ndarray raise {
  let data = FixedArray::makei(x.data.length(), fn(i) raise {
    @maths.dawsn(x.data[i])
  })
  { shape: x.shape.copy(), data }
}
