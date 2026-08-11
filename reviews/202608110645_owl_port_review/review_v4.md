# R4: 神经网络与计算图模块审查 — src/neural/ 和 src/compute/

审查时间：2026-08-11

### 审查范围

- `src/neural/types.mbt`
- `src/neural/neuron.mbt`
- `src/neural/graph.mbt`
- `src/neural/neural_test.mbt`
- `src/compute/types.mbt`
- `src/compute/constructors.mbt`
- `src/compute/graph.mbt`
- `src/compute/eval.mbt`
- `src/compute/shape.mbt`
- `src/compute/compute_test.mbt`
- `src/compute/compute_wbtest.mbt`

### 发现

#### [严重] `collect_ancestors` 拓扑排序算法在菱形依赖下产生错误顺序

- **位置**：`src/compute/graph.mbt:153-176`
- **描述**：`collect_ancestors` 使用栈做 DFS，在节点出栈时立即将其加入 `result`，最后反转 `result` 作为拓扑序。这并非真正的后序 DFS。对于菱形依赖 `A -> B, A -> C, B -> D, C -> D`，从 D 开始遍历：`result = [D, C, A, B]`，反转后得到 `[B, A, C, D]`。此时 B 排在 A 之前，但 A 是 B 的父节点，违反拓扑序。正确顺序应为 `[A, B, C, D]` 或 `[A, C, B, D]`。`eval_graph` 依赖此顺序求值，菱形依赖下会在父节点未求值时调用 `get_node_value` 触发 `abort`。
- **建议**：改用递归后序 DFS（在所有父节点处理完后才将当前节点加入 `result`），或使用 Kahn 算法（基于入度的 BFS 拓扑排序）。示例：
  ```moonbit
  fn _dfs(n : Node, visited : Array[Bool], result : Array[Node]) -> Unit {
    let nid = n.id.val
    if visited[nid] { return }
    visited[nid] = true
    for p in n.prev.val { _dfs(p, visited, result) }
    result.push(n) // 后序：父节点全部处理后才加入
  }
  ```

#### [严重] `get_network` 隐含副作用污染 Network.outputs 字段

- **位置**：`src/neural/graph.mbt:96-99`
- **描述**：`get_network(n)` 每次调用都执行 `n.network.val.outputs.val = [n]`，将网络输出覆盖为当前节点。在链式构建 `linear(x, 3)` → `activation(h, ...)` → `linear(a, 1)` 中，每次调用都会覆盖 `outputs`，最终 `outputs` 仅包含最后调用 `get_network` 的节点，而非真正的输出层。虽然 `forward`/`backward` 不使用 `outputs`（改用 `topo` 末元素），但公共 API `get_outputs(nn)` 返回错误结果，且副作用使函数语义不可预测。
- **建议**：`get_network` 应为纯查询函数，不应修改任何状态。若需设置输出节点，应提供独立的 `set_output` API 或在 `add_node` 中维护。改为：
  ```moonbit
  pub fn get_network(n : Node) -> Network {
    n.network.val
  }
  ```

#### [严重] `run` 假设单输入单输出，多输入/多输出网络会出错

- **位置**：`src/neural/graph.mbt:207-221`
- **描述**：`run` 中 `Input(_) => [x]` 将所有 `Input` 节点绑定到同一个输入 `x`。若网络有多个不同形状的输入节点（如双分支网络），所有输入会被替换为同一个值，导致形状不匹配或语义错误。此外，`sink = nn.topo.val[nn.topo.val.length() - 1]` 取拓扑末元素作为输出，假设网络只有一个输出；多输出网络只返回其中一个。
- **建议**：支持多输入应改为 `run(inputs : Array[@algodiff.T], nn : Network)`，按节点匹配输入；支持多输出应返回 `Array[@algodiff.T]` 或由用户指定输出节点。至少应在文档中明确限制单输入单输出。

#### [严重] `_min_scalar` 对 AD 节点直接返回，HardSigmoid/Relu6 反向梯度错误

- **位置**：`src/neural/neuron.mbt:84-105`
- **描述**：`_min_scalar` 对 `F(v)` 和 `Arr(arr)` 正确处理，但对 `DF`/`DR`（AD 节点）走 `_ => x` 分支直接返回，不应用 `min` 操作。`_hard_sigmoid` 和 `_relu6` 内部调用 `_min_scalar`，当输入是反向模式 AD 节点（`mktag_network` 后的 `DR` 节点）时，`min` 操作被跳过，前向值和反向梯度均不正确。这使得 `HardSigmoid` 和 `Relu6` 激活函数在训练中产生错误梯度。
- **建议**：应先取 `primal_(x)` 获取底层数值，应用 `min` 后重新包装。若 `min` 不可微，至少应正确计算前向值并使用次梯度（subgradient）。需要与 algodiff 模块协作，可能需要新增 `min_scalar` 的可微实现。

