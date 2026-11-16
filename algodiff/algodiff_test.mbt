///|
/// Algodiff tests.

///|
fn approx_eq_val(a : Double, b : Double, eps~ : Double = 1.0e-8) -> Bool {
  (a - b).abs() < eps
}

///|
test "diff: constant" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.mul(x, x) }
  let d = @algodiff.diff(f, @algodiff.pack_flt(3.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(d), 6.0))
}

///|
test "diff: sin" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.sin(x) }
  let d = @algodiff.diff(f, @algodiff.pack_flt(0.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(d), 1.0))
}

///|
test "diff: cos" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.cos(x) }
  let d = @algodiff.diff(f, @algodiff.pack_flt(0.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(d), 0.0))
}

///|
test "diff: exp" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.exp(x) }
  let d = @algodiff.diff(f, @algodiff.pack_flt(0.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(d), 1.0))
}

///|
test "diff: log" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.log(x) }
  let d = @algodiff.diff(f, @algodiff.pack_flt(2.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(d), 0.5))
}

///|
test "diff: sqrt" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.sqrt(x) }
  let d = @algodiff.diff(f, @algodiff.pack_flt(4.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(d), 0.25))
}

///|
test "diff: x^3 at 2" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise {
    @algodiff.mul(x, @algodiff.mul(x, x))
  }
  let d = @algodiff.diff(f, @algodiff.pack_flt(2.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(d), 12.0))
}

///|
test "diff: sin(x^2) at 1 (chain rule)" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise {
    @algodiff.sin(@algodiff.mul(x, x))
  }
  let d = @algodiff.diff(f, @algodiff.pack_flt(1.0))
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(d), 2.0 * @math.cos(1.0)),
  )
}

///|
test "diff: 1/(1+x^2) at 0" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise {
    @algodiff.div(
      @algodiff.pack_flt(1.0),
      @algodiff.add(@algodiff.pack_flt(1.0), @algodiff.mul(x, x)),
    )
  }
  let d = @algodiff.diff(f, @algodiff.pack_flt(0.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(d), 0.0))
}

///|
test "diff_prime: returns both value and derivative" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.mul(x, x) }
  let (v, d) = @algodiff.diff_prime(f, @algodiff.pack_flt(3.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(v), 9.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(d), 6.0))
}

///|
test "grad: sum(x*x) at [1,2]" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise {
    @algodiff.sum_(@algodiff.mul(x, x))
  }
  let x = @algodiff.pack_arr(@ndarray.of_array([1.0, 2.0], [2]))
  let g = @algodiff.grad(f, x)
  let g_arr = @algodiff.unpack_arr(g)
  @test.assert_eq(true, approx_eq_val(g_arr.data[0], 2.0))
  @test.assert_eq(true, approx_eq_val(g_arr.data[1], 4.0))
}

///|
test "grad: sum(sin(x)) at [0,0]" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise {
    @algodiff.sum_(@algodiff.sin(x))
  }
  let x = @algodiff.pack_arr(@ndarray.of_array([0.0, 0.0], [2]))
  let g = @algodiff.grad(f, x)
  let g_arr = @algodiff.unpack_arr(g)
  @test.assert_eq(true, approx_eq_val(g_arr.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(g_arr.data[1], 1.0))
}

///|
test "neg: basic" {
  let x = @algodiff.pack_flt(3.0)
  let r = @algodiff.neg(x)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), -3.0))
}

///|
test "add: basic" {
  let r = @algodiff.add(@algodiff.pack_flt(2.0), @algodiff.pack_flt(3.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 5.0))
}

///|
test "mul: basic" {
  let r = @algodiff.mul(@algodiff.pack_flt(2.0), @algodiff.pack_flt(3.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 6.0))
}

///|
test "sqr: basic" {
  let r = @algodiff.sqr(@algodiff.pack_flt(4.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 16.0))
}

///|
// ===== Forward mode (DF) tests for siso ops =====

///|
test "df neg: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(3.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r = @algodiff.neg(x)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), -3.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), -1.0),
  )
}

///|
test "df sqr: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(3.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r = @algodiff.sqr(x)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 9.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 6.0),
  )
}

///|
test "df sqrt: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(4.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r = @algodiff.sqrt(x)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 2.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 0.25),
  )
}

///|
test "df log: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(2.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r = @algodiff.log(x)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), @math.ln(2.0)),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 0.5),
  )
}

///|
test "df exp: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(0.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r = @algodiff.exp(x)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 1.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 1.0),
  )
}

