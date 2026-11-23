# core

基础类型与常量：`OwlError`、CNN 填充类型、数学常量。

[← 返回总览](../README.md)

## 安装

```bash
moon add walkzzz/owl_mbt@0.3.1
```

```moonbit
// moon.pkg
import {
  "walkzzz/owl_mbt/core" as @core
}
```

## 主要接口

| 名称 | 说明 |
|---|---|
| `OwlError` | 全库统一错误（`suberror`），数值错误通过它抛出 |
| `Padding` | CNN 池化/卷积填充方式 |
| `pi` / `pi_2` / `pi_4` | π 及其倍数 |
| `e` / `euler` | 自然常数 |
| `eps` | 双精度机器 epsilon |
| `max_float64` / `min_float64` | 浮点边界 |
| `sqrt2` / `sqrtpi` | 常用常量 |

## 示例

```moonbit
let area = @core.pi * 2.0 * 2.0
let tiny = @core.eps

// 统一错误类型
fn safe_div(a : Double, b : Double) -> Double raise @core.OwlError {
  if b == 0.0 {
    raise @core.OwlError("division by zero")
  }
  a / b
}
```

## 行为说明

- core 不依赖任何业务包，是依赖图的根。
- 数值算法统一使用 `Double`（f64），不提供精度可配置的泛型容器。
- 错误信息为 `String`，调用方可用 `catch` 统一处理。

## 相关

- [接口契约](./pkg.generated.mbti)
- [架构与包结构](../AGENTS.md)
- [质量评估](../docs/assessment.md)