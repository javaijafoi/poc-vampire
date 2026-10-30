// Gera o fluxograma das escolhas a partir do roteiro em Ink.
//
//   node fluxo/gerar.cjs          -> fluxo/fluxo.json e dist/fluxo.html
//   node fluxo/gerar.cjs 0        -> o mesmo, sem jogar partidas de teste (mais rápido)
//
// Lê os capítulos de fluxo/capitulos.json. Cada capítulo aponta para um arquivo .ink;
// dentro de um arquivo, a linha "// CAPÍTULO 2: Título" também muda o capítulo dos knots seguintes.
// O leitor entende o que o jogo usa: knots, opções (* e +) com {condições} e [texto],
// desvios (->), blocos { cond: ... - else: ... }, ~ variáveis, # pista e # final.
// Depois joga partidas aleatórias com o inkjs para medir quanto cada cena, pista e final aparece.
const fs = require('fs');
const path = require('path');
const RAIZ = path.join(__dirname, '..');
const PARTIDAS = process.argv[2] !== undefined ? +process.argv[2] : 600; // por personagem

const ROLAR = { 0: 'falhou', 1: 'passou', 2: 'crítico', 3: 'crítico bagunçado', 4: 'falha bestial' };

// Lê um trecho entre { } ou [ ] respeitando chaves aninhadas. Devolve [conteúdo, índice depois do fecho].
function trecho(s, i, abre, fecha) {
  let prof = 0;
  for (let j = i; j < s.length; j++) {
    const c = s[j];
    if (c === '{' && abre !== '{') prof++;
    else if (c === '}' && abre !== '{') prof--;
    else if (c === abre) prof++;
    else if (c === fecha) { prof--; if (prof === 0) return [s.slice(i + 1, j), j + 1]; }
  }
  return [s.slice(i + 1), s.length];
}

// Divide "cond: a|b" no primeiro ":" fora de chaves.
function dividirCond(s) {
  let prof = 0;
  for (let i = 0; i < s.length; i++) {
    if (s[i] === '{') prof++;
    else if (s[i] === '}') prof--;
    else if (s[i] === ':' && prof === 0 && s[i + 1] !== ':' && s[i - 1] !== ':') return [s.slice(0, i).trim(), s.slice(i + 1)];
  }
  return [null, s];
}

const negar = c => /^not \(.*\)$/.test(c) ? c.slice(5, -1) : `not (${c})`;

// Texto de opção para mostrar: {a:b|c} vira "b / c", {x} vira "[x]".
function textoLimpo(t) {
  let out = '', i = 0;
  while (i < t.length) {
    if (t[i] === '{') {
      const [dentro, fim] = trecho(t, i, '{', '}');
      const [cond, resto] = dividirCond(dentro);
      if (cond === null) out += `[${dentro.trim()}]`;
      else out += resto.split('|').map(x => textoLimpo(x).trim()).filter(Boolean).join(' / ');
      i = fim;
    } else out += t[i++];
  }
  return out.replace(/\s*;;\s*/g, ' · ').replace(/\s+/g, ' ').trim();
}