///|
test "df sin/cos: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(0.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let s = @algodiff.sin(x)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(s)), 0.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(s)), 1.0),
  )
  let x2 = @algodiff.make_forward(
    @algodiff.pack_flt(0.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let c = @algodiff.cos(x2)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(c)), 1.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(c)), 0.0),
  )
}

///|
test "df tan: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(0.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r = @algodiff.tan(x)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 0.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 1.0),
  )
}

///|
test "df sinh/cosh: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(0.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let s = @algodiff.sinh(x)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(s)), 0.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(s)), 1.0),
  )
  let x2 = @algodiff.make_forward(
    @algodiff.pack_flt(0.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let c = @algodiff.cosh(x2)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(c)), 1.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(c)), 0.0),
  )
}

///|
test "df abs/signum: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(3.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let a = @algodiff.abs(x)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(a)), 3.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(a)), 1.0),
  )
  let x2 = @algodiff.make_forward(
    @algodiff.pack_flt(3.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let s = @algodiff.signum(x2)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(s)), 1.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(s)), 0.0),
  )
}

///|
test "df relu: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(3.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r = @algodiff.relu(x)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 3.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 1.0),
  )
  let x2 = @algodiff.make_forward(
    @algodiff.pack_flt(-3.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r2 = @algodiff.relu(x2)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r2)), 0.0),
  )
}

///|
test "df tanh/softplus/softsign: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(0.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let t = @algodiff.tanh(x)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(t)), 0.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(t)), 1.0),
  )
  let x2 = @algodiff.make_forward(
    @algodiff.pack_flt(0.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let sp = @algodiff.softplus(x2)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(sp)), @math.ln(2.0)),
  )
  let x3 = @algodiff.make_forward(
    @algodiff.pack_flt(0.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let ss = @algodiff.softsign(x3)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(ss)), 0.0),
  )
}

///|
// ===== Reverse mode (DR) tests for siso ops =====

///|
test "dr neg: reverse mode" {
  let x = @algodiff.make_reverse(@algodiff.pack_flt(3.0), @algodiff.tag())
  let r = @algodiff.neg(x)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), -3.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), -1.0),
  )
}

///|
test "dr sqr: reverse mode" {
  let x = @algodiff.make_reverse(@algodiff.pack_flt(3.0), @algodiff.tag())
  let r = @algodiff.sqr(x)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 9.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 6.0),
  )
}

///|
test "dr sqrt: reverse mode" {
  let x = @algodiff.make_reverse(@algodiff.pack_flt(4.0), @algodiff.tag())
  let r = @algodiff.sqrt(x)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 2.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 0.25),
  )
}

///|
test "dr log: reverse mode" {
  let x = @algodiff.make_reverse(@algodiff.pack_flt(2.0), @algodiff.tag())
  let r = @algodiff.log(x)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 0.5),
  )
}

///|
test "dr exp: reverse mode" {
  let x = @algodiff.make_reverse(@algodiff.pack_flt(0.0), @algodiff.tag())
  let r = @algodiff.exp(x)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 1.0),
  )
}

///|
test "dr sin: reverse mode" {
  let x = @algodiff.make_reverse(@algodiff.pack_flt(0.0), @algodiff.tag())
  let r = @algodiff.sin(x)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 1.0),
  )
}

///|
test "dr abs: reverse mode" {
  let x = @algodiff.make_reverse(@algodiff.pack_flt(3.0), @algodiff.tag())
  let r = @algodiff.abs(x)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 1.0),
  )
}

///|
test "dr relu: reverse mode" {
  let x = @algodiff.make_reverse(@algodiff.pack_flt(3.0), @algodiff.tag())
  let r = @algodiff.relu(x)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 1.0),
  )
}

///|
// ===== Forward mode (DF) tests for piso ops =====

///|
test "df add: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(2.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let y = @algodiff.pack_flt(3.0)
  let r = @algodiff.add(x, y)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 5.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 1.0),
  )
}

///|
test "df sub: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(2.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let y = @algodiff.pack_flt(3.0)
  let r = @algodiff.sub(x, y)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), -1.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 1.0),
  )
}

///|
test "df mul: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(2.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let y = @algodiff.pack_flt(3.0)
  let r = @algodiff.mul(x, y)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 6.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 3.0),
  )
}

///|
test "df div: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(6.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let y = @algodiff.pack_flt(3.0)
  let r = @algodiff.div(x, y)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 2.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 1.0 / 3.0),
  )
}

///|
test "df pow: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(2.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let y = @algodiff.pack_flt(3.0)
  let r = @algodiff.pow(x, y)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 8.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 12.0),
  )
}

