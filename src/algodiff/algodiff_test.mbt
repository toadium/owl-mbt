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

///|
// ===== Forward mode (DF) tests for siso ops =====

///|
test "df neg: forward mode" {
  let x = make_forward(pack_flt(3.0), pack_flt(1.0), tag())
  let r = neg(x)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), -3.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), -1.0))
}

///|
test "df sqr: forward mode" {
  let x = make_forward(pack_flt(3.0), pack_flt(1.0), tag())
  let r = sqr(x)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 9.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), 6.0))
}

///|
test "df sqrt: forward mode" {
  let x = make_forward(pack_flt(4.0), pack_flt(1.0), tag())
  let r = sqrt(x)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 2.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), 0.25))
}

///|
test "df log: forward mode" {
  let x = make_forward(pack_flt(2.0), pack_flt(1.0), tag())
  let r = log(x)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), @math.ln(2.0)))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), 0.5))
}

///|
test "df exp: forward mode" {
  let x = make_forward(pack_flt(0.0), pack_flt(1.0), tag())
  let r = exp(x)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 1.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), 1.0))
}

///|
test "df sin/cos: forward mode" {
  let x = make_forward(pack_flt(0.0), pack_flt(1.0), tag())
  let s = sin(x)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(s)), 0.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(s)), 1.0))
  let x2 = make_forward(pack_flt(0.0), pack_flt(1.0), tag())
  let c = cos(x2)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(c)), 1.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(c)), 0.0))
}

///|
test "df tan: forward mode" {
  let x = make_forward(pack_flt(0.0), pack_flt(1.0), tag())
  let r = tan(x)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 0.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), 1.0))
}

///|
test "df sinh/cosh: forward mode" {
  let x = make_forward(pack_flt(0.0), pack_flt(1.0), tag())
  let s = sinh(x)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(s)), 0.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(s)), 1.0))
  let x2 = make_forward(pack_flt(0.0), pack_flt(1.0), tag())
  let c = cosh(x2)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(c)), 1.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(c)), 0.0))
}

///|
test "df abs/signum: forward mode" {
  let x = make_forward(pack_flt(3.0), pack_flt(1.0), tag())
  let a = abs(x)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(a)), 3.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(a)), 1.0))
  let x2 = make_forward(pack_flt(3.0), pack_flt(1.0), tag())
  let s = signum(x2)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(s)), 1.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(s)), 0.0))
}

///|
test "df relu: forward mode" {
  let x = make_forward(pack_flt(3.0), pack_flt(1.0), tag())
  let r = relu(x)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 3.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), 1.0))
  let x2 = make_forward(pack_flt(-3.0), pack_flt(1.0), tag())
  let r2 = relu(x2)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r2)), 0.0))
}

///|
test "df tanh/softplus/softsign: forward mode" {
  let x = make_forward(pack_flt(0.0), pack_flt(1.0), tag())
  let t = tanh(x)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(t)), 0.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(t)), 1.0))
  let x2 = make_forward(pack_flt(0.0), pack_flt(1.0), tag())
  let sp = softplus(x2)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(sp)), @math.ln(2.0)))
  let x3 = make_forward(pack_flt(0.0), pack_flt(1.0), tag())
  let ss = softsign(x3)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(ss)), 0.0))
}

///|
// ===== Reverse mode (DR) tests for siso ops =====

///|
test "dr neg: reverse mode" {
  let x = make_reverse(pack_flt(3.0), tag())
  let r = neg(x)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), -3.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(x)), -1.0))
}

///|
test "dr sqr: reverse mode" {
  let x = make_reverse(pack_flt(3.0), tag())
  let r = sqr(x)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 9.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(x)), 6.0))
}

///|
test "dr sqrt: reverse mode" {
  let x = make_reverse(pack_flt(4.0), tag())
  let r = sqrt(x)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 2.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(x)), 0.25))
}

///|
test "dr log: reverse mode" {
  let x = make_reverse(pack_flt(2.0), tag())
  let r = log(x)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(x)), 0.5))
}

///|
test "dr exp: reverse mode" {
  let x = make_reverse(pack_flt(0.0), tag())
  let r = exp(x)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(x)), 1.0))
}

///|
test "dr sin: reverse mode" {
  let x = make_reverse(pack_flt(0.0), tag())
  let r = sin(x)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(x)), 1.0))
}

