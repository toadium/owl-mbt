<div align="center">

# owl-mbt

**Owl 科学计算库的纯 MoonBit 移植**

无 C FFI · 多后端兼容 (Native/Wasm/JS) · 582 测试全通过

[![MoonBit](https://img.shields.io/badge/MoonBit-pure%20implementation-blue)](https://www.moonbitlang.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-582%20passed-brightgreen)]()
[![Coverage](https://img.shields.io/badge/coverage-90.6%25%20(core)-brightgreen)](docs/assessment.md)
[![Mutation](https://img.shields.io/badge/mutation-10%2F10%20KILLED-brightgreen)](scripts/mutation_test.mjs)
[![No C FFI](https://img.shields.io/badge/No%20C%20FFI-pure%20MoonBit-orange)]()
[![mooncakes](https://img.shields.io/badge/mooncakes-walkzzz%2Fowl__mbt-purple)](https://mooncakes.io/docs/walkzzz/owl_mbt)
[![WebAssembly](https://img.shields.io/badge/WebAssembly-WasmGC%20live%20demo-3b82f6)](https://toadium.github.io/owl-mbt/)

</div>

---

## 概述

owl-mbt 是 OCaml 生态最重要的科学计算库 [Owl](https://github.com/owlbarn/owl) 的纯 MoonBit 移植。覆盖 N 维数组、线性代数、自动微分、神经网络、优化算法、统计分布、计算图等核心功能。**14,801 行纯 MoonBit 代码，无 C FFI 依赖，支持 Native/Wasm/JS 三后端。**

> **生态定位**：MoonBit 生态中唯一的科学计算库，与 moonbitstack/moondate（日期时间）、connect0459/almanac（日期时间）属完全不同领域，无功能重叠。

### 在线演示（WebAssembly GC）

**<https://toadium.github.io/owl-mbt/>** — 矩阵点积 / 2×2 行列式、描述统计 + 高斯 KDE、Γ / erf / J₀ 曲线；所有计算都在浏览器内的 **WasmGC 模块** 中实时完成（无服务器、无 CDN）。演示导出层见 `playground/`（`#export_name` + `pkgtype(kind: "foreign_library")`），页面源码见 `docs/`，CI 通过 `pages.yml` 重新构建 wasm 并部署到 GitHub Pages。

### 适用与不适用场景

**适用**：

- MoonBit 项目中的科学计算与数值算法实现（矩阵运算、线性代数、统计分布、特殊函数）
- 机器学习教学与算法实验（自动微分、神经网络前向/反向传播、优化器）
- 需要 wasm/js/native 跨端发布的纯 MoonBit 依赖链（零 C FFI，浏览器与 Node 可直接使用）

**不适用**：

- 高性能生产级数值计算（纯 MoonBit 实现，性能低于原生 BLAS/LAPACK 后端）
- 稀疏矩阵与 GPU 加速场景（未实现稀疏存储与设备计算）
- 需要长期 API 冻结承诺的下游（0.x 开发阶段，见下方版本说明）

### 版本说明（0.x 阶段）

本项目处于 0.x 开发阶段，按 [SemVer](https://semver.org/) 0.x 规则 API 尚未冻结。**0.2.0 是一次性的布局与类型规整版本**（包路径迁移、`Int → Int32`、可选参数 `?→~` 语法），此后次版本升级不再引入同类破坏性变更。从 0.1.1 升级请先阅读 [迁移指南](docs/migration-0.1.1-to-0.2.0.md)。

## 项目信息

| 项目 | 说明 |
|------|------|
| 原项目 | [Owl](https://github.com/owlbarn/owl)（OCaml 科学计算库） |
| 原项目许可证 | LGPL-2.1+ |
| 移植范围 | `owl-base` 包（纯 OCaml，34,326 行），不含 C 绑定层 |
| 本项目许可证 | MIT（详见 [LICENSE](LICENSE)） |
| 代码规模 | 14,801 行 MoonBit 代码，79 个源文件 |
| 测试 | 582 个，全部通过（四后端） |
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
maths → stats → ndarray → ┬→ linalg ──→ compute
                           ├→ algodiff → ┬→ optimise
                           │             └→ neural
                           └→ misc
```

## 模块概览

| 包 | 功能 | 核心内容 |
|---|------|---------|
| `@core` | 类型与常量 | Number/Index/Padding 枚举 + OwlError + 17 个数学常量 |
| `@maths` | 数学函数 | 基础运算 + erf/erfc + sigmoid + signum + 数论（素数/模运算） |
| `@stats` | 统计分布 | PRNG + 5 种分布采样 + 描述性统计 + 直方图 + KDE |
| `@ndarray` | N 维数组 | strided Ndarray + 创建/切片/运算/广播/规约 + 卷积/池化 |
| `@linalg` | 线性代数 | LU/Cholesky/QR/SVD 分解 + inv/det/logdet/rank/trace + 三对角求解 |
| `@algodiff` | 自动微分 | 前向+反向模式 + diff/grad/jacobian/hessian API |
| `@optimise` | 优化算法 | 梯度下降 + 动量法 + 正则化 + 学习率调度 + 梯度裁剪 + 早停 |
| `@neural` | 神经网络 | 10 种层类型（含 inverted Dropout）+ forward/backward + Neuron 图 |
| `@compute` | 计算图 | 120+ Op 全求值（卷积/池化/标量/裁剪/索引）+ DAG + 拓扑排序 + 形状推断 |
| `@misc` | 辅助工具 | 彩色 Logger + Stack[T] + Heap[T] + CountMinSketch + DataFrame |

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
moon test    # 运行测试（582 个）
moon fmt     # 格式化
moon info    # 生成接口
```

## 修改与适配

相对原项目 owl-base 的主要修改：

1. **Bigarray → 自实现 Ndarray** — 自行实现 strided N 维数组，替代 OCaml Bigarray.Genarray
2. **sigmoid bug 修复** — 原项目 `log(-x)` 疑似 bug，已修复为标准 `1/(1+exp(-x))`
3. **linalg 自实现扩展** — 原项目仅 inv/det/lu，本项目自行实现 Cholesky 分解、QR 分解（Householder）、SVD（单边 Jacobi）、logdet、rank
4. **纯后端实现** — 移除所有 C FFI 依赖，支持 Native/Wasm/JS 三后端
5. **错误处理** — OCaml 异常 → MoonBit checked errors（suberror + raise）
6. **可变状态** — OCaml `ref` → MoonBit `Ref[T]`
7. **原项目未实现项自行实现** — dawsn（原 NOT_IMPLEMENTED 占位）、SVD、FFT（radix-2，一维 2 的幂）、gamma/beta/J0/J1（原在 Cephes C 层，超出纯移植范围）

## 尚未移植的功能

- Y0/Y1 第二类贝塞尔函数（原项目在 Cephes C 层；gamma/beta/J0/J1/dawsn 已以纯 MoonBit 实现，见 `maths/gamma.mbt`、`maths/bessel.mbt`）
- 完整 BLAS/LAPACK 接口
- 稀疏矩阵
- Plotting

## 代码审查

经过 6 轮代码审查（141 个问题）：P0-P1 严重项全部修复；P2-P4 共 78 项中 28 项已修复，其余项以文档标注行为或记录为已知限制（详见 `reviews/` 目录）。2026-11 迭代补齐了 ndarray 边界校验、`col_min`/`col_max` 空列、`slicing` step==0 等静默错误风险项，并完成 compute 计算图全 op 求值、Dropout/梯度裁剪/早停实现、LU 分解去重与测试盲区补齐。

## FAQ 与踩坑指南

**Q1：从 0.1.1 升级后编译报包找不到 / `@types` 未定义？**
0.2.0 重构了包布局（`src/` 前缀移除、`@types`+`@const` 合并为 `@core`），按[迁移指南](docs/migration-0.1.1-to-0.2.0.md)的映射表更新 `moon.pkg` 的 import 路径。

**Q2：调用 ndarray 函数报参数类型不匹配（`Int` vs `Int32`）？**
0.2.0 将索引/形状参数统一为 `Int32`。整数字面量（`1`、`0`）按上下文自动重载无需改动，仅需修正显式类型注解；MoonBit 中 `Int` 即 `Int32`。

**Q3：可选参数传参语法报错？**
MoonBit 新语法为 `f(x~1)`（`~` 后直接跟值），旧写法 `f(x=1)` 已弃用。受影响函数清单见迁移指南第三节。

**Q4：在包内添加警告抑制的正确方式？**
`moon.pkg` 中使用 assign 语句 `warnings = "-79"`（`warn-list` 是旧 JSON 格式字段名，在新格式中会导致词法错误）。诊断编号可用 `moon explain --diagnostic 79` 查询含义。

**Q5：为什么某些函数新增了 `raise` 声明？**
0.2.0 为 ndarray 补齐了边界校验（axis 越界、形状不一致、非法步长等），这些函数从静默接受非法输入改为显式抛出 `OwlError::InvalidArgument`。若你的调用点在 `noraise` 上下文，需补 `catch` 处理。

**Q6：`derive` 写在哪里？**
使用新语法 `#derive(Debug)` 独立一行放在类型声明之前；旧式尾部 `} derive(Debug)` 已弃用。

- 测试覆盖率：核心逻辑 **90.6%（4516/4982，排除 bench/examples）**，由 `node scripts/check_coverage.mjs` 实测（门槛 90%）；历史文档中的 97.7% 为旧口径，已废弃
- 变异测试：`node scripts/mutation_test.mjs` 10/10 KILLED（kde/erf/bessel/special/countmin/matrix 关键分支）

## 维护与反馈

- **维护者**：walkzzz
- **问题反馈**：[GitHub Issues](https://github.com/toadium/owl-mbt/issues)（附最小复现 + moon 版本 + 后端）
- **响应时效承诺**：Bug 报告 48 小时内响应；安全漏洞 72 小时内评估并给出修复计划；高危问题在一个补丁版本内修复
- **贡献**：欢迎 PR，流程与质量门禁见 [CONTRIBUTING.md](CONTRIBUTING.md)；公开契约变化通过 `pkg.generated.mbti` 接口快照在 CI 中自动校验（mbti diff 未记录于 CHANGELOG 则阻断合并）
- **性能数据**：核心操作基准（wasm/native 两口径）见 [docs/benchmark.md](docs/benchmark.md)，基准工具为 `bench/` 可执行包（`moon run bench --release`）
- **发布节奏**：功能以次版本发布，修复以补丁版本发布；版本随 mooncakes.io 发布并打 git tag

## 许可证

本项目采用 [MIT 许可证](LICENSE)。原项目 Owl 采用 LGPL-2.1+ 许可证，版权声明已在 LICENSE 中保留。