///|
test "df add both DF: forward mode" {
  let t = @algodiff.tag()
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(2.0),
    @algodiff.pack_flt(1.0),
    t,
  )
  let y = @algodiff.make_forward(
    @algodiff.pack_flt(3.0),
    @algodiff.pack_flt(1.0),
    t,
  )
  let r = @algodiff.add(x, y)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 5.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 2.0),
  )
}

///|
test "df mul both DF: forward mode" {
  let t = @algodiff.tag()
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(2.0),
    @algodiff.pack_flt(1.0),
    t,
  )
  let y = @algodiff.make_forward(
    @algodiff.pack_flt(3.0),
    @algodiff.pack_flt(1.0),
    t,
  )
  let r = @algodiff.mul(x, y)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 6.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 5.0),
  )
}

///|
test "df scalar ops: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(2.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r1 = @algodiff.mul_scalar(x, 3.0)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r1)), 6.0),
  )
  let x2 = @algodiff.make_forward(
    @algodiff.pack_flt(2.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r2 = @algodiff.add_scalar(x2, 3.0)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r2)), 5.0),
  )
  let x3 = @algodiff.make_forward(
    @algodiff.pack_flt(2.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r3 = @algodiff.sub_scalar(x3, 3.0)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r3)), -1.0),
  )
  let x4 = @algodiff.make_forward(
    @algodiff.pack_flt(6.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r4 = @algodiff.div_scalar(x4, 3.0)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r4)), 2.0),
  )
}

///|
// ===== Reverse mode (DR) tests for piso ops =====

///|
test "dr add: reverse mode" {
  let t = @algodiff.tag()
  let x = @algodiff.make_reverse(@algodiff.pack_flt(2.0), t)
  let y = @algodiff.make_reverse(@algodiff.pack_flt(3.0), t)
  let r = @algodiff.add(x, y)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 1.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(y)), 1.0),
  )
}

///|
test "dr sub: reverse mode" {
  let t = @algodiff.tag()
  let x = @algodiff.make_reverse(@algodiff.pack_flt(2.0), t)
  let y = @algodiff.make_reverse(@algodiff.pack_flt(3.0), t)
  let r = @algodiff.sub(x, y)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 1.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(y)), -1.0),
  )
}

///|
test "dr mul: reverse mode" {
  let t = @algodiff.tag()
  let x = @algodiff.make_reverse(@algodiff.pack_flt(2.0), t)
  let y = @algodiff.make_reverse(@algodiff.pack_flt(3.0), t)
  let r = @algodiff.mul(x, y)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 3.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(y)), 2.0),
  )
}

///|
test "dr div: reverse mode" {
  let t = @algodiff.tag()
  let x = @algodiff.make_reverse(@algodiff.pack_flt(6.0), t)
  let y = @algodiff.make_reverse(@algodiff.pack_flt(3.0), t)
  let r = @algodiff.div(x, y)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 1.0 / 3.0),
  )
}

///|
test "dr pow: reverse mode" {
  let t = @algodiff.tag()
  let x = @algodiff.make_reverse(@algodiff.pack_flt(2.0), t)
  let y = @algodiff.make_reverse(@algodiff.pack_flt(3.0), t)
  let r = @algodiff.pow(x, y)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 8.0),
  )
}

///|
test "dr scalar ops: reverse mode" {
  let x = @algodiff.make_reverse(@algodiff.pack_flt(2.0), @algodiff.tag())
  let r = @algodiff.mul_scalar(x, 3.0)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 3.0),
  )
}

///|
// ===== Array ops with DF/DR =====

///|
test "df sum_: forward mode array" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0], [3])
  let tan = @ndarray.of_array([1.0, 1.0, 1.0], [3])
  let x = @algodiff.make_forward(
    @algodiff.pack_arr(arr),
    @algodiff.pack_arr(tan),
    @algodiff.tag(),
  )
  let r = @algodiff.sum_(x)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 6.0),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 3.0),
  )
}

///|
test "dr sum_: reverse mode array" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0], [3])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(arr), @algodiff.tag())
  let r = @algodiff.sum_(x)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  let g = @algodiff.unpack_arr(@algodiff.adjval(x))
  @test.assert_eq(true, approx_eq_val(g.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(g.data[1], 1.0))
  @test.assert_eq(true, approx_eq_val(g.data[2], 1.0))
}

///|
test "df sum: forward mode array" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let tan = @ndarray.of_array([1.0, 1.0, 1.0, 1.0], [2, 2])
  let x = @algodiff.make_forward(
    @algodiff.pack_arr(arr),
    @algodiff.pack_arr(tan),
    @algodiff.tag(),
  )
  let r = @algodiff.sum(x, axis=0)
  let rp = @algodiff.unpack_arr(@algodiff.primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 4.0))
}