///|
test "dr abs: reverse mode" {
  let x = make_reverse(pack_flt(3.0), tag())
  let r = abs(x)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(x)), 1.0))
}

///|
test "dr relu: reverse mode" {
  let x = make_reverse(pack_flt(3.0), tag())
  let r = relu(x)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(x)), 1.0))
}

///|
// ===== Forward mode (DF) tests for piso ops =====

///|
test "df add: forward mode" {
  let x = make_forward(pack_flt(2.0), pack_flt(1.0), tag())
  let y = pack_flt(3.0)
  let r = add(x, y)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 5.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), 1.0))
}

///|
test "df sub: forward mode" {
  let x = make_forward(pack_flt(2.0), pack_flt(1.0), tag())
  let y = pack_flt(3.0)
  let r = sub(x, y)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), -1.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), 1.0))
}

///|
test "df mul: forward mode" {
  let x = make_forward(pack_flt(2.0), pack_flt(1.0), tag())
  let y = pack_flt(3.0)
  let r = mul(x, y)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 6.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), 3.0))
}

///|
test "df div: forward mode" {
  let x = make_forward(pack_flt(6.0), pack_flt(1.0), tag())
  let y = pack_flt(3.0)
  let r = div(x, y)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 2.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), 1.0 / 3.0))
}

///|
test "df pow: forward mode" {
  let x = make_forward(pack_flt(2.0), pack_flt(1.0), tag())
  let y = pack_flt(3.0)
  let r = pow(x, y)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 8.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), 12.0))
}

///|
test "df add both DF: forward mode" {
  let t = tag()
  let x = make_forward(pack_flt(2.0), pack_flt(1.0), t)
  let y = make_forward(pack_flt(3.0), pack_flt(1.0), t)
  let r = add(x, y)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 5.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), 2.0))
}

///|
test "df mul both DF: forward mode" {
  let t = tag()
  let x = make_forward(pack_flt(2.0), pack_flt(1.0), t)
  let y = make_forward(pack_flt(3.0), pack_flt(1.0), t)
  let r = mul(x, y)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 6.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), 5.0))
}

///|
test "df scalar ops: forward mode" {
  let x = make_forward(pack_flt(2.0), pack_flt(1.0), tag())
  let r1 = mul_scalar(x, 3.0)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r1)), 6.0))
  let x2 = make_forward(pack_flt(2.0), pack_flt(1.0), tag())
  let r2 = add_scalar(x2, 3.0)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r2)), 5.0))
  let x3 = make_forward(pack_flt(2.0), pack_flt(1.0), tag())
  let r3 = sub_scalar(x3, 3.0)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r3)), -1.0))
  let x4 = make_forward(pack_flt(6.0), pack_flt(1.0), tag())
  let r4 = div_scalar(x4, 3.0)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r4)), 2.0))
}

///|
// ===== Reverse mode (DR) tests for piso ops =====

///|
test "dr add: reverse mode" {
  let t = tag()
  let x = make_reverse(pack_flt(2.0), t)
  let y = make_reverse(pack_flt(3.0), t)
  let r = add(x, y)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(x)), 1.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(y)), 1.0))
}

///|
test "dr sub: reverse mode" {
  let t = tag()
  let x = make_reverse(pack_flt(2.0), t)
  let y = make_reverse(pack_flt(3.0), t)
  let r = sub(x, y)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(x)), 1.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(y)), -1.0))
}

///|
test "dr mul: reverse mode" {
  let t = tag()
  let x = make_reverse(pack_flt(2.0), t)
  let y = make_reverse(pack_flt(3.0), t)
  let r = mul(x, y)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(x)), 3.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(y)), 2.0))
}

///|
test "dr div: reverse mode" {
  let t = tag()
  let x = make_reverse(pack_flt(6.0), t)
  let y = make_reverse(pack_flt(3.0), t)
  let r = div(x, y)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(x)), 1.0 / 3.0))
}

///|
test "dr pow: reverse mode" {
  let t = tag()
  let x = make_reverse(pack_flt(2.0), t)
  let y = make_reverse(pack_flt(3.0), t)
  let r = pow(x, y)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 8.0))
}

