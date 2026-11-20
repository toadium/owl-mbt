#!/usr/bin/env node
// 变异测试 — 注入缺陷 → 跑全量测试 → KILLED/SURVIVED → 恢复 → 汇总。
// Mutation testing: mutate a line, run the suite, classify, restore, summarize.
//
// 用法：node scripts/mutation_test.mjs
// 红线：killed == total（100%）

import { spawnSync } from 'node:child_process';
import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';

const ROOT = fileURLToPath(new URL('..', import.meta.url));

const MUTATIONS = [
  { id: 'M01', file: 'stats/kde.mbt', old: 'let (mn, mx) = minmax(vs)', new: 'let (mn, mx) = (0.0, 0.0)', desc: 'kde point range collapsed' },
  { id: 'M02', file: 'stats/kde.mbt', old: 'if s <= 0.0 {', new: 'if s < 0.0 {', desc: 'kde constant-data guard removed' },
  { id: 'M03', file: 'maths/erf.mbt', old: 's * y', new: 'y', desc: 'erf sign handling dropped' },
  { id: 'M04', file: 'maths/erf.mbt', old: 'pub fn erfc(x : Double) -> Double {\n  1.0 - erf(x)', new: 'pub fn erfc(x : Double) -> Double {\n  erf(x) - 1.0', desc: 'erfc inverted' },
  { id: 'M05', file: 'maths/bessel.mbt', old: 'pub fn j0(x : Double) -> Double {\n  if x.is_nan() {\n    return x\n  }\n  let ax = x.abs()\n  if ax > _bessel_asymptotic_switch {', new: 'pub fn j0(x : Double) -> Double {\n  if x.is_nan() {\n    return x\n  }\n  let ax = x.abs()\n  if ax < _bessel_asymptotic_switch {', desc: 'j0 branch flipped' },
  { id: 'M06', file: 'maths/special.mbt', old: 'if x.is_nan() {\n    0.0 / 0.0', new: 'if false {\n    0.0 / 0.0', desc: 'signum NaN passthrough dropped' },
  { id: 'M07', file: 'maths/special.mbt', old: 'if x <= -37.0 {', new: 'if x <= -1.0 {', desc: 'log1pexp small-x branch widened' },
  { id: 'M08', file: 'misc/countmin.mbt', old: 'if l <= 0 || w <= 0 {', new: 'if l < 0 || w < 0 {', desc: 'cms zero-dimension guard loosened' },
  { id: 'M09', file: 'ndarray/matrix.mbt', old: 'data[i] = x.data[r * cols + c]', new: 'data[i] = x.data[i]', desc: 'diag ignores offsets' },
  { id: 'M10', file: 'ndarray/matrix.mbt', old: 'data[j] = x.data[i * cols + j]', new: 'data[j] = x.data[j]', desc: 'row extraction ignores row index' },
];

function run() {
  const r = spawnSync('moon test --target native', {
    shell: true,
    encoding: 'utf8',
    maxBuffer: 128 * 1024 * 1024,
    cwd: ROOT,
  });
  return r.status ?? 1;
}

console.log('=== baseline ===');
if (run() !== 0) {
  console.error('baseline tests are red; fix before mutation testing');
  process.exit(1);
}

let killed = 0;
let survived = 0;
let skipped = 0;
const results = [];
for (const m of MUTATIONS) {
  const p = join(ROOT, m.file);
  const original = readFileSync(p, 'utf8');
  const hits = original.split(m.old).length - 1;
  if (hits !== 1) {
    skipped++;
    results.push(`${m.id}: SKIPPED (occurrences=${hits}) — ${m.desc}`);
    continue;
  }
  writeFileSync(p, original.replace(m.old, m.new), 'utf8');
  const code = run();
  writeFileSync(p, original, 'utf8');
  if (code === 0) {
    survived++;
    results.push(`${m.id}: SURVIVED — ${m.desc}`);
  } else {
    killed++;
    results.push(`${m.id}: KILLED — ${m.desc}`);
  }
}

const finalCode = run();
for (const r of results) console.log(r);
console.log('=== mutation summary ===');
console.log(`killed=${killed} survived=${survived} skipped=${skipped} total=${MUTATIONS.length}`);
if (finalCode !== 0) {
  console.error('WARNING: baseline failing after restore — manual check needed');
  process.exit(1);
}
if (survived > 0 || skipped > 0) {
  console.error('FAIL: survived/skipped above zero');
  process.exit(1);
}
console.log('PASS: all mutations killed');