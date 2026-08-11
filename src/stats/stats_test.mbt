///|
/// 描述统计测试。golden values 来自 OCaml owl-base 参考行为。
test "sum and mean" {
  @test.assert_eq(sum([1.0, 2.0, 3.0, 4.0]), 10.0)
  @test.assert_eq(mean([1.0, 2.0, 3.0, 4.0]), 2.5)
  @test.assert_eq(sum([]), 0.0)
}

///|
test "variance and std" {
  let x = [1.0, 2.0, 3.0, 4.0, 5.0]
  inspect(
    variance(None, x),
    content=(
      #|2.5
    ),
  )
  inspect(
    std(None, x),
    content=(
      #|1.5811388300841898
    ),
  )
  inspect(
    variance(Some(3.0), x),
    content=(
      #|2.5
    ),
  )
}

///|
test "sem and absdev" {
  let x = [1.0, 2.0, 3.0, 4.0, 5.0]
  inspect(
    sem(None, x),
    content=(
      #|0.7071067811865476
    ),
  )
  inspect(
    absdev(None, x),
    content=(
      #|1.2
    ),
  )
}

///|
test "skew and kurtosis" {
  let x = [1.0, 2.0, 3.0, 4.0, 5.0]
  inspect(
    skew(None, None, x),
    content=(
      #|0
    ),
  )
  inspect(
    kurtosis(None, None, x),
    content=(
      #|1.0880000000000003
    ),
  )
}

///|
test "central_moment" {
  let x = [1.0, 2.0, 3.0, 4.0, 5.0]
  inspect(
    central_moment(2, x),
    content=(
      #|2
    ),
  )
  inspect(
    central_moment(3, x),
    content=(
      #|0
    ),
  )
}

///|
test "cov" {
  let x0 = [1.0, 2.0, 3.0, 4.0]
  let x1 = [2.0, 4.0, 6.0, 8.0]
  inspect(
    cov(None, None, x0, x1),
    content=(
      #|2.5
    ),
  )
}

///|
/// 排序与秩测试。
test "sort" {
  @test.assert_eq(sort([3.0, 1.0, 2.0]), [1.0, 2.0, 3.0])
  @test.assert_eq(sort(inc=false, [3.0, 1.0, 2.0]), [3.0, 2.0, 1.0])
  @test.assert_eq(sort([5.0]), [5.0])
}

///|
test "argsort" {
  @test.assert_eq(argsort([3.0, 1.0, 2.0]), [1, 2, 0])
  @test.assert_eq(argsort(inc=false, [3.0, 1.0, 2.0]), [0, 2, 1])
}

///|
test "rank" {
  @test.assert_eq([3.0, 1.0, 2.0], rank([3.0, 1.0, 2.0]))
  @test.assert_eq([1.5, 1.5, 3.0], rank([1.0, 1.0, 3.0]))
  @test.assert_eq([2.0, 2.0, 2.0], rank([1.0, 1.0, 1.0]))
}

///|
test "kendall_tau" {
  let x0 = [1.0, 2.0, 3.0, 4.0]
  let x1 = [1.0, 2.0, 3.0, 4.0]
  inspect(
    kendall_tau(x0, x1),
    content=(
      #|1
    ),
  )
}

///|
/// 极值测试。
test "min max minmax" {
  let x = [3.0, 1.0, 4.0, 1.0, 5.0]
  @test.assert_eq(min(x), 1.0)
  @test.assert_eq(max(x), 5.0)
  @test.assert_eq(minmax(x), (1.0, 5.0))
  @test.assert_eq(min_i(x), 1)
  @test.assert_eq(max_i(x), 4)
  @test.assert_eq(minmax_i(x), (1, 4))
}

///|
/// 分位数测试。
test "percentile and median" {
  let x = [1.0, 2.0, 3.0, 4.0, 5.0]
  inspect(
    median(x),
    content=(
      #|3
    ),
  )
  inspect(
    percentile(x, 0.0),
    content=(
      #|1
    ),
  )
  inspect(
    percentile(x, 100.0),
    content=(
      #|5
    ),
  )
  inspect(
    first_quartile(x),
    content=(
      #|2
    ),
  )
  inspect(
    third_quartile(x),
    content=(
      #|4
    ),
  )
  inspect(
    interquartile(x),
    content=(
      #|2
    ),
  )
}

