# 待办事项

## R1: 基础层（types/const/maths/stats）

### T1 [严重] `min`/`max`/`minmax` 对空数组越界崩溃
- 位置：`src/stats/order.mbt:160,171,182`
- 修复：添加空数组检查并 `raise @types.OwlError::InvalidArgument`，与 `minmax_i` 保持一致

### T2 [严重] `is_pow2(Int::min)` 返回 `true`
- 位置：`src/maths/helpers.mbt:36`
- 修复：改为 `x > 0 && (x & (x - 1)) == 0`

### T3 [一般] `variance` 单元素数组行为偏离 OCaml
- 位置：`src/stats/descriptive.mbt:33`
- 修复：在注释中标注行为，或统一用 `l - 1.0`

### T4 [一般] `cov` 用 n 而 `variance` 用 n-1 作分母
- 位置：`src/stats/descriptive.mbt:127`
- 修复：在文档注释中说明使用总体协方差

### T5 [一般] `quantile` 闭包对空数组返回 0.0
- 位置：`src/stats/quantile.mbt:18`
- 修复：改为 raise InvalidArgument

### T6 [一般] `gaussian_kde` 对常量数据除零
- 位置：`src/stats/kde.mbt:49`
- 修复：检查 `h <= 0.0` 时 raise

### T7 [一般] `erfc`/`erfcx` 对大正 x 精度丧失
- 位置：`src/maths/erf.mbt:22`
- 修复：在文档注释中标注精度范围

### T8 [一般] `std_gaussian_rvs` 与 `gaussian_rvs` 代码重复
- 位置：`src/stats/dist.mbt:24,41`
- 修复：`gaussian_rvs` 改为 `mu + sigma * std_gaussian_rvs()`

### T9 [一般] `_binary_exp` 参数命名与语义不符
- 位置：`src/maths/number_theory.mbt:8`
- 修复：重命名为 `_binary_exp(exp, base, m, f, id)`

### T10 [一般] `normalise`/`normalise_density` 未防护零总计数
- 位置：`src/stats/histogram.mbt:371,391`
- 修复：检查 `total == 0` 时 raise

### T11 [一般] `kendall_tau` 对 n<2 除零
- 位置：`src/stats/order.mbt:35`
- 修复：添加 `x0.length() < 2` 检查

### T12 [一般] 分布采样缺少参数校验
- 位置：`src/stats/dist.mbt:65,149,156`
- 修复：校验 `lambda > 0.0`，用 `rand01_exclusive()` 避开 0.0

### T13 [轻微] `Index` 类型缺少 `Eq` derive
- 位置：`src/types/types.mbt:12`
- 修复：改为 `derive(Debug, Eq)`

### T14 [轻微] `is_subnormal` 硬编码 DBL_MIN
- 位置：`src/maths/helpers.mbt:17`
- 修复：在 const 中定义 `min_normal64` 并引用

### T15 [轻微] `round` 负半整数行为非对称
- 位置：`src/maths/basic.mbt:141`
- 修复：在文档注释中补充示例

### T16 [轻微] 测试缺少关键边界用例
- 位置：`src/maths/maths_test.mbt`、`src/stats/stats_test.mbt`
- 修复：补充 round 负半整数、is_pow2(Int::min)、空数组、erfc 大 x 等用例

### T17 [轻微] `concordant`/`discordant` 内层 `i != j` 冗余
- 位置：`src/stats/order.mbt:10,25`
- 修复：删除 `i != j &&` 条件

### T18 [轻微] `same_sign` 对 ±0.0 不区分
- 位置：`src/maths/helpers.mbt:41`
- 修复：在文档注释中标注行为

## R2: Ndarray 核心数据结构（详见 `review_v2.md`）

### T19 [严重] conv2d kernel 索引计算错误（out_channel > 1 时结果完全错误）
- 位置：`src/ndarray/nn_conv.mbt:127,144-147`
- 修复：`k_col_stride = kernel_rows * in_channel * out_channel`，`k_base` 含 `out_channel` 因子；补充 out_channel>1 测试

