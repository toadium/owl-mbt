// owl-mbt WebAssembly 在线演示：加载 WasmGC 模块并驱动交互。
// All computation below runs inside the browser WebAssembly instance.
// 8 个导出函数的参数顺序与公式保持不变；自检会逐项验证数值。

let wasm = null;

const $ = (sel) => document.querySelector(sel);
const reduceMotion = () =>
  window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

const esc = (s) =>
  String(s).replace(/[&<>"']/g, (c) => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
  })[c]);

// 沿用原有规则：6 位小数截断 + 大/小数值走指数格式。
function fmt(x) {
  if (!Number.isFinite(x)) return String(x);
  if (Math.abs(x) >= 1e4 || (Math.abs(x) > 0 && Math.abs(x) < 1e-3)) {
    return x.toExponential(4);
  }
  return String(Math.round(x * 1e6) / 1e6);
}

const OUT = {
  matrix: '#matrix-out',
  stats: '#stats-out',
  plot: '#plot-out',
};

const buttons = Array.from(document.querySelectorAll('button[data-run]'));
const baseDesc = new WeakMap();
document.querySelectorAll('input[aria-describedby], select[aria-describedby]').forEach((el) => {
  baseDesc.set(el, el.getAttribute('aria-describedby'));
});

// ---------------------------------------------------------------------------
// 输出框：容器 role/aria-live 固定，内部错误元素单独 role="alert"。
// ---------------------------------------------------------------------------
function setOut(sel, kind, body, trace) {
  const el = $(sel);
  if (!el) return;
  if (kind === 'error') {
    el.className = 'out is-error';
    el.innerHTML = `<span class="out-error" role="alert">⚠ 错误：${esc(body)}</span>`;
    return;
  }
  if (kind === 'success') {
    el.className = 'out is-success';
    el.innerHTML =
      `<span class="out-ok" aria-hidden="true">✓</span> ${esc(body)}` +
      (trace ? `\n<span class="out-trace">${esc(trace)}</span>` : '');
    return;
  }
  const cls = kind === 'loading' || kind === 'busy' ? 'is-loading' : kind === 'ready' ? 'is-ready' : '';
  el.className = cls ? `out ${cls}` : 'out';
  el.textContent = body;
}

function setFieldError(input, outputSel, bad) {
  if (!input) return;
  if (bad) {
    input.setAttribute('aria-invalid', 'true');
    const base = baseDesc.get(input) || '';
    const outId = $(outputSel)?.id;
    input.setAttribute('aria-describedby', [base, outId].filter(Boolean).join(' '));
  } else {
    input.removeAttribute('aria-invalid');
    const base = baseDesc.get(input);
    if (base) input.setAttribute('aria-describedby', base);
    else input.removeAttribute('aria-describedby');
  }
}

// ---------------------------------------------------------------------------
// 输入校验：逐项 Number.isFinite，定位到出错的序号与原始文本。
// ---------------------------------------------------------------------------
function parseFour(text, prefix) {
  const items = String(text).split(/[\s,;]+/).filter(Boolean);
  const values = [];
  for (let i = 0; i < items.length; i++) {
    const v = Number(items[i]);
    if (!Number.isFinite(v)) {
      return { error: `${prefix}；第 ${i + 1} 项「${items[i]}」无法解析。`, badIndex: i };
    }
    values.push(v);
  }
  if (values.length !== 4) return { error: `${prefix}。` };
  return { values };
}

function getFn(key) {
  const table = {
    gamma: { name: 'Γ(x)', color: '#5EEAD4', f: (x) => wasm.owl_gamma(x), exportName: 'owl_gamma' },
    erf: { name: 'erf(x)', color: '#A78BFA', f: (x) => wasm.owl_erf(x), exportName: 'owl_erf' },
    j0: { name: 'J₀(x)', color: '#F59E0B', f: (x) => wasm.owl_j0(x), exportName: 'owl_j0' },
  };
  return table[key] || null;
}

// ---------------------------------------------------------------------------
// Canvas：按 CSS 显示尺寸 × devicePixelRatio 设置 backing store，
// 绘制坐标统一使用 CSS px（ctx 已 setTransform(dpr)）。
// ---------------------------------------------------------------------------
const PAD = { l: 56, r: 18, t: 24, b: 36 };

