# Warning 治理跟踪

项目根目录：D:/CodeWorkspace/forMoonbit/owl-mbt
治理启动时间：2026-08-10 20:25

## 基线
检查报告：D:/CodeWorkspace/forMoonbit/owl-mbt/governances/202608102025_warning_governance/check_v1.md | 总warning数：236 | 分布：unused_constructor=119, core_package_not_imported=78, unused_value=19, unused_error_type=16, deprecated_syntax=2, deprecated=2

---

## R1 PLAN unused_value 全量清理
策略：按 warning_guidelines.md "Unused Variable" 处理原则，优先删除未使用变量；不适合删除的改为弃元 `_`。 | 目标warning：unused_value | 预估修复数：19 | 理由：unused_value 是指导原则明确处理范围内唯一存在的类型，修复方式简单统一，19个分散于 algodiff/ndarray/optimise 三个包共7个文件，作为一批风险可控；其他类别（unused_constructor、core_package_not_imported、unused_error_type、deprecated_syntax、deprecated）均不在指导原则处理范围内，本轮排除。

---

## R1 RESULT
计划文件：D:/CodeWorkspace/forMoonbit/owl-mbt/governances/202608102025_warning_governance/plan_v1.md | 执行报告：D:/CodeWorkspace/forMoonbit/owl-mbt/governances/202608102025_warning_governance/exec_v1.md
计划修复：19 | 实际修复：19 | 新引入问题：无 | 剩余：217
说明：unused_value 由 19 降至 0；其余类别数量不变（unused_constructor=119, core_package_not_imported=78, unused_error_type=16, deprecated_syntax=2, deprecated=2）。moon check 通过，moon test 397/397 通过。

---

## R2 判定 无可自动治理问题
策略：评估剩余 217 个 warning 是否可安全自动修复。 | 结论：NO_ACTIONABLE_PLAN | 理由：剩余 warning 类别为 unused_constructor、core_package_not_imported、unused_error_type、deprecated_syntax、deprecated，均不在 warning_guidelines.md 当前处理范围（仅 Unused Import、Unused Variable、Possibly Confusing Line Terminator）内。依据 planner.md 完成判定「剩余warning不在指导原则处理范围内」，本轮无可自动治理问题。
