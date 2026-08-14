# owl-mbt

Owl 科学计算库的纯 MoonBit 移植，无 C FFI，多后端兼容（Native/Wasm/JS）。

## 项目信息

- **原项目**：[Owl](https://github.com/owlbarn/owl)（OCaml 科学计算库）
- **原项目许可证**：LGPL-2.1+
- **移植范围**：`owl-base` 包（纯 OCaml，34,326 行），不含 `owl` 包的 C 绑定层（OpenBLAS/LAPACK/Cephes）
- **本项目许可证**：MIT（详见 [LICENSE](LICENSE)）
- **代码规模**：14,801 行 MoonBit 代码，79 个源文件
- **测试**：497 个，全部通过
- **编译状态**：0 error，0 warning

## 迁移进度

| 阶段 | 模块 | 行数 | 状态 |
|---|---|---:|:---:|
| 0 | types + const（脚手架） | 972 | ✅ |
| 1 | maths（基础+特殊数学函数） | 1,664 | ✅ |
| 2 | stats（统计与分布） | 763 | ✅ |
| 3 | ndarray + matrix（核心难点） | 6,762 | ✅ |
| 4 | linalg | 656 | ✅ |
| 5 | algodiff | 3,803 | ✅ |
| 6 | optimise | 1,140 | ✅ |
| 7 | neural | 6,183 | ✅ |
| 8 | compute | 5,430 | ✅ |
| 9 | misc + 顶层聚合 | 4,068 | ✅ |

## 已完成

- **阶段 0**：`src/types/`（Number/Index/Padding/DeviceType enums + OwlError suberror）、`src/const/`（17 个数学常量）
- **阶段 1**：`src/maths/` — basic.mbt、erf.mbt、special.mbt、helpers.mbt、number_theory.mbt
- **阶段 2**：`src/stats/` — prng.mbt、dist.mbt、descriptive.mbt、order.mbt、quantile.mbt、histogram.mbt、kde.mbt、sample.mbt
- **阶段 3**：`src/ndarray/` — core/creation/shape_ops/arithmetic/math_ops/reduction/iteration/comparison/matrix/slicing/random_init/extra/real_ops/nn_conv/nn_pool/nn_backward
- **阶段 4**：`src/linalg/` — is_triu/is_tril/is_symmetric/is_diag/trace/lu/det/logdet/inv/linsolve_lu/chol/qr/rank/tridiag_solve
- **阶段 5**：`src/algodiff/` — AD 类型(T/Op) + SISO/PISO操作 + neg/abs/signum/sqr/sqrt/log/exp/sin/cos/tan/sinh/cosh/sigmoid/relu + add/sub/mul/div/pow + sum/transpose/concatenate + reverse mode + diff/grad/jacobian/hessian API
- **阶段 6**：`src/optimise/` — LearningRate/Batch/GradientMethod/Momentum/Regularisation/Clipping/Stopping + minimise_fun
- **阶段 7**：`src/neural/` — 10 layer types + Neuron enum + forward/backward + input/linear/linear_nobias/activation/flatten/reshape/dropout/lambda
- **阶段 8**：`src/compute/` — Op enum(120+ 变体) + DAG graph + topological_sort + shape inference + eval
- **阶段 9**：`src/misc/` — Logger + Stack[T] + Heap[T] + CountMinSketch + DataFrame + 工具函数
- **验证**：`moon check` 0 error、0 warning、`moon test` 497/497 passed

## 修改与适配

相对原项目 owl-base 的主要修改：

1. **Bigarray → 自实现 Ndarray**：OCaml 的 `Bigarray.Genarray` 在 MoonBit 中无对应物，自行实现了 strided n-d array 数据结构，这是整个移植的最大障碍
2. **sigmoid bug 修复**：原项目 `owl_base_maths.ml:120` 的 `sigmoid x = 1. /. (1. +. log (-.x))` 疑似 bug（应为 `exp`），已修复为标准 `1/(1+exp(-x))`
3. **linalg 自实现扩展**：原项目仅实现了 `inv`/`det`/`lu`/`linsolve_lu`/`linsolve_gauss`/`tridiag_solve_vec`，其余为 `NOT_IMPLEMENTED` 占位符。本项目自行实现了 `chol`（Cholesky 分解）、`qr`（Householder QR）、`logdet`、`rank`（基于 QR）、`trace`
4. **纯后端实现**：移除所有 C FFI 依赖，全部用纯 MoonBit 实现，支持 Native/Wasm/JS 三后端
5. **错误处理**：OCaml 异常 → MoonBit checked errors（`suberror` + `raise`）
6. **可变状态**：OCaml `ref` → MoonBit `Ref[T]`
7. **控制流**：OCaml `Owl_exception.FOUND` → `while` + `let mut` 循环

## 尚未移植或暂不支持的功能

1. **SVD 分解**：`svd` 在原项目中为 `NOT_IMPLEMENTED`，本项目也未实现
2. **高级特殊函数**：gamma/beta/bessel 函数等在 `owl` 包的 Cephes C 层，不在 `owl-base` 纯 OCaml 层
3. **BLAS/LAPACK 完整接口**：原 `owl` 包通过 C FFI 调用 OpenBLAS/LAPACK，本项目用纯 MoonBit 实现了核心线性代数操作但不含完整 BLAS/LAPACK 接口
4. **稀疏矩阵**：原项目有稀疏矩阵支持，本项目暂未移植
5. **FFT**：快速傅里叶变换未移植
6. **Plotting**：可视化功能不在纯计算库范围内

## 示例

```sh
moon run src/examples/ndarray_demo   # Ndarray 基本操作
moon run src/examples/neural_demo    # 神经网络前向/反向传播
moon run src/examples/stats_demo     # 统计与分布采样
```

## 构建

```sh
moon check   # 类型检查
moon test    # 运行测试
moon fmt     # 格式化
moon info    # 生成接口
```

## 代码审查

经过 6 轮代码审查（141 个问题），全部 P0-P4 修复完成。审查报告位于 `reviews/` 目录。

## 规划

详见 [docs/migration-plan.md](docs/migration-plan.md)。

## 许可证

本项目采用 [MIT 许可证](LICENSE)。原项目 Owl 采用 LGPL-2.1+ 许可证。
