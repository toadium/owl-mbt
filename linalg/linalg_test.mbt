///|
/// Linalg tests.

///|
fn approx_eq(
  a : @ndarray.Ndarray,
  b : @ndarray.Ndarray,
  eps~ : Double = 1.0e-10,
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
  @test.assert_eq(true, @linalg.is_triu(u))
  @test.assert_eq(false, @linalg.is_tril(u))
  let l = @ndarray.of_arrays([[1.0, 0.0, 0.0], [2.0, 3.0, 0.0], [4.0, 5.0, 6.0]])
  @test.assert_eq(true, @linalg.is_tril(l))
  @test.assert_eq(false, @linalg.is_triu(l))
}

///|
test "is_symmetric and is_diag" {
  let s = @ndarray.of_arrays([[1.0, 2.0, 3.0], [2.0, 4.0, 5.0], [3.0, 5.0, 6.0]])
  @test.assert_eq(true, @linalg.is_symmetric(s))
  let ns = @ndarray.of_arrays([[1.0, 2.0], [3.0, 4.0]])
  @test.assert_eq(false, @linalg.is_symmetric(ns))
  let d = @ndarray.of_arrays([[1.0, 0.0], [0.0, 2.0]])
  @test.assert_eq(true, @linalg.is_diag(d))
}

///|
test "trace" {
  let a = @ndarray.of_arrays([[1.0, 2.0], [3.0, 4.0]])
  @test.assert_eq(5.0, @linalg.trace(a))
  let b = @ndarray.of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]])
  @test.assert_eq(15.0, @linalg.trace(b))
}

///|
test "det" {
  let a = @ndarray.of_arrays([[1.0, 2.0], [3.0, 4.0]])
  @test.assert_eq(true, (@linalg.det(a) - -2.0).abs() < 1.0e-10)
  let i = @ndarray.eye(3)
  @test.assert_eq(true, (@linalg.det(i) - 1.0).abs() < 1.0e-10)
}

///|
test "inv" {
  let a = @ndarray.of_arrays([[4.0, 7.0], [2.0, 6.0]])
  let ai = @linalg.inv(a)
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
  let (l, u, _) = @linalg.lu(a)
  let prod = @ndarray.dot(l, u)
  @test.assert_eq(true, approx_eq(a, prod, eps=1.0e-10))
}

///|
test "chol" {
  let a = @ndarray.of_arrays([[4.0, 2.0], [2.0, 3.0]])
  let l = @linalg.chol(a)
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
  let (q, r) = @linalg.qr(a)
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
  let x = @linalg.linsolve_lu(a, b)
  @test.assert_eq(true, (x.data[0] - 0.8).abs() < 1.0e-10)
  @test.assert_eq(true, (x.data[1] - 1.4).abs() < 1.0e-10)
}

///|
test "rank" {
  let a = @ndarray.of_arrays([[1.0, 2.0], [2.0, 4.0]])
  @test.assert_eq(1, @linalg.rank(a))
  let b = @ndarray.of_arrays([[1.0, 0.0], [0.0, 1.0]])
  @test.assert_eq(2, @linalg.rank(b))
}

