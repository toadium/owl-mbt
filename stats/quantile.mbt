///|
/// 分位数与百分位数。移植自 owl_base_stats.ml 第 530-562 行。

///|
/// 返回分位数函数（闭包）。移植自 owl_base_stats.ml 第 530-545 行。
pub fn quantile(x : Array[Double]) -> (Double) -> Double raise {
  let y = sort(x)
  let n = y.length()
  fn(p : Double) -> Double raise {
    if p < 0.0 || p > 1.0 {
      raise @core.OwlError::InvalidArgument(
        "quantile: expected float between 0 and 1",
      )
    }
    let index = p * (n - 1).to_double()
    let lhs = index.to_int()
    let delta = index - lhs.to_double()
    if n == 0 {
      raise @core.OwlError::InvalidArgument("quantile: empty array")
    } else if lhs == n - 1 {
      y[lhs]
    } else {
      (1.0 - delta) * y[lhs] + delta * y[lhs + 1]
    }
  }
}

///|
/// 百分位数（p ∈ [0, 100]）
pub fn percentile(x : Array[Double], p : Double) -> Double raise {
  quantile(x)(p / 100.0)
}

///|
/// 中位数
pub fn median(x : Array[Double]) -> Double raise {
  percentile(x, 50.0)
}

///|
/// 第一四分位数（25% 分位数）
pub fn first_quartile(x : Array[Double]) -> Double raise {
  percentile(x, 25.0)
}

///|
/// 第三四分位数（75% 分位数）
pub fn third_quartile(x : Array[Double]) -> Double raise {
  percentile(x, 75.0)
}

///|
/// 四分位距 IQR = Q3 - Q1
pub fn interquartile(x : Array[Double]) -> Double raise {
  third_quartile(x) - first_quartile(x)
}

///|
/// Tukey 围栏 (Q1 - k·IQR, Q3 + k·IQR)，默认 k=1.5，用于离群值判定
pub fn tukey_fences(
  k~ : Double = 1.5,
  arr : Array[Double],
) -> (Double, Double) raise {
  let q1 = first_quartile(arr)
  let q3 = third_quartile(arr)
  let offset = k * (q3 - q1)
  (q1 - offset, q3 + offset)
}
