# R6: 测试质量与 API 表面审查 — 全模块跨切关注点

审查时间：2026-08-11

### 审查范围

- 全部 11 个测试文件（397 个测试）：`src/*/[!_]*_test.mbt`、`src/*/[!_]*_wbtest.mbt`
- 全部 11 个公共接口文件：`src/*/pkg.generated.mbti`
- 跨模块 API 一致性：错误处理、命名约定、参数顺序、函数重复

### 发现

#### [严重] 错误处理风格跨模块不一致，用户无法统一处理错误

- **位置**：`src/misc/heap.mbt:66`、`src/misc/dataframe.mbt:85`、`src/neural/graph.mbt:107,219`、`src/compute/graph.mbt:129` 用 `abort`；`src/linalg/linalg.mbt:80` 等用 `raise @types.OwlError`；`src/misc/stack.mbt` 返回 `T?`
- **描述**：三种错误处理策略混用：(1) `raise @types.OwlError`（71 处，maths/stats/ndarray/linalg/algodiff/optimise）；(2) `abort(msg)`（6 处，misc/neural/compute，不可捕获，直接终止）；(3) 返回 `Option`（`Stack::pop`/`peek`）。用户无法用统一的 `try/catch` 处理跨模块错误，`abort` 路径无法恢复。
- **建议**：统一为 `raise @types.OwlError` 体系。将 `Heap::pop`/`peek` 的 `abort` 改为 `raise`（或返回 `T?` 与 `Stack` 一致），将 `DataFrame`/`neural`/`compute` 的 `abort` 改为 `raise`。

#### [严重] 内部实现类型暴露，破坏封装不变性

- **位置**：`src/algodiff/pkg.generated.mbti:165-177`（`Op`/`T`）、`src/compute/pkg.generated.mbti:106-245`（`Node`/`Op` 125 变体）、`src/neural/pkg.generated.mbti`（`Node`/`Network` 及 10 个 `*Neuron` 子类型）、`src/optimise/pkg.generated.mbti:132-144`（`State` 暴露 `gs`/`ps`/`us`/`ch`）
- **描述**：`algodiff.Op` 暴露 `adjoint`/`register`/`label_name`/`label_parents` 函数字段；`algodiff.T` 暴露 `F`/`Arr`/`DF`/`DR` 变体（用户应使用 `pack_flt`/`pack_arr`）；`compute.Op` 暴露 125 个变体；`neural.Node`/`Network` 暴露所有 `Ref` 字段，用户可直接篡改内部状态；`optimise.State` 暴露可变内部字段。
- **建议**：将内部类型设为包私有，仅暴露构造函数（`pack_flt`/`pack_arr`/`op_*`）和查询方法。若 MoonBit 可见性不支持包私有类型，至少在文档中标注"内部类型，不应直接构造"。

#### [严重] 内部函数仅为白盒测试公开，污染公共 API

- **位置**：`src/neural/pkg.generated.mbti`：`activation_create`/`add_create`/`concatenate_create`/`dropout_create`/`flatten_create`/`input_create`/`lambda_create`/`linear_create`/`linear_nobias_create`/`reshape_create`/`mkadj`/`mkadj_network`/`mkpar`/`mkpar_network`/`mkpri`/`mkpri_network`/`mktag`/`mktag_network`/`connect`/`connect_to_parents`/`collect_output`/`get_roots`/`make_network`/`make_node`/`init_neuron`/`update_neuron`/`update_network`/`to_name`；`src/optimise/pkg.generated.mbti`：`run_gradient`/`run_learning_rate`/`run_momentum`/`run_regularisation`/`run_clipping`/`run_stopping`/`update_ch`/`init_state`；`src/compute/pkg.generated.mbti`：`eval_node`/`collect_ancestors`
- **描述**：约 40 个内部函数仅为白盒测试（`*_wbtest.mbt`）而公开，用户面对的公共 API 表面膨胀，且内部函数签名不稳定，破坏向后兼容。
- **建议**：MoonBit 若支持 `pub(test)` 或内部测试可见性，将此类函数标记为测试可见而非公共。否则将白盒测试改为黑盒测试（通过公共 API 测试内部行为），移除内部函数的 `pub`。

#### [严重] 大量测试使用空断言 `assert_eq(true, true)`，不验证结果正确性

