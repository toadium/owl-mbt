# R2: Ndarray 核心数据结构审查 — src/ndarray/

审查时间：2026-08-11

### 审查范围

- src/ndarray/core.mbt
- src/ndarray/creation.mbt
- src/ndarray/arithmetic.mbt
- src/ndarray/math_ops.mbt
- src/ndarray/reduction.mbt
- src/ndarray/shape_ops.mbt
- src/ndarray/real_ops.mbt
- src/ndarray/matrix.mbt
- src/ndarray/comparison.mbt
- src/ndarray/slicing.mbt
- src/ndarray/iteration.mbt
- src/ndarray/random_init.mbt
- src/ndarray/extra.mbt
- src/ndarray/nn_conv.mbt
- src/ndarray/nn_pool.mbt
- src/ndarray/nn_backward.mbt
- src/ndarray/ndarray_test.mbt
- src/ndarray/pkg.generated.mbti
- src/ndarray/moon.pkg

### 发现

#### [严重] conv2d kernel 索引计算错误（out_channel > 1 时结果完全错误）

- **位置**：`src/ndarray/nn_conv.mbt:127,144-147`
- **描述**：`conv2d` 中 kernel 的 flat 索引计算缺少 `out_channel` 因子。kernel shape 为 `[k_col, k_row, in_channel, out_channel]`（行主序），位置 `(di, dj, q, k)` 的正确 flat 索引应为：
  ```
  di * (kernel_rows * in_channel * out_channel) + dj * (in_channel * out_channel) + q * out_channel + k
  ```
  但代码中 `k_col_stride = kernel_rows * in_channel`（L127，缺少 `out_channel`），且 `k_base = di * k_col_stride + dj * in_channel + k`（L144），最终访问 `kernel.data[k_base + q * out_channel]`（L147），展开为：
  ```
  di * (kernel_rows * in_channel) + dj * in_channel + k + q * out_channel
  ```
  当 `out_channel > 1` 时，`di` 和 `dj` 的步长均少乘了 `out_channel`，导致读取到错误的 kernel 元素。现有测试（L416-429）仅覆盖 `out_channel == 1`，未暴露此 bug。经独立验证：input=[1,2,3,4] shape=[1,2,2,1]，kernel=[1..8] shape=[2,2,1,2]，正确结果应为 [50, 60]，实际输出 [30, 40]。
- **建议**：将 L127 改为 `let k_col_stride = kernel_rows * in_channel * out_channel`，将 L144 改为 `let k_base = di * k_col_stride + dj * (in_channel * out_channel) + q * out_channel + k`，移除 L147 的 `+ q * out_channel`（合并到 k_base）。或直接参照 `conv2d_backward_kernel`（L156-159）的正确写法。补充 `out_channel > 1` 的测试用例。

#### [严重] conv3d kernel 索引计算错误（out_channel > 1 时结果完全错误）

- **位置**：`src/ndarray/nn_conv.mbt:315-320`
- **描述**：与 conv2d 同类 bug。kernel shape 为 `[k_col, k_row, k_dpt, in_channel, out_channel]`，正确 flat 索引应为：
  ```
  di * (kernel_rows * kernel_dpts * in_channel * out_channel) + dj * (kernel_dpts * in_channel * out_channel) + d_dpt * (in_channel * out_channel) + q * out_channel + k
  ```
  但代码中（L315-319）缺少所有 `out_channel` 因子。当 `out_channel > 1` 时结果错误。现有测试（L868-879）仅覆盖 `out_channel == 1`。
- **建议**：参照 `conv3d_backward_kernel`（L384-389）的正确写法修正。补充 `out_channel > 1` 的测试用例。

#### [严重] conv2d_backward_input kernel 索引计算错误

- **位置**：`src/ndarray/nn_backward.mbt:80-83`
- **描述**：与 conv2d 同类 bug。`k_idx = di * (kernel_rows * in_channel) + dj * in_channel + q * out_channel + k`，缺少 `out_channel` 因子。当 `out_channel > 1` 时梯度计算错误。
- **建议**：改为 `di * (kernel_rows * in_channel * out_channel) + dj * (in_channel * out_channel) + q * out_channel + k`，参照 `conv2d_backward_kernel`（L156-159）。

#### [严重] conv3d_backward_input kernel 索引计算错误

