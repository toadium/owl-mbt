///|
/// 直方图。移植自 owl_base_stats.ml 第 289-521 行。

///|
pub(all) struct Histogram {
  bins : Array[Double]
  counts : Array[Int]
  weighted_counts : Array[Double]?
  normalised_counts : Array[Double]?
  density : Array[Double]?
} derive(Debug)

///|
/// 分箱规格。移植自 OCaml polymorphic variant `N of int | `Bins of float array
pub(all) enum BinSpec {
  N(Int)
  Bins(Array[Double])
} derive(Debug)

///|
fn fcmp(a : Double, b : Double) -> Int {
  if a < b {
    -1
  } else if a > b {
    1
  } else {
    0
  }
}

///|
/// 二分搜索。移植自 owl_utils_array.ml bsearch。
/// 返回最大 bin_edge <= k 的索引。左闭右开。
fn _bsearch_aux(k : Double, edges : Array[Double], i : Int, j : Int) -> Int {
  if i > j {
    j
  } else {
    let middle = i + (j - i) / 2
    let c = fcmp(k, edges[middle])
    if c == 0 {
      middle
    } else if c < 0 {
      _bsearch_aux(k, edges, i, middle - 1)
    } else {
      _bsearch_aux(k, edges, middle + 1, j)
    }
  }
}

///|
fn bsearch(k : Double, edges : Array[Double]) -> Int raise {
  let n = edges.length() - 1
  if n < 0 {
    raise @types.OwlError::InvalidArgument("bsearch: empty array")
  }
  let c0 = fcmp(edges[0], k)
  let cn = fcmp(edges[n], k)
  if c0 > 0 {
    -1
  } else if cn <= 0 {
    n
  } else {
    _bsearch_aux(k, edges, 0, n)
  }
}

///|
/// 均匀分箱设置。移植自 owl_base_stats.ml setup_uniform_binning
fn setup_uniform_binning(
  n : Int,
  x : Array[Double],
) -> (Double, Double, Double, Array[Double], (Double) -> Int) raise {
  if n < 1 {
    raise @types.OwlError::InvalidArgument("Need at least one bin!")
  }
  let (bmin, bmax) = minmax(x)
  let db = (bmax - bmin) / n.to_double()
  let nbins = n + 1
  let bins = [ for i in 0..<nbins => bmin + i.to_double() * db ]
  let get_bin = fn(y : Double) -> Int {
    let i = ((y - bmin) / db).to_int()
    if i == n {
      n - 1
    } else {
      i
    }
  }
  (bmin, bmax, db, bins, get_bin)
}

///|
/// 均匀分箱直方图。移植自 owl_base_stats.ml hist_uniform
pub fn hist_uniform(
  n : Int,
  x : Array[Double],
) -> (Array[Double], Array[Int]) raise {
  let (_, _, _, bins, get_bin) = setup_uniform_binning(n, x)
  let c = Array::make(n, 0)
  for y in x {
    let i = get_bin(y)
    c[i] += 1
  }
  (bins, c)
}

///|
/// 加权均匀分箱直方图。移植自 owl_base_stats.ml hist_weighted_uniform
pub fn hist_weighted_uniform(
  n : Int,
  w : Array[Double],
  x : Array[Double],
) -> ((Array[Double], Array[Int]), Array[Double]) raise {
  if x.length() != w.length() {
    raise @types.OwlError::InvalidArgument(
      "Data and weights must have the same length.",
    )
  }
  let (_, _, _, bins, get_bin) = setup_uniform_binning(n, x)
  let c = Array::make(n, 0)
  let wc = Array::make(n, 0.0)
  for j in 0..<x.length() {
    let i = get_bin(x[j])
    c[i] += 1
    wc[i] += w[j]
  }
  ((bins, c), wc)
}

