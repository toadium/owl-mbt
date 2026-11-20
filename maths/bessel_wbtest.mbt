///|
/// 覆盖率补强 — Bessel J0/J1（级数分支 / 渐近分支 / 奇偶性 / NaN）
/// Coverage-gap tests for Bessel J0/J1.

///|
test "j0 and j1 at origin" {
  assert_true((j0(0.0) - 1.0).abs() < 1.0e-12)
  assert_true(j1(0.0).abs() < 1.0e-12)
}

///|
test "j0/j1 series branch (|x| <= 25)" {
  let v = j0(2.0)
  assert_true(v > 0.0 && v < 1.0)
  assert_true(j1(2.0) > 0.0)
}

///|
test "j0/j1 asymptotic branch (|x| > 25)" {
  let v = j0(30.0)
  assert_true(!v.is_nan())
  assert_true(v.abs() < 0.5)
  let w = j1(30.0)
  assert_true(!w.is_nan())
  assert_true(w.abs() < 0.5)
}

///|
test "j0 even / j1 odd / NaN passthrough" {
  assert_true((j0(-2.0) - j0(2.0)).abs() < 1.0e-12)
  assert_true((j1(-2.0) + j1(2.0)).abs() < 1.0e-12)
  assert_true(j0(0.0 / 0.0).is_nan())
  assert_true(j1(0.0 / 0.0).is_nan())
}
