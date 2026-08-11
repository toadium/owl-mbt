///|
/// 全局 PRNG 状态。移植自 owl_base_stats_prng.ml。
/// OCaml 用 Random 模块（全局 Mersenne Twister），MoonBit 用 @random.Rand::chacha8。
/// MoonBit 顶层 let 不可变，用 Ref 包装可变状态。
let _rand : Ref[@random.Rand] = Ref(@random.Rand::chacha8())

///|
pub fn prng_init(seed : Int) -> Unit {
  let b = Bytes::makei(32, fn(i) {
    match i {
      0 => (seed & 0xFF).to_byte()
      1 => ((seed >> 8) & 0xFF).to_byte()
      2 => ((seed >> 16) & 0xFF).to_byte()
      3 => ((seed >> 24) & 0xFF).to_byte()
      _ => (0).to_byte()
    }
  })
  _rand.val = @random.Rand::chacha8(seed=b)
}

///|
pub fn prng_self_init() -> Unit {
  _rand.val = @random.Rand::chacha8()
}

///|
/// 返回 [0, n-1] 的随机整数。移植自 owl_base_stats_dist_uniform.ml
pub fn uniform_int_rvs(n : Int) -> Int {
  _rand.val.int(limit=n)
}

///|
/// 返回 [0, 1) 的随机浮点数。移植自 owl_base_stats_dist_uniform.ml
pub fn std_uniform_rvs() -> Double {
  _rand.val.double()
}

///|
/// 返回 [a, b) 的随机浮点数。
pub fn uniform_rvs(a : Double, b : Double) -> Double {
  a + (b - a) * _rand.val.double()
}

///|
/// 返回 (0, 1) 的随机浮点数。移植自 owl_base_stats_dist_uniform.ml
/// OCaml: 0x0.0000000000001p-1022 +. Random.float 0x1.fffffffffffffp-1
/// 即 Float.succ 0. + Random.float (Float.pred 1.)
fn rand01_exclusive() -> Double {
  5.0e-324 + _rand.val.double() * 0.9999999999999999
}
