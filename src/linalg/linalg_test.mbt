///|
/// Linalg tests.

///|
fn approx_eq(
  a : @ndarray.Ndarray,
  b : @ndarray.Ndarray,
  eps? : Double = 1.0e-10,
) -> Bool {
  if a.shape[0] != b.shape[0] || a.shape[1] != b.shape[1] {
    return false
  }
  for i in 0..<a.data.length() {
    if (a.data[i] - b.data[i]).abs() >= eps {
      return false
    }
  }
  true
}

///|
test "is_triu and is_tril" {
  let u = @ndarray.of_arrays([[1.0, 2.0, 3.0], [0.0, 4.0, 5.0], [0.0, 0.0, 6.0]])
  @test.assert_eq(true, is_triu(u))
  @test.assert_eq(false, is_tril(u))
  let l = @ndarray.of_arrays([[1.0, 0.0, 0.0], [2.0, 3.0, 0.0], [4.0, 5.0, 6.0]])
  @test.assert_eq(true, is_tril(l))
  @test.assert_eq(false, is_triu(l))
}

///|
test "is_symmetric and is_diag" {
  let s = @ndarray.of_arrays([[1.0, 2.0, 3.0], [2.0, 4.0, 5.0], [3.0, 5.0, 6.0]])
  @test.assert_eq(true, is_symmetric(s))
  let ns = @ndarray.of_arrays([[1.0, 2.0], [3.0, 4.0]])
  @test.assert_eq(false, is_symmetric(ns))
  let d = @ndarray.of_arrays([[1.0, 0.0], [0.0, 2.0]])
  @test.assert_eq(true, is_diag(d))
}

///|
test "trace" {
  let a = @ndarray.of_arrays([[1.0, 2.0], [3.0, 4.0]])
  @test.assert_eq(5.0, trace(a))
  let b = @ndarray.of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]])
  @test.assert_eq(15.0, trace(b))
}

///|
test "det" {
  let a = @ndarray.of_arrays([[1.0, 2.0], [3.0, 4.0]])
  @test.assert_eq(true, (det(a) - -2.0).abs() < 1.0e-10)
  let i = @ndarray.eye(3)
  @test.assert_eq(true, (det(i) - 1.0).abs() < 1.0e-10)
}

///|
test "inv" {
  let a = @ndarray.of_arrays([[4.0, 7.0], [2.0, 6.0]])
  let ai = inv(a)
  @test.assert_eq(true, (ai.data[0] - 0.6).abs() < 1.0e-10)
  @test.assert_eq(true, (ai.data[1] - -0.7).abs() < 1.0e-10)
  @test.assert_eq(true, (ai.data[2] - -0.2).abs() < 1.0e-10)
  @test.assert_eq(true, (ai.data[3] - 0.4).abs() < 1.0e-10)
  let prod = @ndarray.dot(a, ai)
  @test.assert_eq(true, (prod.data[0] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, (prod.data[3] - 1.0).abs() < 1.0e-10)
}

///|
test "lu" {
  let a = @ndarray.of_arrays([[2.0, 1.5, 1.0], [1.0, 3.0, 2.0], [4.0, 1.0, 7.0]])
  let (l, u, _) = lu(a)
  let prod = @ndarray.dot(l, u)
  @test.assert_eq(true, approx_eq(a, prod, eps=1.0e-10))
}

///|
test "chol" {
  let a = @ndarray.of_arrays([[4.0, 2.0], [2.0, 3.0]])
  let l = chol(a)
  @test.assert_eq(true, (l.data[0] - 2.0).abs() < 1.0e-10)
  @test.assert_eq(true, (l.data[1] - 0.0).abs() < 1.0e-10)
  @test.assert_eq(true, (l.data[2] - 1.0).abs() < 1.0e-10)
  let lt = @ndarray.transpose(l)
  let prod = @ndarray.dot(l, lt)
  @test.assert_eq(true, approx_eq(a, prod, eps=1.0e-10))
}

///|
test "qr" {
  let a = @ndarray.of_arrays([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]])
  let (q, r) = qr(a)
  let prod = @ndarray.dot(q, r)
  @test.assert_eq(true, approx_eq(a, prod, eps=1.0e-10))
  let qt = @ndarray.transpose(q)
  let qtq = @ndarray.dot(qt, q)
  @test.assert_eq(true, (qtq.data[0] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, (qtq.data[4] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, (qtq.data[8] - 1.0).abs() < 1.0e-10)
}

///|
test "linsolve_lu" {
  let a = @ndarray.of_arrays([[2.0, 1.0], [1.0, 3.0]])
  let b = @ndarray.of_arrays([[3.0], [5.0]])
  let x = linsolve_lu(a, b)
  @test.assert_eq(true, (x.data[0] - 0.8).abs() < 1.0e-10)
  @test.assert_eq(true, (x.data[1] - 1.4).abs() < 1.0e-10)
}

///|
test "rank" {
  let a = @ndarray.of_arrays([[1.0, 2.0], [2.0, 4.0]])
  @test.assert_eq(1, rank(a))
  let b = @ndarray.of_arrays([[1.0, 0.0], [0.0, 1.0]])
  @test.assert_eq(2, rank(b))
}

///|
test "tridiag_solve" {
  let a = [0.0, 1.0, 1.0]
  let b = [2.0, 2.0, 2.0]
  let c = [1.0, 1.0, 0.0]
  let r = [4.0, 8.0, 8.0]
  let x = tridiag_solve(a, b, c, r)
  @test.assert_eq(true, (x[0] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, (x[1] - 2.0).abs() < 1.0e-10)
  @test.assert_eq(true, (x[2] - 3.0).abs() < 1.0e-10)
}

///|
test "logdet" {
  let a = @ndarray.of_arrays([[2.0, 0.0], [0.0, 3.0]])
  @test.assert_eq(true, (logdet(a) - @math.ln(6.0)).abs() < 1.0e-10)
}
