///|
/// Check if a matrix is upper triangular.
pub fn is_triu(x : @ndarray.Ndarray) -> Bool {
  let m = x.shape[0]
  let n = x.shape[1]
  for i in 0..<m {
    for j in 0..<(if i < n { i } else { n }) {
      if x.data[i * n + j] != 0.0 {
        return false
      }
    }
  }
  true
}

///|
/// Check if a matrix is lower triangular.
pub fn is_tril(x : @ndarray.Ndarray) -> Bool {
  let m = x.shape[0]
  let n = x.shape[1]
  for i in 0..<m {
    let start = i + 1
    if start < n {
      for j in start..<n {
        if x.data[i * n + j] != 0.0 {
          return false
        }
      }
    }
  }
  true
}

///|
/// Check if a matrix is symmetric.
pub fn is_symmetric(x : @ndarray.Ndarray) -> Bool {
  let m = x.shape[0]
  let n = x.shape[1]
  if m != n {
    return false
  }
  for i in 0..<n {
    for j in (i + 1)..<n {
      if x.data[i * n + j] != x.data[j * n + i] {
        return false
      }
    }
  }
  true
}

///|
/// Check if a matrix is diagonal.
pub fn is_diag(x : @ndarray.Ndarray) -> Bool {
  is_triu(x) && is_tril(x)
}

///|
/// Trace of a matrix (sum of diagonal elements).
pub fn trace(x : @ndarray.Ndarray) -> Double {
  let m = x.shape[0]
  let n = x.shape[1]
  let k = if m < n { m } else { n }
  let mut s = 0.0
  for i in 0..<k {
    s += x.data[i * n + i]
  }
  s
}

///|
/// LU decomposition with partial pivoting.
/// Returns (L, U, piv) where L*U = A[piv,:].
/// L is lower triangular with unit diagonal, U is upper triangular.
pub fn lu(
  a : @ndarray.Ndarray,
) -> (@ndarray.Ndarray, @ndarray.Ndarray, Array[Int]) raise {
  let n = a.shape[0]
  if a.shape[1] != n {
    raise @types.OwlError::InvalidArgument("lu: matrix must be square")
  }
  let lu_data = FixedArray::make(n * n, 0.0)
  for i in 0..<n {
    for j in 0..<n {
      lu_data[i * n + j] = a.data[i * n + j]
    }
  }
  let indx = Array::make(n, 0)
  let tiny = 1.0e-40
  let vv = Array::make(n, 0.0)
  for i in 0..<n {
    let mut big = 0.0
    for j in 0..<n {
      let temp = lu_data[i * n + j].abs()
      if temp > big {
        big = temp
      }
    }
    if big == 0.0 {
      raise @types.OwlError::InvalidArgument("lu: singular matrix")
    }
    vv[i] = 1.0 / big
  }
  for k in 0..<n {
    let mut big = 0.0
    let mut imax = k
    for i in k..<n {
      let temp = vv[i] * lu_data[i * n + k].abs()
      if temp > big {
        big = temp
        imax = i
      }
    }
    if k != imax {
      for j in 0..<n {
        let temp = lu_data[imax * n + j]
        lu_data[imax * n + j] = lu_data[k * n + j]
        lu_data[k * n + j] = temp
      }
      vv[imax] = vv[k]
    }
    indx[k] = imax
    if lu_data[k * n + k] == 0.0 {
      lu_data[k * n + k] = tiny
    }
    for i in (k + 1)..<n {
      lu_data[i * n + k] /= lu_data[k * n + k]
      let factor = lu_data[i * n + k]
      for j in (k + 1)..<n {
        lu_data[i * n + j] -= factor * lu_data[k * n + j]
      }
    }
  }
  let l_data = FixedArray::make(n * n, 0.0)
  for i in 0..<n {
    l_data[i * n + i] = 1.0
    for j in 0..<i {
      l_data[i * n + j] = lu_data[i * n + j]
      lu_data[i * n + j] = 0.0
    }
  }
  (
    @ndarray.from_data([n, n], l_data),
    @ndarray.from_data([n, n], lu_data),
    indx,
  )
}

