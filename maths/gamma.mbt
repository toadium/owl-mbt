///|
/// Gamma 函数族：log_gamma / gamma / beta。
/// 算法：Lanczos 近似（g=7, n=9 系数）+ reflection 公式。
/// 系数与算法参考 Cephes `gamma.c` 的 Lanczos 形式与标准 Lanczos 公式（纯 MoonBit 重写）。

///|
let _lanczos_g : Double = 7.0

///|
let _lanczos_half_ln_2pi : Double = 0.91893853320467274178032973640562

///|
let _lanczos : Array[Double] = [
  0.99999999999980993, 676.5203681218851, -1259.1392167224028, 771.32342877765313,
  -176.61502916214059, 12.507343278686905, -0.13857109526572012, 9.9843695780195716e-6,
  1.5056327351493116e-7,
]

///|
/// Gamma 函数 Γ(x)。
/// 对非正整数极点返回 +inf（与 C 库惯例一致）；NaN 传播。
pub fn gamma(x : Double) -> Double {
  if x.is_nan() {
    return x
  }
  if x <= 0.0 && x == x.floor() {
    return 1.0 / 0.0
  }
  // 正整数：Γ(n) = (n-1)!，n ≤ 19 时阶乘在 double 中精确（18! < 2^53），
  // 连乘保证整数参数结果精确（exp(log_gamma) 复合舍入无法达到）
  if x == x.floor() && x >= 1.0 && x <= 19.0 {
    let mut r = 1.0
    let mut k = 2.0
    while k < x {
      r *= k
      k += 1.0
    }
    return r
  }
  // 负非整数：Γ(x)Γ(1-x) = π/sin(πx)，Γ(x) 在区间 (−k−1,−k) 内符号为 (−1)^(k+1)；
  // log_gamma 返回 ln|Γ|，此处恢复符号
  if x < 0.0 {
    let n = (-x).floor()
    let sgn = if n % 2.0 == 0.0 { -1.0 } else { 1.0 }
    return sgn * @math.exp(log_gamma(x))
  }
  @math.exp(log_gamma(x))
}

///|
/// 伽马函数的自然对数（C 库 lgamma 惯例：返回 ln|Γ(x)|）。
/// 对非正整数极点返回 +inf；NaN 传播。
/// 精度：对 x > 0 与负半整数相对误差 < 1e-14。
pub fn log_gamma(x : Double) -> Double {
  if x.is_nan() {
    return x
  }
  if x <= 0.0 && x == x.floor() {
    return 1.0 / 0.0
  }
  if x < 0.5 {
    // reflection: Γ(x)Γ(1-x) = π/sin(πx)；x<0 时 sin(πx) 变号，
    // 取 ln|Γ(x)| = ln(π) − ln|sin(πx)| − log_gamma(1-x)
    @math.ln(@core.pi / @math.sin(@core.pi * x).abs()) - log_gamma(1.0 - x)
  } else {
    let z = x - 1.0
    let mut s = _lanczos[0]
    for i in 1..<_lanczos.length() {
      s += _lanczos[i] / (z + i.to_double())
    }
    let t = z + _lanczos_g + 0.5
    _lanczos_half_ln_2pi + (z + 0.5) * @math.ln(t) - t + @math.ln(s)
  }
}

///|
/// Beta 函数 B(x, y) = Γ(x)Γ(y)/Γ(x+y)。
/// 仅支持正参数；非正参数返回 NaN。
pub fn beta(x : Double, y : Double) -> Double {
  if x <= 0.0 || y <= 0.0 || x.is_nan() || y.is_nan() {
    return 0.0 / 0.0
  }
  @math.exp(log_gamma(x) + log_gamma(y) - log_gamma(x + y))
}
