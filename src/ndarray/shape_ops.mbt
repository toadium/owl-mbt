///|
/// Reshape an ndarray. Supports -1 for inferred dimension.
pub fn reshape(x : Ndarray, new_shape : Array[Int]) -> Ndarray raise {
  let minus_one_count = new_shape.iter().filter(fn(v) { v == -1 }).length()
  if minus_one_count > 1 {
    raise @types.OwlError::InvalidArgument(
      "can only specify one unknown dimension",
    )
  }
  let n = numel(x)
  let shape = if minus_one_count == 0 {
    new_shape.copy()
  } else {
    let mut product = 1
    for v in new_shape {
      if v != -1 {
        product *= v
      }
    }
    new_shape.copy().map(fn(v) { if v == -1 { n / product } else { v } })
  }
  { shape, data: x.data.copy() }
}

///|
/// Flatten to 1D array.
pub fn flatten(x : Ndarray) -> Ndarray {
  { shape: [x.data.length()], data: x.data.copy() }
}

///|
/// Reverse element order.
pub fn reverse(x : Ndarray) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n, 0.0)
  for i in 0..<n {
    data[i] = x.data[n - 1 - i]
  }
  { shape: x.shape.copy(), data }
}

///|
/// Squeeze dimensions of size 1. If axis is given, only squeeze those axes.
pub fn squeeze(x : Ndarray, axis? : Array[Int] = []) -> Ndarray {
  let ax = axis
  let new_shape = if ax.length() == 0 {
    x.shape.iter().filter(fn(v) { v != 1 }).to_array()
  } else {
    let result = []
    for i in 0..<x.shape.length() {
      if !ax.contains(i) {
        result.push(x.shape[i])
      }
    }
    result
  }
  { shape: new_shape, data: x.data.copy() }
}

///|
/// Expand dims by adding a dimension of size 1.
/// If hi=true, append at end; otherwise prepend at beginning.
/// Note: _d parameter is currently ignored; dimension is always added
/// at head (hi=false) or tail (hi=true).
pub fn expand(x : Ndarray, _d : Int, hi? : Bool = false) -> Ndarray {
  let new_shape = if hi {
    let s = x.shape.copy()
    s.push(1)
    s
  } else {
    [1] + x.shape
  }
  { shape: new_shape, data: x.data.copy() }
}

///|
/// Transpose (reverse all axes). For 2D this is matrix transpose.
pub fn transpose(x : Ndarray, axis? : Array[Int] = []) -> Ndarray {
  let n = x.shape.length()
  // Fast path: 2D transpose (most common case)
  if n == 2 && axis.length() == 0 {
    let r = x.shape[0]
    let c = x.shape[1]
    let data = FixedArray::make(r * c, 0.0)
    let xd = x.data
    for i in 0..<r {
      for j in 0..<c {
        data[j * r + i] = xd[i * c + j]
      }
    }
    return { shape: [c, r], data }
  }
  let perm = if axis.length() == 0 {
    Array::makei(n, fn(i) { n - 1 - i })
  } else {
    axis
  }
  let new_shape = Array::makei(n, fn(i) { x.shape[perm[i]] })
  let old_strides = calc_strides(x.shape)
  let new_strides = calc_strides(new_shape)
  let total = _numel_shape(x.shape)
  let data = FixedArray::make(total, 0.0)
  let old_idx = Array::make(n, 0)
  // Pre-allocate new_idx to avoid per-iteration allocation
  let new_idx = Array::make(n, 0)
  let mut should_stop = false
  while !should_stop {
    for i in 0..<n {
      new_idx[i] = old_idx[perm[i]]
    }
    let old_flat = flat_index(old_idx, old_strides)
    let new_flat = flat_index(new_idx, new_strides)
    data[new_flat] = x.data[old_flat]
    if !next_index(old_idx, x.shape) {
      should_stop = true
    }
  }
  { shape: new_shape, data }
}