function prepCanvas(canvas) {
  const dpr = window.devicePixelRatio || 1;
  const rect = canvas.getBoundingClientRect();
  const W = Math.max(1, Math.round(rect.width || canvas.clientWidth || canvas.width));
  const H = Math.max(1, Math.round(rect.height || canvas.clientHeight || canvas.height));
  const bw = Math.round(W * dpr);
  const bh = Math.round(H * dpr);
  if (canvas.width !== bw || canvas.height !== bh) {
    canvas.width = bw;
    canvas.height = bh;
  }
  const ctx = canvas.getContext('2d');
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  return { ctx, W, H };
}

function drawGrid(ctx, W, H) {
  ctx.strokeStyle = 'rgba(148,163,184,0.16)';
  ctx.lineWidth = 1;
  for (let i = 0; i <= 4; i++) {
    const y = PAD.t + ((H - PAD.t - PAD.b) * i) / 4;
    ctx.beginPath();
    ctx.moveTo(PAD.l, y);
    ctx.lineTo(W - PAD.r, y);
    ctx.stroke();
  }
}

function drawEmpty(canvas, message, grid = true) {
  if (!canvas) return;
  canvas._token = (canvas._token || 0) + 1; // 取消上一轮 rAF 揭示动画
  canvas._render = { type: 'empty', message, grid };
  const { ctx, W, H } = prepCanvas(canvas);
  ctx.clearRect(0, 0, W, H);
  ctx.fillStyle = '#070B18';
  ctx.fillRect(0, 0, W, H);
  if (grid) drawGrid(ctx, W, H);
  if (message) {
    ctx.fillStyle = '#9AA8CC';
    ctx.font = '14px ui-monospace, monospace';
    ctx.textAlign = 'left';
    const tw = ctx.measureText(message).width;
    ctx.fillText(message, Math.max(12, (W - tw) / 2), H / 2);
  }
}

function paintBackground(ctx, g) {
  const { W, H, lo, hi, xmin, xmax } = g;
  ctx.fillStyle = '#070B18';
  ctx.fillRect(0, 0, W, H);
  drawGrid(ctx, W, H);

  // 刻度：12px mono / --chart-axis
  ctx.fillStyle = '#9AA8CC';
  ctx.font = '12px ui-monospace, monospace';
  ctx.textAlign = 'left';
  ctx.fillText(fmt(hi), 6, PAD.t + 4);
  ctx.fillText(fmt(lo), 6, H - PAD.b);
  ctx.fillText(fmt(xmin), PAD.l, H - 12);
  ctx.textAlign = 'right';
  ctx.fillText(fmt(xmax), W - PAD.r, H - 12);
  ctx.textAlign = 'left';

  // 零线：仅 1px，无垂直网格
  if (lo < 0 && hi > 0) {
    ctx.strokeStyle = 'rgba(148,163,184,0.35)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(PAD.l, g.py(0));
    ctx.lineTo(W - PAD.r, g.py(0));
    ctx.stroke();
  }

  // 系列标签：13px sans + （wasm）
  ctx.fillStyle = g.color;
  ctx.font = '13px ui-sans-serif, system-ui, sans-serif';
  ctx.fillText(`${g.label}（wasm）`, PAD.l + 8, PAD.t + 16);
}

function paintCurve(ctx, g, fraction) {
  const last = Math.max(1, Math.floor(fraction * (g.pts.length - 1)));
  ctx.strokeStyle = g.color;
  ctx.lineWidth = 2;
  ctx.lineJoin = 'round';
  ctx.lineCap = 'round';
  ctx.shadowBlur = 0;
  ctx.beginPath();
  let started = false;
  for (let i = 0; i <= last; i++) {
    const [x, y] = g.pts[i];
    if (!Number.isFinite(y)) {
      started = false; // 非有限值处断线
      continue;
    }
    const sx = g.px(x);
    const sy = g.py(y);
    if (!started) {
      ctx.moveTo(sx, sy);
      started = true;
    } else {
      ctx.lineTo(sx, sy);
    }
  }
  ctx.stroke();
}

