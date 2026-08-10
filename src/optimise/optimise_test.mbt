///|
/// Optimise tests.

///|
fn approx_eq_val(a : Double, b : Double, eps? : Double = 1.0e-4) -> Bool {
  (a - b).abs() < eps
}

///|
test "minimise_fun: minimise (x-3)^2" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise {
    @algodiff.sqr(@algodiff.sub(x, @algodiff.pack_flt(3.0)))
  }
  let params = default_params()
  params.set_epochs(100.0)
  params.set_learning_rate(lr_const(0.1))
  let (_, x_opt) = minimise_fun(params, f, @algodiff.pack_flt(0.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(x_opt), 3.0))
}

///|
test "minimise_fun: minimise x^2 + 2x + 1 = (x+1)^2" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise {
    @algodiff.add(
      @algodiff.add(@algodiff.sqr(x), @algodiff.mul(@algodiff.pack_flt(2.0), x)),
      @algodiff.pack_flt(1.0),
    )
  }
  let params = default_params()
  params.set_epochs(100.0)
  params.set_learning_rate(lr_const(0.1))
  let (_, x_opt) = minimise_fun(params, f, @algodiff.pack_flt(0.0))
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(x_opt), -1.0))
}

///|
test "minimise_fun: minimise sum(x^2) at [1,1]" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise {
    @algodiff.sum_(@algodiff.sqr(x))
  }
  let params = default_params()
  params.set_epochs(200.0)
  params.set_learning_rate(lr_const(0.1))
  let x_init = @algodiff.pack_arr(@ndarray.of_array([1.0, 1.0], [2]))
  let (_, x_opt) = minimise_fun(params, f, x_init)
  let x_arr = @algodiff.unpack_arr(x_opt)
  @test.assert_eq(true, approx_eq_val(x_arr.data[0], 0.0, eps=1.0e-3))
  @test.assert_eq(true, approx_eq_val(x_arr.data[1], 0.0, eps=1.0e-3))
}

///|
test "learning_rate: Const" {
  let r = run_learning_rate(lr_const(0.01), 5, @algodiff.pack_flt(1.0), [
    @algodiff.pack_flt(0.0),
  ])
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 0.01))
}

///|
test "learning_rate: Decay" {
  let r = run_learning_rate(lr_decay(0.1, 0.1), 10, @algodiff.pack_flt(1.0), [
    @algodiff.pack_flt(0.0),
  ])
  let expected = 0.1 / (1.0 + 0.1 * 10.0)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), expected))
}

///|
test "momentum: Standard" {
  let u = @algodiff.pack_flt(1.0)
  let u_new = @algodiff.pack_flt(0.5)
  let r = run_momentum(mom_standard(0.9), u, u_new)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 0.9 * 1.0 + 0.5))
}

///|
test "momentum: None" {
  let u = @algodiff.pack_flt(1.0)
  let u_new = @algodiff.pack_flt(0.5)
  let r = run_momentum(mom_none(), u, u_new)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 0.5))
}
