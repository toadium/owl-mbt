# Owl → MoonBit 迁移规划

> 源：`D:\CodeWorkspace\forOcaml\owl` 的 `owl-base` 包（纯 OCaml，34,326 行）
> 目标：`owl-mbt` — Owl 的纯 MoonBit 移植，无 C FFI，多后端兼容（Native/Wasm/JS）
> 生成：2026-08-09，基于 `ocaml2moonbit-migration` skill

## 1. 源选择与边界

### 为什么以 `owl-base` 为源

Owl 分三层包：

| 包 | C 依赖 | 行数 | 选为源？ |
|---|:---:|---:|:---:|
| `owl-base` | 否（但用 OCaml `Bigarray`） | 34,326 | ✅ |
| `owl` | 是（OpenBLAS/LAPACK/CBLAS/FFTPACK） | +更多 | ❌ |
| `owl-top` | 否 | 少量 | 后期 |

用户偏好明确：**纯后端实现、无 C FFI、全后端支持**。`owl-base` 是唯一符合的源。其 Ndarray 虽基于 OCaml 标准库 `Bigarray.Genarray`，但无外部 C 库，可移植。

### owl-base 模块规模与依赖

| 模块 | 文件数 | 行数 | 依赖 | 移植难度 |
|---|---:|---:|---|:---:|
| `types` | 14 | 972 | 无（签名） | 低 |
| `core` | 11 | 2,865 | types | 中 |
| `maths` | 10 | 1,664 | core/const | **低** |
| `stats` | 11 | 763 | maths | **低** |
| `dense` | 20 | 6,762 | core, maths, **Bigarray** | **高** |
| `linalg` | 11 | 656 | dense | 中 |
| `algodiff` | 23 | 3,803 | dense, maths, types | **高** |
| `optimise` | 4 | 1,140 | algodiff | 中 |
| `neural` | 6 | 6,183 | algodiff, dense | **高** |
| `compute` | 19 | 5,430 | dense, types | **高** |
| `misc` | 27 | 4,068 | 多模块 | 中 |
| **合计** | **146** | **34,326** | | |

### 依赖图（移植顺序据此）

```
types ──► core ──► maths ──► stats
              │       │
              ▼       ▼
            dense ◄───┘
              │
      ┌───────┼───────┐
      ▼       ▼       ▼
   linalg  algodiff  compute
              │
      ┌───────┴───────┐
      ▼               ▼
  optimise         neural
      │               │
      └───────┬───────┘
              ▼
            misc
              ▼
          顶层 Owl
```

## 2. 关键技术决策

### 2.1 Ndarray 表示（最核心决策）

**问题**：OCaml `Bigarray.Genarray.t` 是多维、C layout、零拷贝、GC 外的大数组。MoonBit 无对应物。

**决策**：自行实现 **strided n-d array**：

```moonbit
struct Ndarray {
  shape : Array[Int]        // 各维大小，如 [2, 3, 4]
  strides : Array[Int]      // 行优先步长，如 [12, 4, 1]
  offset : Int              // 起始偏移（支持切片视图）
  data : FixedArray[Double] // 连续存储，row-major
}
```

**理由**：
- `FixedArray[Double]` 对应 OCaml `float array` / Bigarray 的连续存储
- 显式 `strides` + `offset` 支持切片视图（零拷贝），对齐 Owl 的 slicing 语义
- row-major（C layout）与 Owl 一致
- 纯 MoonBit，三后端通用

**切片视图 vs 拷贝**：Owl 的 `get_slice` 返回新数组。移植先做**拷贝语义**（简单正确），后续优化为视图（引入 `is_view` 标志或 Cow）。

**精度分型**：先只做 **F64**（`Double`，对应 Owl 默认 `D` / `Owl.Arr`）。用 trait 抽象元素类型，后续扩展 F32/C32/C64：

```moonbit
trait Elt {
  zero() -> Self
  one() -> Self
  add(Self, Self) -> Self
  // ...
}
```

### 2.2 Bigarray kind 多态

**问题**：`owl_const.ml` 用 `(a, b) Bigarray.kind -> a` 按 kind 分发 zero/one。

**决策**：MoonBit 用 trait + 泛型，或直接为 `Double` 实现。F64 优先阶段不需要多 kind 分发。

### 2.3 Functor 化设计

**问题**：Owl 普遍用 functor（`Owl_algodiff_generic.Make(Primal_ops.D)`）。

