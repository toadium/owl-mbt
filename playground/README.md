# playground

浏览器演示导出层：把数值内核编译成约 12 KB 的自包含 WasmGC 模块。

[← 返回总览](../README.md)

## 用途

GitHub Pages 的在线演示由本包提供。它只导出 **f64 → f64 纯函数**，避免跨语言
字符串/数组 ABI；页面直接 `WebAssembly.instantiate` 后调用，全部计算在浏览器内完成。

## 导出函数

| 导出名 | 说明 |
|---|---|
| `owl_dot4(a0..a3, b0..b3)` | 4 维点积 |
| `owl_det2(a, b, c, d)` | 2×2 行列式 |
| `owl_mean4(a..d)` | 4 样本均值 |
| `owl_var4(a..d)` | 4 样本方差（总体） |
| `owl_gamma(x)` | Gamma 函数 |
| `owl_j0(x)` | 第一类 Bessel J₀ |
| `owl_erf(x)` | 误差函数 |
| `owl_kde_pdf(x, v0..v3)` | 高斯核密度（带宽 0.5） |

## 构建

```bash
moon build --target wasm-gc --release playground
```

产物：

```text
_build/wasm-gc/release/build/playground/playground.wasm
```

`scripts/check_pages.mjs` 会重新构建并复制到 `docs/playground.wasm`，同时验证
8 个导出与数值一致性。

## 示例（浏览器）

```js
const { instance } = await WebAssembly.instantiateStreaming(
  fetch("./playground.wasm"),
  {},
);
const dot = instance.exports.owl_dot4(1, 2, 3, 4, 4, 3, 2, 1); // 20
const g = instance.exports.owl_gamma(5);                      // 24
```

## 约束

- 只允许 `f64` 参数与返回值；不要新增字符串/数组跨语言 ABI。
- 模块必须零 import（自包含）；新增导出需同步页面、`check_pages.mjs` 与 README。
- WasmGC 需要 Chrome 119+ / Firefox 120+ / Safari 18+；Node 侧验证需 Node 22+。
- 数值结果必须与 native 一致（同一份 MoonBit 源码）。

## 相关

- [接口契约](./pkg.generated.mbti)
- [展示页门禁](../scripts/check_pages.mjs)
- [在线演示](https://toadium.github.io/owl-mbt/)