///|
/// 描述统计。移植自 owl_base_stats.ml 第 71-178 行。

///|
pub fn sum(x : Array[Double]) -> Double {
  x.fold(init=0.0, fn(acc, a) { acc + a })
}

///|
pub fn mean(x : Array[Double]) -> Double {
  let n = x.length().to_double()
  sum(x) / n
}

///|
fn _get_mean(m : Double?, x : Array[Double]) -> Double {
  match m {
    Some(v) => v
    None => mean(x)
  }
}

///|
/// 方差。移植自 owl_base_stats.ml var。OCaml ?mean → MoonBit Double? 参数。
pub fn variance(mean : Double?, x : Array[Double]) -> Double {
  let m = _get_mean(mean, x)
  let mut t = 0.0
  for a in x {
    let d = a - m
    t += d * d
  }
  let l = x.length().to_double()
  let n = if l == 1.0 { 1.0 } else { l - 1.0 }
  t / n
}

///|
pub fn std(mean : Double?, x : Array[Double]) -> Double {
  variance(mean, x).sqrt()
}

///|
pub fn sem(mean : Double?, x : Array[Double]) -> Double {
  let s = std(mean, x)
  let n = x.length().to_double()
  s / n.sqrt()
}

///|
pub fn absdev(mean : Double?, x : Array[Double]) -> Double {
  let m = _get_mean(mean, x)
  let mut t = 0.0
  for a in x {
    let d = (a - m).abs()
    t += d
  }
  let n = x.length().to_double()
  t / n
}

///|
pub fn skew(mean : Double?, sd : Double?, x : Array[Double]) -> Double {
  let m = _get_mean(mean, x)
  let s = match sd {
    Some(v) => v
    None => std(Some(m), x)
  }
  let mut t = 0.0
  for a in x {
    let z = (a - m) / s
    t += z * z * z
  }
  let n = x.length().to_double()
  t / n
}

///|
pub fn kurtosis(mean : Double?, sd : Double?, x : Array[Double]) -> Double {
  let m = _get_mean(mean, x)
  let s = match sd {
    Some(v) => v
    None => std(Some(m), x)
  }
  let mut t = 0.0
  for a in x {
    let z = (a - m) / s
    let u = z * z
    t += u * u
  }
  let n = x.length().to_double()
  t / n
}

///|
pub fn central_moment(n : Int, x : Array[Double]) -> Double {
  let m = n.to_double()
  let u = mean(x)
  let mut s = 0.0
  for a in x {
    s += @math.pow(a - u, m)
  }
  s / x.length().to_double()
}

///|
pub fn cov(
  m0 : Double?,
  m1 : Double?,
  x0 : Array[Double],
  x1 : Array[Double],
) -> Double raise {
  let n0 = x0.length()
  let n1 = x1.length()
  if n0 != n1 {
    raise @types.OwlError::InvalidArgument(
      "cov: arrays must have the same length",
    )
  }
  let mu0 = _get_mean(m0, x0)
  let mu1 = _get_mean(m1, x1)
  let mut t = 0.0
  for i in 0..<n0 {
    let d0 = x0[i] - mu0
    let d1 = x1[i] - mu1
    t += d0 * d1
  }
  t / n0.to_double()
}
