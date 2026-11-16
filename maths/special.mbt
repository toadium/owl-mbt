///|
/// 特殊函数与辅助数学函数。移植自 owl_base_maths.ml 第 54-140 行。

///|
/// 忠实移植 OCaml signum：nan 返回 nan，正返回 1，负返回 -1，零返回 0。
pub fn signum(x : Double) -> Double {
  if x.is_nan() {
    0.0 / 0.0
  } else if x > 0.0 {
    1.0
  } else if x < 0.0 {
    -1.0
  } else {
    0.0
  }
}

///|
/// Standard sigmoid: 1 / (1 + exp(-x)).
/// Note: OCaml source uses log instead of exp (suspected bug), fixed to standard.
pub fn sigmoid(x : Double) -> Double {
  1.0 / (1.0 + @math.exp(-x))
}

///|
/// Dawson 积分 D(x) = exp(-x^2) * ∫ exp(t^2) dt。
/// |x| <= 3 使用幂级数 D(x) = Σ (-1)^k 2^k x^(2k+1) / (2k+1)!!；
/// |x| > 3 使用渐近级数 D(x) ~ Σ (2k-1)!! / (2^(k+1) x^(2k+1))，在最小项处截断。
pub fn dawsn(x : Double) -> Double {
  if x.is_nan() {
    return x
  }
  let ax = x.abs()
  let sign = if x < 0.0 { -1.0 } else { 1.0 }
  if ax <= 3.0 {
    // 幂级数，递推项 term_k = (-2x^2)^k x / (2k+1)!!，即乘 (-2x^2)/(2k+3)
    let mut term = ax
    let mut sum = ax
    for k in 1..<60 {
      term = term * (-2.0 * ax * ax) / (2.0 * k.to_double() + 1.0)
      sum += term
      if term.abs() < 1.0e-18 * sum.abs() {
        break
      }
    }
    sign * sum
  } else {
    // 渐近级数：D(x) ~ 1/(2x) + 1/(4x^3) + 3/(8x^5) + ...，项比 (2k-1)/(2x^2)，
    // 项先减后增，在项开始增大处（最小项）截断。
    let mut term = 1.0 / (2.0 * ax)
    let mut sum = term
    let mut prev = term.abs()
    for k in 1..<400 {
      term = term * (2.0 * k.to_double() - 1.0) / (2.0 * ax * ax)
      if term.abs() > prev || term == 0.0 {
        break
      }
      sum += term
      prev = term.abs()
    }
    sign * sum
  }
}

///|
/// x * log(y), with the convention that 0 * log(y) = 0 for y >= 0.
pub fn xlogy(x : Double, y : Double) -> Double {
  if x == 0.0 && !y.is_nan() {
    0.0
  } else {
    x * @math.ln(y)
  }
}

///|
/// x * log(1 + y), with the convention that 0 * log(1+y) = 0.
#warnings("-unused_value")
fn xlog1py(x : Double, y : Double) -> Double {
  if x == 0.0 && !y.is_nan() {
    0.0
  } else {
    x * @math.ln_1p(y)
  }
}

///|
pub fn logit(x : Double) -> Double {
  @math.ln(x / (1.0 - x))
}

///|
pub fn expit(x : Double) -> Double {
  1.0 / (1.0 + @math.exp(-x))
}

///|
pub fn log1mexp(x : Double) -> Double {
  if -x > @math.ln(2.0) {
    @math.ln_1p(-@math.exp(x))
  } else {
    @math.ln(-@math.expm1(x))
  }
}

///|
pub fn log1pexp(x : Double) -> Double {
  if x <= -37.0 {
    @math.exp(x)
  } else if x <= 18.0 {
    @math.ln_1p(@math.exp(x))
  } else if x <= 33.3 {
    x + @math.exp(-x)
  } else {
    x
  }
}
