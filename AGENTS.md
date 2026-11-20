# AGENTS.md — walkzzz/owl_mbt

MoonBit 科学计算库（Owl/OCaml 的纯 MoonBit 移植，无 C FFI）。主模块 `moon.mod` v0.3.1（0.3.0 为 mooncakes 已发布版本；0.3.1 待发布）。

## 构建与验证（完成标准）

- `moon check --deny-warn --target all` — 四后端零警告
- `moon test --target all` — 582 测试 × 4 后端全绿（native / wasm / wasm-gc / js）
- `moon fmt --check` — 格式门禁
- `node scripts/check_coverage.mjs` — 覆盖率门槛（core ≥ 90%，排除 bench/examples）
- `node scripts/mutation_test.mjs` — 10 变异点全 KILLED
- `node scripts/check_docs.mjs` — 文档数字断言
- `moon run bench --release --target native` — 性能基准 smoke

## 包结构

```
owl_mbt.mbt     # 门面（re-export）
core/           # 基础类型（Ndarray/OwlError/常量）
ndarray/        # N 维数组、切片、FFT、矩阵视图、CNN 算子
linalg/         # LU/SVD/求解器
maths/          # 基本数学、erf/bessel/gamma、特殊函数、数论
stats/          # 描述统计、分布、PRNG、顺序统计、直方图、KDE
algodiff/       # 自动微分（正向/反向、操作符、构建器）
neural/         # 神经网络层/图/神经元
optimise/       # 优化器
compute/        # 计算图（shape/eval/构造）
misc/           # 数据结构（堆/栈/DataFrame/CountMin/日志）
bench/          # 基准可执行包
examples/       # 可运行示例（ndarray/neural/stats）
governances/    # 治理记录
reviews/        # 代码审查记录
docs/           # 基准/迁移/评估文档
```

## 工程纪律

- **零 C FFI**：全部纯 MoonBit；新增数值算法必须有测试与容差说明。
- **契约优先**：`pkg.generated.mbti` 入库；公开 API 变化必须更新 CHANGELOG 并（破坏性时）更新迁移指南；CI 严格阻断 drift。
- **口径可复算**：README/AGENTS/assessment 中的测试数、覆盖率、基准数字必须能被 `scripts/*.mjs` 与 `moon` 命令复算；不确定时以实测为准。
- **覆盖率门槛**：core ≥ 90%（当前实测 90.6%，排除 bench/examples）；不得为过门槛而排除被测代码。
- **变异红线**：`scripts/mutation_test.mjs` 必须 10/10 KILLED；新增核心算法应同步增加变异点。
- **已知限制**：README「尚未移植的功能」与 `reviews/` 记录的 P2-P4 项是事实源；不得在文档中宣称已实现而未实现的能力。
- **发布**：`moon publish` 由维护者执行；发版前必须四目标测试 + 覆盖率 + 变异 + docs 断言全绿，并回写 `moon.mod`/README/CHANGELOG/AGENTS。

## 版本纪律

- `moon.mod` 版本 = CHANGELOG 最新条目 = README 发布说明。
- 0.x 阶段允许破坏性变更，但必须写迁移指南（`docs/migration-*.md`）。
- 发布后打 `vX.Y.Z` tag，并在 README 更新 mooncakes 徽章/版本段。