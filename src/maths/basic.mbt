///|
/// 基础与三角函数。移植自 owl_base_maths.ml 第 6-117 行。
/// OCaml Stdlib 函数映射见各函数注释。

///|
pub fn add(x : Double, y : Double) -> Double {
  x + y
}

///|
pub fn sub(x : Double, y : Double) -> Double {
  x - y
}

///|
pub fn mul(x : Double, y : Double) -> Double {
  x * y
}

///|
pub fn div(x : Double, y : Double) -> Double {
  x / y
}

///|
/// OCaml `x ** y` → `@math.pow`
pub fn pow(x : Double, y : Double) -> Double {
  @math.pow(x, y)
}

///|
/// OCaml `mod_float` → `Double::mod`
pub fn fmod(x : Double, y : Double) -> Double {
  x.mod(y)
}

///|
pub fn atan2(x : Double, y : Double) -> Double {
  @math.atan2(x, y)
}

///|
pub fn hypot(x : Double, y : Double) -> Double {
  @math.hypot(x, y)
}

///|
pub fn abs(x : Double) -> Double {
  x.abs()
}

///|
pub fn neg(x : Double) -> Double {
  -x
}

///|
pub fn reci(x : Double) -> Double {
  1.0 / x
}

///|
pub fn softsign(x : Double) -> Double {
  x / (1.0 + abs(x))
}

///|
pub fn softplus(x : Double) -> Double {
  @math.ln(1.0 + @math.exp(x))
}

///|
pub fn sqr(x : Double) -> Double {
  x * x
}

///|
pub fn sqrt(x : Double) -> Double {
  x.sqrt()
}

///|
/// OCaml `x ** 0.333...` → `@math.cbrt`（现成且更精确）
pub fn cbrt(x : Double) -> Double {
  @math.cbrt(x)
}

///|
pub fn exp(x : Double) -> Double {
  @math.exp(x)
}

///|
pub fn exp2(x : Double) -> Double {
  @math.pow(2.0, x)
}

///|
pub fn exp10(x : Double) -> Double {
  @math.pow(10.0, x)
}

///|
pub fn expm1(x : Double) -> Double {
  @math.expm1(x)
}

///|
pub fn log(x : Double) -> Double {
  @math.ln(x)
}

///|
/// OCaml `log x /. loge2` → `@math.log2`（现成且更精确）
pub fn log2(x : Double) -> Double {
  @math.log2(x)
}

///|
pub fn log10(x : Double) -> Double {
  @math.log10(x)
}

///|
pub fn log1p(x : Double) -> Double {
  @math.ln_1p(x)
}

///|
pub fn floor(x : Double) -> Double {
  @math.floor(x)
}

///|
pub fn ceil(x : Double) -> Double {
  @math.ceil(x)
}

///|
/// 忠实移植 OCaml `round x = floor (x +. 0.5)`（非银行家舍入）。
/// 注意：负半整数向上取整，如 round(-0.5) = 0, round(-1.5) = -1, round(-2.5) = -2。
pub fn round(x : Double) -> Double {
  @math.floor(x + 0.5)
}

///|
pub fn trunc(x : Double) -> Double {
  @math.trunc(x)
}

///|
pub fn fix(x : Double) -> Double {
  if x < 0.0 {
    @math.ceil(x)
  } else {
    @math.floor(x)
  }
}

///|
pub fn sin(x : Double) -> Double {
  @math.sin(x)
}

///|
pub fn cos(x : Double) -> Double {
  @math.cos(x)
}

///|
pub fn tan(x : Double) -> Double {
  @math.tan(x)
}

///|
pub fn cot(x : Double) -> Double {
  1.0 / @math.tan(x)
}

///|
pub fn sec(x : Double) -> Double {
  1.0 / @math.cos(x)
}

///|
pub fn csc(x : Double) -> Double {
  1.0 / @math.sin(x)
}

///|
pub fn sinh(x : Double) -> Double {
  @math.sinh(x)
}

///|
pub fn cosh(x : Double) -> Double {
  @math.cosh(x)
}

///|
pub fn tanh(x : Double) -> Double {
  @math.tanh(x)
}

///|
pub fn asin(x : Double) -> Double {
  @math.asin(x)
}

///|
pub fn acos(x : Double) -> Double {
  @math.acos(x)
}

///|
pub fn atan(x : Double) -> Double {
  @math.atan(x)
}

///|
pub fn acot(x : Double) -> Double {
  @const.pi_2 - @math.atan(x)
}

///|
pub fn asec(x : Double) -> Double {
  @math.acos(1.0 / x)
}

///|
pub fn acsc(x : Double) -> Double {
  @math.asin(1.0 / x)
}

///|
pub fn asinh(x : Double) -> Double {
  @math.asinh(x)
}

///|
pub fn acosh(x : Double) -> Double {
  @math.acosh(x)
}

///|
pub fn atanh(x : Double) -> Double {
  @math.atanh(x)
}

///|
pub fn acoth(x : Double) -> Double {
  @math.atanh(1.0 / x)
}

///|
pub fn asech(x : Double) -> Double {
  @math.acosh(1.0 / x)
}

///|
pub fn acsch(x : Double) -> Double {
  @math.asinh(1.0 / x)
}

///|
pub fn relu(x : Double) -> Double {
  if x > 0.0 {
    x
  } else {
    0.0
  }
}
