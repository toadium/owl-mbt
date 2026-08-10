///|
/// Sum of all elements (scalar).
pub fn sum_(x : Ndarray) -> Double {
  let mut s = 0.0
  for i in 0..<x.data.length() {
    s += x.data[i]
  }
  s
}

///|
/// Minimum element (scalar).
pub fn min_(x : Ndarray) -> Double {
  let mut m = x.data[0]
  for i in 1..<x.data.length() {
    if x.data[i] < m {
      m = x.data[i]
    }
  }
  m
}

///|
/// Maximum element (scalar).
pub fn max_(x : Ndarray) -> Double {
  let mut m = x.data[0]
  for i in 1..<x.data.length() {
    if x.data[i] > m {
      m = x.data[i]
    }
  }
  m
}

///|
/// Generic fold along an axis.
fn _fold_along(
  f : (Double, Double) -> Double,
  m : Int,
  n : Int,
  o : Int,
  x : Ndarray,
  out_shape : Array[Int],
  init : Double,
) -> Ndarray {
  let total = _numel_shape(out_shape)
  let data = FixedArray::make(total, init)
  let mut src_idx = 0
  let mut dst_idx = 0
  for _ in 0..<m {
    let mut incy = 0
    for j in 0..<n {
      data[dst_idx + incy] = f(data[dst_idx + incy], x.data[src_idx + j])
      if incy + 1 == o {
        incy = 0
      } else {
        incy += 1
      }
    }
    src_idx += n
    dst_idx += o
  }
  { shape: out_shape, data }
}

///|
/// Sum along an axis.
pub fn sum(x : Ndarray, axis? : Int = -1, keep_dims? : Bool = true) -> Ndarray {
  let ax = axis
  if ax < 0 {
    create([1], sum_(x))
  } else {
    let (m, n, o, out_shape) = reduce_params(ax, x.shape)
    let result = _fold_along(fn(a, b) { a + b }, m, n, o, x, out_shape, 0.0)
    if keep_dims {
      result
    } else {
      squeeze(result)
    }
  }
}

///|
/// Min along an axis.
pub fn min(x : Ndarray, axis? : Int = -1, keep_dims? : Bool = true) -> Ndarray {
  let ax = axis
  if ax < 0 {
    create([1], min_(x))
  } else {
    let (m, n, o, out_shape) = reduce_params(ax, x.shape)
    let init_val = @const.max_float64
    let result = _fold_along(
      fn(a, b) { if a < b { a } else { b } },
      m,
      n,
      o,
      x,
      out_shape,
      init_val,
    )
    if keep_dims {
      result
    } else {
      squeeze(result)
    }
  }
}

///|
/// Max along an axis.
pub fn max(x : Ndarray, axis? : Int = -1, keep_dims? : Bool = true) -> Ndarray {
  let ax = axis
  if ax < 0 {
    create([1], max_(x))
  } else {
    let (m, n, o, out_shape) = reduce_params(ax, x.shape)
    let init_val = @const.min_float64
    let result = _fold_along(
      fn(a, b) { if a > b { a } else { b } },
      m,
      n,
      o,
      x,
      out_shape,
      init_val,
    )
    if keep_dims {
      result
    } else {
      squeeze(result)
    }
  }
}

///|
/// Mean of all elements (scalar).
pub fn mean_(x : Ndarray) -> Double {
  sum_(x) / x.data.length().to_double()
}

///|
/// L1 norm (scalar).
pub fn l1norm_(x : Ndarray) -> Double {
  let mut s = 0.0
  for i in 0..<x.data.length() {
    s += x.data[i].abs()
  }
  s
}

///|
/// L2 norm squared (scalar).
pub fn l2norm_sqr_(x : Ndarray) -> Double {
  let mut s = 0.0
  for i in 0..<x.data.length() {
    s += x.data[i] * x.data[i]
  }
  s
}

///|
/// L2 norm (scalar).
pub fn l2norm_(x : Ndarray) -> Double {
  l2norm_sqr_(x).sqrt()
}