- **位置**：`src/algodiff/algodiff_test.mbt` 15 处（L516,539,562,584,607,635,751,761,770,780,789,799,808,818,1011）；`src/compute/compute_wbtest.mbt` 8 处（L48,76,113,138,166,195,202,237）；`src/optimise/optimise_wbtest.mbt` 5 处（L30,42,54,66,88）；`src/neural/neural_test.mbt` 17 处 `let _ = ...` 丢弃返回值
- **描述**：至少 28 个测试计算了结果但用 `let _ = ...` 丢弃后 `assert_eq(true, true)`，仅验证代码不崩溃。algodiff 的反向传播测试（结合 R3 发现的 sigmoid/sum/concatenate bug）是 bug 未被发现的主要原因。compute_wbtest 的 `eval_node` 覆盖测试不验证计算结果。optimise_wbtest 的 CG/CD/NonlinearCG/DaiYuanCG 测试不验证优化结果。
- **建议**：每个测试应验证具体数值。建议添加通用 `num_grad(f, x, eps)` 有限差分工具，对 algodiff 每个 op 进行 `|analytic_grad - num_grad| < tol` 断言。compute_wbtest 应验证 `eval_node` 的实际计算结果而非仅调用。

#### [严重] 浮点数使用精确相等 `assert_eq` 比较，测试脆弱

- **位置**：`src/maths/maths_test.mbt`：L4-12（add/sub/mul/div）、L17-18（exp/log）、L47-48（sin/cos）、L77-83（floor/ceil）、L88-89（erf/erfc）、L220-223（pow）、L229（softplus 硬编码 0.693...）、L238（expm1 硬编码 1.718...）、L244（cot 1.0000000000000002 极度脆弱）；`src/ndarray/ndarray_test.mbt`：L100-105、L111、L1169-1171、L1193、L1221；`src/misc/misc_test.mbt`：L158、L193-196；`src/neural/neural_test.mbt`：L168
- **描述**：maths 和 ndarray 大量使用 `assert_eq` 对浮点做精确比较，依赖 IEEE 754 舍入行为，跨平台/编译器可能失败。`cot(pi/4) == 1.0000000000000002` 尤其脆弱。linalg 测试一致使用 `approx_eq` 辅助函数（容差 1e-10），是正确做法。
- **建议**：为 maths 和 ndarray 添加 `approx_eq` 辅助函数（容差 1e-10 或 1e-12），将所有浮点 `assert_eq` 改为 `assert_true((actual - expected).abs() < eps)`。magic number 应替换为 `@math.PI / 4.0`、`@math.ln(2.0)` 等表达式并注释。

#### [一般] 跨模块命名不一致，同一操作不同名称

- **位置**：矩阵乘法 `ndarray.dot` vs `algodiff.matmul` vs `compute.Op::Dot`；元素乘法 `ndarray.mul` vs `algodiff.elmul`；元素除法 `ndarray.div` vs `algodiff.eldiv`；归约 `ndarray.sum_`/`min_`/`max_`（尾下划线）vs `stats.sum`/`min`/`max`；近似相等 `misc.approx_equal(Double, Double, Double)` vs `ndarray.approx_equal(Ndarray, Ndarray, eps?)` 参数顺序不同
- **描述**：用户跨模块使用时需记忆不同命名。`sum_` 尾下划线约定不直观（OCaml 惯例，MoonBit 无此必要）。
- **建议**：统一命名：`matmul` 跨模块一致（或 `dot` 一致）；`elmul`/`eldiv` 改为 `mul`/`div` 与 ndarray 一致；`sum_`/`min_`/`max_` 在文档中说明尾下划线含义或提供无下划线别名。

#### [一般] 边界用例测试缺失

- **位置**：全模块。空数组：仅 `stats.sum([])` 测试，其他归约函数未测试；NaN/Inf：maths 无 `log(0)`/`log(-1)`/`sqrt(-1)` 测试；单元素：stats/ndarray 未测试；奇异矩阵：linalg 无 `inv`/`lu`/`det` 奇异测试；非方阵：linalg 未测试；`chol` 非正定：未测试；`conv2d`/`max_pool2d` Same padding：未测试（仅 Valid）；`dropout` rate=0/1 边界：未测试
- **描述**：边界用例是发现 bug 的主要手段，缺失导致 R1-R5 发现的空数组崩溃、奇异矩阵处理不一致等问题未被测试捕获。
- **建议**：为每个公共函数添加边界测试套件：空输入、单元素、零值、负值、NaN、Inf、极大/极小值。linalg 添加奇异矩阵（应 raise）、非方阵（应 raise）、1x1 矩阵测试。

#### [一般] 逆关系/不变性验证不足

