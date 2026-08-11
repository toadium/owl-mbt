///|
/// Number of rows (assumes 2D).
pub fn row_num(x : Ndarray) -> Int {
  x.shape[0]
}

///|
/// Number of columns (assumes 2D).
pub fn col_num(x : Ndarray) -> Int {
  x.shape[1]
}

///|
/// Extract a single row.
pub fn row(x : Ndarray, i : Int) -> Ndarray {
  let cols = x.shape[1]
  let data = FixedArray::make(cols, 0.0)
  for j in 0..<cols {
    data[j] = x.data[i * cols + j]
  }
  { shape: [cols], data }
}

///|
/// Extract multiple rows.
pub fn rows(x : Ndarray, indices : Array[Int]) -> Ndarray {
  let cols = x.shape[1]
  let r = indices.length()
  let data = FixedArray::make(r * cols, 0.0)
  for k in 0..<r {
    for j in 0..<cols {
      data[k * cols + j] = x.data[indices[k] * cols + j]
    }
  }
  { shape: [r, cols], data }
}

///|
/// Extract diagonal.
pub fn diag(x : Ndarray, k? : Int = 0) -> Ndarray {
  let rows = x.shape[0]
  let cols = x.shape[1]
  let kv = k
  let mut n = 0
  if kv >= 0 {
    n = if rows < cols - kv { rows } else { cols - kv }
  } else {
    n = if rows + kv < cols { rows + kv } else { cols }
  }
  if n < 0 {
    n = 0
  }
  let data = FixedArray::make(n, 0.0)
  for i in 0..<n {
    let r = if kv >= 0 { i } else { i - kv }
    let c = if kv >= 0 { i + kv } else { i }
    data[i] = x.data[r * cols + c]
  }
  { shape: [n], data }
}

///|
/// Convert 2D array to array of row ndarrays.
pub fn to_rows(x : Ndarray) -> Array[Ndarray] {
  let r = x.shape[0]
  let c = x.shape[1]
  Array::makei(r, fn(i) {
    let data = FixedArray::make(c, 0.0)
    for j in 0..<c {
      data[j] = x.data[i * c + j]
    }
    { shape: [c], data }
  })
}

///|
/// Convert array of row ndarrays to 2D array.
pub fn of_rows(arrs : Array[Ndarray]) -> Ndarray {
  let r = arrs.length()
  let c = if r > 0 { arrs[0].shape[0] } else { 0 }
  let data = FixedArray::make(r * c, 0.0)
  for i in 0..<r {
    for j in 0..<c {
      data[i * c + j] = arrs[i].data[j]
    }
  }
  { shape: [r, c], data }
}

///|
/// Convert 2D array to array of column ndarrays.
pub fn to_cols(x : Ndarray) -> Array[Ndarray] {
  let r = x.shape[0]
  let c = x.shape[1]
  Array::makei(c, fn(j) {
    let data = FixedArray::make(r, 0.0)
    for i in 0..<r {
      data[i] = x.data[i * c + j]
    }
    { shape: [r], data }
  })
}

///|
/// Convert array of column ndarrays to 2D array.
pub fn of_cols(arrs : Array[Ndarray]) -> Ndarray {
  let c = arrs.length()
  let r = if c > 0 { arrs[0].shape[0] } else { 0 }
  let data = FixedArray::make(r * c, 0.0)
  for j in 0..<c {
    for i in 0..<r {
      data[i * c + j] = arrs[j].data[i]
    }
  }
  { shape: [r, c], data }
}

///|
/// Matrix dot product.
/// For 1D x 1D: scalar (inner product).
/// For 2D x 2D: matrix multiplication.
/// For 1D x 2D: vector-matrix product.
/// For 2D x 1D: matrix-vector product.
pub fn dot(x : Ndarray, y : Ndarray) -> Ndarray raise {
  let ndx = x.shape.length()
  let ndy = y.shape.length()
  match ndx {
    1 =>
      match ndy {
        // inner product
        1 => {
          let n = x.data.length()
          let mut s = 0.0
          for i in 0..<n {
            s += x.data[i] * y.data[i]
          }
          create([1], s)
        }
        // vector @ matrix
        2 => {
          let n = x.data.length()
          let m = y.shape[1]
          let data = FixedArray::make(m, 0.0)
          for j in 0..<m {
            let mut s = 0.0
            for i in 0..<n {
              s += x.data[i] * y.data[i * m + j]
            }
            data[j] = s
          }
          { shape: [m], data }
        }
        _ =>
          raise @types.OwlError::InvalidArgument("dot: unsupported dimensions")
      }
    2 =>
      match ndy {
        // matrix @ vector
        1 => {
          let r = x.shape[0]
          let c = x.shape[1]
          let data = FixedArray::make(r, 0.0)
          for i in 0..<r {
            let mut s = 0.0
            for j in 0..<c {
              s += x.data[i * c + j] * y.data[j]
            }
            data[i] = s
          }
          { shape: [r], data }
        }
        // matrix @ matrix (i-p-j order for cache locality)
        2 => {
          let r = x.shape[0]
          let k = x.shape[1]
          let c = y.shape[1]
          if y.shape[0] != k {
            raise @types.OwlError::InvalidArgument("dot: dimension mismatch")
          }
          let data = FixedArray::make(r * c, 0.0)
          let xd = x.data
          let yd = y.data
          for i in 0..<r {
            let row_off = i * c
            for p in 0..<k {
              let x_ip = xd[i * k + p]
              let y_off = p * c
              for j in 0..<c {
                data[row_off + j] += x_ip * yd[y_off + j]
              }
            }
          }
          { shape: [r, c], data }
        }
        _ =>
          raise @types.OwlError::InvalidArgument("dot: unsupported dimensions")
      }
    _ => raise @types.OwlError::InvalidArgument("dot: unsupported dimensions")
  }
}

///|
/// Trace of a 2D matrix.
pub fn trace(x : Ndarray) -> Double {
  let n = if x.shape[0] < x.shape[1] { x.shape[0] } else { x.shape[1] }
  let c = x.shape[1]
  let mut s = 0.0
  for i in 0..<n {
    s += x.data[i * c + i]
  }
  s
}