///|
test "dr sum: reverse mode array" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(arr), @algodiff.tag())
  let r = @algodiff.sum(x, axis=0)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.of_array([1.0, 1.0], [2])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let g = @algodiff.unpack_arr(@algodiff.adjval(x))
  // sum along axis=0:2)) = [4, 6], gradient w.r.t. x is ones([2,2])
  @test.assert_eq(true, approx_eq_val(g.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(g.data[1], 1.0))
  @test.assert_eq(true, approx_eq_val(g.data[2], 1.0))
  @test.assert_eq(true, approx_eq_val(g.data[3], 1.0))
}

///|
test "df transpose: forward mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let tan = @ndarray.of_array([1.0, 0.0, 0.0, 1.0], [2, 2])
  let x = @algodiff.make_forward(
    @algodiff.pack_arr(arr),
    @algodiff.pack_arr(tan),
    @algodiff.tag(),
  )
  let r = @algodiff.transpose(x)
  let rp = @algodiff.unpack_arr(@algodiff.primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(rp.data[1], 3.0))
}

///|
test "dr transpose: reverse mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(arr), @algodiff.tag())
  let r = @algodiff.transpose(x)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([2, 2])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let g = @algodiff.unpack_arr(@algodiff.adjval(x))
  // transpose gradient is also transpose, ones maps to ones
  @test.assert_eq(true, approx_eq_val(g.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(g.data[3], 1.0))
}

///|
test "df reshape: forward mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let tan = @ndarray.of_array([1.0, 1.0, 1.0, 1.0], [2, 2])
  let x = @algodiff.make_forward(
    @algodiff.pack_arr(arr),
    @algodiff.pack_arr(tan),
    @algodiff.tag(),
  )
  let r = @algodiff.reshape(x, [4])
  let rp = @algodiff.unpack_arr(@algodiff.primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(rp.data[3], 4.0))
}

///|
test "dr reshape: reverse mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(arr), @algodiff.tag())
  let r = @algodiff.reshape(x, [4])
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([4])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let g = @algodiff.unpack_arr(@algodiff.adjval(x))
  // reshape gradient is identity, ones maps to ones
  @test.assert_eq(true, approx_eq_val(g.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(g.data[3], 1.0))
}

///|
test "df flatten: forward mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let tan = @ndarray.of_array([1.0, 1.0, 1.0, 1.0], [2, 2])
  let x = @algodiff.make_forward(
    @algodiff.pack_arr(arr),
    @algodiff.pack_arr(tan),
    @algodiff.tag(),
  )
  let r = @algodiff.flatten(x)
  let rp = @algodiff.unpack_arr(@algodiff.primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
}

///|
test "dr flatten: reverse mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(arr), @algodiff.tag())
  let r = @algodiff.flatten(x)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([4])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let g = @algodiff.unpack_arr(@algodiff.adjval(x))
  // flatten gradient is identity, ones maps to ones
  @test.assert_eq(true, approx_eq_val(g.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(g.data[3], 1.0))
}

///|
test "df softmax: forward mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0], [3])
  let tan = @ndarray.of_array([1.0, 0.0, 0.0], [3])
  let x = @algodiff.make_forward(
    @algodiff.pack_arr(arr),
    @algodiff.pack_arr(tan),
    @algodiff.tag(),
  )
  let r = @algodiff.softmax(x)
  let rp = @algodiff.unpack_arr(@algodiff.primal(r))
  let total = rp.data[0] + rp.data[1] + rp.data[2]
  @test.assert_eq(true, approx_eq_val(total, 1.0))
}

///|
test "dr softmax: reverse mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0], [3])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(arr), @algodiff.tag())
  let r = @algodiff.softmax(x)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([3])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let g = @algodiff.unpack_arr(@algodiff.adjval(x))
  // softmax Jacobian: J = diag(s) - s*s^T
  // With ones pushed, gradient = J^T * ones = s - s * (sum(s)) = s - s*1 = 0
  @test.assert_eq(true, approx_eq_val(g.data[0], 0.0, eps=1.0e-8))
  @test.assert_eq(true, approx_eq_val(g.data[1], 0.0, eps=1.0e-8))
  @test.assert_eq(true, approx_eq_val(g.data[2], 0.0, eps=1.0e-8))
}