**决策**：MoonBit 无 functor。用 **trait + 泛型函数** 替代。核心算子写成对 `Elt` trait 的泛型，按精度实例化为具体模块。若 trait 表达力不足，F64 优先手写，后续用代码生成或宏扩展 S/C/Z。

### 2.4 错误处理

**问题**：OCaml 用 `Invalid_argument`/`Not_found`/`Failure` 等异常。

**决策**：定义项目级 `suberror OwlError`，fallible 函数声明 `raise OwlError`。`main` 与 test 用 `fn main raise`。不复制 unchecked 异常流。

```moonbit
suberror OwlError
```

### 2.5 字符串/字节分类

**问题**：OCaml `string` 是字节序列，MoonBit `String` 是 UTF-16。

**决策**：Owl 是数值库，**几乎无字符串**。仅有 `print`/`to_string` 等诊断函数。分类：
- 数值格式化输出 → `String`（人类可读，UTF-8/ASCII 数值）
- 无二进制格式、无文件 IO 在 owl-base 范围内
- **结论**：byte/string 风险极低，`print` 系列直接用 `String` + `Double::to_string`

### 2.6 可选参数

**问题**：OCaml `?a:elt -> ?step:elt -> int array -> arr`。

**决策**：MoonBit labelled + default：`fn sequential(shape : ArrayView[Int], a? : Double = 0.0, step? : Double = 1.0) -> Ndarray`。

### 2.7 多后端

**决策**：纯 MoonBit，`moon.pkg` 不限 target，自动支持 Native/Wasm/JS。无 `#cfg(target=...)` 需求（owl-base 无平台依赖）。性能对标 C 由 MoonBit Native 后端保证。

## 3. MoonBit 包边界设计

```
owl-mbt/                          # moon.mod.json: module owl_mbt
├── src/
│   ├── types/                    # 共享类型与签名（trait 定义）
│   │   └── moon.pkg.json
│   ├── const/                    # 数学常量（owl_const.ml）
│   │   └── moon.pkg.json
│   ├── maths/                    # 基础+特殊数学函数
│   │   └── moon.pkg.json         # import: const
│   ├── stats/                    # 统计与分布
│   │   └── moon.pkg.json         # import: maths
│   ├── ndarray/                  # Ndarray 核心（strided 实现）
│   │   └── moon.pkg.json         # import: maths, const
│   ├── matrix/                   # 稠密矩阵（基于 ndarray）
│   │   └── moon.pkg.json         # import: ndarray
│   ├── linalg/                   # 纯 MoonBit 线性代数
│   │   └── moon.pkg.json         # import: matrix, ndarray
│   ├── algodiff/                 # 算法微分
│   │   └── moon.pkg.json         # import: ndarray, maths
│   ├── optimise/                 # 优化与回归
│   │   └── moon.pkg.json         # import: algodiff
│   ├── neural/                   # 神经网络
│   │   └── moon.pkg.json         # import: algodiff, ndarray
│   ├── compute/                  # 计算图引擎
│   │   └── moon.pkg.json         # import: ndarray, types
│   ├── misc/                     # 聚类、数据集、sketch 等
│   │   └── moon.pkg.json
│   └── owl/                      # 顶层聚合（Owl.Arr / Owl.Mat 别名）
│       └── moon.pkg.json         # import: 全部
└── test/
    └── ...                       # 各包对应测试
```

**命名**：`owl_mbt`（MoonBit 模块名下划线，kebab-case 仓库名 `owl-mbt`）。包名用 MoonBit 惯例短名（`maths`、`ndarray`）。

## 4. 分阶段路线图

每阶段遵循 `ocaml2moonbit-migration` skill 的切片循环：**端口 → 测试 → `moon check` → `moon test` → `moon info` → `moon fmt`**。

### 阶段 0：脚手架（前置）

- `moon.mod.json`、`src/types/`、`src/const/`
- `suberror OwlError`
- `trait Elt`（元素类型抽象）
- 基础类型：`number` enum（F32/F64/C32/C64）、`index`/`slice`/`padding` enum
- 验收：`moon check` 通过，空 `moon test` 通过

### 阶段 1：maths（1,664 行，最易，无 Bigarray）

**源**：`src/base/maths/`（`owl_base_maths.ml/mli`、`owl_base_complex.ml`、`owl_maths_interpolate.ml`、`owl_maths_quadrature.ml`、`owl_maths_root.ml`）

