// Monta o jogo web num único HTML. "cdn" = versão para publicar, "local" = para testes offline.
const fs = require('fs');
const mode = process.argv[2] || 'cdn';
const MIME = { png: 'image/png', webp: 'image/webp', jpg: 'image/jpeg' };
const b64 = f => `data:${MIME[f.split('.').pop()]};base64,` + fs.readFileSync(f).toString('base64');
// uma imagem por personagem e expressão: art/cena/<personagem>_<expressao>.webp
const personagens = {};
for (const f of fs.readdirSync('art/cena')) {
  const m = f.match(/^([a-z]+)_([a-z]+)\.webp$/);
  if (m) (personagens[m[1]] ??= {})[m[2]] = b64('art/cena/' + f);
}
let html = fs.readFileSync('web/template.html', 'utf8');
const inkjs = mode === 'cdn' ? 'https://cdn.jsdelivr.net/npm/inkjs@2.2.3/dist/ink.js' : 'ink.js';
html = html.replace('{{INKJS}}', inkjs)
  .replace('{{V5}}', () => fs.readFileSync('web/v5.js', 'utf8'))
  .replace('{{STORY}}', () => fs.readFileSync('ink/rayo.json', 'utf8'))
  .replace('{{BG}}', () => b64('art/cena/fundo.webp')).replace('{{MOLDURA}}', () => b64('art/cena/moldura.webp')).replace('{{RASGO}}', () => b64('art/cena/rasgo.png')).replace('{{PERSONAGENS}}', () => JSON.stringify(personagens));
fs.mkdirSync('dist', { recursive: true });
const out = mode === 'cdn' ? 'dist/index.html' : 'dist/local.html';
fs.writeFileSync(out, html);
if (mode === 'local') fs.copyFileSync('node_modules/inkjs/dist/ink.js', 'dist/ink.js');
console.log(out, html.length, 'bytes');
