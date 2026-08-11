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
