# 执行报告（v1）

## 执行概述
修复 19 处 `unused_value` warning，涉及 7 个文件。

## 修复清单

| 文件 | Warning类别 | 修改内容 |
|------|------------|---------|
| src/algodiff/ops_arr_ext.mbt | unused_value | 第 93 行函数参数 `full_slice` 改为 `_full_slice`（私有函数参数，不宜删除签名） |
| src/algodiff/ops_arr_ext.mbt | unused_value | 第 112 行 match 模式 `F(v)` 改为 `F(_)` |
| src/algodiff/ops_piso.mbt | unused_value | 第 123 行闭包参数 `cp` 改为 `_cp` |
| src/algodiff/ops_piso.mbt | unused_value | 第 124 行闭包参数 `cp` 改为 `_cp` |
| src/algodiff/ops_piso.mbt | unused_value | 第 149 行闭包参数 `cp` 改为 `_cp` |
| src/algodiff/ops_piso_ext.mbt | unused_value | 第 21 行闭包参数 `a` 改为 `_a` |
| src/algodiff/ops_piso_ext.mbt | unused_value | 第 22 行闭包参数 `b` 改为 `_b` |
| src/ndarray/core.mbt | unused_value | 删除未使用的私有函数 `get_broadcasted_index`（含注释） |
| src/ndarray/nn_backward.mbt | unused_value | 第 181 行删除未使用变量绑定 `let in_channel = input_shp[3]` |
| src/ndarray/nn_backward.mbt | unused_value | 第 414 行删除未使用变量绑定 `let in_channel = input_shp[4]` |
| src/ndarray/nn_backward.mbt | unused_value | 第 1049 行删除未使用变量绑定 `let kernel_cols = kernel_shp[0]` |
| src/ndarray/nn_backward.mbt | unused_value | 第 1050 行删除未使用变量绑定 `let kernel_rows = kernel_shp[1]` |
| src/ndarray/nn_backward.mbt | unused_value | 第 1051 行删除未使用变量绑定 `let in_channel = kernel_shp[2]` |
| src/ndarray/nn_backward.mbt | unused_value | 第 1052 行删除未使用变量绑定 `let out_channel = kernel_shp[3]`；并连带删除已失去引用的 `let kernel_shp = kernel.shape`（避免引入新 warning） |
| src/ndarray/nn_conv.mbt | unused_value | 第 126 行删除未使用变量绑定 `let k_stride = kernel_cols * kernel_rows * in_channel` |
| src/optimise/modules.mbt | unused_value | 第 106 行 pub fn 参数 `f` 改为 `_f`（保留签名位置，不破坏公共 API） |
| src/optimise/modules.mbt | unused_value | 第 107 行 pub fn 参数 `w` 改为 `_w`（保留签名位置，不破坏公共 API） |
| src/optimise/modules.mbt | unused_value | 第 195 行 match 模式 `Value(a, b)` 改为 `Value(_, _)` |

## 修复统计
计划修复数：19 | 实际修复数：19 | 未能修复数：0

## 未修复说明

全部修复。

## 编译验证
通过。`moon check`：0 errors，217 warnings（由 236 降至 217，`unused_value` 计数降为 0）。`moon test`：Total tests: 397, passed: 397, failed: 0。

## 风险评估
低风险。变更均为局部变量绑定删除、闭包参数弃元、match 模式弃元或未使用私有函数删除，不影响函数签名与公共 API。其中 `nn_backward.mbt` 第 1048 行 `kernel_shp` 的连带删除属于修复引入的立即修正（删除 1049-1052 行后该绑定失去引用，不删会新增 unused warning）。`optimise/modules.mbt` 的 `run_gradient` 为 pub fn，仅将参数名改为 `_` 前缀以抑制 warning，参数位置与类型不变，不影响调用方。