#### [严重] `connect_pair` 使用节点名称去重，名称冲突时连接丢失

- **位置**：`src/neural/graph.mbt:114-132`
- **描述**：`connect_pair` 通过 `_contains_node(next.prev.val, prev.name.val)` 判断是否已连接，依赖节点名称唯一性。但 `make_node` 自动生成名称时使用 `network.size.val`，若手动调用 `make_node` 或 `size` 计数不同步，可能产生重名节点，导致本应建立的连接被跳过。名称是字符串比较，效率也低于引用相等。
- **建议**：使用节点引用相等（`is`）或唯一 ID（如 `id : Ref[Int]`）去重，而非名称字符串比较。

#### [一般] `Dropout` 层未实现，前向传播直接返回输入

- **位置**：`src/neural/neuron.mbt:324`（`Dropout(_) => input[0]`）
- **描述**：`run_neuron` 中 `Dropout` 直接返回输入，未实现训练时的随机置零和推理时的缩放。`dropout_create` 保存了 `rate` 但从未使用。测试 `scenario: dropout in training mode` 仅验证输出形状，未验证 dropout 实际效果，掩盖了此问题。
- **建议**：训练模式下按 `rate` 生成伯努利掩码并缩放（inverted dropout），推理模式下直接返回。需访问 `Node.train` 字段判断模式。

#### [一般] `eval_node` 大量操作为 passthrough，功能未实现

- **位置**：`src/compute/eval.mbt:26-31, 102-109, 122-153`
- **描述**：大量 Op（`Tile`, `Repeat`, `Concatenate`, `Stack`, `Split`, `Draw`, `OneHot`, `ScalarPow`, `PowScalar`, `AddScalar`–`ScalarDiv`, `EltEqualScalar`–`EltGreaterEqualScalar`, 所有 `Conv`/`Pool`/`UpSampling`, `RowNum`, `ColNum`, `Row`, `Rows`, `CopyRowTo`, `CopyColTo`, `Inv`, `Trace`, `ToRows`, `OfRows`, `FusedAdagrad`）直接返回 `inputs[0]`，未实现实际计算。白盒测试仅调用 `_eval1`/`_eval2` 不检查结果，掩盖了此问题。
- **建议**：对每个 passthrough op 实现实际语义，或对暂未实现的 op 使用 `raise` 抛出 `NotImplemented` 异常，避免静默返回错误结果。

#### [一般] `Min`/`Max`/`Sum` 忽略 `(Bool, Int)` 轴参数

- **位置**：`src/compute/eval.mbt:56-58`
- **描述**：`Min(_, _) => @ndarray.min(inputs[0])`、`Max`、`Sum` 同理，忽略 `Bool`（是否沿轴 reduce）和 `Int`（轴索引）参数，始终做全局 reduce。`SumReduce` 同样直接调用 `@ndarray.sum` 忽略轴数组。
- **建议**：根据 `Bool` 和 `Int` 参数调用对应的沿轴 reduce 函数（如 `@ndarray.sum_axis(inputs[0], axis)`）。

#### [一般] `_infer_shape_concatenate` 形状推断错误

- **位置**：`src/compute/shape.mbt:164-175`
- **描述**：`Concatenate(axis)` 应沿指定轴合并所有输入的对应维度，但 `_infer_shape_concatenate` 仅返回 `input_shapes[0][0]`（第一个输入的形状），未合并任何维度。与 `eval_node` 中 `Concatenate(_) => inputs[0]` 的 passthrough 一致，但形状推断应独立正确。
- **建议**：遍历所有输入形状，沿 `axis` 累加维度，其余维度保持一致。

#### [一般] `backward` 假设标量输出，数组输出初始梯度错误

- **位置**：`src/neural/graph.mbt:234-240`
- **描述**：`backward` 调用 `@algodiff.reverse_prop(@algodiff.pack_flt(1.0), y)`，使用标量 `1.0` 作为初始 adjoint。当 `y` 是数组（如 `Arr`）时，`reverse_prop` 的初始梯度 `v` 应为与 `y` 同形状的全 1 数组，而非标量。标量与数组相加在 `reverse_push` 的 `aa.val = add(aa.val, v)` 中可能形状不匹配或语义错误。
- **建议**：根据 `y` 的形状生成全 1 数组作为初始 adjoint：
  ```moonbit
  let init_grad = match @algodiff.shape(y) {
    [] => @algodiff.pack_flt(1.0)
    s => @algodiff.pack_arr(@ndarray.ones(s))
  }
  @algodiff.reverse_prop(init_grad, y)
  ```

