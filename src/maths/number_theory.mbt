///|
/// 整数数论函数。移植自 owl_base_maths.ml 第 206-317 行。
/// mulmod/powmod/fermat_fact 声明 raise @types.OwlError（OCaml 用 Invalid_argument 异常）。
/// 跨包错误类型须用 @types.OwlError（migration skill：无 open，用 @alias）。

///|
/// 二进制快速幂辅助。用于 powmod，f 为 mulmod（raise）。
fn _binary_exp(
  a : Int,
  b : Int,
  m : Int,
  f : (Int, Int, Int) -> Int raise @types.OwlError,
  id : Int,
) -> Int raise @types.OwlError {
  let mut r = id
  let mut a = a
  let mut b = b
  while a > 0 {
    if (a & 1) == 1 {
      r = f(r, b, m)
    }
    a = a >> 1
    if a > 0 {
      b = f(b, b, m)
    }
  }
  r
}

///|
/// 模乘：(a * b) mod m。要求 a >= 0, b >= 0, m >= 1。
/// 用 Int64 做中间乘法避免 32 位 Int 溢出（a,b < m < 2^31，积 < 2^62 < Int64 max）。
/// 行为等价于 OCaml 版（含 _binary_exp 大数路径），但更简洁且无溢出风险。
pub fn mulmod(a : Int, b : Int, m : Int) -> Int raise @types.OwlError {
  if !(a >= 0 && b >= 0 && m >= 1) {
    raise @types.OwlError::InvalidArgument(
      "mulmod requires a >= 0, b >= 0, m >= 1; however the inputs are a = \{a}, b = \{b}, m = \{m}",
    )
  }
  let a = a % m
  let b = b % m
  (a.to_int64() * b.to_int64() % m.to_int64()).to_int()
}

///|
/// 模幂：(a ^ b) mod m。要求 a >= 0, b >= 0, m >= 1。
pub fn powmod(a : Int, b : Int, m : Int) -> Int raise @types.OwlError {
  if !(a >= 0 && b >= 0 && m >= 1) {
    raise @types.OwlError::InvalidArgument(
      "powmod requires a >= 0, b >= 0, m >= 1; however the inputs are a = \{a}, b = \{b}, m = \{m}",
    )
  }
  if m == 1 && b == 0 {
    0
  } else {
    _binary_exp(b, a % m, m, mulmod, 1)
  }
}

///|
/// Fermat 分解：对奇数 x 返回 (factor0, factor1) 使得 x = factor0 * factor1。
pub fn fermat_fact(x : Int) -> (Int, Int) raise @types.OwlError {
  if !is_odd(x) {
    raise @types.OwlError::InvalidArgument(
      "the input of fermat_fact should be an odd number",
    )
  }
  let xf = x.to_double()
  let mut y = @math.ceil(xf.sqrt())
  let mut z = y * y - xf
  while !is_int(z.sqrt()) {
    y += 1.0
    z = y * y - xf
  }
  let sq = z.sqrt()
  let fac0 = (y + sq).to_int()
  let fac1 = (y - sq).to_int()
  (fac0, fac1)
}

///|
/// 分解 n = 2^i * r，返回 (i, r) 其中 r 为奇数。
fn _factor_powtwo(n : Int) -> (Int, Int) {
  let mut i = 0
  let mut r = n
  while (r & 1) == 0 {
    r = r >> 1
    i += 1
  }
  (i, r)
}

///|
/// Miller-Rabin 单基检测。
fn _possible_prime(
  s : Int,
  d : Int,
  n : Int,
  a : Int,
) -> Bool raise @types.OwlError {
  let mut p = powmod(a, d, n)
  if p == 1 || p == n - 1 {
    true
  } else {
    let mut i = 0
    let mut found = false
    while i < s && !found {
      p = mulmod(p, p, n)
      if p == n - 1 {
        found = true
      }
      i += 1
    }
    found
  }
}

///|
/// 素数检测（Miller-Rabin，确定性基）。移植自 owl_base_maths.ml 第 278-317 行。
pub fn is_prime(x : Int) -> Bool raise @types.OwlError {
  if x < 30 {
    let small_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    small_primes.contains(x)
  } else if x % 2 == 0 || x % 3 == 0 {
    false
  } else {
    let bases : Array[Int] = if x <= 1073741823 {
      [2, 7, 61]
    } else {
      [2, 325, 9375, 28178, 450775, 9780504, 6 * 299210837]
    }
    let (s, d) = _factor_powtwo(x - 1)
    let mut all_pass = true
    for b in bases {
      if all_pass {
        if b % x != 0 && !_possible_prime(s, d, x, b % x) {
          all_pass = false
        }
      }
    }
    all_pass
  }
}
