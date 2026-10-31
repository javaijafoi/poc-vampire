# O Matusalém Desaparecido

Jogo de investigação em estilo visual novel, ambientado na São Paulo de Vampiro: A Máscara (V5). Um Matusalém sumiu no caminho entre o Porto de Santos e o cofre do Príncipe Dante. Você interroga quatro testemunhas no Porão do Vincenzo, uma em cada canto do bar, e acusa alguém antes do amanhecer. Ninguém conta a verdade inteira, como em Rashomon.

Primeira versão jogável: tela inicial, abertura animada, escolha entre 3 personagens prontos (Gangrel, Nosferatu, Ministério), as testemunhas (Rayo, Cão, Harumi e o fantasma do Biel, chamado pela Nonna), a acusação diante da Corte e 4 finais. As imagens ainda são provisórias.

| Pasta | O que é |
| --- | --- |
| `ink/jogo.ink` | Roteiro em Ink: capítulo 1 (o Porão) e as funções comuns. No fim, `INCLUDE capitulo2.ink` |
| `ink/capitulo2.ink` | Capítulo 2, O Custo do Esquecimento: a gala da Corte no Elísio do MASP |
| `ink/rayo.ink` | A cena de teste antiga (só o Rayo), mantida para comparação com o Ren'Py |
| `web/` | Interface web que roda o roteiro |
| `dist/index.html` | Jogo web pronto, num arquivo só, com a música ao lado em `dist/musica/`. Abra no navegador (precisa de internet para o motor Ink e as fontes) |
| `art/` | Arte: `recortar_personagens.py` tira o fundo das artes do Trello, `gerar_fundos.py` gera os fundos com sdxl-turbo, `montar_cena.py` faz o recorte de revista e os fundos finais (`npm run arte`) |
| `musica/` | Trilha sonora: uma faixa por cena, todas CC0 (`CREDITOS.md` diz qual toca onde; `bash musica/preparar.sh` refaz os MP3) |
| `video/` | A abertura como vídeo MP4, feita com HyperFrames (`bash video/renderizar.sh`) |
| `renpy/game/` | A cena de teste em Ren'Py |
| `bench/` | Medição de tempo de carregamento |
| `fluxo/` | Fluxograma das escolhas, gerado do roteiro (`npm run fluxo` cria `dist/fluxo.html`) |

## Convenções do roteiro

- `Rayo: texto` é fala; linha sem nome é narração.
- `Gatilho :: texto` é uma opção ou observação especial (clã, atributo, prova, teste, Disciplina) e aparece com uma etiqueta colorida.
- `# pista <aba>: texto` coloca a pista no caderno, na folha da aba (`dossie`, `rayo`, `cao`, `harumi`, `biel`, `bar`).
- `# fundo: nome` troca o fundo (`art/cena/fundo_<nome>.webp`); `# entra: nome` põe a testemunha em cena; `# limpa` tira todo mundo.
- `# expr: medo` troca o rosto de quem fala na linha; `# expr cao: pego` troca o rosto de alguém numa narração. A imagem é `art/cena/<personagem>_<expressão>.webp`; enquanto ela não existe, fica o neutro. A lista de poses para gerar está no doc "Capítulo 2 · o que falta decidir e lista de poses".
- `# musica: nome` troca a música (`musica/<nome>.mp3`). Sem a tag, cada fundo já tem a sua faixa (a tabela fica em `MUSICA_FUNDO`, no `web/template.html`).
- As explicações para quem não joga Vampiro (ficha de cada personagem, botão "?", dica ao passar o mouse nas etiquetas e o tutorial do começo) ficam em `web/template.html`, no bloco "Ajuda para quem não joga Vampiro". As notas da ficha repetem as do roteiro: mudou uma, mude a outra.
- Celular: o mesmo `web/template.html` serve em pé e deitado (bloco "Celular" no CSS). Em pé, a cena fica em cima e o texto embaixo; deitado, é a tela do PC. No toque, tocar numa etiqueta (ou segurar o dedo na opção) mostra a dica, e tocar na cena avança.
- `# imagem: nome` mostra uma ilustração de momento-chave por cima da cena; `# final: letra` marca o final.
- Hora falada e hora no caderno vêm do relógio do jogo: use `{hora_falada()}` ("Três e dez"), `{hora_digital()}` ("03h10") e `{tempo_falta()}` ("uma hora e vinte minutos"). Os avisos do Vincenzo entram em qualquer conversa com `-> avisos ->`.
- Palavra com gênero falando com o protagonista: `forasteir{o}` ou `{o == "a":moça|moço}`. O `test_texto.cjs` joga com a Irene e a Joana e acusa masculino solto.
- `@pistas` numa fala vira "N pistas", com o número do caderno.

