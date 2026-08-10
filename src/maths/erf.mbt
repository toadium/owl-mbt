///|
/// 误差函数。移植自 owl_base_maths.ml 第 142-161 行。
/// 使用 Abramowitz & Stegun 7.1.26 近似公式。

///|
pub fn erf(x : Double) -> Double {
  let a = 0.254829592
  let b = -0.284496736
  let c = 1.421413741
  let d = -1.453152027
  let e = 1.061405429
  let p = 0.327591100
  let s = signum(x)
  let ax = abs(x)
  let t = 1.0 / (1.0 + p * ax)
  let y = 1.0 -
    ((((e * t + d) * t + c) * t + b) * t + a) * t * @math.exp(-(ax * ax))
  s * y
}

///|
pub fn erfc(x : Double) -> Double {
  1.0 - erf(x)
}

///|
pub fn erfcx(x : Double) -> Double {
  @math.exp(x * x) * erfc(x)
}