///|
/// Determinant via LU decomposition.
pub fn det(a : @ndarray.Ndarray) -> Double raise {
  let n = a.shape[0]
  if a.shape[1] != n {
    raise @types.OwlError::InvalidArgument("det: matrix must be square")
  }
  let lu_data = FixedArray::make(n * n, 0.0)
  for i in 0..<n {
    for j in 0..<n {
      lu_data[i * n + j] = a.data[i * n + j]
    }
  }
  let tiny = 1.0e-40
  let vv = Array::make(n, 0.0)
  for i in 0..<n {
    let mut big = 0.0
    for j in 0..<n {
      let temp = lu_data[i * n + j].abs()
      if temp > big {
        big = temp
      }
    }
    if big == 0.0 {
      return 0.0
    }
    vv[i] = 1.0 / big
  }
  let mut sign = 1.0
  for k in 0..<n {
    let mut big = 0.0
    let mut imax = k
    for i in k..<n {
      let temp = vv[i] * lu_data[i * n + k].abs()
      if temp > big {
        big = temp
        imax = i
      }
    }
    if k != imax {
      for j in 0..<n {
        let temp = lu_data[imax * n + j]
        lu_data[imax * n + j] = lu_data[k * n + j]
        lu_data[k * n + j] = temp
      }
      vv[imax] = vv[k]
      sign = -sign
    }
    if lu_data[k * n + k] == 0.0 {
      lu_data[k * n + k] = tiny
    }
    for i in (k + 1)..<n {
      lu_data[i * n + k] /= lu_data[k * n + k]
      let factor = lu_data[i * n + k]
      for j in (k + 1)..<n {
        lu_data[i * n + j] -= factor * lu_data[k * n + j]
      }
    }
  }
  let mut result = sign
  for i in 0..<n {
    result *= lu_data[i * n + i]
  }
  result
}

///|
/// Log determinant via LU decomposition.
pub fn logdet(a : @ndarray.Ndarray) -> Double raise {
  let n = a.shape[0]
  if a.shape[1] != n {
    raise @types.OwlError::InvalidArgument("logdet: matrix must be square")
  }
  let lu_data = FixedArray::make(n * n, 0.0)
  for i in 0..<n {
    for j in 0..<n {
      lu_data[i * n + j] = a.data[i * n + j]
    }
  }
  let tiny = 1.0e-40
  let vv = Array::make(n, 0.0)
  for i in 0..<n {
    let mut big = 0.0
    for j in 0..<n {
      let temp = lu_data[i * n + j].abs()
      if temp > big {
        big = temp
      }
    }
    if big == 0.0 {
      raise @types.OwlError::InvalidArgument("logdet: singular matrix")
    }
    vv[i] = 1.0 / big
  }
  for k in 0..<n {
    let mut big = 0.0
    let mut imax = k
    for i in k..<n {
      let temp = vv[i] * lu_data[i * n + k].abs()
      if temp > big {
        big = temp
        imax = i
      }
    }
    if k != imax {
      for j in 0..<n {
        let temp = lu_data[imax * n + j]
        lu_data[imax * n + j] = lu_data[k * n + j]
        lu_data[k * n + j] = temp
      }
      vv[imax] = vv[k]
    }
    if lu_data[k * n + k] == 0.0 {
      lu_data[k * n + k] = tiny
    }
    for i in (k + 1)..<n {
      lu_data[i * n + k] /= lu_data[k * n + k]
      let factor = lu_data[i * n + k]
      for j in (k + 1)..<n {
        lu_data[i * n + j] -= factor * lu_data[k * n + j]
      }
    }
  }
  let mut result = 0.0
  for i in 0..<n {
    result += @math.ln(lu_data[i * n + i].abs())
  }
  result
}

///|
/// Matrix inverse via Gauss-Jordan elimination with partial pivoting.
pub fn inv(a : @ndarray.Ndarray) -> @ndarray.Ndarray raise {
  let n = a.shape[0]
  if a.shape[1] != n {
    raise @types.OwlError::InvalidArgument("inv: matrix must be square")
  }
  let aug_data = FixedArray::make(n * 2 * n, 0.0)
  for i in 0..<n {
    for j in 0..<n {
      aug_data[i * (2 * n) + j] = a.data[i * n + j]
    }
    aug_data[i * (2 * n) + n + i] = 1.0
  }
  let col_size = 2 * n
  for col in 0..<n {
    let mut max_row = col
    let mut max_val = aug_data[col * col_size + col].abs()
    for row in (col + 1)..<n {
      let val = aug_data[row * col_size + col].abs()
      if val > max_val {
        max_val = val
        max_row = row
      }
    }
    if max_val < 1.0e-300 {
      raise @types.OwlError::InvalidArgument("inv: singular matrix")
    }
    if max_row != col {
      for j in 0..<col_size {
        let temp = aug_data[col * col_size + j]
        aug_data[col * col_size + j] = aug_data[max_row * col_size + j]
        aug_data[max_row * col_size + j] = temp
      }
    }
    let pivot = aug_data[col * col_size + col]
    for j in 0..<col_size {
      aug_data[col * col_size + j] /= pivot
    }
    for row in 0..<n {
      if row != col {
        let factor = aug_data[row * col_size + col]
        for j in 0..<col_size {
          aug_data[row * col_size + j] -= factor * aug_data[col * col_size + j]
        }
      }
    }
  }
  let inv_data = FixedArray::make(n * n, 0.0)
  for i in 0..<n {
    for j in 0..<n {
      inv_data[i * n + j] = aug_data[i * col_size + n + j]
    }
  }
  @ndarray.from_data([n, n], inv_data)
}