///|
test "tukey_fences" {
  let x = [1.0, 2.0, 3.0, 4.0, 5.0]
  @test.assert_eq((-1.0, 7.0), tukey_fences(x))
}

///|
/// 直方图测试。
test "histogram uniform" {
  let x = [0.5, 1.5, 2.5, 3.5, 0.8, 1.2]
  let h = histogram(BinSpec::N(4), None, x)
  @test.assert_eq(h.counts, [3, 1, 1, 1])
  @test.assert_eq(h.bins.length(), 5)
}

///|
test "histogram nonuniform" {
  let x = [0.5, 1.5, 2.5, 3.5]
  let bins = [0.0, 1.0, 2.0, 3.0, 4.0]
  let h = histogram(BinSpec::Bins(bins), None, x)
  @test.assert_eq(h.counts, [1, 1, 1, 1])
}

///|
test "histogram normalise" {
  let x = [0.5, 1.5, 2.5, 3.5, 0.8, 1.2]
  let h = histogram(BinSpec::N(4), None, x)
  let hn = normalise(h)
  let nc = match hn.normalised_counts {
    Some(v) => v
    None => []
  }
  inspect(
    nc[0],
    content=(
      #|0.5
    ),
  )
}

///|
/// 分布采样测试（检查值域，不检查精确值）。
test "uniform rvs" {
  prng_init(42)
  let v = uniform_rvs(0.0, 10.0)
  @test.assert_eq(true, v >= 0.0 && v < 10.0)
}

///|
test "gaussian rvs" {
  prng_init(42)
  let v = gaussian_rvs(0.0, 1.0)
  @test.assert_eq(true, !v.is_nan())
}

///|
test "exponential rvs" {
  prng_init(42)
  let v = exponential_rvs(1.0)
  @test.assert_eq(true, v >= 0.0)
}

///|
test "gamma rvs" {
  prng_init(42)
  let v = gamma_rvs(2.0, 1.0)
  @test.assert_eq(true, v >= 0.0)
}

///|
test "bernoulli rvs" {
  prng_init(42)
  let v = bernoulli_rvs(0.5)
  @test.assert_eq(true, v == 0.0 || v == 1.0)
}

///|
/// 采样测试。
test "shuffle" {
  prng_init(42)
  let x = [1, 2, 3, 4, 5]
  let y = shuffle(x)
  @test.assert_eq(y.length(), 5)
  @test.assert_eq(x, [1, 2, 3, 4, 5])
}

///|
test "sample" {
  prng_init(42)
  let x = [10, 20, 30, 40, 50]
  let y = sample(x, 3)
  @test.assert_eq(y.length(), 3)
  for v in y {
    @test.assert_eq(true, x.contains(v))
  }
}

///|
test "choose" {
  prng_init(42)
  let x = [10, 20, 30, 40, 50]
  let y = choose(x, 3)
  @test.assert_eq(y.length(), 3)
}

// ===== Business Scenario Tests =====

///|
test "scenario: descriptive statistics workflow" {
  let data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
  let m = mean(data)
  @test.assert_eq(true, (m - 5.5).abs() < 1.0e-10)
  let v = variance(Some(m), data)
  @test.assert_eq(true, v > 0.0)
  let s = std(Some(m), data)
  @test.assert_eq(true, (s - v.sqrt()).abs() < 1.0e-10)
  let sk = skew(Some(m), Some(s), data)
  // Symmetric data → skewness ≈ 0
  @test.assert_eq(true, sk.abs() < 1.0e-10)
  let k = kurtosis(Some(m), Some(s), data)
  @test.assert_eq(true, k > 0.0)
  let ad = absdev(Some(m), data)
  @test.assert_eq(true, ad > 0.0)
  let cm = central_moment(3, data)
  // Symmetric data → odd central moment ≈ 0
  @test.assert_eq(true, cm.abs() < 1.0e-8)
}

