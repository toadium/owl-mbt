# R1: 基础层模块审查 — src/types/、src/const/、src/maths/、src/stats/

审查时间：2026-08-11

### 审查范围

- `src/types/types.mbt`、`src/types/moon.pkg`、`src/types/pkg.generated.mbti`
- `src/const/const.mbt`、`src/const/moon.pkg`、`src/const/pkg.generated.mbti`
- `src/maths/basic.mbt`、`src/maths/helpers.mbt`、`src/maths/special.mbt`、`src/maths/erf.mbt`、`src/maths/number_theory.mbt`、`src/maths/maths_test.mbt`、`src/maths/moon.pkg`、`src/maths/pkg.generated.mbti`
- `src/stats/descriptive.mbt`、`src/stats/dist.mbt`、`src/stats/prng.mbt`、`src/stats/sample.mbt`、`src/stats/quantile.mbt`、`src/stats/order.mbt`、`src/stats/histogram.mbt`、`src/stats/kde.mbt`、`src/stats/stats_test.mbt`、`src/stats/moon.pkg`、`src/stats/pkg.generated.mbti`

验证执行：`moon check`（无错误）、`moon test src/maths src/stats`（64 测试全部通过）、`moon info`（接口一致）、`moon fmt --check`（格式合规）。

### 发现

#### [严重] `min`/`max`/`minmax` 对空数组越界崩溃

- **位置**：`src/stats/order.mbt:160`、`src/stats/order.mbt:171`、`src/stats/order.mbt:182`
- **描述**：`min`、`max`、`minmax` 三个函数均以 `let mut result = x[0]` / `let mut mn = x[0]` 起始，对空数组会触发数组越界 panic。同文件中 `minmax_i`（第 126 行）已显式检查 `x.length() == 0` 并 `raise @types.OwlError::InvalidArgument("minmax_i: empty array")`，但 `min`/`max`/`minmax` 未做同等检查，行为不一致且存在崩溃风险。下游 `histogram.mbt` 的 `setup_uniform_binning`（第 76 行调用 `minmax`）、`kde.mbt` 的 `_build_points`（第 25 行调用 `minmax`）和 `gaussian_kde`（第 47 行间接通过 `interquartile`→`sort` 安全，但 `std(None, vs)` 在第 48 行对单元素数组返回 0.0，对空数组返回 NaN）均会被波及。
- **建议**：将 `min`/`max`/`minmax` 改为 `raise @types.OwlError`，在头部加入空数组检查；或在文档中显式声明前置条件并保留 unchecked 风格，但需与 `minmax_i` 保持一致。鉴于 `minmax_i` 已 raise，推荐统一 raise。

#### [严重] `is_pow2` 对 `Int::min` 返回 `true`

- **位置**：`src/maths/helpers.mbt:36`
- **描述**：`is_pow2(x) = x != 0 && (x & (x - 1)) == 0`。对 `x = -2147483648`（即 `Int::min`，二进制 `0x80000000`）：`x - 1 = 0x7FFFFFFF`（32 位回绕），`0x80000000 & 0x7FFFFFFF = 0`，故 `is_pow2(-2147483648)` 返回 `true`，数学上错误。负数均不应视为 2 的幂。OCaml 原版可能共享此缺陷，但移植时应修正。
- **建议**：增加非负检查：`x > 0 && (x & (x - 1)) == 0`。

#### [一般] `variance` 单元素数组行为偏离 OCaml

- **位置**：`src/stats/descriptive.mbt:33`
- **描述**：`let n = if l == 1.0 { 1.0 } else { l - 1.0 }`。单元素数组时分母取 1.0，返回 `0.0 / 1.0 = 0.0`。但样本方差 Bessel 校正分母为 `n-1`，单元素时应为 `0/0 = NaN`。这是对 OCaml 行为的静默修改，未在注释中说明，且与 `cov`（第 127 行用 `n` 作分母）的不一致叠加后，整体除法约定混乱。
- **建议**：若为忠实移植请在注释标注 OCaml 原版同样处理；若为 MoonBit 改动请说明理由，或直接沿用 `l - 1.0` 让单元素返回 NaN（与数学定义一致）。

#### [一般] `cov` 用 `n` 而 `variance` 用 `n-1` 作分母