function renderCurve(canvas, spec, animate) {
  if (!canvas || !spec || typeof spec.f !== 'function') return;
  if (canvas.getAttribute('aria-label') !== spec.aria) {
    canvas.setAttribute('aria-label', spec.aria || '由 WebAssembly 计算的曲线');
  }
  const token = (canvas._token || 0) + 1;
  canvas._token = token;
  canvas._render = { type: 'curve', spec };

  const { ctx, W, H } = prepCanvas(canvas);
  const pts = [];
  for (let i = 0; i < spec.n; i++) {
    const x = spec.xmin + ((spec.xmax - spec.xmin) * i) / (spec.n - 1);
    pts.push([x, spec.f(x)]);
  }
  const finite = pts.filter(([, y]) => Number.isFinite(y));
  if (finite.length < 2) {
    canvas.setAttribute('aria-label', '曲线不可用：当前区间内没有有限值');
    drawEmpty(canvas, '该区间内没有有限值（尝试调整区间）', true);
    return;
  }

  const ys = finite.map(([, y]) => y);
  const ymin = Math.min(...ys);
  const ymax = Math.max(...ys);
  const span = ymax - ymin || 1;
  const padY = span * 0.08;
  const lo = ymin - padY;
  const hi = ymax + padY;
  const g = {
    W,
    H,
    pts,
    color: spec.color,
    label: spec.label,
    lo,
    hi,
    xmin: spec.xmin,
    xmax: spec.xmax,
    px: (x) => PAD.l + ((x - spec.xmin) / (spec.xmax - spec.xmin)) * (W - PAD.l - PAD.r),
    py: (y) => H - PAD.b - ((y - lo) / (hi - lo)) * (H - PAD.t - PAD.b),
  };

  // 每帧先 clear 再重绘背景与局部曲线，不闪烁。
  const paint = (fraction) => {
    ctx.clearRect(0, 0, W, H);
    paintBackground(ctx, g);
    paintCurve(ctx, g, fraction);
  };

  if (!animate || reduceMotion()) {
    paint(1);
    return;
  }
  const duration = 500;
  let start = null;
  const frame = (ts) => {
    if (canvas._token !== token) return; // 新点击取消上一轮，不排队不叠加
    if (start === null) start = ts;
    const t = Math.min(1, (ts - start) / duration);
    paint(t);
    if (t < 1) requestAnimationFrame(frame);
  };
  requestAnimationFrame(frame);
}

// ---------------------------------------------------------------------------
// 三个演示动作：8 个 wasm 导出函数的调用与公式保持原样。
// ---------------------------------------------------------------------------
function runMatrix() {
  if (!wasm) return;
  const aInput = $('#a');
  const bInput = $('#b');
  const prefix = '两个向量都需要 4 个有效数字（逗号或空格分隔）';
  const aRes = parseFour(aInput.value, prefix);
  const bRes = parseFour(bInput.value, prefix);
  const bad = aRes.error || bRes.error;
  if (bad) {
    setFieldError(aInput, OUT.matrix, !!aRes.error);
    setFieldError(bInput, OUT.matrix, !!bRes.error);
    setOut(OUT.matrix, 'error', bad);
    return;
  }
  setFieldError(aInput, OUT.matrix, false);
  setFieldError(bInput, OUT.matrix, false);

  const a = aRes.values;
  const b = bRes.values;
  const dot = wasm.owl_dot4(a[0], a[1], a[2], a[3], b[0], b[1], b[2], b[3]);
  const det = wasm.owl_det2(a[0], a[1], b[0], b[1]);
  setOut(
    OUT.matrix,
    'success',
    `a = [${a.join(', ')}]\nb = [${b.join(', ')}]\n` +
      `dot(a, b) = ${fmt(dot)}\n` +
      `det[[a0,a1],[b0,b1]] = ${fmt(det)}`,
    '调用：owl_dot4 / owl_det2（wasm-gc）',
  );
}

function runStats() {
  if (!wasm) return;
  const input = $('#samples');
  const res = parseFour(input.value, '请输入 4 个有效数字（逗号或空格分隔）');
  if (res.error) {
    setFieldError(input, OUT.stats, true);
    setOut(OUT.stats, 'error', `${res.error} 曲线仍显示上一次结果。`);
    return; // 绝不清空 canvas
  }
  setFieldError(input, OUT.stats, false);

  const vs = res.values;
  const mean = wasm.owl_mean4(vs[0], vs[1], vs[2], vs[3]);
  const variance = wasm.owl_var4(vs[0], vs[1], vs[2], vs[3]);
  setOut(
    OUT.stats,
    'success',
    `样本 = [${vs.join(', ')}]\nmean = ${fmt(mean)}\nvariance = ${fmt(variance)}`,
    '调用：owl_mean4 / owl_var4 / owl_kde_pdf（wasm-gc）',
  );

  const lo = Math.min(...vs) - 1.5;
  const hi = Math.max(...vs) + 1.5;
  renderCurve(
    $('#kde'),
    {
      xmin: lo,
      xmax: hi,
      n: 180,
      f: (x) => wasm.owl_kde_pdf(x, vs[0], vs[1], vs[2], vs[3]),
      label: '高斯 KDE',
      color: '#5EEAD4',
      aria: `高斯核密度曲线，样本 [${vs.join(', ')}]，横轴 [${fmt(lo)}, ${fmt(hi)}]，由 WebAssembly 计算。`,
    },
    true,
  );
}

