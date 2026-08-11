# R5: 线性代数与工具模块审查 — src/linalg/ 和 src/misc/

审查时间：2026-08-11

### 审查范围

- `src/linalg/linalg.mbt`（622 行）：LU/Cholesky/QR 分解、det/logdet/rank/trace、inv、linsolve_lu、tridiag_solve
- `src/linalg/linalg_test.mbt`（273 行）：线性代数测试
- `src/misc/log.mbt`（100 行）：日志系统
- `src/misc/heap.mbt`（109 行）：二叉堆
- `src/misc/stack.mbt`（59 行）：栈
- `src/misc/countmin.mbt`（62 行）：Count-Min Sketch
- `src/misc/dataframe.mbt`（187 行）：DataFrame
- `src/misc/utils.mbt`（94 行）：工具函数
- `src/misc/misc_test.mbt`（264 行）：misc 测试

交叉参照：`src/ndarray/core.mbt`、`src/ndarray/creation.mbt`、`src/ndarray/matrix.mbt`、`src/ndarray/shape_ops.mbt`、`src/types/types.mbt`

### 发现

#### [严重] Count-Min Sketch 哈希函数整数溢出

- **位置**：`src/misc/countmin.mbt:16`
- **描述**：`_hash31` 中 `let result = a * x + b`，其中 `a` 和 `x` 均可达 `1073741823`（约 2^30），`a * x` 可达 2^60，远超 MoonBit `Int`（32 位有符号）范围 `2^31 - 1`。乘法静默溢出为负数或回绕，导致哈希值完全错误，sketch 统计结果不可信。后续 `((result >> 31) + result) & _bigprime` 的模约简也基于已溢出的 `result`，无法修正。
- **建议**：使用 `Int64` 进行中间运算：`let result = a.to_int64() * x.to_int64() + b.to_int64()`，再对 `_bigprime` 取模后转回 `Int`。或采用大素数模乘（Montgomery / Barrett）避免溢出。

#### [严重] Count-Min Sketch 负索引导致数组越界

- **位置**：`src/misc/countmin.mbt:45`、`src/misc/countmin.mbt:56`
- **描述**：`_hash31` 在溢出时可能返回负数（`result` 溢出为负，`>> 31` 算术右移保留符号位，`& _bigprime` 对负数结果仍可能为负或非预期正值）。`let idx = _hash31(x, ai, bi) % s.w` 中，MoonBit 的 `%` 对负被除数返回负余数，`idx` 为负时 `s.tbl.val[i][idx]` 数组越界，运行时 abort。
- **建议**：在 `_hash31` 返回前确保非负：`let h = ((result >> 31) + result) & _bigprime; if h < 0 { h + s.w } else { h }`，或更彻底地修复溢出（见上一条）后在 `%` 后加 `((idx % w) + w) % w` 保证非负。

#### [严重] Count-Min Sketch 初始化不验证参数，存在除零风险

- **位置**：`src/misc/countmin.mbt:22-30`、`src/misc/countmin.mbt:34-38`
- **描述**：`cms_init_lw(l, w)` 不检查 `l > 0` 和 `w > 0`。若传入 `l=0` 或 `w=0`，创建空 sketch 后 `cms_incr`/`cms_count` 中 `_hash31(x, ai, bi) % s.w` 以 `w=0` 取模，触发除零 abort。`cms_init(epsilon, delta)` 不检查 `epsilon`、`delta` 属于 `(0, 1)`：若 `delta >= 1.0`，`log2(1.0/delta) <= 0`，`ceil(...).to_int()` 可能为 0 或负，导致 `l <= 0`。
- **建议**：在 `cms_init_lw` 开头 `if l <= 0 || w <= 0 { raise @types.OwlError::InvalidArgument("cms_init_lw: l and w must be positive") }`；在 `cms_init` 中验证 `epsilon > 0.0 && epsilon < 1.0 && delta > 0.0 && delta < 1.0`。

#### [严重] tridiag_solve 不校验输入数组长度，存在越界风险