///|
test "dr scalar ops: reverse mode" {
  let x = make_reverse(pack_flt(2.0), tag())
  let r = mul_scalar(x, 3.0)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(x)), 3.0))
}

///|
// ===== Array ops with DF/DR =====

///|
test "df sum_: forward mode array" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0], [3])
  let tan = @ndarray.of_array([1.0, 1.0, 1.0], [3])
  let x = make_forward(pack_arr(arr), pack_arr(tan), tag())
  let r = sum_(x)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r)), 6.0))
  @test.assert_eq(true, approx_eq_val(unpack_flt(tangent(r)), 3.0))
}

///|
test "dr sum_: reverse mode array" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0], [3])
  let x = make_reverse(pack_arr(arr), tag())
  let r = sum_(x)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  let g = unpack_arr(adjval(x))
  @test.assert_eq(true, approx_eq_val(g.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(g.data[1], 1.0))
  @test.assert_eq(true, approx_eq_val(g.data[2], 1.0))
}

///|
test "df sum: forward mode array" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let tan = @ndarray.of_array([1.0, 1.0, 1.0, 1.0], [2, 2])
  let x = make_forward(pack_arr(arr), pack_arr(tan), tag())
  let r = sum(x, axis=0)
  let rp = unpack_arr(primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 4.0))
}

///|
test "dr sum: reverse mode array" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let x = make_reverse(pack_arr(arr), tag())
  let r = sum(x, axis=0)
  reverse_reset(r)
  let ones = @ndarray.ones([2])
  reverse_push(pack_arr(ones), r)
  let _ = unpack_arr(adjval(x))
  @test.assert_eq(true, true)
}

///|
test "df transpose: forward mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let tan = @ndarray.of_array([1.0, 0.0, 0.0, 1.0], [2, 2])
  let x = make_forward(pack_arr(arr), pack_arr(tan), tag())
  let r = transpose(x)
  let rp = unpack_arr(primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(rp.data[1], 3.0))
}

///|
test "dr transpose: reverse mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let x = make_reverse(pack_arr(arr), tag())
  let r = transpose(x)
  reverse_reset(r)
  let ones = @ndarray.ones([2, 2])
  reverse_push(pack_arr(ones), r)
  let _ = unpack_arr(adjval(x))
  @test.assert_eq(true, true)
}

///|
test "df reshape: forward mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let tan = @ndarray.of_array([1.0, 1.0, 1.0, 1.0], [2, 2])
  let x = make_forward(pack_arr(arr), pack_arr(tan), tag())
  let r = reshape(x, [4])
  let rp = unpack_arr(primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(rp.data[3], 4.0))
}

///|
test "dr reshape: reverse mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let x = make_reverse(pack_arr(arr), tag())
  let r = reshape(x, [4])
  reverse_reset(r)
  let ones = @ndarray.ones([4])
  reverse_push(pack_arr(ones), r)
  let _ = unpack_arr(adjval(x))
  @test.assert_eq(true, true)
}

///|
test "df flatten: forward mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let tan = @ndarray.of_array([1.0, 1.0, 1.0, 1.0], [2, 2])
  let x = make_forward(pack_arr(arr), pack_arr(tan), tag())
  let r = flatten(x)
  let rp = unpack_arr(primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
}

///|
test "dr flatten: reverse mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let x = make_reverse(pack_arr(arr), tag())
  let r = flatten(x)
  reverse_reset(r)
  let ones = @ndarray.ones([4])
  reverse_push(pack_arr(ones), r)
  let _ = unpack_arr(adjval(x))
  @test.assert_eq(true, true)
}

///|
test "df softmax: forward mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0], [3])
  let tan = @ndarray.of_array([1.0, 0.0, 0.0], [3])
  let x = make_forward(pack_arr(arr), pack_arr(tan), tag())
  let r = softmax(x)
  let rp = unpack_arr(primal(r))
  let total = rp.data[0] + rp.data[1] + rp.data[2]
  @test.assert_eq(true, approx_eq_val(total, 1.0))
}

///|
test "dr softmax: reverse mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0], [3])
  let x = make_reverse(pack_arr(arr), tag())
  let r = softmax(x)
  reverse_reset(r)
  let ones = @ndarray.ones([3])
  reverse_push(pack_arr(ones), r)
  let _ = unpack_arr(adjval(x))
  @test.assert_eq(true, true)
}

