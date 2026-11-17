///|
/// 基础与三角函数。移植自 owl_base_maths.ml 第 6-117 行。
/// OCaml Stdlib 函数映射见各函数注释。

///|
/// 标量加法 x + y
pub fn add(x : Double, y : Double) -> Double {
  x + y
}

///|
/// 标量减法 x - y
pub fn sub(x : Double, y : Double) -> Double {
  x - y
}

///|
/// 标量乘法 x * y
pub fn mul(x : Double, y : Double) -> Double {
  x * y
}

///|
/// 标量除法 x / y
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
/// 双参数反正切 atan2(x, y)
pub fn atan2(x : Double, y : Double) -> Double {
  @math.atan2(x, y)
}

///|
/// √(x² + y²)，避免中间量溢出
pub fn hypot(x : Double, y : Double) -> Double {
  @math.hypot(x, y)
}

///|
/// 标量绝对值
pub fn abs(x : Double) -> Double {
  x.abs()
}

///|
/// 标量取反 -x
pub fn neg(x : Double) -> Double {
  -x
}

///|
/// 标量倒数 1/x
pub fn reci(x : Double) -> Double {
  1.0 / x
}

///|
/// softsign 激活函数 x / (1 + |x|)
pub fn softsign(x : Double) -> Double {
  x / (1.0 + abs(x))
}

///|
/// softplus 激活函数 ln(1 + e^x)
pub fn softplus(x : Double) -> Double {
  @math.ln(1.0 + @math.exp(x))
}

///|
/// 标量平方 x²
pub fn sqr(x : Double) -> Double {
  x * x
}

///|
/// 标量平方根
pub fn sqrt(x : Double) -> Double {
  x.sqrt()
}

///|
/// OCaml `x ** 0.333...` → `@math.cbrt`（现成且更精确）
pub fn cbrt(x : Double) -> Double {
  @math.cbrt(x)
}

///|
/// 标量指数 e^x
pub fn exp(x : Double) -> Double {
  @math.exp(x)
}

///|
/// 2 的 x 次幂 2^x
pub fn exp2(x : Double) -> Double {
  @math.pow(2.0, x)
}

///|
/// 10 的 x 次幂 10^x
pub fn exp10(x : Double) -> Double {
  @math.pow(10.0, x)
}

///|
/// e^x - 1 的稳定实现（小 x 精度更高）
pub fn expm1(x : Double) -> Double {
  @math.expm1(x)
}

///|
/// 标量自然对数 ln x
pub fn log(x : Double) -> Double {
  @math.ln(x)
}

///|
/// OCaml `log x /. loge2` → `@math.log2`（现成且更精确）
pub fn log2(x : Double) -> Double {
  @math.log2(x)
}

///|
/// 标量以 10 为底对数
pub fn log10(x : Double) -> Double {
  @math.log10(x)
}

///|
/// ln(1 + x) 的稳定实现（小 x 精度更高）
pub fn log1p(x : Double) -> Double {
  @math.ln_1p(x)
}

///|
/// 向下取整
pub fn floor(x : Double) -> Double {
  @math.floor(x)
}

///|
/// 向上取整
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
/// 向零截断取整
pub fn trunc(x : Double) -> Double {
  @math.trunc(x)
}

///|
/// 向零取整（负数向上、正数向下）
pub fn fix(x : Double) -> Double {
  if x < 0.0 {
    @math.ceil(x)
  } else {
    @math.floor(x)
  }
}

///|
/// 标量正弦
pub fn sin(x : Double) -> Double {
  @math.sin(x)
}

///|
/// 标量余弦
pub fn cos(x : Double) -> Double {
  @math.cos(x)
}

///|
/// 标量正切
pub fn tan(x : Double) -> Double {
  @math.tan(x)
}

///|
/// 标量余切 1/tan(x)
pub fn cot(x : Double) -> Double {
  1.0 / @math.tan(x)
}

///|
/// 标量正割 1/cos(x)
pub fn sec(x : Double) -> Double {
  1.0 / @math.cos(x)
}

///|
/// 标量余割 1/sin(x)
pub fn csc(x : Double) -> Double {
  1.0 / @math.sin(x)
}

///|
/// 标量双曲正弦
pub fn sinh(x : Double) -> Double {
  @math.sinh(x)
}

///|
/// 标量双曲余弦
pub fn cosh(x : Double) -> Double {
  @math.cosh(x)
}

///|
/// 标量双曲正切
pub fn tanh(x : Double) -> Double {
  @math.tanh(x)
}

///|
/// 标量反正弦
pub fn asin(x : Double) -> Double {
  @math.asin(x)
}

///|
/// 标量反余弦
pub fn acos(x : Double) -> Double {
  @math.acos(x)
}

///|
/// 标量反正切
pub fn atan(x : Double) -> Double {
  @math.atan(x)
}

///|
/// 标量反余切 π/2 - atan(x)
pub fn acot(x : Double) -> Double {
  @core.pi_2 - @math.atan(x)
}

///|
/// 标量反正割 acos(1/x)
pub fn asec(x : Double) -> Double {
  @math.acos(1.0 / x)
}

///|
/// 标量反余割 asin(1/x)
pub fn acsc(x : Double) -> Double {
  @math.asin(1.0 / x)
}

///|
/// 标量反双曲正弦
pub fn asinh(x : Double) -> Double {
  @math.asinh(x)
}

///|
/// 标量反双曲余弦
pub fn acosh(x : Double) -> Double {
  @math.acosh(x)
}

///|
/// 标量反双曲正切
pub fn atanh(x : Double) -> Double {
  @math.atanh(x)
}

///|
/// 标量反双曲余切 atanh(1/x)
pub fn acoth(x : Double) -> Double {
  @math.atanh(1.0 / x)
}

///|
/// 标量反双曲正割 acosh(1/x)
pub fn asech(x : Double) -> Double {
  @math.acosh(1.0 / x)
}

///|
/// 标量反双曲余割 asinh(1/x)
pub fn acsch(x : Double) -> Double {
  @math.asinh(1.0 / x)
}

///|
/// 标量 ReLU 激活函数 max(0, x)
pub fn relu(x : Double) -> Double {
  if x > 0.0 {
    x
  } else {
    0.0
  }
}
