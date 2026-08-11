///|
/// 分位数与百分位数。移植自 owl_base_stats.ml 第 530-562 行。

///|
/// 返回分位数函数（闭包）。移植自 owl_base_stats.ml 第 530-545 行。
pub fn quantile(x : Array[Double]) -> (Double) -> Double raise {
  let y = sort(x)
  let n = y.length()
  fn(p : Double) -> Double raise {
    if p < 0.0 || p > 1.0 {
      raise @types.OwlError::InvalidArgument(
        "quantile: expected float between 0 and 1",
      )
    }
    let index = p * (n - 1).to_double()
    let lhs = index.to_int()
    let delta = index - lhs.to_double()
    if n == 0 {
      0.0
    } else if lhs == n - 1 {
      y[lhs]
    } else {
      (1.0 - delta) * y[lhs] + delta * y[lhs + 1]
    }
  }
}

///|
pub fn percentile(x : Array[Double], p : Double) -> Double raise {
  quantile(x)(p / 100.0)
}

///|
pub fn median(x : Array[Double]) -> Double raise {
  percentile(x, 50.0)
}

///|
pub fn first_quartile(x : Array[Double]) -> Double raise {
  percentile(x, 25.0)
}

///|
pub fn third_quartile(x : Array[Double]) -> Double raise {
  percentile(x, 75.0)
}

///|
pub fn interquartile(x : Array[Double]) -> Double raise {
  third_quartile(x) - first_quartile(x)
}

///|
pub fn tukey_fences(
  k? : Double = 1.5,
  arr : Array[Double],
) -> (Double, Double) raise {
  let q1 = first_quartile(arr)
  let q3 = third_quartile(arr)
  let offset = k * (q3 - q1)
  (q1 - offset, q3 + offset)
}
