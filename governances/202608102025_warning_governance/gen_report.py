import csv
from collections import defaultdict

base_dir = "D:/CodeWorkspace/forMoonbit/owl-mbt/governances/202608102025_warning_governance/"

# 读取 CSV
warnings = []
with open(base_dir + "warnings.csv", "r", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        warnings.append(row)

# 读取清理后的原始输出
with open(base_dir + "clean_output.txt", "r", encoding="utf-8") as f:
    raw_output = f.read().strip()

# 统计
total = len(warnings)
by_category = defaultdict(list)
for w in warnings:
    by_category[w["Category"]].append(w)

# 排序类别（按数量降序）
sorted_categories = sorted(by_category.keys(), key=lambda c: -len(by_category[c]))

# 构建报告
lines = []
lines.append("# Warning 检查报告（v1）")
lines.append("")
lines.append("## 检查结果")
lines.append("")
lines.append("ISSUES_FOUND")
lines.append("")
lines.append("## 执行信息")
lines.append("")
lines.append("- 命令：`moon check`")
lines.append("- 退出码：0")
lines.append(f"- Warning总数：{total}")
lines.append("")
lines.append("## Warning统计")
lines.append("")
lines.append("| Warning类别 | 问题数 |")
lines.append("|------------|-------|")
for cat in sorted_categories:
    lines.append(f"| {cat} | {len(by_category[cat])} |")
lines.append("")
lines.append("## Warning清单")
lines.append("")

for cat in sorted_categories:
    lines.append(f"### {cat}")
    lines.append("")
    lines.append("| 文件 | 行号 | Warning内容 |")
    lines.append("|------|------|------------|")
    # 按文件和行号排序
    sorted_items = sorted(by_category[cat], key=lambda x: (x["File"], int(x["Line"])))
    for item in sorted_items:
        msg = item["Message"].replace("|", "\\|")
        lines.append(f"| {item['File']} | {item['Line']} | {msg} |")
    lines.append("")

lines.append("## 原始输出")
lines.append("")
lines.append("```")
lines.append(raw_output)
lines.append("```")
lines.append("")
lines.append("## 判定")
lines.append("")
lines.append("- **CLEAN**：编译输出中无warning")
lines.append("- **ISSUES_FOUND**：编译输出中存在至少一个warning")
lines.append("")
lines.append(f"当前判定：**ISSUES_FOUND**（检测到 {total} 个 warning）")

report = "\n".join(lines)

with open(base_dir + "check_v1.md", "w", encoding="utf-8") as f:
    f.write(report)

print(f"Report generated. Total warnings: {total}")
for cat in sorted_categories:
    print(f"  {cat}: {len(by_category[cat])}")
