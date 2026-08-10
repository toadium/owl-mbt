# 治理计划（v1）

## 概述
本轮聚焦 `unused_value`（Unused Variable）类型 warning 的全量清理。该类型是当前检查报告中唯一落在 `warning_guidelines.md` 明确处理范围内的 warning 类型，共 19 处，分布于 algodiff、ndarray、optimise 三个包共 7 个文件。修复方式统一：优先删除未使用变量绑定，不适合删除的场景改为弃元 `_`。

## 批次策略
采用"单类型全量清理"策略。理由：
1. `unused_value` 是指导原则范围内唯一可处理类型，修复方式明确（删除或改 `_`），自动化程度高。
2. 19 处问题规模适中，作为一批可在不引入回归的前提下一次性消除该类型全部 warning。
3. 按包/文件无法进一步细分出更小的有意义批次（最大单文件 6 处），合并为一批可减少轮次开销。
4. 修复仅涉及局部变量绑定删除或重命名，不影响函数签名与公共 API，回归风险低。

## 修复清单

### unused_value

| 文件 | 行号 | Warning内容 |
|------|------|------------|
| src/algodiff/ops_arr_ext.mbt | 93 | Unused variable 'full_slice' |
| src/algodiff/ops_arr_ext.mbt | 112 | Unused variable 'v' |
| src/algodiff/ops_piso.mbt | 123 | Unused variable 'cp' |
| src/algodiff/ops_piso.mbt | 124 | Unused variable 'cp' |
| src/algodiff/ops_piso.mbt | 149 | Unused variable 'cp' |
| src/algodiff/ops_piso_ext.mbt | 21 | Unused variable 'a' |
| src/algodiff/ops_piso_ext.mbt | 22 | Unused variable 'b' |
| src/ndarray/core.mbt | 113 | Unused function 'get_broadcasted_index' |
| src/ndarray/nn_backward.mbt | 181 | Unused variable 'in_channel' |
| src/ndarray/nn_backward.mbt | 414 | Unused variable 'in_channel' |
| src/ndarray/nn_backward.mbt | 1049 | Unused variable 'kernel_cols' |
| src/ndarray/nn_backward.mbt | 1050 | Unused variable 'kernel_rows' |
| src/ndarray/nn_backward.mbt | 1051 | Unused variable 'in_channel' |
| src/ndarray/nn_backward.mbt | 1052 | Unused variable 'out_channel' |
| src/ndarray/nn_conv.mbt | 126 | Unused variable 'k_stride' |
| src/optimise/modules.mbt | 106 | Unused variable 'f' |
| src/optimise/modules.mbt | 107 | Unused variable 'w' |
| src/optimise/modules.mbt | 195 | Unused variable 'a' |
| src/optimise/modules.mbt | 195 | Unused variable 'b' |

## 排除项
本轮不修复以下 warning，原因均为不在 `warning_guidelines.md` 当前处理范围内（指导原则明确"仅处理以下列出的情况，其他 warning 暂不处理"）：

- `unused_constructor`（119 处）：指导原则未列出该类型处理策略；这些 variant 多为库 API 预留构造子，盲目删除会破坏公共 API 契约，需单独评估。
- `core_package_not_imported`（78 处）：属于 moon.pkg.json 导入配置问题，非源码局部修复，指导原则未列出该类型处理策略。
- `unused_error_type`（16 处）：涉及函数错误类型签名设计，指导原则未列出该类型处理策略。
- `deprecated_syntax`（2 处）：涉及 `fn` effect 推断语法迁移，指导原则未列出该类型处理策略。
- `deprecated`（2 处）：涉及 `x is None` 与 `PI` 替换，指导原则未列出该类型处理策略。

## 预期效果
预期本轮消除 19 处 `unused_value` warning，使该类型计数降为 0；总 warning 数由 236 降至 217。其余 5 类 warning 保持不变，留待后续轮次在指导原则扩展处理范围后再行治理。下一轮方向：重新运行 `moon check` 生成 check_v2.md，确认无新增回归；若指导原则范围未扩展且剩余 warning 仍均不在处理范围内，则返回 `NO_ACTIONABLE_PLAN`。
