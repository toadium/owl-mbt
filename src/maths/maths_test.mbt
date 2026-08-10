///|
/// 基础算术与数学函数测试。golden values 来自 OCaml owl-base 参考行为。
test "basic arithmetic" {
  @test.assert_eq(@maths.add(1.0, 2.0), 3.0)
  @test.assert_eq(@maths.sub(5.0, 3.0), 2.0)
  @test.assert_eq(@maths.mul(2.0, 3.0), 6.0)
  @test.assert_eq(@maths.div(6.0, 2.0), 3.0)
  @test.assert_eq(@maths.sqrt(4.0), 2.0)
  @test.assert_eq(@maths.sqr(3.0), 9.0)
  @test.assert_eq(@maths.neg(5.0), -5.0)
  @test.assert_eq(@maths.abs(-7.0), 7.0)
  @test.assert_eq(@maths.reci(2.0), 0.5)
}

///|
test "exp and log" {
  @test.assert_eq(@maths.exp(0.0), 1.0)
  @test.assert_eq(@maths.log(1.0), 0.0)
  inspect(
    @maths.exp(1.0),
    content=(
      #|2.718281828459045
    ),
  )
  inspect(
    @maths.log(2.0),
    content=(
      #|0.6931471805599453
    ),
  )
  inspect(
    @maths.log2(8.0),
    content=(
      #|3
    ),
  )
  inspect(
    @maths.log10(1000.0),
    content=(
      #|3
    ),
  )
}

///|
test "trig" {
  @test.assert_eq(@maths.sin(0.0), 0.0)
  @test.assert_eq(@maths.cos(0.0), 1.0)
  inspect(
    @maths.sin(1.5707963267948966),
    content=(
      #|1
    ),
  )
  inspect(
    @maths.tan(0.7853981633974483),
    content=(
      #|0.9999999999999999
    ),
  )
}

///|
test "hyperbolic" {
  @test.assert_eq(@maths.sinh(0.0), 0.0)
  @test.assert_eq(@maths.cosh(0.0), 1.0)
  inspect(
    @maths.tanh(1.0),
    content=(
      #|0.7615941559557649
    ),
  )
}

///|
test "floor ceil round trunc fix" {
  @test.assert_eq(@maths.floor(2.7), 2.0)
  @test.assert_eq(@maths.ceil(2.3), 3.0)
  @test.assert_eq(@maths.round(2.4), 2.0)
  @test.assert_eq(@maths.round(2.6), 3.0)
  @test.assert_eq(@maths.trunc(-2.7), -2.0)
  @test.assert_eq(@maths.fix(-2.7), -2.0)
  @test.assert_eq(@maths.fix(2.7), 2.0)
}

///|
test "erf erfc" {
  @test.assert_eq(@maths.erf(0.0), 0.0)
  @test.assert_eq(@maths.erfc(0.0), 1.0)
  inspect(
    @maths.erf(1.0),
    content=(
      #|0.8427006897475899
    ),
  )
  inspect(
    @maths.erfc(1.0),
    content=(
      #|0.15729931025241006
    ),
  )
  inspect(
    @maths.erf(-1.0),
    content=(
      #|-0.8427006897475899
    ),
  )
}

///|
test "signum" {
  @test.assert_eq(@maths.signum(3.0), 1.0)
  @test.assert_eq(@maths.signum(-2.0), -1.0)
  @test.assert_eq(@maths.signum(0.0), 0.0)
  @test.assert_eq(@maths.is_nan(@maths.signum(0.0 / 0.0)), true)
}

///|
test "special functions" {
  inspect(
    @maths.softplus(0.0),
    content=(
      #|0.6931471805599453
    ),
  )
  inspect(
    @maths.expit(0.0),
    content=(
      #|0.5
    ),
  )
  inspect(
    @maths.log1pexp(0.0),
    content=(
      #|0.6931471805599453
    ),
  )
  inspect(
    @maths.xlogy(0.0, 5.0),
    content=(
      #|0
    ),
  )
  @test.assert_eq(@maths.xlogy(0.0, 5.0), 0.0)
}

///|
test "number theory: is_prime" {
  @test.assert_eq(@maths.is_prime(2), true)
  @test.assert_eq(@maths.is_prime(3), true)
  @test.assert_eq(@maths.is_prime(7), true)
  @test.assert_eq(@maths.is_prime(1), false)
  @test.assert_eq(@maths.is_prime(8), false)
  @test.assert_eq(@maths.is_prime(9), false)
  @test.assert_eq(@maths.is_prime(97), true)
  @test.assert_eq(@maths.is_prime(100), false)
  @test.assert_eq(@maths.is_prime(7919), true)
}

