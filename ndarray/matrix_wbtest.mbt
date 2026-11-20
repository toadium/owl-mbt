///|
/// 覆盖率补强 — 矩阵视图（row/rows/diag/to_rows/of_rows/to_cols/of_cols/dot/trace）
/// Coverage-gap tests for matrix views and products.

///|
test "matrix: shape, row and rows" {
  let m = of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
  assert_eq(row_num(m), 2)
  assert_eq(col_num(m), 3)
  assert_eq(row(m, 0).data[0], 1.0)
  let r = rows(m, [1])
  assert_eq(r.shape[0], 1)
  assert_eq(r.data[0], 4.0)
}

///|
test "matrix: diag with positive/negative offsets and zero size" {
  let m = of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
  let d0 = diag(m)
  assert_eq(d0.shape[0], 2)
  assert_eq(d0.data[0], 1.0)
  assert_eq(d0.data[1], 5.0)
  let d1 = diag(m, k=1)
  assert_eq(d1.shape[0], 2)
  assert_eq(d1.data[0], 2.0)
  let dn = diag(m, k=-1)
  assert_eq(dn.shape[0], 1)
  assert_eq(dn.data[0], 4.0)
  let empty = diag(m, k=5)
  assert_eq(empty.shape[0], 0)
}

///|
test "matrix: row/col conversions round-trip" {
  let m = of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
  let rs = to_rows(m)
  assert_eq(rs.length(), 2)
  let m2 = of_rows(rs)
  assert_eq(m2.shape[0], 2)
  assert_eq(m2.shape[1], 3)
  assert_eq(m2.data[5], 6.0)
  let cs = to_cols(m)
  assert_eq(cs.length(), 3)
  let m3 = of_cols(cs)
  assert_eq(m3.shape[0], 2)
  assert_eq(m3.shape[1], 3)
  assert_eq(m3.data[3], 4.0)
}

///|
test "matrix: dot product and trace" {
  let a = of_arrays([[1.0, 2.0], [3.0, 4.0]])
  let b = of_arrays([[5.0, 6.0], [7.0, 8.0]])
  let c = dot(a, b)
  assert_eq(c.shape[0], 2)
  assert_eq(c.shape[1], 2)
  assert_eq(c.data[0], 19.0)
  assert_eq(c.data[1], 22.0)
  assert_eq(c.data[2], 43.0)
  assert_eq(c.data[3], 50.0)
  assert_true((trace(a) - 5.0).abs() < 1.0e-12)
}
