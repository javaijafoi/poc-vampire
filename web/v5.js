// Regras de dados de Vampiro V5, usadas pelo jogo web e pelos testes.
// Resultado: 0 falha, 1 sucesso, 2 crítico, 3 crítico bagunçado, 4 falha bestial
(function (root) {
  function rolarV5(parada, fome, dificuldade, rng) {
    rng = rng || Math.random;
    const d10 = () => 1 + Math.floor(rng() * 10);
    const nFome = Math.min(fome, parada);
    const dados = [];
    for (let i = 0; i < parada; i++) dados.push({ valor: d10(), fome: i < nFome });
    let sucessos = dados.filter(d => d.valor >= 6).length;
    const dezes = dados.filter(d => d.valor === 10);
    const pares = Math.floor(dezes.length / 2);
    sucessos += pares * 2; // cada par de 10 vale 4 sucessos no total
    const passou = sucessos >= dificuldade;
    let resultado;
    if (passou && pares > 0 && dezes.some(d => d.fome)) resultado = 3;
    else if (passou && pares > 0) resultado = 2;
    else if (passou) resultado = 1;
    else if (dados.some(d => d.fome && d.valor === 1)) resultado = 4;
    else resultado = 0;
    return { resultado, sucessos, dados, dificuldade };
  }
  function despertarV5(rng) { return 1 + Math.floor((rng || Math.random)() * 10) >= 6; }
  root.V5 = { rolarV5, despertarV5 };
})(typeof window !== 'undefined' ? window : globalThis);
