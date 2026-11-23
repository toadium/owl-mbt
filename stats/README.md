# stats

统计与概率：描述统计、分布采样、PRNG、KDE、直方图与顺序统计。

[← 返回总览](../README.md)

## 安装

```bash
moon add walkzzz/owl_mbt@0.3.1
```

```moonbit
// moon.pkg
import {
  "walkzzz/owl_mbt/stats" as @stats
}
```

## 主要接口

| 接口 | 说明 |
|---|---|
| `mean(xs)` / `variance(mean?, xs)` / `std(mean?, xs)` | 描述统计 |
| `min` / `max` / `sum` / `median` / `quantile` | 汇总与顺序统计 |
| `absdev` / `central_moment` / `cov` / `corr` | 离散度与相关性 |
| `prng_init(seed)` | 初始化伪随机数生成器 |
| `gaussian_rvs(mu, sigma)` 等 | 正态 / 指数 / 伯努利 / 柯西采样 |
| `gaussian_kde(xs, bandwidth?)` | 高斯核密度估计 |
| `histogram` / `hist_uniform` / `hist_sorted` | 直方图 |

## 示例

```moonbit
@stats.prng_init(42)

let xs = []
for _ in 0..<100 {
  xs.push(@stats.gaussian_rvs(0.0, 1.0))
}

let m = @stats.mean(xs)
let v = @stats.variance(None, xs)
let s = @stats.std(None, xs)
```

KDE：

```moonbit
let (points, density) = @stats.gaussian_kde([1.0, 2.0, 3.0, 5.0])
```

## 行为说明

- 统计函数接受 `Array[Double]`，`mean` 可选传入已知均值以复用。
- `gaussian_kde` 默认 Scott 带宽；常量数据可能触发带宽为 0 的错误。
- PRNG 为确定性实现，同一 seed 跨后端结果一致。

## 相关

- [接口契约](./pkg.generated.mbti)
- [特殊函数](../maths/README.md)
- [代码示例](../examples/stats_demo/main.mbt)