# 贡献指南（CONTRIBUTING）

感谢考虑为 owl-mbt 贡献代码。本项目是 Owl 科学计算库的纯 MoonBit 移植，遵循以下流程以保证上游库质量。

## 环境搭建

1. 安装 MoonBit 工具链：<https://www.moonbitlang.com/download>（本项目基线 moon 0.1.20261104）
2. 克隆仓库：`git clone https://github.com/toadium/owl-mbt`
3. 验证环境：`moon check --deny-warn && moon test`（应零警告、561 测试全过）

## 开发流程

1. 从 `main` 创建特性分支（`feat/xxx`、`fix/xxx`、`docs/xxx`）
2. 实现变更，遵循项目编码规范（`AGENTS.md`：`///|` 块分隔、`#derive` 新语法、snake_case、`warnings = "-N"` 包级抑制语法）
3. 自检通过后提交 PR，使用 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/) 格式的提交信息（`feat:`/`fix:`/`docs:`/`refactor:`/`test:`/`chore:`）

## 质量门禁（合并前必须全部通过）

```sh
moon check  --target all --deny-warn   # 四后端零警告零错误
moon test   --target all               # 四后端全量测试
moon info   --target native            # 刷新接口快照（见下方契约校验）
moon fmt                               # 格式化（CI 会检查 fmt 幂等）
```

## 公开契约（API）变更流程

本项目以 `pkg.generated.mbti` 接口快照作为公开契约的事实源，CI 中 `moon info` 后比对 `.mbti` diff——**任何公开 API 变化都会被检出并阻断合并**，直到：

1. 变化在 `CHANGELOG.md` 对应版本段记录（Added / Changed / **Breaking Changes**）
2. 破坏性变更（签名/移除/raise 变化）同步更新 `docs/migration-*.md` 迁移指南
3. 重新生成的 `.mbti` 文件随变更一并提交

参照规范：次版本升级允许新增 API（Added），补丁版本仅允许修复；0.x 阶段的破坏性变更必须在 Breaking Changes 段显式公示。

## 新增功能的测试要求

- 新公开 API 必须附黑盒测试（`_test.mbt`，使用 `@包名.` 显式前缀）
- 边界值、非法输入必须有负向测试（`try ... catch ... noraise` 模式）
- 数值算法需 golden value 或数学恒等式断言（参考 `maths/special_test.mbt`）

## 问题反馈

- Bug 报告：[GitHub Issues](https://github.com/toadium/owl-mbt/issues)（附最小复现 + moon 版本 + 后端）
- 维护响应时效承诺见 [README 维护与反馈](README.md#维护与反馈)
