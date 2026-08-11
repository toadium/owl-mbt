# R3: 自动微分与优化模块审查 — src/algodiff/ 和 src/optimise/

审查时间：2026-08-11 07:30

### 审查范围

- `src/algodiff/types.mbt`
- `src/algodiff/creation.mbt`
- `src/algodiff/builder.mbt`
- `src/algodiff/api.mbt`
- `src/algodiff/ops_siso.mbt`
- `src/algodiff/ops_siso_ext.mbt`
- `src/algodiff/ops_piso.mbt`
- `src/algodiff/ops_piso_ext.mbt`
- `src/algodiff/ops_arr.mbt`
- `src/algodiff/ops_arr2.mbt`
- `src/algodiff/ops_arr_ext.mbt`
- `src/algodiff/reverse.mbt`
- `src/algodiff/algodiff_test.mbt`
- `src/optimise/types.mbt`
- `src/optimise/core.mbt`
- `src/optimise/modules.mbt`
- `src/optimise/optimise_test.mbt`
- `src/optimise/optimise_wbtest.mbt`

### 发现

#### [严重] sigmoid 标量前向公式与导数公式不匹配，AD 结果错误

- **位置**：`src/algodiff/ops_siso.mbt:172-182`
- **描述**：标量前向分支使用 `1.0 / (1.0 + @math.ln(-v))`（忠实移植 OCaml 的疑似 bug），但前向导数 `df` 与反向导数 `dr` 都使用标准 sigmoid 的导数公式 `cp * (1 - cp)`。设 `s(x) = 1/(1+ln(-x))`，则 `s'(x) = 1/(x*(1+ln(-x))^2)`，而非 `s(x)*(1-s(x))`。当前实现对 `x>0` 会产生 NaN（`ln(-x)`），对 `x<0` 导数与前向不匹配，梯度计算错误。数组分支 `@ndarray.sigmoid` 同样使用错误公式（经 `@maths.sigmoid`），与前向一致但导数仍不匹配。
- **建议**：将前向公式修正为标准 sigmoid `1.0 / (1.0 + @math.exp(-v))`，使前向与导数一致。若需保留 OCaml 忠实移植行为，应同步修正导数公式为 `s'(x) = 1/(x*(1+ln(-x))^2)`，并在文档中明确标注。当前状态会导致使用 sigmoid 的梯度下降给出错误方向。

#### [严重] sum 沿 axis 的反向传播忽略 axis 参数，梯度形状/数值错误

- **位置**：`src/algodiff/ops_arr.mbt:46-70`
- **描述**：`sum(x, axis=..., keep_dims=...)` 的 DR 分支捕获了 `captured_axis` 和 `captured_keep_dims`，但在 adjoint 闭包中用 `let _ = captured_axis` 和 `let _ = captured_keep_dims` 显式丢弃。adjoint 使用 `ones(captured_x.shape) * ca.val`，当 `axis != -1` 时 `ca` 的形状（降维后）与 `captured_x` 的形状不同，`mul` 会产生形状错误或数值错误。例如 `sum(x, axis=0)` 对 `[2,2]` 数组结果为 `[2]`，梯度应将 `[2]` 广播回 `[2,2]`，但当前代码尝试 `[2,2] ones * [2] ca`。
- **建议**：在 adjoint 中根据 `captured_axis` 和 `captured_keep_dims` 将 `ca.val` 沿对应 axis 广播回 `captured_x` 的形状，再乘以 ones。可利用 `@ndarray` 的 broadcast/expand 功能。同时补充 `axis != -1` 的梯度数值验证测试。

#### [严重] concatenate 反向传播只处理第一个输入，其余输入梯度丢失

- **位置**：`src/algodiff/ops_arr2.mbt:76-101`
- **描述**：concatenate 的 DR 分支 adjoint 闭包实现为 `_prepend((ca.val, captured_arrs[0]), t)`，只将梯度 `ca.val` 赋给 `captured_arrs[0]`，其余输入数组的梯度完全丢失。正确行为应沿 `captured_axis` 将 `ca.val` 分割成 `arrs.length()` 段，每段对应一个输入的梯度。此外 `register` 用 `result.push(a)` 而非 `_prepend`，将 parents 追加到末尾而非前部，与 SISO/PISO 的 `_prepend` 约定不一致。
- **建议**：adjoint 应调用 `@ndarray.split(ca.val, axis=captured_axis, sections=arrs.length())` 或等价逻辑，为每个输入生成对应的梯度对 `(grad_i, captured_arrs[i])`，全部 prepend 到 `t`。同时 `register` 应使用 `_prepend` 或确保遍历顺序一致。