- **位置**：`src/linalg/linalg.mbt:594-622`
- **描述**：`tridiag_solve(a, b, c, r)` 以 `n = b.length()` 为系统规模，但不检查 `a.length() >= n`、`c.length() >= n`、`r.length() >= n`。当 `a` 或 `c` 或 `r` 短于 `b` 时，循环内 `a[j]`（line 610）、`c[j - 1]`（line 609）、`r[j]`（line 614）越界 abort。此外 `n = 0` 时 `b[0]`（line 603）直接越界。
- **建议**：函数签名加 `raise`，开头校验：
  ```
  if n == 0 { raise @types.OwlError::InvalidArgument("tridiag_solve: empty system") }
  if a.length() < n || c.length() < n || r.length() < n {
    raise @types.OwlError::InvalidArgument("tridiag_solve: array length mismatch")
  }
  ```

#### [严重] DataFrame 不校验列长度一致，后续操作越界

- **位置**：`src/misc/dataframe.mbt:46-57`
- **描述**：`make_dataframe` 仅根据 `columns[0]` 的长度设置 `n_rows`，不验证所有列长度一致。若某列长度小于 `n_rows`，`dataframe_to_string`（line 176-185）中 `col.float_data[i]` / `col.int_data[i]` / `col.string_data[i]` 越界 abort。`col_mean` / `col_min` / `col_max` 对短列也会越界。
- **建议**：在 `make_dataframe` 中遍历所有列，验证每列数据长度等于第一列：
  ```
  for col in columns {
    let len = match col.typ { FloatCol => col.float_data.length() ... }
    if len != n_rows { raise @types.OwlError::InvalidArgument("make_dataframe: column length mismatch") }
  }
  ```
  函数签名加 `raise`。

#### [严重] QR 分解 thin 参数声明但未实现

- **位置**：`src/linalg/linalg.mbt:508`
- **描述**：`qr(a, thin? : Bool = false)` 签名声明了 `thin` 参数，但函数体内 `let _ = thin` 直接丢弃，始终执行 full QR 分解。调用方传入 `thin=true` 期望得到 reduced Q (m×k) 和 R (k×n)（其中 k = min(m,n)），却得到 full Q (m×m) 和 R (m×n)，API 行为与声明不符，属于"静默错误"。
- **建议**：要么实现 thin QR（截断 Q 的后 `m-k` 列和 R 的后 `m-k` 行），要么移除 `thin` 参数并在文档中说明仅支持 full QR。若保留参数待实现，应 `raise @types.OwlError::NotImplemented("qr: thin QR")` 而非静默忽略。

#### [一般] LU 分解对奇异矩阵不报错，返回数值垃圾

- **位置**：`src/linalg/linalg.mbt:123-125`、`src/linalg/linalg.mbt:393-395`
- **描述**：`lu` 和 `linsolve_lu` 中，当主元 `lu_data[k * n + k] == 0.0` 时，用 `tiny = 1.0e-40` 替换并继续，不 raise。对于真正奇异的矩阵，后续除法产生 ~1e40 量级的垃圾值。`linsolve_lu` 的后向代换（line 434 `sum / lu_data[i * n + i]`）会除以 `tiny`，返回巨大无意义数值。这与 `det`（返回 0.0）和 `logdet`（raise）的奇异处理不一致。
- **建议**：统一奇异矩阵处理策略。建议在 `lu` 中当主元为 0 时 `raise @types.OwlError::InvalidArgument("lu: singular matrix")`，与 `inv` 的行为一致。`linsolve_lu` 同理。若需容忍数值接近奇异的场景，可加 `tol` 参数控制。

#### [一般] logdet 对数值奇异矩阵不报错

- **位置**：`src/linalg/linalg.mbt:261-263`
- **描述**：`logdet` 仅在某行完全为零（`big == 0.0`，line 238）时 raise。但当矩阵数值奇异（行不全为零但 LU 主元为零）时，主元被替换为 `tiny = 1e-40`，`ln(1e-40) ≈ -92.1` 被累加到结果中，返回大负数而不报错，误导调用方认为行列式为极小正数。
- **建议**：在主元为零时 raise `singular matrix`，或在返回前检查是否发生过 `tiny` 替换并 raise。

#### [一般] Cholesky 分解不检查矩阵对称性

