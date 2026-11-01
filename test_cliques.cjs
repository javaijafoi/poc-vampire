// Mede quantas caixas de texto (cliques de avanço) uma partida tem, com e sem o agrupamento de falas do web/template.html.
// Reproduz a regra de agrupar(): até 3 linhas seguidas (a primeira e mais falas da mesma pessoa ou narrações), sem etiqueta "::", sem tag
// além de pista, sem dados no meio e com até 300 letras no total.
const { Story } = require('inkjs/dist/ink-full.js');
require('./web/v5.js');
const json = require('fs').readFileSync('ink/jogo.json', 'utf8');
const N = +process.argv[2] || 300, MAX = +process.argv[3] || 300;
const quem = t => / :: /.test(t) ? null : ((t.match(/^([A-ZÀ-Ú][a-zà-ú]+): /) || [])[1] || '');
let linhas = 0, caixas = 0, escolhas = 0;
for (let run = 0; run < N; run++) {
  const s = new Story(json); let dados = 0;
  s.BindExternalFunction('rolar', (p, f, d) => { dados++; return V5.rolarV5(p, f, d).resultado; }, false);
  s.BindExternalFunction('despertar', () => {}, false);
  for (let passos = 0; passos < 3000; passos++) {
    let grupo = null;
    while (s.canContinue) {
      const d0 = dados, t = s.Continue().trim(), tags = s.currentTags;
      if (!t) continue;
      linhas++;
      const q = quem(t), ok = grupo && q !== null && (q === grupo.q || !q) && dados === d0 && grupo.n < 3 && tags.every(x => /^\s*pista\b/.test(x)) && grupo.len + t.length <= MAX;
      if (ok) { grupo.n++; grupo.len += t.length; } else { caixas++; grupo = q === null ? null : { q, n: 1, len: t.length }; }
      if (dados !== d0) grupo = null;
    }
    if (!s.currentChoices.length) break;
    s.ChooseChoiceIndex(Math.floor(Math.random() * s.currentChoices.length)); escolhas++;
  }
}
console.log(`${N} partidas: ${(linhas / N).toFixed(0)} linhas por partida, ${(caixas / N).toFixed(0)} caixas com agrupamento (${(100 - 100 * caixas / linhas).toFixed(0)}% menos cliques de avanço), ${(escolhas / N).toFixed(0)} escolhas.`);