- **位置**：`src/stats/stats_test.mbt`：`sort`（L97-101）未验证是原数组排列，`argsort`（L104-107）未验证 `sort(x) == x[argsort(x)]`，`rank`（L110-114）未验证与排序关系；`src/ndarray/ndarray_test.mbt`：`transpose(transpose(A)) == A` 未测试，`split` 后 `concatenate` 恢复原数组未测试；`src/algodiff/algodiff_test.mbt`：前向模式与反向模式梯度一致性未测试，`jacobianv` 与 `jacobianTv` 对偶关系未测试
- **描述**：逆关系验证是检验实现正确性的强有力手段，缺失使 bug 更难发现。
- **建议**：添加逆关系测试：`transpose` 二次应用恢复原数组；`split`/`concatenate` 互逆；`sort`/`argsort` 关系；前向/反向 AD 梯度一致性。

#### [一般] `Ndarray.data` 字段公开暴露，允许绕过形状约束

- **位置**：`src/ndarray/pkg.generated.mbti:444-447`、`src/ndarray/core.mbt:4-7`
- **描述**：`pub struct Ndarray` 的 `shape : Array[Int]` 和 `data : FixedArray[Double]` 均公开可修改。外部代码可直接修改 `shape` 而不修改 `data`，破坏 `prod(shape) == data.length()` 不变性，后续操作越界或产生垃圾结果。（与 R2 T26 同一问题，从 API 表面角度复述）
- **建议**：字段设为包私有，仅通过 `shape()`/`get()`/`set()` 方法访问。

#### [一般] 池化反向传播 padding 参数位置与前向不一致

- **位置**：`src/ndarray/pkg.generated.mbti:263`（`max_pool2d_backward(padding, input, kernel, stride, grad_out)` — padding 第一参数）vs L265（`max_pool2d(input, kernel, stride, padding?)` — padding 最后参数可选）
- **描述**：前向传播 padding 为可选末参数，反向传播 padding 为必选首参数，用户需记忆不同顺序。
- **建议**：统一 padding 为最后参数（反向传播中亦为必选最后参数）。

#### [一般] `inspect` 快照测试等效于浮点精确比较

- **位置**：`src/maths/maths_test.mbt` L19-42,67-72,90-107,120-143；`src/stats/stats_test.mbt` L12-30,35-46,52-63 等
- **描述**：`inspect` 将值转为字符串做快照比较，对浮点等效于精确比较（依赖 `to_string` 的舍入行为），且快照字符串可能跨 MoonBit 版本变化。
- **建议**：将 `inspect` 测试改为 `approx_eq` 容差比较，仅对整数/字符串保留 `inspect`。

#### [一般] 硬编码 magic number 无注释

- **位置**：`src/maths/maths_test.mbt` L50（`1.5707963267948966` = pi/2）、L56（`0.7853981633974483` = pi/4）、L229（`0.6931471805599453` = ln2）、L238（`1.718281828459045` = e-1）；`src/stats/stats_test.mbt` L333（容差 0.2）、L341（容差 0.3）；`src/neural/neural_test.mbt` L158（容差 0.01）
- **描述**：未注释的 magic number 降低可读性，且硬编码的 pi/2、ln2 等应使用 `@const.pi_2`、`@math.ln(2.0)` 表达式。
- **建议**：替换为常量表达式并注释，容差值注释解释选择依据。

#### [轻微] 未实现函数暴露在公共 API

- **位置**：`src/maths/pkg.generated.mbti:51`（`dawsn` 声明 `raise OwlError` 但实现仅 `raise NotImplemented`，见 `src/maths/special.mbt:27-28`）
- **描述**：`dawsn`（Dawson 积分）完全未实现，但暴露在公共 API 中，用户调用才发现不可用。
- **建议**：移除 `dawsn` 的 `pub` 或在文档中明确标注 `NotImplemented`。

#### [轻微] `DeviceType::OpenCl`/`Cuda` 暴露但项目无 GPU 支持

- **位置**：`src/types/pkg.generated.mbti:20-24`
- **描述**：项目是纯后端实现（无 C FFI），`OpenCl`/`Cuda` 变体无用，暴露误导用户。
- **建议**：移除 `OpenCl`/`Cuda` 变体，仅保留 `Cpu`。

#### [轻微] `const` 命名易混淆

- **位置**：`src/const/pkg.generated.mbti`：`pi2`（2*pi）vs `pi_2`（pi/2）、`pi4`（4*pi）vs `pi_4`（pi/4）
- **描述**：`pi2` 和 `pi_2` 仅差一个下划线但语义相反（乘 vs 除），易误用。
- **建议**：重命名为 `two_pi`/`pi_over_2`/`four_pi`/`pi_over_4`，或在文档中显著标注。

#### [轻微] `Index::I`/`L`/`R` 单字母命名不清晰

- **位置**：`src/types/pkg.generated.mbti:26-30`
- **描述**：`I`（索引）、`L`（左）、`R`（右）单字母命名，用户需查文档才能理解。
- **建议**：重命名为 `Index`/`Left`/`Right` 或 `Idx`/`Left`/`Right`。

