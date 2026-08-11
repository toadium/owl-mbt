///|
/// Count-Min sketch for probabilistic frequency counting.
pub struct CountMinSketch {
  tbl : Ref[Array[Array[Int]]]
  w : Int
  hash_fns : Array[(Int, Int, Int)]
}

///|
/// The prime number for hashing.
let _bigprime : Int = 2147483647

///|
/// Calculate (a*x + b) mod (2^31 - 1) using Int64 to avoid overflow.
fn _hash31(x : Int, a : Int, b : Int) -> Int {
  let xl = x.to_int64()
  let al = a.to_int64()
  let bl = b.to_int64()
  let result = al * xl + bl
  let h = ((result >> 31) + result) & _bigprime.to_int64()
  h.to_int()
}

///|
/// Initialize a Count-Min sketch with given depth (l) and width (w).
pub fn cms_init_lw(l : Int, w : Int) -> CountMinSketch raise {
  if l <= 0 || w <= 0 {
    raise @types.OwlError::InvalidArgument(
      "cms_init_lw: l and w must be positive",
    )
  }
  let tbl = Array::makei(l, fn(_i) { Array::make(w, 0) })
  let hash_fns = Array::makei(l, fn(i) {
    let a = @stats.uniform_int_rvs(1073741823)
    let b = @stats.uniform_int_rvs(1073741823)
    (i, a, b)
  })
  { tbl: Ref(tbl), w, hash_fns }
}

///|
/// Initialize a Count-Min sketch with error bounds epsilon and delta.
pub fn cms_init(epsilon : Double, delta : Double) -> CountMinSketch raise {
  if epsilon <= 0.0 || epsilon >= 1.0 || delta <= 0.0 || delta >= 1.0 {
    raise @types.OwlError::InvalidArgument(
      "cms_init: epsilon and delta must be in (0, 1)",
    )
  }
  let l = @math.ceil(@math.log2(1.0 / delta)).to_int()
  let w = @math.ceil(1.0 / epsilon).to_int()
  cms_init_lw(l, w)
}

///|
/// Increment the count for an element.
pub fn cms_incr(s : CountMinSketch, x : Int) -> Unit {
  for i in 0..<s.hash_fns.length() {
    let (_, ai, bi) = s.hash_fns[i]
    let raw = _hash31(x, ai, bi) % s.w
    let idx = if raw < 0 { raw + s.w } else { raw }
    s.tbl.val[i][idx] = s.tbl.val[i][idx] + 1
  }
}

///|
/// Get the estimated count for an element.
pub fn cms_count(s : CountMinSketch, x : Int) -> Int {
  let mut min_val = 2147483647
  for i in 0..<s.hash_fns.length() {
    let (_, ai, bi) = s.hash_fns[i]
    let raw = _hash31(x, ai, bi) % s.w
    let idx = if raw < 0 { raw + s.w } else { raw }
    if s.tbl.val[i][idx] < min_val {
      min_val = s.tbl.val[i][idx]
    }
  }
  min_val
}