**范围确认**：owl-base/maths **不含** `gamma`/`beta`/`bessel`/`digamma`/`legendre`/`ellip` 等高级特殊函数（它们在 `owl` 包的 Cephes C 层，超出纯移植范围）。owl-base/maths 仅含：基础函数 + `erf`/`erfc`/`erfcx`（纯 OCaml 实现，无 `external`）+ `sigmoid`/`softplus` + 插值/求积/求根。

**切片**：
1. 基础函数（add/sub/mul/div/sqrt/exp/log/pow/sin/cos/...）→ 多数直接映射 `@math` + `Double` 方法
2. `erf`/`erfc`/`erfcx`（纯 OCaml 实现，直接移植数值算法）
3. `sigmoid`/`softplus`/`round`/`signum` 等
4. `Owl_base_complex`（复数运算）
5. 插值（`owl_maths_interpolate`）、求积（`owl_maths_quadrature`，含 `gauss_legendre`）、求根（`owl_maths_root`）

**测试**：对每个函数与 OCaml 参考值对比（golden values），覆盖边界（0、负、inf、nan）。

**验收**：`moon test` 全过，`erf` 等相对误差 < 1e-10。

**后续扩展**（可选，超出 owl-base 范围）：若需 `gamma`/`beta`/`bessel`，参考 Cephes 算法在 MoonBit 纯重写。

### 阶段 2：stats（763 行）

**源**：`src/base/stats/`（PRNG + 8 种基础分布 + 描述统计）

**切片**：
1. PRNG：owl-base 用 OCaml `Random` + 自实现。MoonBit 用 `@random.Rand::chacha8`（确定性）或移植 SFMT 算法。**决策**：先用 `@random`，后续按需移植 SFMT
2. 描述统计（mean/var/std/skew/kurtosis/min/max/...）
3. 8 种分布（Bernoulli/Cauchy/Exp/Gamma/Gaussian/Gumbel1/Gumbel2/Uniform）的 pdf/cdf/draw

**验收**：分布的 pdf/cdf 数值对齐参考；PRNG 确定性可复现。

### 阶段 3：ndarray + matrix（6,762 行，核心难点）

**源**：`src/base/dense/`

**前置**：实现 strided `Ndarray` struct（§2.1）。

**切片**：
1. `Ndarray` 核心：创建（zeros/ones/sequential/uniform/gaussian/init）、shape/get/set/reshape/flatten
2. 切片（basic slicing，先拷贝语义）
3. 逐元素算术 + 广播（`_get_broadcasted_dims`/`_get_broadcasted_index` 逻辑移植）
4. 归约（sum/mean/min/max/沿轴）
5. map/fold/scan
6. 拼接/平铺/repeat/tile/squeeze/expand
7. `Matrix` 作为 2D Ndarray 特化
8. 卷积/池化（`owl_base_dense_ndarray_generic` 中的 conv/pool 纯 OCaml 实现）

**测试**：每个切片与 OCaml toplevel 对比小数组结果；广播边界（形状不兼容抛 `OwlError`）；round-trip（reshape↔flatten, slice↔set_slice）。

**验收**：`Owl.Arr` 等价 API 可用，数值与 owl-base 一致。

### 阶段 4：linalg（656 行）

**源**：`src/base/linalg/`（纯 OCaml 线性代数，非 LAPACK）

**切片**：inv/det/rank/trace/solve/svd/eig/qr/lu/chol — 纯算法实现，基于矩阵基本算子。

**验收**：与 OCaml 对比 3×3/4×4 矩阵结果；`A * inv(A) ≈ I`。

### 阶段 5：algodiff（3,803 行）

**源**：`src/base/algodiff/`

**切片**：
1. AD 类型定义（DF/DR — 前向/反向节点）
2. core 算子（primal/tangent/adjref/...）
3. primal_ops（F64 的可微原语）
4. generic ops（sin/cos/exp/log/... 的可微版本）
5. reverse mode（反向传播核心）
6. graph_convert（DF↔DR 转换）

**测试**：`diff`/`grad`/`hessian`/`jacobian` 对已知函数验证（如 `diff sin = cos`）。

### 阶段 6：optimise（1,140 行）

**源**：`src/base/optimise/`

**切片**：Gradient/Newton/BFGS/L-BFGS/CG/Nelder-Mead + 回归 + 求根（zeros/）。

