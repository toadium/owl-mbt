///|
/// 第一类贝塞尔函数 J0 / J1。
/// |x| <= 25 使用幂级数（系数由定义直接计算，无查表）；
/// |x| > 25 使用 Hankel 渐近展开首项修正（P/Q 系数由 DLMF 10.17.3 公式推导）。
/// 第二类函数 Y0/Y1 暂未移植。

///|
let _bessel_asymptotic_switch : Double = 25.0

///|
/// 第一类零阶贝塞尔函数 J0(x)。偶函数。
pub fn j0(x : Double) -> Double {
  if x.is_nan() {
    return x
  }
  let ax = x.abs()
  if ax > _bessel_asymptotic_switch {
    // J0 ≈ sqrt(2/(pi x)) [P0 cos(chi) - Q0 sin(chi)], chi = x - pi/4, mu = 0
    let p0 = 1.0 - 9.0 / (128.0 * ax * ax)
    let q0 = -1.0 / (8.0 * ax)
    let chi = ax - @core.pi_4
    let amp = (2.0 / (@core.pi * ax)).sqrt()
    return amp * (p0 * @math.cos(chi) - q0 * @math.sin(chi))
  }
  // 幂级数：J0 = sum (-1)^k (x^2/4)^k / (k!)^2
  let x2 = ax * ax / 4.0
  let mut term = 1.0
  let mut sum = 1.0
  for k in 1..<80 {
    let kd = k.to_double()
    term = term * -x2 / (kd * kd)
    sum += term
    if term.abs() < 1.0e-18 * sum.abs() {
      break
    }
  }
  sum
}

///|
/// 第一类一阶贝塞尔函数 J1(x)。奇函数。
pub fn j1(x : Double) -> Double {
  if x.is_nan() {
    return x
  }
  let ax = x.abs()
  let sign = if x < 0.0 { -1.0 } else { 1.0 }
  if ax > _bessel_asymptotic_switch {
    // J1 ≈ sign * sqrt(2/(pi x)) [P1 cos(chi) - Q1 sin(chi)], chi = x - 3pi/4, mu = 4
    let p1 = 1.0 + 15.0 / (128.0 * ax * ax)
    let q1 = 3.0 / (8.0 * ax)
    let chi = ax - @core.pi * 0.75
    let amp = (2.0 / (@core.pi * ax)).sqrt()
    return sign * amp * (p1 * @math.cos(chi) - q1 * @math.sin(chi))
  }
  // 幂级数：J1 = (x/2) sum (-1)^k (x^2/4)^k / (k! (k+1)!)
  let x2 = ax * ax / 4.0
  let mut term = 1.0
  let mut sum = 1.0
  for k in 1..<80 {
    let kd = k.to_double()
    term = term * -x2 / (kd * (kd + 1.0))
    sum += term
    if term.abs() < 1.0e-18 * sum.abs() {
      break
    }
  }
  0.5 * ax * sum * sign
}
