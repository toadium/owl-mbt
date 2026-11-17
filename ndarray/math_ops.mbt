///|
/// Apply a unary function element-wise.
fn _map_elem(x : Ndarray, f : (Double) -> Double) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n, 0.0)
  let xd = x.data
  for i in 0..<n {
    data[i] = f(xd[i])
  }
  { shape: x.shape.copy(), data, }
}

///|
/// Apply a unary function element-wise, returning a new ndarray.
/// Same as `map` but with argument order `(x, f)` instead of `(f, x)`.
pub fn map_elem(x : Ndarray, f : (Double) -> Double) -> Ndarray {
  _map_elem(x, f)
}

///|
/// Apply a unary function element-wise IN-PLACE (modifies x.data directly, no allocation).
/// Returns x for chaining.
pub fn map_elem_inplace(x : Ndarray, f : (Double) -> Double) -> Ndarray {
  let n = x.data.length()
  let xd = x.data
  for i in 0..<n {
    xd[i] = f(xd[i])
  }
  x
}

///|
/// Apply a binary function element-wise (public).
pub fn map_elem2(
  x : Ndarray,
  y : Ndarray,
  f : (Double, Double) -> Double,
) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n, 0.0)
  let xd = x.data
  let yd = y.data
  for i in 0..<n {
    data[i] = f(xd[i], yd[i])
  }
  { shape: x.shape.copy(), data, }
}

///|
/// 逐元素绝对值
pub fn abs(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { v.abs() })
}

///|
/// 逐元素取反
pub fn neg(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { -v })
}

///|
/// 逐元素向下取整
pub fn floor(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { v.floor() })
}

///|
/// 逐元素向上取整
pub fn ceil(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { v.ceil() })
}

///|
/// 逐元素取整
pub fn round(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { v.round() })
}

///|
/// 逐元素平方
pub fn sqr(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { v * v })
}

///|
/// 逐元素平方根
pub fn sqrt(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { v.sqrt() })
}

///|
/// 逐元素自然对数
pub fn log(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.ln(v) })
}

///|
/// 逐元素以 2 为底对数
pub fn log2(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.log2(v) })
}

///|
/// 逐元素以 10 为底对数
pub fn log10(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.log10(v) })
}

///|
/// 逐元素指数 e^x
pub fn exp(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.exp(v) })
}

///|
/// 逐元素正弦
pub fn sin(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.sin(v) })
}

///|
/// 逐元素余弦
pub fn cos(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.cos(v) })
}

///|
/// 逐元素正切
pub fn tan(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.tan(v) })
}

///|
/// 逐元素双曲正弦
pub fn sinh(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.sinh(v) })
}

///|
/// 逐元素双曲余弦
pub fn cosh(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.cosh(v) })
}

///|
/// 逐元素双曲正切
pub fn tanh(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.tanh(v) })
}

///|
/// 逐元素反正弦
pub fn asin(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.asin(v) })
}

///|
/// 逐元素反余弦
pub fn acos(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.acos(v) })
}

///|
/// 逐元素反正切
pub fn atan(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.atan(v) })
}

///|
/// 逐元素反双曲正弦
pub fn asinh(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.asinh(v) })
}

///|
/// 逐元素反双曲余弦
pub fn acosh(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.acosh(v) })
}

///|
/// 逐元素反双曲正切
pub fn atanh(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @math.atanh(v) })
}

///|
/// 逐元素符号函数（NaN 传 NaN，正 1 负 -1 零 0）
pub fn signum(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @maths.signum(v) })
}

///|
/// 逐元素 sigmoid 激活函数
pub fn sigmoid(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { @maths.sigmoid(v) })
}

///|
/// 逐元素 ReLU 激活函数 max(0, x)
pub fn relu(x : Ndarray) -> Ndarray {
  _map_elem(x, fn(v) { if v > 0.0 { v } else { 0.0 } })
}

///|
/// 逐元素 Dawson 积分
pub fn dawsn(x : Ndarray) -> Ndarray {
  let n = x.data.length()
  let data = FixedArray::make(n, 0.0)
  let xd = x.data
  for i in 0..<n {
    data[i] = @maths.dawsn(xd[i])
  }
  { shape: x.shape.copy(), data, }
}
