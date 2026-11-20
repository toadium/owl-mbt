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

// 3. instantiate + exports
const bytes = readFileSync(WASM_DOCS);
const mod = new WebAssembly.Module(bytes);
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