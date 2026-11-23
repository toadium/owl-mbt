# maths

标量数学：基础函数、特殊函数（gamma / erf / Bessel）与数论工具。

[← 返回总览](../README.md)

## 安装

```bash
moon add walkzzz/owl_mbt@0.3.1
```

```moonbit
// moon.pkg
import {
  "walkzzz/owl_mbt/maths" as @maths
}
```

## 主要接口

| 接口 | 说明 |
|---|---|
| `exp` / `log` / `sqrt` / `pow` | 基础函数 |
| `sin` / `cos` / `tan` 及反函数、双曲函数 | 三角函数族 |
| `gamma(x)` | Gamma 函数 |
| `erf(x)` / `erfc(x)` | 误差函数及其补函数 |
| `j0(x)` / `j1(x)` / `jn(n, x)` | 第一类 Bessel 函数 |
| `is_nan` / `is_inf` / `approx_equal` | 数值判定 |

## 示例

```moonbit
let g = @maths.gamma(5.0)      // 24.0
let e = @maths.erf(1.0)        // 0.8427007929…
let b = @maths.j0(2.0)         // 0.2238907791…
let s = @maths.sqrt(2.0)
```

## 行为说明

- 全部为纯 MoonBit 实现，不依赖 libm / C FFI。
- 特殊函数实现与验证口径见 `docs/benchmark.md`，页面 wasm 演示也直接调用这些实现。
- 定义域外的输入返回 `NaN` 或抛 `OwlError`（以具体函数为准）。

## 相关

- [接口契约](./pkg.generated.mbti)
- [统计模块](../stats/README.md)
- [基准报告](../docs/benchmark.md)