///|
/// Derivative of f (scalar -> scalar) at x, forward AD.
/// Returns (primal, tangent).
pub fn diff_prime(f : (T) -> T raise, x : T) -> (T, T) raise {
  if !is_float(x) {
    raise @types.OwlError::InvalidArgument("diff: input must be a scalar")
  }
  let x_df = make_forward(x, pack_flt(1.0), tag())
  let y = f(x_df)
  (primal(y), tangent(y))
}

///|
/// Derivative of f (scalar -> scalar) at x, forward AD.
pub fn diff(f : (T) -> T raise, x : T) -> T raise {
  let (_, t) = diff_prime(f, x)
  t
}

///|
/// Gradient of f (vector -> scalar) at x, reverse AD.
/// Returns (primal, gradient).
pub fn grad_prime(f : (T) -> T raise, x : T) -> (T, T) raise {
  let x_dr = make_reverse(x, tag())
  let y = f(x_dr)
  if !is_float(y) {
    raise @types.OwlError::InvalidArgument("grad: output must be a scalar")
  }
  reverse_reset(y)
  reverse_push(pack_flt(1.0), y)
  (primal(y), adjval(x_dr))
}

///|
/// Gradient of f (vector -> scalar) at x, reverse AD.
pub fn grad(f : (T) -> T raise, x : T) -> T raise {
  let (_, g) = grad_prime(f, x)
  g
}

///|
/// Jacobian-vector product of f (vector -> vector) at x along v, forward AD.
/// Returns (primal, jvp).
pub fn jacobianv_prime(f : (T) -> T raise, x : T, v : T) -> (T, T) raise {
  if shape(x) != shape(v) {
    raise @types.OwlError::InvalidArgument(
      "jacobianv: vector dimension mismatch",
    )
  }
  let x_df = make_forward(x, v, tag())
  let y = f(x_df)
  (primal(y), tangent(y))
}

///|
/// Jacobian-vector product of f (vector -> vector) at x along v, forward AD.
pub fn jacobianv(f : (T) -> T raise, x : T, v : T) -> T raise {
  let (_, t) = jacobianv_prime(f, x, v)
  t
}

///|
/// Transposed Jacobian-vector product of f (vector -> vector) at x along v, backward AD.
/// Returns (primal, jtv).
pub fn jacobianTv_prime(f : (T) -> T raise, x : T, v : T) -> (T, T) raise {
  let x_dr = make_reverse(x, tag())
  let y = f(x_dr)
  if shape(y) != shape(v) {
    raise @types.OwlError::InvalidArgument(
      "jacobianTv: vector dimension mismatch",
    )
  }
  reverse_reset(y)
  reverse_push(v, y)
  (primal(y), adjval(x_dr))
}

///|
/// Transposed Jacobian-vector product of f (vector -> vector) at x along v, backward AD.
pub fn jacobianTv(f : (T) -> T raise, x : T, v : T) -> T raise {
  let (_, t) = jacobianTv_prime(f, x, v)
  t
}

///|
/// Jacobian of f (row vector -> row vector) at x.
/// Returns (primal, jacobian).
///
/// Assumes input and output are 2D row vectors of shape `[1, n]` and `[1, m]`.
/// For 1D inputs, `m` or `n` defaults to 1. For 3D+ inputs, only the second
/// dimension is used and higher dimensions are ignored.
pub fn jacobian_prime(f : (T) -> T raise, x : T) -> (T, T) raise {
  let y = f(x)
  let y_shape = shape(y)
  let x_shape = shape(x)
  let m = if y_shape.length() >= 2 { y_shape[1] } else { 1 }
  let n = if x_shape.length() >= 2 { x_shape[1] } else { 1 }
  let jvps : Array[T] = []
  if m > n {
    for i in 0..<n {
      let v_arr = @ndarray.zeros([1, n])
      @ndarray.set(v_arr, [0, i], 1.0)
      let jvp = jacobianv(f, x, Arr(v_arr))
      jvps.push(jvp)
    }
  } else {
    for i in 0..<m {
      let v_arr = @ndarray.zeros([1, m])
      @ndarray.set(v_arr, [0, i], 1.0)
      let jtv = jacobianTv(f, x, Arr(v_arr))
      jvps.push(jtv)
    }
  }
  let z = if m > n {
    concatenate(jvps, axis=0)
  } else {
    transpose(concatenate(jvps, axis=0))
  }
  (primal(y), z)
}

///|
/// Jacobian of f (row vector -> row vector) at x.
pub fn jacobian(f : (T) -> T raise, x : T) -> T raise {
  let (_, j) = jacobian_prime(f, x)
  j
}

///|
/// Hessian of f (vector -> scalar) at x.
///
/// Warning: implemented via nested reverse-mode AD (`jacobian(grad(f), x)`).
/// The inner `grad` mutates global tag state and node adjoint refs, which can
/// interfere with the outer `jacobian`'s AD graph. Results may be unreliable
/// for complex functions. Consider this experimental.
pub fn hessian(f : (T) -> T raise, x : T) -> T raise {
  let g = fn(x : T) -> T raise { grad(f, x) }
  jacobian(g, x)
}

///|
/// Hessian of f, returns (primal, hessian).
pub fn hessian_prime(f : (T) -> T raise, x : T) -> (T, T) raise {
  (f(x), hessian(f, x))
}
