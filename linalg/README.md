# linalg

线性代数：LU / Cholesky / SVD 分解、行列式、求逆与线性求解。

[← 返回总览](../README.md)

## 安装

```bash
moon add walkzzz/owl_mbt@0.3.1
```

```moonbit
// moon.pkg
import {
  "walkzzz/owl_mbt/linalg" as @linalg,
  "walkzzz/owl_mbt/ndarray" as @ndarray
}
```

## 主要接口

| 接口 | 说明 |
|---|---|
| `det(x)` | 行列式 |
| `inv(x)` | 求逆 |
| `lu(x)` | LU 分解，返回 `(L, U, perm)` |
| `chol(x, upper?)` | Cholesky 分解 |
| `svd(x)` | SVD，返回 `(U, S, V)` |
| `linsolve_lu(a, b)` | 用 LU 求解 `Ax = b` |
| `is_symmetric` / `is_diag` / `is_triangular` | 矩阵性质判定 |

## 示例

```moonbit
let a = @ndarray.of_arrays([[1.0, 2.0], [3.0, 4.0]])

let d = @linalg.det(a)          // -2.0
let inv_a = @linalg.inv(a)
let (l, u, perm) = @linalg.lu(a)
let (u_mat, s, v) = @linalg.svd(a)
```

求解：

```moonbit
let b = @ndarray.of_arrays([[5.0], [11.0]])
let x = @linalg.linsolve_lu(a, b)
```

## 行为说明

- 奇异矩阵的 `det`/`inv`/`lu` 可能抛 `OwlError`，调用前可先用 `is_diag` 等做形状检查。
- 数值容差与基准见 `docs/benchmark.md`；32×32 求逆、16×16 SVD 有性能基线。
- 输入统一为 `Ndarray`（二维矩阵），不做自动展平。

## 相关

- [接口契约](./pkg.generated.mbti)
- [N 维数组](../ndarray/README.md)
- [基准报告](../docs/benchmark.md)