///|
/// Solve Ax = b using LU decomposition.
/// a: n×n matrix, b: n×m matrix (m columns of right-hand sides).
/// Returns x: n×m solution matrix.
pub fn linsolve_lu(
  a : @ndarray.Ndarray,
  b : @ndarray.Ndarray,
) -> @ndarray.Ndarray raise {
  let n = a.shape[0]
  if a.shape[1] != n {
    raise @types.OwlError::InvalidArgument("linsolve_lu: A must be square")
  }
  if b.shape[0] != n {
    raise @types.OwlError::InvalidArgument("linsolve_lu: dimension mismatch")
  }
  let m = b.shape[1]
  let lu_data = FixedArray::make(n * n, 0.0)
  for i in 0..<n {
    for j in 0..<n {
      lu_data[i * n + j] = a.data[i * n + j]
    }
  }
  let indx = Array::make(n, 0)
  let tiny = 1.0e-40
  let vv = Array::make(n, 0.0)
  for i in 0..<n {
    let mut big = 0.0
    for j in 0..<n {
      let temp = lu_data[i * n + j].abs()
      if temp > big {
        big = temp
      }
    }
    if big == 0.0 {
      raise @types.OwlError::InvalidArgument("linsolve_lu: singular matrix")
    }
    vv[i] = 1.0 / big
  }
  for k in 0..<n {
    let mut big = 0.0
    let mut imax = k
    for i in k..<n {
      let temp = vv[i] * lu_data[i * n + k].abs()
      if temp > big {
        big = temp
        imax = i
      }
    }
    if k != imax {
      for j in 0..<n {
        let temp = lu_data[imax * n + j]
        lu_data[imax * n + j] = lu_data[k * n + j]
        lu_data[k * n + j] = temp
      }
      vv[imax] = vv[k]
    }
    indx[k] = imax
    if lu_data[k * n + k] == 0.0 {
      lu_data[k * n + k] = tiny
    }
    for i in (k + 1)..<n {
      lu_data[i * n + k] /= lu_data[k * n + k]
      let factor = lu_data[i * n + k]
      for j in (k + 1)..<n {
        lu_data[i * n + j] -= factor * lu_data[k * n + j]
      }
    }
  }
  let x_data = FixedArray::make(n * m, 0.0)
  for col in 0..<m {
    let b_col = Array::make(n, 0.0)
    for i in 0..<n {
      b_col[i] = b.data[i * m + col]
    }
    let x_col = Array::make(n, 0.0)
    for i in 0..<n {
      x_col[i] = b_col[i]
    }
    let mut ii = -1
    for i in 0..<n {
      let ip = indx[i]
      let mut sum = x_col[ip]
      x_col[ip] = x_col[i]
      if ii >= 0 {
        for j in ii..<i {
          sum -= lu_data[i * n + j] * x_col[j]
        }
      } else if sum != 0.0 {
        ii = i
      }
      x_col[i] = sum
    }
    let mut i = n - 1
    while i >= 0 {
      let mut sum = x_col[i]
      for j in (i + 1)..<n {
        sum -= lu_data[i * n + j] * x_col[j]
      }
      x_col[i] = sum / lu_data[i * n + i]
      i -= 1
    }
    for i in 0..<n {
      x_data[i * m + col] = x_col[i]
    }
  }
  @ndarray.from_data([n, m], x_data)
}

///|
/// Cholesky decomposition: A = L * L^T for symmetric positive definite A.
/// Returns lower triangular L.
pub fn chol(
  a : @ndarray.Ndarray,
  upper? : Bool = false,
) -> @ndarray.Ndarray raise {
  let n = a.shape[0]
  if a.shape[1] != n {
    raise @types.OwlError::InvalidArgument("chol: matrix must be square")
  }
  let l_data = FixedArray::make(n * n, 0.0)
  for i in 0..<n {
    for j in 0..<=i {
      let mut sum = a.data[i * n + j]
      for k in 0..<j {
        sum -= l_data[i * n + k] * l_data[j * n + k]
      }
      if i == j {
        if sum <= 0.0 {
          raise @types.OwlError::InvalidArgument(
            "chol: matrix is not positive definite",
          )
        }
        l_data[i * n + j] = sum.sqrt()
      } else {
        l_data[i * n + j] = sum / l_data[j * n + j]
      }
    }
  }
  if upper {
    let u_data = FixedArray::make(n * n, 0.0)
    for i in 0..<n {
      for j in i..<n {
        u_data[i * n + j] = l_data[j * n + i]
      }
    }
    @ndarray.from_data([n, n], u_data)
  } else {
    @ndarray.from_data([n, n], l_data)
  }
}

