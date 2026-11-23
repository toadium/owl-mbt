# compute

计算图：节点/形状推导、图求值与输出获取。

[← 返回总览](../README.md)

## 安装

```bash
moon add walkzzz/owl_mbt@0.3.1
```

```moonbit
// moon.pkg
import {
  "walkzzz/owl_mbt/compute" as @compute
}
```

## 主要接口

| 接口 | 说明 |
|---|---|
| `connect(a, b)` | 建立节点依赖 |
| `get_nodes(graph)` / `get_inputs(graph)` / `get_outputs(graph)` | 图结构查询 |
| `get_node_shape(node)` | 形状推导（未决为 `None`） |
| `get_node_value(node)` | 读取节点值 |
| `eval_graph(graph)` | 就地求值全部节点 |
| `eval_outputs(graph)` | 求值并返回输出数组 |

## 示例

```moonbit
// graph 由算子在构造阶段自动登记
@compute.eval_graph(graph)

let outputs = @compute.eval_outputs(graph)
let shapes = @compute.get_node_shape(output_node)
```

## 行为说明

- 计算图是惰性的：构造只记录结构，`eval_*` 才执行。
- 形状不完整或依赖成环时抛 `OwlError`。
- 张量运算实际复用 `ndarray` / `linalg` / `algodiff` 的实现，不做第二套数值内核。

## 相关

- [接口契约](./pkg.generated.mbti)
- [N 维数组](../ndarray/README.md)
- [自动微分](../algodiff/README.md)