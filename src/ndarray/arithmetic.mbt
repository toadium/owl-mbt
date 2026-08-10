///|
/// Generic broadcasted binary operation.
fn _broadcasted_op(
  x : Ndarray,
  y : Ndarray,
  op_fun : (Double, Double) -> Double,
) -> Ndarray raise {
  let (ext_a, ext_b, dims_c) = get_broadcasted_dims(x.shape, y.shape)
  let total = _numel_shape(dims_c)
  let data = FixedArray::make(total, 0.0)
  let strides_a = calc_strides(ext_a)
  let strides_b = calc_strides(ext_b)
  let strides_c = calc_strides(dims_c)
  let ind = Array::make(dims_c.length(), 0)
  let mut should_stop = false
  while !should_stop {
    let ind_a = get_broadcasted_index(ind, ext_a)
    let ind_b = get_broadcasted_index(ind, ext_b)
    let flat_a = flat_index(ind_a, strides_a)
    let flat_b = flat_index(ind_b, strides_b)
    let flat_c = flat_index(ind, strides_c)
    data[flat_c] = op_fun(x.data[flat_a], y.data[flat_b])
    if !next_index(ind, dims_c) {
      should_stop = true
    }
  }
  { shape: dims_c, data }
}

///|
pub fn add(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { a + b })
}

///|
pub fn sub(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { a - b })
}

///|
pub fn mul(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { a * b })
}

///|
pub fn div(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { a / b })
}

///|
pub fn pow(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { _pow(a, b) })
}

///|
pub fn fma(x : Ndarray, y : Ndarray, z : Ndarray) -> Ndarray raise {
  let xy = mul(x, y)
  add(xy, z)
}

///|
pub fn add_scalar(x : Ndarray, s : Double) -> Ndarray {
  let data = FixedArray::makei(x.data.length(), fn(i) { x.data[i] + s })
  { shape: x.shape.copy(), data }
}

///|
pub fn sub_scalar(x : Ndarray, s : Double) -> Ndarray {
  let data = FixedArray::makei(x.data.length(), fn(i) { x.data[i] - s })
  { shape: x.shape.copy(), data }
}

///|
pub fn mul_scalar(x : Ndarray, s : Double) -> Ndarray {
  let data = FixedArray::makei(x.data.length(), fn(i) { x.data[i] * s })
  { shape: x.shape.copy(), data }
}

///|
pub fn div_scalar(x : Ndarray, s : Double) -> Ndarray {
  let data = FixedArray::makei(x.data.length(), fn(i) { x.data[i] / s })
  { shape: x.shape.copy(), data }
}

///|
pub fn scalar_add(s : Double, x : Ndarray) -> Ndarray {
  add_scalar(x, s)
}

///|
pub fn scalar_sub(s : Double, x : Ndarray) -> Ndarray {
  let data = FixedArray::makei(x.data.length(), fn(i) { s - x.data[i] })
  { shape: x.shape.copy(), data }
}

///|
pub fn scalar_mul(s : Double, x : Ndarray) -> Ndarray {
  mul_scalar(x, s)
}

///|
pub fn scalar_div(s : Double, x : Ndarray) -> Ndarray {
  let data = FixedArray::makei(x.data.length(), fn(i) { s / x.data[i] })
  { shape: x.shape.copy(), data }
}

///|
pub fn scalar_pow(s : Double, x : Ndarray) -> Ndarray {
  let data = FixedArray::makei(x.data.length(), fn(i) { _pow(s, x.data[i]) })
  { shape: x.shape.copy(), data }
}

///|
pub fn pow_scalar(x : Ndarray, s : Double) -> Ndarray {
  let data = FixedArray::makei(x.data.length(), fn(i) { _pow(x.data[i], s) })
  { shape: x.shape.copy(), data }
}