///|
test "scenario: covariance and correlation" {
  let x = [1.0, 2.0, 3.0, 4.0, 5.0]
  let y = [2.0, 4.0, 6.0, 8.0, 10.0]
  let c = cov(None, None, x, y)
  // y = 2x, so cov(x,y) = 2*var(x) = 2*2 = 4
  @test.assert_eq(true, (c - 4.0).abs() < 1.0e-10)
  let tau = kendall_tau(x, y)
  // Perfect monotonic → tau = 1
  @test.assert_eq(true, (tau - 1.0).abs() < 1.0e-10)
}

///|
test "scenario: distribution sampling" {
  prng_init(42)
  // Gaussian sampling
  let mut gauss_sum = 0.0
  let n = 1000
  for _ in 0..<n {
    gauss_sum += gaussian_rvs(0.0, 1.0)
  }
  // Mean of N(0,1) samples should be close to 0. Tolerance 0.2 accounts for
  // sampling noise with n=200 (std error ~ 1/sqrt(200) ≈ 0.07, 3-sigma ≈ 0.2).
  let sample_mean = gauss_sum / n.to_double()
  @test.assert_eq(true, sample_mean.abs() < 0.2)
  // Exponential sampling
  let mut exp_sum = 0.0
  for _ in 0..<n {
    exp_sum += exponential_rvs(1.0)
  }
  // Mean of Exp(1) samples should be close to 1. Tolerance 0.3 accounts for
  // sampling noise with n=200 (std error ~ 1/sqrt(200) ≈ 0.07, 4-sigma ≈ 0.3).
  let exp_mean = exp_sum / n.to_double()
  @test.assert_eq(true, (exp_mean - 1.0).abs() < 0.3)
}

///|
test "scenario: quantile and percentile analysis" {
  let data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
  let med = median(data)
  @test.assert_eq(true, (med - 5.5).abs() < 1.0e-10)
  let q1 = first_quartile(data)
  @test.assert_eq(true, q1 > 0.0)
  let q3 = third_quartile(data)
  @test.assert_eq(true, q3 > q1)
  let iqr = interquartile(data)
  @test.assert_eq(true, iqr > 0.0)
  let p90 = percentile(data, 90.0)
  @test.assert_eq(true, p90 > med)
}

///|
test "scenario: order statistics and sorting" {
  let data = [5.0, 3.0, 8.0, 1.0, 9.0, 2.0, 7.0, 4.0, 6.0]
  let sorted = sort(data)
  @test.assert_eq(1.0, sorted[0])
  @test.assert_eq(9.0, sorted[8])
  let sorted_desc = sort(inc=false, data)
  @test.assert_eq(9.0, sorted_desc[0])
  let (min_v, max_v) = minmax(data)
  @test.assert_eq(1.0, min_v)
  @test.assert_eq(9.0, max_v)
  let min_idx = min_i(data)
  @test.assert_eq(3, min_idx)
  let max_idx = max_i(data)
  @test.assert_eq(4, max_idx)
}

///|
test "scenario: histogram construction" {
  prng_init(42)
  let data = []
  for _ in 0..<100 {
    data.push(gaussian_rvs(0.0, 1.0))
  }
  let (bins, counts) = hist_uniform(10, data)
  @test.assert_eq(10, counts.length())
  @test.assert_eq(11, bins.length())
  // Total count should equal data length
  let mut total = 0
  for c in counts {
    total += c
  }
  @test.assert_eq(100, total)
}

///|
test "scenario: PRNG reproducibility" {
  prng_init(123)
  let v1 = std_uniform_rvs()
  let v2 = std_uniform_rvs()
  prng_init(123)
  let v3 = std_uniform_rvs()
  let v4 = std_uniform_rvs()
  // Same seed → same sequence
  @test.assert_eq(v1, v3)
  @test.assert_eq(v2, v4)
}

