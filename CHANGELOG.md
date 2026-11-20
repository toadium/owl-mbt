# Changelog

## [0.3.1] - 2026-11-20

### Added

- **测试 561 → 582**：KDE（Scott/Silverman 带宽、单样本/常量数据异常）、erf/erfc/erfcx、Bessel J0/J1（级数/渐近/奇偶/NaN）、特殊函数分支（signum/dawsn/xlogy/logit/expit/log1mexp/log1pexp）、CountMin（初始化/非法参数/计数）、矩阵视图（row/rows/diag 正负偏移/行列转换/dot/trace）
- `scripts/check_coverage.mjs`：覆盖率门槛（core ≥ 90%，排除 bench/examples）
- `scripts/mutation_test.mjs`：10 变异点（kde/erf/bessel/special/countmin/matrix），要求 100% KILLED
- `scripts/check_docs.mjs`：5 断言（版本/CHANGELOG、测试数、死链、覆盖率门槛+CI、assessment 口径）
- `AGENTS.md`：构建门禁、包结构、工程纪律、版本纪律

### Changed

- CI 重构：quality（fmt / check / `.mbti` 严格 drift / docs）/ test × 4 后端 / coverage / bench smoke / 手动 mutation
- 覆盖率口径修正：README 旧称 97.7% → **实测 90.6%（4516/4982，排除 bench/examples）**；门槛 90%
- 版本 0.3.1（0.3.0 为 mooncakes 已发布版本）

### Verified

- 582 测试 × 4 后端全绿；`moon check --deny-warn --target all` 零警告
- core 覆盖率 90.6%；变异 10/10 KILLED；docs 断言 5/5

## [0.3.0] - 2026-11-16

### Added

- **性能基准**：`bench/` 可执行包（`moon run bench --release`）+ `docs/benchmark.md`——13 组核心操作基准（ndarray 基础/FFT/SVD/LU/gamma/j0/AD/PRNG，wasm 与 native 双 release 口径，参数数组防常量折叠），与覆盖率数据共同构成质量量化证据
- **契约校验**：各包 `pkg.generated.mbti` 接口快照入库，CI 新增 `moon info` 契约校验步骤（mbti diff 未记录于 CHANGELOG 则阻断合并）
- **贡献指南**：`CONTRIBUTING.md`（环境搭建/开发流程/质量门禁/API 变更流程/测试要求）
- `bench.mbtx` standalone 基准脚本（0.3.0 发布后可 `moonx bench.mbtx` 直接运行）

### Changed

- CI 后端矩阵补 wasm-gc（native/wasm/wasm-gc/js 四后端，与 supported_targets 对齐）
- 迁移指南修正：`?→~` 仅是签名声明语法变化，调用点 `f(x=1)` 写法不变（实测验证）
- README 新增：适用与不适用场景、0.x 版本说明、FAQ 与踩坑指南、维护与反馈段（含响应时效 SLA）
- README 记录测试覆盖率 97.7%（moon coverage analyze 实测）

## [0.2.0] - 2026-11-16

### Breaking Changes

> 0.x 阶段按 SemVer 允许 API 变化；完整迁移方案见 [docs/migration-0.1.1-to-0.2.0.md](docs/migration-0.1.1-to-0.2.0.md)。

- **包布局**：源码从 `src/` 前缀迁移到模块根目录（扁平多根包布局），全部包引用路径变化；`@types` + `@const` 合并为 `@core`（25 个声明等价迁移，签名零变化）
- **Int → Int32**：约 150 处索引/形状/计数参数与返回值
- **可选参数声明语法**：签名声明 `x? : T = v` → `x~ : T = v`（约 30 个函数）；调用点 `f(x=1)` 写法不变，下游调用代码无需改动（实测验证）
- **raise 变化**：ndarray 11 个函数新增 raise（边界校验显式抛错）；`maths::dawsn`/`ndarray::dawsn` 移除 raise（已实现真实算法）
- **无 API 移除、无 API 改名**：0.1.1 的 665 个公开声明在 0.2.0 中全部可用（177 处签名变化均属上述 4 类）

### Added