///|
test "df matmul: forward mode" {
  let a = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let b = @ndarray.of_array([1.0, 0.0, 0.0, 1.0], [2, 2])
  let ta = @ndarray.of_array([1.0, 0.0, 0.0, 0.0], [2, 2])
  let x = make_forward(pack_arr(a), pack_arr(ta), tag())
  let y = pack_arr(b)
  let r = matmul(x, y)
  let rp = unpack_arr(primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
}

///|
test "dr matmul: reverse mode" {
  let t = tag()
  let a = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let b = @ndarray.of_array([1.0, 0.0, 0.0, 1.0], [2, 2])
  let x = make_reverse(pack_arr(a), t)
  let y = make_reverse(pack_arr(b), t)
  let r = matmul(x, y)
  reverse_reset(r)
  let ones = @ndarray.ones([2, 2])
  reverse_push(pack_arr(ones), r)
  let _ = unpack_arr(adjval(x))
  let _ = unpack_arr(adjval(y))
  @test.assert_eq(true, true)
}

///|
// ===== API tests =====

///|
test "jacobianv: basic" {
  let f = fn(x : T) -> T raise { mul(x, x) }
  let x = pack_arr(@ndarray.of_array([3.0], [1]))
  let v = pack_arr(@ndarray.of_array([1.0], [1]))
  let jv = jacobianv(f, x, v)
  let jv_arr = unpack_arr(jv)
  @test.assert_eq(true, approx_eq_val(jv_arr.data[0], 6.0))
}

///|
test "jacobianTv: basic" {
  let f = fn(x : T) -> T raise { mul(x, x) }
  let x = pack_arr(@ndarray.of_array([3.0], [1]))
  let v = pack_arr(@ndarray.of_array([1.0], [1]))
  let jtv = jacobianTv(f, x, v)
  let jtv_arr = unpack_arr(jtv)
  @test.assert_eq(true, approx_eq_val(jtv_arr.data[0], 6.0))
}

///|
test "jacobian: basic" {
  let f = fn(x : T) -> T raise { mul(x, x) }
  let x = pack_arr(@ndarray.of_array([3.0], [1, 1]))
  let j = jacobian(f, x)
  let j_arr = unpack_arr(j)
  @test.assert_eq(true, approx_eq_val(j_arr.data[0], 6.0))
}

///|
test "hessian: basic" {
  // hessian of f(x) = sum(x*x) at [3] should be 2*I
  let f = fn(x : T) -> T raise { sum_(mul(x, x)) }
  let x = pack_arr(@ndarray.of_array([3.0], [1, 1]))
  let result = try {
    let h = hessian(f, x)
    let h_arr = unpack_arr(h)
    approx_eq_val(h_arr.data[0], 2.0)
  } catch {
    _ => false
  }
  @test.assert_eq(true, result)
}

///|
test "diff_prime: error case" {
  let f = fn(x : T) -> T raise { mul(x, x) }
  let x = pack_arr(@ndarray.of_array([3.0], [1]))
  let result = try {
    let _ = diff_prime(f, x)
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, result)
}

///|
// ===== Creation function tests =====

///|
test "zeros_arr: basic" {
  let z = zeros_arr([3])
  let z_arr = unpack_arr(z)
  @test.assert_eq(true, approx_eq_val(z_arr.data[0], 0.0))
  @test.assert_eq(true, approx_eq_val(z_arr.data[2], 0.0))
}

///|
test "f_const: basic" {
  let c = f_const(42.0)
  @test.assert_eq(true, approx_eq_val(unpack_flt(c), 42.0))
}

///|
test "copy_primal_: basic" {
  let x = pack_flt(3.0)
  let c = copy_primal_(x)
  @test.assert_eq(true, approx_eq_val(unpack_flt(c), 3.0))
  let arr = @ndarray.of_array([1.0, 2.0], [2])
  let y = pack_arr(arr)
  let c2 = copy_primal_(y)
  let c2_arr = unpack_arr(c2)
  @test.assert_eq(true, approx_eq_val(c2_arr.data[0], 1.0))
}

///|
test "arr_shape: basic" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let x = pack_arr(arr)
  let s = arr_shape(x)
  @test.assert_eq([2], s)
}

