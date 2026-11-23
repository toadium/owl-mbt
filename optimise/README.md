# optimise

优化器：学习率策略、动量、正则化、梯度裁剪与通用最小化入口。

[← 返回总览](../README.md)

## 安装

```bash
moon add walkzzz/owl_mbt@0.3.1
```

```moonbit
// moon.pkg
import {
  "walkzzz/owl_mbt/optimise" as @optimise
}
```

## 主要接口

| 接口 | 说明 |
|---|---|
| `lr_const(lr)` / `lr_decay(lr, k)` / `lr_exp_decay` | 学习率策略 |
| `lr_adam(a, b1, b2)` / `lr_adagrad(lr)` / `lr_rmsprop` | 自适应学习率 |
| `mom_none` / `mom_standard(m)` / `mom_nesterov(m)` | 动量 |
| `reg_none` / `reg_l1norm` / `reg_l2norm` / `reg_elastic_net` | 正则化 |
| `clip_none` / `clip_value(lo, hi)` / `clip_l2norm(max_norm)` | 梯度裁剪 |
| `stop_none` / `stop_early(patience, delta)` / `stop_const` | 停止条件 |
| `default_params()` / `Params::set_learning_rate` / `set_epochs` | 参数配置 |
| `minimise_fun(params, f, x)` | 通用最小化 |

## 示例

```moonbit
let params = @optimise.default_params()
params.set_learning_rate(@optimise.lr_adam(0.001, 0.9, 0.999))
params.set_epochs(100.0)

let (state, x_min) = @optimise.minimise_fun(params, loss, x0)
```

## 行为说明

- `minimise_fun` 返回最终状态与最优参数；失败时抛 `OwlError`。
- 学习率、动量、正则化均为不可变配置值，组合后交给 `Params`。
- 停止条件与优化器可独立配置（提前停止、固定步数）。

## 相关

- [接口契约](./pkg.generated.mbti)
- [神经网络](../neural/README.md)
- [自动微分](../algodiff/README.md)