///|
/// QR decomposition via Householder reflections.
/// Returns (Q, R) where A = Q * R.
/// Q is orthogonal, R is upper triangular.
pub fn qr(
  a : @ndarray.Ndarray,
  thin? : Bool = false,
) -> (@ndarray.Ndarray, @ndarray.Ndarray) {
  let m = a.shape[0]
  let n = a.shape[1]
  let r_data = FixedArray::make(m * n, 0.0)
  for i in 0..<m {
    for j in 0..<n {
      r_data[i * n + j] = a.data[i * n + j]
    }
  }
  let q_data = FixedArray::make(m * m, 0.0)
  for i in 0..<m {
    q_data[i * m + i] = 1.0
  }
  let k_max = if m < n { m } else { n }
  let _ = thin
  for k in 0..<k_max {
    let mut norm = 0.0
    for i in k..<m {
      norm += r_data[i * n + k] * r_data[i * n + k]
    }
    norm = norm.sqrt()
    if norm == 0.0 {
      continue
    }
    let alpha = if r_data[k * n + k] >= 0.0 { -norm } else { norm }
    let v = Array::make(m, 0.0)
    v[k] = r_data[k * n + k] - alpha
    for i in (k + 1)..<m {
      v[i] = r_data[i * n + k]
    }
    let mut v_norm_sqr = 0.0
    for i in k..<m {
      v_norm_sqr += v[i] * v[i]
    }
    if v_norm_sqr == 0.0 {
      continue
    }
    let beta = 2.0 / v_norm_sqr
    for j in k..<n {
      let mut dot = 0.0
      for i in k..<m {
        dot += v[i] * r_data[i * n + j]
      }
      dot *= beta
      for i in k..<m {
        r_data[i * n + j] -= dot * v[i]
      }
    }
    for j in 0..<m {
      let mut dot = 0.0
      for i in k..<m {
        dot += v[i] * q_data[j * m + i]
      }
      dot *= beta
      for i in k..<m {
        q_data[j * m + i] -= dot * v[i]
      }
    }
  }
  let q_result = FixedArray::make(m * m, 0.0)
  for i in 0..<m {
    for j in 0..<m {
      q_result[i * m + j] = q_data[i * m + j]
    }
  }
  (@ndarray.from_data([m, m], q_result), @ndarray.from_data([m, n], r_data))
}

///|
/// Matrix rank via QR decomposition.
pub fn rank(a : @ndarray.Ndarray, tol? : Double = -1.0) -> Int {
  let m = a.shape[0]
  let n = a.shape[1]
  let (_, r) = qr(a)
  let k = if m < n { m } else { n }
  let threshold = if tol > 0.0 {
    tol
  } else {
    let mut max_diag = 0.0
    for i in 0..<k {
      let val = r.data[i * n + i].abs()
      if val > max_diag {
        max_diag = val
      }
    }
    max_diag * (if m > n { m } else { n }).to_double() * 2.2e-16
  }
  let mut r_count = 0
  for i in 0..<k {
    if r.data[i * n + i].abs() > threshold {
      r_count += 1
    }
  }
  r_count
}

///|
/// Solve tridiagonal system using Thomas algorithm.
/// a: subdiagonal (a[0] unused), b: diagonal, c: superdiagonal (c[n-1] unused), r: rhs.
/// Returns solution vector x.
pub fn tridiag_solve(
  a : Array[Double],
  b : Array[Double],
  c : Array[Double],
  r : Array[Double],
) -> Array[Double] raise {
  let n = b.length()
  let x = Array::make(n, 0.0)
  let gam = Array::make(n, 0.0)
  let mut bet = b[0]
  if bet == 0.0 {
    raise @types.OwlError::InvalidArgument("tridiag_solve: zero pivot")
  }
  x[0] = r[0] / bet
  for j in 1..<n {
    gam[j] = c[j - 1] / bet
    bet = b[j] - a[j] * gam[j]
    if bet == 0.0 {
      raise @types.OwlError::InvalidArgument("tridiag_solve: zero pivot")
    }
    x[j] = (r[j] - a[j] * x[j - 1]) / bet
  }
  let mut j = n - 2
  while j >= 0 {
    x[j] -= gam[j + 1] * x[j + 1]
    j -= 1
  }
  x
}
