///|
/// SVD：单边 Jacobi（Hestenes）方法。
/// 原项目 owl-base 的 svd 为 NOT_IMPLEMENTED 占位，本实现为自行编写。
/// 返回 thin SVD：A ≈ U·diag(S)·Vᵀ，S 降序。
/// m >= n：U 为 m×n（列正交）、S 为 n、V 为 n×n；
/// m < n：对 Aᵀ 分解后交换角色，U 为 m×m、S 为 m、V 为 n×m。

///|
/// 单边 Jacobi 收敛阈值
let _svd_eps : Double = 1.0e-14

///|
/// Jacobi 扫描轮数上限
let _svd_max_sweeps : Int32 = 60

///|
/// 奇异值分解。
/// 输入必须是二维矩阵；返回 (U, S, V)：U 列正交（m×min(m,n)）、
/// S 一维奇异值（降序，长度 min(m,n)）、V 列正交（n×min(m,n)），
/// 满足 A ≈ U · diag(S) · Vᵀ。
pub fn svd(
  x : @ndarray.Ndarray,
) -> (@ndarray.Ndarray, @ndarray.Ndarray, @ndarray.Ndarray) raise {
  if x.shape.length() != 2 {
    raise @core.OwlError::InvalidArgument("svd: input must be 2-dimensional")
  }
  let m = x.shape[0]
  let n = x.shape[1]
  if m < 1 || n < 1 {
    raise @core.OwlError::InvalidArgument("svd: matrix must be non-empty")
  }
  if m >= n {
    let (u, s, v) = _svd_core(x.data, m, n)
    (
      @ndarray.from_data([m, n], u),
      @ndarray.from_data([n], s),
      @ndarray.from_data([n, n], v),
    )
  } else {
    // Aᵀ (n×m) = U'·diag(S)·V'ᵀ  =>  A (m×n) = V'·diag(S)·U'ᵀ
    let at = FixedArray::make(m * n, 0.0)
    for i in 0..<m {
      for j in 0..<n {
        at[j * m + i] = x.data[i * n + j]
      }
    }
    let (up, s, vp) = _svd_core(at, n, m)
    (
      @ndarray.from_data([m, m], vp),
      @ndarray.from_data([m], s),
      @ndarray.from_data([n, m], up),
    )
  }
}

///|
/// 单边 Jacobi 核心（m >= n）：返回 (u m×n 列正交, s n 降序, v n×n)。
fn _svd_core(
  a : FixedArray[Double],
  m : Int32,
  n : Int32,
) -> (FixedArray[Double], FixedArray[Double], FixedArray[Double]) {
  let mn = m * n
  let u = FixedArray::make(mn, 0.0)
  for i in 0..<mn {
    u[i] = a[i]
  }
  let nn = n * n
  let v = FixedArray::make(nn, 0.0)
  for i in 0..<n {
    v[i * n + i] = 1.0
  }
  for _sweep in 0..<_svd_max_sweeps {
    let mut converged = true
    for p in 0..<(n - 1) {
      for q in (p + 1)..<n {
        let mut alpha = 0.0
        let mut beta = 0.0
        let mut gamma = 0.0
        for k in 0..<m {
          let kp = k * n + p
          let kq = k * n + q
          let up = u[kp]
          let uq = u[kq]
          alpha += up * up
          beta += uq * uq
          gamma += up * uq
        }
        if alpha < 1.0e-300 || beta < 1.0e-300 {
          continue
        }
        if gamma.abs() > _svd_eps * (alpha * beta).sqrt() {
          converged = false
          let zeta = (beta - alpha) / (2.0 * gamma)
          let denom = zeta.abs() + (1.0 + zeta * zeta).sqrt()
          let t = (if zeta >= 0.0 { 1.0 } else { -1.0 }) / denom
          let c = 1.0 / (1.0 + t * t).sqrt()
          let s = c * t
          for k in 0..<m {
            let kp = k * n + p
            let kq = k * n + q
            let up = u[kp]
            let uq = u[kq]
            u[kp] = c * up - s * uq
            u[kq] = s * up + c * uq
          }
          for k in 0..<n {
            let kp = k * n + p
            let kq = k * n + q
            let vp = v[kp]
            let vq = v[kq]
            v[kp] = c * vp - s * vq
            v[kq] = s * vp + c * vq
          }
        }
      }
    }
    if converged {
      break
    }
  }
  // 奇异值 = 列范数
  let s = FixedArray::make(n, 0.0)
  for j in 0..<n {
    let mut norm = 0.0
    for k in 0..<m {
      let kj = k * n + j
      norm += u[kj] * u[kj]
    }
    s[j] = norm.sqrt()
  }
  // 奇异值降序排序（选择排序），同步重排 U/V 列
  for i in 0..<n {
    let mut max_i = i
    for j in (i + 1)..<n {
      if s[j] > s[max_i] {
        max_i = j
      }
    }
    if max_i != i {
      let tmp = s[i]
      s[i] = s[max_i]
      s[max_i] = tmp
      for k in 0..<m {
        let ki = k * n + i
        let km = k * n + max_i
        let tmp2 = u[ki]
        u[ki] = u[km]
        u[km] = tmp2
      }
      for k in 0..<n {
        let ki = k * n + i
        let km = k * n + max_i
        let tmp3 = v[ki]
        v[ki] = v[km]
        v[km] = tmp3
      }
    }
  }
  // U 列归一化（sigma > 0）；零奇异值列保持为零向量
  for j in 0..<n {
    let sj = s[j]
    if sj > 0.0 {
      for k in 0..<m {
        let kj = k * n + j
        u[kj] = u[kj] / sj
      }
    }
  }
  (u, s, v)
}
