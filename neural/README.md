# neural

神经网络：激活函数、神经元/网络构造、前向与反向传播。

[← 返回总览](../README.md)

## 安装

```bash
moon add walkzzz/owl_mbt@0.3.1
```

```moonbit
// moon.pkg
import {
  "walkzzz/owl_mbt/neural" as @neural,
  "walkzzz/owl_mbt/algodiff" as @algodiff
}
```

## 主要接口

| 接口 | 说明 |
|---|---|
| `act_relu` / `act_sigmoid` / `act_tanh` / `act_softmax(axis)` | 激活函数 |
| `act_leaky_relu(slope)` / `act_elu` / `act_softplus` | 变体激活 |
| `neuron_input` / `neuron_linear` | 输入神经元 / 线性神经元 |
| `add_node(network, inputs, node, act_typ?)` | 向网络添加节点 |
| `forward(network, x)` | 前向传播，返回输出与缓存 |
| `backward(network, dy)` | 反向传播，返回参数梯度 |
| `collect_output(nodes)` | 汇总输出 |
| `init_network` / `update_network` / `get_network` | 初始化与参数更新 |

## 示例

```moonbit
let relu = @neural.act_relu()
let softmax = @neural.act_softmax(0)
```

前向/反向（示意）：

```moonbit
let (y, cache) = @neural.forward(net, x)
let (grads, _) = @neural.backward(net, dy)
@neural.update_network(net, grads)
```

## 行为说明

- 网络由 `Node` 图组织，`add_node` 自动完成形状推导并抛 `OwlError` 报告不匹配。
- 前向缓存用于反向传播；`train=false` 时可跳过缓存。
- 完整可运行示例见 `examples/neural_demo`。

## 相关

- [接口契约](./pkg.generated.mbti)
- [自动微分](../algodiff/README.md)
- [优化器](../optimise/README.md)
- [代码示例](../examples/neural_demo/main.mbt)