- **位置**：`src/linalg/linalg.mbt:447-485`
- **描述**：`chol` 要求输入为对称正定矩阵，但实现只使用下三角部分（`a.data[i * n + j]` for `j <= i`），不验证对称性。传入非对称矩阵时，函数静默使用下三角计算，返回的 L 满足 `L * L^T = sym(A)`（对称化后的矩阵）而非 A 本身，结果误导用户。若对称化后的矩阵非正定，会在 line 463 raise "not positive definite"，但错误消息不准确（原矩阵可能根本不对称）。
- **建议**：在分解前调用 `is_symmetric` 检查（加容差版本），不对称时 raise `InvalidArgument("chol: matrix must be symmetric")`。或在文档中明确说明"仅使用下三角，调用方需保证对称"。

#### [一般] LU 分解逻辑在四个函数中大量重复

- **位置**：`src/linalg/linalg.mbt:75-147`（lu）、`151-213`（det）、`217-277`（logdet）、`340-442`（linsolve_lu）
- **描述**：`lu`、`det`、`logdet`、`linsolve_lu` 各自复制了约 30 行完全相同的 LU 分解主循环（缩放向量 `vv` 计算、部分主元选择、行交换、消元），仅返回值处理不同。总计约 120 行重复代码，维护成本高：修复一个 bug 需要同步四处修改，容易遗漏。
- **建议**：提取内部辅助函数 `_lu_decompose(a : @ndarray.Ndarray) -> (FixedArray[Double], Array[Int], Bool) raise`，返回（LU 复合矩阵、置换数组、是否奇异），四个公共函数各自调用并做后处理。

#### [一般] Heap pop/peek 返回 T 而非 T?，与 Stack API 不一致

- **位置**：`src/misc/heap.mbt:64-67`、`src/misc/heap.mbt:98-103`
- **描述**：`Heap::pop` 和 `Heap::peek` 在空堆时 `abort`，返回类型为 `T`。而同模块的 `Stack::pop` 返回 `T?`（空栈返回 `None`），`Stack::peek` 同理。同一项目内两个数据结构的空态处理风格不一致，调用方需要不同的防御逻辑。
- **建议**：统一为 `T?` 返回类型：`pub fn[T] Heap::pop(h : Heap[T]) -> T?`，空堆返回 `None`。或两者都用 `raise` 风格（`raise @types.OwlError::OutOfRange`）。当前 `abort` 是最差选择——无法被调用方捕获。

#### [一般] DataFrame get_column 找不到列时 abort 而非 raise

- **位置**：`src/misc/dataframe.mbt:85`
- **描述**：`get_column` 在列名不存在时 `abort("get_column: column not found")`，不可恢复。项目已有 `@types.OwlError::NotFound` 错误类型，linalg 模块也统一用 `raise` 处理错误。DataFrame 的 abort 风格与项目整体错误处理约定不符。
- **建议**：改为 `raise @types.OwlError::NotFound`，函数签名加 `raise`。

#### [一般] col_min / col_max 对空列返回 0.0 语义错误

- **位置**：`src/misc/dataframe.mbt:135-148`、`src/misc/dataframe.mbt:152-165`
- **描述**：`col_min` 和 `col_max` 在空列时返回 `0.0`，但 0.0 既不是空集的最小值也不是最大值（空集的 min/max 数学上无定义）。返回 0.0 会误导调用方认为列中有 0.0 元素。`col_mean` 返回 0.0 尚可接受（空均值约定为 0），但 min/max 不行。
- **建议**：空列时 `raise @types.OwlError::InvalidArgument("col_min: empty column")`，或返回 `Double?`（`None` 表示空）。

#### [一般] Logger 的 colorful 字段声明但从未使用

- **位置**：`src/misc/log.mbt:65`、`src/misc/log.mbt:82-84`、`src/misc/log.mbt:94-99`
- **描述**：`Logger` 结构有 `colorful : Ref[Bool]` 字段，`set_colorful` 可设置它，但 `format_msg` 完全不读取 `colorful`，始终输出无色纯文本。功能声明但未实现，与 QR 的 `thin` 问题同类。
- **建议**：要么在 `format_msg` 中根据 `colorful` 添加 ANSI 颜色码（如 `\x1b[32mINFO\x1b[0m : msg`），要么移除 `colorful` 字段和 `set_colorful` 函数。