#### [轻微] `shall_print` 命名非标准英语

- **位置**：`src/misc/pkg.generated.mbti:83`
- **描述**：`shall_print` 应为 `should_print`（标准英语情态动词）。
- **建议**：重命名为 `should_print`。

#### [轻微] 公共函数文档缺失

- **位置**：`src/neural/neuron.mbt`（`run_activation`/`init_run`）、`src/neural/graph.mbt`（`make_network`/`make_node`）、`src/compute/constructors.mbt`（`op_*` 函数）、`src/optimise/modules.mbt`（`run_gradient`/`update_ch`）、`src/maths/special.mbt`（`softplus`/`expit`/`log1pexp`/`log1mexp`）、`src/stats/descriptive.mbt`（`sem`/`absdev`/`central_moment`）
- **描述**：多个公共函数缺乏 `///` 用户文档，仅有移植注释。
- **建议**：为所有公共函数添加 `///` 文档注释，说明参数、返回值、异常和示例。

#### [轻微] `xlogy`/`xlog1py`/`sem`/`absdev`/`draw`/`op_var`/`update_ch` 命名不清晰

- **位置**：`src/maths/pkg.generated.mbti:161,163`（`xlogy`/`xlog1py`）、`src/stats/pkg.generated.mbti:9,95`（`absdev`/`sem`）、`src/ndarray/pkg.generated.mbti:127`（`draw`）、`src/compute/pkg.generated.mbti:81`（`op_var`）、`src/optimise/pkg.generated.mbti:67`（`update_ch`）
- **描述**：函数名含义不自明，需查文档。
- **建议**：在文档中解释，或重命名为更清晰的名称（`x_times_log_y`/`x_times_log1p_y`/`absolute_deviation`/`standard_error`）。

#### [轻微] `concordant`/`discordant` 内部辅助函数公开

- **位置**：`src/stats/pkg.generated.mbti:21,25`
- **描述**：仅用于 `kendall_tau` 计算的内部辅助函数暴露在公共 API。
- **建议**：移除 `pub` 或标记为内部。

#### [轻微] `map`/`map_elem`/`map_elem_inplace` 三种命名冗余

- **位置**：`src/ndarray/pkg.generated.mbti:247,249,253`
- **描述**：三个 map 变体命名风格不一，`map_elem` 与 `map` 功能重叠。
- **建议**：统一为 `map`/`map_inplace`，移除 `map_elem` 或在文档中说明区别。

#### [轻微] `from_fn`/`init_flat`/`init_nd` 三个创建函数职责重叠

- **位置**：`src/ndarray/pkg.generated.mbti:187,203,205`
- **描述**：三个创建函数功能相近，用户不知该选哪个。
- **建议**：合并为统一 API 或在文档中明确各自适用场景。

### 本轮统计

| 严重程度 | 数量 |
|---------|------|
| 严重 | 5 |
| 一般 | 6 |
| 软微 | 10 |

### 总评

**测试质量**：397 个测试数量充足，但质量参差不齐。linalg 测试质量最高（一致使用 `approx_eq` 容差、逆关系验证完整、边界用例有注释）。algodiff/compute_wbtest/optimise_wbtest 质量最低（28 处空断言 `assert_eq(true, true)`，结合 R3 发现的反向传播 bug，这些测试是 bug 未被发现的主要原因）。maths/ndarray 的浮点精确比较是系统性问题，跨平台脆弱。边界用例缺失是全模块通病——空数组、NaN/Inf、奇异矩阵、非方阵等边界场景未测试，导致 R1-R5 发现的诸多崩溃和错误处理问题未被测试捕获。

**API 表面**：公共 API 庞大且污染严重。neural 模块约 40 个内部函数仅为白盒测试公开，optimise 的 `run_*`/`update_ch` 同类问题。`algodiff.Op`/`T`、`compute.Op`（125 变体）、`neural.Node`/`Network` 等内部类型暴露所有字段，破坏封装。错误处理三种风格混用（`raise`/`abort`/`Option`），用户无法统一处理。跨模块命名不一致（`dot` vs `matmul`、`mul` vs `elmul`、`sum_` vs `sum`）增加学习成本。

**核心建议**：(1) 优先修复 28 处空断言测试，添加数值梯度验证；(2) 统一错误处理为 `raise @types.OwlError`；(3) 收敛公共 API，将内部函数/类型设为包私有；(4) 为 maths/ndarray 添加 `approx_eq` 辅助函数，替换浮点精确比较；(5) 系统性补充边界测试套件。
