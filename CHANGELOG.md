# Changelog

## [0.2.0] - 2026-11-10

### Changed

- 重构为扁平多根包布局（源码从 `src/` 迁移到根级目录）
- 合并 `types` + `const` 为 `core` 零依赖包
- 所有包引用从 `@types.`/`@const.` 统一为 `@core.`
- 创建根包入口 `owl_mbt.mbt` + `moon.pkg`
- 移除 `moon.mod` 中的 `source = "src"` 配置
- 更新申报书为 `hackathon2026_owl_mbt_proposal.md`

### Removed

- 删除过时的 `PROPOSAL.md`（已被新申报书替代）
- 删除过时的 `自查报告.md`（引用旧规则和旧架构）
- 删除 `instructions/` 目录（无用指令文件）
- 删除根级 `pkg.generated.mbti`（自动生成文件）

## [0.1.1] - 2026-08-14

### Added

- 发布至 mooncakes.io (`walkzzz/owl_mbt`)

### Fixed

- 修复所有 P0/P1 自查问题
- 消除全部编译警告（137 → 0）

## [0.1.0] - 2026-08-13

### Added

- 完整移植 Owl 科学计算库的 `owl-base` 包从 OCaml 到 MoonBit
- 10 个模块：core(types+const), maths, stats, ndarray, linalg, algodiff, optimise, neural, compute, misc
- 14,801 行 MoonBit 代码，79 个源文件
- 497 个测试，全部通过
- 3 个可运行示例：ndarray_demo, neural_demo, stats_demo
- GitHub Actions CI 配置
- MIT 许可证

### 移植内容

- **core**：类型定义、OwlError suberror、17 个数学常量
- **maths**：基础数学函数、erf/erfc（Abramowitz-Stegun 近似）、特殊函数、数论函数
- **stats**：PRNG、概率分布采样（高斯/指数/柯西/伽马/Gumbel）、描述性统计、直方图、KDE
- **ndarray**：自实现 strided N 维数组，替代 OCaml Bigarray
- **linalg**：LU 分解、行列式、逆矩阵、Cholesky 分解、QR 分解（Householder）、秩、三对角求解
- **algodiff**：自动微分前向+反向模式，支持标量/数组操作，广播机制
- **optimise**：梯度下降、动量法、正则化、学习率调度
- **neural**：10 种网络层（Input/Linear/LinearNoBias/Activation/Flatten/Reshape/Dropout/Add/Concatenate/Lambda）
- **compute**：计算图 DAG，120+ 操作类型，拓扑排序，形状推断
- **misc**：Logger、泛型 Stack/Heap、CountMinSketch、DataFrame

### 修复

- 修复原项目 sigmoid 实现 bug（`log` → `exp`）
- 自行实现 Cholesky 分解、QR 分解、logdet、rank（原项目为占位符）

### 代码审查

- 6 轮代码审查，141 个问题（P0-P4）全部修复
- Warning 治理：236 → 0
- 覆盖率提升：44.8% → 81.1%+