///|
/// T111: sort then argsort gives sorted order
test "invariance: sort-argsort relation" {
  let x = [3.0, 1.0, 4.0, 1.0, 5.0, 9.0, 2.0, 6.0]
  let s = sort(x)
  let idx = argsort(x)
  // argsort indices should produce sorted array
  for i in 0..<x.length() {
    @test.assert_eq(s[i], x[idx[i]])
  }
}

///|
/// T111: sort is idempotent (sort(sort(x)) == sort(x))
test "invariance: sort idempotent" {
  let x = [3.0, 1.0, 4.0, 1.0, 5.0]
  let s1 = sort(x)
  let s2 = sort(s1)
  for i in 0..<x.length() {
    @test.assert_eq(s1[i], s2[i])
  }
}

///|
/// T111: minmax matches min and max individually
test "invariance: minmax matches min/max" {
  let x = [3.0, 1.0, 4.0, 1.0, 5.0, 9.0, 2.0, 6.0]
  let (mn, mx) = minmax(x)
  @test.assert_eq(mn, min(x))
  @test.assert_eq(mx, max(x))
}

///|
/// Coverage: weighted histogram uniform
test "histogram weighted uniform" {
  let x = [0.5, 1.5, 2.5, 3.5, 0.8, 1.2]
  let w = [1.0, 2.0, 3.0, 4.0, 0.5, 0.5]
  let h = histogram(BinSpec::N(4), Some(w), x)
  @test.assert_eq(h.counts, [3, 1, 1, 1])
  let wc = match h.weighted_counts {
    Some(v) => v
    None => []
  }
  @test.assert_eq(2.0, wc[0])
  @test.assert_eq(2.0, wc[1])
  @test.assert_eq(3.0, wc[2])
  @test.assert_eq(4.0, wc[3])
}

///|
/// Coverage: weighted histogram nonuniform
test "histogram weighted nonuniform" {
  let x = [0.5, 1.5, 2.5, 3.5]
  let w = [1.0, 2.0, 3.0, 4.0]
  let bins = [0.0, 1.0, 2.0, 3.0, 4.0]
  let h = histogram(BinSpec::Bins(bins), Some(w), x)
  @test.assert_eq(h.counts, [1, 1, 1, 1])
  let wc = match h.weighted_counts {
    Some(v) => v
    None => []
  }
  @test.assert_eq(1.0, wc[0])
  @test.assert_eq(2.0, wc[1])
  @test.assert_eq(3.0, wc[2])
  @test.assert_eq(4.0, wc[3])
}

///|
/// Coverage: histogram_sorted with N bins
test "histogram_sorted uniform" {
  let x = [0.5, 0.8, 1.2, 1.5, 2.5, 3.5]
  let h = histogram_sorted(BinSpec::N(4), None, x)
  @test.assert_eq(h.counts, [3, 1, 1, 1])
}

///|
/// Coverage: histogram_sorted with explicit bins
test "histogram_sorted explicit bins" {
  let x = [0.5, 1.5, 2.5, 3.5]
  let bins = [0.0, 1.0, 2.0, 3.0, 4.0]
  let h = histogram_sorted(BinSpec::Bins(bins), None, x)
  @test.assert_eq(h.counts, [1, 1, 1, 1])
}

///|
/// Coverage: histogram_sorted weighted
test "histogram_sorted weighted" {
  let x = [0.5, 0.8, 1.2, 1.5, 2.5, 3.5]
  let w = [1.0, 0.5, 0.5, 2.0, 3.0, 4.0]
  let h = histogram_sorted(BinSpec::N(4), Some(w), x)
  @test.assert_eq(h.counts, [3, 1, 1, 1])
  let wc = match h.weighted_counts {
    Some(v) => v
    None => []
  }
  @test.assert_eq(2.0, wc[0])
  @test.assert_eq(2.0, wc[1])
}

