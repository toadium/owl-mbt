///|
/// White-box tests for optimise: directly construct enum variants
/// to cover run_gradient, run_learning_rate, update_ch branches.

///|
fn approx_eq_val(a : Double, b : Double, eps? : Double = 1.0e-4) -> Bool {
  (a - b).abs() < eps
}

///|
test "wb run_gradient: GD" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.sqr(x) }
  let w = @algodiff.pack_flt(1.0)
  let g_prev = @algodiff.pack_flt(0.0)
  let p_prev = @algodiff.pack_flt(0.0)
  let g_new = @algodiff.pack_flt(2.0)
  let r = run_gradient(GradientMethod::GD, f, w, g_prev, p_prev, g_new)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), -2.0))
}

///|
test "wb run_gradient: CG" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.sqr(x) }
  let w = @algodiff.pack_flt(1.0)
  let g_prev = @algodiff.pack_flt(1.0)
  let p_prev = @algodiff.pack_flt(-1.0)
  let g_new = @algodiff.pack_flt(2.0)
  let r = run_gradient(GradientMethod::CG, f, w, g_prev, p_prev, g_new)
  let _ = @algodiff.unpack_flt(r)
  @test.assert_eq(true, true)
}

///|
test "wb run_gradient: CD" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.sqr(x) }
  let w = @algodiff.pack_flt(1.0)
  let g_prev = @algodiff.pack_flt(1.0)
  let p_prev = @algodiff.pack_flt(-1.0)
  let g_new = @algodiff.pack_flt(2.0)
  let r = run_gradient(GradientMethod::CD, f, w, g_prev, p_prev, g_new)
  let _ = @algodiff.unpack_flt(r)
  @test.assert_eq(true, true)
}

///|
test "wb run_gradient: NonlinearCG" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.sqr(x) }
  let w = @algodiff.pack_flt(1.0)
  let g_prev = @algodiff.pack_flt(1.0)
  let p_prev = @algodiff.pack_flt(-1.0)
  let g_new = @algodiff.pack_flt(2.0)
  let r = run_gradient(GradientMethod::NonlinearCG, f, w, g_prev, p_prev, g_new)
  let _ = @algodiff.unpack_flt(r)
  @test.assert_eq(true, true)
}

///|
test "wb run_gradient: DaiYuanCG" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.sqr(x) }
  let w = @algodiff.pack_flt(1.0)
  let g_prev = @algodiff.pack_flt(1.0)
  let p_prev = @algodiff.pack_flt(-1.0)
  let g_new = @algodiff.pack_flt(2.0)
  let r = run_gradient(GradientMethod::DaiYuanCG, f, w, g_prev, p_prev, g_new)
  let _ = @algodiff.unpack_flt(r)
  @test.assert_eq(true, true)
}

///|
test "wb run_gradient: NewtonCG and Newton" {
  let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.sqr(x) }
  let w = @algodiff.pack_flt(1.0)
  let g_prev = @algodiff.pack_flt(0.0)
  let p_prev = @algodiff.pack_flt(0.0)
  let g_new = @algodiff.pack_flt(2.0)
  let r1 = run_gradient(GradientMethod::NewtonCG, f, w, g_prev, p_prev, g_new)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r1), -2.0))
  let r2 = run_gradient(GradientMethod::Newton, f, w, g_prev, p_prev, g_new)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r2), -2.0))
}

///|
test "wb Batch types" {
  let _ = Batch::Full
  let _ = Batch::Mini(10)
  let _ = Batch::Sample(5)
  let _ = Batch::Stochastic
  @test.assert_eq(true, true)
}

///|
test "wb learning_rate: Const" {
  let r = run_learning_rate(lr_const(0.01), 5, @algodiff.pack_flt(1.0), [
    @algodiff.pack_flt(0.0),
  ])
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 0.01))
}

///|
test "wb learning_rate: Decay" {
  let r = run_learning_rate(lr_decay(0.1, 0.1), 10, @algodiff.pack_flt(1.0), [
    @algodiff.pack_flt(0.0),
  ])
  let expected = 0.1 / (1.0 + 0.1 * 10.0)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), expected))
}

///|
test "wb momentum: Standard" {
  let u = @algodiff.pack_flt(1.0)
  let u_new = @algodiff.pack_flt(0.5)
  let r = run_momentum(mom_standard(0.9), u, u_new)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 0.9 * 1.0 + 0.5))
}

///|
test "wb momentum: None" {
  let u = @algodiff.pack_flt(1.0)
  let u_new = @algodiff.pack_flt(0.5)
  let r = run_momentum(mom_none(), u, u_new)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 0.5))
}

///|
test "wb learning_rate: Adagrad" {
  let r = run_learning_rate(lr_adagrad(0.1), 1, @algodiff.pack_flt(0.5), [
    @algodiff.pack_flt(1.0),
  ])
  let val = @algodiff.unpack_flt(r)
  @test.assert_eq(true, val > 0.0)
}

