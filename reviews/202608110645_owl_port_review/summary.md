# Owl OCaml → MoonBit 移植代码审查总结

审查时间：2026-08-11
审查轮次：6 轮（R1-R6）
审查范围：96 文件，20,339 行新增，11 个包，397 个测试

## 总体评价

移植工作完成了 Owl 科学计算库从 OCaml 到纯 MoonBit（无 C FFI）的忠实移植，覆盖 types/const/maths/stats/ndarray/linalg/algodiff/optimise/neural/compute/misc 共 11 个包。397 个测试全部通过，0 warnings，0 errors。性能优化已完成两轮（广播快速路径、matmul 循环重排、原地操作 API 等）。

**主要成就**：
- 忠实移植了 OCaml 源码行为（包括疑似 bug 如 sigmoid 用 ln 而非 exp）
- 自行实现了 OCaml Bigarray.Genarray 的 MoonBit 替代（strided n-d array）
- 自行实现了 linalg 的 chol/qr/logdet/rank（OCaml 源码为 NOT_IMPLEMENTED 占位）
- 测试覆盖率从 44.8% 提升到 81.1%
- Warning 治理从 236 降至 0

**主要风险**：141 个问题待修复，其中 31 个严重、64 个一般、46 个轻微。

## 问题统计

| 轮次 | 模块 | 严重 | 一般 | 轻微 | 小计 |
|------|------|------|------|------|------|
| R1 | types/const/maths/stats | 2 | 9 | 7 | 18 |
| R2 | ndarray | 7 | 18 | 6 | 31 |
| R3 | algodiff/optimise | 5 | 11 | 5 | 21 |
| R4 | neural/compute | 5 | 9 | 6 | 20 |
| R5 | linalg/misc | 7 | 11 | 12 | 30 |
| R6 | 测试质量/API表面 | 5 | 6 | 10 | 21 |
| **合计** | | **31** | **64** | **46** | **141** |

## 严重问题分类（31 项）

### 正确性 bug（11 项）— 最高优先级
1. **conv2d/conv3d kernel 索引计算 bug**（R2 T19-T22）：out_channel > 1 时结果完全错误，缺少 out_channel 因子，影响前向和反向传播
2. **sigmoid 前向公式与导数不匹配**（R3 T46）：梯度方向错误，影响所有使用 sigmoid 的梯度下降
3. **sum 沿 axis 反向传播忽略 axis**（R3 T47）：梯度形状/数值错误
4. **concatenate 反向传播只处理第一个输入**（R3 T48）：其余输入梯度丢失
5. **`collect_ancestors` 拓扑排序在菱形依赖下错误**（R4 T62）：eval_graph 在菱形依赖下 abort
6. **`_min_scalar` 对 AD 节点直接返回**（R4 T65）：HardSigmoid/Relu6 梯度错误
7. **Count-Min Sketch 哈希整数溢出**（R5 T76）：a*x 可达 2^60 远超 Int32
8. **Count-Min Sketch 负索引越界**（R5 T77）：溢出时负余数导致数组越界
9. **`is_pow2(Int::min)` 返回 true**（R1 T2）：边界 bug
10. **`get_network` 隐含副作用**（R4 T63）：污染 Network.outputs
11. **`connect_pair` 名称去重不可靠**（R4 T66）：名称冲突时连接丢失

### 安全性/边界处理（10 项）
12. **`min`/`max`/`minmax` 空数组崩溃**（R1 T1）
13. **`min_`/`max_`/`mean_` 空数组崩溃/除零**（R2 T23-T24）
14. **avg_pool 零窗口除零**（R2 T25）
15. **Count-Min Sketch 初始化不验证参数**（R5 T78）
16. **tridiag_solve 不校验输入长度**（R5 T79）
17. **DataFrame 不校验列长度一致**（R5 T80）
18. **`run` 假设单输入单输出**（R4 T64）
19. **concatenate DF tag 硬编码 0**（R3 T49）
20. **QR thin 参数声明但未实现**（R5 T81）
21. **`min`/`max` 空数组（stats）**（R1 T1，与 T23 同类）

### 测试质量（3 项）
22. **28 处空断言 `assert_eq(true, true)`**（R6 T107）：不验证结果正确性
23. **浮点精确比较**（R6 T108）：测试脆弱
24. **13 处反向传播空断言**（R3 T50，与 T107 重叠）

### API 设计（4 项）
25. **错误处理三种风格混用**（R6 T104）：raise/abort/Option
26. **内部类型暴露**（R6 T105）：破坏封装
27. **约 40 个内部函数公开**（R6 T106）：污染 API
28. **`Ndarray.data` 字段暴露**（R2 T26，与 T105 同类）

## 修复优先级建议

### P0 — 立即修复（正确性 bug，11 项）
- conv2d/conv3d 索引 bug（T19-T22）
- sigmoid/sum/concatenate 反向传播 bug（T46-T49）
- 拓扑排序 bug（T62）
- `_min_scalar` AD 节点处理（T65）
- Count-Min Sketch 溢出（T76-T77）
- `is_pow2(Int::min)`（T2）

### P1 — 尽快修复（安全性/边界，10 项）
- 空数组崩溃（T1, T23-T25）
- 输入校验（T78-T81）
- `get_network` 副作用（T63）、`run` 单输入假设（T64）、`connect_pair` 去重（T66）

### P2 — 计划修复（测试质量，3 项）
- 空断言测试（T107）
- 浮点精确比较（T108）
- 边界测试补充（T110）

### P3 — 逐步改进（API 设计，4 项）
- 错误处理统一（T104）
- 内部类型/函数收敛（T105-T106）

### P4 — 机会修复（一般 + 轻微，113 项）
- 详见 todo.md T3-T18, T26-T45, T51-T61, T67-T103, T109-T124

## 文件清单

- `reviews/202608110645_owl_port_review/scope.md` — 审查范围
- `reviews/202608110645_owl_port_review/review.md` — 进度跟踪
- `reviews/202608110645_owl_port_review/review_v1.md` — R1 基础层
- `reviews/202608110645_owl_port_review/review_v2.md` — R2 Ndarray
- `reviews/202608110645_owl_port_review/review_v3.md` — R3 Algodiff+Optimise
- `reviews/202608110645_owl_port_review/review_v4.md` — R4 Neural+Compute
- `reviews/202608110645_owl_port_review/review_v5.md` — R5 Linalg+Misc
- `reviews/202608110645_owl_port_review/review_v6.md` — R6 测试质量+API
- `reviews/202608110645_owl_port_review/todo.md` — 全部 141 个待办（T1-T124）
- `reviews/202608110645_owl_port_review/summary.md` — 本总结

## 下一步

1. 按优先级 P0-P4 修复 todo.md 中的问题
2. 每修复一批后运行 `moon test` 验证不回归
3. 严重问题修复后考虑重新审查受影响的模块
