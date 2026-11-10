///|
/// owl-mbt — Owl 科学计算库的纯 MoonBit 移植
///
/// 提供 N 维数组、线性代数、自动微分、神经网络、优化算法、统计分布等核心功能。
/// 无 C FFI 依赖，支持 Native/Wasm/JS 三后端。
///
/// ## 快速开始
///
/// ```moonbit
/// let arr = @ndarray.arange(0.0, 10.0, 1.0)
/// let mat = @ndarray.zeros([3, 3])
/// let result = @linalg.inv(mat)
/// ```
///
/// ## 包结构
///
/// | 包 | 功能 |
/// |---|------|
/// | `@core` | 类型定义 + 数学常量（零依赖） |
/// | `@maths` | 基础与特殊数学函数 |
/// | `@stats` | 统计与概率分布 |
/// | `@ndarray` | N 维数组核心数据结构 |
/// | `@linalg` | 线性代数（LU/Chol/QR/inv/det） |
/// | `@algodiff` | 自动微分（前向+反向模式） |
/// | `@optimise` | 优化算法 |
/// | `@neural` | 神经网络层 |
/// | `@compute` | 计算图 DAG |
/// | `@misc` | 辅助工具（DataFrame/Heap/Stack） |
