///|
/// 谓词与分类函数。移植自 owl_base_maths.ml 第 165-204 行。

///|
pub fn is_nan(x : Double) -> Bool {
  x.is_nan()
}

///|
pub fn is_inf(x : Double) -> Bool {
  x.is_inf()
}

///|
/// subnormal：非零且绝对值小于最小 normal 数（DBL_MIN ≈ 2.225e-308）
pub fn is_subnormal(x : Double) -> Bool {
  x != 0.0 && x.abs() < 2.2250738585072014e-308
}

///|
pub fn is_normal(x : Double) -> Bool {
  x != 0.0 && !x.is_nan() && !x.is_inf() && !is_subnormal(x)
}

///|
pub fn is_odd(x : Int) -> Bool {
  x.abs() % 2 == 1
}

///|
pub fn is_even(x : Int) -> Bool {
  x % 2 == 0
}

///|
pub fn is_pow2(x : Int) -> Bool {
  x > 0 && (x & (x - 1)) == 0
}

///|
pub fn same_sign(x : Double, y : Double) -> Bool {
  if x >= 0.0 && y >= 0.0 {
    true
  } else if x <= 0.0 && y <= 0.0 {
    true
  } else {
    false
  }
}

///|
/// 判断数组是否为单纯形（非负且和为 1）。移植自 owl_base_maths.ml 第 183-199 行。
/// OCaml 用异常控制流提前退出，此处改为直接返回。
pub fn is_simplex(x : ArrayView[Double]) -> Bool {
  let mut acc = 0.0
  for a in x {
    if a < 0.0 {
      return false
    }
    acc += a
  }
  (1.0 - acc).abs() <= @const.eps
}

///|
pub fn is_int(x : Double) -> Bool {
  @math.trunc(x) == x
}

///|
pub fn is_sqr(x : Int) -> Bool {
  is_int(x.to_double().sqrt())
}
