# owl-mbt 项目申报书

> 2026 MoonBit 国产基础软件开源大赛参赛申报 | 方向：科学计算 | 申报日期：2026-11-10

---

## 基本信息

- 项目名称：owl-mbt — Owl 科学计算库的纯 MoonBit 移植
- 参赛者：蒋本雄
- 联系方式：13689047817 745244185@qq.com
- GitHub 仓库链接：https://github.com/toadium/owl-mbt.git
- mooncakes 包名：`walkzzz/owl_mbt`
- 项目方向：科学计算 — Ndarray/线性代数/自动微分/神经网络
- 是否为移植项目：是（从 OCaml Owl 库 `owl-base` 包移植）

---

## 项目简介

owl-mbt 是 OCaml 生态最重要的科学计算库 [Owl](https://github.com/owlbarn/owl) 的纯 MoonBit 移植，覆盖 N 维数组、线性代数、自动微分、神经网络、优化算法、统计分布、计算图等核心功能。14,801 行纯 MoonBit 代码，无 C FFI 依赖，支持 Native/Wasm/JS 三后端。

mooncakes 生态调研确认：截至 2026-11-10，**MoonBit 生态无任何科学计算库**（Ndarray + 线性代数 + 自动微分 + 神经网络），本项目填补该空白。与 moonbitstack/moondate（日期时间库）、connect0459/almanac（日期时间库）属**完全不同领域，无功能重叠**。

---

## 当前完成状态（v0.1.1）

| 指标 | 数值 |
|------|------|
| 源文件数 | **79** 个 .mbt 文件 |
| 代码行数 | **14,801** 行纯 MoonBit |
| 测试数 | **497**（全部通过） |
| Warnings | **0** |
| Errors | **0** |
| 模块数 | **10**（types/const/maths/stats/ndarray/linalg/algodiff/optimise/neural/compute/misc） |
| 可运行示例 | **3**（ndarray_demo/neural_demo/stats_demo） |
| 代码审查 | 6 轮，141 个问题全部修复 |
| CI | ✅ GitHub Actions（moon check + moon test + moon fmt check） |
| mooncakes 发布 | ✅ `walkzzz/owl_mbt v0.1.1` |

---

## 技术方案

### 模块依赖拓扑

```
types + const（零依赖核心类型与常量）
      ↑
  maths（基础+特殊数学函数）
      ↑
  stats（统计与概率分布）
      ↑
  ndarray（自实现 strided N 维数组 — 最大技术难点）
      ↑
  ┌───┴───┬──────────┬──────────┐
  linalg  algodiff   compute    misc
  (LU/Chol/QR)  (前向+反向)  (DAG)   (DataFrame/Heap)
      ↑       ↑
  optimise  neural
  (梯度下降)  (10层网络)
```

### 关键技术决策

1. **自实现 strided Ndarray** — OCaml Bigarray 在 MoonBit 无对应物，自行实现 strided N 维数组数据结构，是整个移植最大障碍
2. **纯 MoonBit 无 C FFI** — 所有数学运算纯实现，天然支持 Native/Wasm/JS 三后端
3. **原项目 bug 修复** — sigmoid 实现 `log(-x)` 疑似 bug，已修复为标准 `1/(1+exp(-x))`
4. **自实现扩展** — 原项目 linalg 仅 inv/det/lu，本项目自行实现 Cholesky 分解、QR 分解（Householder）、logdet、rank
5. **错误处理适配** — OCaml 异常 → MoonBit checked errors（suberror + raise）

### 类型映射

| MoonBit | 说明 | OCaml 原型 |
|---------|------|-----------|
| `Ndarray[T]` | 自实现 strided N 维数组 | `Bigarray.Genarray` |
| `OwlError` | checked error + suberror | `Owl_exception` |
| `Ref[T]` | 可变状态 | `ref` |
| `T`（algodiff） | 自动微分类型 | `Algodiff.D.T` |
| `Op`（compute） | 120+ 变体计算图操作 | `Compute.Op` |

---

## 项目架构（重构后扁平多根包布局）

```
owl-mbt/
├── moon.mod / moon.pkg          # 根包（文档入口 + 便捷函数）
├── owl_mbt.mbt                  #   根包文档 + 便捷 API
├── core/                        # 零依赖核心（types + const 合并）
│   ├── types.mbt                #   类型定义 + OwlError suberror
│   └── const.mbt                #   17 个数学常量
├── maths/                       # 基础+特殊数学函数
├── stats/                       # 统计与概率分布
├── ndarray/                     # N 维数组核心（最大模块）
├── linalg/                      # 线性代数（LU/Chol/QR/inv/det）
├── algodiff/                    # 自动微分（前向+反向模式）
├── optimise/                    # 优化算法
├── neural/                      # 神经网络层
├── compute/                     # 计算图 DAG
├── misc/                        # 辅助工具（DataFrame/Heap/Stack）
├── cmd/
│   └── main/                    # 可执行入口
├── docs/                        # 开发文档
└── examples/                    # 可运行示例
```

线性无环依赖，core 零依赖可独立复用。源码直接放在根级目录下，不使用 `src/` 子目录。

---

## 核心功能范围

| 模块 | 核心功能 | 原项目对应 |
|------|---------|-----------|
| **core** | Number/Index/Padding 枚举 + OwlError + 17 个数学常量 | owl_types_common + owl_const |
| **maths** | 基础函数 + erf/erfc + 特殊函数 + 数论 | owl_maths |
| **stats** | PRNG + 5 种分布采样 + 描述性统计 + 直方图 + KDE | owl_stats |
| **ndarray** | strided N 维数组 + 创建/切片/运算/规约 + 卷积/池化 | owl_ndarray |
| **linalg** | LU/Cholesky/QR 分解 + inv/det/rank/trace + 三对角求解 | owl_linalg |
| **algodiff** | 前向+反向模式 + SISO/PISO 操作 + diff/grad/jacobian/hessian | owl_algodiff |
| **optimise** | 梯度下降 + 动量法 + 正则化 + 学习率调度 + 停止条件 | owl_optimise |
| **neural** | 10 种层（Input/Linear/Activation/Flatten/Reshape/Dropout/Add/Concatenate/Lambda） | owl_neural |
| **compute** | 120+ Op 变体 + DAG 图 + 拓扑排序 + 形状推断 + eval | owl_compute |
| **misc** | Logger + Stack[T] + Heap[T] + CountMinSketch + DataFrame | owl_misc |

---

## mooncakes.io 生态对比

mooncakes.io 上无任何科学计算库提供 Ndarray + 线性代数 + 自动微分 + 神经网络功能。本项目是唯一填补此空白的项目。

| 库 | 领域 | 与本项目关系 |
|---|---|---|
| **walkzzz/owl_mbt**（本项目） | 科学计算 | — |
| moonbitstack/moondate | 日期时间 | 无重叠，完全不同领域 |
| connect0459/almanac | 日期时间 | 无重叠，完全不同领域 |

---

## 验收标准对齐

| 大赛验收项 | 本项目满足方式 |
|-----------|-------------|
| MoonBit 为主 | 14,801 行 100% 纯 MoonBit，无 C/其他语言源文件 |
| 仓库公开 | GitHub 公开仓库，持续提交 |
| 能够运行 | 3 个可运行示例 + 497 测试 + 0 warnings |
| 工作有效 | 从 OCaml 移植到 MoonBit，独立重写，6 轮审查 |
| 开源合规 | MIT License，原项目 LGPL-2.1+ 归属已标注 |
| AI 可解释 | AI 辅助开发，所有算法经人工审查 |

---

## 原项目信息

- **原项目名称**：Owl
- **原项目链接**：https://github.com/owlbarn/owl
- **原项目许可证**：LGPL-2.1+
- **移植范围**：`owl-base` 包（纯 OCaml，34,326 行），不含 C FFI 绑定层
- **未移植功能**：SVD、高级特殊函数（gamma/beta/bessel）、完整 BLAS/LAPACK 接口、稀疏矩阵、FFT、Plotting（详见 README.md）

---

## 对 MoonBit 生态的价值

1. **填补科学计算空白** — MoonBit 生态目前无科学计算库，本项目提供 Ndarray/线性代数/自动微分/神经网络等核心功能
2. **验证 MoonBit 能力** — 14,801 行纯 MoonBit 代码证明该语言处理复杂数值计算的能力
3. **多后端兼容** — 纯实现支持 Native/Wasm/JS，无需平台特定优化
4. **可扩展基础** — 为后续 ML/科学计算生态提供基础构件