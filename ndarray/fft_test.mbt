///|
/// FFT 测试：解析已知 DFT 结果、round-trip、Parseval 定理、参数校验。

///|
/// 相对误差 |a - b| / max(|b|, 1)
fn fft_rel_err(a : Double, b : Double) -> Double {
  (a - b).abs() / b.abs().max(1.0)
}

///|
test "fft: delta function transforms to all ones" {
  let x = @ndarray.of_array([1.0, 0.0, 0.0, 0.0], [4])
  let (re, im) = @ndarray.fft(x)
  for i in 0..<4 {
    assert_true(fft_rel_err(@ndarray.get(re, [i]), 1.0) < 1.0e-12)
    assert_true(@ndarray.get(im, [i]).abs() < 1.0e-12)
  }
}

///|
test "fft: constant sequence concentrates at zero frequency" {
  let x = @ndarray.of_array([1.0, 1.0, 1.0, 1.0], [4])
  let (re, im) = @ndarray.fft(x)
  assert_true((@ndarray.get(re, [0]) - 4.0).abs() < 1.0e-12)
  for i in 1..<4 {
    assert_true(@ndarray.get(re, [i]).abs() < 1.0e-12)
    assert_true(@ndarray.get(im, [i]).abs() < 1.0e-12)
  }
}

///|
test "fft: unit impulse at one matches analytic dft" {
  // DFT[k] = e^{-2 pi i k / 4}: re=[1,0,-1,0], im=[0,-1,0,1]
  let x = @ndarray.of_array([0.0, 1.0, 0.0, 0.0], [4])
  let (re, im) = @ndarray.fft(x)
  let exp_re = [1.0, 0.0, -1.0, 0.0]
  let exp_im = [0.0, -1.0, 0.0, 1.0]
  for i in 0..<4 {
    assert_true((@ndarray.get(re, [i]) - exp_re[i]).abs() < 1.0e-12)
    assert_true((@ndarray.get(im, [i]) - exp_im[i]).abs() < 1.0e-12)
  }
}

///|
test "fft/ifft round trip recovers input" {
  let x = @ndarray.of_array([1.0, 2.5, -0.3, 4.0, 0.7, -1.2, 2.2, 0.0], [8])
  let (re, im) = @ndarray.fft(x)
  let y = @ndarray.ifft(re, im)
  for i in 0..<8 {
    assert_true((@ndarray.get(y, [i]) - @ndarray.get(x, [i])).abs() < 1.0e-12)
  }
}

///|
test "fft: parseval theorem" {
  let x = @ndarray.of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0], [8])
  let (re, im) = @ndarray.fft(x)
  let mut energy_t = 0.0
  for i in 0..<8 {
    let v = @ndarray.get(x, [i])
    energy_t += v * v
  }
  let mut energy_f = 0.0
  for i in 0..<8 {
    energy_f += @ndarray.get(re, [i]) * @ndarray.get(re, [i]) +
      @ndarray.get(im, [i]) * @ndarray.get(im, [i])
  }
  // sum|x|^2 = (1/n) sum|X|^2
  assert_true((energy_f / 8.0 - energy_t).abs() < 1.0e-9)
}

///|
test "fft: single-frequency sine peaks at expected bin" {
  // x[k] = sin(2 pi k / 8), 预计算值（sqrt2/2 = 0.7071067811865476）
  let vals = [
    0.0, 0.7071067811865476, 1.0, 0.7071067811865476, 0.0, -0.7071067811865476, -1.0,
    -0.7071067811865476,
  ]
  let x = @ndarray.of_array(vals, [8])
  let (re, im) = @ndarray.fft(x)
  let mag1 = @ndarray.get(re, [1]) * @ndarray.get(re, [1]) +
    @ndarray.get(im, [1]) * @ndarray.get(im, [1])
  let mag3 = @ndarray.get(re, [3]) * @ndarray.get(re, [3]) +
    @ndarray.get(im, [3]) * @ndarray.get(im, [3])
  assert_true(mag1 > 15.0)
  assert_true(mag3 < 1.0e-8)
}

///|
test "fft: rejects non-power-of-two and non-1d input" {
  let bad = @ndarray.of_array([1.0, 2.0, 3.0], [3])
  let bad2d = @ndarray.of_array([1.0, 2.0, 3.0, 4.0], [2, 2])
  try @ndarray.fft(bad) catch {
    @core.OwlError::InvalidArgument(_) =>
      inspect("rejected non-power-of-two", content="rejected non-power-of-two")
    _ => fail("expected InvalidArgument for non-power-of-two")
  } noraise {
    _ => fail("expected raise for non-power-of-two")
  }
  try @ndarray.fft(bad2d) catch {
    @core.OwlError::InvalidArgument(_) =>
      inspect("rejected non-1d", content="rejected non-1d")
    _ => fail("expected InvalidArgument for non-1d")
  } noraise {
    _ => fail("expected raise for non-1d")
  }
  // n=1 合法（空变换）
  let one = @ndarray.of_array([5.0], [1])
  let (re1, im1) = @ndarray.fft(one)
  assert_true((@ndarray.get(re1, [0]) - 5.0).abs() < 1.0e-12)
  assert_true(@ndarray.get(im1, [0]).abs() < 1.0e-12)
}
