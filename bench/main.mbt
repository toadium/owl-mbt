///|
/// 运行单组基准：热身 10% 迭代后计时。
/// 回调携带迭代索引 i，供数值函数从参数数组取值（防止编译器常量折叠）。
fn bench(name : String, iters : Int32, f : (Int32) -> Unit raise) -> Unit raise {
  let warm = iters / 10 + 1
  for i in 0..<warm {
    f(i)
  }
  let t0 = @async.now()
  for i in 0..<iters {
    f(i)
  }
  let t1 = @async.now()
  let ms = t1 - t0
  let per_us = (ms.to_double() * 1000000.0 / iters.to_double()).round() / 1000.0
  println("\{name} | \{iters} | \{ms} | \{per_us}")
}

///|
/// owl-mbt 核心操作基准。
/// 输出列：operation | iterations | total_ms | us_per_iter
/// 运行：moon run bench --release（wasm 口径）
///       moon run bench --target native --release（native 口径）
/// 多口径结果汇总见 docs/benchmark.md
fn main raise {
  println("owl-mbt benchmark | time-source=@async.now() | unit=us/iter")
  println("operation | iterations | total_ms | us_per_iter")

  // --- ndarray 基础 ---
  bench("ndarray.zeros[100x100]", 2000, _i => ignore(@ndarray.zeros([100, 100])))
  let a128 = @ndarray.sequential([128, 128])
  let b128 = @ndarray.init_flat([128, 128], fn(i) { i.to_double() + 16384.0 })
  bench("ndarray.add[128x128]", 1000, _i => ignore(@ndarray.add(a128, b128)))
  let a64 = @ndarray.sequential([64, 64])
  let b64 = @ndarray.init_flat([64, 64], fn(i) { i.to_double() + 4096.0 })
  bench("ndarray.dot[64x64]", 200, _i => ignore(@ndarray.dot(a64, b64)))

  // --- FFT（radix-2，本库实现）---
  let sig256 = @ndarray.gaussian([256], mu=0.0, sigma=1.0)
  bench("ndarray.fft[256]", 500, _i => ignore(@ndarray.fft(sig256)))
  let sig1024 = @ndarray.gaussian([1024], mu=0.0, sigma=1.0)
  bench("ndarray.fft[1024]", 100, _i => ignore(@ndarray.fft(sig1024)))
  bench("ndarray.ifft[256] round-trip", 250, _i => {
    let (re, im) = @ndarray.fft(sig256)
    ignore(@ndarray.ifft(re, im))
  })

  // --- 特殊函数（参数数组防常量折叠）---
  let gam_args = @ndarray.map_elem(
    @ndarray.gaussian([256], mu=2.0, sigma=0.5),
    fn(v) { v.abs() + 0.1 },
  )
  bench("maths.gamma", 200000, i => {
    ignore(@maths.gamma(@ndarray.get(gam_args, [i % 256])))
  })
  let j0_args = @ndarray.gaussian([256], mu=3.0, sigma=2.0)
  bench("maths.j0", 100000, i => {
    ignore(@maths.j0(@ndarray.get(j0_args, [i % 256])))
  })

  // --- 线性代数 ---
  let m32 = @ndarray.gaussian([32, 32], mu=0.0, sigma=1.0)
  bench("linalg.inv[32x32]", 100, _i => ignore(@linalg.inv(m32)))
  let m16 = @ndarray.gaussian([16, 16], mu=0.0, sigma=1.0)
  bench("linalg.svd[16x16]", 30, _i => {
    let (u, s, v) = @linalg.svd(m16)
    ignore((u, s, v))
  })

  // --- 自动微分（反向模式，输入值防折叠）---
  let ad_args = @ndarray.gaussian([64], mu=0.3, sigma=0.5)
  bench("algodiff.diff sin(exp(x))", 10000, i => {
    let f = fn(x : @algodiff.T) -> @algodiff.T raise {
      @algodiff.sin(@algodiff.exp(x))
    }
    ignore(
      @algodiff.diff(f, @algodiff.pack_flt(@ndarray.get(ad_args, [i % 64]))),
    )
  })

  // --- 统计 ---
  @stats.prng_init(42)
  bench("ndarray.gaussian[1000] (PRNG)", 500, _i => {
    ignore(@ndarray.gaussian([1000], mu=0.0, sigma=1.0))
  })
  bench("stats.prng_init+seed", 50000, _i => @stats.prng_init(42))
}
