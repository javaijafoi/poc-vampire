const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch();
  const res = [];
  for (const thr of [1, 4]) {
    const runs = [];
    for (let k = 0; k < 7; k++) {
      const ctx = await b.newContext({ viewport: { width: 1280, height: 800 } });
      const p = await ctx.newPage();
      await p.route(/fonts\.(googleapis|gstatic)/, r => r.abort());
      const cdp = await ctx.newCDPSession(p);
      await cdp.send('Emulation.setCPUThrottlingRate', { rate: thr });
      await p.goto('file://' + process.cwd() + '/dist/local.html');
      await p.waitForFunction(() => window.__primeiroTexto, null, { timeout: 10000 });
      const m = await p.evaluate(() => ({ first: window.__primeiroTexto, heap: performance.memory ? performance.memory.usedJSHeapSize : 0 }));
      runs.push(m); await ctx.close();
    }
    runs.sort((a, b) => a.first - b.first);
    const med = runs[3];
    res.push({ cpu: thr === 1 ? 'normal' : '4x mais lenta', primeiro_texto_ms: Math.round(med.first), heap_mb: (med.heap / 1048576).toFixed(1) });
  }
  console.table(res);
  await b.close();
})();
