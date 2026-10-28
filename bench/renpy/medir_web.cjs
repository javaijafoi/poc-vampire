// Mede a versão web do Ren'Py no Chromium: bytes baixados e tempo até a primeira tela.
// Uso: node bench/renpy/medir_web.cjs <pasta do build web> [repetições]
// O servidor compacta com gzip, como um site de hospedagem faria.
const http = require('http');
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');
const { chromium } = require('playwright');

const raiz = path.resolve(process.argv[2]);
const vezes = Number(process.argv[3] || 3);
const tipos = { '.html': 'text/html', '.js': 'text/javascript', '.wasm': 'application/wasm', '.json': 'application/json', '.jpg': 'image/jpeg', '.png': 'image/png' };
const cache = new Map();
let enviados = 0;

const servidor = http.createServer((req, res) => {
  const arq = path.join(raiz, decodeURIComponent(req.url.split('?')[0]).replace(/\/$/, '/index.html'));
  if (!arq.startsWith(raiz) || !fs.existsSync(arq) || fs.statSync(arq).isDirectory()) { res.writeHead(404); return res.end(); }
  if (!cache.has(arq)) cache.set(arq, zlib.gzipSync(fs.readFileSync(arq), { level: 6 }));
  res.writeHead(200, { 'Content-Type': tipos[path.extname(arq)] || 'application/octet-stream', 'Content-Encoding': 'gzip', 'Cache-Control': 'no-store' });
  enviados += cache.get(arq).length;
  res.end(cache.get(arq));
});

(async () => {
  await new Promise(r => servidor.listen(0, r));
  const url = `http://127.0.0.1:${servidor.address().port}/`;
  const resultados = [];
  for (let i = 0; i < vezes; i++) {
    // Navegador novo a cada vez: nada em cache, como na primeira visita de um jogador.
    const browser = await chromium.launch({ args: ['--autoplay-policy=no-user-gesture-required'] });
    enviados = 0;
    const ctx = await browser.newContext({ viewport: { width: 1280, height: 720 } });
    const page = await ctx.newPage();
    const cdp = await ctx.newCDPSession(page);
    await page.goto(url);
    await page.waitForFunction(() => window.porao_primeira_tela, null, { timeout: 120000, polling: 50 });
    const ms = await page.evaluate(() => window.porao_primeira_tela);
    const memoria = (await cdp.send('Runtime.getHeapUsage')).usedSize;
    const r = { ms: Math.round(ms), mb_baixados: +(enviados / 1e6).toFixed(1), heap_js_mb: +(memoria / 1e6).toFixed(1) };
    resultados.push(r);
    console.log(JSON.stringify(r));
    if (i === vezes - 1 && process.env.PORAO_SHOT) await page.waitForTimeout(1500), await page.screenshot({ path: process.env.PORAO_SHOT });
    await browser.close();
  }
  const ms = resultados.map(r => r.ms).sort((a, b) => a - b);
  console.log(`Primeira tela na web: mediana ${ms[Math.floor(ms.length / 2)]} ms ${JSON.stringify(ms)}, download ${resultados[0].mb_baixados} MB compactado`);
  servidor.close();
})();
