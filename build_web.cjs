// Monta o jogo web num único HTML. "cdn" = versão para publicar, "local" = para testes offline.
const fs = require('fs');
const mode = process.argv[2] || 'cdn';
const b64 = f => 'data:image/png;base64,' + fs.readFileSync(f).toString('base64');
let html = fs.readFileSync('web/template.html', 'utf8');
const inkjs = mode === 'cdn' ? 'https://cdn.jsdelivr.net/npm/inkjs@2.2.3/dist/ink.js' : 'ink.js';
html = html.replace('{{INKJS}}', inkjs)
  .replace('{{V5}}', () => fs.readFileSync('web/v5.js', 'utf8'))
  .replace('{{STORY}}', () => fs.readFileSync('ink/rayo.json', 'utf8'))
  .replace('{{BG}}', b64('art/bar.png')).replace('{{RAYO}}', b64('art/rayo.png')).replace('{{CAPACETE}}', b64('art/capacete.png'));
fs.mkdirSync('dist', { recursive: true });
const out = mode === 'cdn' ? 'dist/index.html' : 'dist/local.html';
fs.writeFileSync(out, html);
if (mode === 'local') fs.copyFileSync('node_modules/inkjs/dist/ink.js', 'dist/ink.js');
console.log(out, html.length, 'bytes');
