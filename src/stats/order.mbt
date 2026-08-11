///|
/// 排序、秩、极值。移植自 owl_base_stats.ml 第 180-276 行。

///|
pub fn concordant(x0 : Array[Double], x1 : Array[Double]) -> Int {
  let n = x0.length()
  let mut c = 0
  for i in 0..<(n - 1) {
    for j in (i + 1)..<n {
      if (x0[i] < x0[j] && x1[i] < x1[j]) || (x0[i] > x0[j] && x1[i] > x1[j]) {
        c += 1
      }
    }
  }
  c
}

///|
pub fn discordant(x0 : Array[Double], x1 : Array[Double]) -> Int {
  let n = x0.length()
  let mut c = 0
  for i in 0..<(n - 1) {
    for j in (i + 1)..<n {
      if (x0[i] < x0[j] && x1[i] > x1[j]) || (x0[i] > x0[j] && x1[i] < x1[j]) {
        c += 1
      }
    }
  }
  c
}

///|
pub fn kendall_tau(x0 : Array[Double], x1 : Array[Double]) -> Double raise {
  if x0.length() < 2 {
    raise @types.OwlError::InvalidArgument(
      "kendall_tau: need at least 2 elements",
    )
  }
  let a = concordant(x0, x1).to_double()
  let b = discordant(x0, x1).to_double()
  let n = x0.length().to_double()
  2.0 * (a - b) / (n * (n - 1.0))
}

///|
/// 升序/降序排序，返回新数组。移植自 owl_base_stats.ml 第 211-215 行。
pub fn sort(inc? : Bool = true, x : Array[Double]) -> Array[Double] {
  let y = x.copy()
  if inc {
    y.sort()
  } else {
    y.sort_by(fn(a, b) { if a < b { 1 } else if a > b { -1 } else { 0 } })
  }
  y
}

///|
/// 返回排序后索引。移植自 owl_base_stats.ml 第 218-223 行。
pub fn argsort(inc? : Bool = true, x : Array[Double]) -> Array[Int] {
  let n = x.length()
  let order = [ for i in 0..<n => i ]
  if inc {
    order.sort_by(fn(i, j) {
      if x[i] < x[j] {
        -1
      } else if x[i] > x[j] {
        1
      } else {
        0
      }
    })
  } else {
    order.sort_by(fn(i, j) {
      if x[i] < x[j] {
        1
      } else if x[i] > x[j] {
        -1
      } else {
        0
      }
    })
  }
  order
}

///|
/// 秩策略（处理 ties）。移植自 owl_base_stats.ml polymorphic variant `Average/`Min/`Max
pub(all) enum TiesStrategy {
  Average
  Min
  Max
} derive(Debug, Eq)

///|
fn _resolve_ties(next : Int, d : Int, strategy : TiesStrategy) -> Double {
  match strategy {
    TiesStrategy::Average => next.to_double() - d.to_double() / 2.0
    TiesStrategy::Min => (next - d).to_double()
    TiesStrategy::Max => next.to_double()
  }
}

///|
/// 计算秩。移植自 owl_base_stats.ml 第 232-247 行。
pub fn rank(
  ties_strategy? : TiesStrategy = TiesStrategy::Average,
  vs : Array[Double],
) -> Array[Double] {
  let n = vs.length()
  let order = argsort(vs)
  let ranks = Array::make(n, 0.0)
  let mut d = 0
  for i in 0..<n {
    if i == n - 1 || vs[order[i]] != vs[order[i + 1]] {
      let tie_rank = _resolve_ties(i + 1, d, ties_strategy)
      for j in (i - d)..<(i + 1) {
        ranks[order[j]] = tie_rank
      }
      d = 0
    } else {
      d += 1
    }
  }
  ranks
}

///|
/// 返回 (min_index, max_index)。移植自 owl_base_stats.ml 第 250-267 行。
pub fn minmax_i(x : Array[Double]) -> (Int, Int) raise {
  if x.length() == 0 {
    raise @types.OwlError::InvalidArgument("minmax_i: empty array")
  }
  let mut mn = x[0]
  let mut mx = x[0]
  let mut mn_idx = 0
  let mut mx_idx = 0
  for i in 0..<x.length() {
    let a = x[i]
    if a < mn {
      mn = a
      mn_idx = i
    } else if a > mx {
      mx = a
      mx_idx = i
    }
  }
  (mn_idx, mx_idx)
}

///|
pub fn min_i(x : Array[Double]) -> Int raise {
  let (mn, _) = minmax_i(x)
  mn
}

///|
pub fn max_i(x : Array[Double]) -> Int raise {
  let (_, mx) = minmax_i(x)
  mx
}

///|
pub fn min(x : Array[Double]) -> Double raise {
  if x.length() == 0 {
    raise @types.OwlError::InvalidArgument("min: empty array")
  }
  let mut result = x[0]
  for i in 1..<x.length() {
    if x[i] < result {
      result = x[i]
    }
  }
  result
}

///|
pub fn max(x : Array[Double]) -> Double raise {
  if x.length() == 0 {
    raise @types.OwlError::InvalidArgument("max: empty array")
  }
  let mut result = x[0]
  for i in 1..<x.length() {
    if x[i] > result {
      result = x[i]
    }
  }
  result
}

///|
pub fn minmax(x : Array[Double]) -> (Double, Double) raise {
  if x.length() == 0 {
    raise @types.OwlError::InvalidArgument("minmax: empty array")
  }
  let mut mn = x[0]
  let mut mx = x[0]
  for a in x {
    if a < mn {
      mn = a
    }
    if a > mx {
      mx = a
    }
  }
  (mn, mx)
}