- **位置**：`src/ndarray/nn_backward.mbt:289-294`
- **描述**：与 conv3d 同类 bug。缺少所有 `out_channel` 因子。当 `out_channel > 1` 时梯度计算错误。
- **建议**：参照 `conv3d_backward_kernel`（L384-389）的正确写法修正。

#### [严重] min_ / max_ 对空数组越界访问

- **位置**：`src/ndarray/reduction.mbt:14, 26`
- **描述**：`min_` 和 `max_` 直接访问 `x.data[0]`，当 `x.data.length() == 0` 时越界崩溃。`sum_`（L3-9）对空数组返回 0.0 是安全的，但 `min_`/`max_` 没有保护。
- **建议**：空数组时 raise `OwlError::InvalidArgument`，或返回 `nan`/`±inf` 并在文档中说明。

#### [严重] mean_ 对空数组除以零

- **位置**：`src/ndarray/reduction.mbt:138`
- **描述**：`mean_(x) = sum_(x) / x.data.length().to_double()`，当 `x.data.length() == 0` 时除以 0，返回 NaN。
- **建议**：空数组时 raise `OwlError::InvalidArgument`。

#### [严重] avg_pool2d / avg_pool3d 窗口全在 padding 区域时除以零

- **位置**：`src/ndarray/nn_pool.mbt:238, 288`
- **描述**：`end_fn` 中 `sum_val / cnt.to_double()`，当 `cnt == 0`（窗口完全落在 padding 区域外）时除以 0，返回 NaN。这在 `Same` padding + 大 stride + 大 kernel 的组合下可能发生。
- **建议**：当 `cnt == 0` 时返回 0.0（或 raise），而非除以零。

#### [一般] Ndarray struct 字段公开暴露，破坏封装不变性

- **位置**：`src/ndarray/core.mbt:4-7`，`pkg.generated.mbti:444-447`
- **描述**：`pub struct Ndarray` 的字段 `shape : Array[Int]` 和 `data : FixedArray[Double]` 均为公开可访问/可修改。外部代码可直接修改 `shape` 而不修改 `data`，导致 `prod(shape) != data.length()` 的不变性破坏，后续所有操作将越界或产生垃圾结果。
- **建议**：将字段设为包私有（去掉 `pub` 或使用 MoonBit 的可见性控制），仅通过 `shape()`/`get()`/`set()` 等方法访问。若需暴露字段用于性能，至少在文档中明确警告"外部不应直接修改"。

#### [一般] from_data 不校验 data 长度与 shape 一致性

- **位置**：`src/ndarray/creation.mbt:86-88`
- **描述**：文档注释写明 "The data length must match the product of shape dimensions"，但无运行时检查。调用者传入不一致的 shape/data 后，后续操作越界崩溃，错误难以追溯。
- **建议**：添加 `if data.length() != _numel_shape(shape) { raise ... }`，或在 debug 构建中加断言。

#### [一般] of_array 不校验 arr 长度与 shape 一致性

- **位置**：`src/ndarray/creation.mbt:146-153`
- **描述**：`of_array(arr, shape)` 假定 `arr.length() >= n`（`n = prod(shape)`），当 `arr.length() < n` 时 L150 `data[i] = arr[i]` 越界访问 `arr`。
- **建议**：添加长度检查，或仅复制 `min(arr.length(), n)` 个元素并补零。

#### [一般] of_arrays 不校验各行长度一致

- **位置**：`src/ndarray/creation.mbt:157-168`
- **描述**：`of_arrays` 用 `arrays[0].length()` 作为列数，但若后续行 `arrays[i].length() != cols`，L164 `data[i * cols + j] = arrays[i][j]` 会越界或静默错位。
- **建议**：遍历检查所有行长度一致，不一致时 raise。

#### [一般] get / set 不校验 index 维度数

- **位置**：`src/ndarray/creation.mbt:40-55, 59-74`
- **描述**：`get(x, index)` 和 `set(x, index, value)` 不检查 `index.length() == x.shape.length()`。当 `index` 维度数不匹配时，1D/2D 快速路径会越界访问 `index`，或 nD 路径的 `flat_index` 产生错误结果（多/少维度对应的 stride 计算错误）。
- **建议**：添加 `if index.length() != x.shape.length() { raise ... }`。

#### [一般] map_elem2 / greater / less / greater_equal / less_equal 不校验形状一致