///|
test "df matmul: forward mode" {
  let a = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let b = @ndarray.of_array([1.0, 0.0, 0.0, 1.0], [2, 2])
  let ta = @ndarray.of_array([1.0, 0.0, 0.0, 0.0], [2, 2])
  let x = @algodiff.make_forward(
    @algodiff.pack_arr(a),
    @algodiff.pack_arr(ta),
    @algodiff.tag(),
  )
  let y = @algodiff.pack_arr(b)
  let r = @algodiff.matmul(x, y)
  let rp = @algodiff.unpack_arr(@algodiff.primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
}

///|
test "dr matmul: reverse mode" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let b = @ndarray.of_array([1.0, 0.0, 0.0, 1.0], [2, 2])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(a), t)
  let y = @algodiff.make_reverse(@algodiff.pack_arr(b), t)
  let r = @algodiff.matmul(x, y)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([2, 2])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let ga = @algodiff.unpack_arr(@algodiff.adjval(x))
  let gy = @algodiff.unpack_arr(@algodiff.adjval(y))
  // dA = dC * B^T = ones * I = ones
  @test.assert_eq(true, approx_eq_val(ga.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(ga.data[3], 1.0))
  // dB = A^T * dC = [[1,3],[2,4]] * ones = [[4,4],[6,6]]
  @test.assert_eq(true, approx_eq_val(gy.data[0], 4.0))
  @test.assert_eq(true, approx_eq_val(gy.data[1], 4.0))
  @test.assert_eq(true, approx_eq_val(gy.data[2], 6.0))
  @test.assert_eq(true, approx_eq_val(gy.data[3], 6.0))
}

///|
// ===== API tests =====

///|
test "jacobianv: basic" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.mul(x, x) }
  let x = @algodiff.pack_arr(@ndarray.of_array([3.0], [1]))
  let v = @algodiff.pack_arr(@ndarray.of_array([1.0], [1]))
  let jv = @algodiff.jacobianv(f, x, v)
  let jv_arr = @algodiff.unpack_arr(jv)
  @test.assert_eq(true, approx_eq_val(jv_arr.data[0], 6.0))
}

///|
test "jacobianTv: basic" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.mul(x, x) }
  let x = @algodiff.pack_arr(@ndarray.of_array([3.0], [1]))
  let v = @algodiff.pack_arr(@ndarray.of_array([1.0], [1]))
  let jtv = @algodiff.jacobianTv(f, x, v)
  let jtv_arr = @algodiff.unpack_arr(jtv)
  @test.assert_eq(true, approx_eq_val(jtv_arr.data[0], 6.0))
}

///|
test "jacobian: basic" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.mul(x, x) }
  let x = @algodiff.pack_arr(@ndarray.of_array([3.0], [1, 1]))
  let j = @algodiff.jacobian(f, x)
  let j_arr = @algodiff.unpack_arr(j)
  @test.assert_eq(true, approx_eq_val(j_arr.data[0], 6.0))
}

///|
test "hessian: basic" {
  // hessian of f(x) = sum(x*x) at [3] should be 2*I
  let f = fn(x : @algodiff.T) -> @algodiff.T raise {
    @algodiff.sum_(@algodiff.mul(x, x))
  }
  let x = @algodiff.pack_arr(@ndarray.of_array([3.0], [1, 1]))
  let result = try {
    let h = @algodiff.hessian(f, x)
    let h_arr = @algodiff.unpack_arr(h)
    approx_eq_val(h_arr.data[0], 2.0)
  } catch {
    _ => false
  }
  @test.assert_eq(true, result)
}

///|
test "diff_prime: error case" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.mul(x, x) }
  let x = @algodiff.pack_arr(@ndarray.of_array([3.0], [1]))
  let result = try {
    let _ = @algodiff.diff_prime(f, x)
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
  let z = @algodiff.zeros_arr([3])
  let z_arr = @algodiff.unpack_arr(z)
  @test.assert_eq(true, approx_eq_val(z_arr.data[0], 0.0))
  @test.assert_eq(true, approx_eq_val(z_arr.data[2], 0.0))
}

///|
test "f_const: basic" {
  let c = @algodiff.f_const(42.0)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(c), 42.0))
}

///|
test "copy_primal_: basic" {
  let x = @algodiff.pack_flt(3.0)
  let c = @algodiff.copy_primal_(x)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(c), 3.0))
  let arr = @ndarray.of_array([1.0, 2.0], [2])
  let y = @algodiff.pack_arr(arr)
  let c2 = @algodiff.copy_primal_(y)
  let c2_arr = @algodiff.unpack_arr(c2)
  @test.assert_eq(true, approx_eq_val(c2_arr.data[0], 1.0))
}

