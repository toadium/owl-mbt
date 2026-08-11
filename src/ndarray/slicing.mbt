///|
/// Expand a slice definition into explicit indices.
/// spec: [] = all, [start] = single, [start; stop] = range, [start; stop; step] = strided range
fn _enumerate_slice_def(dim : Int, spec : Array[Int]) -> Array[Int] {
  if spec.length() == 0 {
    return Array::makei(dim, fn(i) { i })
  }
  let start = if spec[0] < 0 { dim + spec[0] } else { spec[0] }
  if spec.length() == 1 {
    return [start]
  }
  let stop = if spec[1] < 0 { dim + spec[1] } else { spec[1] }
  let step = if spec.length() >= 3 {
    spec[2]
  } else if start <= stop {
    1
  } else {
    -1
  }
  if step == 0 {
    abort("_enumerate_slice_def: step cannot be zero")
  }
  let step_abs = if step < 0 { -step } else { step }
  let diff = if stop - start < 0 { start - stop } else { stop - start }
  let len = (diff + step_abs) / step_abs
  Array::makei(len, fn(i) { start + i * step })
}

///|
/// Expand slice index list into explicit index arrays for each dimension.
fn _expand_slice_indices(
  index_list : Array[Array[Int]],
  dims : Array[Int],
) -> Array[Array[Int]] {
  let rank = dims.length()
  let sdef_len = index_list.length()
  let specified = Array::makei(sdef_len, fn(i) {
    _enumerate_slice_def(dims[i], index_list[i])
  })
  let rest = Array::makei(rank - sdef_len, fn(p) {
    Array::makei(dims[p + sdef_len], fn(i) { i })
  })
  specified + rest
}

///|
/// Get a slice of the ndarray.
/// index_list: each sub-array specifies indices for that dimension:
///   [] = all, [start] = single, [start; stop] = range, [start; stop; step] = strided range
pub fn get_slice(index_list : Array[Array[Int]], x : Ndarray) -> Ndarray {
  let dims = x.shape
  let rank = dims.length()
  let index_array = _expand_slice_indices(index_list, dims)
  let slice_dims = Array::makei(rank, fn(i) { index_array[i].length() })
  let total = _numel_shape(slice_dims)
  let data = FixedArray::make(total, 0.0)
  let x_strides = calc_strides(dims)
  let slice_strides = calc_strides(slice_dims)
  let slice_ind = Array::make(rank, 0)
  let original_ind = Array::make(rank, 0)
  let mut should_stop = false
  while !should_stop {
    for i in 0..<rank {
      original_ind[i] = index_array[i][slice_ind[i]]
    }
    let src_flat = flat_index(original_ind, x_strides)
    let dst_flat = flat_index(slice_ind, slice_strides)
    data[dst_flat] = x.data[src_flat]
    if !next_index(slice_ind, slice_dims) {
      should_stop = true
    }
  }
  { shape: slice_dims, data }
}

///|
/// Set a slice of the ndarray from another ndarray.
pub fn set_slice(
  index_list : Array[Array[Int]],
  x : Ndarray,
  slice_varr : Ndarray,
) -> Ndarray raise {
  let dims = x.shape
  let rank = dims.length()
  let index_array = _expand_slice_indices(index_list, dims)
  let slice_dims = Array::makei(rank, fn(i) { index_array[i].length() })
  let reshaped = reshape(slice_varr, slice_dims)
  let x_strides = calc_strides(dims)
  let slice_strides = calc_strides(slice_dims)
  let slice_ind = Array::make(rank, 0)
  let original_ind = Array::make(rank, 0)
  let mut should_stop = false
  while !should_stop {
    for i in 0..<rank {
      original_ind[i] = index_array[i][slice_ind[i]]
    }
    let dst_flat = flat_index(original_ind, x_strides)
    let src_flat = flat_index(slice_ind, slice_strides)
    x.data[dst_flat] = reshaped.data[src_flat]
    if !next_index(slice_ind, slice_dims) {
      should_stop = true
    }
  }
  x
}