///|
/// 非均匀分箱设置。移植自 owl_base_stats.ml setup_nonuniform_binning
fn setup_nonuniform_binning(
  bins : Array[Double],
) -> (Int, (Double) -> Int raise) raise {
  let n = bins.length() - 1
  if n < 1 {
    raise @types.OwlError::InvalidArgument("Need at least two bin boundaries!")
  }
  let get_bin = fn(y : Double) -> Int raise {
    let i = bsearch(y, bins)
    if i == n && fcmp(y, bins[n]) == 0 {
      i - 1
    } else {
      i
    }
  }
  (n, get_bin)
}

///|
/// 非均匀分箱直方图。移植自 owl_base_stats.ml hist_nonuniform
pub fn hist_nonuniform(
  bins : Array[Double],
  x : Array[Double],
) -> (Array[Double], Array[Int]) raise {
  let (n, get_bin) = setup_nonuniform_binning(bins)
  let c = Array::make(n, 0)
  for y in x {
    let i = get_bin(y)
    if 0 <= i && i < n {
      c[i] += 1
    }
  }
  (bins, c)
}

///|
/// 加权非均匀分箱直方图。移植自 owl_base_stats.ml hist_weighted_nonuniform
pub fn hist_weighted_nonuniform(
  bins : Array[Double],
  w : Array[Double],
  x : Array[Double],
) -> ((Array[Double], Array[Int]), Array[Double]) raise {
  if x.length() != w.length() {
    raise @types.OwlError::InvalidArgument(
      "Data and weights must have the same length.",
    )
  }
  let (n, get_bin) = setup_nonuniform_binning(bins)
  let c = Array::make(n, 0)
  let wc = Array::make(n, 0.0)
  for j in 0..<x.length() {
    let i = get_bin(x[j])
    if 0 <= i && i < n {
      c[i] += 1
      wc[i] += w[j]
    }
  }
  ((bins, c), wc)
}

///|
/// 从排序数组生成均匀分箱边界。
fn make_uniform_bins_from_sorted(n : Int, x : Array[Double]) -> Array[Double] {
  let (bmin, bmax) = minmax(x)
  let db = (bmax - bmin) / n.to_double()
  let nbins = n + 1
  [
    for i in 0..<nbins => bmin + i.to_double() * db
  ]
}

///|
/// 排序数组直方图。移植自 owl_base_stats.ml hist_sorted
pub fn hist_sorted(
  bins : Array[Double],
  x : Array[Double],
) -> (Array[Double], Array[Int]) raise {
  let n = bins.length() - 1
  if n < 1 {
    raise @types.OwlError::InvalidArgument("Need at least two bin boundaries!")
  }
  let m = x.length()
  let (i0, j0) = if fcmp(bins[0], x[0]) < 1 {
    (bsearch(x[0], bins), 0)
  } else {
    (0, 1 + bsearch(bins[0], x))
  }
  let mut bin_i = i0
  let mut x_j = j0
  let c = Array::make(n, 0)
  while bin_i <= n - 1 {
    while x_j < m && fcmp(x[x_j], bins[bin_i + 1]) < 0 {
      c[bin_i] += 1
      x_j += 1
    }
    bin_i += 1
  }
  while x_j < m && fcmp(x[x_j], bins[n]) == 0 {
    c[n - 1] += 1
    x_j += 1
  }
  (bins, c)
}

///|
/// 加权排序数组直方图。移植自 owl_base_stats.ml hist_weighted_sorted
pub fn hist_weighted_sorted(
  bins : Array[Double],
  w : Array[Double],
  x : Array[Double],
) -> ((Array[Double], Array[Int]), Array[Double]) raise {
  if x.length() != w.length() {
    raise @types.OwlError::InvalidArgument(
      "Data and weights must have the same length.",
    )
  }
  let n = bins.length() - 1
  if n < 1 {
    raise @types.OwlError::InvalidArgument("Need at least two bin boundaries!")
  }
  let m = x.length()
  let (i0, j0) = if fcmp(bins[0], x[0]) < 1 {
    (bsearch(x[0], bins), 0)
  } else {
    (0, 1 + bsearch(bins[0], x))
  }
  let mut bin_i = i0
  let mut x_j = j0
  let c = Array::make(n, 0)
  let wc = Array::make(n, 0.0)
  while bin_i <= n - 1 {
    while x_j < m && fcmp(x[x_j], bins[bin_i + 1]) < 0 {
      c[bin_i] += 1
      wc[bin_i] += w[x_j]
      x_j += 1
    }
    bin_i += 1
  }
  while x_j < m && fcmp(x[x_j], bins[n]) == 0 {
    c[n - 1] += 1
    wc[n - 1] += w[x_j]
    x_j += 1
  }
  ((bins, c), wc)
}