- **位置**：`src/ndarray/math_ops.mbt:33-46`，`src/ndarray/comparison.mbt:90-131`
- **描述**：这些函数假定 `x.data.length() == y.data.length()`，但不检查形状一致。当 `x` 和 `y` 长度不同时，L43/L93/L103/L114/L125 越界访问 `y.data[i]`。`map_elem2` 还假定 shape 相同但仅复制 `x.shape`，若 `y` shape 不同会静默产生错误结果。
- **建议**：添加形状一致性检查（或至少长度检查），不一致时 raise。

#### [一般] dot 函数各分支缺少维度一致性检查

- **位置**：`src/ndarray/matrix.mbt:124-200`
- **描述**：
  - 1D×1D（L131-138）：不检查 `x.length() == y.length()`，越界访问 `y.data[i]`。
  - 1D×2D（L140-152）：不检查 `x.length() == y.shape[0]`，越界或错误结果。
  - 2D×1D（L159-170）：不检查 `x.shape[1] == y.length()`，越界或错误结果。
  - 2D×2D（L173-194）：仅检查 `y.shape[0] != k`（L177），但未检查输入是否为 2D。
- **建议**：各分支添加维度一致性检查。

#### [一般] concatenate / stack 不校验所有数组形状一致

- **位置**：`src/ndarray/shape_ops.mbt:121-158, 162-200`
- **描述**：`concatenate` 仅用 `arrs[0].shape` 作为基准，不检查其他数组在非 axis 维度的形状是否一致。`stack` 同样不检查所有数组形状一致。形状不一致时，`flat_index` 计算的输出位置会重叠或越界。
- **建议**：遍历检查所有数组在非 axis 维度形状一致。

#### [一般] tile / repeat 不校验 reps 长度

- **位置**：`src/ndarray/shape_ops.mbt:204-230, 234-260`
- **描述**：`tile(x, reps)` 和 `repeat(x, reps)` 假定 `reps.length() == x.shape.length()`，不检查。当 `reps` 长度不足时，L208/L237 `new_shape[i] = x.shape[i] * reps[i]` 越界访问 `reps`。
- **建议**：添加长度检查，或自动补 1。

#### [一般] sum / min / max 不校验 axis 越界

- **位置**：`src/ndarray/reduction.mbt:68-133`
- **描述**：`sum(x, axis=ax)` 当 `ax >= x.shape.length()` 时，`reduce_params`（core.mbt:115-130）越界访问 `shape[axis]` 和 `strides[axis]`。
- **建议**：添加 axis 范围检查。

#### [一般] transpose 不校验 axis 是有效排列

- **位置**：`src/ndarray/shape_ops.mbt:76-117`
- **描述**：`transpose(x, axis=perm)` 不检查 `perm` 是 `[0, 1, ..., n-1]` 的排列。当 `perm` 包含越界值或重复值时，L96 `x.shape[perm[i]]` 越界或产生错误形状，后续 `flat_index` 计算错误。
- **建议**：检查 `perm` 是有效排列（长度匹配、值在 [0,n)、无重复）。

#### [一般] conv2d / conv3d 不校验 in_channel 一致性和 stride 长度

- **位置**：`src/ndarray/nn_conv.mbt:97-162, 260-342`
- **描述**：`conv2d` 不检查 `input.shape[3] == kernel.shape[2]`（in_channel 一致），不检查 `stride.length() >= 2`，不检查 `input.shape.length() == 4` 和 `kernel.shape.length() == 4`。`conv3d` 同理。维度不匹配时静默越界或产生垃圾结果。
- **建议**：添加形状和维度一致性检查。

#### [一般] expand 函数的 _d 参数被忽略

- **位置**：`src/ndarray/shape_ops.mbt:63-72`
- **描述**：`expand(x, _d, hi?=false)` 的第二个参数 `_d` 以下划线开头表示未使用。函数仅在头部或尾部插入维度，忽略 `_d` 指定的位置。签名暗示可在任意位置插入维度，但实际不支持。
- **建议**：实现 `_d` 参数（在指定位置插入维度），或移除该参数并重命名为 `expand_head`/`expand_tail`。

#### [一般] softmax 1D 快速路径对空数组越界

- **位置**：`src/ndarray/real_ops.mbt:104-127`
- **描述**：1D 快速路径 L109 `let mut m = xd[0]`，当 `n == 0` 时越界。
- **建议**：空数组时提前返回，或 raise。

#### [一般] log_sum_exp_ 对空数组越界

- **位置**：`src/ndarray/real_ops.mbt:72-79`
- **描述**：`max_(x)` 对空数组越界（依赖 `max_` 的 bug）。
- **建议**：空数组时 raise，或修复 `max_` 后此处自动安全。

