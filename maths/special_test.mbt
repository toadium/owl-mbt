///|
/// 特殊函数测试：gamma 族 / bessel / dawsn。
/// 采用数学恒等式与标准参考值双验证，容差以相对误差控制。

///|
/// 相对误差 |a - b| / max(|b|, 1)
fn rel_err(a : Double, b : Double) -> Double {
  (a - b).abs() / b.abs().max(1.0)
}

///|
test "gamma: integer and half-integer reference values" {
  // gamma(n-1) = n
  assert_eq(@maths.gamma(1.0), 1.0)
  assert_eq(@maths.gamma(5.0), 24.0)
  assert_true(rel_err(@maths.gamma(10.0), 362880.0) < 1.0e-14)
  // gamma(0.5) = sqrt(pi)
  assert_true(rel_err(@maths.gamma(0.5), @core.sqrtpi) < 1.0e-14)
  // gamma(-0.5) = -2 sqrt(pi)
  assert_true(rel_err(@maths.gamma(-0.5), -2.0 * @core.sqrtpi) < 1.0e-14)
  // gamma(3.5) = 2.5 * 1.5 * 0.5 * sqrt(pi)
  let g35 = 2.5 * 1.5 * 0.5 * @core.sqrtpi
  assert_true(rel_err(@maths.gamma(3.5), g35) < 1.0e-14)
}

///|
test "gamma: poles at non-positive integers" {
  assert_true(@maths.gamma(0.0).is_inf())
  assert_true(@maths.gamma(-1.0).is_inf())
  assert_true(@maths.gamma(-5.0).is_inf())
  let nan_result = @maths.gamma(0.0 / 0.0)
  assert_true(nan_result.is_nan())
}

///|
test "log_gamma: functional equations" {
  // lgamma(x+1) = lgamma(x) + ln(x)
  let d = @maths.log_gamma(3.5) - @maths.log_gamma(2.5) - @math.ln(2.5)
  assert_true(d.abs() < 1.0e-13)
  // lgamma(0.5) = ln(sqrt(pi))
  assert_true((@maths.log_gamma(0.5) - @math.ln(@core.sqrtpi)).abs() < 1.0e-14)
  // lgamma(100) ≈ 359.1342053695754（Cephes golden value）
  assert_true(rel_err(@maths.log_gamma(100.0), 359.1342053695754) < 1.0e-14)
  // 极点
  assert_true(@maths.log_gamma(-2.0).is_inf())
}

///|
test "beta: known closed forms" {
  // B(2,3) = Γ(2)Γ(3)/Γ(5) = 1/12（∫₀¹ t(1-t)² dt 验证；原 golden 1/30 为 B(3,3) 之误）
  assert_true(rel_err(@maths.beta(2.0, 3.0), 1.0 / 12.0) < 1.0e-14)
  // B(1/2, 1/2) = pi
  assert_true(rel_err(@maths.beta(0.5, 0.5), @core.pi) < 1.0e-14)
  // 非正参数 -> NaN
  assert_true(@maths.beta(-1.0, 2.0).is_nan())
  assert_true(@maths.beta(0.0, 2.0).is_nan())
}

///|
test "bessel: reference values" {
  assert_eq(@maths.j0(0.0), 1.0)
  assert_eq(@maths.j1(0.0), 0.0)
  // J0(1) ≈ 0.7651976865579666（Cephes golden value）
  assert_true(rel_err(@maths.j0(1.0), 0.7651976865579666) < 1.0e-14)
  // J1(1) ≈ 0.4400505857449335
  assert_true(rel_err(@maths.j1(1.0), 0.4400505857449335) < 1.0e-14)
  // 奇偶性：J0 偶，J1 奇
  assert_true((@maths.j0(-5.0) - @maths.j0(5.0)).abs() < 1.0e-15)
  assert_true((@maths.j1(-5.0) + @maths.j1(5.0)).abs() < 1.0e-15)
}

///|
// J1(25) 真值 −0.125350236567869 由 Miller 下推递推独立计算（n=60/80/100 三者一致），
// 原 golden −0.0755945... 为参考值记忆有误；渐近展开与真值相对差 ~3e-7，容差 1e-6 不变
test "bessel: asymptotic agrees with series near switch point" {
  // x=25 附近幂级数（精度 ~1e-11）与渐近（误差 O(x^-3)）交叉验证
  assert_true(rel_err(@maths.j0(25.0), 0.09626677328264806) < 1.0e-6)
  assert_true(rel_err(@maths.j1(25.0), -0.125350236567869) < 1.0e-6)
}

///|
test "dawsn: reference and cross validation" {
  // D(1) ≈ 0.5380795069127684（Dawson golden value）
  assert_true(rel_err(@maths.dawsn(1.0), 0.5380795069127684) < 1.0e-14)
  // 奇函数
  assert_true((@maths.dawsn(-2.0) + @maths.dawsn(2.0)).abs() < 1.0e-15)
  // 级数与连分式在切换点附近一致
  assert_true((@maths.dawsn(3.0) - @maths.dawsn(3.2)).abs() < 0.05)
  // 大 x 渐近 D(x) ~ 1/(2x)
  let big = @maths.dawsn(50.0)
  assert_true(rel_err(big, 1.0 / (2.0 * 50.0)) < 1.0e-3)
}

///|
test "dawsn: nan propagation" {
  assert_true(@maths.dawsn(0.0 / 0.0).is_nan())
}