#### [严重] concatenate 的 DF 分支对非 DF 结果将 tag 硬编码为 0

- **位置**：`src/algodiff/ops_arr2.mbt:56-75`
- **描述**：DF 分支中 `match cp { DF(_, _, ai) => DF(cp, ct, ai) ; _ => DF(cp, ct, 0) }`。`cp` 是 `concatenate(primal_arrs, axis~)` 的结果，`primal_arrs` 元素是各 DF 的 primal（可能是 F/Arr/DF/DR）。当 `cp` 不是 DF 时，tag 被设为 0，与全局 tag 计数器脱节，后续 tag 比较逻辑（`cmp_tag`）会错误判断节点层级，导致前向传播结果错误或 "forward and reverse clash" 误报。
- **建议**：应从原始 `arrs` 中提取有效 tag（如 `arrs[0]` 的 tag），或在 concatenate 入口统一提取 tag。不应硬编码为 0。

#### [严重] 大量反向传播测试使用空断言，未验证梯度正确性

- **位置**：`src/algodiff/algodiff_test.mbt` 多处：508-517, 531-540, 554-563, 576-585, 599-608, 623-636, 746-752, 755-762, 774-781, 793-800, 812-819, 969-979, 1003-1012
- **描述**：至少 13 个反向传播测试计算了 `adjval(x)` 但用 `let _ = unpack_arr(adjval(x))` 丢弃，随后 `@test.assert_eq(true, true)`。这些测试只验证代码不崩溃，完全没有验证梯度数值正确性。涉及 transpose、reshape、flatten、softmax、matmul、sigmoid、tanh、softplus、softsign、concatenate、get_slice 等关键操作。结合上述 sum/concatenate/sigmoid 的 bug，这些空断言测试是 bug 未被发现的主要原因。
- **建议**：每个反向传播测试应与数值梯度（有限差分）或已知解析梯度对比。建议添加通用 `num_grad(f, x, eps)` 工具函数，对每个 op 进行 `|analytic_grad - num_grad| < tol` 断言。

#### [一般] is_arr 函数命名与语义相反，误导调用者

- **位置**：`src/algodiff/types.mbt:140-147`
- **描述**：`is_arr` 对 `Arr(_)` 返回 `false`，对 `F(_)` 返回 `true`，与函数名语义相反。注释说明 "OCaml source has is_arr with swapped logic, faithfully ported as-is"。虽然忠实移植，但此命名会误导任何根据名称假设行为的调用者，且与 `is_float`（`F` 返回 true）形成混乱的对照。
- **建议**：要么修正逻辑使 `is_arr` 对 `Arr` 返回 true（并修正所有调用点），要么重命名为 `is_scalar` / `is_not_arr` 以匹配实际行为。当前 `is_float` 和 `is_arr` 都对 `F` 返回 true，语义重叠且 `is_arr` 名不副实。

#### [一般] run_clipping 完全未实现，所有裁剪类型直接返回原值

- **位置**：`src/optimise/modules.mbt:192-199`
- **描述**：`run_clipping` 对 `L2norm(_)`、`Value(_, _)`、`None` 三个分支全部返回 `x`，没有任何裁剪逻辑。`L2norm(c)` 应将梯度范数裁剪到 `c`，`Value(min, max)` 应逐元素裁剪到 `[min, max]`。API 暴露了 `clip_l2norm` / `clip_value` 构造器，用户会误以为裁剪生效。
- **建议**：实现 `L2norm` 裁剪：计算梯度 L2 范数 `norm`，若 `norm > c` 则缩放为 `x * (c / norm)`。实现 `Value` 裁剪：逐元素 `max(min, min(max, x))`。若暂不实现，应在文档和类型上标注 `NotImplemented`。