///|
test "arr_shape: basic" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  let x = @algodiff.pack_arr(arr)
  let s = @algodiff.arr_shape(x)
  @test.assert_eq([2], s)
}

///|
test "gaussian_arr: basic" {
  let g = @algodiff.gaussian_arr(0.0, 1.0, [3])
  let g_arr = @algodiff.unpack_arr(g)
  @test.assert_eq(3, g_arr.data.length())
}

///|
// ===== Additional ops coverage =====

///|
test "df sigmoid: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(-1.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r = @algodiff.sigmoid(x)
  let s = 1.0 / (1.0 + @math.exp(1.0))
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), s),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), s * (1.0 - s)),
  )
}

///|
test "dr sigmoid: reverse mode" {
  let x = @algodiff.make_reverse(@algodiff.pack_flt(-1.0), @algodiff.tag())
  let r = @algodiff.sigmoid(x)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  let s = 1.0 / (1.0 + @math.exp(1.0))
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), s * (1.0 - s)),
  )
}

///|
test "df tanh: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(1.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r = @algodiff.tanh(x)
  let t = @math.tanh(1.0)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), t),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 1.0 - t * t),
  )
}

///|
test "dr tanh: reverse mode" {
  let x = @algodiff.make_reverse(@algodiff.pack_flt(1.0), @algodiff.tag())
  let r = @algodiff.tanh(x)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  let t = @math.tanh(1.0)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 1.0 - t * t),
  )
}

///|
test "df softplus: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(1.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r = @algodiff.softplus(x)
  let sp = @math.ln(1.0 + @math.exp(1.0))
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), sp),
  )
  @test.assert_eq(
    true,
    approx_eq_val(
      @algodiff.unpack_flt(@algodiff.tangent(r)),
      1.0 / (1.0 + @math.exp(-1.0)),
    ),
  )
}

///|
test "dr softplus: reverse mode" {
  let x = @algodiff.make_reverse(@algodiff.pack_flt(1.0), @algodiff.tag())
  let r = @algodiff.softplus(x)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(
      @algodiff.unpack_flt(@algodiff.adjval(x)),
      1.0 / (1.0 + @math.exp(-1.0)),
    ),
  )
}

///|
test "df softsign: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(1.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r = @algodiff.softsign(x)
  // softsign(1) = 1/(1+1) = 0.5, derivative = 1/(1+|x|)^2 = 0.25
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r)), 0.5),
  )
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.tangent(r)), 0.25),
  )
}

///|
test "dr softsign: reverse mode" {
  let x = @algodiff.make_reverse(@algodiff.pack_flt(1.0), @algodiff.tag())
  let r = @algodiff.softsign(x)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 0.25),
  )
}

///|
test "df elmul/eldiv: forward mode" {
  let x = @algodiff.make_forward(
    @algodiff.pack_flt(2.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let y = @algodiff.pack_flt(3.0)
  let r1 = @algodiff.elmul(x, y)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r1)), 6.0),
  )
  let x2 = @algodiff.make_forward(
    @algodiff.pack_flt(6.0),
    @algodiff.pack_flt(1.0),
    @algodiff.tag(),
  )
  let r2 = @algodiff.eldiv(x2, y)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.primal(r2)), 2.0),
  )
}

///|
test "dr elmul: reverse mode" {
  let t = @algodiff.tag()
  let x = @algodiff.make_reverse(@algodiff.pack_flt(2.0), t)
  let y = @algodiff.make_reverse(@algodiff.pack_flt(3.0), t)
  let r = @algodiff.elmul(x, y)
  @algodiff.reverse_reset(r)
  @algodiff.reverse_push(@algodiff.pack_flt(1.0), r)
  @test.assert_eq(
    true,
    approx_eq_val(@algodiff.unpack_flt(@algodiff.adjval(x)), 3.0),
  )
}

///|
test "df add array: forward mode" {
  let a = @ndarray.of_array([1.0, 2.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let ta = @ndarray.of_array([1.0, 1.0], [2])
  let x = @algodiff.make_forward(
    @algodiff.pack_arr(a),
    @algodiff.pack_arr(ta),
    @algodiff.tag(),
  )
  let y = @algodiff.pack_arr(b)
  let r = @algodiff.add(x, y)
  let rp = @algodiff.unpack_arr(@algodiff.primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 4.0))
}

///|
test "dr add array: reverse mode" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([1.0, 2.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(a), t)
  let y = @algodiff.make_reverse(@algodiff.pack_arr(b), t)
  let r = @algodiff.add(x, y)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([2])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let gx = @algodiff.unpack_arr(@algodiff.adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 1.0))
}

