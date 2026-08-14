# 项目申报书：owl-mbt

## 项目名称

owl-mbt — Owl 科学计算库的纯 MoonBit 移植

## 项目类型

T2 移植项目：将 OCaml 科学计算库 [Owl](https://github.com/owlbarn/owl) 的 `owl-base` 包移植到 MoonBit。

## 项目概述

Owl 是 OCaml 生态中最重要的科学计算库之一，提供 N 维数组、线性代数、自动微分、神经网络、优化等核心功能。本项目将其纯 OCaml 部分（`owl-base`，34,326 行）移植到 MoonBit，实现完全无 C FFI 的纯后端方案，支持 Native/Wasm/JS 三后端。

## 项目现有基础

已完成全部 10 个阶段的移植：

| 模块 | 功能 | 状态 |
|------|------|------|
| types + const | 类型定义与数学常量 | ✅ |
| maths | 基础与特殊数学函数 | ✅ |
| stats | 统计与概率分布 | ✅ |
| ndarray | N 维数组核心数据结构 | ✅ |
| linalg | 线性代数（LU/Chol/QR/inv/det） | ✅ |
| algodiff | 自动微分（前向+反向模式） | ✅ |
| optimise | 优化算法 | ✅ |
| neural | 神经网络层 | ✅ |
| compute | 计算图 DAG | ✅ |
| misc | 辅助工具（DataFrame/Heap/Stack 等） | ✅ |

- **代码规模**：14,801 行 MoonBit 代码，79 个源文件
- **测试**：497 个，全部通过
- **编译**：0 error，0 warning
- **代码审查**：6 轮审查，141 个问题已全部修复

## 技术路线

1. 以 `owl-base` 纯 OCaml 源码为蓝本，逐模块翻译为 MoonBit
2. 自行实现 strided N 维数组替代 OCaml Bigarray（最大技术难点）
3. 用 MoonBit checked errors 替代 OCaml 异常
4. 用 `Ref[T]` 替代 OCaml `ref`
5. 纯 MoonBit 实现所有数学运算，无 C FFI 依赖
6. 每阶段完成后编写测试并运行 `moon check` + `moon test` 验证

## 预期目标

- [x] 完整移植 owl-base 全部 10 个模块
- [x] 497 个测试全部通过
- [x] 0 编译错误，0 warning
- [x] 3 个可运行示例
- [x] CI 持续集成配置
- [x] 发布至 mooncakes.io

## 原项目信息

- **原项目名称**：Owl
- **原项目链接**：https://github.com/owlbarn/owl
- **原项目许可证**：LGPL-2.1+
- **移植范围**：`owl-base` 包（纯 OCaml 部分），不含 C FFI 绑定层
- **修改说明**：详见 README.md "修改与适配" 章节
- **未移植功能**：SVD、高级特殊函数、BLAS/LAPACK 完整接口、稀疏矩阵、FFT，详见 README.md "尚未移植或暂不支持的功能" 章节

## 对 MoonBit 生态的价值

1. **填补科学计算空白**：MoonBit 生态目前无科学计算库，本项目提供了 Ndarray/线性代数/自动微分/神经网络等核心功能
2. **验证 MoonBit 能力**：14,768 行纯 MoonBit 代码证明了该语言处理复杂数值计算的能力
3. **多后端兼容**：纯实现支持 Native/Wasm/JS，无需平台特定优化
4. **可扩展基础**：为后续 ML/科学计算生态提供基础构件