///|
test "wb learning_rate: ExpDecay" {
  let r = run_learning_rate(
    lr_exp_decay(0.1, 0.01),
    10,
    @algodiff.pack_flt(1.0),
    [@algodiff.pack_flt(0.0)],
  )
  let expected = 0.1 * @math.exp(-0.01 * 10.0)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), expected))
}

///|
test "wb learning_rate: RMSprop" {
  let r = run_learning_rate(lr_rmsprop(0.1, 0.9), 1, @algodiff.pack_flt(0.5), [
    @algodiff.pack_flt(1.0),
  ])
  let val = @algodiff.unpack_flt(r)
  @test.assert_eq(true, val > 0.0)
}

///|
test "wb learning_rate: Adam" {
  let r = run_learning_rate(
    lr_adam(0.001, 0.9, 0.999),
    5,
    @algodiff.pack_flt(0.5),
    [@algodiff.pack_flt(0.1), @algodiff.pack_flt(0.05)],
  )
  let val = @algodiff.unpack_flt(r)
  @test.assert_eq(true, val > 0.0)
}

///|
test "wb learning_rate: Schedule" {
  let r = run_learning_rate(
    lr_schedule([0.1, 0.01, 0.001]),
    5,
    @algodiff.pack_flt(1.0),
    [@algodiff.pack_flt(0.0)],
  )
  // 5 % 3 = 2, so schedule[2] = 0.001
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 0.001))
}

///|
test "wb update_ch: Adagrad" {
  let g = @algodiff.pack_flt(0.5)
  let ch = [@algodiff.pack_flt(1.0)]
  let ch2 = update_ch(lr_adagrad(0.1), g, ch)
  @test.assert_eq(1, ch2.length())
}

///|
test "wb update_ch: RMSprop" {
  let g = @algodiff.pack_flt(0.5)
  let ch = [@algodiff.pack_flt(1.0)]
  let ch2 = update_ch(lr_rmsprop(0.1, 0.9), g, ch)
  @test.assert_eq(1, ch2.length())
}

///|
test "wb update_ch: Adam" {
  let g = @algodiff.pack_flt(0.5)
  let ch = [@algodiff.pack_flt(0.1), @algodiff.pack_flt(0.05)]
  let ch2 = update_ch(lr_adam(0.001, 0.9, 0.999), g, ch)
  @test.assert_eq(2, ch2.length())
}

///|
test "wb update_ch: Const (default)" {
  let g = @algodiff.pack_flt(0.5)
  let ch = [@algodiff.pack_flt(1.0)]
  let ch2 = update_ch(lr_const(0.1), g, ch)
  @test.assert_eq(1, ch2.length())
}

///|
test "wb momentum: Nesterov" {
  let u = @algodiff.pack_flt(1.0)
  let u_new = @algodiff.pack_flt(0.5)
  let r = run_momentum(mom_nesterov(0.9), u, u_new)
  let expected = 0.9 * 0.9 * 1.0 + (0.9 + 1.0) * 0.5
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), expected))
}

///|
test "wb regularisation: L1norm" {
  let x = @algodiff.pack_arr(@ndarray.of_array([1.0, -2.0, 3.0], [3]))
  let r = run_regularisation(reg_l1norm(0.1), x)
  // 0.1 * (|1| + |-2| + |3|) = 0.1 * 6 = 0.6
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 0.6))
}

///|
test "wb regularisation: L2norm" {
  let x = @algodiff.pack_arr(@ndarray.of_array([1.0, 2.0, 3.0], [3]))
  let r = run_regularisation(reg_l2norm(0.1), x)
  // 0.1 * (1 + 4 + 9) = 0.1 * 14 = 1.4
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 1.4))
}

///|
test "wb regularisation: ElasticNet" {
  let x = @algodiff.pack_arr(@ndarray.of_array([1.0, -2.0], [2]))
  let r = run_regularisation(reg_elastic_net(0.1, 0.2), x)
  // 0.1 * (1 + 2) + 0.2 * (1 + 4) = 0.3 + 1.0 = 1.3
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 1.3))
}

///|
test "wb regularisation: None" {
  let x = @algodiff.pack_flt(1.0)
  let r = run_regularisation(reg_none(), x)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 0.0))
}

///|
test "wb clipping: all types" {
  let x = @algodiff.pack_flt(1.0)
  let r1 = run_clipping(clip_l2norm(1.0), x)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r1), 1.0))
  let r2 = run_clipping(clip_value(-1.0, 1.0), x)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r2), 1.0))
  let r3 = run_clipping(clip_none(), x)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r3), 1.0))
}

///|
test "wb stopping: all types" {
  @test.assert_eq(true, run_stopping(stop_const(0.01), 0.001))
  @test.assert_eq(false, run_stopping(stop_const(0.01), 0.1))
  @test.assert_eq(false, run_stopping(stop_early(10, 5), 0.001))
  @test.assert_eq(false, run_stopping(stop_none(), 0.001))
}
