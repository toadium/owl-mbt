///|
/// 浏览器演示导出层（WebAssembly GC 目标）。
/// 只导出 f64 → f64 的纯函数，避免跨语言字符串/数组 ABI；计算全部在浏览器 wasm 内完成。
/// Browser demo exports (WasmGC). Only f64 -> f64 pure functions cross the
/// boundary; all computation runs inside the browser WebAssembly module.

///|
#export_name("owl_dot4")
pub fn owl_dot4(
  a0 : Double,
  a1 : Double,
  a2 : Double,
  a3 : Double,
  b0 : Double,
  b1 : Double,
  b2 : Double,
  b3 : Double,
) -> Double {
  a0 * b0 + a1 * b1 + a2 * b2 + a3 * b3
}

///|
#export_name("owl_det2")
pub fn owl_det2(a : Double, b : Double, c : Double, d : Double) -> Double {
  a * d - b * c
}

///|
#export_name("owl_mean4")
pub fn owl_mean4(a : Double, b : Double, c : Double, d : Double) -> Double {
  (a + b + c + d) / 4.0
}

///|
#export_name("owl_var4")
pub fn owl_var4(a : Double, b : Double, c : Double, d : Double) -> Double {
  let m = (a + b + c + d) / 4.0
  let s = (a - m) * (a - m) +
    (b - m) * (b - m) +
    (c - m) * (c - m) +
    (d - m) * (d - m)
  s / 4.0
}

///|
#export_name("owl_gamma")
pub fn owl_gamma(x : Double) -> Double {
  @maths.gamma(x)
}

///|
#export_name("owl_j0")
pub fn owl_j0(x : Double) -> Double {
  @maths.j0(x)
}

///|
#export_name("owl_erf")
pub fn owl_erf(x : Double) -> Double {
  @maths.erf(x)
}

///|
#export_name("owl_kde_pdf")
pub fn owl_kde_pdf(
  x : Double,
  v0 : Double,
  v1 : Double,
  v2 : Double,
  v3 : Double,
) -> Double {
  let h = 0.5
  let k = fn(p : Double) -> Double {
    let u = (p - x) / h
    @maths.exp(-u * u / 2.0) / (h * 2.5066282746310002)
  }
  (k(v0) + k(v1) + k(v2) + k(v3)) / 4.0
}