### T20 [严重] conv3d kernel 索引计算错误（out_channel > 1 时结果完全错误）
- 位置：`src/ndarray/nn_conv.mbt:315-320`
- 修复：参照 `conv3d_backward_kernel`（L384-389）的正确写法；补充 out_channel>1 测试

### T21 [严重] conv2d_backward_input kernel 索引计算错误
- 位置：`src/ndarray/nn_backward.mbt:80-83`
- 修复：加 `out_channel` 因子，参照 `conv2d_backward_kernel`（L156-159）

### T22 [严重] conv3d_backward_input kernel 索引计算错误
- 位置：`src/ndarray/nn_backward.mbt:289-294`
- 修复：参照 `conv3d_backward_kernel`（L384-389）

### T23 [严重] min_ / max_ 对空数组越界访问
- 位置：`src/ndarray/reduction.mbt:14, 26`
- 修复：空数组时 raise `OwlError::InvalidArgument`

### T24 [严重] mean_ 对空数组除以零
- 位置：`src/ndarray/reduction.mbt:138`
- 修复：空数组时 raise

### T25 [严重] avg_pool2d / avg_pool3d 窗口全在 padding 区域时除以零
- 位置：`src/ndarray/nn_pool.mbt:238, 288`
- 修复：`cnt == 0` 时返回 0.0

### T26 [一般] Ndarray struct 字段公开暴露，破坏封装不变性
- 位置：`src/ndarray/core.mbt:4-7`
- 修复：字段设为包私有，仅通过方法访问

### T27 [一般] from_data 不校验 data 长度与 shape 一致性
- 位置：`src/ndarray/creation.mbt:86-88`
- 修复：添加长度检查

### T28 [一般] of_array 不校验 arr 长度与 shape 一致性
- 位置：`src/ndarray/creation.mbt:146-153`
- 修复：添加长度检查

### T29 [一般] of_arrays 不校验各行长度一致
- 位置：`src/ndarray/creation.mbt:157-168`
- 修复：遍历检查所有行长度一致

### T30 [一般] get / set 不校验 index 维度数
- 位置：`src/ndarray/creation.mbt:40-55, 59-74`
- 修复：添加 `index.length() != x.shape.length()` 检查

### T31 [一般] map_elem2 / greater / less / greater_equal / less_equal 不校验形状一致
- 位置：`src/ndarray/math_ops.mbt:33-46`，`src/ndarray/comparison.mbt:90-131`
- 修复：添加形状一致性检查

### T32-T45 [一般/轻微] 其余 R2 问题（共 14 项）
- 详见 `review_v2.md`：broadcast 形状不校验、reshape/tile/repeat 边界、concatenate/stack 维度检查、slice 边界、roll axis 校验、swapaxes 语义、性能优化机会、文档缺失等

## R3: Algodiff + Optimise（详见 `review_v3.md`）

### T46 [严重] sigmoid 标量前向公式与导数公式不匹配，AD 结果错误
- 位置：`src/algodiff/ops_siso.mbt:172-182`
- 修复：前向改为标准 sigmoid `1.0 / (1.0 + @math.exp(-v))`，或同步修正导数公式

### T47 [严重] sum 沿 axis 的反向传播忽略 axis 参数，梯度形状/数值错误
- 位置：`src/algodiff/ops_arr.mbt:46-70`
- 修复：adjoint 中根据 `captured_axis` 将 `ca.val` 广播回 `captured_x` 形状

### T48 [严重] concatenate 反向传播只处理第一个输入，其余输入梯度丢失
- 位置：`src/algodiff/ops_arr2.mbt:76-101`
- 修复：沿 `captured_axis` 分割 `ca.val` 为各输入梯度

### T49 [严重] concatenate 的 DF 分支对非 DF 结果将 tag 硬编码为 0
- 位置：`src/algodiff/ops_arr2.mbt:56-75`
- 修复：从原始 `arrs` 提取有效 tag

### T50 [严重] 大量反向传播测试使用空断言，未验证梯度正确性
- 位置：`src/algodiff/algodiff_test.mbt` 13 处
- 修复：与数值梯度（有限差分）对比，添加 `num_grad` 工具函数

