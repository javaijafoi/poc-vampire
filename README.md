# Porão do Vincenzo

Prova de conceito de um jogo de investigação em estilo visual novel, ambientado na São Paulo de Vampiro: A Máscara (V5). O jogador interroga testemunhas num bar e precisa descobrir quem está mentindo, no estilo Rashomon.

Esta primeira cena (o depoimento do Rayo) existe em duas versões, para comparar as ferramentas:

| Pasta | O que é |
| --- | --- |
| `ink/rayo.ink` | Roteiro da cena em Ink |
| `web/` | Interface web estilo Coffee Talk que roda o roteiro Ink |
| `dist/index.html` | Jogo web pronto. Abra no navegador (precisa de internet para carregar o motor Ink) |
| `renpy/game/` | A mesma cena em Ren'Py |
| `art/` | Arte da cena: `montar_cena.py` faz o fundo e o recorte de revista dos personagens (`npm run arte`). A versão Ren'Py ainda usa a pixel art antiga (`make_art.py`) |
| `bench/` | Medição de tempo de carregamento |

## Convenções do roteiro

- `Rayo: texto` é fala; linha sem nome é narração.
- `Gatilho :: texto` é uma opção ou observação especial (clã, atributo, prova, teste, Disciplina) e aparece com uma etiqueta colorida.
- `# pista: texto` coloca a pista no caderno do jogador.

## Versão Ink

```
npm install
npm run testar   # joga a cena 10.000 vezes e checa se sempre chega ao fim
npm run build    # gera dist/index.html
```

Para editar o roteiro e jogar o texto na hora, use o editor Inky (github.com/inkle/inky) e abra `ink/rayo.ink`.

## Versão Ren'Py

1. Baixe o Ren'Py 8 em renpy.org.
2. Copie a pasta `renpy/` para a pasta de projetos do Ren'Py e renomeie para `PoraoDoVincenzo`.
3. No launcher, clique em "Refresh", escolha o projeto e clique em "Launch Project".

Para medir a versão Ren'Py (no Linux, com o SDK 8.5.3 e o suporte web descompactado dentro dele):

```
RENPY_SDK=~/renpy-8.5.3-sdk bench/renpy/medir.sh 300    # lint, tempo até a primeira tela e 300 partidas automáticas
RENPY_SDK=~/renpy-8.5.3-sdk bench/renpy/medir_web.sh 5  # build web e carregamento no Chromium
```

Os dois scripts trabalham numa cópia temporária do projeto e acrescentam `bench/renpy/zz_bench.rpy`, que nunca entra no jogo.
