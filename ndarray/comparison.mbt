///|
/// 判断数组中是否存在满足谓词的元素
pub fn exists(f : (Double) -> Bool, x : Ndarray) -> Bool {
  for i in 0..<x.data.length() {
    if f(x.data[i]) {
      return true
    }
  }
  false
}

///|
/// 判断数组中是否不存在满足谓词的元素
pub fn not_exists(f : (Double) -> Bool, x : Ndarray) -> Bool {
  !exists(f, x)
}

///|
/// 判断数组是否所有元素都满足谓词
pub fn for_all(f : (Double) -> Bool, x : Ndarray) -> Bool {
  for i in 0..<x.data.length() {
    if !f(x.data[i]) {
      return false
    }
  }
  true
}

///|
/// 判断数组是否全为零
pub fn is_zero(x : Ndarray) -> Bool {
  for_all(fn(v) { v == 0.0 }, x)
}

///|
/// 判断数组是否全部严格为正
pub fn is_positive(x : Ndarray) -> Bool {
  for_all(fn(v) { v > 0.0 }, x)
}

///|
/// 判断数组是否全部严格为负
pub fn is_negative(x : Ndarray) -> Bool {
  for_all(fn(v) { v < 0.0 }, x)
}

///|
/// 判断数组是否全部非正（≤ 0）
pub fn is_nonpositive(x : Ndarray) -> Bool {
  for_all(fn(v) { v <= 0.0 }, x)
}

///|
/// 判断数组是否全部非负（≥ 0）
pub fn is_nonnegative(x : Ndarray) -> Bool {
  for_all(fn(v) { v >= 0.0 }, x)
}

///|
/// 判断数组元素是否全为 normal 数（非零、非 NaN、非无穷、非次正规）
pub fn is_normal(x : Ndarray) -> Bool {
  for_all(fn(v) { @maths.is_normal(v) }, x)
}

///|
/// 判断数组是否不含 NaN
pub fn not_nan(x : Ndarray) -> Bool {
  for_all(fn(v) { !v.is_nan() }, x)
}

///|
/// 判断数组是否不含无穷
pub fn not_inf(x : Ndarray) -> Bool {
  for_all(fn(v) { !v.is_inf() }, x)
}

///|
/// 判断两数组形状与所有元素是否完全相等
pub fn equal(x : Ndarray, y : Ndarray) -> Bool {
  if x.shape.length() != y.shape.length() {
    return false
  }
  for i in 0..<x.shape.length() {
    if x.shape[i] != y.shape[i] {
      return false
    }
  }
  for i in 0..<x.data.length() {
    if x.data[i] != y.data[i] {
      return false
    }
  }
  true
}

///|
/// 判断两数组是否不完全相等（形状或任一元素不同）
pub fn not_equal(x : Ndarray, y : Ndarray) -> Bool {
  !equal(x, y)
}

///|
/// 判断 x 逐位置全部严格大于 y（不广播）
pub fn greater(x : Ndarray, y : Ndarray) -> Bool {
  let n = x.data.length()
  for i in 0..<n {
    if x.data[i] <= y.data[i] {
      return false
    }
  }
  true
}

///|
/// 判断 x 逐位置全部严格小于 y（不广播）
pub fn less(x : Ndarray, y : Ndarray) -> Bool {
  let n = x.data.length()
  for i in 0..<n {
    if x.data[i] >= y.data[i] {
      return false
    }
  }
  true
}

///|
/// 判断 x 逐位置全部大于等于 y（不广播）
pub fn greater_equal(x : Ndarray, y : Ndarray) -> Bool {
  let n = x.data.length()
  for i in 0..<n {
    if x.data[i] < y.data[i] {
      return false
    }
  }
  true
}

///|
/// 判断 x 逐位置全部小于等于 y（不广播）
pub fn less_equal(x : Ndarray, y : Ndarray) -> Bool {
  let n = x.data.length()
  for i in 0..<n {
    if x.data[i] > y.data[i] {
      return false
    }
  }
  true
}

///|
/// 逐元素相等比较，支持广播，满足处为 1.0 否则 0.0
pub fn elt_equal(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { if a == b { 1.0 } else { 0.0 } })
}