///|
/// 直方图。移植自 owl_base_stats.ml histogram
pub fn histogram(
  bins : BinSpec,
  weights : Array[Double]?,
  x : Array[Double],
) -> Histogram raise {
  match bins {
    BinSpec::N(n) =>
      match weights {
        None => {
          let (b, c) = hist_uniform(n, x)
          {
            bins: b,
            counts: c,
            weighted_counts: None,
            normalised_counts: None,
            density: None,
          }
        }
        Some(w) => {
          let ((b, c), wc) = hist_weighted_uniform(n, w, x)
          {
            bins: b,
            counts: c,
            weighted_counts: Some(wc),
            normalised_counts: None,
            density: None,
          }
        }
      }
    BinSpec::Bins(b) =>
      match weights {
        None => {
          let (bb, c) = hist_nonuniform(b, x)
          {
            bins: bb,
            counts: c,
            weighted_counts: None,
            normalised_counts: None,
            density: None,
          }
        }
        Some(w) => {
          let ((bb, c), wc) = hist_weighted_nonuniform(b, w, x)
          {
            bins: bb,
            counts: c,
            weighted_counts: Some(wc),
            normalised_counts: None,
            density: None,
          }
        }
      }
  }
}

///|
/// 排序数组直方图。移植自 owl_base_stats.ml histogram_sorted
pub fn histogram_sorted(
  bins : BinSpec,
  weights : Array[Double]?,
  x : Array[Double],
) -> Histogram raise {
  let bs = match bins {
    BinSpec::N(n) => make_uniform_bins_from_sorted(n, x)
    BinSpec::Bins(b) => b
  }
  match weights {
    None => {
      let (b, c) = hist_sorted(bs, x)
      {
        bins: b,
        counts: c,
        weighted_counts: None,
        normalised_counts: None,
        density: None,
      }
    }
    Some(w) => {
      let ((b, c), wc) = hist_weighted_sorted(bs, w, x)
      {
        bins: b,
        counts: c,
        weighted_counts: Some(wc),
        normalised_counts: None,
        density: None,
      }
    }
  }
}

///|
/// 归一化计数。移植自 owl_base_stats.ml normalise
pub fn normalise(h : Histogram) -> Histogram {
  let nc = match h.weighted_counts {
    None => {
      let total = h.counts.fold(init=0, fn(acc, c) { acc + c }).to_double()
      [
        for c in h.counts => c.to_double() / total
      ]
    }
    Some(wcounts) => {
      let total = wcounts.fold(init=0.0, fn(acc, wc) { acc + wc })
      [
        for wc in wcounts => wc / total
      ]
    }
  }
  { ..h, normalised_counts: Some(nc) }
}

///|
/// 归一化密度。移植自 owl_base_stats.ml normalise_density
pub fn normalise_density(h : Histogram) -> Histogram {
  let ds = match h.weighted_counts {
    None => {
      let total = h.counts.fold(init=0, fn(acc, c) { acc + c }).to_double()
      [
        for i in 0..<h.counts.length() => {
          h.counts[i].to_double() / (h.bins[i + 1] - h.bins[i]) / total
        }
      ]
    }
    Some(wcounts) => {
      let total = wcounts.fold(init=0.0, fn(acc, wc) { acc + wc })
      [
        for i in 0..<wcounts.length() => {
          wcounts[i] / (h.bins[i + 1] - h.bins[i]) / total
        }
      ]
    }
  }
  { ..h, density: Some(ds) }
}