- **位置**：`src/stats/descriptive.mbt:127` vs `src/stats/descriptive.mbt:33`
- **描述**：`cov` 第 127 行 `t / n0.to_double()` 用总体协方差（分母 n），而 `variance` 用样本方差（分母 n-1）。对同一数据 `cov(x, x)` 应等于 `variance(x)`，但当前实现下 `cov(x, x) = (n-1)/n * variance(x)`，破坏了自洽性。这是 OCaml owl-base 的已知不一致，忠实移植但应在文档中明确标注。
- **建议**：在 `cov` 文档注释中说明使用总体协方差（分母 n），与 `variance`（样本方差，分母 n-1）不同；或统一为同一种约定。

#### [一般] `quantile` 闭包对空数组返回 `0.0` 而非 raise

- **位置**：`src/stats/quantile.mbt:18`
- **描述**：`quantile` 返回的闭包中，`if n == 0 { 0.0 }` 对空数组返回 0.0。这掩盖了空数组错误，调用者可能将 0.0 误认为合法分位数。此外，`let index = p * (n - 1).to_double()` 在 `n == 0` 时计算 `p * -1`，虽不致命但逻辑顺序不直观——空数组检查应在最前。
- **建议**：将 `n == 0` 检查移到闭包首行并 `raise @types.OwlError::InvalidArgument("quantile: empty array")`，或在 `quantile` 外层就检查 `x.length() == 0`。

#### [一般] `gaussian_kde` 对常量数据除零

- **位置**：`src/stats/kde.mbt:49`
- **描述**：`let s = if sd_val < iqr / 0.34 { sd_val } else { iqr / 0.34 }`。当所有样本值相同时 `sd_val = 0` 且 `iqr = 0`，`s = 0`，进而 `h = 0`。后续 `_build_points` 中 `step = (b - a) / n_points`，`b = mn + 3*0 = mn`，`a = mn - 3*0 = mn`，`step = 0`，所有 points 相同；`_gaussian_kernel` 中 `u = (v - p) / 0` 产生 NaN/Inf，最终 pdf 全为 NaN。未对 `h == 0` 做防护。
- **建议**：在计算 `h` 后检查 `h <= 0.0` 时 `raise @types.OwlError::InvalidArgument("gaussian_kde: bandwidth is zero, data may be constant")`。

#### [一般] `erfc` 对大正 x 灾难性抵消

- **位置**：`src/maths/erf.mbt:22`
- **描述**：`erfc(x) = 1.0 - erf(x)`。对大正 x（如 x > 6），`erf(x)` 接近 1.0，`1.0 - erf(x)` 会损失几乎全部有效数字（如 `1.0 - 0.9999999999 = 1e-10` 仅剩 ~5 位精度）。数学上 `erfc(10) ≈ 2.0e-45`，但当前实现返回 `0.0`。`erfcx(x) = exp(x*x) * erfc(x)`（第 28 行）会进一步放大问题：`exp(100) * 0.0 = 0.0`，而精确值约 `0.0564`。这是 A&S 近似的固有局限，但 `erfc` 应至少在文档中标注精度范围。
- **建议**：在 `erfc`/`erfcx` 文档注释中标注"基于 A&S 7.1.26 近似，对 x > 6 精度严重下降；erfc 大 x 时返回 0.0，erfcx 大 x 时返回 0.0 而非 ~1/(x√π)"；或引入互补误差函数的高精度实现。

#### [一般] `std_gaussian_rvs` 与 `gaussian_rvs` 代码重复

- **位置**：`src/stats/dist.mbt:24` 与 `src/stats/dist.mbt:41`
- **描述**：`gaussian_rvs(mu, sigma)` 完全复制了 `std_gaussian_rvs` 的 Box-Muller 逻辑，仅末尾改为 `mu + sigma * z0`。两处独立维护 `_gauss_case`/`_gauss_z1` 缓存，若未来修改一处忘记另一处会产生不一致。
- **建议**：`gaussian_rvs(mu, sigma)` 直接实现为 `mu + sigma * std_gaussian_rvs()`，消除重复。当前重复的唯一理由是避免一次乘法和加法，但可读性损失大于性能收益。

#### [一般] `_binary_exp` 参数命名与语义不符

- **位置**：`src/maths/number_theory.mbt:8`
- **描述**：`_binary_exp(a, b, m, f, id)` 中 `a` 实际是指数、`b` 是底数（由 `powmod` 第 56 行调用 `_binary_exp(b, a % m, m, mulmod, 1)` 可知），但参数名 `a`/`b` 与数学惯例（底数 a、指数 b）相反，严重误导阅读。
- **建议**：重命名为 `_binary_exp(exp, base, m, f, id)` 或调换参数顺序为 `(base, exp, m, f, id)` 并同步更新 `powmod` 调用。

