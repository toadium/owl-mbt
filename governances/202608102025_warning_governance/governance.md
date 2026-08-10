# Warning 治理跟踪

项目根目录：D:/CodeWorkspace/forMoonbit/owl-mbt
治理启动时间：2026-08-10 20:25

## 基线
检查报告：D:/CodeWorkspace/forMoonbit/owl-mbt/governances/202608102025_warning_governance/check_v1.md | 总warning数：236 | 分布：unused_constructor=119, core_package_not_imported=78, unused_value=19, unused_error_type=16, deprecated_syntax=2, deprecated=2

---

## R1 PLAN unused_value 全量清理
策略：按 warning_guidelines.md "Unused Variable" 处理原则，优先删除未使用变量；不适合删除的改为弃元 `_`。 | 目标warning：unused_value | 预估修复数：19 | 理由：unused_value 是指导原则明确处理范围内唯一存在的类型，修复方式简单统一，19个分散于 algodiff/ndarray/optimise 三个包共7个文件，作为一批风险可控；其他类别（unused_constructor、core_package_not_imported、unused_error_type、deprecated_syntax、deprecated）均不在指导原则处理范围内，本轮排除。
