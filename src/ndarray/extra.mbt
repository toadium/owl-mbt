///|
/// Copy x into out (in-place). out must have same shape as x.
pub fn copy_(out : Ndarray, x : Ndarray) -> Unit raise {
  if out.data.length() != x.data.length() {
    raise @types.OwlError::InvalidArgument("copy_: size mismatch")
  }
  for i in 0..<x.data.length() {
    out.data[i] = x.data[i]
  }
}

///|
/// Copy a vector into a specific row of a 2D matrix.
pub fn copy_row_to(vec : Ndarray, mat : Ndarray, ind : Int) -> Unit raise {
  let cols = mat.shape[1]
  if vec.data.length() != cols {
    raise @types.OwlError::InvalidArgument(
      "copy_row_to: vector length mismatch",
    )
  }
  for j in 0..<cols {
    mat.data[ind * cols + j] = vec.data[j]
  }
}

///|
/// Copy a vector into a specific column of a 2D matrix.
pub fn copy_col_to(vec : Ndarray, mat : Ndarray, ind : Int) -> Unit raise {
  let rows = mat.shape[0]
  let cols = mat.shape[1]
  if vec.data.length() != rows {
    raise @types.OwlError::InvalidArgument(
      "copy_col_to: vector length mismatch",
    )
  }
  for i in 0..<rows {
    mat.data[i * cols + ind] = vec.data[i]
  }
}

///|
/// Pad an ndarray with a value along each dimension.
/// padding: Array of [before, after] pairs for each dimension.
/// If a dimension's pair is empty, no padding is applied.
pub fn pad(
  x : Ndarray,
  padding : Array[Array[Int]],
  v? : Double = 0.0,
) -> Ndarray {
  let s0 = x.shape
  let n = s0.length()
  let expanded = Array::makei(n, fn(i) {
    if i < padding.length() {
      let p = padding[i]
      if p.length() == 0 {
        [0, 0]
      } else if p.length() == 1 {
        [p[0], p[0]]
      } else {
        [p[0], p[1]]
      }
    } else {
      [0, 0]
    }
  })
  let s1 = Array::makei(n, fn(i) { s0[i] + expanded[i][0] + expanded[i][1] })
  let total = _numel_shape(s1)
  let data = FixedArray::make(total, v)
  let x_strides = calc_strides(s0)
  let out_strides = calc_strides(s1)
  let x_idx = Array::make(n, 0)
  let out_idx = Array::makei(n, fn(i) { expanded[i][0] })
  let mut should_stop = false
  while !should_stop {
    let src_flat = flat_index(x_idx, x_strides)
    let dst_flat = flat_index(out_idx, out_strides)
    data[dst_flat] = x.data[src_flat]
    if !next_index(x_idx, s0) {
      should_stop = true
    } else {
      for i in 0..<n {
        out_idx[i] = x_idx[i] + expanded[i][0]
      }
    }
  }
  { shape: s1, data }
}

///|
/// Split an ndarray along an axis into parts of given sizes.
pub fn split(
  x : Ndarray,
  parts : Array[Int],
  axis? : Int = 0,
) -> Array[Ndarray] {
  let dims = x.shape
  let rank = dims.length()
  let mut pos = 0
  Array::makei(parts.length(), fn(k) {
    let start = pos
    pos += parts[k]
    let stop = pos - 1
    let index_list = Array::makei(rank, fn(i) {
      if i == axis {
        [start, stop]
      } else {
        []
      }
    })
    get_slice(index_list, x)
  })
}

///|
/// Draw n random slices along an axis.
/// Returns (drawn_array, original_indices).
pub fn draw(x : Ndarray, count : Int, axis? : Int = 0) -> (Ndarray, Array[Int]) {
  let dims = x.shape
  let rank = dims.length()
  let dim_axis = dims[axis]
  let rng = @random.Rand::chacha8()
  let indices = Array::make(count, 0)
  for i in 0..<count {
    indices[i] = rng.int(limit=dim_axis)
  }
  let index_list = Array::makei(rank, fn(i) {
    if i == axis {
      indices.copy()
    } else {
      []
    }
  })
  (get_slice(index_list, x), indices)
}

///|
/// One-hot encoding. depth: number of classes.
/// Input: 1D array of integer-valued indices. Output: 2D array of shape (len, depth).
pub fn one_hot(depth : Int, x : Ndarray) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n * depth, 0.0)
  for i in 0..<n {
    let idx = x.data[i].to_int()
    if idx >= 0 && idx < depth {
      data[i * depth + idx] = 1.0
    }
  }
  { shape: [n, depth], data }
}

///|
/// Sum reduce along multiple axes.
pub fn sum_reduce(x : Ndarray, axis? : Array[Int] = []) -> Ndarray {
  if axis.length() == 0 {
    return create(Array::make(x.shape.length(), 1), sum_(x))
  }
  let mut result = x
  let sorted_axes = axis.copy()
  sorted_axes.sort()
  for ax in sorted_axes.rev_iter() {
    result = sum(result, axis=ax, keep_dims=true)
  }
  result
}

///|
/// Format a double for printing.
fn _format_double(v : Double) -> String {
  if v == 0.0 {
    "0"
  } else if v.is_nan() {
    "nan"
  } else if v.is_inf() {
    if v > 0.0 {
      "inf"
    } else {
      "-inf"
    }
  } else {
    let s = v.to_string()
    if s.contains("e") || s.contains("E") {
      s
    } else if s.contains(".") {
      s
    } else {
      s + "."
    }
  }
}

///|
/// Print an ndarray to a string.
/// For 1D: [v0; v1; ...; vn]
/// For 2D: matrix format with rows
/// For nD: nested structure
pub fn to_string(
  x : Ndarray,
  max_row? : Int = -1,
  max_col? : Int = -1,
) -> String {
  let dims = x.shape
  let rank = dims.length()
  if rank == 0 {
    return _format_double(x.data[0])
  }
  if rank == 1 {
    let n = dims[0]
    let limit = if max_col > 0 && max_col < n { max_col } else { n }
    let mut s = "["
    for i in 0..<limit {
      if i > 0 {
        s += "; "
      }
      s += _format_double(x.data[i])
    }
    if limit < n {
      s += "; ... "
    }
    s + "]"
  } else if rank == 2 {
    let rows = dims[0]
    let cols = dims[1]
    let row_limit = if max_row > 0 && max_row < rows { max_row } else { rows }
    let col_limit = if max_col > 0 && max_col < cols { max_col } else { cols }
    let mut s = "["
    for i in 0..<row_limit {
      if i > 0 {
        s += "; "
      }
      s += "["
      for j in 0..<col_limit {
        if j > 0 {
          s += "; "
        }
        s += _format_double(x.data[i * cols + j])
      }
      if col_limit < cols {
        s += "; ... "
      }
      s += "]"
    }
    if row_limit < rows {
      s += "; ... "
    }
    s + "]"
  } else {
    let n = _numel_shape(dims)
    let strides = calc_strides(dims)
    let idx = Array::make(rank, 0)
    let mut s = "["
    let mut first = true
    for _ in 0..<n {
      if !first {
        s += "; "
      }
      first = false
      let flat = flat_index(idx, strides)
      s += _format_double(x.data[flat])
      ignore(next_index(idx, dims))
    }
    s + "]"
  }
}

///|
/// Print an ndarray to stdout.
pub fn print(x : Ndarray, max_row? : Int = -1, max_col? : Int = -1) -> Unit {
  println(to_string(x, max_row~, max_col~))
}