#### [一般] `normalise`/`normalise_density` 未防护零总计数

- **位置**：`src/stats/histogram.mbt:371`、`src/stats/histogram.mbt:391`
- **描述**：`normalise` 中 `total = h.counts.fold(...)`，若所有 `counts` 为 0（空数据集直方图），`total = 0`，`c.to_double() / 0.0 = NaN`。`normalise_density` 同理，且额外有 `h.bins[i+1] - h.bins[i]` 可能为 0（重复边界），再次除零。
- **建议**：检查 `total == 0` 时 raise 或返回原直方图；检查相邻 bin 边界相等时跳过或 raise。

#### [一般] `kendall_tau` 对 `n < 2` 除零

- **位置**：`src/stats/order.mbt:35`
- **描述**：`2.0 * (a - b) / (n * (n - 1.0))`。当 `n = 0` 或 `n = 1` 时分母为 0，返回 NaN 或 Inf。未做前置检查。
- **建议**：添加 `if x0.length() < 2 { raise @types.OwlError::InvalidArgument("kendall_tau: needs at least 2 elements") }`，或返回 0.0 并文档说明。

#### [一般] `exponential_rvs`/`gumbel1_rvs`/`gumbel2_rvs` 缺少参数校验

- **位置**：`src/stats/dist.mbt:65`、`src/stats/dist.mbt:149`、`src/stats/dist.mbt:156`
- **描述**：`exponential_rvs(lambda)` 当 `lambda = 0` 时 `-1.0 / 0.0 = -Inf`，后续 `* ln_1p(-u)` 产生 NaN。`gumbel1_rvs`/`gumbel2_rvs` 当 `x = 0.0`（`_rand.val.double()` 理论上可返回 0.0）时 `ln(0) = -Inf`，传播产生 Inf/NaN。均未校验。
- **建议**：对 `exponential_rvs` 校验 `lambda > 0.0`；对 `gumbel1_rvs`/`gumbel2_rvs` 用 `rand01_exclusive()` 替换 `_rand.val.double()` 以避开 0.0，或显式跳过 u=0 的样本。

#### [轻微] `Index` 类型缺少 `Eq` derive

- **位置**：`src/types/types.mbt:12`
- **描述**：`pub(all) enum Index { I(Int); L(Array[Int]); R(Array[Int]) } derive(Debug)` 仅 derive Debug。`Array[Int]` 在 MoonBit 标准库支持 `Eq`，可安全添加 `Eq`。其他同文件枚举（`Number`、`Padding`、`DeviceType`）均 derive `(Debug, Eq)`，`Index` 不一致。
- **建议**：改为 `derive(Debug, Eq)`。

#### [轻微] `is_subnormal` 硬编码 DBL_MIN 魔数

- **位置**：`src/maths/helpers.mbt:17`
- **描述**：`x.abs() < 2.2250738585072014e-308` 直接硬编码 `DBL_MIN`（最小 normal 正数）。魔数无命名，且若未来需要双精度平台移植会埋坑。注释已说明来源，但代码中仍是裸数字。
- **建议**：在 `src/const/const.mbt` 中新增 `pub let min_normal64 : Double = 2.2250738585072014e-308`，此处引用 `@const.min_normal64`。

#### [轻微] `round` 对负半整数行为非对称

- **位置**：`src/maths/basic.mbt:141`
- **描述**：`round(x) = floor(x + 0.5)`：`round(-0.5) = floor(0.0) = 0.0`，`round(-1.5) = floor(-1.0) = -1.0`，`round(-2.5) = floor(-2.0) = -2.0`。即负半整数向 +∞ 方向舍入，与正半整数（`round(0.5) = 1.0`、`round(1.5) = 2.0`）方向一致（整体向上取整）。注释已标注"忠实移植 OCaml `round x = floor (x +. 0.5)`"，行为正确但易被误用为四舍五入。
- **建议**：在文档注释中补充示例 `round(-0.5) = 0.0`、`round(1.5) = 2.0` 以提示向上舍入语义；测试中补充负半整数用例。

#### [轻微] `rand01_exclusive` 注释与实现不严格等价

