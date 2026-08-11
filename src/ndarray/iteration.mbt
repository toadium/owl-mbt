///|
/// Iterate over elements with 1D index.
pub fn iteri(f : (Int, Double) -> Unit, x : Ndarray) -> Unit {
  for i in 0..<x.data.length() {
    f(i, x.data[i])
  }
}

///|
/// Iterate over elements.
pub fn iter(f : (Double) -> Unit, x : Ndarray) -> Unit {
  for i in 0..<x.data.length() {
    f(x.data[i])
  }
}

///|
/// Map with 1D index.
pub fn mapi(f : (Int, Double) -> Double, x : Ndarray) -> Ndarray {
  let data = FixedArray::makei(x.data.length(), fn(i) { f(i, x.data[i]) })
  { shape: x.shape.copy(), data }
}

///|
/// Map elements: apply `f` to each element, returning a new ndarray.
/// Same as `map_elem` but with argument order `(f, x)`.
pub fn map(f : (Double) -> Double, x : Ndarray) -> Ndarray {
  let data = FixedArray::makei(x.data.length(), fn(i) { f(x.data[i]) })
  { shape: x.shape.copy(), data }
}

///|
/// Filter elements, returning indices where predicate is true.
pub fn filteri(f : (Int, Double) -> Bool, x : Ndarray) -> Array[Int] {
  let result = []
  for i in 0..<x.data.length() {
    if f(i, x.data[i]) {
      result.push(i)
    }
  }
  result
}

///|
/// Filter elements.
pub fn filter(f : (Double) -> Bool, x : Ndarray) -> Array[Int] {
  filteri(fn(_i, v) { f(v) }, x)
}

///|
/// Fold over all elements (no axis or along axis).
pub fn foldi(
  f : (Int, Double, Double) -> Double,
  init : Double,
  x : Ndarray,
  axis? : Int = -1,
) -> Ndarray {
  let ax = axis
  if ax < 0 {
    let mut acc = init
    for i in 0..<x.data.length() {
      acc = f(i, acc, x.data[i])
    }
    create([1], acc)
  } else {
    let (m, n, o, out_shape) = reduce_params(ax, x.shape)
    let total = _numel_shape(out_shape)
    let data = FixedArray::make(total, init)
    let mut src_idx = 0
    let mut dst_idx = 0
    for _ in 0..<m {
      let mut incy = 0
      for j in 0..<n {
        data[dst_idx + incy] = f(
          src_idx,
          data[dst_idx + incy],
          x.data[src_idx + j],
        )
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
}

///|
/// Fold over all elements.
pub fn fold(
  f : (Double, Double) -> Double,
  init : Double,
  x : Ndarray,
  axis? : Int = -1,
) -> Ndarray {
  foldi(fn(_i, a, b) { f(a, b) }, init, x, axis~)
}

///|
/// Scan (cumulative operation) along an axis.
pub fn scani(
  f : (Int, Double, Double) -> Double,
  x : Ndarray,
  axis? : Int = -1,
) -> Ndarray {
  let n = x.shape.length()
  let ax = if axis < 0 { n - 1 } else { axis }
  let st = calc_strides(x.shape)
  let sz = slice_size(x)
  let m = _numel_shape(x.shape) / sz[ax]
  let stride = st[ax]
  let total = _numel_shape(x.shape)
  let data = FixedArray::make(total, 0.0)
  for i in 0..<total {
    data[i] = x.data[i]
  }
  let mut start_x = 0
  let mut start_y = stride
  let mut k = 0
  for _ in 0..<m {
    for j in 0..<(sz[ax] - stride) {
      data[start_y + j] = f(k, data[start_x + j], data[start_y + j])
      k += 1
    }
    start_x += sz[ax]
    start_y += sz[ax]
  }
  { shape: x.shape.copy(), data }
}

///|
/// Scan along an axis.
pub fn scan(
  f : (Double, Double) -> Double,
  x : Ndarray,
  axis? : Int = -1,
) -> Ndarray {
  scani(fn(_i, a, b) { f(a, b) }, x, axis~)
}
