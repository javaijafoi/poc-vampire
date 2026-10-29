// Caminhos roteirizados: confere que o caminho certo chega ao final certo e que provas fracas não bastam.
const { Story } = require('inkjs/dist/ink-full.js');
require('./web/v5.js');
const json = require('fs').readFileSync('ink/jogo.json', 'utf8');
function jogar(passos) {
  const s = new Story(json);
  s.BindExternalFunction('rolar', () => 1, false); // todo teste passa
  s.BindExternalFunction('despertar', () => {}, false);
  let final = null; const texto = [];
  for (const re of passos) {
    while (s.canContinue) { texto.push(s.Continue().trim()); for (const t of s.currentTags) if (t.startsWith('final:')) final = t.split(':')[1].trim(); }
    const i = s.currentChoices.findIndex(c => re.test(c.text));
    if (i < 0) throw new Error(`opção ${re} não encontrada. Havia: ${s.currentChoices.map(c => c.text).join(' | ')}`);
    s.ChooseChoiceIndex(i);
  }
  while (s.canContinue) { texto.push(s.Continue().trim()); for (const t of s.currentTags) if (t.startsWith('final:')) final = t.split(':')[1].trim(); }
  return { final, texto, s };
}
const investigar = [/^Tomás/, /^Rayo, debruçado/, /aconteceu na Serra/, /Atrasou quanto/, /Insistir mais uma vez/, /Prova :: Dossiê/, /^Gangrel ::/,
  /^O Cão, no canto/, /aconteceu no túnel/, /Como você sabe/, /Disciplina: Animalismo :: Chamar o rato/, /Prova :: Selo queimado/,
  /Chamar o Príncipe/, /^Sim\. Mandar/, /O Xerife, o Cão/];
const casos = [
  ['três provas fortes', [...investigar, /selo Tremere/, /hora da entrega/, /esconderijo/], 'B'],
  ['uma prova fraca no meio', [...investigar, /selo Tremere/, /hora da entrega/, /desvio do Rayo/], 'G'],
  ['parar antes de três provas', [...investigar, /selo Tremere/, /Isso é tudo/], 'G'],
];
let falhou = 0;
for (const [nome, passos, esperado] of casos) {
  try { const { final } = jogar(passos); const ok = final === esperado; if (!ok) falhou++; console.log(`${ok ? 'ok ' : 'ERRO'} ${nome}: final ${final} (esperado ${esperado})`); }
  catch (e) { falhou++; console.log(`ERRO ${nome}: ${e.message}`); }
}
// a hora falada pelo Vincenzo bate com o relógio
const { texto } = jogar([/^Irene/, ...Array(12).fill(0).flatMap(() => [/^Harumi, na mesa/, /O que saiu do porto/, /Voltar para o salão/])].slice(0, 37));
const aviso = texto.find(t => /^Vincenzo: (Três|Quatro|Cinco|Duas)/.test(t));
console.log(aviso ? `ok  aviso de hora: "${aviso}"` : 'ERRO aviso de hora não apareceu');
if (!aviso) falhou++;
process.exit(falhou ? 1 : 0);
