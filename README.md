# owl-mbt

Owl 科学计算库的纯 MoonBit 移植，无 C FFI，多后端兼容（Native/Wasm/JS）。

源：[owl-base](https://github.com/owlbarn/owl)（纯 OCaml，34,326 行）。

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
| 7 | neural | 6,183 | ⏳ |
| 8 | compute | 5,430 | ⏳ |
| 9 | misc + 顶层聚合 | 4,068 | ⏳ |

## 已完成

- **阶段 0**：`src/types/`（Number/Index/Padding/DeviceType enums + OwlError suberror）、`src/const/`（17 个数学常量）
- **阶段 1**：`src/maths/` — basic.mbt、erf.mbt、special.mbt、helpers.mbt、number_theory.mbt（15 测试）
- **阶段 2**：`src/stats/` — prng.mbt、dist.mbt、descriptive.mbt、order.mbt、quantile.mbt、histogram.mbt、kde.mbt、sample.mbt（24 测试）
- **阶段 3**：`src/ndarray/` — core/creation/shape_ops/arithmetic/math_ops/reduction/iteration/comparison/matrix/slicing/random_init/extra/real_ops/nn_conv/nn_pool/nn_backward（44 测试）
- **阶段 4**：`src/linalg/` — is_triu/is_tril/is_symmetric/is_diag/trace/lu/det/logdet/inv/linsolve_lu/chol/qr/rank/tridiag_solve（12 测试）
- **阶段 5**：`src/algodiff/` — AD 类型(T/Op) + 核心helper + SISO/PISO操作builder + neg/abs/signum/sqr/sqrt/log/exp/sin/cos/tan/sinh/cosh/sigmoid/relu + add/sub/mul/div/pow + sum/transpose/concatenate + reverse_reset/push/prop + diff/grad/jacobian/hessian API（16 测试）
- **阶段 6**：`src/optimise/` — LearningRate/Batch/GradientMethod/Momentum/Regularisation/Clipping/Stopping enums + State/Params + run_learning_rate/update_ch/run_gradient/run_momentum/run_regularisation/run_clipping/run_stopping + minimise_fun（7 测试）
- **验证**：`moon check` 0 错误、`moon test` 118/118 passed

## 构建

```sh
moon check   # 类型检查
moon test    # 运行测试
moon fmt     # 格式化
moon info    # 生成接口
```

## 规划

详见 [docs/migration-plan.md](docs/migration-plan.md)。