#### [一般] run_stopping 的 Early 分支未实现

- **位置**：`src/optimise/modules.mbt:202-208`
- **描述**：`Stopping::Early(i, j)` 应实现早停：若连续 `j` 轮迭代损失未改善超过阈值 `i` 则停止。当前直接返回 `false`，早停功能完全不工作。
- **建议**：实现早停逻辑，需要在 `State` 中维护历史损失记录和最佳损失值，`run_stopping` 需要访问 state 而非仅当前 loss。可能需要调整 `run_stopping` 签名。

#### [一般] minimise_fun 在 stop 触发后仍执行参数更新，返回过更新的 x

- **位置**：`src/optimise/core.mbt:20-57`
- **描述**：循环中 `state.stop = run_stopping(params.stopping, loss_flt)` 设置 stop 后，循环体继续执行：计算 `g_clipped`、`p_new`、`rate`、`u_new`，并更新 `x_ref.val = primal_(add(xi, u_new))`。这意味着当 stopping 条件满足时，返回的 `x_ref.val` 是 stop 之后再更新一步的值，而非 stop 时的最优点。
- **建议**：在 `state.stop = run_stopping(...)` 后立即检查 `if state.stop { break }`，避免额外更新。或将更新逻辑放在 stop 检查之后。

#### [一般] Adam 学习率公式分母多余项，与标准 Adam 不一致

- **位置**：`src/optimise/modules.mbt:43-65`
- **描述**：Adam 分母实现为 `(sqrt(c[1]) + 1e-8) * (g + 1e-32)`，多乘了一个 `(g + 1e-32)` 项。标准 Adam 公式为 `lr = a * sqrt(1-b2^t) / (1-b1^t) * m / (sqrt(v) + eps)`，分母只有 `sqrt(v) + eps`。当前实现等价于多除了一个 `g`（当前梯度），且 `c[1]`（二阶矩 v）未做偏差修正。这会导致学习率随梯度幅度反常缩放，梯度大时学习率反小。
- **建议**：移除分母中的 `(g + 1e-32)` 项。若忠实移植 OCaml 源码的 bug，应明确注释说明。建议对照 OCaml 源码确认是否为移植笔误。

#### [一般] hessian 通过嵌套 AD 实现，正确性不可靠

- **位置**：`src/algodiff/api.mbt:127-130`
- **描述**：`hessian(f, x) = jacobian(g, x)` 其中 `g(x) = grad(f, x)`。`grad` 内部调用 `make_reverse`、`reverse_reset`、`reverse_push`，修改全局 `_global_tag` 和节点内部的 `Ref` 状态。`jacobian` 又会创建新的 AD 节点并调用 `grad`。嵌套 AD 中内层 `grad` 会修改外层正在使用的节点的 adjoint 引用，导致状态混乱。测试用 `try-catch` 包裹且只检查 `h_arr.data[0] == 2.0`，未验证完整 Hessian 矩阵。
- **建议**：嵌套 AD 需要独立的 tag 空间和节点状态隔离。可考虑为 `grad` 等函数增加 `tag_offset` 参数，或使用前向模式计算 Hessian（避免嵌套反向）。至少应在文档中标注 `hessian` 为实验性功能。

#### [一般] copy_primal_ 对嵌套 AD 节点不递归取 primal

- **位置**：`src/algodiff/creation.mbt:21-27`
- **描述**：`copy_primal_` 使用 `match primal(x)`（只取一层），`_` 分支返回 `primal(x)` 即原节点引用，未复制。对于嵌套节点如 `DF(DR(...), ...)`，`primal(x)` 返回 `DR(...)`，`_` 分支直接返回该 DR 引用而非深拷贝。这违反了 "copy" 的语义，调用者修改返回值会影响原节点的子节点。
- **建议**：使用 `primal_(x)`（递归取 primal）代替 `primal(x)`，并对 Arr 分支确保深拷贝（当前已用 `@ndarray.copy`，正确）。

#### [一般] get_slice 的 set_slice 辅助函数对 DF/DR 节点直接返回原值