///|
/// Coverage: normalise with weighted counts
test "histogram normalise weighted" {
  let x = [0.5, 1.5, 2.5, 3.5]
  let w = [1.0, 1.0, 2.0, 2.0]
  let h = histogram(BinSpec::N(4), Some(w), x)
  let hn = normalise(h)
  let nc = match hn.normalised_counts {
    Some(v) => v
    None => []
  }
  @test.assert_eq(true, (nc[0] - 1.0 / 6.0).abs() < 1.0e-10)
  @test.assert_eq(true, (nc[2] - 2.0 / 6.0).abs() < 1.0e-10)
}

///|
/// Coverage: normalise_density
test "histogram normalise_density" {
  let x = [0.5, 1.5, 2.5, 3.5, 0.8, 1.2]
  let h = histogram(BinSpec::N(4), None, x)
  let hd = normalise_density(h)
  let ds = match hd.density {
    Some(v) => v
    None => []
  }
  // min=0.5, max=3.5, db=0.75, total=6
  // density[i] = count[i] / db / total
  let db = 0.75
  @test.assert_eq(true, (ds[0] - 3.0 / db / 6.0).abs() < 1.0e-10)
  @test.assert_eq(true, (ds[1] - 1.0 / db / 6.0).abs() < 1.0e-10)
}

///|
/// Coverage: normalise_density with weighted counts
test "histogram normalise_density weighted" {
  let x = [0.5, 1.5, 2.5, 3.5]
  let w = [1.0, 1.0, 2.0, 2.0]
  let h = histogram(BinSpec::N(4), Some(w), x)
  let hd = normalise_density(h)
  let ds = match hd.density {
    Some(v) => v
    None => []
  }
  // min=0.5, max=3.5, db=0.75, total=6
  let db = 0.75
  @test.assert_eq(true, (ds[0] - 1.0 / db / 6.0).abs() < 1.0e-10)
  @test.assert_eq(true, (ds[2] - 2.0 / db / 6.0).abs() < 1.0e-10)
}

///|
/// Coverage: hist_weighted_uniform directly
test "hist_weighted_uniform direct" {
  let x = [1.0, 2.0, 3.0, 4.0, 5.0]
  let w = [0.5, 1.0, 1.5, 2.0, 2.5]
  let ((bins, counts), wc) = hist_weighted_uniform(5, w, x)
  @test.assert_eq(5, counts.length())
  @test.assert_eq(5, wc.length())
  @test.assert_eq(6, bins.length())
  @test.assert_eq(0.5, wc[0])
  @test.assert_eq(2.5, wc[4])
}

///|
/// Coverage: hist_weighted_nonuniform directly
test "hist_weighted_nonuniform direct" {
  let x = [1.0, 2.0, 3.0, 4.0, 5.0]
  let w = [0.5, 1.0, 1.5, 2.0, 2.5]
  let bins = [0.0, 2.0, 4.0, 6.0]
  let ((_, counts), wc) = hist_weighted_nonuniform(bins, w, x)
  @test.assert_eq(3, counts.length())
  @test.assert_eq(0.5, wc[0])
  @test.assert_eq(2.5, wc[1])
  @test.assert_eq(4.5, wc[2])
}

///|
/// Coverage: hist_sorted directly
test "hist_sorted direct" {
  let x = [0.5, 1.5, 2.5, 3.5]
  let bins = [0.0, 1.0, 2.0, 3.0, 4.0]
  let (b, c) = hist_sorted(bins, x)
  @test.assert_eq([1, 1, 1, 1], c)
  @test.assert_eq(bins, b)
}

///|
/// Coverage: hist_weighted_sorted directly
test "hist_weighted_sorted direct" {
  let x = [0.5, 1.5, 2.5, 3.5]
  let w = [1.0, 2.0, 3.0, 4.0]
  let bins = [0.0, 1.0, 2.0, 3.0, 4.0]
  let ((_, c), wc) = hist_weighted_sorted(bins, w, x)
  @test.assert_eq([1, 1, 1, 1], c)
  @test.assert_eq(1.0, wc[0])
  @test.assert_eq(4.0, wc[3])
}