#### [一般] `connect`（compute）不去重，重复连接导致冗余计算

- **位置**：`src/compute/graph.mbt:81-84`
- **描述**：`connect(parent, child)` 无条件 push，多次调用 `connect(p, c)` 会添加重复边。`collect_ancestors` 有 `visited` 去重避免重复访问，但 `eval_graph` 中 `Array::makei(n.prev.val.length(), ...)` 会因重复 prev 产生冗余输入数组，且 `eval_node` 对 `Add` 等二元操作只取 `inputs[0]` 和 `inputs[1]`，重复输入可能导致错误。
- **建议**：在 `connect` 中检查是否已存在相同父节点（引用相等），或提供 `connect_unique` 变体。

#### [一般] `connect`（neural）对 `Linear`/`LinearNoBias` 的 in_shape 仅取一维

- **位置**：`src/neural/neuron.mbt:207-208`
- **描述**：`Linear(l) => l.in_shape.val = [out_shapes[0][0]]` 只取父节点输出形状的第一个维度。若前一层输出是多维（如经过 `Reshape` 到 2D 后接 `Linear`），会丢失维度信息，`init_neuron` 中 `m = l.in_shape.val[0]` 仅用一维初始化权重，导致 `matmul` 形状不匹配。
- **建议**：应保留完整输出形状，或在 `Linear` 创建时明确限制输入必须为 1D/2D 并做断言。

#### [一般] `linear_create` 初始化权重为 `[0, 0]` 形状，忘记 `init_network` 会静默错误

- **位置**：`src/neural/neuron.mbt:113-121`
- **描述**：`linear_create` 将 `w` 和 `b` 初始化为 `@ndarray.zeros([0, 0])`，实际形状在 `init_neuron` 中根据 `in_shape`/`out_shape` 重新分配。若用户忘记调用 `init_network(nn)`，`run` 时 `matmul(input, w)` 会因 `[0,0]` 形状产生空数组或形状不匹配，错误信息不直观。
- **建议**：在 `run` 或 `forward` 入口检查权重形状是否已正确初始化，或文档中强调必须先调用 `init_network`。

#### [一般] `calc_fans` 对 1D 和高维（>=6）数组使用 sqrt(prod) 启发式

- **位置**：`src/neural/neuron.mbt:11-30`
- **描述**：`calc_fans` 对 `length == 1`（1D 权重）和 `length >= 6` 走 else 分支，返回 `(sqrt(prod), sqrt(prod))`。1D 权重通常不应出现于 Linear 层，但若误传会得到不合理的 fan_in/fan_out。高维权重（如卷积核 4D/5D）有明确的 receptive field 计算（已处理 3-5D），但 >=6D 缺乏合理依据。
- **建议**：对 1D 输入抛出异常或警告；对 >=6D 文档说明退化策略或拒绝。

#### [一般] `make_node` 自动命名使用 `network.size.val`，与 `add_node` 计数可能不同步

- **位置**：`src/neural/graph.mbt:42-67`
- **描述**：`make_node` 在 `name == ""` 时生成 `"{to_name}_{network.size.val}"`，但 `size` 仅在 `add_node` 中递增。若直接调用 `make_node`（不经 `add_node`）或多次调用，可能生成重名节点，与 `connect_pair` 的名称去重冲突。
- **建议**：使用独立的全局计数器或 `network` 内部单调计数器生成唯一名称，不依赖 `size`。

#### [轻微] `_array_prod` 在 neural 和 compute 两个包中重复定义

- **位置**：`src/neural/neuron.mbt:2-8` 和 `src/compute/eval.mbt:165-171`
- **描述**：两个包各自定义了相同的私有 `_array_prod` 函数，代码重复。
- **建议**：提取到公共工具模块（如 `misc`）或 `types` 包中复用。

#### [轻微] `collect_output` 和 `get_node_value` 使用 `abort` 而非 `raise`

- **位置**：`src/neural/graph.mbt:107`、`src/compute/graph.mbt:129`
- **描述**：节点无输出/无值时调用 `abort`，直接终止程序，无法被调用者捕获处理。MoonBit 惯用法建议用 `raise` 抛出可恢复异常。
- **建议**：改为 `raise @types.OwlError::InvalidArgument("...")`，或在返回类型中使用 `Option`/`Result`。

