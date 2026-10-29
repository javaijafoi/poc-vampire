// Joga com as protagonistas mulheres (Irene e Joana) e procura palavra no masculino falando com elas.
// Também confere que nenhuma pergunta ao fantasma aparece de novo depois de feita.
const { Story } = require('inkjs/dist/ink-full.js');
require('./web/v5.js');
const json = require('fs').readFileSync('ink/jogo.json', 'utf8');
const N = +process.argv[2] || 1500;
// palavras que só podem aparecer para o Tomás (ou falando de outro homem: ajuste a lista se for o caso)
const MASC = /\b(moço|forasteiro|querido|filho|louco|surdo|mesmo aí|este aí|o forasteira)\b/;
const achados = new Map(); let biel_repetida = 0;
for (let run = 0; run < N; run++) {
  const s = new Story(json);
  s.BindExternalFunction('rolar', (p, f, d) => V5.rolarV5(p, f, d).resultado, false);
  s.BindExternalFunction('despertar', () => { if (!V5.despertarV5()) s.variablesState['fome'] = Math.min(5, s.variablesState['fome'] + 1); }, false);
  let passos = 0; const feitas = new Set();
  while (passos < 3000) {
    while (s.canContinue) {
      const t = s.Continue() + ' ' + s.currentTags.join(' ');
      if (passos > 0 && s.variablesState['o'] === 'a') { const m = t.match(MASC); if (m && !achados.has(t)) achados.set(t, m[0]); }
    }
    if (!s.currentChoices.length) break;
    let ops = s.currentChoices;
    if (passos === 0) { s.ChooseChoiceIndex(1 + (run % 2)); passos++; continue; } // Irene ou Joana
    for (const c of ops) {
      if (s.variablesState['o'] === 'a') { const m = c.text.match(MASC); if (m) achados.set('[opção] ' + c.text, m[0]); }
    }
    const naSessao = ops.some(c => /Deixar o fantasma descansar/.test(c.text));
    if (naSessao) for (const c of ops) { if (feitas.has(c.text)) biel_repetida++; }
    let idx = ops.map((c, i) => i);
    if (run % 2 && passos < 150 && s.variablesState['minutos'] < 300) idx = idx.filter(i => !/acusação|Voltar|Agora não|descansar/.test(ops[i].text));
    if (!idx.length) idx = ops.map((c, i) => i);
    const i = idx[Math.floor(Math.random() * idx.length)];
    if (naSessao) feitas.add(ops[i].text);
    s.ChooseChoiceIndex(i); passos++;
  }
}
for (const [t, w] of achados) console.log(`MASCULINO "${w}": ${t.slice(0, 160)}`);
console.log(`${N} partidas com Irene e Joana. Trechos no masculino: ${achados.size}. Perguntas ao fantasma repetidas: ${biel_repetida}.`);
process.exit(achados.size || biel_repetida ? 1 : 0);
