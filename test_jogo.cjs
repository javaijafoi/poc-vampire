// Joga a história inteira milhares de vezes escolhendo opções ao acaso e checa se toda partida chega a um final.
const { Story } = require('inkjs/dist/ink-full.js');
require('./web/v5.js');
const json = require('fs').readFileSync('ink/jogo.json', 'utf8');
const N = +process.argv[2] || 5000;
const finais = {}, porPersonagem = {};
let semFinal = 0, erros = 0, maxPassos = 0;
const t0 = performance.now();
for (let run = 0; run < N; run++) {
  const s = new Story(json);
  s.BindExternalFunction('rolar', (p, f, d) => V5.rolarV5(p, f, d).resultado, false);
  s.BindExternalFunction('despertar', () => { if (!V5.despertarV5()) s.variablesState['fome'] = Math.min(5, s.variablesState['fome'] + 1); }, false);
  s.onError = e => { erros++; if (erros < 5) console.log('ERRO', e); };
  let passos = 0, final = null;
  while (passos < 3000) {
    while (s.canContinue) {
      s.Continue();
      for (const t of s.currentTags) if (t.startsWith('final:')) final = t.split(':')[1].trim();
    }
    if (!s.currentChoices.length) break;
    // metade das partidas evita "Voltar"/"acusar" cedo, para explorar mais
    let ops = s.currentChoices.map((c, i) => i);
    if (run % 2 && passos < 150 && s.variablesState['minutos'] < 300) ops = ops.filter(i => !/acusação|Voltar|Agora não|descansar/.test(s.currentChoices[i].text)) .concat([]);
    if (!ops.length) ops = s.currentChoices.map((c, i) => i);
    s.ChooseChoiceIndex(ops[Math.floor(Math.random() * ops.length)]);
    passos++;
  }
  maxPassos = Math.max(maxPassos, passos);
  if (!final) semFinal++;
  finais[final] = (finais[final] || 0) + 1;
  const k = `${s.variablesState['nome']} -> ${final}`;
  porPersonagem[k] = (porPersonagem[k] || 0) + 1;
}
const ms = performance.now() - t0;
console.log(`${N} partidas em ${ms.toFixed(0)} ms. Sem final: ${semFinal}. Erros: ${erros}. Máximo de escolhas numa partida: ${maxPassos}.`);
for (const [k, n] of Object.entries(finais).sort()) console.log(`Final ${k}: ${(100 * n / N).toFixed(1)}%`);
for (const [k, n] of Object.entries(porPersonagem).sort()) console.log(`  ${k}: ${(100 * n / N).toFixed(1)}%`);