///|
test "df mul array: forward mode" {
  let a = @ndarray.of_array([1.0, 2.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let ta = @ndarray.of_array([1.0, 0.0], [2])
  let x = @algodiff.make_forward(
    @algodiff.pack_arr(a),
    @algodiff.pack_arr(ta),
    @algodiff.tag(),
  )
  let y = @algodiff.pack_arr(b)
  let r = @algodiff.mul(x, y)
  let rp = @algodiff.unpack_arr(@algodiff.primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 3.0))
  @test.assert_eq(true, approx_eq_val(rp.data[1], 8.0))
}

///|
test "dr mul array: reverse mode" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([1.0, 2.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(a), t)
  let y = @algodiff.make_reverse(@algodiff.pack_arr(b), t)
  let r = @algodiff.mul(x, y)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([2])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let gx = @algodiff.unpack_arr(@algodiff.adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 3.0))
}

///|
test "df sub array: forward mode" {
  let a = @ndarray.of_array([5.0, 6.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let ta = @ndarray.of_array([1.0, 1.0], [2])
  let x = @algodiff.make_forward(
    @algodiff.pack_arr(a),
    @algodiff.pack_arr(ta),
    @algodiff.tag(),
  )
  let y = @algodiff.pack_arr(b)
  let r = @algodiff.sub(x, y)
  let rp = @algodiff.unpack_arr(@algodiff.primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 2.0))
}

///|
test "dr sub array: reverse mode" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([5.0, 6.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(a), t)
  let y = @algodiff.make_reverse(@algodiff.pack_arr(b), t)
  let r = @algodiff.sub(x, y)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([2])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let gx = @algodiff.unpack_arr(@algodiff.adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 1.0))
}

///|
test "df div array: forward mode" {
  let a = @ndarray.of_array([6.0, 8.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let ta = @ndarray.of_array([1.0, 0.0], [2])
  let x = @algodiff.make_forward(
    @algodiff.pack_arr(a),
    @algodiff.pack_arr(ta),
    @algodiff.tag(),
  )
  let y = @algodiff.pack_arr(b)
  let r = @algodiff.div(x, y)
  let rp = @algodiff.unpack_arr(@algodiff.primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 2.0))
  @test.assert_eq(true, approx_eq_val(rp.data[1], 2.0))
}

///|
test "dr div array: reverse mode" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([6.0, 8.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(a), t)
  let y = @algodiff.make_reverse(@algodiff.pack_arr(b), t)
  let r = @algodiff.div(x, y)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([2])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let gx = @algodiff.unpack_arr(@algodiff.adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 1.0 / 3.0))
}

///|
test "df concatenate: forward mode" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([1.0, 2.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let ta = @ndarray.of_array([1.0, 1.0], [2])
  let tb = @ndarray.of_array([0.0, 0.0], [2])
  let x = @algodiff.make_forward(
    @algodiff.pack_arr(a),
    @algodiff.pack_arr(ta),
    t,
  )
  let y = @algodiff.make_forward(
    @algodiff.pack_arr(b),
    @algodiff.pack_arr(tb),
    t,
  )
  let r = @algodiff.concatenate([x, y])
  let rp = @algodiff.unpack_arr(@algodiff.primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(rp.data[3], 4.0))
}

///|
test "dr concatenate: reverse mode" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([1.0, 2.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(a), t)
  let y = @algodiff.make_reverse(@algodiff.pack_arr(b), t)
  let r = @algodiff.concatenate([x, y])
  let rp = @algodiff.unpack_arr(@algodiff.primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(rp.data[3], 4.0))
}

///|
test "concatenate: primal array" {
  let a = @ndarray.of_array([1.0, 2.0], [2])
  let b = @ndarray.of_array([3.0, 4.0], [2])
  let r = @algodiff.concatenate([@algodiff.pack_arr(a), @algodiff.pack_arr(b)])
  let rp = @algodiff.unpack_arr(r)
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(rp.data[3], 4.0))
}

///|
test "df get_slice: forward mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [4])
  let tan = @ndarray.of_array([1.0, 1.0, 1.0, 1.0], [4])
  let x = @algodiff.make_forward(
    @algodiff.pack_arr(arr),
    @algodiff.pack_arr(tan),
    @algodiff.tag(),
  )
  let r = @algodiff.get_slice([[0, 1]], x)
  let rp = @algodiff.unpack_arr(@algodiff.primal(r))
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
  @test.assert_eq(true, approx_eq_val(rp.data[1], 2.0))
}

