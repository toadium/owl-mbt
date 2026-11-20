// owl-mbt WebAssembly 在线演示：加载 WasmGC 模块并驱动交互。
// All computation below runs inside the browser WebAssembly instance.

let wasm = null;

const $ = (sel) => document.querySelector(sel);

function parseList(text) {
  return text
    .split(/[\s,;]+/)
    .filter((s) => s.length > 0)
    .map((s) => Number(s));
}

function fmt(x) {
  if (!Number.isFinite(x)) return String(x);
  if (Math.abs(x) >= 1e4 || (Math.abs(x) > 0 && Math.abs(x) < 1e-3)) {
    return x.toExponential(4);
  }
  return String(Math.round(x * 1e6) / 1e6);
}

function setOut(id, text) {
  $(id).textContent = text;
}

async function init() {
  try {
    const response = await fetch("playground.wasm");
    if (!response.ok) throw new Error(`HTTP ${response.status} for playground.wasm`);
    const bytes = await response.arrayBuffer();
    const { instance } = await WebAssembly.instantiate(bytes, {});
    wasm = instance.exports;
    setOut("#matrix-out", "wasm 已就绪：点击「计算」。");
    setOut("#stats-out", "wasm 已就绪：点击「计算」。");
    setOut("#plot-out", "wasm 已就绪：点击「绘制」。");
    document.querySelectorAll("button[data-run]").forEach((b) => (b.disabled = false));
    drawPlot();
  } catch (error) {
    const message =
      "无法加载 WebAssembly：" +
      error.message +
      "\n请使用支持 WasmGC 的浏览器（Chrome 119+ / Firefox 120+ / Safari 18+），并通过 HTTP(S) 访问本页。";
    setOut("#matrix-out", message);
    setOut("#stats-out", message);
    setOut("#plot-out", message);
  }
}

function runMatrix() {
  if (!wasm) return;
  try {
    const a = parseList($("#a").value);
    const b = parseList($("#b").value);
    if (a.length !== 4 || b.length !== 4) {
      throw new Error("两个向量都需要 4 个数，例如 1,2,3,4");
    }
    const dot = wasm.owl_dot4(a[0], a[1], a[2], a[3], b[0], b[1], b[2], b[3]);
    const det = wasm.owl_det2(a[0], a[1], b[0], b[1]);
    setOut(
      "#matrix-out",
      `a = [${a.join(", ")}]\nb = [${b.join(", ")}]\n` +
        `dot(a, b) = ${fmt(dot)}\n` +
        `det[[a0,a1],[b0,b1]] = ${fmt(det)}\n` +
        `调用：owl_dot4 / owl_det2（wasm-gc）`,
    );
  } catch (error) {
    setOut("#matrix-out", "错误：" + error.message);
  }
}

function runStats() {
  if (!wasm) return;
  try {
    const vs = parseList($("#samples").value);
    if (vs.length !== 4) throw new Error("请输入 4 个样本，例如 1.0,2.0,3.0,5.0");
    const mean = wasm.owl_mean4(vs[0], vs[1], vs[2], vs[3]);
    const variance = wasm.owl_var4(vs[0], vs[1], vs[2], vs[3]);
    setOut(
      "#stats-out",
      `样本 = [${vs.join(", ")}]\nmean = ${fmt(mean)}\nvariance = ${fmt(variance)}\n` +
        `调用：owl_mean4 / owl_var4 / owl_kde_pdf`,
    );
    const lo = Math.min(...vs) - 1.5;
    const hi = Math.max(...vs) + 1.5;
    drawCurve(
      $("#kde"),
      lo,
      hi,
      180,
      (x) => wasm.owl_kde_pdf(x, vs[0], vs[1], vs[2], vs[3]),
      "高斯 KDE",
      "#5eead4",
    );
  } catch (error) {
    setOut("#stats-out", "错误：" + error.message);
  }
}

