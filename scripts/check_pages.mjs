#!/usr/bin/env node
// 展示页自检：静态资源 + wasm 导出 + 数值一致性（与 native 断言一致）。
// Pages self-check: static assets, wasm exports, and numeric parity.

import { readFileSync, existsSync, copyFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const ROOT = fileURLToPath(new URL('..', import.meta.url));
const WASM_BUILD = join(ROOT, '_build/wasm-gc/release/build/playground/playground.wasm');
const WASM_DOCS = join(ROOT, 'docs/playground.wasm');

let failures = 0;
function check(name, ok, detail) {
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}${detail ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

// 1. static assets
for (const f of ['docs/index.html', 'docs/app.js', 'docs/style.css']) {
  check(`asset exists: ${f}`, existsSync(join(ROOT, f)));
}
const html = readFileSync(join(ROOT, 'docs/index.html'), 'utf8');
check('index.html mentions owl-mbt + WebAssembly', html.includes('owl-mbt') && html.includes('WebAssembly'));
check('index.html loads app.js / style.css', html.includes('app.js') && html.includes('style.css'));

// 1b. 展示页结构（开源库首页范式）
const sections = ['features', 'demo', 'start', 'api', 'quality', 'docs'];
check(
  '分区锚点齐全',
  sections.every((id) => html.includes(`id="${id}"`) && html.includes(`href="#${id}"`)),
  sections.join(', '),
);
check('顶部导航存在', html.includes('class="nav"'));
for (const id of [
  'wasm-size',
  'wasm-imports',
  'wasm-exports',
  'hero-gamma',
  'hero-erf',
  'hero-j0',
  'hero-status',
]) {
  check(`Hero wasm 钩子: ${id}`, html.includes(`id="${id}"`));
}
check('主题切换按钮', html.includes('id="theme-toggle"'));

const appJs = readFileSync(join(ROOT, 'docs/app.js'), 'utf8');
check(
  '主题持久化',
  appJs.includes('owl-mbt-theme') && appJs.includes('localStorage'),
);
const copyTargets = [...html.matchAll(/data-copy-target="([^"]+)"/g)].map((m) => m[1]);
check(
  '复制按钮指向存在的元素',
  copyTargets.length >= 5 && copyTargets.every((id) => html.includes(`id="${id}"`)),
  `${copyTargets.length} 个`,
);
check('无外链 CDN 静态资源', !/https?:\/\/[^"']+\.(css|js)(\?|")/.test(html));
check(
  'Open Graph 信息',
  ['og:title', 'og:description', 'og:url'].every((key) => html.includes(key)),
);
check(
  '深浅主题样式',
  readFileSync(join(ROOT, 'docs/style.css'), 'utf8').includes("[data-theme='light']"),
);

const modules = [
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
const moduleLinks = [...html.matchAll(/blob\/main\/([a-z]+)\/README\.md/g)].map(
  (m) => m[1],
);
check(
  '模块卡 / 表格 / 演示卡链接到包 README',
  moduleLinks.length >= 20 && moduleLinks.every((pkg) => modules.includes(pkg)),
  `${moduleLinks.length} 个链接`,
);
check(
  '11 个包均有 README 入口',
  modules.every((pkg) => html.includes(`/${pkg}/README.md`)),
);
check(
  '11 份包 README 存在',
  modules.every((pkg) => existsSync(join(ROOT, pkg, 'README.md'))),
);
check(
  '特性卡整卡链接（12 个）',
  (html.match(/<a class="feature" /g) || []).length === 12,
);

const readme = readFileSync(join(ROOT, 'README.md'), 'utf8');
const assessment = readFileSync(join(ROOT, 'docs/assessment.md'), 'utf8');
const modVersion = readFileSync(join(ROOT, 'moon.mod'), 'utf8').match(
  /version = "([^"]+)"/,
)?.[1] ?? '';
const testsPer = Number(readme.match(/(\d+) 测试全通过/)?.[1] ?? 0);
const coverage = assessment.match(/= ([\d.]+)%/)?.[1] ?? '';
check(
  '页面每后端测试数 = README',
  testsPer > 0 && html.includes(`${testsPer} × 4 测试`),
  `README=${testsPer}`,
);
check(
  '页面四后端合计',
  testsPer > 0 && html.includes(String(testsPer * 4)),
  String(testsPer * 4),
);
check(
  '页面覆盖率 = assessment',
  coverage.length > 0 && html.includes(`覆盖率 ${coverage}%`),
  coverage,
);
check('页面变异 10 / 10', html.includes('10 / 10'));
check('页面版本 = moon.mod', modVersion.length > 0 && html.includes(`v${modVersion}`));

for (const id of [
  'a',
  'b',
  'samples',
  'fn',
  'xmin',
  'xmax',
  'matrix-out',
  'stats-out',
  'plot-out',
  'kde',
  'plot',
  'retry',
]) {
  check(`演示钩子保留: ${id}`, html.includes(`id="${id}"`));
}
for (const run of ['matrix', 'stats', 'plot', 'retry']) {
  check(`演示动作保留: ${run}`, html.includes(`data-run="${run}"`));
}

// 2. build wasm if needed and keep docs copy in sync
if (!existsSync(WASM_BUILD)) {
  const r = spawnSync('moon build --target wasm-gc --release playground', {
    shell: true,
    encoding: 'utf8',
    cwd: ROOT,
  });
  check('build playground wasm', r.status === 0, (r.stderr ?? '').slice(0, 200));
}
if (existsSync(WASM_BUILD)) {
  copyFileSync(WASM_BUILD, WASM_DOCS);
}
check('docs/playground.wasm exists', existsSync(WASM_DOCS));

if (!existsSync(WASM_DOCS)) {
  process.exit(1);
}

// 3. instantiate + exports（WasmGC 需要 Node 22+ 或现代浏览器）
const bytes = readFileSync(WASM_DOCS);
let mod;
try {
  mod = new WebAssembly.Module(bytes);
} catch (error) {
  check(
    'wasm compiles (WasmGC)',
    false,
    `${error.message} — 需要 Node 22+ 或 Chrome 119+ / Firefox 120+ / Safari 18+`,
  );
  console.log(`\n=== pages check: FAIL (1) ===`);
  process.exit(1);
}
const imports = WebAssembly.Module.imports(mod);
check('wasm has no imports (self-contained)', imports.length === 0, `imports=${imports.length}`);
const { exports } = new WebAssembly.Instance(mod, {});
const expected = ['owl_dot4', 'owl_det2', 'owl_mean4', 'owl_var4', 'owl_gamma', 'owl_j0', 'owl_erf', 'owl_kde_pdf'];
for (const name of expected) check(`export: ${name}`, typeof exports[name] === 'function');

// 4. numeric parity
const near = (a, b, eps = 1e-9) => Math.abs(a - b) < eps;
check('dot4([1,2,3,4],[4,3,2,1]) = 20', exports.owl_dot4(1, 2, 3, 4, 4, 3, 2, 1) === 20);
check('det2(1,2,3,4) = -2', exports.owl_det2(1, 2, 3, 4) === -2);
check('mean4 = 2.75', near(exports.owl_mean4(1, 2, 3, 5), 2.75));
check('gamma(5) = 24', near(exports.owl_gamma(5), 24, 1e-9));
check('erf(1) = 0.8427007929', near(exports.owl_erf(1), 0.8427007929, 1e-6));
check('j0(2) = 0.2238907791', near(exports.owl_j0(2), 0.2238907791, 1e-6));
check('kde_pdf positive', exports.owl_kde_pdf(2.0, 1.0, 2.0, 3.0, 5.0) > 0);

console.log(`\n=== pages check: ${failures === 0 ? 'PASS' : `FAIL (${failures})`} ===`);
if (failures > 0) process.exit(1);