#### [轻微] `_reverse` 直接访问 `Ndarray.data` 字段，破坏封装

- **位置**：`src/compute/eval.mbt:174-179`
- **描述**：`_reverse` 通过 `x.data[n - 1 - i]` 直接访问 `Ndarray` 的内部 `data` 字段。虽然 `Ndarray` 的 `data` 是 `pub` 可见，但直接访问绕过了 stride/shape 逻辑，若未来 `Ndarray` 内部表示改变（如非连续存储）会出错。
- **建议**：使用 `@ndarray` 提供的公共 API（如 `get`/`set`/`map_elem`）实现 reverse，或在 `ndarray` 中新增 `reverse` 函数。

#### [轻微] 测试断言不精确，`v < 0.001` 允许负值

- **位置**：`src/neural/neural_test.mbt:148-150`
- **描述**：`neural_run_activation_relu` 测试 `run_activation(pack_flt(-1.0), act_relu())`，断言 `v < 0.001`。ReLU(-1.0) 应为 0.0，但 `v < 0.001` 允许 v 为任意负数或小于 0.001 的正值，不精确。`neural_run_activation_sigmoid` 的 `(v - 1.0).abs() < 0.01` 也有类似宽松（sigmoid(-1) ≈ 0.269，非 1.0）。
- **建议**：使用精确断言 `@test.assert_eq(0.0, v)` 或 `v.abs() < 1e-10`；sigmoid(-1.0) 应断言 `(v - 0.2689).abs() < 1e-4`。

#### [轻微] 白盒测试仅验证长度/不抛异常，缺乏数值正确性验证

- **位置**：`src/compute/compute_wbtest.mbt:34-238`
- **描述**：大量白盒测试（`wb eval_node *` 系列）仅调用 `eval_node` 后 `@test.assert_eq(true, true)`，验证分支覆盖但不验证计算结果。例如 `wb eval_node binary ops` 对 `Add`/`Sub`/`Mul`/`Div` 不检查实际数值，即使实现错误也不会被发现。
- **建议**：对每个 op 验证具体输出值，至少对关键操作（Add, Mul, Exp, Sigmoid 等）断言数值结果。

#### [轻微] `#warnings("-unused_constructor")` 抑制可能掩盖未使用代码

- **位置**：`src/neural/types.mbt:112`、`src/compute/types.mbt:11`
- **描述**：`Neuron` 和 `Op` enum 上方的 `#warnings("-unused_constructor")` 抑制未使用构造函数警告。虽然 enum 的完整性需要保留所有变体，但这也可能掩盖真正未使用或已废弃的变体。
- **建议**：定期审查 enum 变体使用情况，确认被抑制的警告都是预期的。

### 本轮统计

| 严重程度 | 数量 |
|---------|------|
| 严重 | 5 |
| 一般 | 9 |
| 轻微 | 6 |

### 总评

**src/neural/** 模块实现了基本的神经网络构建与前向/反向传播 API，链式构建（`input` → `linear` → `activation`）接口设计清晰，测试覆盖了多层网络、多种激活/初始化、梯度流等场景。但存在几个严重问题：(1) `get_network` 的隐含副作用使 `outputs` 字段不可靠；(2) `run`/`backward` 假设单输入单输出和标量输出，限制了网络拓扑；(3) `_min_scalar` 对 AD 节点直接返回，导致 `HardSigmoid`/`Relu6` 梯度错误；(4) `connect_pair` 用名称去重不可靠。`Dropout` 未实现也是明显功能缺失。

**src/compute/** 模块定义了完整的 Op enum（130+ 变体）和计算图结构，但实现层面问题较多：(1) **`collect_ancestors` 拓扑排序算法在菱形依赖下产生错误顺序**，这是最严重的问题，会导致 `eval_graph` 在多分支汇聚时崩溃；(2) `eval_node` 大量 op 为 passthrough，功能未实现；(3) `Min`/`Max`/`Sum` 忽略轴参数；(4) `_infer_shape_concatenate` 形状推断错误。白盒测试虽覆盖了分支但缺乏数值验证，未能发现这些问题。

**建议优先修复**：`collect_ancestors` 拓扑排序算法（影响所有计算图求值）、`_min_scalar` AD 处理（影响梯度正确性）、`get_network` 副作用（影响 API 语义）。整体而言，两个模块的 API 设计和测试结构合理，但实现完整性和正确性仍有较大改进空间。