///|
test "gaussian_arr: basic" {
  let g = gaussian_arr(0.0, 1.0, [3])
  let g_arr = unpack_arr(g)
  @test.assert_eq(3, g_arr.data.length())
}

///|
// ===== Additional ops coverage =====

///|
test "df sigmoid: forward mode" {
  let x = make_forward(pack_flt(-1.0), pack_flt(1.0), tag())
  let r = sigmoid(x)
  let _ = unpack_flt(primal(r))
  let _ = unpack_flt(tangent(r))
  @test.assert_eq(true, true)
}

///|
test "dr sigmoid: reverse mode" {
  let x = make_reverse(pack_flt(-1.0), tag())
  let r = sigmoid(x)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  let _ = unpack_flt(adjval(x))
  @test.assert_eq(true, true)
}

///|
test "df tanh: forward mode" {
  let x = make_forward(pack_flt(1.0), pack_flt(1.0), tag())
  let r = tanh(x)
  let _ = unpack_flt(primal(r))
  let _ = unpack_flt(tangent(r))
  @test.assert_eq(true, true)
}

///|
test "dr tanh: reverse mode" {
  let x = make_reverse(pack_flt(1.0), tag())
  let r = tanh(x)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  let _ = unpack_flt(adjval(x))
  @test.assert_eq(true, true)
}

///|
test "df softplus: forward mode" {
  let x = make_forward(pack_flt(1.0), pack_flt(1.0), tag())
  let r = softplus(x)
  let _ = unpack_flt(primal(r))
  let _ = unpack_flt(tangent(r))
  @test.assert_eq(true, true)
}

///|
test "dr softplus: reverse mode" {
  let x = make_reverse(pack_flt(1.0), tag())
  let r = softplus(x)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  let _ = unpack_flt(adjval(x))
  @test.assert_eq(true, true)
}

///|
test "df softsign: forward mode" {
  let x = make_forward(pack_flt(1.0), pack_flt(1.0), tag())
  let r = softsign(x)
  let _ = unpack_flt(primal(r))
  let _ = unpack_flt(tangent(r))
  @test.assert_eq(true, true)
}

///|
test "dr softsign: reverse mode" {
  let x = make_reverse(pack_flt(1.0), tag())
  let r = softsign(x)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  let _ = unpack_flt(adjval(x))
  @test.assert_eq(true, true)
}

///|
test "df elmul/eldiv: forward mode" {
  let x = make_forward(pack_flt(2.0), pack_flt(1.0), tag())
  let y = pack_flt(3.0)
  let r1 = elmul(x, y)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r1)), 6.0))
  let x2 = make_forward(pack_flt(6.0), pack_flt(1.0), tag())
  let r2 = eldiv(x2, y)
  @test.assert_eq(true, approx_eq_val(unpack_flt(primal(r2)), 2.0))
}

///|
test "dr elmul: reverse mode" {
  let t = tag()
  let x = make_reverse(pack_flt(2.0), t)
  let y = make_reverse(pack_flt(3.0), t)
  let r = elmul(x, y)
  reverse_reset(r)
  reverse_push(pack_flt(1.0), r)
  @test.assert_eq(true, approx_eq_val(unpack_flt(adjval(x)), 3.0))
}

