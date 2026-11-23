#!/usr/bin/env node
// 文档数字一致性自检 — 版本 / CHANGELOG / 测试数 / 覆盖率 / 死链
// Docs consistency: version, changelog, test count, coverage claim, dead links.
//
// 用法：node scripts/check_docs.mjs
// 退出码：全绿 0；任一断言失败 1。

import { readFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import path from 'node:path';

const ROOT = path.resolve(import.meta.dirname, '..');

async function read(rel) {
  return readFile(path.join(ROOT, rel), 'utf8');
}

function cap(re, text, file, what) {
  const m = text.match(re);
  if (!m) throw new Error(`${what}: not found in ${file}`);
  return m[1];
}

const ASSERTIONS = [
  {
    id: 'A1',
    desc: 'moon.mod version == CHANGELOG 最新条目',
    async run() {
      const mod = cap(/^version = "([^"]+)"/m, await read('moon.mod'), 'moon.mod', 'version');
      const cl = cap(/^## \[([^\]]+)\]/m, await read('CHANGELOG.md'), 'CHANGELOG.md', 'latest entry');
      if (mod !== cl) throw new Error(`moon.mod=${mod} != CHANGELOG=${cl}`);
      return { version: mod };
    },
  },
  {
    id: 'A2',
    desc: 'README 测试数 == AGENTS.md 测试数',
    async run() {
      const readme = await read('README.md');
      const agents = await read('AGENTS.md');
      const a = cap(/(\d+) 测试全通过/, readme, 'README.md', 'readme tests');
      const b = cap(/(\d+) 测试 × 4 后端/, agents, 'AGENTS.md', 'agents tests');
      if (a !== b) throw new Error(`README=${a} != AGENTS=${b}`);
      return { tests: a };
    },
  },
  {
    id: 'A3',
    desc: 'README 引用的 docs/*.md 全部存在（防死链）',
    async run() {
      const readme = await read('README.md');
      const links = [...readme.matchAll(/\]\((docs\/[\w.-]+\.md)\)/g)].map((m) => m[1]);
      const missing = links.filter((f) => !existsSync(path.join(ROOT, f)));
      if (missing.length) throw new Error(`missing docs: ${missing.join(', ')}`);
      return { checked: links.length };
    },
  },
  {
    id: 'A4',
    desc: '覆盖率门槛脚本存在（core 90%）且 CI 引用',
    async run() {
      const cov = await read('scripts/check_coverage.mjs');
      const min = cap(/const CORE_MIN = ([\d.]+)/, cov, 'scripts/check_coverage.mjs', 'CORE_MIN');
      if (min !== '90.0') throw new Error(`CORE_MIN=${min} != 90.0`);
      const ci = await read('.github/workflows/ci.yml');
      if (!ci.includes('node scripts/check_coverage.mjs')) throw new Error('CI 未引用 check_coverage.mjs');
      return { core_min: min };
    },
  },
  {
    id: 'A5',
    desc: 'ASSESSMENT 存在且含实测测试数（防口径漂移）',
    async run() {
      const doc = await read('docs/assessment.md');
      const tests = cap(/(\d+) 测试/, doc, 'docs/assessment.md', 'assessment tests');
      const readme = cap(/(\d+) 测试全通过/, await read('README.md'), 'README.md', 'readme tests');
      if (tests !== readme) throw new Error(`assessment=${tests} != README=${readme}`);
      return { tests };
    },
  },
  {
    id: 'A6',
    desc: '11 个包 README 齐全，且包内相对链接无死链',
    async run() {
      const pkgs = [
        'core',
        'ndarray',
        'linalg',
        'maths',
        'stats',
        'algodiff',
        'neural',
        'optimise',
        'compute',
        'misc',
        'playground',
      ];
      const missing = pkgs.filter(
        (pkg) => !existsSync(path.join(ROOT, pkg, 'README.md')),
      );
      if (missing.length) throw new Error(`缺少 README: ${missing.join(', ')}`);

      const dead = [];
      for (const pkg of pkgs) {
        const text = await read(`${pkg}/README.md`);
        for (const match of text.matchAll(/\]\(([^)]+)\)/g)) {
          const target = match[1];
          if (/^(https?:|#|mailto:)/.test(target)) continue;
          const file = target.split('#')[0];
          if (!file) continue;
          if (!existsSync(path.resolve(ROOT, pkg, file))) {
            dead.push(`${pkg}/README.md -> ${target}`);
          }
        }
      }
      if (dead.length) throw new Error(`死链: ${dead.slice(0, 5).join('; ')}`);
      return { packages: pkgs.length };
    },
  },
];

const results = [];
for (const a of ASSERTIONS) {
  try {
    results.push({ id: a.id, desc: a.desc, ok: true, evidence: await a.run() });
  } catch (e) {
    results.push({ id: a.id, desc: a.desc, ok: false, fail: String(e.message) });
  }
}
const failed = results.filter((r) => !r.ok).length;
console.log(JSON.stringify({ schema: 'check_docs@1', total: results.length, failed, results }, null, 2));
process.exit(failed === 0 ? 0 : 1);