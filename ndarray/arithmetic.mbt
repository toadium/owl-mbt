///|
/// Check if two shapes are equal.
fn _shapes_equal(a : Array[Int32], b : Array[Int32]) -> Bool {
  let n = a.length()
  if n != b.length() {
    return false
  }
  for i in 0..<n {
    if a[i] != b[i] {
      return false
    }
  }
  true
}

///|
/// Fast path for same-shape element-wise operation (no broadcasting needed).
fn _same_shape_op(
  x : Ndarray,
  y : Ndarray,
  op_fun : (Double, Double) -> Double,
) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n, 0.0)
  let xd = x.data
  let yd = y.data
  for i in 0..<n {
    data[i] = op_fun(xd[i], yd[i])
  }
  { shape: x.shape.copy(), data, }
}

///|
/// Generic broadcasted binary operation.
fn _broadcasted_op(
  x : Ndarray,
  y : Ndarray,
  op_fun : (Double, Double) -> Double,
) -> Ndarray raise {
  // Fast path: same shape, no broadcasting needed
  if _shapes_equal(x.shape, y.shape) {
    return _same_shape_op(x, y, op_fun)
  }
  let (ext_a, ext_b, dims_c) = get_broadcasted_dims(x.shape, y.shape)
  let total = _numel_shape(dims_c)
  let data = FixedArray::make(total, 0.0)
  let strides_a = calc_strides(ext_a)
  let strides_b = calc_strides(ext_b)
  let strides_c = calc_strides(dims_c)
  // Reuse index arrays to avoid per-iteration allocation
  let ind = Array::make(dims_c.length(), 0)
  let ind_a = Array::make(ext_a.length(), 0)
  let ind_b = Array::make(ext_b.length(), 0)
  let mut should_stop = false
  while !should_stop {
    // Compute broadcasted indices in-place (no allocation)
    for i in 0..<ext_a.length() {
      ind_a[i] = if ext_a[i] == 1 { 0 } else { ind[i] }
    }
    for i in 0..<ext_b.length() {
      ind_b[i] = if ext_b[i] == 1 { 0 } else { ind[i] }
    }
    let flat_a = flat_index(ind_a, strides_a)
    let flat_b = flat_index(ind_b, strides_b)
    let flat_c = flat_index(ind, strides_c)
    data[flat_c] = op_fun(x.data[flat_a], y.data[flat_b])
    if !next_index(ind, dims_c) {
      should_stop = true
    }
  }
  { shape: dims_c, data, }
}

///|
/// 逐元素相加，支持广播
pub fn add(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { a + b })
}

///|
/// 逐元素相减，支持广播
pub fn sub(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { a - b })
}

///|
/// 逐元素相乘，支持广播
pub fn mul(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { a * b })
}

///|
/// 逐元素相除，支持广播
pub fn div(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { a / b })
}

///|
/// 逐元素乘方 x^y，支持广播
pub fn pow(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { _pow(a, b) })
}

///|
/// Fused multiply-add: x * y + z in a single pass (no intermediate allocation).
pub fn fma(x : Ndarray, y : Ndarray, z : Ndarray) -> Ndarray raise {
  // Fast path: all same shape
  if _shapes_equal(x.shape, y.shape) && _shapes_equal(x.shape, z.shape) {
    let n = x.data.length()
    let data = FixedArray::make(n, 0.0)
    let xd = x.data
    let yd = y.data
    let zd = z.data
    for i in 0..<n {
      data[i] = xd[i] * yd[i] + zd[i]
    }
    return { shape: x.shape.copy(), data, }
  }
  // Fallback: two-pass
  let xy = mul(x, y)
  add(xy, z)
}

///|
/// 每个元素加标量
pub fn add_scalar(x : Ndarray, s : Double) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n, 0.0)
  let xd = x.data
  for i in 0..<n {
    data[i] = xd[i] + s
  }
  { shape: x.shape.copy(), data, }
}

///|
/// 每个元素减标量
pub fn sub_scalar(x : Ndarray, s : Double) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n, 0.0)
  let xd = x.data
  for i in 0..<n {
    data[i] = xd[i] - s
  }
  { shape: x.shape.copy(), data, }
}

///|
/// 每个元素乘标量
pub fn mul_scalar(x : Ndarray, s : Double) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n, 0.0)
  let xd = x.data
  for i in 0..<n {
    data[i] = xd[i] * s
  }
  { shape: x.shape.copy(), data, }
}

///|
/// 每个元素除以标量
pub fn div_scalar(x : Ndarray, s : Double) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n, 0.0)
  let xd = x.data
  for i in 0..<n {
    data[i] = xd[i] / s
  }
  { shape: x.shape.copy(), data, }
}

///|
/// 标量加数组，等价于 add_scalar
pub fn scalar_add(s : Double, x : Ndarray) -> Ndarray {
  add_scalar(x, s)
}

///|
/// 标量减数组 s - x（注意与 sub_scalar 的操作数顺序相反）
pub fn scalar_sub(s : Double, x : Ndarray) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n, 0.0)
  let xd = x.data
  for i in 0..<n {
    data[i] = s - xd[i]
  }
  { shape: x.shape.copy(), data, }
}

///|
/// 标量乘数组，等价于 mul_scalar
pub fn scalar_mul(s : Double, x : Ndarray) -> Ndarray {
  mul_scalar(x, s)
}

///|
/// 标量除以数组 s / x（注意与 div_scalar 的操作数顺序相反）
pub fn scalar_div(s : Double, x : Ndarray) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n, 0.0)
  let xd = x.data
  for i in 0..<n {
    data[i] = s / xd[i]
  }
  { shape: x.shape.copy(), data, }
}

///|
/// 标量为底的逐元素乘方 s^x
pub fn scalar_pow(s : Double, x : Ndarray) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n, 0.0)
  let xd = x.data
  for i in 0..<n {
    data[i] = _pow(s, xd[i])
  }
  { shape: x.shape.copy(), data, }
}

///|
/// 逐元素以标量为指数的乘方 x^s
pub fn pow_scalar(x : Ndarray, s : Double) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n, 0.0)
  let xd = x.data
  for i in 0..<n {
    data[i] = _pow(xd[i], s)
  }
  { shape: x.shape.copy(), data, }
}

///|
/// Add scalar IN-PLACE (modifies x, no allocation). Returns x for chaining.
pub fn add_scalar_inplace(x : Ndarray, s : Double) -> Ndarray {
  let n = x.data.length()
  let xd = x.data
  for i in 0..<n {
    xd[i] += s
  }
  x
}

///|
/// Multiply by scalar IN-PLACE (modifies x, no allocation). Returns x for chaining.
pub fn mul_scalar_inplace(x : Ndarray, s : Double) -> Ndarray {
  let n = x.data.length()
  let xd = x.data
  for i in 0..<n {
    xd[i] *= s
  }
  x
}

///|
/// Add another array IN-PLACE (modifies x, no allocation). Returns x for chaining.
/// Requires same shape (no broadcasting).
pub fn add_inplace(x : Ndarray, y : Ndarray) -> Ndarray raise {
  if !_shapes_equal(x.shape, y.shape) {
    raise @core.OwlError::InvalidArgument("add_inplace: shape mismatch")
  }
  let n = x.data.length()
  let xd = x.data
  let yd = y.data
  for i in 0..<n {
    xd[i] += yd[i]
  }
  x
}
