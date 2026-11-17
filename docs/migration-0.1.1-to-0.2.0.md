# owl-mbt 0.1.1 → 0.2.0 迁移指南

0.2.0 是一次性的布局与类型规整版本。按 [SemVer](https://semver.org/) 的 0.x 阶段规则（`0.y.z` 为初始开发期，公共 API 尚不稳定，`y` 位升级允许包含不兼容变化），本版本包含**破坏性变更**。本文给出全部变化与逐步迁移方案。**0.2.0 之后 API 将进入稳定期**，后续小版本升级不再出现本文所列类别的变更。

## 一、包布局变化（影响所有下游）

0.2.0 将源码从 `src/` 前缀迁移到模块根目录（扁平多根包布局），并合并了 `types` + `const` 为零依赖 `core` 包。**所有包引用路径都要更新**：

| 0.1.1 旧路径 | 0.2.0 新路径 | 备注 |
|---|---|---|
| `walkzzz/owl_mbt/types` | `walkzzz/owl_mbt/core` | 合并 |
| `walkzzz/owl_mbt/const` | `walkzzz/owl_mbt/core` | 合并 |
| `walkzzz/owl_mbt/maths` | `walkzzz/owl_mbt/maths` | 同名平移 |
| `walkzzz/owl_mbt/stats` | `walkzzz/owl_mbt/stats` | 同名平移 |
| `walkzzz/owl_mbt/ndarray` | `walkzzz/owl_mbt/ndarray` | 同名平移 |
| `walkzzz/owl_mbt/linalg` | `walkzzz/owl_mbt/linalg` | 同名平移 |
| `walkzzz/owl_mbt/algodiff` | `walkzzz/owl_mbt/algodiff` | 同名平移 |
| `walkzzz/owl_mbt/optimise` | `walkzzz/owl_mbt/optimise` | 同名平移 |
| `walkzzz/owl_mbt/neural` | `walkzzz/owl_mbt/neural` | 同名平移 |
| `walkzzz/owl_mbt/compute` | `walkzzz/owl_mbt/compute` | 同名平移 |
| `walkzzz/owl_mbt/misc` | `walkzzz/owl_mbt/misc` | 同名平移 |
| `walkzzz/owl_mbt/examples/*` | `walkzzz/owl_mbt/examples/*` | 移至模块根 |

迁移操作：在各包 `moon.pkg` 的 `import` 块中把旧路径替换为新路径；`@types.Xxx` / `@const.Xxx` 引用统一改为 `@core.Xxx`（`core` 包吸收了原 `types` 的全部类型与 `const` 的全部常量，签名零变化）。

## 二、类型迁移：Int → Int32

约 150 处索引、形状、计数相关的参数与返回值从 `Int` 迁移为 `Int32`（`moon fmt` 亦会将 `Int` 规范化为 `Int32`）。受影响的典型 API 族：

- ndarray：`shape`/`get`/`set`/`reshape`/`zeros`/`ones`/`of_array` 等的形状与索引参数
- ndarray NN 族：`conv1d/2d/3d`、`dilated_conv*`、`transpose_conv*`、`max_pool*`、`avg_pool*` 及全部 `*_backward` 的 stride/kernel 参数
- stats：`hist_*`、`max_i`/`min_i`/`minmax_i`、`prng_init`、`uniform_int_rvs`、`central_moment`
- algodiff：`tag`/`make_forward`/`make_reverse`/`shape`/`get_slice`/`reshape` 等
- linalg：`lu` 的 `pivot` 返回值
- misc：`cms_*`、`DataFrame` 的 `num_rows`/`num_cols`/`get_int_data`、`Heap::new` 的比较函数返回值、`Stack::length`
- compute：`node_id`/`op_ones`/`op_zeros`/`op_reshape`/`get_node_shape`/`set_node_shape`/`infer_shape`
- optimise / neural：`init_state`、`stop_early`、`input`、`init_run`、`reshape` 等

迁移操作：调用点显式写 `Int32` 字面量或 `.to_int32()` 类转换；MoonBit 的整数字面量按上下文重载，多数 `1` / `0` 无需改动，仅需修正类型注解。

## 三、可选参数语法变化（约 30 个函数）

MoonBit 工具链升级后，可选参数从 `x? : T = 默认值` 语法迁移为 `x~ : T = 默认值`，**调用点写法随之变化**：

```
0.1.1：let y = @ndarray.pad(x, 1, mode=@core.Padding::Same)
0.2.0：let y = @ndarray.pad(x, 1, mode~=@core.Padding::Same)
```

受影响函数族（调用点需要改为 `~` 传参）：ndarray 的 `approx_equal` 族、`bernoulli`、`clip_by_value`、`concatenate`、`diag`、`expand`、`gaussian`、`log_sum_exp`、`max`、`min`、`pad`、`scan`/`scani`、`sequential`、`softmax`、`squeeze`、`stack`、`sum` 族、`to_string`；linalg 的 `chol`、`qr`、`rank`；algodiff 的 `concatenate`、`softmax`、`sum`；neural 的 `add_node`、`linear`、`linear_nobias`。

迁移操作：`f(a=1)` → `f(a~1)` 或 `f(a~value)`（MoonBit 新语法，`~` 后直接跟值，带标签时写 `a~1`）。

## 四、包引用迁移：@types → @core

所有原 `@types.` 前缀的类型引用改为 `@core.`：

| 0.1.1 | 0.2.0 |
|---|---|
| `@types.Number` / `@types.Index` / `@types.Padding` / `@types.DeviceType` | `@core.Number` / `@core.Index` / `@core.Padding` / `@core.DeviceType` |
| `@types.OwlError::InvalidArgument(...)` | `@core.OwlError::InvalidArgument(...)` |
| `@const.pi` / `@const.e` 等 17 个常量 | `@core.pi` / `@core.e` 等（签名零变化） |

## 五、raise 声明变化

**新增 raise（11 个，ndarray）**：`draw`、`fold`、`foldi`、`get_slice`、`repeat`、`split`、`sum`、`sum_reduce`、`tile`、`transpose`、`upsampling2d`。这些函数补齐了边界校验（axis 越界、形状不一致等现在显式抛 `OwlError::InvalidArgument`），调用点若处于 `noraise` 上下文需要加 `catch` 处理。

**移除 raise（2 个）**：`maths::dawsn` 与 `ndarray::dawsn`——原为 `NotImplemented` 占位，0.2.0 已实现真实算法，不再抛错。调用点的 `try` 包裹可以移除。

## 六、其他语义增强（非破坏，但行为可感知）

- `neural::run_neuron` 新增可选参数 `train~ : Bool = false`：Dropout 层在训练模式执行 inverted dropout，推理模式直通（默认推理，已有代码行为不变）
- 新增 `ndarray.fft`/`ifft`、`linalg.svd`、`maths.gamma/log_gamma/beta/j0/j1` 等纯新增 API（不迁移）

## 七、快速迁移 Checklist

1. `moon.pkg` 全部 `import` 路径按第一节映射表替换
2. 全局替换 `@types.` → `@core.`、`@const.` → `@core.`
3. 编译后按报错逐个修正 `?` → `~` 传参写法（第三节清单）
4. 编译后按报错修正 `Int`/`Int32` 类型注解（第二节清单）
5. 对第五节 11 个新增 raise 的函数，检查调用点错误处理
6. `moon check --deny-warn` 通过后跑 `moon test` 确认

## 八、版本策略说明

`0.1.1 → 0.2.0` 的破坏性变更符合 SemVer 0.x 阶段规则。自 0.2.0 起，本项目承诺：**次版本升级不再引入包路径变化与参数语法变化**；仅新增 API 或收窄错误行为（新边界校验会提前在 CHANGELOG 的 Breaking Changes 段预告）。