function lerInk(arquivo, capPadrao) {
  const src = fs.readFileSync(path.join(RAIZ, arquivo), 'utf8');
  const linhas = src.split('\n');
  const vars = {}, knots = [], titulos = {};
  let knot = null, secao = '', cap = capPadrao, escolha = null, temps = {};
  const blocos = []; // { assunto, ramo, ramos: [] }

  const alvo = () => escolha || knot.auto;
  const quando = () => blocos.slice(escolha ? escolha.base : 0).map(b => b.ramo).filter(Boolean);
  const condBlocos = () => blocos.map(b => b.ramo).filter(Boolean);
  const fecharEscolha = () => { escolha = null; };

  function rotular(c) {
    // resultado de teste de dados: "r == 4" -> "falha bestial"
    return c.replace(/\b(\w+)\s*==\s*(\d)\b/g, (m, v, n) => temps[v] ? `teste ${ROLAR[n]}` : m)
      .replace(/^teste (\w[\w ]*)( or teste [\w ]+)+$/, m => m.replace(/ or teste /g, ' / '));
  }

  function conteudo(texto, extra = []) {
    if (!knot) return;
    const w = [...quando(), ...extra];
    const dest = alvo();
    // condicional de uma linha: { cond: a | b }
    const um = texto.match(/^\s*\{(.*)\}\s*$/);
    if (um && /->/.test(um[1])) {
      const [cond, resto] = dividirCond(um[1]);
      if (cond !== null) {
        const [sim, nao] = resto.split('|');
        conteudo(sim, [...extra, rotular(cond)]);
        if (nao !== undefined) conteudo(nao, [...extra, negar(rotular(cond))]);
        return;
      }
    }
    const tun = texto.match(/->\s*(\w+)\s*->/);
    if (tun) { (dest.tuneis = dest.tuneis || []).push(tun[1]); texto = texto.replace(tun[0], ''); }
    for (const m of texto.matchAll(/->\s*([\w.]+)/g)) {
      if (['END', 'DONE'].includes(m[1])) (dest.fim = true);
      else dest.saidas.push({ para: m[1], quando: w });
    }
    const til = texto.match(/^\s*~\s*(temp\s+)?(\w+)\s*(=|\+=|-=)\s*(.+?)\s*$/);
    if (til) {
      const [, temp, v, op, expr] = til;
      if (temp) { if (/rolar\(/.test(expr)) temps[v] = true; }
      else dest.muda.push({ v, op, expr, quando: w });
    } else {
      const f = texto.match(/^\s*~\s*(\w+)\((.*)\)\s*$/);
      if (f && f[1] === 'passar') dest.minutos = (dest.minutos || 0) + (+f[2] || 0);
      if (f && f[1] === 'despertar') dest.despertar = true;
    }
    if (/rolar\(/.test(texto)) {
      const r = texto.match(/rolar\(([^,]+),\s*\w+,\s*(\d+)\)/);
      if (r) dest.teste = { parada: r[1].trim(), dif: +r[2] };
    }
    for (const m of texto.matchAll(/#\s*pista\s+(\w+):\s*([^#]+)/g)) dest.pistas.push({ aba: m[1], texto: m[2].trim(), quando: w });
    for (const m of texto.matchAll(/#\s*final:\s*(\w+)/g)) dest.finais.push(m[1]);
    const tf = texto.match(/^\s*FINAL\s+(\w+)\s*·\s*([^.#]+)/);
    if (tf) {
      const t = tf[2].trim(), velho = titulos[tf[1]];
      titulos[tf[1]] = velho && velho !== t ? t.split(' · ')[0] : t;
    }
  }

  for (let n = 0; n < linhas.length; n++) {
    let l = linhas[n];
    const sec = l.match(/^\s*\/\/\s*-{5,}\s*(.+?)\s*$/);
    if (sec) { secao = sec[1]; continue; }
    const capm = l.match(/^\s*\/\/\s*CAP[IÍ]TULO\s+(\d+)\s*[:·-]?\s*(.*)$/i);
    if (capm) { cap = +capm[1]; continue; }
    const vm = l.match(/^\s*VAR\s+(\w+)\s*=\s*(.+?)\s*(?:\/\/\s*(.*))?$/);
    if (vm) { vars[vm[1]] = { inicial: vm[2].trim(), desc: (vm[3] || '').trim() }; continue; }
    l = l.replace(/(^|\s)\/\/.*$/, '');
    if (!l.trim()) continue;

    const km = l.match(/^\s*={2,}\s*(function\s+)?(\w+)/);
    if (km) {
      fecharEscolha(); blocos.length = 0; temps = {};
      if (km[1]) { knot = null; continue; }
      knot = { id: km[2], secao, cap, linha: n + 1, escolhas: [], auto: { saidas: [], muda: [], pistas: [], finais: [] } };
      knots.push(knot);
      continue;
    }
    if (!knot) continue;
    const st = l.match(/^\s*=\s*(\w+)\s*$/);
    if (st) {
      fecharEscolha(); blocos.length = 0;
      const pai = knots.find(k => k.id === knot.id.split('.')[0]);
      knot = { id: `${pai.id}.${st[1]}`, secao, cap, linha: n + 1, escolhas: [], auto: { saidas: [], muda: [], pistas: [], finais: [] } };
      knots.push(knot);
      continue;
    }

    // fim de bloco
    if (/^\s*\}\s*$/.test(l)) {
      const b = blocos.pop();
      if (escolha && escolha.base > blocos.length) fecharEscolha();
      continue;
    }
    // ramo de bloco: "- else:", "- 4:", "- cond:"
    const rm = blocos.length && l.match(/^\s*-\s*(else|[^:>][^:]*?)\s*:(?!:)(.*)$/);
    if (rm && !/^\s*-\s*->/.test(l)) {
      const b = blocos[blocos.length - 1];
      if (escolha && escolha.base >= blocos.length) fecharEscolha();
      let c;
      if (rm[1] === 'else') c = b.ramos.length ? (b.ramos.length === 1 ? negar(b.ramos[0]) : 'nenhum dos anteriores') : null;
      else c = rotular(b.assunto ? `${b.assunto} == ${rm[1]}` : rm[1]);
      if (rm[1] !== 'else') b.ramos.push(c);
      b.ramo = c;
      if (rm[2].trim()) conteudo(rm[2]);
      continue;
    }
    // abre bloco de várias linhas
    const bm = l.match(/^\s*\{(.*)$/);
    if (bm && (l.match(/\{/g) || []).length > (l.match(/\}/g) || []).length) {
      const dentro = bm[1].trim();
      if (!dentro) blocos.push({ assunto: null, ramo: null, ramos: [] });
      else {
        const [cond, resto] = dividirCond(dentro);
        // "{ r:" seguido de "- 4:" é um switch; "{ cond:" seguido de texto é um if
        const prox = (linhas[n + 1] || '').trim();
        if (/^-\s*[^>]/.test(prox) && !resto.trim()) blocos.push({ assunto: cond, ramo: null, ramos: [] });
        else { blocos.push({ assunto: null, ramo: rotular(cond), ramos: [rotular(cond)] }); if (resto.trim()) conteudo(resto); }
      }
      continue;
    }
    // opção
    const om = l.match(/^\s*([*+](?:\s*[*+])*)\s*(.*)$/);
    if (om) {
      fecharEscolha();
      let resto = om[2], conds = [], texto = '';
      for (;;) {
        resto = resto.replace(/^\s+/, '');
        if (resto[0] === '(') { resto = resto.slice(resto.indexOf(')') + 1); continue; }
        if (resto[0] === '{') { const [c, f] = trecho(resto, 0, '{', '}'); conds.push(c.trim()); resto = resto.slice(f); continue; }
        break;
      }
      if (resto[0] === '[') { const [t, f] = trecho(resto, 0, '[', ']'); texto = t; resto = resto.slice(f); }
      else { texto = resto.replace(/->.*$/, ''); }
      const bruto = textoLimpo(texto);
      const gm = bruto.match(/^(.*?)\s*::\s*(.*)$/);
      escolha = {
        texto: gm ? gm[2] : bruto, gatilho: gm ? gm[1] : null, fixa: om[1].includes('+'),
        conds: [...condBlocos(), ...conds], base: blocos.length,
        saidas: [], muda: [], pistas: [], finais: [], linha: n + 1,
      };
      knot.escolhas.push(escolha);
      if (resto.trim()) conteudo(resto);
      continue;
    }
    // ponto de encontro (gather) fora de bloco fecha a opção
    const gm = !blocos.length && l.match(/^\s*-(?!>)\s*(.*)$/);
    if (gm) { fecharEscolha(); if (gm[1].trim()) conteudo(gm[1]); continue; }
    conteudo(l);
  }
  for (const k of knots) for (const e of k.escolhas) delete e.base;
  return { vars, knots, titulos };
}

// ------------------------------------------------------------------ partidas de teste
function simular(arquivoInk, personagens) {
  const { Story, Compiler, CompilerOptions } = require('inkjs/dist/ink-full.js');
  require(path.join(RAIZ, 'web/v5.js'));
  // compila de novo contando todas as visitas, para saber por quais cenas cada partida passou
  const json = new Compiler(fs.readFileSync(arquivoInk, 'utf8'), new CompilerOptions(null, [], true)).Compile().ToJson();
  const res = {};
  personagens.forEach((nome, idx) => {
    const r = res[nome] = { partidas: 0, finais: {}, visitas: {}, chaves: {} };
    for (let run = 0; run < PARTIDAS; run++) {
      const s = new Story(json);
      s.BindExternalFunction('rolar', (p, f, d) => V5.rolarV5(p, f, d).resultado, false);
      s.BindExternalFunction('despertar', () => { if (!V5.despertarV5()) s.variablesState['fome'] = Math.min(5, s.variablesState['fome'] + 1); }, false);
      s.onError = () => {};
      let passos = 0, final = null;
      while (passos < 3000) {
        while (s.canContinue) {
          s.Continue();
          for (const t of s.currentTags) if (t.startsWith('final:')) final = t.split(':')[1].trim();
        }
        if (!s.currentChoices.length) break;
        let ops = s.currentChoices.map((c, i) => i);
        if (passos === 0) ops = [idx];
        // metade das partidas evita voltar e acusar cedo, para explorar mais (como no test_jogo.cjs)
        else if (run % 2 && passos < 150 && s.variablesState['minutos'] < 300) ops = ops.filter(i => !/acusação|Voltar|Ainda não|Admitir/.test(s.currentChoices[i].text));
        if (!ops.length) ops = s.currentChoices.map((c, i) => i);
        s.ChooseChoiceIndex(ops[Math.floor(Math.random() * ops.length)]);
        passos++;
      }
      r.partidas++;
      r.finais[final || '?'] = (r.finais[final || '?'] || 0) + 1;
      for (const k of knotsSimulados) if (s.state.VisitCountAtPathString(k) > 0) r.visitas[k] = (r.visitas[k] || 0) + 1;
      for (const v of chavesSimuladas) if (s.variablesState[v] === true) r.chaves[v] = (r.chaves[v] || 0) + 1;
    }
  });
  return res;
}
let knotsSimulados = [], chavesSimuladas = [];

// ------------------------------------------------------------------ monta
const capitulos = JSON.parse(fs.readFileSync(path.join(__dirname, 'capitulos.json'), 'utf8'));
const lidos = {};
const saida = { gerado: new Date().toISOString(), titulosFinais: {}, capitulos: [] };
const frase = t => t.charAt(0) + t.slice(1).toLowerCase().replace(/príncipe/g, 'Príncipe').replace(/corte/g, 'Corte').replace(/anarquistas/g, 'Anarquistas');
for (const c of capitulos) {
  const cap = { n: c.n, titulo: c.titulo, resumo: c.resumo || '', arquivo: c.arquivo || null, knots: [], vars: {}, sim: null };
  if (c.arquivo) {
    if (!lidos[c.arquivo]) lidos[c.arquivo] = lerInk(c.arquivo, c.n);
    const { vars, knots, titulos } = lidos[c.arquivo];
    for (const [f, t] of Object.entries(titulos)) saida.titulosFinais[f] = frase(t);
    cap.vars = vars;
    cap.knots = knots.filter(k => k.cap === c.n);
    if (PARTIDAS > 0) {
      const t0 = Date.now();
      knotsSimulados = cap.knots.map(k => k.id);
      chavesSimuladas = Object.keys(vars).filter(v => vars[v].inicial === 'false');
      const esc = cap.knots.find(k => k.id === (c.personagens_em || 'escolha_personagem'));
      const nomes = esc ? esc.escolhas.map(e => (e.muda.find(m => m.v === 'nome') || {}).expr?.replace(/"/g, '') || e.texto) : ['partida'];
      cap.sim = simular(path.join(RAIZ, c.arquivo), nomes);
      console.log(`capítulo ${c.n}: ${nomes.length * PARTIDAS} partidas em ${Date.now() - t0} ms`);
    }
  }
  console.log(`capítulo ${c.n}: ${cap.knots.length} cenas, ${cap.knots.reduce((a, k) => a + k.escolhas.length, 0)} opções`);
  saida.capitulos.push(cap);
}
const json = JSON.stringify(saida);
fs.writeFileSync(path.join(__dirname, 'fluxo.json'), JSON.stringify(saida, null, 1));
const pagina = fs.readFileSync(path.join(__dirname, 'pagina.html'), 'utf8').replace('/*DADOS*/null', () => json.replace(/<\//g, '<\\/'));
fs.mkdirSync(path.join(RAIZ, 'dist'), { recursive: true });
fs.writeFileSync(path.join(RAIZ, 'dist/fluxo.html'),
  '<!doctype html>\n<html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n' +
  '<style>html,body{margin:0;height:100%}*{box-sizing:border-box}[hidden]{display:none!important}</style>\n</head><body>\n' + pagina + '\n</body></html>\n');
// a mesma página sem o esqueleto, para publicar como Artifact
if (process.env.FLUXO_ARTIFACT) fs.writeFileSync(process.env.FLUXO_ARTIFACT, pagina);
console.log('ok: dist/fluxo.html');