#### [一般] _enumerate_slice_def step == 0 时除以零

- **位置**：`src/ndarray/slicing.mbt:13-23`
- **描述**：当 `spec[2] == 0` 时，`step_abs = 0`，L22 `(diff + step_abs) / step_abs` 除以 0，L23 `start + i * step` 产生无效索引。
- **建议**：检查 `step == 0` 并 raise。

#### [一般] copy_row_to / copy_col_to / row / rows 不校验 ind 越界

- **位置**：`src/ndarray/extra.mbt:14-24, 28-39`，`src/ndarray/matrix.mbt:15-22, 26-36`
- **描述**：这些函数不检查 `ind` 是否在有效行/列范围内，越界时静默写入错误位置或越界崩溃。
- **建议**：添加范围检查。

#### [一般] draw 函数不校验 axis 越界

- **位置**：`src/ndarray/extra.mbt:117-134`
- **描述**：`draw(x, count, axis)` 不检查 `axis < x.shape.length()`，越界时 L120 `dims[axis]` 崩溃。
- **建议**：添加 axis 范围检查。

#### [一般] split 不校验 parts 总和与 dims[axis] 一致

- **位置**：`src/ndarray/extra.mbt:91-112`
- **描述**：`split(x, parts, axis)` 不检查 `sum(parts) == x.shape[axis]`。当总和小于维度时，部分元素未被切片；大于时，`get_slice` 越界。
- **建议**：添加总和检查。

#### [一般] 多处 `#warnings("-unused_error_type")` 抑制了 raise 类型不完整警告

- **位置**：`src/ndarray/nn_conv.mbt:96, 259`，`src/ndarray/nn_backward.mbt:402, 1027, 1041, 1104, 1118`
- **描述**：7 处 `#warnings("-unused_error_type")` 抑制了 `raise` 声明但实际不 raise（或 raise 类型不完整）的警告。这掩盖了效果系统的不一致——函数签名声明 `raise` 但函数体可能不 raise，或反之。
- **建议**：审查每个函数的实际 raise 行为，移除不必要的 `raise` 声明或 `#warnings` 抑制，使效果系统与实际行为一致。

#### [一般] empty 函数语义误导

- **位置**：`src/ndarray/creation.mbt:78-81`
- **描述**：`empty(shape)` 实际创建全零数组（`FixedArray::make(n, 0.0)`），与"empty"语义（未初始化/不分配）不符，且与 `zeros` 行为完全相同，造成 API 冗余。
- **建议**：移除 `empty`（用 `zeros` 替代），或改为真正的未初始化分配（若 MoonBit 支持）。

#### [一般] init_flat 与 from_fn API 冗余

- **位置**：`src/ndarray/random_init.mbt:4-11`，`src/ndarray/creation.mbt:111-115`
- **描述**：`init_flat(shape, f)` 和 `from_fn(shape, f)` 功能完全相同（用 1D 索引初始化），仅实现略有差异（`init_flat` 用 `make`+循环，`from_fn` 用 `makei`）。公共 API 暴露两个功能相同的函数，增加维护负担和用户选择困难。
- **建议**：保留一个（建议 `from_fn`，名字更通用），废弃另一个。

#### [一般] sum_reduce 内部 keep_dims=true 但不 squeeze，结果形状不直观

- **位置**：`src/ndarray/extra.mbt:153-164`
- **描述**：`sum_reduce(x, axis=[0, 1])` 对 shape `[2, 3, 4]` 返回 shape `[1, 1, 4]`（保留被 reduce 的维度为 1），而非更直观的 `[4]`。无文档说明此行为。
- **建议**：在文档中明确说明保留 keep_dims 语义，或提供 `keep_dims?` 参数让用户选择。

#### [轻微] init_nd 每次迭代分配 nd_idx 数组

- **位置**：`src/ndarray/creation.mbt:122-130`
- **描述**：`init_nd` 的 `FixedArray::makei` 回调中，每次迭代 `let nd_idx = Array::make(shape.length(), 0)`（L123）都分配新数组。对于大数组，这是 O(n * nd) 的分配开销。
- **建议**：将 `nd_idx` 提到循环外，在回调中复用并重置。但需注意 `f(nd_idx)` 可能持有 nd_idx 引用，需在文档中说明调用者不应持有。

#### [轻微] to_string nD 情况忽略 max_row / max_col 参数