#### [一般] dataframe_to_string 字符串拼接 O(n²)

- **位置**：`src/misc/dataframe.mbt:169-187`
- **描述**：循环中 `result = "\{result}\{...}"` 每次创建新字符串并复制全部旧内容，对于 `n_rows × n_cols` 的 DataFrame，总复杂度 O((n_rows × n_cols)²)。大表（如 1000 行 10 列）会产生约 10^8 次字符复制。
- **建议**：使用 `StringBuilder` 或预分配 `Buffer`，逐段追加。

#### [一般] _repeat_str 字符串拼接 O(n²)

- **位置**：`src/misc/utils.mbt:38-44`
- **描述**：`_repeat_str` 循环中 `result = "\{result}\{s}"`，每次复制全部旧内容。对于 `n` 次重复长度为 `m` 的字符串，复杂度 O(n² × m)。
- **建议**：使用 `StringBuilder`，或倍增法（doubling）：`result = result + result` 每次翻倍，对数级拼接次数。

#### [一般] linsolve_lu 中 b_col 冗余复制

- **位置**：`src/linalg/linalg.mbt:406-413`
- **描述**：对每列求解时，先 `b_col[i] = b.data[i * m + col]`（line 407-409）提取列，再 `x_col[i] = b_col[i]`（line 411-413）复制到 x_col。`b_col` 仅用于初始化 `x_col`，之后不再使用，多了一次 O(n) 复制。
- **建议**：删除 `b_col`，直接 `x_col[i] = b.data[i * m + col]`。

#### [轻微] is_triu / is_tril / is_symmetric 使用精确浮点比较

- **位置**：`src/linalg/linalg.mbt:8`、`src/linalg/linalg.mbt:25`、`src/linalg/linalg.mbt:44`
- **描述**：用 `!= 0.0` 和 `!=` 精确比较浮点数。对于 LU/Cholesky 等分解输出的结构性零，精确比较通常可行；但对于一般矩阵的数值零（如 `1e-20`），会被判为"非零"导致 `is_triu` 返回 false。
- **建议**：提供带容差的重载 `is_triu(x, tol? : Double = 1e-12)`，或在文档中明确说明仅适用于精确零。

#### [轻微] is_diag 遍历矩阵两次

- **位置**：`src/linalg/linalg.mbt:54-56`
- **描述**：`is_diag(x) = is_triu(x) && is_tril(x)` 分别遍历下三角和上三角，共两次扫描。可以单次遍历检查所有非对角元素。
- **建议**：合并为单次双重循环，跳过 `i == j` 的对角元素，检查其余元素是否为零。

#### [轻微] qr 中 q_result 冗余复制

- **位置**：`src/linalg/linalg.mbt:553-558`
- **描述**：`q_result` 是 `q_data` 的完整逐元素复制，随后传给 `from_data`。`q_data` 之后不再使用，可直接 `@ndarray.from_data([m, m], q_data)`，省一次 O(m²) 复制。
- **建议**：删除 `q_result`，直接传 `q_data`。

#### [轻微] qr 中 Householder 向量每次迭代重新分配

- **位置**：`src/linalg/linalg.mbt:519`
- **描述**：`let v = Array::make(m, 0.0)` 在 `k` 的循环内分配，共 `min(m,n)` 次堆分配。对于大矩阵，分配开销可观。
- **建议**：在循环外预分配 `let v = Array::make(m, 0.0)`，循环内仅重置需要的位置。

#### [轻微] Stack / Heap 的 used 字段与 data.length() 冗余

- **位置**：`src/misc/stack.mbt:4-5`、`src/misc/heap.mbt:4-5`
- **描述**：`used : Ref[Int]` 手动跟踪元素数，但 `data : Ref[Array[T]]` 的 `.length()` 也反映元素数。两者需手动保持一致，增加维护负担和出错可能（如 push 只更新一个）。
- **建议**：移除 `used`，统一用 `s.data.val.length()`。若担心函数调用开销，MoonBit 编译器应能内联 `Array::length`。

