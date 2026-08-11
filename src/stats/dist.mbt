///|
/// 概率分布随机数生成。移植自 owl_base_stats_dist_*.ml。

///|
/// 伯努利分布。移植自 owl_base_stats_dist_bernoulli.ml
pub fn bernoulli_rvs(p : Double) -> Double {
  if _rand.val.double() <= p {
    1.0
  } else {
    0.0
  }
}

///|
/// Box-Muller 变换缓存状态。移植自 owl_base_stats_dist_gaussian.ml。
/// OCaml 用 ref，MoonBit 用 Ref（顶层 let 不可变）。
let _gauss_case : Ref[Bool] = Ref(false)

///|
let _gauss_z1 : Ref[Double] = Ref(0.0)

///|
/// 标准正态分布 N(0,1)。移植自 owl_base_stats_dist_gaussian.ml
pub fn std_gaussian_rvs() -> Double {
  if _gauss_case.val {
    _gauss_case.val = false
    _gauss_z1.val
  } else {
    _gauss_case.val = true
    let u1 = rand01_exclusive()
    let u2 = rand01_exclusive()
    let r = (-2.0 * @math.ln(u1)).sqrt()
    let z0 = r * @math.cos(2.0 * @const.pi * u2)
    _gauss_z1.val = r * @math.sin(2.0 * @const.pi * u2)
    z0
  }
}

///|
/// 正态分布 N(mu, sigma^2)。移植自 owl_base_stats_dist_gaussian.ml
pub fn gaussian_rvs(mu : Double, sigma : Double) -> Double {
  mu + sigma * std_gaussian_rvs()
}

///|
/// 标准指数分布。移植自 owl_base_stats_dist_exponential.ml
pub fn std_exponential_rvs() -> Double {
  let u = _rand.val.double()
  -@math.ln_1p(-u)
}

///|
/// 指数分布。移植自 owl_base_stats_dist_exponential.ml
pub fn exponential_rvs(lambda : Double) -> Double raise {
  if lambda <= 0.0 {
    raise @types.OwlError::InvalidArgument("exponential_rvs: lambda must be positive")
  }
  let u = _rand.val.double()
  let s = -1.0 / lambda
  s * @math.ln_1p(-u)
}

///|
/// 标准柯西分布。移植自 owl_base_stats_dist_cauchy.ml
pub fn std_cauchy_rvs() -> Double {
  let a = std_gaussian_rvs()
  let b = std_gaussian_rvs()
  a / b
}

///|
/// 柯西分布。移植自 owl_base_stats_dist_cauchy.ml
pub fn cauchy_rvs(loc : Double, scale : Double) -> Double {
  loc + scale * std_cauchy_rvs()
}

///|
/// 标准伽马分布。移植自 owl_base_stats_dist_gamma.ml
/// 使用 Marsaglia-Tsang 算法。OCaml 原版用 Owl_exception.FOUND 控制流跳出循环，
/// MoonBit 用 while + let mut 替代。
pub fn std_gamma_rvs(shape : Double) -> Double {
  if shape == 1.0 {
    std_exponential_rvs()
  } else if shape < 1.0 {
    let mut result = 0.0
    let mut done = false
    while !done {
      let u = _rand.val.double()
      let v = std_exponential_rvs()
      if u <= 1.0 - shape {
        let x = @math.pow(u, 1.0 / shape)
        if x <= v {
          result = x
          done = true
        }
      } else {
        let y = -@math.ln((1.0 - u) / shape)
        let x = @math.pow(1.0 - shape + shape * y, 1.0 / shape)
        if x <= v + y {
          result = x
          done = true
        }
      }
    }
    result
  } else {
    let b = shape - 1.0 / 3.0
    let c = 1.0 / (9.0 * b).sqrt()
    let mut result = 0.0
    let mut done = false
    while !done {
      let mut x = 0.0
      let mut v_ok = false
      while !v_ok {
        x = std_gaussian_rvs()
        v_ok = 1.0 + c * x > 0.0
      }
      let vv = 1.0 + c * x
      let v = vv * vv * vv
      let u = _rand.val.double()
      if u < 1.0 - 0.0331 * x * x * x * x {
        result = b * v
        done = true
      } else if @math.ln(u) < 0.5 * x * x + b * (1.0 - v + @math.ln(v)) {
        result = b * v
        done = true
      }
    }
    result
  }
}

///|
/// 伽马分布。移植自 owl_base_stats_dist_gamma.ml
pub fn gamma_rvs(shape : Double, scale : Double) -> Double {
  scale * std_gamma_rvs(shape)
}

///|
/// Gumbel Type-1 分布。移植自 owl_base_stats_dist_gumbel1.ml
pub fn gumbel1_rvs(a : Double, b : Double) -> Double raise {
  if a == 0.0 {
    raise @types.OwlError::InvalidArgument("gumbel1_rvs: a must be non-zero")
  }
  if b <= 0.0 {
    raise @types.OwlError::InvalidArgument("gumbel1_rvs: b must be positive")
  }
  let x = _rand.val.double()
  (@math.ln(b) - @math.ln(-@math.ln(x))) / a
}

///|
/// Gumbel Type-2 分布。移植自 owl_base_stats_dist_gumbel2.ml
pub fn gumbel2_rvs(a : Double, b : Double) -> Double raise {
  if a == 0.0 {
    raise @types.OwlError::InvalidArgument("gumbel2_rvs: a must be non-zero")
  }
  if b <= 0.0 {
    raise @types.OwlError::InvalidArgument("gumbel2_rvs: b must be positive")
  }
  let x = _rand.val.double()
  @math.pow(-b / @math.ln(x), 1.0 / a)
}