## Capítulos

- Cada capítulo novo fica no seu arquivo e entra com `INCLUDE` no fim do `ink/jogo.ink` (o `compile.cjs` e o fluxograma colam o texto no lugar da linha).
- O capítulo 1 guarda o final em `final_cap1` (B, C_corte, C_anarq, E, F, G, H ou S). O capítulo 2 começa no knot `capitulo_2` e muda o texto e quem te protege conforme esse final. Sem jogo do capítulo 1, `capitulo_2_novo` escolhe o personagem e começa como se fosse o final B.
- `# capitulo: 2` no roteiro limpa o caderno e avisa na tela. Ao fim do capítulo 1 com o personagem vivo, a tela de fim oferece "Seguir para o capítulo 2" e guarda o estado em `localStorage` (`matusalem-cap1`); o botão "Capítulo 2" da capa começa dali.
- Capítulo 2: dentro do salão (`dentro`) vale a lei do Elísio, e Disciplina ali põe você para fora (`expulso`). Do lado de fora, `acender(n)` sobe o `sinal` do chip; no 5, o BOES chega. O marcador Sinal aparece no topo a partir do capítulo 2.
- `node test_cap2.cjs` joga o capítulo 2 partindo de cada final do 1, confere o caminho neutro (só conversa e provas) com os três personagens e o final S do capítulo 1.

## Fluxograma das escolhas

`npm run fluxo` lê o roteiro em Ink e gera `dist/fluxo.html` (na Vercel, em `/fluxo.html`): um mapa de todas as cenas, com as opções de cada uma, o que cada opção pede, as pistas que ela dá e as opções que ela abre ou tranca em outras cenas. Também joga partidas de teste com escolhas ao acaso e mostra quanto cada cena, pista e final aparece por personagem.

- Cada capítulo aponta para o seu arquivo `.ink` em `fluxo/capitulos.json`. Num arquivo só, a linha `// CAPÍTULO 2: Título` muda o capítulo dos knots seguintes.
- As linhas `// ------ NOME` do roteiro viram as cores das seções no mapa, e o comentário de cada `VAR` vira o nome da pista ou da trava. Escreva esse comentário em português de gente.
- `node fluxo/gerar.cjs 0` gera sem as partidas de teste, em menos de um segundo.

## Versão Ink

```
npm install
npm run testar   # joga a história milhares de vezes, procura erro de gênero e confere os caminhos certos e errados da acusação
npm run build    # gera dist/index.html
```

Para editar o roteiro e jogar o texto na hora, use o editor Inky (github.com/inkle/inky) e abra `ink/jogo.ink`.

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

## Publicar na Vercel

O jogo web é um site estático: `dist/index.html` mais as músicas em `dist/musica/`. O `vercel.json` já diz à Vercel para compilar o roteiro (`npm run compilar && node build_web.cjs cdn`) e publicar a pasta `dist/`. É só importar o repositório na Vercel, sem mudar nenhuma configuração. A arte já está pronta em `art/cena/`, então o build não precisa de Python.

## Registro anônimo das partidas (PostHog)

Para ver onde os jogadores travam, o jogo publicado manda eventos anônimos ao PostHog (plano grátis). Fica tudo em `web/template.html`, bloco "Registro anônimo".

- Eventos: `jogo_aberto`, `partida_iniciada`, `personagem_escolhido`, `cena` (mudou de trecho do roteiro), `escolha`, `abriu` (ajuda, caderno, histórico), `tutorial_pulado`, `parado` (2 minutos sem clicar), `saiu` (fechou ou trocou de aba no meio), `voltou_ao_menu`, `final`.
- Quase todo evento leva `lugar` (knot do Ink), `hora_no_jogo`, `escolhas`, `pistas`, `personagem` e `versao` (commit).
- O jogador é um número sorteado guardado no navegador (`matusalem-jogador`). Nada do caderno, nenhum nome ou e-mail.
- A chave do projeto PostHog fica em `build_web.cjs` (ou na variável `POSTHOG_CHAVE`). Sem chave, em `localhost`/`file:` ou com `?semregistro=1`, nada é enviado. Com `?registro=ver` os eventos aparecem no console em vez de sair.
