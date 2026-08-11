///|
/// Element-wise atan2(y, x) = atan(y / x) with broadcasting.
pub fn atan2(y : Ndarray, x : Ndarray) -> Ndarray raise {
  _broadcasted_op(y, x, fn(a, b) { @math.atan2(a, b) })
}

///|
/// atan2 of scalar and array: atan2(a, x).
pub fn scalar_atan2(a : Double, x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.atan2(a, v) })
}

///|
/// atan2 of array and scalar: atan2(x, a).
pub fn atan2_scalar(x : Ndarray, a : Double) -> Ndarray {
  _map_elem(x, fn(v) { @math.atan2(v, a) })
}

///|
/// Clip elements to [amin, amax].
pub fn clip_by_value(
  x : Ndarray,
  amin? : Double = -1.7976931348623157e308,
  amax? : Double = 1.7976931348623157e308,
) -> Ndarray {
  _map_elem(x, fn(v) {
    if v < amin {
      amin
    } else if v > amax {
      amax
    } else {
      v
    }
  })
}

///|
/// Clip array so its L2 norm does not exceed clip_norm.
pub fn clip_by_l2norm(clip_norm : Double, x : Ndarray) -> Ndarray {
  let l2 = l2norm_(x)
  if l2 > clip_norm {
    mul_scalar(x, clip_norm / l2)
  } else {
    x
  }
}

///|
/// Sum slices along an axis. Returns array of shape dims[axis+1:].
pub fn sum_slices(x : Ndarray, axis? : Int = 0) -> Ndarray {
  let dims = x.shape
  let rank = dims.length()
  let mut num_rows = 1
  for i in 0..<=axis {
    num_rows *= dims[i]
  }
  let num_cols = x.data.length() / num_rows
  let result_shape = Array::makei(rank - axis - 1, fn(i) { dims[axis + 1 + i] })
  let data = FixedArray::make(num_cols, 0.0)
  for j in 0..<num_cols {
    let mut s = 0.0
    for i in 0..<num_rows {
      s += x.data[i * num_cols + j]
    }
    data[j] = s
  }
  { shape: result_shape, data }
}

///|
/// log(sum(exp(x))) scalar version.
pub fn log_sum_exp_(x : Ndarray) -> Double raise {
  let m = max_(x)
  let mut s = 0.0
  for i in 0..<x.data.length() {
    s += @math.exp(x.data[i] - m)
  }
  m + @math.ln(s)
}

///|
/// log(sum(exp(x))) along an axis.
pub fn log_sum_exp(
  x : Ndarray,
  axis? : Int = -1,
  keep_dims? : Bool = true,
) -> Ndarray raise {
  if axis < 0 {
    return create([1], log_sum_exp_(x))
  }
  let m = max(x, axis~, keep_dims~)
  let shifted = sub(x, m)
  let exp_shifted = exp(shifted)
  let s = sum(exp_shifted, axis~, keep_dims~)
  let log_s = _map_elem(s, fn(v) { @math.ln(v) })
  add(m, log_s)
}

///|
/// Softmax along an axis.
pub fn softmax(x : Ndarray, axis? : Int = -1) -> Ndarray raise {
  let ax = if axis < 0 { x.shape.length() - 1 } else { axis }
  // Fast path: 1D softmax (most common in ML)
  if x.shape.length() == 1 {
    let n = x.data.length()
    if n == 0 {
      return { shape: x.shape.copy(), data: FixedArray::make(0, 0.0) }
    }
    let data = FixedArray::make(n, 0.0)
    let xd = x.data
    // Find max for numerical stability
    let mut m = xd[0]
    for i in 1..<n {
      if xd[i] > m {
        m = xd[i]
      }
    }
    // exp(x - max) and sum in one pass
    let mut s = 0.0
    for i in 0..<n {
      let e = @math.exp(xd[i] - m)
      data[i] = e
      s += e
    }
    // Normalize in-place
    for i in 0..<n {
      data[i] /= s
    }
    return { shape: x.shape.copy(), data }
  }
  let m = max(x, axis=ax, keep_dims=true)
  let shifted = sub(x, m)
  let e = exp(shifted)
  let s = sum(e, axis=ax, keep_dims=true)
  div(e, s)
}

///|
/// Check if all elements are approximately equal to a scalar.
pub fn approx_equal_scalar(
  x : Ndarray,
  b : Double,
  eps? : Double = 1.0e-6,
) -> Bool {
  for i in 0..<x.data.length() {
    if (x.data[i] - b).abs() >= eps {
      return false
    }
  }
  true
}

///|
/// Element-wise approximate equality. Returns boolean array (1.0 if approx equal, 0.0 otherwise).
pub fn approx_elt_equal(
  x : Ndarray,
  y : Ndarray,
  eps? : Double = 1.0e-6,
) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { if (a - b).abs() < eps { 1.0 } else { 0.0 } })
}

///|
/// Element-wise approximate equality with a scalar. Returns boolean array.
pub fn approx_elt_equal_scalar(
  x : Ndarray,
  a : Double,
  eps? : Double = 1.0e-6,
) -> Ndarray {
  _map_elem(x, fn(v) { if (v - a).abs() < eps { 1.0 } else { 0.0 } })
}
