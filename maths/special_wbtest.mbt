///|
/// 覆盖率补强 — 特殊函数分支（signum/sigmoid/dawsn/xlogy/logit/expit/log1mexp/log1pexp）
/// Coverage-gap tests for special functions.

///|
test "signum covers nan/positive/negative/zero" {
  assert_true(signum(0.0 / 0.0).is_nan())
  assert_eq(signum(2.0), 1.0)
  assert_eq(signum(-2.0), -1.0)
  assert_eq(signum(0.0), 0.0)
}

///|
test "sigmoid is monotone and centered at 0.5" {
  assert_true((sigmoid(0.0) - 0.5).abs() < 1.0e-12)
  assert_true(sigmoid(5.0) > sigmoid(0.0))
}

///|
test "dawsn covers series and asymptotic branches" {
  assert_true(dawsn(0.0 / 0.0).is_nan())
  let small = dawsn(0.5)
  let big = dawsn(10.0)
  assert_true(small > 0.0 && small < 0.5)
  assert_true(big > 0.0 && big < 0.1)
  assert_true((dawsn(-0.5) + dawsn(0.5)).abs() < 1.0e-12)
}

///|
test "xlogy zero convention and xlog1py" {
  assert_eq(xlogy(0.0, 3.0), 0.0)
  assert_true((xlogy(2.0, 2.718281828459045) - 2.0).abs() < 1.0e-9)
  assert_eq(xlog1py(0.0, 3.0), 0.0)
  assert_true(xlog1py(1.0, 1.0) > 0.0)
}

///|
test "logit/expit inverse and log1mexp/log1pexp branches" {
  assert_true((expit(0.0) - 0.5).abs() < 1.0e-12)
  assert_true(logit(0.5).abs() < 1.0e-12)
  assert_true((expit(logit(0.3)) - 0.3).abs() < 1.0e-9)
  assert_true(log1mexp(-1.0) < 0.0)
  assert_true(log1mexp(-10.0) < 0.0)
  assert_true((log1pexp(-40.0) - @math.exp(-40.0)).abs() < 1.0e-12)
  assert_true(log1pexp(0.0) > 0.0)
  assert_true((log1pexp(40.0) - 40.0).abs() < 1.0e-9)
}