function runPlot() {
  if (!wasm) return;
  const xminInput = $('#xmin');
  const xmaxInput = $('#xmax');
  const xmin = Number(xminInput.value);
  const xmax = Number(xmaxInput.value);
  const badMin = !Number.isFinite(xmin);
  const badMax = !Number.isFinite(xmax);
  if (badMin || badMax || xmin >= xmax) {
    const relationBad = !badMin && !badMax && xmin >= xmax;
    setFieldError(xminInput, OUT.plot, badMin || relationBad);
    setFieldError(xmaxInput, OUT.plot, badMax || relationBad);
    setOut(OUT.plot, 'error', '起点必须小于终点，且为有限数。曲线仍显示上一次结果。');
    return; // 绝不清空 canvas
  }
  setFieldError(xminInput, OUT.plot, false);
  setFieldError(xmaxInput, OUT.plot, false);

  const table = getFn($('#fn').value);
  if (!table) {
    setOut(OUT.plot, 'error', '未知的函数选项。曲线仍显示上一次结果。');
    return;
  }
  renderCurve(
    $('#plot'),
    {
      xmin,
      xmax,
      n: 220,
      f: table.f,
      label: table.name,
      color: table.color,
      aria: `${table.name} 曲线，x 从 ${fmt(xmin)} 到 ${fmt(xmax)}，220 个采样点，由 WebAssembly 计算。`,
    },
    true,
  );
  setOut(
    OUT.plot,
    'success',
    `${table.name} 在 [${fmt(xmin)}, ${fmt(xmax)}] 采样 220 点，由 WebAssembly 实时计算。`,
    `调用：${table.exportName}（wasm-gc）`,
  );
}

// ---------------------------------------------------------------------------
// 加载状态机 G0 / G1 / G2。
// ---------------------------------------------------------------------------
function beginLoading() {
  wasm = null;
  buttons.forEach((b) => {
    if (b.dataset.run === 'retry') return;
    b.setAttribute('aria-disabled', 'true');
    b.classList.add('is-disabled');
  });
  setOut(OUT.matrix, 'loading', '正在加载 WebAssembly…');
  setOut(OUT.stats, 'loading', '正在加载 WebAssembly…');
  setOut(OUT.plot, 'loading', '正在加载 WebAssembly…');
  $('#retry').hidden = true;
  drawEmpty($('#plot'), null, true); // G0：空网格占位，无错误图形
  drawEmpty($('#kde'), null, true);
  $('#plot').setAttribute('aria-label', '曲线加载中：正在初始化 WebAssembly');
  $('#kde').setAttribute('aria-label', '曲线加载中：正在初始化 WebAssembly');
}

function setControlsReady(ready) {
  buttons.forEach((b) => {
    if (b.dataset.run === 'retry') return;
    if (ready) {
      b.removeAttribute('aria-disabled');
      b.classList.remove('is-disabled');
    } else {
      b.setAttribute('aria-disabled', 'true');
      b.classList.add('is-disabled');
    }
  });
  ['#a', '#b', '#samples', '#fn', '#xmin', '#xmax'].forEach((sel) => {
    const el = $(sel);
    if (el) el.disabled = !ready;
  });
}

const TROUBLESHOOT =
  '排查：① 用 Chrome 119+ / Firefox 120+ / Safari 18+；② 通过 http(s) 打开本页，不要双击本地文件；③ 刷新重试；④ 仍失败请到 GitHub 反馈。';

function failureMessage(kind, detail) {
  if (kind === 'file') {
    return '检测到 file:// 协议：请通过 GitHub Pages 地址或本地 HTTP 服务访问，直接双击打开的本地文件无法加载 WebAssembly。';
  }
  if (kind === 'http') {
    return `无法加载 WebAssembly（HTTP ${detail}）。本页所有计算都在你自己的浏览器里完成，因此演示暂不可用；上方介绍与下方说明仍可正常阅读。${TROUBLESHOOT}`;
  }
  if (kind === 'noglobal') {
    return `当前环境没有 WebAssembly 全局对象，无法加载计算模块。本页所有计算都在你自己的浏览器里完成，因此演示暂不可用；上方介绍与下方说明仍可正常阅读。${TROUBLESHOOT}`;
  }
  return `无法加载 WebAssembly（${detail || '模块初始化失败'}）：可能是浏览器不支持 WasmGC 或模块损坏。本页所有计算都在你自己的浏览器里完成，因此演示暂不可用；上方介绍与下方说明仍可正常阅读。${TROUBLESHOOT}`;
}