- **位置**：`src/stats/prng.mbt:48`
- **描述**：注释引用 OCaml 精确公式 `Float.succ 0. + Random.float (Float.pred 1.)`，但 MoonBit 实现为 `5.0e-324 + _rand.val.double() * 0.9999999999999999`。`5.0e-324` 是 `DBL_TRUE_MIN`（最小 subnormal），等价于 `Float.succ 0.`；但 `0.9999999999999999 = 1 - 2^-53` 是 `Float.pred 1.`，而 `_rand.val.double()` 返回 `[0, 1)`，乘以 `Float.pred 1.` 后范围是 `[0, 1-2^-53)`，再加 `DBL_TRUE_MIN` 后下界严格大于 0、上界严格小于 1。实现正确，但注释与代码的对应关系不直观。
- **建议**：在注释中显式标注 `5.0e-324 = DBL_TRUE_MIN = Float.succ 0.`、`0.9999999999999999 = Float.pred 1.`。

#### [轻微] 测试缺少关键边界用例

- **位置**：`src/maths/maths_test.mbt`、`src/stats/stats_test.mbt`
- **描述**：
  - `round` 未测试负半整数（`round(-0.5)`、`round(-1.5)`），无法验证向上舍入语义。
  - `sigmoid` 未显式测试 `sigmoid(x>0)` 返回 NaN（仅测试了 `sigmoid(-1.0)` 和与 `expit` 的差异）。
  - `is_pow2` 未测试 `Int::min`（`-2147483648`）和负数，未暴露前述严重 bug。
  - `is_odd` 未测试 `Int::min`（`abs` 溢出边界）。
  - `min`/`max`/`minmax` 未测试空数组（会崩溃，故未测，但应显式标注 `raise` 契约）。
  - `mean([])`、`std(None, [])`、`kendall_tau` 对 `n<2` 均无测试。
  - `erfc`/`erfcx` 未测试大 x（如 `erfc(10.0)`），未暴露精度丧失。
  - `gaussian_kde` 未测试常量数据（`h=0` 路径）。
- **建议**：补充上述边界用例。对预期 raise 的场景用 `try ... catch { _ => () } noraise { _ => fail(...) }` 模式（已在 `mulmod` 测试中示范）。

#### [轻微] `concordant`/`discordant` 内层 `i != j` 冗余

- **位置**：`src/stats/order.mbt:10`、`src/stats/order.mbt:25`
- **描述**：外层 `for i in 0..<(n - 1)`、内层 `for j in (i + 1)..<n`，已有 `j > i`，故 `i != j` 恒真，条件可省略。
- **建议**：删除 `i != j &&` 简化条件。

#### [轻微] `same_sign` 对 `±0.0` 不区分

- **位置**：`src/maths/helpers.mbt:41`
- **描述**：`x >= 0.0 && y >= 0.0` 中 `+0.0 >= 0.0` 和 `-0.0 >= 0.0` 均为 true，故 `same_sign(+0.0, -0.0)` 返回 `true`。IEEE 754 中 `+0.0` 与 `-0.0` 符号位不同。OCaml 原版可能同样行为，但若需严格符号位一致应改用 `1.0 / x` 的符号判断。
- **建议**：在文档注释中标注"将 ±0 视为同号"；若需严格语义则改实现。

### 本轮统计

| 严重程度 | 数量 |
|---------|------|
| 严重 | 2 |
| 一般 | 9 |
| 轻微 | 7 |

### 总评

整体代码质量较高，MoonBit 惯用法遵循良好：`///|` 分隔符一致使用、`pub`/`pub(all)` 可见性恰当、`raise @types.OwlError` 效果系统统一应用、`Ref[T]` 正确替代 OCaml `ref`、命名采用 snake_case、`derive(Debug, Eq)` 自动派生。`sigmoid` 用 `log` 而非 `exp` 的疑似 bug 已正确忠实移植并在注释与测试中明确标注，值得肯定。测试覆盖包含 golden value、互逆关系（`expit`/`logit`）、数学恒等式（`sin²+cos²=1`、`cosh²-sinh²=1`）、业务场景，质量较高。

主要风险集中在**空数组/边界处理不一致**：`minmax_i` 检查了空数组但 `min`/`max`/`minmax` 未检查，`quantile` 闭包对空数组静默返回 0.0，`mean`/`std`/`kendall_tau` 等对退化输入未防护。`is_pow2(Int::min)` 返回 `true` 是明确的数学错误。`erfc`/`erfcx` 对大 x 的精度丧失是 A&S 近似的固有局限，但应在文档中标注。`cov` 与 `variance` 分母约定不一致是忠实移植的 OCaml 缺陷，建议至少在文档中明示。建议优先修复两个严重问题，并在后续轮次补充边界测试用例。