- 特殊函数（`maths`）：`gamma`/`log_gamma`（Lanczos 近似 + reflection）、`beta`、`j0`/`j1`（幂级数 + Hankel 渐近）、`dawsn`（原项目 NOT_IMPLEMENTED 占位，本版完整实现）
- `ndarray.fft` / `ndarray.ifft`：一维 radix-2 Cooley-Tukey 快速傅里叶变换（2 的幂长度）
- `linalg.svd`：单边 Jacobi（Hestenes）thin SVD（原项目 NOT_IMPLEMENTED 占位，本版自行实现）
- `compute`：`eval_node` 全部可计算 op 实现，40+ passthrough 清零——形状类 Tile/Repeat/Concatenate/Stack/Split/UpSampling2d、标量算术与比较 18 个（标量取自 [1] 形状输入节点）、ClipByValue/ClipByL2norm、Get/Set/RowNum/ColNum/Row/Rows、Inv/Trace（经 linalg，无环依赖）、Conv1d/2d/3d 与 TransposeConv 全系列、全部 Max/AvgPool、OneHot、Draw、带轴 Min/Max/Sum/LogSumExp；语义不可无状态实现的 op（AD Prime 变体、FusedAdagrad、CopyRowTo/CopyColTo、ToRows/OfRows）由静默返回错误结果改为显式 raise `NotImplemented`
- `neural`：Dropout 层训练模式 inverted dropout 实现——bernoulli 掩码（keep 概率 `1-rate`）逐元素置零并按 `1/(1-rate)` 缩放，推理模式直通；`run_neuron` 新增可选 `train~` 参数，graph 层透传 `Node.train` 标志
- `optimise`：`run_clipping` 梯度裁剪实现——`L2norm` 在 primal 范数超过 `c` 时按 `c/norm` 重缩放（保留 AD 值图）；`Value` 经 `@ndarray.clip_by_value` 逐元素裁剪到 `[min,max]`（Owl 原版 `M.clamp` 语义，作用于梯度方向故裁剪 primal 值不破坏更新正确性）
- `optimise`：`run_stopping` Early 停止实现——`current_batch >= min_batches` 且当前批次损失相对 `patience` 批次前无下降（primal 值比较）时停止；签名从 `(Stopping, Double)` 改为 `(Stopping, State)`（包私有函数），调用点改为在停止判定前记录当前批次 loss
- `misc`：Logger 彩色输出实现——`format_msg` 按 `colorful` 开关对等级词做 ANSI 着色（Debug 青/Info 绿/Warn 黄/Error 红/Fatal 品红）

### Changed

- 重构为扁平多根包布局（源码从 `src/` 迁移到根级目录）
- 合并 `types` + `const` 为 `core` 零依赖包
- 所有包引用从 `@types.`/`@const.` 统一为 `@core.`
- 创建根包入口 `owl_mbt.mbt` + `moon.pkg`
- 移除 `moon.mod` 中的 `source = "src"` 配置
- 更新申报书为 `hackathon2026_owl_mbt_proposal.md`
- 迁移旧式 `derive(...)` 为 `#derive(...)` 新语法（core/types、stats 各类型）
- 删除 12 处未使用的包导入（根包、ndarray 的 double 改为测试专用导入、neural 的 math）
- `ndarray.reshape` 改用 `Iterator::count()` 替代弃用的 `length()`
- CI 门禁升级：`moon check --deny-warn` + native/wasm/js 三后端测试矩阵
- `linalg`：提取 `_lu_decompose` 核心供 `lu`/`det`/`logdet`/`linsolve_lu` 共用（行为逐一保持，含 tiny 替换与各自错误消息语义，净减约 170 行重复代码）

### Fixed

- 修复 `algodiff/moon.pkg` 的坏损配置（MoonLang 语法解析失败导致整个模块无法构建）
- 治理全部编译警告至零（2311 → 0，`moon check --deny-warn` 通过）：
  - 2274 处黑盒测试符号显式添加 `@pkg.` 前缀（根治 `test_unqualified_package`）
  - 15 处 `implicit_impl_as_method` 以包级 `warnings = "-79"` 抑制（derive 固有行为，项目内无点语法调用）
- ndarray 边界校验补齐：concatenate/stack 形状一致性、tile/repeat reps 长度、reduce axis 越界、transpose 轴排列、draw axis、split parts 总和
- `misc`：`col_min`/`col_max` 空列改 raise（原静默返回 0.0）；`slicing` step==0 改 raise（原 abort）

### Known Limitations

- `ndarray.draw` 在 `count > 1` 时索引展开实现有缺陷（输出形状随随机值漂移）；`compute.Draw` 已通过逐次抽取拼接绕过，ndarray 层待后续修复
- `compute` 的 `infer_shape` 与 `eval_node` 实现存在部分形状推断不一致（Split/带轴归约等），源码已注明

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
