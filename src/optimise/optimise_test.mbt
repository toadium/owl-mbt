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

///|
test "learning_rate: Adagrad" {
  let r = run_learning_rate(lr_adagrad(0.1), 1, @algodiff.pack_flt(0.5), [
    @algodiff.pack_flt(1.0),
  ])
  let val = @algodiff.unpack_flt(r)
  @test.assert_eq(true, val > 0.0)
}

///|
test "learning_rate: ExpDecay" {
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
test "learning_rate: RMSprop" {
  let r = run_learning_rate(lr_rmsprop(0.1, 0.9), 1, @algodiff.pack_flt(0.5), [
    @algodiff.pack_flt(1.0),
  ])
  let val = @algodiff.unpack_flt(r)
  @test.assert_eq(true, val > 0.0)
}

///|
test "learning_rate: Adam" {
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
test "learning_rate: Schedule" {
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
test "update_ch: Adagrad" {
  let g = @algodiff.pack_flt(0.5)
  let ch = [@algodiff.pack_flt(1.0)]
  let ch2 = update_ch(lr_adagrad(0.1), g, ch)
  @test.assert_eq(1, ch2.length())
}

///|
test "update_ch: RMSprop" {
  let g = @algodiff.pack_flt(0.5)
  let ch = [@algodiff.pack_flt(1.0)]
  let ch2 = update_ch(lr_rmsprop(0.1, 0.9), g, ch)
  @test.assert_eq(1, ch2.length())
}

///|
test "update_ch: Adam" {
  let g = @algodiff.pack_flt(0.5)
  let ch = [@algodiff.pack_flt(0.1), @algodiff.pack_flt(0.05)]
  let ch2 = update_ch(lr_adam(0.001, 0.9, 0.999), g, ch)
  @test.assert_eq(2, ch2.length())
}

///|
test "update_ch: Const (default)" {
  let g = @algodiff.pack_flt(0.5)
  let ch = [@algodiff.pack_flt(1.0)]
  let ch2 = update_ch(lr_const(0.1), g, ch)
  @test.assert_eq(1, ch2.length())
}

///|
test "momentum: Nesterov" {
  let u = @algodiff.pack_flt(1.0)
  let u_new = @algodiff.pack_flt(0.5)
  let r = run_momentum(mom_nesterov(0.9), u, u_new)
  let expected = 0.9 * 0.9 * 1.0 + (0.9 + 1.0) * 0.5
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), expected))
}

///|
test "regularisation: L1norm" {
  let x = @algodiff.pack_arr(@ndarray.of_array([1.0, -2.0, 3.0], [3]))
  let r = run_regularisation(reg_l1norm(0.1), x)
  // 0.1 * (|1| + |-2| + |3|) = 0.1 * 6 = 0.6
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 0.6))
}

///|
test "regularisation: L2norm" {
  let x = @algodiff.pack_arr(@ndarray.of_array([1.0, 2.0, 3.0], [3]))
  let r = run_regularisation(reg_l2norm(0.1), x)
  // 0.1 * (1 + 4 + 9) = 0.1 * 14 = 1.4
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 1.4))
}

///|
test "regularisation: ElasticNet" {
  let x = @algodiff.pack_arr(@ndarray.of_array([1.0, -2.0], [2]))
  let r = run_regularisation(reg_elastic_net(0.1, 0.2), x)
  // 0.1 * (1 + 2) + 0.2 * (1 + 4) = 0.3 + 1.0 = 1.3
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 1.3))
}

///|
test "regularisation: None" {
  let x = @algodiff.pack_flt(1.0)
  let r = run_regularisation(reg_none(), x)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r), 0.0))
}

///|
test "clipping: all types" {
  let x = @algodiff.pack_flt(1.0)
  let r1 = run_clipping(clip_l2norm(1.0), x)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r1), 1.0))
  let r2 = run_clipping(clip_value(-1.0, 1.0), x)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r2), 1.0))
  let r3 = run_clipping(clip_none(), x)
  @test.assert_eq(true, approx_eq_val(@algodiff.unpack_flt(r3), 1.0))
}

///|
test "stopping: all types" {
  @test.assert_eq(true, run_stopping(stop_const(0.01), 0.001))
  @test.assert_eq(false, run_stopping(stop_const(0.01), 0.1))
  @test.assert_eq(false, run_stopping(stop_early(10, 5), 0.001))
  @test.assert_eq(false, run_stopping(stop_none(), 0.001))
}

///|
test "init_state: basic" {
  let s = init_state(10, 5.0)
  @test.assert_eq(0, s.current_batch)
  @test.assert_eq(10, s.batches_per_epoch)
  @test.assert_eq(50, s.batches)
  @test.assert_eq(false, s.stop)
}

///|
test "default_params: basic" {
  let p = default_params()
  @test.assert_eq(10.0, p.epochs)
  @test.assert_eq(false, p.verbosity)
  p.set_epochs(20.0)
  @test.assert_eq(20.0, p.epochs)
  p.set_learning_rate(lr_const(0.01))
  @test.assert_eq(true, true)
}
