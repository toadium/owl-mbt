///|
/// Batched matrix multiply: a *@ b
/// For 2D: standard matrix multiply. For 3D+: batched along leading dims.
pub fn matmul(a : T, b : T) -> T raise {
  piso_op(
    matmul,
    a,
    b,
    "matmul",
    fn(av, bv) { F(av * bv) },
    fn(av, bv) { Arr(@ndarray.mul_scalar(bv, av)) },
    fn(av, bv) { Arr(@ndarray.mul_scalar(av, bv)) },
    fn(av, bv) { Arr(@ndarray.dot(av, bv)) },
    fn(_cp, _ap, at, b) raise { matmul(at, b) },
    fn(_cp, a, _bp, bt) raise { matmul(a, bt) },
    fn(_cp, ap, at, bp, bt) raise { add(matmul(ap, bt), matmul(at, bp)) },
    fn(a, b, _cp, ca) raise {
      let ca_val = ca.val
      (matmul(ca_val, transpose(b)), matmul(transpose(a), ca_val))
    },
    fn(a, b, _cp, ca) raise { matmul(ca.val, transpose(b)) },
    fn(a, b, _cp, ca) raise { matmul(transpose(a), ca.val) },
  )
}