#### [轻微] approx_equal 使用绝对误差而非相对误差

- **位置**：`src/misc/utils.mbt:86-88`
- **描述**：`(a - b).abs() < eps` 对大数不合适：`approx_equal(1e10, 1e10 + 1, 1.0)` 返回 false，但相对误差仅 1e-10。对接近零的数又过严：`approx_equal(1e-20, 2e-20, 1e-10)` 返回 true，但相对误差 100%。
- **建议**：提供相对误差版本：`(|a - b|) / (1 + max(|a|, |b|)) < eps`，或同时提供绝对和相对两个函数。

#### [轻微] LogLevel / PaddingSide 构造函数可能冗余

- **位置**：`src/misc/log.mbt:37-59`、`src/misc/utils.mbt:23-35`
- **描述**：`level_debug()` 等 5 个函数和 `pad_left()` 等 3 个函数分别构造 `LogLevel` 和 `PaddingSide` 的构造子。若 `pub enum` 的构造子已对外可见（MoonBit 中 `pub enum` 构造子默认公开），这些函数完全冗余——用户可直接写 `Debug` / `Left`。测试中用 `level_debug()` 而非 `Debug`，说明可能是习惯或对可见性规则的不确定。
- **建议**：确认 `pub enum` 构造子可见性。若已公开，删除这些冗余构造函数，文档示例改用构造子直接构造。

#### [轻微] Column 结构同时持有三种数据数组

- **位置**：`src/misc/dataframe.mbt:11-17`
- **描述**：`Column` 同时持有 `float_data`、`int_data`、`string_data` 三个数组，无论 `typ` 为何，另外两个为空数组。每个 `Column` 实例多出两个空 `Array` 对象的分配开销。
- **建议**：改用带参数 enum：`pub enum ColumnData { F(Array[Double]); I(Array[Int]); S(Array[String]) }`，`Column` 持有 `data : ColumnData`。消除冗余空数组。

#### [轻微] LU 测试未覆盖需要行交换的矩阵

- **位置**：`src/linalg/linalg_test.mbt:71-76`、`src/linalg/linalg_test.mbt:162-177`
- **描述**：`lu` 测试和 `scenario: LU decomposition and reconstruction` 测试的矩阵（`[[2,1.5,1],[1,3,2],[4,1,7]]` 和 `[[4,3],[6,3]]`）碰巧在部分主元选择下不需要行交换（`vv` 缩放后首列最大值恰在首行），因此 `L*U == A` 成立。测试直接比较 `L*U` 和 `A`，忽略了置换数组 `piv`。若用需要行交换的矩阵（如 `[[1,2],[3,4]]`，首列 3 > 1 会交换），`L*U != A`，测试会失败——但当前测试无法发现此问题。
- **建议**：添加需要行交换的测试用例，并正确验证 `L*U == A[piv,:]`（应用置换后比较）。

#### [轻微] 测试缺少奇异矩阵、非方阵、边界用例

- **位置**：`src/linalg/linalg_test.mbt` 全文
- **描述**：以下边界用例未覆盖：
  - 奇异矩阵的 `det`（应返回 0.0）、`inv`（应 raise）、`linsolve_lu`（应 raise）
  - 非方阵传给 `det`/`inv`/`lu`/`chol`（应 raise InvalidArgument）
  - `chol` 对非正定矩阵（如 `[[-1,0],[0,-1]]`，应 raise）
  - `chol` 的 `upper=true` 参数
  - `logdet` 对负行列式矩阵（如 `[[-1,0],[0,1]]`，det=-1，logdet 应为 0 或 raise）
  - `rank` 对 m≠n 矩阵、零矩阵
  - `tridiag_solve` 输入数组长度不一致（应 raise 或定义行为）
- **建议**：为上述每个边界场景添加测试，验证正确行为（返回值或 raise 的错误类型）。

#### [轻微] heap 测试未覆盖空堆 pop/peek

