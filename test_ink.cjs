// Joga a cena milhares de vezes escolhendo opções ao acaso e checa se a trama fecha.
const { Story } = require('inkjs/dist/ink-full.js');
require('./web/v5.js');
const json = require('fs').readFileSync('ink/rayo.json', 'utf8');
const N = +process.argv[2] || 5000;
const stats = {};
let deadEnds = 0, errors = 0;
const t0 = performance.now();
for (let run = 0; run < N; run++) {
  const s = new Story(json);
  s.BindExternalFunction('rolar', (p, f, d) => V5.rolarV5(p, f, d).resultado, false);
  s.BindExternalFunction('despertar', () => { if (!V5.despertarV5()) s.variablesState['fome'] = Math.min(5, s.variablesState['fome'] + 1); }, false);
  s.onError = () => errors++;
  let steps = 0, ended = false, pistas = 0;
  while (steps < 200) {
    while (s.canContinue) { s.Continue(); if (s.currentTags.some(t => t.startsWith('pista'))) pistas++; if (s.currentTags.includes('fim')) ended = true; }
    if (!s.currentChoices.length) break;
    s.ChooseChoiceIndex(Math.floor(Math.random() * s.currentChoices.length));
    steps++;
  }
  if (!ended) deadEnds++;
  const v = s.variablesState;
  const k = `${v['nome']} | confessou=${v['confessou']} | quebrou_regra=${v['quebrou_regra']}`;
  stats[k] = (stats[k] || 0) + 1;
}
const ms = performance.now() - t0;
console.log(`${N} partidas em ${ms.toFixed(0)} ms (${(ms / N).toFixed(2)} ms cada). Sem final: ${deadEnds}. Erros: ${errors}.`);
for (const [k, n] of Object.entries(stats).sort()) console.log(`${k}: ${(100 * n / N).toFixed(1)}%`);