///|
/// Concatenate arrays along an axis.
pub fn concatenate(arrs : Array[Ndarray], axis? : Int = 0) -> Ndarray raise {
  let ax = axis
  if arrs.length() == 0 {
    raise @types.OwlError::InvalidArgument("cannot concatenate empty array")
  }
  let n_dims = arrs[0].shape.length()
  let new_shape = arrs[0].shape.copy()
  let mut total_along_axis = 0
  for arr in arrs {
    total_along_axis += arr.shape[ax]
  }
  new_shape[ax] = total_along_axis
  let total = _numel_shape(new_shape)
  let data = FixedArray::make(total, 0.0)
  let new_strides = calc_strides(new_shape)
  let mut offset = 0
  for arr in arrs {
    let arr_strides = calc_strides(arr.shape)
    let arr_idx = Array::make(n_dims, 0)
    // Pre-allocate out_idx and reuse
    let out_idx = Array::make(n_dims, 0)
    let mut should_stop = false
    while !should_stop {
      for i in 0..<n_dims {
        out_idx[i] = arr_idx[i]
      }
      out_idx[ax] += offset
      let arr_flat = flat_index(arr_idx, arr_strides)
      let out_flat = flat_index(out_idx, new_strides)
      data[out_flat] = arr.data[arr_flat]
      if !next_index(arr_idx, arr.shape) {
        should_stop = true
      }
    }
    offset += arr.shape[ax]
  }
  { shape: new_shape, data }
}

///|
/// Stack arrays along a new axis.
pub fn stack(arrs : Array[Ndarray], axis? : Int = 0) -> Ndarray raise {
  let ax = axis
  if arrs.length() == 0 {
    raise @types.OwlError::InvalidArgument("cannot stack empty array")
  }
  let n_dims = arrs[0].shape.length()
  let new_shape = Array::make(n_dims + 1, 1)
  let insert_pos = if ax < 0 { n_dims + 1 + ax } else { ax }
  new_shape[insert_pos] = arrs.length()
  for i in 0..<n_dims {
    let target = if i < insert_pos { i } else { i + 1 }
    new_shape[target] = arrs[0].shape[i]
  }
  let total = _numel_shape(new_shape)
  let data = FixedArray::make(total, 0.0)
  let new_strides = calc_strides(new_shape)
  for k in 0..<arrs.length() {
    let arr = arrs[k]
    let arr_strides = calc_strides(arr.shape)
    let arr_idx = Array::make(n_dims, 0)
    // Pre-allocate out_idx and reuse
    let out_idx = Array::make(n_dims + 1, 0)
    out_idx[insert_pos] = k
    let mut should_stop = false
    while !should_stop {
      for i in 0..<n_dims {
        let target = if i < insert_pos { i } else { i + 1 }
        out_idx[target] = arr_idx[i]
      }
      let arr_flat = flat_index(arr_idx, arr_strides)
      let out_flat = flat_index(out_idx, new_strides)
      data[out_flat] = arr.data[arr_flat]
      if !next_index(arr_idx, arr.shape) {
        should_stop = true
      }
    }
  }
  { shape: new_shape, data }
}

///|
/// Tile an ndarray by repeating along each dimension.
pub fn tile(x : Ndarray, reps : Array[Int]) -> Ndarray {
  let n = x.shape.length()
  let new_shape = Array::make(n, 0)
  for i in 0..<n {
    new_shape[i] = x.shape[i] * reps[i]
  }
  let total = _numel_shape(new_shape)
  let data = FixedArray::make(total, 0.0)
  let new_strides = calc_strides(new_shape)
  let old_strides = calc_strides(x.shape)
  let out_idx = Array::make(n, 0)
  // Pre-allocate old_idx to avoid per-iteration allocation
  let old_idx = Array::make(n, 0)
  let mut should_stop = false
  while !should_stop {
    for i in 0..<n {
      old_idx[i] = out_idx[i] % x.shape[i]
    }
    let old_flat = flat_index(old_idx, old_strides)
    let out_flat = flat_index(out_idx, new_strides)
    data[out_flat] = x.data[old_flat]
    if !next_index(out_idx, new_shape) {
      should_stop = true
    }
  }
  { shape: new_shape, data }
}

///|
/// Repeat elements along each dimension.
pub fn repeat(x : Ndarray, reps : Array[Int]) -> Ndarray {
  let n = x.shape.length()
  let new_shape = Array::make(n, 0)
  for i in 0..<n {
    new_shape[i] = x.shape[i] * reps[i]
  }
  let total = _numel_shape(new_shape)
  let data = FixedArray::make(total, 0.0)
  let new_strides = calc_strides(new_shape)
  let old_strides = calc_strides(x.shape)
  let out_idx = Array::make(n, 0)
  // Pre-allocate old_idx to avoid per-iteration allocation
  let old_idx = Array::make(n, 0)
  let mut should_stop = false
  while !should_stop {
    for i in 0..<n {
      old_idx[i] = out_idx[i] / reps[i]
    }
    let old_flat = flat_index(old_idx, old_strides)
    let out_flat = flat_index(out_idx, new_strides)
    data[out_flat] = x.data[old_flat]
    if !next_index(out_idx, new_shape) {
      should_stop = true
    }
  }
  { shape: new_shape, data }
}
