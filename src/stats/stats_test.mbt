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
