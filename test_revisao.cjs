// Consertos da revisão de 09/11: a Corte espera a Senescal, prova de fora, sessão da Nonna no fim da noite, olho amarelo depois da confissão.
const { Story } = require('inkjs/dist/ink-full.js');
const json = require('fs').readFileSync('ink/jogo.json', 'utf8');
function nova() {
  const s = new Story(json); let final = null; const falas = [];
  s.BindExternalFunction('rolar', () => 0, false); s.BindExternalFunction('despertar', () => {}, false);
  const correr = () => { while (s.canContinue) { falas.push(s.Continue()); for (const t of s.currentTags) if (t.startsWith('final:')) final = t.split(':')[1].trim(); } };
  const ir = re => { const i = s.currentChoices.findIndex(c => re.test(c.text)); if (i < 0) return false; s.ChooseChoiceIndex(i); correr(); return true; };
  const tem = re => s.currentChoices.some(c => re.test(c.text));
  return { s, correr, ir, tem, falas, final: () => final };
}
const checar = (ok, nome) => { console.log(`${ok ? 'ok ' : 'FALHOU'} ${nome}`); if (!ok) process.exitCode = 1; };

// Capítulo 2: antes da 01h30 não dá para chamar a Corte; só esperar a Senescal.
{ const j = nova(); j.s.ChoosePathString('capitulo_2_novo'); j.correr(); j.s.ChooseChoiceIndex(1); j.correr();
  for (const p of [/sapatos/, /celular/, /convite/, /Ir para o MASP/, /Esperar a gala abrir/, /^Isadora/, /Quem esteve/, /Ligação/, /Voltar ao salão/, /^Dr. Arnaldo/, /Lama: eu estive/, /Voltar ao salão/]) j.ir(p);
  checar(!j.tem(/Chamar quem preside/) && j.tem(/Esperar a Senescal/), 'antes da Senescal chegar, a Corte não se reúne');
  j.ir(/Esperar a Senescal/);
  checar(j.s.variablesState['minutos'] === 390 && j.s.variablesState['luciana_chegou'] && j.tem(/Chamar quem preside/), 'esperar leva à 01h30 e a Senescal chega');
  // só com provas de dentro do salão, a Senescal não cai
  for (const p of [/Chamar quem preside/, /^Sim/, /com a Luciana/]) j.ir(p);
  checar(j.falas.some(f => /saiu de dentro do salão/.test(f)), 'aviso de que falta prova do lado de fora');
  for (const p of [/^Sim. É isso/, /03h12/, /saiu da Capela/, /arquivo do Cão/]) j.ir(p);
  checar(j.final() === '2F' || j.final() === '2D', `três provas só de dentro não derrubam a Senescal (final ${j.final()})`); }

// Capítulo 1: a Nonna não recusa mais por falta de tempo. Com menos de uma hora, ela avisa e o Príncipe interrompe a sessão.
{ const j = nova(); j.correr(); j.s.ChooseChoiceIndex(0); j.correr();
  j.s.variablesState['minutos'] = j.s.variablesState['limite'] - 30; j.ir(/Nonna/);
  checar(j.tem(/Pagar com sangue/) && j.falas.some(f => /olha a hora/.test(f)), 'Nonna aceita a sessão no fim da noite, com aviso');
  j.ir(/Ficar devendo/);
  checar(j.falas.some(f => /Morto não fala na frente de Príncipe/.test(f)) && j.tem(/Rayo, o motoqueiro/) && j.s.variablesState['minutos'] === j.s.variablesState['limite'], 'o Príncipe interrompe a sessão e a acusação começa'); }
{ const j = nova(); j.correr(); j.s.ChooseChoiceIndex(0); j.correr();
  j.s.variablesState['minutos'] = 300; j.ir(/Nonna/); j.ir(/Ficar devendo/);
  checar(j.tem(/Como você morreu/), 'com 1h40 de noite, a sessão ainda rende pergunta'); }

// Capítulo 1: o Rayo já confessou, o fantasma falou do olho amarelo, e a prova continua disponível.
{ const j = nova(); j.correr(); j.s.ChooseChoiceIndex(0); j.correr();
  j.s.variablesState['rayo_confessou'] = true; j.s.variablesState['biel_morte'] = true;
  j.ir(/Rayo, debruçado/);
  checar(j.ir(/Olho amarelo/) && j.s.variablesState['p_olho'] === true, 'olho amarelo depois da confissão do Rayo'); }

// Capítulo 2: o Príncipe é acusável. Ele admite o porto só nos finais em que foi ele quem mandou; pede uma prova só; final 2A (Tomás escapa, 2G).
for (const [fc, pers, admite] of [['B', 1, true], ['F', 1, false], ['C_corte', 2, false], ['B', 0, true]]) {
  const j = nova(); j.s.ChoosePathString('capitulo_2_novo'); j.correr(); j.s.ChooseChoiceIndex(pers); j.correr();
  j.s.variablesState['final_cap1'] = fc; j.s.ChoosePathString('acusacao2'); j.correr();
  const ok1 = j.ir(/Foi o (senhor, Príncipe|Príncipe Dante)/) && j.ir(/^Sim. É isso/);
  let n = 0; while (!j.final() && j.s.currentChoices.length && n < 3) { j.s.ChooseChoiceIndex(0); j.correr(); n++; }
  const txt = j.falas.join(' ');
  checar(ok1 && n <= 1 && j.final() === (pers === 0 ? '2G' : '2A') && /Mandei você ao porto/.test(txt) === admite && !/undefined/.test(txt), `acusar o Príncipe (cap 1 = ${fc}, personagem ${pers}): final ${j.final()}, ${n} prova`);
}

// Capítulo 2: quem veio pelos Anarquistas pode levar a verdade ao Rayo (final 2L); as fugas saem com alguém e com a dica do informante.
{ const j = nova(); j.s.ChoosePathString('capitulo_2_novo'); j.correr(); j.s.ChooseChoiceIndex(2); j.correr();
  j.s.variablesState['final_cap1'] = 'C_anarq'; j.s.ChoosePathString('luciana_cai'); j.correr();
  const ok = j.ir(/Ao Rayo/);
  checar(ok && j.final() === '2L' && j.s.variablesState['aliado_cap2'] === 'rayo' && j.falas.some(f => /Guga/.test(f)), 'verdade para o Rayo: final 2L, aliado rayo, Guga citado'); }
{ const j = nova(); j.s.ChoosePathString('capitulo_2_novo'); j.correr(); j.s.ChooseChoiceIndex(0); j.correr();
  j.s.ChoosePathString('luciana_cai'); j.correr();
  checar(!j.tem(/Ao Rayo/), 'fora do caminho dos Anarquistas, a opção do Rayo não aparece'); }
for (const [pers, knot, letra, aliado] of [[1, 'irene_some_sinal', '2F', 'digito'], [0, 'tomas_resiste', '2G', 'rayo'], [2, 'joana_dupla', '2H', 'doutora']]) {
  const j = nova(); j.s.ChoosePathString('capitulo_2_novo'); j.correr(); j.s.ChooseChoiceIndex(pers); j.correr();
  j.s.ChoosePathString(knot); j.correr();
  checar(j.final() === letra && j.s.variablesState['aliado_cap2'] === aliado && j.falas.some(f => /Anarquistas|no meio da gente/.test(f)), `fuga ${letra}: sai com ${aliado} e com a dica do informante`); }
