# owl-mbt 工程质量评估（2026-11-20）

> 评估范围：walkzzz/owl_mbt @ 0.3.1（工作区，待发布）· 工具：moon 0.1.20261117（Windows native 实测）
> 口径：测试/覆盖率/变异数字均附复现命令；旧文档中不一致的历史数字以本页为准。

## 总览

| 指标 | 实测 | 复现 |
| --- | --- | --- |
| 测试 | **582 测试 × 4 后端**（native / wasm / wasm-gc / js） | `moon test --target all` |
| 编译门禁 | 四目标 `--deny-warn` 零警告 | `moon check --deny-warn --target all` |
| 格式 | `moon fmt --check` 通过 | `moon fmt --check` |
| 覆盖率（core，排除 bench/examples） | **4516/4982 = 90.6%** | `node scripts/check_coverage.mjs` |
| 变异测试 | **10 / 10 KILLED** | `node scripts/mutation_test.mjs` |
| 文档断言 | **5 / 5** | `node scripts/check_docs.mjs` |
| 基准 | `bench/` 13 组（native release） | `moon run bench --release --target native` |
| 版本 | `moon.mod` 0.3.1（0.3.0 为 mooncakes 已发布版本；0.3.1 待发布） | — |

## 本轮增强（0.3.1）

1. **测试补强 +20**：KDE（0/28 → 全覆盖）、erf/erfc/erfcx、Bessel 级数/渐近分支、特殊函数 8 个函数的分支、CountMin 初始化与计数、矩阵 row/rows/diag（正/负偏移）/行列互转/dot/trace。
2. **覆盖率门槛**：`scripts/check_coverage.mjs`（core ≥ 90%）；旧 README 的 97.7% 为不可复算口径，已改为实测 **90.6%** 并说明排除范围。
3. **变异矩阵**：`scripts/mutation_test.mjs` 10 变异点，覆盖数值/边界/矩阵索引/概率数据结构。
4. **CI 分层**：quality（fmt / check / `.mbti` 严格 / docs）、test × 4、coverage、bench smoke、手动 mutation。
5. **AGENTS.md**：门禁、包结构、工程纪律、版本纪律。

## 覆盖率缺口（下一轮可选）

| 文件 | 覆盖 | 说明 |
| --- | --- | --- |
| `algodiff/ops_piso_ext.mbt` | 50.0% | 扩展一元算子 |
| `compute/constructors.mbt` | 62.5% | 计算图算子构造 |
| `algodiff/ops_arr2.mbt` / `ops_arr.mbt` | 63.5% / 66.7% | 数组自动微分算子 |
| `maths/bessel.mbt` | 64.3%（补测后应升） | J0/J1 分支已补，剩余为极端输入 |
| `algodiff/builder.mbt` / `types.mbt` | 64.5% / 64.6% | 构建器与 AD 类型 |
| `ndarray/matrix.mbt` | 64.6%（补测后应升） | 视图已补，剩余为异常/边界 |
| `misc/dataframe.mbt` | 83.8% | DataFrame 列操作 |

> 覆盖率门槛 90% 为当前红线；上述缺口合计约 300 行，补到 95%+ 属 0.4.0 可选目标，不阻塞 0.3.1 发布。

## 已知限制（事实源）

- 未移植：Y0/Y1 第二类 Bessel、完整 BLAS/LAPACK、稀疏矩阵、Plotting（README「尚未移植的功能」）。
- 纯 MoonBit 实现，性能低于原生 BLAS/LAPACK；基准见 `docs/benchmark.md`。
- 0.x 阶段 API 可能变化，迁移指南见 `docs/migration-*.md`；`pkg.generated.mbti` 为契约快照，CI 严格阻断 drift。

## 风险与提示

| 风险 | 现状 | 处置 |
| --- | --- | --- |
| 文档数字漂移 | 历史 561/97.7% 与实际 582/90.6% 不一致 | 已统一 + `check_docs.mjs` 断言化 |
| Windows `moon prove`/平台差异 | 本项目无 proof 包，不涉及 | — |
| 覆盖率产物误提交 | `cov.txt` 为临时产物 | 已加入 `.gitignore` 并删除 |
| 发布节奏 | 0.3.0 已发布，0.3.1 待发布 | 发布由维护者执行 |