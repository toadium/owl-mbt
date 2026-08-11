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
/// 忠实移植 OCaml `sigmoid x = 1. /. (1. +. log (-.x))`。
/// 注意：源码用 `log` 而非 `exp`，对 x>0 返回 nan。此行为与 OCaml 一致。
pub fn sigmoid(x : Double) -> Double {
  1.0 / (1.0 + @math.ln(-x))
}

///|
/// Dawson 积分，owl-base 未实现。
pub fn dawsn(_x : Double) -> Double raise @types.OwlError {
  raise @types.OwlError::NotImplemented("dawsn")
}

///|
pub fn xlogy(x : Double, y : Double) -> Double {
  if x == 0.0 && !y.is_nan() {
    0.0
  } else {
    x * @math.ln(y)
  }
}

///|
pub fn xlog1py(x : Double, y : Double) -> Double {
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
