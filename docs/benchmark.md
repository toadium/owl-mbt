# owl-mbt 性能基准

## 方法

- 基准实现：`bench/main.mbt`（可执行包），计时源 `@async.now()`（毫秒精度，来自 core 内置 async）
- 每组操作先热身 10% 迭代，再计时正式迭代；结果为**单次平均微秒**（us/iter，保留 3 位小数）
- 数值函数（gamma/j0/diff）从参数数组按迭代索引取输入，**防止编译器常量折叠**（实测：常量参数下 j0 被折叠至 0.01us/iter，修正后恢复真实 0.12-0.18us/iter）
- PRNG 数据由运行时生成（`@ndarray.gaussian`），矩阵/信号数据运行时构造

## 环境

- 工具链：moon 0.1.20261104（940aa18 2026-11-04）
- 平台：Windows 11 Pro x64（开发机实测，单次运行均值，未做多次取中位数）
- 口径：`--release` 优化构建

## 结果（0.2.0，2026-11-16）

| 操作 | 迭代数 | wasm release (us/iter) | native release (us/iter) |
|---|---:|---:|---:|
| `ndarray.zeros[100x100]` | 2000 | 2 | 2 |
| `ndarray.add[128x128]` | 1000 | 42 | 29 |
| `ndarray.dot[64x64]` | 200 | 465 | 360 |
| `ndarray.fft[256]` | 500 | 16 | 8 |
| `ndarray.fft[1024]` | 100 | 50 | 40 |
| `ndarray.ifft[256]` round-trip | 250 | 20 | 12 |
| `maths.gamma` | 200000 | 0.455 | 0.395 |
| `maths.j0` | 100000 | 0.18 | 0.12 |
| `linalg.inv[32x32]` | 100 | 140 | 100 |
| `linalg.svd[16x16]` | 30 | 66.667 | 66.667 |
| `algodiff.diff sin(exp(x))` | 10000 | 0.6 | 0.9 |
| `ndarray.gaussian[1000]`（PRNG 采样） | 500 | 96 | 88 |
| `stats.prng_init` | 50000 | 0.9 | 0.8 |

## 解读

- **数值函数**：gamma（Lanczos）/j0（幂级数+渐近）单次调用亚微秒级，适合高频调用场景
- **矩阵运算**：纯 MoonBit 无 BLAS，64×64 矩阵乘约 360-465us——与原生 BLAS 有数量级差距，适合中小规模与教学/原型场景（与 README"不适用场景"声明一致）
- **FFT**：256 点 8-16us、1024 点 40-50us（radix-2 迭代实现）
- **AD**：反向模式单变量微分约 0.6-0.9us/次
- **后端差异**：native 总体比 wasm 快 10-40%（矩阵/卷积类明显），标量函数接近

## 复现

```sh
moon run bench --release                    # wasm release 口径
moon run bench --target native --release    # native release 口径
```

迭代数可在 `bench/main.mbt` 中调整；总时长约 1 秒/口径。

## 已知限制

- 单次运行均值，未做多次运行取中位数与置信区间
- 计时精度毫秒（`@async.now()`），小于 1ms 的操作依赖大迭代数摊薄
- 未覆盖：stats 分布采样逐函数、KDE、模糊匹配、Viterbi 消歧（后续版本补充）