///|
test "number theory: mulmod powmod" {
  @test.assert_eq(@maths.mulmod(3, 4, 5), 2)
  @test.assert_eq(@maths.mulmod(0, 5, 7), 0)
  @test.assert_eq(@maths.mulmod(10, 10, 13), 9)
  @test.assert_eq(@maths.powmod(2, 10, 1000), 24)
  @test.assert_eq(@maths.powmod(2, 0, 5), 1)
  @test.assert_eq(@maths.powmod(3, 5, 7), 5)
}

///|
test "number theory: fermat_fact" {
  let (f0, f1) = @maths.fermat_fact(15)
  @test.assert_eq(f0 * f1, 15)
  let (g0, g1) = @maths.fermat_fact(21)
  @test.assert_eq(g0 * g1, 21)
}

///|
test "helpers: predicates" {
  @test.assert_eq(@maths.is_odd(3), true)
  @test.assert_eq(@maths.is_odd(4), false)
  @test.assert_eq(@maths.is_even(4), true)
  @test.assert_eq(@maths.is_even(3), false)
  @test.assert_eq(@maths.is_pow2(8), true)
  @test.assert_eq(@maths.is_pow2(6), false)
  @test.assert_eq(@maths.is_pow2(1), true)
  @test.assert_eq(@maths.is_int(3.0), true)
  @test.assert_eq(@maths.is_int(3.5), false)
  @test.assert_eq(@maths.is_sqr(9), true)
  @test.assert_eq(@maths.is_sqr(10), false)
  @test.assert_eq(@maths.is_sqr(16), true)
}

///|
test "helpers: same_sign" {
  @test.assert_eq(@maths.same_sign(1.0, 2.0), true)
  @test.assert_eq(@maths.same_sign(-1.0, -2.0), true)
  @test.assert_eq(@maths.same_sign(1.0, -2.0), false)
  @test.assert_eq(@maths.same_sign(0.0, 0.0), true)
}

///|
test "helpers: is_simplex" {
  @test.assert_eq(@maths.is_simplex([0.5, 0.3, 0.2]), true)
  @test.assert_eq(@maths.is_simplex([0.5, 0.5, 0.5]), false)
  @test.assert_eq(@maths.is_simplex([-0.1, 1.1]), false)
}

///|
test "mulmod rejects invalid inputs" {
  try @maths.mulmod(-1, 2, 5) catch {
    _ => ()
  } noraise {
    _ => fail("expected mulmod to reject negative a")
  }
}

///|
test "basic: pow fmod atan2 hypot" {
  @test.assert_eq(@maths.pow(2.0, 3.0), 8.0)
  @test.assert_eq(@maths.fmod(7.0, 3.0), 1.0)
  @test.assert_eq(@maths.atan2(0.0, 1.0), 0.0)
  @test.assert_eq(@maths.hypot(3.0, 4.0), 5.0)
}

///|
test "basic: softsign softplus cbrt" {
  @test.assert_eq(@maths.softsign(1.0), 0.5)
  @test.assert_eq(@maths.softplus(0.0), 0.6931471805599453)
  @test.assert_eq(@maths.cbrt(8.0), 2.0)
  @test.assert_eq(@maths.cbrt(-27.0), -3.0)
}

///|
test "basic: exp2 exp10 expm1 log1p" {
  @test.assert_eq(@maths.exp2(3.0), 8.0)
  @test.assert_eq(@maths.exp10(2.0), 100.0)
  @test.assert_eq(@maths.expm1(1.0), 1.718281828459045)
  @test.assert_eq(@maths.log1p(1.0), 0.6931471805599453)
}

///|
test "basic: cot sec csc" {
  @test.assert_eq(@maths.cot(0.7853981633974483), 1.0000000000000002)
  @test.assert_eq(@maths.sec(0.0), 1.0)
  @test.assert_eq(@maths.csc(1.5707963267948966), 1.0)
}

///|
test "basic: inverse trig" {
  @test.assert_eq(@maths.asin(0.0), 0.0)
  @test.assert_eq(@maths.acos(1.0), 0.0)
  @test.assert_eq(@maths.atan(0.0), 0.0)
  @test.assert_eq(@maths.acot(0.0), 1.5707963267948966)
  @test.assert_eq(@maths.asec(2.0), 1.0471975511965979)
  @test.assert_eq(@maths.acsc(2.0), 0.5235987755982989)
}

///|
test "basic: inverse hyperbolic" {
  @test.assert_eq(@maths.asinh(0.0), 0.0)
  @test.assert_eq(@maths.acosh(1.0), 0.0)
  @test.assert_eq(@maths.atanh(0.0), 0.0)
  @test.assert_eq(@maths.acoth(2.0), 0.5493061443340548)
  @test.assert_eq(@maths.asech(0.5), 1.3169578969248166)
  @test.assert_eq(@maths.acsch(1.0), 0.881373587019543)
}

///|
test "basic: relu both branches" {
  @test.assert_eq(@maths.relu(3.0), 3.0)
  @test.assert_eq(@maths.relu(-1.0), 0.0)
  @test.assert_eq(@maths.relu(0.0), 0.0)
}