### 阶段 7：neural（6,183 行）

**源**：`src/base/neural/`

**切片**：neuron（Linear/Conv2D/Pool/Activation/...）→ graph → compiler → generic trainer。

### 阶段 8：compute（5,430 行）

**源**：`src/base/compute/`（计算图引擎）

**切片**：graph → operator → shape → symbol → type → optimiser → engine → cpu 后端。

### 阶段 9：misc + 顶层聚合

**源**：`src/base/misc/` + `owl_base.ml` 聚合

**切片**：cluster/dataset/sketch + `Owl` 顶层别名模块（`Owl.Arr`/`Owl.Mat`/`Owl.Algodiff`/...）。

## 5. 风险与回退

| 风险 | 影响 | 缓解 |
|---|---|---|
| 特殊函数在 owl-base 仍调 C（Cephes） | 阶段 1 阻塞 | 探测确认；若需，参考 cephes 算法在 MoonBit 重写（纯算法，非绑 C） |
| strided Ndarray 性能不及 Bigarray | 性能 | 先求正确；Native 后端 + 内联优化；热点可 `FixedArray` 直访 |
| trait 表达力不足 functor 场景 | algodiff/neural | F64 手写；S/C/Z 用代码生成或后续补 |
| 反向模式 AD 内存/性能 | algodiff | 先正确，tape 用 `Array`；后续优化 |
| 规模大、周期长 | 进度 | 严格按阶段+切片，每切片独立可测可提交 |

## 6. 验证策略

- **每切片**：`moon check --warn-list +73` + `moon test` + `moon info` + `moon fmt`
- **每阶段**：与 OCaml 参考值（`owl-base` toplevel）对比 golden values
- **round-trip**：encoder/decoder、reshape/flatten、slice/set_slice 成对验证
- **边界**：空数组、单元素、广播不兼容、溢出、nan/inf
- **多后端**：关键阶段跑 `moon test --target native` + `--target wasm` + `--target js`

## 7. 当前状态与下一步

- ✅ 源 inventory 完成
- ✅ 技术决策确定
- ✅ 包边界设计完成
- ✅ 分阶段路线图完成
- ✅ **阶段 0（脚手架）**：`src/types/` + `src/const/` — `moon check` 通过
- ✅ **阶段 1（maths）**：basic/erf/special/helpers/number_theory — 15 测试通过
- ✅ **阶段 2（stats）**：prng/dist/descriptive/order/quantile/histogram/kde/sample — 24 测试通过
- ✅ `moon check` 0 错误、`moon test` 83/83 passed、`moon fmt` + `moon info` 完成
- ✅ **阶段 3（ndarray + matrix）** — 全部完成：Ndarray struct + 创建/切片/算术/广播/归约/map/fold/拼接/卷积/池化/反向传播（44 测试通过）
- ✅ **阶段 4（linalg）** — 全部完成：is_triu/is_tril/is_symmetric/is_diag/trace/lu/det/logdet/inv/linsolve_lu/chol/qr/rank/tridiag_solve（12 测试通过）
- ✅ **阶段 5（algodiff）** — 核心完成：AD类型(T/Op) + SISO/PISO builder + 15个数学操作 + reverse mode + diff/grad/jacobian/hessian API（16 测试通过）
- ✅ **阶段 6（optimise）** — 全部完成：LearningRate/Batch/GradientMethod/Momentum/Regularisation/Clipping/Stopping enums + State/Params + run_*模块函数 + minimise_fun核心优化循环（7 测试通过）
- ✅ **阶段 7（neural）** — 核心完成：InitTyp/ActivationTyp enums + 10 layer structs (Ref包装) + Neuron enum + init_run/run_activation + connect/init_neuron/mktag/mkpar/mkpri/mkadj/update_neuron/run_neuron + Node/Network graph + forward/backward + input/linear/linear_nobias/activation/flatten/reshape/dropout/lambda layer构造函数 + algodiff扩展(tanh/softplus/softsign/matmul/reshape/flatten/softmax/zeros_arr/uniform_arr/gaussian_arr)（18 测试通过）
- ✅ `moon check` 0 错误、`moon test` 136/136 passed、`moon fmt` + `moon info` 完成

下一步：**阶段 8（compute）**。计算图引擎（5,430 行），含 graph/operator/shape/symbol/type/optimiser/engine/cpu 后端。