function fail(kind, detail) {
  wasm = null;
  const message = failureMessage(kind, detail);
  [OUT.matrix, OUT.stats, OUT.plot].forEach((id) => setOut(id, 'error', message));
  setControlsReady(false);
  $('#retry').hidden = false;
  drawEmpty($('#kde'), 'WebAssembly 未加载，无法绘制', true);
  drawEmpty($('#plot'), 'WebAssembly 未加载，无法绘制', true);
  $('#kde').setAttribute('aria-label', '曲线不可用：WebAssembly 未加载');
  $('#plot').setAttribute('aria-label', '曲线不可用：WebAssembly 未加载');
}

async function init() {
  beginLoading();

  if (location.protocol === 'file:') {
    fail('file');
    return;
  }
  if (typeof WebAssembly === 'undefined') {
    fail('noglobal');
    return;
  }

  try {
    const response = await fetch('playground.wasm');
    if (!response.ok) {
      const err = new Error(`HTTP ${response.status} for playground.wasm`);
      err.http = response.status;
      throw err;
    }
    const bytes = await response.arrayBuffer();
    const { instance } = await WebAssembly.instantiate(bytes, {});
    wasm = instance.exports;

    setControlsReady(true);
    $('#retry').hidden = true;
    setOut(OUT.matrix, 'ready', 'wasm 已就绪：点击「计算」。');
    setOut(OUT.stats, 'ready', 'wasm 已就绪：点击「计算」。');
    setOut(
      OUT.plot,
      'success',
      '示例：Γ(x) 在 [0.5, 5.0] 采样 220 点，由 WebAssembly 实时计算。',
      '调用：owl_gamma（wasm-gc）',
    );

    // G1：卡③自动绘制一次示例曲线（T1）。
    const sample = getFn('gamma');
    renderCurve(
      $('#plot'),
      {
        xmin: 0.5,
        xmax: 5.0,
        n: 220,
        f: sample.f,
        label: sample.name,
        color: sample.color,
        aria: '示例曲线：Γ(x)，x 从 0.5 到 5.0，220 个采样点，由 WebAssembly 计算。',
      },
      true,
    );
    drawEmpty($('#kde'), '点击「计算」查看 KDE 曲线', true);
    $('#kde').setAttribute('aria-label', '高斯核密度曲线区域：点击计算后由 WebAssembly 绘制');
  } catch (error) {
    if (error && error.http) fail('http', error.http);
    else fail('instantiate', error && error.message ? error.message : String(error));
  }
}

// ---------------------------------------------------------------------------
// 事件绑定：不用 HTML disabled，保留键盘可发现性；焦点始终留在按钮上。
// ---------------------------------------------------------------------------
buttons.forEach((button) => {
  button.addEventListener('click', () => {
    const kind = button.dataset.run;
    if (button.getAttribute('aria-disabled') === 'true') {
      if (kind !== 'retry' && !wasm) {
        setOut(OUT[kind] || OUT.matrix, 'loading', 'WebAssembly 仍在加载，请稍候…');
      }
      return;
    }
    if (kind === 'retry') {
      init();
      return;
    }
    const outId = OUT[kind];
    button.setAttribute('aria-busy', 'true');
    // wasm 调用为亚毫秒级：仅当超过 150ms 才显示“计算中”，避免闪烁。
    const timer = setTimeout(() => setOut(outId, 'busy', '正在用 wasm 计算…'), 150);
    try {
      if (kind === 'matrix') runMatrix();
      else if (kind === 'stats') runStats();
      else if (kind === 'plot') runPlot();
    } catch (error) {
      setOut(outId, 'error', `计算失败：${error && error.message ? error.message : String(error)}`);
    } finally {
      clearTimeout(timer);
      button.removeAttribute('aria-busy');
    }
  });
});

// 视口变化后按新的 CSS 尺寸重设 backing store；不重启动画，不排队。
let resizeTimer = null;
window.addEventListener('resize', () => {
  clearTimeout(resizeTimer);
  resizeTimer = setTimeout(() => {
    [$('#kde'), $('#plot')].forEach((canvas) => {
      const r = canvas && canvas._render;
      if (!r) return;
      canvas._token = (canvas._token || 0) + 1;
      if (r.type === 'curve') renderCurve(canvas, r.spec, false);
      else drawEmpty(canvas, r.message, r.grid);
    });
  }, 150);
});

init();