- **位置**：`src/algodiff/ops_arr_ext.mbt:92-106`
- **描述**：`set_slice` 对 `F(_)` 返回 `val`，对 `Arr(arr)` 构造零数组并设置切片，对 `_`（DF/DR）直接返回 `val`。在 `get_slice` 的反向传播中，`ca.val` 是 adjoint 值，通常是 F 或 Arr（primal 类型），所以 `_` 分支可能不会触发。但如果 `ca.val` 是 DR 节点（嵌套 AD 场景），直接返回会丢失切片设置逻辑。
- **建议**：移除 `_` 分支或改为 `raise InvalidArgument`，因为 set_slice 只应处理 primal 类型。当前静默返回可能掩盖错误。

#### [一般] reverse_reset / reverse_push 多次调用状态不一致

- **位置**：`src/algodiff/reverse.mbt:4-48`
- **描述**：`reverse_reset` 累加 `af` 和 `tracker`，`reverse_push` 递减它们。若用户不通过 `reverse_prop` 而单独多次调用 `reverse_push`（不重置），`af` 会变为负数，`af == 0` 永远不成立，adjoint 不会传播，梯度计算静默失败。同理，多次 `reverse_reset` 会使 `af` 翻倍。API 没有防护或文档警告。
- **建议**：在 `reverse_push` 入口检查 `af >= 0`，或在 `reverse_reset` 中重置 `af` 和 `tracker` 到已知状态（而非累加）。文档应明确 `reverse_reset` + `reverse_push` 必须配对使用。

#### [一般] jacobian_prime 假设输入输出为 2D 行向量，维度处理脆弱

- **位置**：`src/algodiff/api.mbt:88-116`
- **描述**：`m = if y_shape.length() >= 2 { y_shape[1] } else { 1 }`，`n = if x_shape.length() >= 2 { x_shape[1] } else { 1 }`。假设输入输出至少 2D 且取 `shape[1]` 作为有效维度。对 1D 输入 `m=1, n=1`，对 3D+ 输入只取第二维，忽略更高维度。`jacobianv` / `jacobianTv` 内部构造 `[1, n]` 或 `[1, m]` 的单位向量，对非行向量形状会出错。
- **建议**：明确文档说明 `jacobian` 仅支持行向量（shape `[1, n]`）输入输出，或扩展为通用形状。对不支持的形状应 raise `InvalidArgument` 而非静默用 `shape[1]`。

#### [一般] minimise_fun 首次循环重复计算梯度，浪费一次 grad_prime 调用

- **位置**：`src/optimise/core.mbt:13-22`
- **描述**：循环外 `let (loss0, g0) = @algodiff.grad_prime(optz_fun, x)` 计算初始梯度和损失。循环内第一次迭代 `xi = x_ref.val`（仍为初始 x），再次 `grad_prime(optz_fun, xi)` 计算同一个点的梯度。对于复杂目标函数，`grad_prime` 涉及完整的前向+反向传播，重复计算是显著浪费。
- **建议**：循环内首次迭代直接使用 `loss0` 和 `g0`，或移除循环外的预计算，在循环内统一处理。

#### [一般] State 结构固定 1x1xN 嵌套数组，不支持 batch 和多参数

- **位置**：`src/optimise/core.mbt:14-17`、`src/optimise/types.mbt:71-83`
- **描述**：`minimise_fun` 初始化 `state.gs = [[g0]]`、`state.ps = [[...]]`、`state.us = [[...]]`、`state.ch = [[[..., ...]]]`，固定为 1 batch × 1 param 的单元素嵌套结构。`Params.batch` 字段支持 `Full`/`Mini`/`Sample`/`Stochastic`，但 `minimise_fun` 硬编码 `init_state(1, params.epochs)`（batches_per_epoch=1），完全忽略 `params.batch`。多参数场景下 `state.gs[0][0]` 只能存一个梯度。
- **建议**：根据 `params.batch` 计算 `batches_per_epoch`，根据参数数量初始化对应大小的嵌套数组。当前应至少在文档中说明仅支持单参数 Full batch。

#### [轻微] piso_op 函数参数过多（14 个），可读性差

