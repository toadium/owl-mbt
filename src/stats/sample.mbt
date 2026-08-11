///|
/// 随机排列与采样。移植自 owl_base_stats.ml 第 32-68 行。

///|
/// Fisher-Yates 洗牌，返回新数组。移植自 owl_base_stats.ml shuffle
pub fn[T] shuffle(x : Array[T]) -> Array[T] {
  let y = x.copy()
  let n = y.length()
  let mut i = n - 1
  while i >= 1 {
    let s = (i + 1).to_double()
    let j = (std_uniform_rvs() * s).to_int()
    let tmp = y[i]
    y[i] = y[j]
    y[j] = tmp
    i -= 1
  }
  y
}

///|
/// 从 x 中随机选取 k 个元素（不重复）。移植自 owl_base_stats.ml choose
pub fn[T] choose(x : Array[T], k : Int) -> Array[T] raise {
  let n = x.length()
  if n < k {
    raise @types.OwlError::InvalidArgument("choose: n < k")
  }
  let y = Array::make(k, x[0])
  let mut i = 0
  let mut j = 0
  while i < n && j < k {
    let s = (n - i).to_double()
    let l = (s * std_uniform_rvs()).to_int()
    if l < k - j {
      y[j] = x[i]
      j += 1
    }
    i += 1
  }
  y
}

///|
/// 从 x 中随机采样 k 个元素（可重复）。移植自 owl_base_stats.ml sample
pub fn[T] sample(x : Array[T], k : Int) -> Array[T] {
  let n = x.length()
  let y = Array::make(k, x[0])
  for i in 0..<k {
    let j = uniform_int_rvs(n)
    y[i] = x[j]
  }
  y
}
