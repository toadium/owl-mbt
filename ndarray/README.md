# ndarray

N 维数组：创建、算术、广播、切片、矩阵乘法、转置、FFT 与 CNN 算子。

[← 返回总览](../README.md)

## 安装

```bash
moon add walkzzz/owl_mbt@0.3.1
```

```moonbit
// moon.pkg
import {
  "walkzzz/owl_mbt/ndarray" as @ndarray
}
```

## 主要接口

| 接口 | 说明 |
|---|---|
| `of_array(data, shape)` / `of_arrays(rows)` | 由一维数据或行数组构造 |
| `zeros(shape)` / `ones(shape)` / `eye(n)` | 零矩阵 / 全 1 / 单位阵 |
| `shape(x)` / `reshape(x, shape)` | 形状查询与重排 |
| `get(x, idx)` / `set(x, idx, v)` | 元素读写（越界抛错） |
| `add` / `sub` / `mul` / `div` 及 `_scalar` 版本 | 逐元素算术与就地版本 |
| `dot(a, b)` | 矩阵乘法 |
| `transpose(x)` | 转置 |
| `sum` / `mean` / `max` / `min`（axis? / keep_dims?） | 归约 |
| `fft(x)` | 快速傅里叶变换，返回实部/虚部 |
| `max_pool1d/2d/3d` 等 | CNN 池化算子 |

## 示例

```moonbit
let a = @ndarray.of_array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [2, 3])
let b = @ndarray.ones([2, 3])

let c = @ndarray.add(a, b)
let at = @ndarray.transpose(a)          // [3, 2]
let s = @ndarray.sum(a)                 // 21.0

println(@ndarray.to_string(c))
```

矩阵乘法：

```moonbit
let m = @ndarray.eye(3)
let p = @ndarray.dot(m, a)              // 单位阵 * a = a
```

## 行为说明

- 形状不一致的逐元素运算抛 `OwlError`；广播规则有限，混用前先对齐 shape。
- 多数算子提供 `_inplace` 变体，会修改输入，注意别名共享。
- CNN 池化/卷积为纯 MoonBit 实现，不含 C FFI。

## 相关

- [接口契约](./pkg.generated.mbti)
- [线性代数](../linalg/README.md)
- [自动微分](../algodiff/README.md)