- **位置**：`src/algodiff/builder.mbt:62-77`
- **描述**：`piso_op` 有 14 个参数，包括 4 个前向函数、3 个前向导数函数、3 个反向导数函数和 3 个上下文参数。调用时参数对齐困难，新增 op 时容易填错位置。
- **建议**：将前向、前向导数、反向导数函数分组为 struct，如 `FwdFns`、`DfFns`、`DrFns`，减少参数数量并增加可读性。

#### [轻微] 闭包捕获冗余赋值

- **位置**：`src/algodiff/builder.mbt:41-42, 203-205, 231-233, 254-256` 等多处
- **描述**：模式如 `let captured_a = a ; let captured_dr = dr` 后在闭包中使用 `captured_a` / `captured_dr`。MoonBit 闭包可直接捕获外层变量 `a` / `dr`，无需重命名。这是 OCaml 移植习惯，在 MoonBit 中冗余。
- **建议**：移除 `let captured_x = x` 等冗余赋值，闭包内直接使用原变量名。

#### [轻微] relu 和 abs 在 x=0 处导数定义为 0，未文档化

- **位置**：`src/algodiff/ops_siso.mbt:186-204`（relu）、`src/algodiff/ops_siso.mbt:17-27`（abs）
- **描述**：`relu` 通过 `is_positive`（`v > 0.0`）判断，x=0 时导数为 0。`abs` 通过 `signum`，signum(0)=0，导数为 0。这是合理的次梯度选择，但未在文档中说明。用户可能期望 x=0 处导数为 1 或 0.5。
- **建议**：在 `relu` / `abs` 的文档注释中说明 x=0 处导数选择为 0。

#### [轻微] _global_tag 全局可变状态无线程安全保证

- **位置**：`src/algodiff/types.mbt:25-38`
- **描述**：`_global_tag` 是全局 `Ref[Int]`，`tag()` 递增并返回。多次 AD 计算交错会使 tag 持续增长，`reset_tag` 可重置但用户需手动调用。若忘记 `reset_tag`，tag 可能溢出（虽然 Int 范围很大）。MoonBit 当前无并发，但未来扩展时这是隐患。
- **建议**：在 `grad` / `diff` / `jacobian` 等顶层 API 内部自动 `reset_tag`，或使用局部 tag 计数器替代全局。

### 本轮统计

| 严重程度 | 数量 |
|---------|------|
| 严重 | 5 |
| 一般 | 11 |
| 轻微 | 5 |

### 总评

algodiff 模块整体架构清晰，忠实移植了 Owl 的 AD 设计：F/Arr/DF/DR 四态类型、SISO/PISO 分派 helper、tag 层级比较、fanout/tracker 反向传播调度。前向模式 AD（DF）的核心逻辑正确，单输入单输出和双输入单输出的链式法则实现无误。反向模式 AD（DR）的调度机制（reverse_reset/reverse_push 的 fanout 计数与 tracker 守卫）逻辑正确，能处理 DAG 共享节点。

但存在 5 个严重问题：(1) sigmoid 前向公式与导数不匹配，梯度方向错误；(2) sum 沿 axis 的反向传播完全忽略 axis 参数；(3) concatenate 反向传播只处理第一个输入，其余梯度丢失；(4) concatenate DF 分支 tag 硬编码为 0；(5) 大量反向传播测试使用 `assert_eq(true, true)` 空断言，未验证梯度数值。这 5 个问题中前 3 个是核心算法 bug，会导致用户得到错误梯度；后 2 个是工程质量问题，是 bug 未被发现的原因。建议优先修复 sigmoid/sum/concatenate 的反向传播，并补充数值梯度验证测试。

optimise 模块实现了 GD/CG/CD/NonlinearCG/DaiYuanCG 等梯度方法和 Adagrad/Decay/ExpDecay/RMSprop/Adam/Schedule 学习率策略，基础 GD 收敛测试通过。但 run_clipping 完全未实现（所有类型 no-op），run_stopping 的 Early 未实现，Adam 学习率公式分母有多余项，minimise_fun 在 stop 后仍更新参数，且忽略 params.batch 硬编码 Full batch。这些是功能完整性问题，当前仅适合单参数 Full batch 的简单 GD 优化场景。