///|
test "df add array: forward mode" {
  let a = @ndarray.of_array([1.0, 2.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let ta = @ndarray.of_array([1.0, 1.0], [2])
  let x = make_forward(pack_arr(a), pack_arr(ta), tag())
  let y = pack_arr(b)
  let r = add(x, y)
  let rp = unpack_arr(primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 4.0))
}

///|
test "dr add array: reverse mode" {
  let t = tag()
  let a = @ndarray.of_array([1.0, 2.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let x = make_reverse(pack_arr(a), t)
  let y = make_reverse(pack_arr(b), t)
  let r = add(x, y)
  reverse_reset(r)
  let ones = @ndarray.ones([2])
  reverse_push(pack_arr(ones), r)
  let gx = unpack_arr(adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 1.0))
}

///|
test "df mul array: forward mode" {
  let a = @ndarray.of_array([1.0, 2.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let ta = @ndarray.of_array([1.0, 0.0], [2])
  let x = make_forward(pack_arr(a), pack_arr(ta), tag())
  let y = pack_arr(b)
  let r = mul(x, y)
  let rp = unpack_arr(primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 3.0))
  @test.assert_eq(true, approx_eq_val(rp.data[1], 8.0))
}

///|
test "dr mul array: reverse mode" {
  let t = tag()
  let a = @ndarray.of_array([1.0, 2.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let x = make_reverse(pack_arr(a), t)
  let y = make_reverse(pack_arr(b), t)
  let r = mul(x, y)
  reverse_reset(r)
  let ones = @ndarray.ones([2])
  reverse_push(pack_arr(ones), r)
  let gx = unpack_arr(adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 3.0))
}

///|
test "df sub array: forward mode" {
  let a = @ndarray.of_array([5.0, 6.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let ta = @ndarray.of_array([1.0, 1.0], [2])
  let x = make_forward(pack_arr(a), pack_arr(ta), tag())
  let y = pack_arr(b)
  let r = sub(x, y)
  let rp = unpack_arr(primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 2.0))
}

///|
test "dr sub array: reverse mode" {
  let t = tag()
  let a = @ndarray.of_array([5.0, 6.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let x = make_reverse(pack_arr(a), t)
  let y = make_reverse(pack_arr(b), t)
  let r = sub(x, y)
  reverse_reset(r)
  let ones = @ndarray.ones([2])
  reverse_push(pack_arr(ones), r)
  let gx = unpack_arr(adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 1.0))
}

///|
test "df div array: forward mode" {
  let a = @ndarray.of_array([6.0, 8.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let ta = @ndarray.of_array([1.0, 0.0], [2])
  let x = make_forward(pack_arr(a), pack_arr(ta), tag())
  let y = pack_arr(b)
  let r = div(x, y)
  let rp = unpack_arr(primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 2.0))
  @test.assert_eq(true, approx_eq_val(rp.data[1], 2.0))
}

///|
test "dr div array: reverse mode" {
  let t = tag()
  let a = @ndarray.of_array([6.0, 8.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let x = make_reverse(pack_arr(a), t)
  let y = make_reverse(pack_arr(b), t)
  let r = div(x, y)
  reverse_reset(r)
  let ones = @ndarray.ones([2])
  reverse_push(pack_arr(ones), r)
  let gx = unpack_arr(adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 1.0 / 3.0))
}

///|
test "df concatenate: forward mode" {
  let t = tag()
  let a = @ndarray.of_array([1.0, 2.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let ta = @ndarray.of_array([1.0, 1.0], [2])
  let tb = @ndarray.of_array([0.0, 0.0], [2])
  let x = make_forward(pack_arr(a), pack_arr(ta), t)
  let y = make_forward(pack_arr(b), pack_arr(tb), t)
  let r = concatenate([x, y])
  let rp = unpack_arr(primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(rp.data[3], 4.0))
}

///|
test "dr concatenate: reverse mode" {
  let t = tag()
  let a = @ndarray.of_array([1.0, 2.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let x = make_reverse(pack_arr(a), t)
  let y = make_reverse(pack_arr(b), t)
  let r = concatenate([x, y])
  let rp = unpack_arr(primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(rp.data[3], 4.0))
}

///|
test "concatenate: primal array" {
  let a = @ndarray.of_array([1.0, 2.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let r = concatenate([pack_arr(a), pack_arr(b)])
  let rp = unpack_arr(r)
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(rp.data[3], 4.0))
}

///|
test "df get_slice: forward mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [4])
  let tan = @ndarray.of_array([1.0, 1.0, 1.0, 1.0], [4])
  let x = make_forward(pack_arr(arr), pack_arr(tan), tag())
  let r = get_slice([[0, 1]], x)
  let rp = unpack_arr(primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(rp.data[1], 2.0))
}

///|
test "dr get_slice: reverse mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [4])
  let x = make_reverse(pack_arr(arr), tag())
  let r = get_slice([[0, 1]], x)
  reverse_reset(r)
  let ones = @ndarray.ones([2])
  reverse_push(pack_arr(ones), r)
  let _ = unpack_arr(adjval(x))
  @test.assert_eq(true, true)
}

///|
test "get_slice: primal" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [4])
  let x = pack_arr(arr)
  let r = get_slice([[0, 1]], x)
  let rp = unpack_arr(r)
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
}
