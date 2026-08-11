///|
/// Squeeze broadcast: sum over broadcasted dimensions to match target shape.
/// For same-shape or scalar operations, this is a no-op.
fn squeeze_broadcast(x : T, s : Array[Int]) -> T raise {
  let shp_x = shape(x)
  let dim_x = shp_x.length()
  let dim = s.length()
  if shp_x == s {
    return x
  }
  if dim == 0 {
    return sum_(x)
  }
  if dim_x < dim {
    raise @types.OwlError::InvalidArgument(
      "squeeze_broadcast: dimension mismatch",
    )
  }
  let axis = []
  for k in 0..<dim {
    if s[k] == 1 && shp_x[k] != 1 {
      axis.push(k)
    }
  }
  if axis.length() == 0 {
    return x
  }
  match primal_(x) {
    Arr(arr) => Arr(@ndarray.sum_reduce(arr, axis~))
    _ => x
  }
}

///|
/// Addition: a + b
pub fn add(a : T, b : T) -> T raise {
  piso_op(
    add,
    a,
    b,
    "add",
    fn(av, bv) { F(av + bv) },
    fn(av, bv) { Arr(@ndarray.scalar_add(av, bv)) },
    fn(av, bv) { Arr(@ndarray.add_scalar(av, bv)) },
    fn(av, bv) raise { Arr(@ndarray.add(av, bv)) },
    fn(_cp, _ap, at, _) { at },
    fn(_cp, _ap, _bp, bt) { bt },
    fn(_cp, _ap, at, _bp, bt) raise { add(at, bt) },
    fn(a, b, _cp, ca) raise {
      (squeeze_broadcast(ca.val, shape(a)), squeeze_broadcast(ca.val, shape(b)))
    },
    fn(a, _b, _cp, ca) raise { squeeze_broadcast(ca.val, shape(a)) },
    fn(_a, b, _cp, ca) raise { squeeze_broadcast(ca.val, shape(b)) },
  )
}

///|
/// Subtraction: a - b
pub fn sub(a : T, b : T) -> T raise {
  piso_op(
    sub,
    a,
    b,
    "sub",
    fn(av, bv) { F(av - bv) },
    fn(av, bv) { Arr(@ndarray.scalar_sub(av, bv)) },
    fn(av, bv) { Arr(@ndarray.sub_scalar(av, bv)) },
    fn(av, bv) raise { Arr(@ndarray.sub(av, bv)) },
    fn(_cp, _ap, at, _) { at },
    fn(_cp, _ap, _bp, bt) raise { neg(bt) },
    fn(_cp, _ap, at, _bp, bt) raise { sub(at, bt) },
    fn(a, b, _cp, ca) raise {
      (
        squeeze_broadcast(ca.val, shape(a)),
        neg(squeeze_broadcast(ca.val, shape(b))),
      )
    },
    fn(a, _b, _cp, ca) raise { squeeze_broadcast(ca.val, shape(a)) },
    fn(_a, b, _cp, ca) raise { neg(squeeze_broadcast(ca.val, shape(b))) },
  )
}

///|
/// Multiplication: a * b
pub fn mul(a : T, b : T) -> T raise {
  piso_op(
    mul,
    a,
    b,
    "mul",
    fn(av, bv) { F(av * bv) },
    fn(av, bv) { Arr(@ndarray.scalar_mul(av, bv)) },
    fn(av, bv) { Arr(@ndarray.mul_scalar(av, bv)) },
    fn(av, bv) raise { Arr(@ndarray.mul(av, bv)) },
    fn(_cp, _ap, at, bp) raise { mul(at, bp) },
    fn(_cp, ap, _bp, bt) raise { mul(ap, bt) },
    fn(_cp, ap, at, bp, bt) raise { add(mul(ap, bt), mul(at, bp)) },
    fn(a, b, _cp, ca) raise {
      (
        squeeze_broadcast(mul(ca.val, b), shape(a)),
        squeeze_broadcast(mul(ca.val, a), shape(b)),
      )
    },
    fn(a, b, _cp, ca) raise { squeeze_broadcast(mul(ca.val, b), shape(a)) },
    fn(a, b, _cp, ca) raise { squeeze_broadcast(mul(ca.val, a), shape(b)) },
  )
}

