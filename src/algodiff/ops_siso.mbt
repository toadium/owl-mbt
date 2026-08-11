///|
/// Negation: -x
pub fn neg(a : T) -> T raise {
  siso_op(
    neg,
    a,
    "neg",
    fn(v) { F(-v) },
    fn(arr) { Arr(@ndarray.neg(arr)) },
    fn(_cp, _ap, at) raise { neg(at) },
    fn(_a, _cp, ca) raise { neg(ca.val) },
  )
}

///|
/// Absolute value: |x|
pub fn abs(a : T) -> T raise {
  siso_op(
    abs,
    a,
    "abs",
    fn(v) { F(v.abs()) },
    fn(arr) { Arr(@ndarray.abs(arr)) },
    fn(_cp, ap, at) raise { mul(at, signum(ap)) },
    fn(a, _cp, ca) raise { mul(ca.val, signum(a)) },
  )
}

///|
/// Signum function
pub fn signum(a : T) -> T raise {
  siso_op(
    signum,
    a,
    "signum",
    fn(v) { F(v.signum()) },
    fn(arr) { Arr(@ndarray.signum(arr)) },
    fn(_cp, ap, _) { zero(ap) },
    fn(a, _cp, _) { zero(a) },
  )
}

///|
/// Square: x^2
pub fn sqr(a : T) -> T raise {
  siso_op(
    sqr,
    a,
    "sqr",
    fn(v) { F(v * v) },
    fn(arr) { Arr(@ndarray.sqr(arr)) },
    fn(_cp, ap, at) raise { mul(mul(F(2.0), at), ap) },
    fn(a, _cp, ca) raise { mul(mul(ca.val, a), F(2.0)) },
  )
}

///|
/// Square root: sqrt(x)
pub fn sqrt(a : T) -> T raise {
  siso_op(
    sqrt,
    a,
    "sqrt",
    fn(v) { F(v.sqrt()) },
    fn(arr) { Arr(@ndarray.sqrt(arr)) },
    fn(cp, _ap, at) raise { div(at, mul(F(2.0), cp)) },
    fn(_a, cp, ca) raise { div(ca.val, mul(F(2.0), cp)) },
  )
}

///|
/// Natural logarithm: ln(x)
pub fn log(a : T) -> T raise {
  siso_op(
    log,
    a,
    "log",
    fn(v) { F(@math.ln(v)) },
    fn(arr) { Arr(@ndarray.log(arr)) },
    fn(_cp, ap, at) raise { div(at, ap) },
    fn(a, _cp, ca) raise { div(ca.val, a) },
  )
}

///|
/// Exponential: exp(x)
pub fn exp(a : T) -> T raise {
  siso_op(
    exp,
    a,
    "exp",
    fn(v) { F(@math.exp(v)) },
    fn(arr) { Arr(@ndarray.exp(arr)) },
    fn(cp, _ap, at) raise { mul(at, cp) },
    fn(_a, cp, ca) raise { mul(ca.val, cp) },
  )
}

///|
/// Sine: sin(x)
pub fn sin(a : T) -> T raise {
  siso_op(
    sin,
    a,
    "sin",
    fn(v) { F(@math.sin(v)) },
    fn(arr) { Arr(@ndarray.sin(arr)) },
    fn(_cp, ap, at) raise { mul(at, cos(ap)) },
    fn(a, _cp, ca) raise { mul(ca.val, cos(a)) },
  )
}

///|
/// Cosine: cos(x)
pub fn cos(a : T) -> T raise {
  siso_op(
    cos,
    a,
    "cos",
    fn(v) { F(@math.cos(v)) },
    fn(arr) { Arr(@ndarray.cos(arr)) },
    fn(_cp, ap, at) raise { neg(mul(at, sin(ap))) },
    fn(a, _cp, ca) raise { mul(ca.val, neg(sin(a))) },
  )
}

///|
/// Tangent: tan(x)
pub fn tan(a : T) -> T raise {
  siso_op(
    tan,
    a,
    "tan",
    fn(v) { F(@math.tan(v)) },
    fn(arr) { Arr(@ndarray.tan(arr)) },
    fn(_cp, ap, at) raise { div(at, sqr(cos(ap))) },
    fn(a, _cp, ca) raise { div(ca.val, sqr(cos(a))) },
  )
}

///|
/// Hyperbolic sine: sinh(x)
pub fn sinh(a : T) -> T raise {
  siso_op(
    sinh,
    a,
    "sinh",
    fn(v) { F(@math.sinh(v)) },
    fn(arr) { Arr(@ndarray.sinh(arr)) },
    fn(_cp, ap, at) raise { mul(at, cosh(ap)) },
    fn(a, _cp, ca) raise { mul(ca.val, cosh(a)) },
  )
}

///|
/// Hyperbolic cosine: cosh(x)
pub fn cosh(a : T) -> T raise {
  siso_op(
    cosh,
    a,
    "cosh",
    fn(v) { F(@math.cosh(v)) },
    fn(arr) { Arr(@ndarray.cosh(arr)) },
    fn(_cp, ap, at) raise { mul(at, sinh(ap)) },
    fn(a, _cp, ca) raise { mul(ca.val, sinh(a)) },
  )
}

///|
/// Sigmoid: 1 / (1 + exp(-x))
/// Note: OCaml source uses log instead of exp (suspected bug).
/// Fixed to use standard sigmoid to match the derivative formula cp*(1-cp).
pub fn sigmoid(a : T) -> T raise {
  siso_op(
    sigmoid,
    a,
    "sigmoid",
    fn(v) { F(1.0 / (1.0 + @math.exp(-v))) },
    fn(arr) { Arr(@ndarray.sigmoid(arr)) },
    fn(cp, _ap, at) raise { mul(at, mul(cp, sub(F(1.0), cp))) },
    fn(_a, cp, ca) raise { mul(ca.val, mul(cp, sub(F(1.0), cp))) },
  )
}

///|
/// ReLU: max(0, x)
pub fn relu(a : T) -> T raise {
  siso_op(
    relu,
    a,
    "relu",
    fn(v) { F(if v > 0.0 { v } else { 0.0 }) },
    fn(arr) { Arr(@ndarray.relu(arr)) },
    fn(_cp, ap, at) { if is_positive(ap) { at } else { zero(at) } },
    fn(a, _cp, ca) { if is_positive(a) { ca.val } else { zero(ca.val) } },
  )
}

///|
fn is_positive(x : T) -> Bool {
  match primal_(x) {
    F(v) => v > 0.0
    _ => false
  }
}
