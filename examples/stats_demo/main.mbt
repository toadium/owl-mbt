///|
/// 统计与分布采样示例
/// 演示描述性统计和概率分布采样
fn main raise {
  // 初始化随机数生成器
  @stats.prng_init(42)

  // 生成正态分布样本
  let samples = []
  for _ in 0..<100 {
    samples.push(@stats.gaussian_rvs(0.0, 1.0))
  }

  // 描述性统计 (stats 函数接受 Array[Double])
  let mean = @stats.mean(samples)
  let variance = @stats.variance(None, samples)
  let std = @stats.std(None, samples)
  let min = @stats.min(samples)
  let max = @stats.max(samples)

  println("正态分布 N(0,1) 采样统计 (n=100):")
  println("  均值: \{mean}")
  println("  方差: \{variance}")
  println("  标准差: \{std}")
  println("  最小值: \{min}")
  println("  最大值: \{max}")

  // 其他分布采样
  let exp_sample = @stats.exponential_rvs(1.0)
  println("\n指数分布 Exp(1) 采样: \{exp_sample}")

  let gamma_sample = @stats.gamma_rvs(2.0, 1.0)
  println("伽马分布 Gamma(2,1) 采样: \{gamma_sample}")

  let bernoulli_sample = @stats.bernoulli_rvs(0.7)
  println("伯努利分布 Bern(0.7) 采样: \{bernoulli_sample}")

  // 直方图
  let hist = @stats.histogram(@stats.BinSpec::N(10), None, samples)
  println("\n直方图 (10 bins):")
  for i in 0..<hist.counts.length() {
    let bar = "#".repeat(hist.counts[i])
    println("  bin \{i}: \{hist.counts[i]} \{bar}")
  }
}