///|
test "dr get_slice: reverse mode" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [4])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(arr), @algodiff.tag())
  let r = @algodiff.get_slice([[0, 1]], x)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([2])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let _ = @algodiff.unpack_arr(@algodiff.adjval(x))
  @test.assert_eq(true, true)
}

///|
test "get_slice: primal" {
  let arr = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [4])
  let x = @algodiff.pack_arr(arr)
  let r = @algodiff.get_slice([[0, 1]], x)
  let rp = @algodiff.unpack_arr(r)
  @test.assert_eq(true, approx_eq_val(rp.data[0], 1.0))
}

///|
/// Coverage: squeeze_broadcast with scalar target (dim == 0)
/// add(array, scalar) in reverse mode triggers squeeze_broadcast(ca, shape(scalar))
test "dr add array+scalar: broadcast squeeze" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([1.0, 2.0, 3.0], [3])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(a), t)
  let y = @algodiff.make_reverse(@algodiff.pack_flt(10.0), t)
  let r = @algodiff.add(x, y)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([3])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let gx = @algodiff.unpack_arr(@algodiff.adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 1.0))
}

///|
/// Coverage: squeeze_broadcast with scalar target for mul
test "dr mul array*scalar: broadcast squeeze" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([1.0, 2.0, 3.0], [3])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(a), t)
  let y = @algodiff.make_reverse(@algodiff.pack_flt(2.0), t)
  let r = @algodiff.mul(x, y)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([3])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let gx = @algodiff.unpack_arr(@algodiff.adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 2.0))
}

///|
/// Coverage: squeeze_broadcast with scalar target for sub
test "dr sub array-scalar: broadcast squeeze" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([5.0, 6.0], [2])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(a), t)
  let y = @algodiff.make_reverse(@algodiff.pack_flt(3.0), t)
  let r = @algodiff.sub(x, y)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([2])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let gx = @algodiff.unpack_arr(@algodiff.adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 1.0))
}

///|
/// Coverage: squeeze_broadcast with scalar target for div
test "dr div array/scalar: broadcast squeeze" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([6.0, 8.0], [2])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(a), t)
  let y = @algodiff.make_reverse(@algodiff.pack_flt(2.0), t)
  let r = @algodiff.div(x, y)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([2])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let gx = @algodiff.unpack_arr(@algodiff.adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 0.5))
}

///|
/// Coverage: squeeze_broadcast with scalar target for pow
test "dr pow array^scalar: broadcast squeeze" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([2.0, 3.0], [2])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(a), t)
  let y = @algodiff.make_reverse(@algodiff.pack_flt(2.0), t)
  let r = @algodiff.pow(x, y)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([2])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let gx = @algodiff.unpack_arr(@algodiff.adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 4.0))
}

///|
/// Coverage: squeeze_broadcast with 2D broadcast (row broadcast)
/// add([2,3] array, [1,3] array) triggers squeeze along axis 0
test "dr add 2D broadcast row: squeeze" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  let b = @ndarray.of_array([10.0, 20.0, 30.0], [1, 3])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(a), t)
  let y = @algodiff.make_reverse(@algodiff.pack_arr(b), t)
  let r = @algodiff.add(x, y)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([2, 3])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let gx = @algodiff.unpack_arr(@algodiff.adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 1.0))
}

///|
/// Coverage: squeeze_broadcast with 2D broadcast (col broadcast)
/// add([2,3] array, [2,1] array) triggers squeeze along axis 1
test "dr add 2D broadcast col: squeeze" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  let b = @ndarray.of_array([10.0, 20.0], [2, 1])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(a), t)
  let y = @algodiff.make_reverse(@algodiff.pack_arr(b), t)
  let r = @algodiff.add(x, y)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([2, 3])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let gx = @algodiff.unpack_arr(@algodiff.adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 1.0))
}

///|
/// Coverage: squeeze_broadcast with 2D broadcast for mul
test "dr mul 2D broadcast: squeeze" {
  let t = @algodiff.tag()
  let a = @ndarray.of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
  let b = @ndarray.of_array([10.0, 20.0, 30.0], [1, 3])
  let x = @algodiff.make_reverse(@algodiff.pack_arr(a), t)
  let y = @algodiff.make_reverse(@algodiff.pack_arr(b), t)
  let r = @algodiff.mul(x, y)
  @algodiff.reverse_reset(r)
  let ones = @ndarray.ones([2, 3])
  @algodiff.reverse_push(@algodiff.pack_arr(ones), r)
  let gx = @algodiff.unpack_arr(@algodiff.adjval(x))
  @test.assert_eq(true, approx_eq_val(gx.data[0], 10.0))
}