///|
test "tridiag_solve" {
  let a = [0.0, 1.0, 1.0]
  let b = [2.0, 2.0, 2.0]
  let c = [1.0, 1.0, 0.0]
  let r = [4.0, 8.0, 8.0]
  let x = @linalg.tridiag_solve(a, b, c, r)
  @test.assert_eq(true, (x[0] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, (x[1] - 2.0).abs() < 1.0e-10)
  @test.assert_eq(true, (x[2] - 3.0).abs() < 1.0e-10)
}

///|
test "logdet" {
  let a = @ndarray.of_arrays([[2.0, 0.0], [0.0, 3.0]])
  @test.assert_eq(true, (@linalg.logdet(a) - @math.ln(6.0)).abs() < 1.0e-10)
}

// ===== Business Scenario Tests =====

///|
test "scenario: solve linear system Ax=b" {
  // 3x3 system: x + 2y + 3z = 14, 4x + 5y + 6z = 32, 7x + 8y + 10z = 47
  // Solution: x=-5, y=14, z=-3 (verified via Cramer's rule)
  let a = @ndarray.of_arrays([
    [1.0, 2.0, 3.0],
    [4.0, 5.0, 6.0],
    [7.0, 8.0, 10.0],
  ])
  let b = @ndarray.of_arrays([[14.0], [32.0], [47.0]])
  let x = @linalg.linsolve_lu(a, b)
  @test.assert_eq(true, (x.data[0] + 5.0).abs() < 1.0e-10)
  @test.assert_eq(true, (x.data[1] - 14.0).abs() < 1.0e-10)
  @test.assert_eq(true, (x.data[2] + 3.0).abs() < 1.0e-10)
  // Verify: A * x = b
  let ax = @ndarray.dot(a, x)
  @test.assert_eq(true, (ax.data[0] - 14.0).abs() < 1.0e-10)
  @test.assert_eq(true, (ax.data[1] - 32.0).abs() < 1.0e-10)
  @test.assert_eq(true, (ax.data[2] - 47.0).abs() < 1.0e-10)
}

///|
test "scenario: LU decomposition and reconstruction" {
  let a = @ndarray.of_arrays([[4.0, 3.0], [6.0, 3.0]])
  let (l, u, _piv) = @linalg.lu(a)
  // L should be lower triangular with unit diagonal
  @test.assert_eq(true, @linalg.is_tril(l))
  @test.assert_eq(true, (l.data[0] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, (l.data[3] - 1.0).abs() < 1.0e-10)
  // U should be upper triangular
  @test.assert_eq(true, @linalg.is_triu(u))
  // Reconstruct: L * U should give back A (up to pivoting)
  let lu_prod = @ndarray.dot(l, u)
  @test.assert_eq(true, (lu_prod.data[0] - 4.0).abs() < 1.0e-10)
  @test.assert_eq(true, (lu_prod.data[1] - 3.0).abs() < 1.0e-10)
  @test.assert_eq(true, (lu_prod.data[2] - 6.0).abs() < 1.0e-10)
  @test.assert_eq(true, (lu_prod.data[3] - 3.0).abs() < 1.0e-10)
}

///|
test "scenario: Cholesky decomposition of SPD matrix" {
  // Symmetric positive definite matrix
  let a = @ndarray.of_arrays([[4.0, 2.0], [2.0, 3.0]])
  let c = @linalg.chol(a)
  // C should be lower triangular
  @test.assert_eq(true, @linalg.is_tril(c))
  // C * C^T should reconstruct A
  let ct = @ndarray.transpose(c)
  let recon = @ndarray.dot(c, ct)
  @test.assert_eq(true, (recon.data[0] - 4.0).abs() < 1.0e-10)
  @test.assert_eq(true, (recon.data[1] - 2.0).abs() < 1.0e-10)
  @test.assert_eq(true, (recon.data[2] - 2.0).abs() < 1.0e-10)
  @test.assert_eq(true, (recon.data[3] - 3.0).abs() < 1.0e-10)
}

///|
test "scenario: QR decomposition and reconstruction" {
  let a = @ndarray.of_arrays([[1.0, 1.0], [1.0, -1.0]])
  let (q, r) = @linalg.qr(a)
  // Q * R should reconstruct A
  let recon = @ndarray.dot(q, r)
  @test.assert_eq(true, (recon.data[0] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, (recon.data[1] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, (recon.data[2] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, (recon.data[3] + 1.0).abs() < 1.0e-10)
}

///|
test "scenario: matrix inverse verification" {
  // A * A^{-1} = I
  let a = @ndarray.of_arrays([[1.0, 2.0], [3.0, 4.0]])
  let a_inv = @linalg.inv(a)
  let prod = @ndarray.dot(a, a_inv)
  // Should be identity matrix
  @test.assert_eq(true, (prod.data[0] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, prod.data[1].abs() < 1.0e-10)
  @test.assert_eq(true, prod.data[2].abs() < 1.0e-10)
  @test.assert_eq(true, (prod.data[3] - 1.0).abs() < 1.0e-10)
}

///|
test "scenario: determinant of known matrices" {
  // det([[1,2],[3,4]]) = 1*4 - 2*3 = -2
  let a = @ndarray.of_arrays([[1.0, 2.0], [3.0, 4.0]])
  @test.assert_eq(true, (@linalg.det(a) + 2.0).abs() < 1.0e-10)
  // det of identity = 1
  let i = @ndarray.of_arrays([[1.0, 0.0], [0.0, 1.0]])
  @test.assert_eq(true, (@linalg.det(i) - 1.0).abs() < 1.0e-10)
  // det of diagonal = product of diagonal
  let d = @ndarray.of_arrays([[3.0, 0.0], [0.0, 5.0]])
  @test.assert_eq(true, (@linalg.det(d) - 15.0).abs() < 1.0e-10)
}

///|
test "scenario: matrix rank computation" {
  // Full rank 2x2
  let full = @ndarray.of_arrays([[1.0, 2.0], [3.0, 4.0]])
  @test.assert_eq(2, @linalg.rank(full))
  // Rank 1 (second row is 2x first)
  let rank1 = @ndarray.of_arrays([[1.0, 2.0], [2.0, 4.0]])
  @test.assert_eq(1, @linalg.rank(rank1))
}

///|
test "scenario: tridiagonal solver" {
  // Solve tridiagonal system
  // [2 -1  0] [x]   [1]
  // [-1 2 -1] [y] = [0]
  // [0 -1  2] [z]   [1]
  // Solution: x=1, y=1, z=1
  // tridiag_solve(a, b, c, r): a=subdiagonal (a[0] unused), b=diagonal, c=superdiagonal (c[n-1] unused)
  let lower = [0.0, -1.0, -1.0]
  let diag = [2.0, 2.0, 2.0]
  let upper = [-1.0, -1.0, 0.0]
  let d = [1.0, 0.0, 1.0]
  let x = @linalg.tridiag_solve(lower, diag, upper, d)
  @test.assert_eq(true, (x[0] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, (x[1] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, (x[2] - 1.0).abs() < 1.0e-10)
}

///|
test "scenario: matrix properties check" {
  let sym = @ndarray.of_arrays([[1.0, 2.0], [2.0, 3.0]])
  @test.assert_eq(true, @linalg.is_symmetric(sym))
  let nonsym = @ndarray.of_arrays([[1.0, 2.0], [3.0, 4.0]])
  @test.assert_eq(false, @linalg.is_symmetric(nonsym))
  let triu_mat = @ndarray.of_arrays([[1.0, 2.0], [0.0, 3.0]])
  @test.assert_eq(true, @linalg.is_triu(triu_mat))
  @test.assert_eq(false, @linalg.is_tril(triu_mat))
  let diag_mat = @ndarray.of_arrays([[5.0, 0.0], [0.0, 7.0]])
  @test.assert_eq(true, @linalg.is_diag(diag_mat))
  @test.assert_eq(true, (@linalg.trace(diag_mat) - 12.0).abs() < 1.0e-10)
}

///|
test "boundary: is_diag single-pass" {
  // Non-diagonal matrix
  let nd = @ndarray.of_arrays([[1.0, 2.0], [3.0, 4.0]])
  @test.assert_eq(false, @linalg.is_diag(nd))
  // 3x3 diagonal
  let d3 = @ndarray.of_arrays([
    [1.0, 0.0, 0.0],
    [0.0, 2.0, 0.0],
    [0.0, 0.0, 3.0],
  ])
  @test.assert_eq(true, @linalg.is_diag(d3))
  // 3x3 non-diagonal (off-diagonal in lower triangle)
  let nd3 = @ndarray.of_arrays([
    [1.0, 0.0, 0.0],
    [0.5, 2.0, 0.0],
    [0.0, 0.0, 3.0],
  ])
  @test.assert_eq(false, @linalg.is_diag(nd3))
}

///|
test "boundary: inv singular matrix raises" {
  let singular = @ndarray.of_arrays([[1.0, 2.0], [2.0, 4.0]])
  let raised = try {
    let _ = @linalg.inv(singular)
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, raised)
}

///|
test "boundary: chol non-positive-definite raises" {
  let neg_def = @ndarray.of_arrays([[-1.0, 0.0], [0.0, -1.0]])
  let raised = try {
    let _ = @linalg.chol(neg_def)
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, raised)
}

///|
test "boundary: chol upper=true" {
  let spd = @ndarray.of_arrays([[4.0, 2.0], [2.0, 3.0]])
  let upper = @linalg.chol(spd, upper=true)
  let lower = @linalg.chol(spd, upper=false)
  // upper should be transpose of lower
  @test.assert_eq(true, (upper.data[0] - lower.data[0]).abs() < 1.0e-10)
  @test.assert_eq(true, (upper.data[1] - lower.data[2]).abs() < 1.0e-10)
  @test.assert_eq(true, (upper.data[2] - lower.data[1]).abs() < 1.0e-10)
  @test.assert_eq(true, (upper.data[3] - lower.data[3]).abs() < 1.0e-10)
}

///|
test "boundary: det singular matrix returns 0" {
  let singular = @ndarray.of_arrays([[1.0, 2.0], [2.0, 4.0]])
  let d = @linalg.det(singular)
  @test.assert_eq(true, d.abs() < 1.0e-10)
}

///|
test "boundary: non-square matrix raises" {
  let rect = @ndarray.of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
  // det
  let r1 = try {
    let _ = @linalg.det(rect)
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, r1)
  // inv
  let r2 = try {
    let _ = @linalg.inv(rect)
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, r2)
  // lu
  let r3 = try {
    let _ = @linalg.lu(rect)
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, r3)
  // chol
  let r4 = try {
    let _ = @linalg.chol(rect)
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, r4)
}

///|
test "boundary: rank non-square and zero matrix" {
  // Non-square matrix 2x3
  let rect = @ndarray.of_arrays([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
  let r_rect = @linalg.rank(rect)
  @test.assert_eq(true, r_rect >= 1 && r_rect <= 2)
  // Zero matrix
  let zero = @ndarray.of_arrays([[0.0, 0.0], [0.0, 0.0]])
  let r_zero = @linalg.rank(zero)
  @test.assert_eq(0, r_zero)
}

///|
test "boundary: lu with row pivoting" {
  // [[0,1],[1,0]] has a zero leading pivot and requires a row swap
  let a = @ndarray.of_arrays([[0.0, 1.0], [1.0, 0.0]])
  let (l, u, piv) = @linalg.lu(a)
  // piv must record the swap: row 1 was moved into pivot position 0
  @test.assert_eq(1, piv[0])
  // L*U reconstructs the row-permuted A[piv,:] (the identity here)
  let prod = @ndarray.dot(l, u)
  @test.assert_eq(true, (prod.data[0] - 1.0).abs() < 1.0e-10)
  @test.assert_eq(true, prod.data[1].abs() < 1.0e-10)
  @test.assert_eq(true, prod.data[2].abs() < 1.0e-10)
  @test.assert_eq(true, (prod.data[3] - 1.0).abs() < 1.0e-10)
  // det([[0,1],[1,0]]) = -1: one swap flips the sign
  @test.assert_eq(true, (@linalg.det(a) + 1.0).abs() < 1.0e-10)
  // [[0,2],[3,4]] also needs a swap: det = -(3*2) = -6
  let b = @ndarray.of_arrays([[0.0, 2.0], [3.0, 4.0]])
  @test.assert_eq(true, (@linalg.det(b) + 6.0).abs() < 1.0e-10)
  // linsolve_lu on a pivoting-required system: [[0,1],[1,0]]x=[3,4] => x=[4,3]
  let rhs = @ndarray.of_arrays([[3.0], [4.0]])
  let x = @linalg.linsolve_lu(a, rhs)
  @test.assert_eq(true, (x.data[0] - 4.0).abs() < 1.0e-10)
  @test.assert_eq(true, (x.data[1] - 3.0).abs() < 1.0e-10)
}

///|
test "boundary: logdet of matrix with negative determinant" {
  // det([[-2,0],[0,3]]) = -6; logdet sums ln|diag| = ln 2 + ln 3 = ln 6
  let a = @ndarray.of_arrays([[-2.0, 0.0], [0.0, 3.0]])
  @test.assert_eq(true, (@linalg.logdet(a) - @math.ln(6.0)).abs() < 1.0e-10)
  // Symmetric negative definite [[-4,0],[0,-3]]: det = 12, logdet = ln 12
  let b = @ndarray.of_arrays([[-4.0, 0.0], [0.0, -3.0]])
  @test.assert_eq(true, (@linalg.logdet(b) - @math.ln(12.0)).abs() < 1.0e-10)
}

///|
test "boundary: tridiag_solve length mismatch raises" {
  let diag = [2.0, 2.0, 2.0]
  // subdiagonal too short
  let r1 = try {
    let _ = @linalg.tridiag_solve([1.0, 1.0], diag, [1.0, 1.0, 0.0], [
      4.0, 8.0, 8.0,
    ])
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, r1)
  // superdiagonal too short
  let r2 = try {
    let _ = @linalg.tridiag_solve([0.0, 1.0, 1.0], diag, [1.0, 1.0], [
      4.0, 8.0, 8.0,
    ])
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, r2)
  // rhs too short
  let r3 = try {
    let _ = @linalg.tridiag_solve([0.0, 1.0, 1.0], diag, [1.0, 1.0, 0.0], [
      4.0, 8.0,
    ])
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, r3)
}
