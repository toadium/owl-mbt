///|
/// 覆盖率补强 — KDE（Scott/Silverman 带宽、点集生成、异常路径）
/// Coverage-gap tests for gaussian KDE.

///|
test "gaussian_kde: default Scott produces points and positive density" {
  let (points, pdf) = gaussian_kde([1.0, 2.0, 3.0, 4.0, 5.0])
  assert_eq(points.length(), 512)
  assert_eq(pdf.length(), 512)
  let total = pdf.fold(init=0.0, fn(acc, v) { acc + v })
  assert_true(total > 0.0)
}

///|
test "gaussian_kde: Silverman bandwidth with custom point count" {
  let (points, pdf) = gaussian_kde(
    [1.0, 2.0, 3.0, 4.0],
    bandwidth=Bandwidth::Silverman,
    n_points=16,
  )
  assert_eq(points.length(), 16)
  assert_eq(pdf.length(), 16)
  assert_true(points[0] < points[15])
}

///|
test "gaussian_kde: rejects single-sample and constant data" {
  let mut single = false
  try {
    let _ = gaussian_kde([1.0])
  } catch {
    @core.OwlError::InvalidArgument(_) => single = true
    _ => ()
  }
  assert_true(single)
  let mut constant = false
  try {
    let _ = gaussian_kde([2.0, 2.0, 2.0])
  } catch {
    @core.OwlError::InvalidArgument(_) => constant = true
    _ => ()
  }
  assert_true(constant)
}

///|
test "gaussian_kde: estimation points span the sample range" {
  let vs = [1.0, 2.0, 3.0, 4.0, 5.0]
  let (points, _) = gaussian_kde(vs, n_points=64)
  assert_true(points[0] < 1.0)
  assert_true(points[63] > 5.0)
}