///|
/// Division: a / b
pub fn div(a : T, b : T) -> T raise {
  piso_op(
    div,
    a,
    b,
    "div",
    fn(av, bv) { F(av / bv) },
    fn(av, bv) { Arr(@ndarray.scalar_div(av, bv)) },
    fn(av, bv) { Arr(@ndarray.div_scalar(av, bv)) },
    fn(av, bv) raise { Arr(@ndarray.div(av, bv)) },
    fn(_cp, _ap, at, bp) raise { div(at, bp) },
    fn(cp, ap, _bp, bt) raise { neg(mul(div(ap, sqr(cp)), bt)) },
    fn(_cp, ap, at, bp, bt) raise {
      sub(div(at, bp), mul(div(ap, sqr(bp)), bt))
    },
    fn(a, b, _cp, ca) raise {
      (
        squeeze_broadcast(div(ca.val, b), shape(a)),
        squeeze_broadcast(neg(mul(ca.val, div(a, sqr(b)))), shape(b)),
      )
    },
    fn(a, b, _cp, ca) raise { squeeze_broadcast(div(ca.val, b), shape(a)) },
    fn(a, b, _cp, ca) raise {
      squeeze_broadcast(neg(mul(ca.val, div(a, sqr(b)))), shape(b))
    },
  )
}

///|
/// Power: a^b
pub fn pow(a : T, b : T) -> T raise {
  piso_op(
    pow,
    a,
    b,
    "pow",
    fn(av, bv) { F(@math.pow(av, bv)) },
    fn(av, bv) { Arr(@ndarray.scalar_pow(av, bv)) },
    fn(av, bv) { Arr(@ndarray.pow_scalar(av, bv)) },
    fn(av, bv) raise { Arr(@ndarray.pow(av, bv)) },
    fn(_cp, ap, at, bp) raise { mul(mul(bp, pow(ap, sub(bp, F(1.0)))), at) },
    fn(cp, ap, _bp, bt) raise { mul(mul(cp, log(ap)), bt) },
    fn(cp, ap, at, bp, bt) raise {
      add(mul(mul(bp, pow(ap, sub(bp, F(1.0)))), at), mul(mul(cp, log(ap)), bt))
    },
    fn(a, b, cp, ca) raise {
      (
        squeeze_broadcast(mul(mul(ca.val, b), pow(a, sub(b, F(1.0)))), shape(a)),
        squeeze_broadcast(mul(mul(ca.val, cp), log(a)), shape(b)),
      )
    },
    fn(a, b, _cp, ca) raise {
      squeeze_broadcast(mul(mul(ca.val, b), pow(a, sub(b, F(1.0)))), shape(a))
    },
    fn(a, b, cp, ca) raise {
      squeeze_broadcast(mul(mul(ca.val, cp), log(a)), shape(b))
    },
  )
}

///|
/// Element-wise multiplication (alias for mul)
pub fn elmul(a : T, b : T) -> T raise {
  mul(a, b)
}

///|
/// Element-wise division (alias for div)
pub fn eldiv(a : T, b : T) -> T raise {
  div(a, b)
}

///|
/// Scalar multiplication: a * scalar
pub fn mul_scalar(a : T, s : Double) -> T raise {
  mul(a, F(s))
}

///|
/// Scalar addition: a + scalar
pub fn add_scalar(a : T, s : Double) -> T raise {
  add(a, F(s))
}

///|
/// Scalar subtraction: a - scalar
pub fn sub_scalar(a : T, s : Double) -> T raise {
  sub(a, F(s))
}

///|
/// Scalar division: a / scalar
pub fn div_scalar(a : T, s : Double) -> T raise {
  div(a, F(s))
}
