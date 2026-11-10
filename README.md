<div align="center">

# owl-mbt

**Owl 科学计算库的纯 MoonBit 移植**

无 C FFI · 多后端兼容 (Native/Wasm/JS) · 497 测试全通过

[![MoonBit](https://img.shields.io/badge/MoonBit-pure%20implementation-blue)](https://www.moonbitlang.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-497%20passed-brightgreen)]()
[![No C FFI](https://img.shields.io/badge/No%20C%20FFI-pure%20MoonBit-orange)]()
[![mooncakes](https://img.shields.io/badge/mooncakes-walkzzz%2Fowl__mbt-purple)](https://mooncakes.io/docs/walkzzz/owl_mbt)

</div>

---

## 概述

owl-mbt 是 OCaml 生态最重要的科学计算库 [Owl](https://github.com/owlbarn/owl) 的纯 MoonBit 移植。覆盖 N 维数组、线性代数、自动微分、神经网络、优化算法、统计分布、计算图等核心功能。**14,801 行纯 MoonBit 代码，无 C FFI 依赖，支持 Native/Wasm/JS 三后端。**

> **生态定位**：MoonBit 生态中唯一的科学计算库，与 moonbitstack/moondate（日期时间）、connect0459/almanac（日期时间）属完全不同领域，无功能重叠。

## 项目信息

| 项目 | 说明 |
|------|------|
| 原项目 | [Owl](https://github.com/owlbarn/owl)（OCaml 科学计算库） |
| 原项目许可证 | LGPL-2.1+ |
| 移植范围 | `owl-base` 包（纯 OCaml，34,326 行），不含 C 绑定层 |
| 本项目许可证 | MIT（详见 [LICENSE](LICENSE)） |
| 代码规模 | 14,801 行 MoonBit 代码，79 个源文件 |
| 测试 | 497 个，全部通过 |
| mooncakes | `walkzzz/owl_mbt` |

## 包结构

扁平多根包布局，源码直接放在根级目录下：

```
owl-mbt/
├── core/          # 零依赖核心（types + const 合并）
├── maths/         # 基础+特殊数学函数
├── stats/         # 统计与概率分布
├── ndarray/       # N 维数组核心（最大模块）
├── linalg/        # 线性代数
├── algodiff/      # 自动微分
├── optimise/      # 优化算法
├── neural/        # 神经网络层
├── compute/       # 计算图 DAG
├── misc/          # 辅助工具
├── examples/      # 可运行示例
├── owl_mbt.mbt    # 根包入口
└── docs/          # 开发文档
```

**依赖拓扑**（线性无环）：

```
core（零依赖）
  ↑
maths → stats → ndarray → ┬→ linalg
                           ├→ algodiff → ┬→ optimise
                           │             └→ neural
                           ├→ compute
                           └→ misc
```

## 模块概览

| 包 | 功能 | 核心内容 |
|---|------|---------|
| `@core` | 类型与常量 | Number/Index/Padding 枚举 + OwlError + 17 个数学常量 |
| `@maths` | 数学函数 | 基础运算 + erf/erfc + sigmoid + signum + 数论（素数/模运算） |
| `@stats` | 统计分布 | PRNG + 5 种分布采样 + 描述性统计 + 直方图 + KDE |
| `@ndarray` | N 维数组 | strided Ndarray + 创建/切片/运算/广播/规约 + 卷积/池化 |
| `@linalg` | 线性代数 | LU/Cholesky/QR 分解 + inv/det/rank/trace + 三对角求解 |
| `@algodiff` | 自动微分 | 前向+反向模式 + diff/grad/jacobian/hessian API |
| `@optimise` | 优化算法 | 梯度下降 + 动量法 + 正则化 + 学习率调度 |
| `@neural` | 神经网络 | 10 种层类型 + forward/backward + Neuron 图 |
| `@compute` | 计算图 | 120+ Op 变体 + DAG + 拓扑排序 + 形状推断 |
| `@misc` | 辅助工具 | Logger + Stack[T] + Heap[T] + CountMinSketch + DataFrame |

## 快速开始

```sh
moon add walkzzz/owl_mbt
```

```moonbit
// 创建 N 维数组
let arr = @ndarray.arange(0.0, 10.0, 1.0)

// 矩阵运算
let mat = @ndarray.zeros([3, 3])
let inv_mat = @linalg.inv(mat)

// 自动微分
let f = fn(x : @algodiff.T) -> @algodiff.T raise { @algodiff.sin(x) }
let d = @algodiff.diff(f, @algodiff.pack_flt(0.0))
```

## 示例

```sh
moon run examples/ndarray_demo   # Ndarray 基本操作
moon run examples/neural_demo    # 神经网络前向/反向传播
moon run examples/stats_demo     # 统计与分布采样
```

## 构建

```sh
moon check   # 类型检查
moon test    # 运行测试（497 个）
moon fmt     # 格式化
moon info    # 生成接口
```

## 修改与适配

相对原项目 owl-base 的主要修改：

1. **Bigarray → 自实现 Ndarray** — 自行实现 strided N 维数组，替代 OCaml Bigarray.Genarray
2. **sigmoid bug 修复** — 原项目 `log(-x)` 疑似 bug，已修复为标准 `1/(1+exp(-x))`
3. **linalg 自实现扩展** — 原项目仅 inv/det/lu，本项目自行实现 Cholesky 分解、QR 分解（Householder）、logdet、rank
4. **纯后端实现** — 移除所有 C FFI 依赖，支持 Native/Wasm/JS 三后端
5. **错误处理** — OCaml 异常 → MoonBit checked errors（suberror + raise）
6. **可变状态** — OCaml `ref` → MoonBit `Ref[T]`

## 尚未移植的功能

- SVD 分解（原项目也为 `NOT_IMPLEMENTED`）
- 高级特殊函数（gamma/beta/bessel，在 Cephes C 层）
- 完整 BLAS/LAPACK 接口
- 稀疏矩阵
- FFT
- Plotting

## 代码审查

经过 6 轮代码审查（141 个问题），全部 P0-P4 修复完成。审查报告位于 `reviews/` 目录。

## 许可证

本项目采用 [MIT 许可证](LICENSE)。原项目 Owl 采用 LGPL-2.1+ 许可证，版权声明已在 LICENSE 中保留。
