///|
/// 高斯核密度估计。移植自 owl_base_stats.ml 第 565-605 行。

///|
/// 带宽选择策略。移植自 OCaml polymorphic variant `Silverman | `Scott
pub(all) enum Bandwidth {
  Silverman
  Scott
} derive(Debug, Eq)

///|
/// 高斯核函数。移植自 owl_base_stats.ml build_kernel `Gaussian
fn _gaussian_kernel(h : Double, p : Double, v : Double) -> Double {
  let u = (v - p) / h
  1.0 / (@const.sqrt2 * @const.sqrtpi) * @math.exp(-@maths.sqr(u) / 2.0)
}

///|
/// 构建估计点。移植自 owl_base_stats.ml build_points
fn _build_points(
  n_points : Int,
  h : Double,
  vs : Array[Double],
) -> Array[Double] {
  let (mn, mx) = minmax(vs)
  let a = mn - 3.0 * h
  let b = mx + 3.0 * h
  let step = (b - a) / n_points.to_double()
  [
    for i in 0..<n_points => a + i.to_double() * step
  ]
}

///|
/// 高斯 KDE。移植自 owl_base_stats.ml gaussian_kde
pub fn gaussian_kde(
  bandwidth? : Bandwidth = Bandwidth::Scott,
  n_points? : Int = 512,
  vs : Array[Double],
) -> (Array[Double], Array[Double]) raise {
  if vs.length() < 2 {
    raise @types.OwlError::InvalidArgument(
      "estimate_pdf: sample should have multiple elements",
    )
  }
  let n = vs.length().to_double()
  let iqr = interquartile(vs)
  let sd_val = std(None, vs)
  let s = if sd_val < iqr / 0.34 { sd_val } else { iqr / 0.34 }
  let h = match bandwidth {
    Bandwidth::Silverman => 0.90 * s * @math.pow(n, -0.2)
    Bandwidth::Scott => 1.06 * s * @math.pow(n, -0.2)
  }
  let points = _build_points(n_points, h, vs)
  let f = 1.0 / (h * n)
  let pdf = [
    for i in 0..<n_points => {
      let p = points[i]
      let s = vs.fold(init=0.0, fn(acc, v) { acc + _gaussian_kernel(h, p, v) })
      f * s
    }
  ]
  (points, pdf)
}