- **位置**：`src/misc/misc_test.mbt:39-79`
- **描述**：`heap_basic` 和 `heap_max_heap` 测试在堆非空时 pop/peek，未测试空堆 pop/peek 的 abort 行为。`heap_to_array` 只检查长度，不检查返回数组的顺序。
- **建议**：添加空堆测试（用 `@test.assert_panic` 或 try-catch 验证 abort）。`to_array` 文档应说明返回的是内部存储顺序而非排序顺序，或提供 `to_sorted_array`。

#### [轻微] countmin 测试只检查下界，未验证估计精度

- **位置**：`src/misc/misc_test.mbt:82-97`
- **描述**：`countmin_basic` 只断言 `c1 >= 3`、`c2 >= 1` 等（Count-Min Sketch 的下界性质），不检查上界或与精确值的偏差。无法发现哈希溢出导致的统计错误（溢出可能恰好仍满足下界）。
- **建议**：对小规模 sketch 检查估计值不超过 `true_count + epsilon * total_count`（上界），并增加大规模测试以暴露溢出问题。

#### [轻微] dataframe 测试未覆盖列长度不一致

- **位置**：`src/misc/misc_test.mbt:178-215`
- **描述**：所有 DataFrame 测试都用长度一致的列构造，未测试列长度不一致时 `make_dataframe` 的行为（当前不报错，后续操作越界）。
- **建议**：添加列长度不一致的测试，验证 `make_dataframe` raise 或 `dataframe_to_string` 的安全行为。

### 本轮统计

| 严重程度 | 数量 |
|---------|------|
| 严重 | 7 |
| 一般 | 11 |
| 轻微 | 12 |

### 总评

**线性代数模块（src/linalg/）**：`lu`/`det`/`inv`/`linsolve_lu`/`tridiag_solve` 的核心算法正确，忠实于 Numerical Recipes 的部分主元 LU 分解和 Thomas 算法，测试中 L*U 重建、A*x=b 求解、A*A^{-1}=I 验证均通过。自行实现的 `chol`（Cholesky）算法正确，SPD 矩阵重建精度达标；`qr`（Householder）算法正确，Q*R 重建和 Q^T*Q=I 验证通过；`rank` 基于 QR 对角线阈值判定，逻辑合理。

主要风险集中在：**(1) 奇异矩阵处理不一致**——`lu`/`linsolve_lu` 用 `tiny` 替换零主元静默继续，`det` 返回 0，`logdet` 仅全零行才 raise，`inv` 才正确 raise，四者行为应统一；**(2) LU 分解代码重复四处**，约 120 行复制，维护隐患大；**(3) `qr` 的 `thin` 参数声明但未实现**，API 误导；**(4) `tridiag_solve` 缺少输入长度校验**，越界风险。测试覆盖不足——未测试需要行交换的 LU、奇异矩阵、非方阵、`chol` 的 `upper` 参数等边界场景。

**工具模块（src/misc/）**：`Stack` 实现简洁正确，`Heap` 的 sift up/down 逻辑正确（min-heap/max-heap 测试通过），`DataFrame` 基本功能完整，`utils` 的 pad/repeat 功能正确。

主要问题集中在：**(1) Count-Min Sketch 的 `_hash31` 整数溢出**——`a * x` 可达 2^60 远超 Int32，导致哈希错误和潜在负索引越界，是本轮最严重的正确性缺陷；**(2) `make_dataframe` 不校验列长度一致**，后续 `to_string`/`col_min` 等越界；**(3) `Heap::pop`/`peek` 用 `abort` 而非 `T?`**，与 `Stack` API 不一致且不可恢复；**(4) `Logger.colorful` 声明但未实现**，与 `qr.thin` 同类问题；**(5) 字符串拼接 O(n²)**（`dataframe_to_string`、`_repeat_str`）。`Column` 结构的三数组设计冗余但功能正确。

**MoonBit 惯用法**：错误处理风格不统一——linalg 用 `raise OwlError::InvalidArgument`，DataFrame 用 `abort`，Stack 用 `T?`，Heap 用 `abort`，应统一为 `raise` + `OwlError` 体系。`pub enum` 构造函数可能冗余，需确认可见性规则。`///|` 分隔、`Ref[T]` 可变性、命名约定均符合项目规范。
