///|
/// SVD 测试：golden 奇异值、正交性、重建、矩形与奇异矩阵。

///|
/// 相对误差 |a - b| / max(|b|, 1)
fn svd_rel_err(a : Double, b : Double) -> Double {
  (a - b).abs() / b.abs().max(1.0)
}

///|
/// 验证 U 列正交：UᵀU ≈ I
fn svd_check_orthonormal(u : @ndarray.Ndarray, r : Int32) -> Bool {
  let rows = u.shape[0]
  for p in 0..<r {
    for q in 0..<r {
      let mut dot = 0.0
      for k in 0..<rows {
        dot += u.data[k * r + p] * u.data[k * r + q]
      }
      let target = if p == q { 1.0 } else { 0.0 }
      if (dot - target).abs() > 1.0e-10 {
        return false
      }
    }
  }
  true
}

///|
/// U · diag(s)（列缩放），测试辅助
fn svd_scale_cols(
  u : @ndarray.Ndarray,
  s : @ndarray.Ndarray,
) -> @ndarray.Ndarray raise {
  let m = u.shape[0]
  let r = u.shape[1]
  let data = FixedArray::make(m * r, 0.0)
  for j in 0..<r {
    let sj = @ndarray.get(s, [j])
    for i in 0..<m {
      data[i * r + j] = u.data[i * r + j] * sj
    }
  }
  @ndarray.from_data([m, r], data)
}

///|
test "svd: diagonal matrix has exact singular values" {
  let a = @ndarray.of_array([3.0, 0.0, 0.0, 4.0], [2, 2])
  let (u, s, v) = @linalg.svd(a)
  assert_true(svd_rel_err(@ndarray.get(s, [0]), 4.0) < 1.0e-12)
  assert_true(svd_rel_err(@ndarray.get(s, [1]), 3.0) < 1.0e-12)
  // 重建 U·diag(s)·Vᵀ ≈ A
  let us = svd_scale_cols(u, s)
  let recon = @ndarray.dot(us, @ndarray.transpose(v))
  assert_true(svd_rel_err(@ndarray.get(recon, [0, 0]), 3.0) < 1.0e-12)
  assert_true(svd_rel_err(@ndarray.get(recon, [1, 1]), 4.0) < 1.0e-12)
  assert_true(@ndarray.get(recon, [0, 1]).abs() < 1.0e-12)
  assert_true(@ndarray.get(recon, [1, 0]).abs() < 1.0e-12)
}

///|
test "svd: symmetric matrix singular values equal eigenvalue magnitudes" {
  // [[1,2],[2,1]] 特征值 3, -1 -> 奇异值 3, 1
  let a = @ndarray.of_array([1.0, 2.0, 2.0, 1.0], [2, 2])
  let (u, s, v) = @linalg.svd(a)
  assert_true(svd_rel_err(@ndarray.get(s, [0]), 3.0) < 1.0e-12)
  assert_true(svd_rel_err(@ndarray.get(s, [1]), 1.0) < 1.0e-12)
  assert_true(svd_check_orthonormal(u, 2))
  assert_true(svd_check_orthonormal(v, 2))
}

///|
test "svd: tall matrix round trip" {
  // 3x4 矩阵（m < n 情形）
  let a = @ndarray.of_array(
    [1.0, 2.0, 0.5, 1.5, 2.0, -1.0, 1.0, 0.0, 0.5, 1.0, -2.0, 3.0],
    [3, 4],
  )
  let (u, s, v) = @linalg.svd(a)
  let us = svd_scale_cols(u, s)
  let recon = @ndarray.dot(us, @ndarray.transpose(v))
  for i in 0..<3 {
    for j in 0..<4 {
      let orig = @ndarray.get(a, [i, j])
      let got = @ndarray.get(recon, [i, j])
      assert_true((got - orig).abs() < 1.0e-10)
    }
  }
}

///|
test "svd: wide matrix round trip" {
  // 4x3 矩形（m > n）
  let a = @ndarray.of_array(
    [2.0, 1.0, 0.0, 1.0, 3.0, 1.0, 0.0, 1.0, 4.0, 1.5, 0.5, 2.0],
    [4, 3],
  )
  let (u, s, v) = @linalg.svd(a)
  assert_true(svd_check_orthonormal(u, 3))
  let us = svd_scale_cols(u, s)
  let recon = @ndarray.dot(us, @ndarray.transpose(v))
  for i in 0..<4 {
    for j in 0..<3 {
      let orig = @ndarray.get(a, [i, j])
      let got = @ndarray.get(recon, [i, j])
      assert_true((got - orig).abs() < 1.0e-10)
    }
  }
}

///|
test "svd: singular matrix has zero singular value" {
  // [[1,1],[1,1]] 秩 1：奇异值 [2, 0]
  let a = @ndarray.of_array([1.0, 1.0, 1.0, 1.0], [2, 2])
  let (u, s, v) = @linalg.svd(a)
  assert_true(svd_rel_err(@ndarray.get(s, [0]), 2.0) < 1.0e-12)
  assert_true(@ndarray.get(s, [1]).abs() < 1.0e-12)
  let us = svd_scale_cols(u, s)
  let recon = @ndarray.dot(us, @ndarray.transpose(v))
  for i in 0..<2 {
    for j in 0..<2 {
      assert_true((@ndarray.get(recon, [i, j]) - 1.0).abs() < 1.0e-12)
    }
  }
}

///|
test "svd: singular values sorted descending" {
  let a = @ndarray.of_array([5.0, 1.0, 2.0, 1.0, 4.0, 0.0, 2.0, 0.0, 3.0], [
    3, 3,
  ])
  let (_, s, _) = @linalg.svd(a)
  assert_true(@ndarray.get(s, [0]) >= @ndarray.get(s, [1]))
  assert_true(@ndarray.get(s, [1]) >= @ndarray.get(s, [2]))
}

///|
test "svd: rejects non-2d and empty input" {
  let bad1d = @ndarray.of_array([1.0, 2.0], [2])
  try @linalg.svd(bad1d) catch {
    @core.OwlError::InvalidArgument(_) =>
      inspect("rejected non-2d", content="rejected non-2d")
    _ => fail("expected InvalidArgument for non-2d")
  } noraise {
    _ => fail("expected raise for non-2d")
  }
  let empty = @ndarray.of_array([], [0, 0])
  try @linalg.svd(empty) catch {
    @core.OwlError::InvalidArgument(_) =>
      inspect("rejected empty", content="rejected empty")
    _ => fail("expected InvalidArgument for empty")
  } noraise {
    _ => fail("expected raise for empty")
  }
}
