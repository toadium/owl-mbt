///|
/// Return the shape of an ndarray.
pub fn shape(x : Ndarray) -> Array[Int] {
  x.shape
}

///|
/// Return the number of dimensions.
pub fn num_dims(x : Ndarray) -> Int {
  x.shape.length()
}

///|
/// Return the total number of elements.
pub fn numel(x : Ndarray) -> Int {
  _numel_shape(x.shape)
}

///|
/// Return the strides (row-major).
pub fn strides(x : Ndarray) -> Array[Int] {
  calc_strides(x.shape)
}

///|
/// Return the slice sizes (cumulative product from right).
pub fn slice_size(x : Ndarray) -> Array[Int] {
  let n = x.shape.length()
  let result = Array::make(n, 1)
  let mut i = n - 2
  while i >= 0 {
    result[i] = result[i + 1] * x.shape[i + 1]
    i -= 1
  }
  result
}

///|
/// Get element at multi-dimensional index.
pub fn get(x : Ndarray, index : Array[Int]) -> Double raise {
  let nd = x.shape.length()
  // Fast paths for 1D and 2D (avoid calc_strides allocation)
  let idx = match nd {
    1 => index[0]
    2 => index[0] * x.shape[1] + index[1]
    _ => {
      let st = calc_strides(x.shape)
      flat_index(index, st)
    }
  }
  if idx < 0 || idx >= x.data.length() {
    raise @types.OwlError::InvalidArgument("index out of bounds")
  }
  x.data[idx]
}

///|
/// Set element at multi-dimensional index.
pub fn set(x : Ndarray, index : Array[Int], value : Double) -> Unit raise {
  let nd = x.shape.length()
  // Fast paths for 1D and 2D (avoid calc_strides allocation)
  let idx = match nd {
    1 => index[0]
    2 => index[0] * x.shape[1] + index[1]
    _ => {
      let st = calc_strides(x.shape)
      flat_index(index, st)
    }
  }
  if idx < 0 || idx >= x.data.length() {
    raise @types.OwlError::InvalidArgument("index out of bounds")
  }
  x.data[idx] = value
}

///|
/// Create an empty ndarray with given shape.
pub fn empty(shape : Array[Int]) -> Ndarray {
  let n = _numel_shape(shape)
  { shape: shape.copy(), data: FixedArray::make(n, 0.0) }
}

///|
/// Create an ndarray from existing FixedArray data and shape.
/// The data length must match the product of shape dimensions.
pub fn from_data(shape : Array[Int], data : FixedArray[Double]) -> Ndarray {
  { shape: shape.copy(), data }
}

///|
/// Create an ndarray filled with a constant value.
pub fn create(shape : Array[Int], value : Double) -> Ndarray {
  let n = _numel_shape(shape)
  { shape: shape.copy(), data: FixedArray::make(n, value) }
}

///|
/// Create an ndarray filled with zeros.
pub fn zeros(shape : Array[Int]) -> Ndarray {
  create(shape, 0.0)
}

///|
/// Create an ndarray filled with ones.
pub fn ones(shape : Array[Int]) -> Ndarray {
  create(shape, 1.0)
}

///|
/// Create an ndarray using a 1D index-based init function.
pub fn from_fn(shape : Array[Int], f : (Int) -> Double) -> Ndarray {
  let n = _numel_shape(shape)
  let data = FixedArray::makei(n, f)
  { shape: shape.copy(), data }
}

///|
/// Create an ndarray using an n-dimensional index-based init function.
pub fn init_nd(shape : Array[Int], f : (Array[Int]) -> Double) -> Ndarray {
  let n = _numel_shape(shape)
  let st = calc_strides(shape)
  let data = FixedArray::makei(n, fn(i) {
    let nd_idx = Array::make(shape.length(), 0)
    let mut rem = i
    for j in 0..<shape.length() {
      nd_idx[j] = rem / st[j]
      rem = rem % st[j]
    }
    f(nd_idx)
  })
  { shape: shape.copy(), data }
}

///|
/// Create a sequential ndarray: a, a+step, a+2*step, ...
pub fn sequential(
  shape : Array[Int],
  a? : Double = 0.0,
  step? : Double = 1.0,
) -> Ndarray {
  from_fn(shape, fn(i) { a + step * i.to_double() })
}

///|
/// Create an ndarray from a flat array with given shape.
pub fn of_array(arr : Array[Double], shape : Array[Int]) -> Ndarray {
  let n = _numel_shape(shape)
  let data = FixedArray::make(n, 0.0)
  for i in 0..<n {
    data[i] = arr[i]
  }
  { shape: shape.copy(), data }
}

///|
/// Create a 2D ndarray from an array of arrays (rows).
pub fn of_arrays(arrays : Array[Array[Double]]) -> Ndarray {
  let rows = arrays.length()
  let cols = if rows > 0 { arrays[0].length() } else { 0 }
  let n = rows * cols
  let data = FixedArray::make(n, 0.0)
  for i in 0..<rows {
    for j in 0..<cols {
      data[i * cols + j] = arrays[i][j]
    }
  }
  { shape: [rows, cols], data }
}

///|
/// Create an identity matrix.
pub fn eye(n : Int) -> Ndarray {
  let m = zeros([n, n])
  for i in 0..<n {
    m.data[i * n + i] = 1.0
  }
  m
}

///|
/// Copy an ndarray.
pub fn copy(x : Ndarray) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n, 0.0)
  for i in 0..<n {
    data[i] = x.data[i]
  }
  { shape: x.shape.copy(), data }
}

///|
/// Reset all elements to zero.
pub fn reset(x : Ndarray) -> Unit {
  for i in 0..<x.data.length() {
    x.data[i] = 0.0
  }
}

///|
/// Fill all elements with a constant value.
pub fn fill(x : Ndarray, value : Double) -> Unit {
  for i in 0..<x.data.length() {
    x.data[i] = value
  }
}
