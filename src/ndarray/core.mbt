///|
/// Strided n-d array with row-major (C layout) storage.
/// Replaces OCaml Bigarray.Genarray.t from owl-base.
pub struct Ndarray {
  shape : Array[Int]
  data : FixedArray[Double]
}

///|
fn _pow(base : Double, exp : Double) -> Double {
  @math.pow(base, exp)
}

///|
fn calc_strides(shape : Array[Int]) -> Array[Int] {
  let n = shape.length()
  if n == 0 {
    return []
  }
  let strides = Array::make(n, 1)
  let mut i = n - 2
  while i >= 0 {
    strides[i] = strides[i + 1] * shape[i + 1]
    i -= 1
  }
  strides
}

///|
fn _numel_shape(shape : Array[Int]) -> Int {
  let mut p = 1
  for i in 0..<shape.length() {
    p *= shape[i]
  }
  p
}

///|
fn flat_index(index : Array[Int], strides : Array[Int]) -> Int {
  let mut idx = 0
  for i in 0..<index.length() {
    idx += index[i] * strides[i]
  }
  idx
}

///|
/// Increment a multi-dimensional index in row-major order.
/// Returns false when the index wraps around (all zeros).
fn next_index(index : Array[Int], dims : Array[Int]) -> Bool {
  let n = index.length()
  let mut i = n - 1
  let mut ok = false
  while i >= 0 && !ok {
    if index[i] + 1 < dims[i] {
      index[i] += 1
      ok = true
    } else {
      index[i] = 0
      i -= 1
    }
  }
  ok
}

///|
/// Prepend an array with ones to the given length.
fn prepend_dims(dims : Array[Int], desired_len : Int) -> Array[Int] {
  let dims_len = dims.length()
  if dims_len >= desired_len {
    return dims
  }
  let result = Array::make(desired_len, 1)
  for i in 0..<dims_len {
    result[desired_len - dims_len + i] = dims[i]
  }
  result
}

///|
/// Compute broadcasted dimensions from two shapes.
/// Returns (ext_a, ext_b, result_shape).
fn get_broadcasted_dims(
  dims_a : Array[Int],
  dims_b : Array[Int],
) -> (Array[Int], Array[Int], Array[Int]) raise {
  let len_c = if dims_a.length() > dims_b.length() {
    dims_a.length()
  } else {
    dims_b.length()
  }
  let ext_a = prepend_dims(dims_a, len_c)
  let ext_b = prepend_dims(dims_b, len_c)
  let dims_c = Array::make(len_c, 0)
  for i in 0..<len_c {
    let val_a = ext_a[i]
    let val_b = ext_b[i]
    if val_a == val_b {
      dims_c[i] = val_a
    } else if val_a != 1 && val_b != 1 {
      raise @types.OwlError::InvalidArgument(
        "arrays cannot be broadcast into the same shape",
      )
    } else {
      dims_c[i] = if val_a > val_b { val_a } else { val_b }
    }
  }
  (ext_a, ext_b, dims_c)
}

///|
/// Map an output index to an input index for broadcasting.
fn get_broadcasted_index(
  index : Array[Int],
  dims : Array[Int],
) -> Array[Int] raise {
  let n = dims.length()
  let result = Array::make(n, 0)
  for i in 0..<n {
    let max_ind = dims[i]
    let ind_val = index[i]
    if ind_val < max_ind {
      result[i] = ind_val
    } else if max_ind == 1 {
      result[i] = 0
    } else {
      raise @types.OwlError::InvalidArgument("not broadcasted correctly")
    }
  }
  result
}

///|
/// Compute reduce params for folding along an axis.
/// Returns (m, n, o, output_shape) where:
/// m = number of slices, n = slice size, o = strides, s = output shape
fn reduce_params(axis : Int, shape : Array[Int]) -> (Int, Int, Int, Array[Int]) {
  let strides = calc_strides(shape)
  let n = shape.length()
  let mut slice_size = 1
  for i in (axis + 1)..<n {
    slice_size *= shape[i]
  }
  let m = _numel_shape(shape) / (shape[axis] * slice_size)
  let o = strides[axis]
  let out_shape = Array::make(n, 1)
  for i in 0..<n {
    if i != axis {
      out_shape[i] = shape[i]
    }
  }
  (m, shape[axis] * slice_size, o, out_shape)
}
