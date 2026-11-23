# misc

杂项数据结构：DataFrame、Count-Min Sketch、堆栈与日志。

[← 返回总览](../README.md)

## 安装

```bash
moon add walkzzz/owl_mbt@0.3.1
```

```moonbit
// moon.pkg
import {
  "walkzzz/owl_mbt/misc" as @misc
}
```

## 主要接口

| 接口 | 说明 |
|---|---|
| `make_dataframe(columns)` | 由列构造数据框 |
| `get_column(df, name)` / `col_names(df)` | 列访问 |
| `col_mean` / `col_sum` / `col_min` / `col_max` | 列聚合 |
| `dataframe_to_string(df)` | 表格文本输出 |
| `cms_init(eps, delta)` / `cms_init_lw(w, d)` | Count-Min Sketch 构造 |
| `cms_incr(sketch, key)` / `cms_count(sketch, key)` | 计数更新与查询 |
| `make_logger()` / `format_msg(logger, level, msg)` | 简易日志 |
| `approx_equal` / `approx_equal_rel` | 近似比较 |

## 示例

```moonbit
let sketch = @misc.cms_init(0.01, 0.99)
@misc.cms_incr(sketch, 42)
@misc.cms_incr(sketch, 42)

let n = @misc.cms_count(sketch, 42)   // 2（可能有上界误差）
```

数据框：

```moonbit
let df = @misc.make_dataframe(columns)
println(@misc.dataframe_to_string(df))
let avg = @misc.col_mean(df, "score")
```

## 行为说明

- Count-Min Sketch 是概率结构，查询值可能高于真实计数，不会低估。
- DataFrame 为内存表，无 SQL/文件 IO；列类型与构造方式见接口契约。
- 日志为轻量级别枚举（debug/info/warn/error/fatal），不依赖外部日志框架。

## 相关

- [接口契约](./pkg.generated.mbti)
- [统计模块](../stats/README.md)
- [代码示例](../examples/ndarray_demo/main.mbt)