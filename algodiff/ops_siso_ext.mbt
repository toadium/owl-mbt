///|
/// Tanh: hyperbolic tangent
pub fn tanh(a : T) -> T raise {
  siso_op(
    tanh,
    a,
    "tanh",
    fn(v) { F(@math.tanh(v)) },
    fn(arr) { Arr(@ndarray.tanh(arr)) },
    fn(cp, _ap, at) raise { mul(at, sub(F(1.0), sqr(cp))) },
    fn(_a, cp, ca) raise { mul(ca.val, sub(F(1.0), sqr(cp))) },
  )
}

///|
/// Softplus: log(1 + exp(x))
pub fn softplus(a : T) -> T raise {
  siso_op(
    softplus,
    a,
    "softplus",
    fn(v) {
      if v > 20.0 {
        F(v)
      } else if v < -20.0 {
        F(@math.exp(v))
      } else {
        F(@math.ln(1.0 + @math.exp(v)))
      }
    },
    fn(arr) {
      Arr(
        @ndarray.map_elem(arr, fn(v) {
          if v > 20.0 {
            v
          } else if v < -20.0 {
            @math.exp(v)
          } else {
            @math.ln(1.0 + @math.exp(v))
          }
        }),
      )
    },
    fn(_cp, ap, at) raise { mul(at, sigmoid(ap)) },
    fn(a, _cp, ca) raise { mul(ca.val, sigmoid(a)) },
  )
}

///|
/// Softsign: x / (1 + |x|)
pub fn softsign(a : T) -> T raise {
  siso_op(
    softsign,
    a,
    "softsign",
    fn(v) { F(v / (1.0 + v.abs())) },
    fn(arr) { Arr(@ndarray.map_elem(arr, fn(v) { v / (1.0 + v.abs()) })) },
    fn(_cp, ap, at) raise { mul(at, div(F(1.0), sqr(add(F(1.0), abs(ap))))) },
    fn(a, _cp, ca) raise { mul(ca.val, div(F(1.0), sqr(add(F(1.0), abs(a))))) },
  )
}