### T51-T61 [一般/轻微] 其余 R3 问题（共 11 项）
- 详见 `review_v3.md`：is_arr 命名、run_clipping 未实现、run_stopping Early 未实现、minimise_fun stop 后仍更新、Adam 学习率公式、hessian 嵌套 AD、copy_primal_ 不递归、set_slice 对 DF/DR 返回、reverse_reset/push 状态、jacobian_prime 维度假设、minimise_fun 重复梯度计算

## R4: Neural + Compute（详见 `review_v4.md`）

### T62 [严重] `collect_ancestors` 拓扑排序在菱形依赖下产生错误顺序
- 位置：`src/compute/graph.mbt:153-176`
- 修复：改用递归后序 DFS 或 Kahn 算法

### T63 [严重] `get_network` 隐含副作用污染 Network.outputs 字段
- 位置：`src/neural/graph.mbt:96-99`
- 修复：改为纯查询函数 `n.network.val`

### T64 [严重] `run` 假设单输入单输出，多输入/多输出网络会出错
- 位置：`src/neural/graph.mbt:207-221`
- 修复：支持 `run(inputs : Array[T], nn)` 或文档明确限制

### T65 [严重] `_min_scalar` 对 AD 节点直接返回，HardSigmoid/Relu6 反向梯度错误
- 位置：`src/neural/neuron.mbt:84-105`
- 修复：取 `primal_(x)` 应用 min 后重新包装

### T66 [严重] `connect_pair` 使用节点名称去重，名称冲突时连接丢失
- 位置：`src/neural/graph.mbt:114-132`
- 修复：使用节点引用相等或唯一 ID 去重

### T67-T75 [一般/轻微] 其余 R4 问题（共 9 项）
- 详见 `review_v4.md`：Dropout 未实现、eval_node 大量 passthrough、Min/Max/Sum 忽略轴参数、_infer_shape_concatenate 错误、backward 标量输出假设、connect 不去重、connect Linear in_shape 仅取一维、linear_create 权重 [0,0] 形状

## R5: Linalg + Misc（详见 `review_v5.md`）

### T76 [严重] Count-Min Sketch 哈希函数整数溢出
- 位置：`src/misc/countmin.mbt:16`
- 修复：使用 `Int64` 中间运算

### T77 [严重] Count-Min Sketch 负索引导致数组越界
- 位置：`src/misc/countmin.mbt:45, 56`
- 修复：确保 `_hash31` 返回非负，或 `%` 后加 `((idx % w) + w) % w`

### T78 [严重] Count-Min Sketch 初始化不验证参数，存在除零风险
- 位置：`src/misc/countmin.mbt:22-38`
- 修复：校验 `l > 0 && w > 0` 和 `epsilon/delta ∈ (0,1)`

### T79 [严重] tridiag_solve 不校验输入数组长度，存在越界风险
- 位置：`src/linalg/linalg.mbt:594-622`
- 修复：校验 `a/c/r.length() >= n` 和 `n > 0`

### T80 [严重] DataFrame 不校验列长度一致，后续操作越界
- 位置：`src/misc/dataframe.mbt:46-57`
- 修复：遍历所有列验证长度一致

### T81 [严重] QR 分解 thin 参数声明但未实现
- 位置：`src/linalg/linalg.mbt:508`
- 修复：实现 thin QR 或 raise `NotImplemented`

### T82-T103 [一般/轻微] 其余 R5 问题（共 22 项）
- 详见 `review_v5.md`：LU 奇异矩阵不报错、logdet 数值奇异不报错、LU 代码重复、inv/chol/logdet/rank 边界测试缺失、Heap pop/peek 用 abort、Logger.colorful 未实现、DataFrame to_string O(n²)、Column 三数组冗余、错误处理风格不统一、测试覆盖不足等

## R6: 测试质量与 API 表面（详见 `review_v6.md`）

### T104 [严重] 错误处理风格跨模块不一致（raise / abort / Option 三种混用）
- 位置：`src/misc/heap.mbt:66`、`src/misc/dataframe.mbt:85`、`src/neural/graph.mbt:107,219`、`src/compute/graph.mbt:129` 用 abort；`src/misc/stack.mbt` 返回 T?
- 修复：统一为 `raise @types.OwlError` 体系