///|
/// Coverage: histogram error - mismatched weights
test "histogram error: mismatched weights" {
  let x = [1.0, 2.0, 3.0]
  let w = [1.0, 2.0]
  let raised = try {
    let _ = histogram(BinSpec::N(2), Some(w), x)
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, raised)
}

///|
/// Coverage: std_gaussian_rvs with cache (second call uses cached z1)
test "dist: std_gaussian_rvs cache" {
  prng_init(42)
  let _ = std_gaussian_rvs()
  let v = std_gaussian_rvs()
  @test.assert_eq(true, !v.is_nan())
}

///|
/// Coverage: std_exponential_rvs
test "dist: std_exponential_rvs" {
  prng_init(42)
  let v = std_exponential_rvs()
  @test.assert_eq(true, v >= 0.0)
}

///|
/// Coverage: exponential_rvs error branch (lambda <= 0)
test "dist: exponential_rvs invalid lambda" {
  prng_init(42)
  let raised = try {
    let _ = exponential_rvs(0.0)
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, raised)
}

///|
/// Coverage: std_cauchy_rvs
test "dist: std_cauchy_rvs" {
  prng_init(42)
  let v = std_cauchy_rvs()
  @test.assert_eq(true, !v.is_nan())
}

///|
/// Coverage: cauchy_rvs
test "dist: cauchy_rvs" {
  prng_init(42)
  let v = cauchy_rvs(1.0, 2.0)
  @test.assert_eq(true, !v.is_nan())
}

///|
/// Coverage: std_gamma_rvs shape == 1.0 (exponential fallback)
test "dist: std_gamma_rvs shape 1" {
  prng_init(42)
  let v = std_gamma_rvs(1.0)
  @test.assert_eq(true, v >= 0.0)
}

///|
/// Coverage: std_gamma_rvs shape < 1.0
test "dist: std_gamma_rvs shape < 1" {
  prng_init(42)
  let v = std_gamma_rvs(0.5)
  @test.assert_eq(true, v >= 0.0)
}

///|
/// Coverage: std_gamma_rvs shape > 1.0 (Marsaglia-Tsang)
test "dist: std_gamma_rvs shape > 1" {
  prng_init(42)
  let v = std_gamma_rvs(3.0)
  @test.assert_eq(true, v >= 0.0)
}

///|
/// Coverage: gamma_rvs with different shape/scale
test "dist: gamma_rvs shape scale" {
  prng_init(42)
  let v = gamma_rvs(0.5, 2.0)
  @test.assert_eq(true, v >= 0.0)
}

///|
/// Coverage: gumbel1_rvs
test "dist: gumbel1_rvs" {
  prng_init(42)
  let v = gumbel1_rvs(1.0, 1.0)
  @test.assert_eq(true, !v.is_nan())
}

///|
/// Coverage: gumbel1_rvs error: a == 0
test "dist: gumbel1_rvs a zero" {
  prng_init(42)
  let raised = try {
    let _ = gumbel1_rvs(0.0, 1.0)
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, raised)
}

///|
/// Coverage: gumbel1_rvs error: b <= 0
test "dist: gumbel1_rvs b negative" {
  prng_init(42)
  let raised = try {
    let _ = gumbel1_rvs(1.0, -1.0)
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, raised)
}

///|
/// Coverage: gumbel2_rvs
test "dist: gumbel2_rvs" {
  prng_init(42)
  let v = gumbel2_rvs(2.0, 1.0)
  @test.assert_eq(true, !v.is_nan())
}

///|
/// Coverage: gumbel2_rvs error: a == 0
test "dist: gumbel2_rvs a zero" {
  prng_init(42)
  let raised = try {
    let _ = gumbel2_rvs(0.0, 1.0)
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, raised)
}

///|
/// Coverage: gumbel2_rvs error: b <= 0
test "dist: gumbel2_rvs b negative" {
  prng_init(42)
  let raised = try {
    let _ = gumbel2_rvs(1.0, 0.0)
    false
  } catch {
    _ => true
  }
  @test.assert_eq(true, raised)
}
