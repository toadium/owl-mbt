///|
/// Algodiff tests.

///|
fn approx_eq_val(a : Double, b : Double, eps? : Double = 1.0e-8) -> Bool {
  (a - b).abs() < eps
}

///|
test "diff: constant" {
  let f = fn(x : T) -> T raise { mul(x, x) }
  let d = diff(f, pack_flt(3.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(d), 6.0))
}

///|
test "diff: sin" {
  let f = fn(x : T) -> T raise { sin(x) }
  let d = diff(f, pack_flt(0.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(d), 1.0))
}

///|
test "diff: cos" {
  let f = fn(x : T) -> T raise { cos(x) }
  let d = diff(f, pack_flt(0.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(d), 0.0))
}

///|
test "diff: exp" {
  let f = fn(x : T) -> T raise { exp(x) }
  let d = diff(f, pack_flt(0.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(d), 1.0))
}

///|
test "diff: log" {
  let f = fn(x : T) -> T raise { log(x) }
  let d = diff(f, pack_flt(2.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(d), 0.5))
}

///|
test "diff: sqrt" {
  let f = fn(x : T) -> T raise { sqrt(x) }
  let d = diff(f, pack_flt(4.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(d), 0.25))
}

///|
test "diff: x^3 at 2" {
  let f = fn(x : T) -> T raise { mul(x, mul(x, x)) }
  let d = diff(f, pack_flt(2.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(d), 12.0))
}

///|
test "diff: sin(x^2) at 1 (chain rule)" {
  let f = fn(x : T) -> T raise { sin(mul(x, x)) }
  let d = diff(f, pack_flt(1.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(d), 2.0 * @math.cos(1.0)))
}

///|
test "diff: 1/(1+x^2) at 0" {
  let f = fn(x : T) -> T raise {
    div(pack_flt(1.0), add(pack_flt(1.0), mul(x, x)))
  }
  let d = diff(f, pack_flt(0.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(d), 0.0))
}

///|
test "diff_prime: returns both value and derivative" {
  let f = fn(x : T) -> T raise { mul(x, x) }
  let (v, d) = diff_prime(f, pack_flt(3.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(v), 9.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(d), 6.0))
}

///|
test "grad: sum(x*x) at [1,2]" {
  let f = fn(x : T) -> T raise { sum_(mul(x, x)) }
  let x = pack_arr(@ndarray.of_array([1.0, 2.0], [2]))
  let g = grad(f, x)
  let g_arr = unpack_arr(g)
  @test.assert_eq(true, approx_eq_val(g_arr.data[0], 2.0))
  @test.assert_eq(true, approx_eq_val(g_arr.data[1], 4.0))
}

///|
test "grad: sum(sin(x)) at [0,0]" {
  let f = fn(x : T) -> T raise { sum_(sin(x)) }
  let x = pack_arr(@ndarray.of_array([0.0, 0.0], [2]))
  let g = grad(f, x)
  let g_arr = unpack_arr(g)
  @test.assert_eq(true, approx_eq_val(g_arr.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(g_arr.data[1], 1.0))
}

///|
test "neg: basic" {
  let x = pack_flt(3.0)
  let r = neg(x)
  @test.assert_eq(true, approx_eq_val(unpack_flt(r), -3.0))
}

///|
test "add: basic" {
  let r = add(pack_flt(2.0), pack_flt(3.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(r), 5.0))
}

///|
test "mul: basic" {
  let r = mul(pack_flt(2.0), pack_flt(3.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(r), 6.0))
}

///|
test "sqr: basic" {
  let r = sqr(pack_flt(4.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(r), 16.0))
}