### T105 [严重] 内部实现类型暴露，破坏封装（algodiff.Op/T、compute.Op 125变体、neural.Node/Network、optimise.State）
- 位置：`src/algodiff/pkg.generated.mbti:165-177`、`src/compute/pkg.generated.mbti:106-245`、`src/neural/pkg.generated.mbti`、`src/optimise/pkg.generated.mbti:132-144`
- 修复：内部类型设为包私有，仅暴露构造函数和查询方法

### T106 [严重] 约 40 个内部函数仅为白盒测试公开，污染公共 API
- 位置：`src/neural/pkg.generated.mbti`（`*_create`/`mk*`/`connect*`/`make_*` 等）、`src/optimise/pkg.generated.mbti`（`run_*`/`update_ch`）、`src/compute/pkg.generated.mbti`（`eval_node`/`collect_ancestors`）
- 修复：移除 pub 或改白盒测试为黑盒测试

### T107 [严重] 28 处测试使用空断言 `assert_eq(true, true)`，不验证结果
- 位置：`src/algodiff/algodiff_test.mbt` 15处、`src/compute/compute_wbtest.mbt` 8处、`src/optimise/optimise_wbtest.mbt` 5处、`src/neural/neural_test.mbt` 17处 `let _ = ...`
- 修复：添加数值梯度验证工具 `num_grad`，每个测试断言具体数值

### T108 [严重] 浮点数使用精确相等 `assert_eq` 比较，测试脆弱
- 位置：`src/maths/maths_test.mbt` 多处、`src/ndarray/ndarray_test.mbt` 多处、`src/misc/misc_test.mbt` L158,193-196、`src/neural/neural_test.mbt` L168
- 修复：添加 `approx_eq` 辅助函数，替换所有浮点 assert_eq

### T109 [一般] 跨模块命名不一致（dot vs matmul、mul vs elmul、sum_ vs sum）
- 位置：跨 ndarray/algodiff/compute 模块
- 修复：统一命名

### T110 [一般] 边界用例测试缺失（空数组、NaN/Inf、奇异矩阵、非方阵等）
- 位置：全模块
- 修复：为每个公共函数添加边界测试套件

### T111 [一般] 逆关系/不变性验证不足（transpose²=I、sort/argsort 关系、前向/反向 AD 一致性）
- 位置：stats/ndarray/algodiff 测试
- 修复：添加逆关系测试

### T112 [一般] 池化反向传播 padding 参数位置与前向不一致
- 位置：`src/ndarray/pkg.generated.mbti:263` vs L265
- 修复：统一 padding 为最后参数

### T113 [一般] inspect 快照测试等效于浮点精确比较
- 位置：`src/maths/maths_test.mbt`、`src/stats/stats_test.mbt` 大量使用
- 修复：改为 approx_eq 容差比较

### T114 [一般] 硬编码 magic number 无注释
- 位置：`src/maths/maths_test.mbt` L50,56,229,238；`src/stats/stats_test.mbt` L333,341；`src/neural/neural_test.mbt` L158
- 修复：替换为常量表达式并注释

### T115-T124 [轻微] 其余 R6 问题（共 10 项）
- 详见 `review_v6.md`：dawsn 未实现但暴露、DeviceType OpenCl/Cuda 无用、const pi2/pi_2 易混淆、Index I/L/R 单字母、shall_print 命名、公共函数文档缺失、xlogy/sem/absdev 命名不清晰、concordant/discordant 内部函数公开、map/map_elem 命名冗余、from_fn/init_flat/init_nd 职责重叠

## 累计统计

| 轮次 | 严重 | 一般 | 轻微 | 小计 |
|------|------|------|------|------|
| R1 | 2 | 9 | 7 | 18 |
| R2 | 7 | 18 | 6 | 31 |
| R3 | 5 | 11 | 5 | 21 |
| R4 | 5 | 9 | 6 | 20 |
| R5 | 7 | 11 | 12 | 30 |
| R6 | 5 | 6 | 10 | 21 |
| **合计** | **31** | **64** | **46** | **141** |