function runPlot() {
  if (!wasm) return;
  const fn = $("#fn").value;
  const xmin = Number($("#xmin").value);
  const xmax = Number($("#xmax").value);
  if (!Number.isFinite(xmin) || !Number.isFinite(xmax) || xmin >= xmax) {
    setOut("#plot-out", "错误：起点必须小于终点，且为有限数");
    return;
  }
  const table = {
    gamma: { name: "Γ(x)", color: "#5eead4", f: (x) => wasm.owl_gamma(x) },
    erf: { name: "erf(x)", color: "#a78bfa", f: (x) => wasm.owl_erf(x) },
    j0: { name: "J₀(x)", color: "#f59e0b", f: (x) => wasm.owl_j0(x) },
  }[fn];
  drawCurve($("#plot"), xmin, xmax, 220, table.f, table.name, table.color);
  setOut(
    "#plot-out",
    `${table.name} 在 [${fmt(xmin)}, ${fmt(xmax)}] 采样 220 点，全部由 wasm 计算。`,
  );
}

function drawPlot() {
  if (!wasm) return;
  runPlot();
}

function drawCurve(canvas, xmin, xmax, n, f, label, color) {
  const ctx = canvas.getContext("2d");
  const W = canvas.width;
  const H = canvas.height;
  ctx.clearRect(0, 0, W, H);
  ctx.fillStyle = "#070d1d";
  ctx.fillRect(0, 0, W, H);

  const pad = { l: 56, r: 18, t: 24, b: 36 };
  const points = [];
  for (let i = 0; i < n; i++) {
    const x = xmin + ((xmax - xmin) * i) / (n - 1);
    const y = f(x);
    points.push([x, y]);
  }
  const finite = points.filter(([, y]) => Number.isFinite(y));
  if (finite.length < 2) {
    ctx.fillStyle = "#9aa8cc";
    ctx.font = "14px ui-monospace, monospace";
    ctx.fillText("该区间内没有有限值（尝试调整区间）", pad.l, H / 2);
    return;
  }
  const ys = finite.map(([, y]) => y);
  const ymin = Math.min(...ys);
  const ymax = Math.max(...ys);
  const span = ymax - ymin || 1;
  const padY = span * 0.08;
  const lo = ymin - padY;
  const hi = ymax + padY;
  const px = (x) => pad.l + ((x - xmin) / (xmax - xmin)) * (W - pad.l - pad.r);
  const py = (y) => H - pad.b - ((y - lo) / (hi - lo)) * (H - pad.t - pad.b);

  // grid
  ctx.strokeStyle = "rgba(148,163,184,0.16)";
  ctx.lineWidth = 1;
  for (let i = 0; i <= 4; i++) {
    const y = pad.t + ((H - pad.t - pad.b) * i) / 4;
    ctx.beginPath();
    ctx.moveTo(pad.l, y);
    ctx.lineTo(W - pad.r, y);
    ctx.stroke();
  }
  // axes labels
  ctx.fillStyle = "#9aa8cc";
  ctx.font = "12px ui-monospace, monospace";
  ctx.fillText(fmt(hi), 6, pad.t + 4);
  ctx.fillText(fmt(lo), 6, H - pad.b);
  ctx.fillText(fmt(xmin), pad.l, H - 12);
  ctx.textAlign = "right";
  ctx.fillText(fmt(xmax), W - pad.r, H - 12);
  ctx.textAlign = "left";

  // zero line
  if (lo < 0 && hi > 0) {
    ctx.strokeStyle = "rgba(148,163,184,0.35)";
    ctx.beginPath();
    ctx.moveTo(pad.l, py(0));
    ctx.lineTo(W - pad.r, py(0));
    ctx.stroke();
  }

  // curve (break on non-finite)
  ctx.strokeStyle = color;
  ctx.lineWidth = 2;
  ctx.beginPath();
  let started = false;
  for (const [x, y] of points) {
    if (!Number.isFinite(y)) {
      started = false;
      continue;
    }
    const sx = px(x);
    const sy = py(y);
    if (!started) {
      ctx.moveTo(sx, sy);
      started = true;
    } else {
      ctx.lineTo(sx, sy);
    }
  }
  ctx.stroke();

  // label
  ctx.fillStyle = color;
  ctx.font = "13px ui-sans-serif, system-ui, sans-serif";
  ctx.fillText(label + "（wasm）", pad.l + 8, pad.t + 16);
}

document.querySelectorAll("button[data-run]").forEach((button) => {
  button.disabled = true;
  button.addEventListener("click", () => {
    const kind = button.dataset.run;
    if (kind === "matrix") runMatrix();
    else if (kind === "stats") runStats();
    else if (kind === "plot") runPlot();
  });
});

init();