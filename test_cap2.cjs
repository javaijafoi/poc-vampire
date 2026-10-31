// Capítulo 2: joga milhares de partidas ao acaso, partindo de cada final do capítulo 1, e checa se toda partida chega a um final.
const { Story } = require('inkjs/dist/ink-full.js');
require('./web/v5.js');
const json = require('fs').readFileSync('ink/jogo.json', 'utf8');
const N = +process.argv[2] || 3000;
const PARTIDAS = ['B', 'C_corte', 'C_anarq', 'E', 'F', 'G', 'H', 'S'];
const finais = {}, porPersonagem = {}, porPartida = {};
let semFinal = 0, erros = 0, maxPassos = 0, sinalMax = 0;
// palavras no masculino que não podem aparecer para a Irene e a Joana
const MASC = /\b(forasteiro|querido|cansado|drogado|sozinho|enterrado|sonâmbulo|satisfeito|perigoso|convidado|aliviado|surdo|louco|este aí)\b/;
const achados = new Map();
for (let run = 0; run < N; run++) {
  const s = new Story(json);
  s.BindExternalFunction('rolar', (p, f, d) => V5.rolarV5(p, f, d).resultado, false);
  s.BindExternalFunction('despertar', () => { if (!V5.despertarV5()) s.variablesState['fome'] = Math.min(5, s.variablesState['fome'] + 1); }, false);
  s.onError = e => { erros++; if (erros < 5) console.log('ERRO', e); };
  s.ChoosePathString('capitulo_2_novo');
  while (s.canContinue) s.Continue();
  s.ChooseChoiceIndex(run % 3);
  const partida = PARTIDAS[Math.floor(run / 3) % PARTIDAS.length];
  s.variablesState['final_cap1'] = partida;
  if (partida === 'S') { s.variablesState['tem_frasco'] = true; s.variablesState['favor_principe'] = true; }
  let passos = 0, final = null;
  while (passos < 3000) {
    while (s.canContinue) {
      const txt = s.Continue();
      for (const t of s.currentTags) if (t.startsWith('final:')) final = t.split(':')[1].trim();
      if (s.variablesState['o'] === 'a') { const m = (txt + ' ' + s.currentTags.join(' ')).match(MASC); if (m && !/convidado (do|meu)|uma pessoa que eu convidei/.test(txt)) achados.set(txt, m[0]); }
    }
    if (!s.currentChoices.length) break;
    let ops = s.currentChoices.map((c, i) => i);
    if (run % 2 && passos < 150 && s.variablesState['minutos'] < 300) ops = ops.filter(i => !/Corte e dizer|Voltar|Ainda não|Admitir/.test(s.currentChoices[i].text));
    if (!ops.length) ops = s.currentChoices.map((c, i) => i);
    s.ChooseChoiceIndex(ops[Math.floor(Math.random() * ops.length)]);
    passos++;
  }
  sinalMax = Math.max(sinalMax, s.variablesState['sinal']);
  maxPassos = Math.max(maxPassos, passos);
  if (!final) semFinal++;
  finais[final] = (finais[final] || 0) + 1;
  const k = `${s.variablesState['nome']} -> ${final}`;
  porPersonagem[k] = (porPersonagem[k] || 0) + 1;
  porPartida[`${partida} -> ${final}`] = (porPartida[`${partida} -> ${final}`] || 0) + 1;
}
for (const [t, w] of achados) console.log(`MASCULINO (${w}): ${t.trim()}`);
console.log(`${N} partidas do capítulo 2. Trechos no masculino com Irene e Joana: ${achados.size}. Sem final: ${semFinal}. Erros: ${erros}. Máximo de escolhas: ${maxPassos}. Sinal máximo: ${sinalMax}.`);
for (const [k, n] of Object.entries(finais).sort()) console.log(`Final ${k}: ${(100 * n / N).toFixed(1)}%`);
for (const [k, n] of Object.entries(porPersonagem).sort()) console.log(`  ${k}: ${(100 * n / N).toFixed(1)}%`);
if (process.argv[3] === 'partidas') for (const [k, n] of Object.entries(porPartida).sort()) console.log(`  ${k}: ${n}`);
if (semFinal || erros || achados.size) process.exitCode = 1;