- **位置**：`src/ndarray/extra.mbt:246-262`
- **描述**：`to_string` 仅 1D 和 2D 路径处理 `max_row`/`max_col` 截断，nD 路径（L246-262）忽略这些参数，大数组打印时可能产生超长字符串。
- **建议**：nD 路径也支持截断，或至少在文档中说明 nD 不支持。

#### [轻微] draw 每次调用创建新 RNG，不可复现

- **位置**：`src/ndarray/extra.mbt:121`
- **描述**：`draw` 内部 `let rng = @random.Rand::chacha8()` 每次调用创建新 RNG（无种子），结果不可复现，不利于测试和调试。
- **建议**：接受可选 `rng` 参数，或接受种子参数。

#### [轻微] clip_by_l2norm 当 l2 == 0 且 clip_norm >= 0 时返回原数组（含全零），但 l2 == 0 且 clip_norm < 0 时除以零

- **位置**：`src/ndarray/real_ops.mbt:39-46`
- **描述**：当 `l2 == 0.0` 且 `clip_norm < 0.0` 时，`l2 > clip_norm` 为 true，执行 `mul_scalar(x, clip_norm / l2)` 除以 0。虽然 `clip_norm < 0` 本身不合理，但无检查。
- **建议**：检查 `clip_norm >= 0`，或 `l2 == 0` 时直接返回原数组。

#### [轻微] _format_double 不区分 +0.0 和 -0.0

- **位置**：`src/ndarray/extra.mbt:168-189`
- **描述**：`if v == 0.0` 在 IEEE 754 中 `-0.0 == 0.0` 为 true，所以 `-0.0` 被格式化为 `"0"`。这在调试时可能丢失符号信息。
- **建议**：若需区分，用 `1.0 / v == -inf` 检测 `-0.0`。

#### [轻微] 广播路径中 ind_a / ind_b 每次迭代重计算（已复用数组，但可进一步优化）

- **位置**：`src/ndarray/arithmetic.mbt:57-62`
- **描述**：`_broadcasted_op` 已复用 `ind_a`/`ind_b` 数组避免分配，但每次迭代仍遍历所有维度设置 `ind_a[i]`/`ind_b[i]`。对于高维数组，这是 O(nd) 每元素的开销。可考虑沿广播维度增量更新索引，但实现复杂度较高。
- **建议**：低维（nd <= 4）保持现状；高维可考虑增量索引优化。当前实现正确性无问题，仅性能可改进。

### 本轮统计

| 严重程度 | 数量 |
|---------|------|
| 严重 | 7 |
| 一般 | 18 |
| 轻微 | 6 |

### 总评

src/ndarray/ 包作为项目最大的模块（~5000 行），整体架构清晰、文件职责划分合理，核心索引计算（`calc_strides`/`flat_index`/`next_index`/`get_broadcasted_dims`/`reduce_params`）实现正确，广播逻辑正确，快速路径（1D/2D get、同形状算术、i-p-j matmul、1D softmax）覆盖得当，原地操作 API 设计良好，测试覆盖面广（95 个测试全部通过）。

但存在 **7 个严重问题**，其中最关键的是 **conv2d/conv3d 及其 backward_input 的 kernel 索引计算 bug**（缺少 `out_channel` 因子）：当 `out_channel > 1` 时卷积结果完全错误。此 bug 被现有测试遗漏（所有卷积测试均用 `out_channel == 1`），经独立验证已确认。其余严重问题集中在空数组/零窗口的除零和越界。

一般问题主要是**系统性的边界检查缺失**：大量函数（`from_data`/`of_array`/`of_arrays`/`get`/`set`/`map_elem2`/`dot`/`concatenate`/`stack`/`tile`/`transpose`/`conv2d` 等）不校验形状/维度/索引一致性，依赖调用者保证正确性，违反"快速失败"原则。建议系统性补充前置检查，至少在 debug 构建中加断言。

MoonBit 惯用法方面，`raise`/`OwlError` 使用基本一致，但 7 处 `#warnings("-unused_error_type")` 表明效果系统存在不一致，应审查并修正。`Ndarray` struct 字段公开暴露破坏封装，建议收紧可见性。

测试质量方面，覆盖面广但存在盲区：卷积/pooling 仅测试 `out_channel == 1`，未暴露索引 bug；空数组、形状不一致、axis 越界等边界用例缺失。建议补充 `out_channel > 1` 的卷积测试和系统性的边界/异常测试。
