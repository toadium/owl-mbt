///|
/// 覆盖率补强 — Count-Min Sketch（初始化/非法参数/计数）
/// Coverage-gap tests for CountMinSketch.

///|
test "cms: init, increments and estimates" {
  let s = cms_init(0.01, 0.01)
  cms_incr(s, 42)
  cms_incr(s, 42)
  cms_incr(s, 7)
  assert_true(cms_count(s, 42) >= 2)
  assert_true(cms_count(s, 7) >= 1)
  assert_true(cms_count(s, 999) >= 0)
}

///|
test "cms: rejects invalid depth/width and epsilon/delta" {
  let mut bad_lw = false
  try {
    let _ = cms_init_lw(0, 5)
  } catch {
    @core.OwlError::InvalidArgument(_) => bad_lw = true
    _ => ()
  }
  assert_true(bad_lw)
  let mut bad_eps = false
  try {
    let _ = cms_init(0.0, 0.5)
  } catch {
    @core.OwlError::InvalidArgument(_) => bad_eps = true
    _ => ()
  }
  assert_true(bad_eps)
  let mut bad_delta = false
  try {
    let _ = cms_init(0.5, 1.0)
  } catch {
    @core.OwlError::InvalidArgument(_) => bad_delta = true
    _ => ()
  }
  assert_true(bad_delta)
}
