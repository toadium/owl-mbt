# algodiff

自动微分：正向 / 反向模式、标量与数组梯度、算子与构建器。

[← 返回总览](../README.md)

## 安装

```bash
moon add walkzzz/owl_mbt@0.3.1
```

```moonbit
// moon.pkg
import {
  "walkzzz/owl_mbt/algodiff" as @algodiff,
  "walkzzz/owl_mbt/ndarray" as @ndarray
}
```

## 主要接口

| 接口 | 说明 |
|---|---|
| `grad(f, x)` | 标量函数梯度（支持嵌套） |
| `grad_prime(f, x)` | 同时返回函数值与梯度 |
| `diff(f, x)` | 标量求导 |
| `diff_prime(f, x)` | 返回函数值与导数 |
| `pack_arr(x)` / `pack_flt(x)` | 包装成可微节点 |
| `unpack_arr(t)` / `unpack_flt(t)` | 取回底层数组 / 标量 |
| `add` / `mul` / `div` / `matmul` / `sin` / `exp` 等 | 可微算子 |
| `sum_(t)` / `mean_(t)` | 归约算子 |

## 示例

```moonbit
let f = fn(x : @algodiff.T) -> @algodiff.T raise {
  @algodiff.sum_(@algodiff.mul(x, x))
}

let x = @algodiff.pack_arr(@ndarray.of_array([1.0, 2.0], [2]))
let g = @algodiff.grad(f, x)
let g_arr = @algodiff.unpack_arr(g)
// g_arr.data = [2.0, 4.0]
```

## 行为说明

- 梯度类型 `T` 统一承载标量与 `Ndarray`，通过 `pack_*` / `unpack_*` 进出边界。
- 反向模式基于 tape；`grad` 内部可嵌套以获得高阶导。
- 未注册的可微操作会抛 `OwlError`，新增算子需同步导数规则。

## 相关

- [接口契约](./pkg.generated.mbti)
- [神经网络](../neural/README.md)
- [优化器](../optimise/README.md)