// Caminho neutro: só conversa e provas, sem teste de dado nem Disciplina. Qualquer personagem chega ao final certo.
function caminho(personagem, partida, passos, esperado) {
  const s = new Story(json);
  s.BindExternalFunction('rolar', () => 0, false);
  s.BindExternalFunction('despertar', () => {}, false);
  s.ChoosePathString('capitulo_2_novo');
  while (s.canContinue) s.Continue();
  s.ChooseChoiceIndex(personagem);
  s.variablesState['final_cap1'] = partida;
  let final = null;
  const correr = () => { while (s.canContinue) { s.Continue(); for (const t of s.currentTags) if (t.startsWith('final:')) final = t.split(':')[1].trim(); } };
  correr();
  for (const p of passos) {
    const i = s.currentChoices.findIndex(c => p.test(c.text));
    if (i < 0) { console.log(`FALHOU ${partida}/${personagem}: sem opção ${p} em [${s.currentChoices.map(c => c.text).join(' | ')}]`); process.exitCode = 1; return; }
    s.ChooseChoiceIndex(i); correr();
  }
  console.log(`${final === esperado ? 'ok ' : 'FALHOU'} caminho neutro ${s.variablesState['nome']} partindo de ${partida}: final ${final} (esperado ${esperado})`);
  if (final !== esperado) process.exitCode = 1;
}
const NEUTRO = [/sapatos/, /celular/, /convite/, /^Isadora/, /Ligação/, /Voltar ao salão/, /^Dr. Arnaldo/, /Lama: eu estive/, /Voltar ao salão/,
  /Descer para o vão/, /Valentina/, /me viu/, /Lama: eu voltei/, /Voltar ao vão/, /Subir para o salão/,
  /^Dr. Arnaldo/, /Quem nesta cidade/, /segurança da porta é humano/, /Voltar ao salão/,
  /^Luciana/, /Arquivo:/, /^Voltar$/, /Chamar quem preside/, /^Sim/, /A Luciana/, /03h12/, /saiu da Capela/, /mulher de luvas/];
for (const pers of [0, 1, 2]) caminho(pers, 'B', [...NEUTRO, /Ao Príncipe/], '2B');
caminho(1, 'C_corte', [...NEUTRO, /À Constance/], '2C');
caminho(2, 'E', [...NEUTRO, /Dr. Arnaldo, o Juiz/], '2J');
caminho(0, 'C_anarq', [...NEUTRO, /A ninguém/], '2K');

// Final S do capítulo 1 (O Cofre Aberto): com carimbo, informante, Constance aliada, frasco e sem quebrar regra, a opção aparece e leva ao S.
{
  const s = new Story(json);
  s.BindExternalFunction('rolar', () => 0, false); s.BindExternalFunction('despertar', () => {}, false);
  for (const v of ['p_boes', 'p_informante', 'constance_aliada', 'p_frasco']) s.variablesState[v] = true;
  s.ChoosePathString('cao_desmorona');
  let final = null; const correr = () => { while (s.canContinue) { s.Continue(); for (const t of s.currentTags) if (t.startsWith('final:')) final = t.split(':')[1].trim(); } };
  correr();
  const i = s.currentChoices.findIndex(c => /Final ideal/.test(c.text));
  if (i >= 0) { s.ChooseChoiceIndex(i); correr(); }
  const ok = final === 'S' && s.variablesState['tem_frasco'] && s.variablesState['favor_principe'] && s.variablesState['final_cap1'] === 'S';
  console.log(`${ok ? 'ok ' : 'FALHOU'} final S do capítulo 1: ${final}, frasco ${s.variablesState['tem_frasco']}, favor ${s.variablesState['favor_principe']}`);
  if (!ok) process.exitCode = 1;
  s.variablesState['quebrou_regra'] = 1; // com regra quebrada, a opção some
  s.ChoosePathString('cao_desmorona'); correr();
  if (s.currentChoices.some(c => /Final ideal/.test(c.text))) { console.log('FALHOU final S aparece mesmo com regra quebrada'); process.exitCode = 1; }
}
