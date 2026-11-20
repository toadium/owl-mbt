///|
/// 覆盖率补强 — erf / erfc / erfcx
/// Coverage-gap tests for the error functions.

///|
test "erf and erfc basic values" {
  assert_true(erf(0.0).abs() < 1.0e-12)
  assert_true((erf(1.0) - 0.8427007929).abs() < 1.0e-6)
  assert_true((erfc(1.0) - 0.1572992071).abs() < 1.0e-6)
  assert_true((erf(-1.0) + 0.8427007929).abs() < 1.0e-6)
}

///|
test "erfcx scaled complementary error function" {
  assert_true((erfcx(0.0) - 1.0).abs() < 1.0e-9)
  assert_true(erfcx(1.0) > 0.0)
}