///|
/// 逐元素不等比较，支持广播，满足处为 1.0 否则 0.0
pub fn elt_not_equal(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { if a != b { 1.0 } else { 0.0 } })
}

///|
/// 逐元素小于比较，支持广播，满足处为 1.0 否则 0.0
pub fn elt_less(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { if a < b { 1.0 } else { 0.0 } })
}

///|
/// 逐元素大于比较，支持广播，满足处为 1.0 否则 0.0
pub fn elt_greater(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { if a > b { 1.0 } else { 0.0 } })
}

///|
/// 逐元素小于等于比较，支持广播，满足处为 1.0 否则 0.0
pub fn elt_less_equal(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { if a <= b { 1.0 } else { 0.0 } })
}

///|
/// 逐元素大于等于比较，支持广播，满足处为 1.0 否则 0.0
pub fn elt_greater_equal(x : Ndarray, y : Ndarray) -> Ndarray raise {
  _broadcasted_op(x, y, fn(a, b) { if a >= b { 1.0 } else { 0.0 } })
}

///|
/// 判断所有元素是否都等于标量 s
pub fn equal_scalar(x : Ndarray, s : Double) -> Bool {
  for_all(fn(v) { v == s }, x)
}

///|
/// 判断是否存在不等于标量 s 的元素
pub fn not_equal_scalar(x : Ndarray, s : Double) -> Bool {
  !equal_scalar(x, s)
}

///|
/// 判断所有元素是否都小于标量 s
pub fn less_scalar(x : Ndarray, s : Double) -> Bool {
  for_all(fn(v) { v < s }, x)
}

///|
/// 判断所有元素是否都大于标量 s
pub fn greater_scalar(x : Ndarray, s : Double) -> Bool {
  for_all(fn(v) { v > s }, x)
}

///|
/// 判断所有元素是否都小于等于标量 s
pub fn less_equal_scalar(x : Ndarray, s : Double) -> Bool {
  for_all(fn(v) { v <= s }, x)
}

///|
/// 判断所有元素是否都大于等于标量 s
pub fn greater_equal_scalar(x : Ndarray, s : Double) -> Bool {
  for_all(fn(v) { v >= s }, x)
}

///|
/// 逐元素与标量比较相等，满足处为 1.0 否则 0.0
pub fn elt_equal_scalar(x : Ndarray, s : Double) -> Ndarray {
  _map_elem(x, fn(v) { if v == s { 1.0 } else { 0.0 } })
}

///|
/// 逐元素与标量比较不等，满足处为 1.0 否则 0.0
pub fn elt_not_equal_scalar(x : Ndarray, s : Double) -> Ndarray {
  _map_elem(x, fn(v) { if v != s { 1.0 } else { 0.0 } })
}

///|
/// 逐元素与标量比较小于，满足处为 1.0 否则 0.0
pub fn elt_less_scalar(x : Ndarray, s : Double) -> Ndarray {
  _map_elem(x, fn(v) { if v < s { 1.0 } else { 0.0 } })
}

///|
/// 逐元素与标量比较大于，满足处为 1.0 否则 0.0
pub fn elt_greater_scalar(x : Ndarray, s : Double) -> Ndarray {
  _map_elem(x, fn(v) { if v > s { 1.0 } else { 0.0 } })
}

///|
/// 逐元素与标量比较小于等于，满足处为 1.0 否则 0.0
pub fn elt_less_equal_scalar(x : Ndarray, s : Double) -> Ndarray {
  _map_elem(x, fn(v) { if v <= s { 1.0 } else { 0.0 } })
}

///|
/// 逐元素与标量比较大于等于，满足处为 1.0 否则 0.0
pub fn elt_greater_equal_scalar(x : Ndarray, s : Double) -> Ndarray {
  _map_elem(x, fn(v) { if v >= s { 1.0 } else { 0.0 } })
}

///|
/// 判断两数组逐元素绝对差是否都在 eps 内（默认 1.0e-6）
pub fn approx_equal(x : Ndarray, y : Ndarray, eps~ : Double = 1.0e-6) -> Bool {
  let n = x.data.length()
  if n != y.data.length() {
    return false
  }
  for i in 0..<n {
    if (x.data[i] - y.data[i]).abs() > eps {
      return false
    }
  }
  true
}
