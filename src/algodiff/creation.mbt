///|
/// Create a zero array of given shape as T.
pub fn zeros_arr(shape : Array[Int]) -> T {
  Arr(@ndarray.zeros(shape))
}

///|
/// Create a uniform random array as T.
pub fn uniform_arr(a : Double, b : Double, shape : Array[Int]) -> T {
  Arr(@ndarray.uniform(shape, a~, b~))
}

///|
/// Create a gaussian random array as T.
pub fn gaussian_arr(mu : Double, sigma : Double, shape : Array[Int]) -> T {
  Arr(@ndarray.gaussian(shape, mu~, sigma~))
}

///|
/// Copy the primal value of a T, returning a new T with no derivative info.
pub fn copy_primal_(x : T) -> T {
  match primal(x) {
    F(v) => F(v)
    Arr(arr) => Arr(@ndarray.copy(arr))
    _ => primal(x)
  }
}

///|
/// Create a constant float T (alias for pack_flt, matches OCaml's _f).
pub fn f_const(v : Double) -> T {
  F(v)
}

///|
/// Get the shape of a T as ndarray shape (excluding batch dim).
pub fn arr_shape(x : T) -> Array[Int] raise {
  let s = shape(x)
  if s.length() > 1 {
    Array::makei(s.length() - 1, fn(i) { s[i + 1] })
  } else {
    []
  }
}
