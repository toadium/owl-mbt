///|
/// Initialize an ndarray with a flat-index function.
/// f receives the flat (row-major) index [0, n).
pub fn init_flat(shape : Array[Int], f : (Int) -> Double) -> Ndarray {
  let n = _numel_shape(shape)
  let data = FixedArray::make(n, 0.0)
  for i in 0..<n {
    data[i] = f(i)
  }
  { shape: shape.copy(), data }
}

///|
/// Create an ndarray with uniform random values in [a, b).
pub fn uniform(
  shape : Array[Int],
  a? : Double = 0.0,
  b? : Double = 1.0,
) -> Ndarray {
  let n = _numel_shape(shape)
  let data = FixedArray::make(n, 0.0)
  for i in 0..<n {
    data[i] = @stats.uniform_rvs(a, b)
  }
  { shape: shape.copy(), data }
}

///|
/// Create an ndarray with Gaussian random values.
pub fn gaussian(
  shape : Array[Int],
  mu? : Double = 0.0,
  sigma? : Double = 1.0,
) -> Ndarray {
  let n = _numel_shape(shape)
  let data = FixedArray::make(n, 0.0)
  for i in 0..<n {
    data[i] = @stats.gaussian_rvs(mu, sigma)
  }
  { shape: shape.copy(), data }
}

///|
/// Create an ndarray with Bernoulli random values (0 or 1).
pub fn bernoulli(shape : Array[Int], p? : Double = 0.5) -> Ndarray {
  let n = _numel_shape(shape)
  let data = FixedArray::make(n, 0.0)
  for i in 0..<n {
    data[i] = @stats.bernoulli_rvs(p)
  }
  { shape: shape.copy(), data }
}
