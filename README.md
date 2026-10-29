# O Matusalém Desaparecido

Jogo de investigação em estilo visual novel, ambientado na São Paulo de Vampiro: A Máscara (V5). Um Matusalém sumiu no caminho entre o Porto de Santos e o cofre do Príncipe Dante. Você interroga quatro testemunhas no Porão do Vincenzo, uma em cada canto do bar, e acusa alguém antes do amanhecer. Ninguém conta a verdade inteira, como em Rashomon.

Primeira versão jogável: tela inicial, abertura animada, escolha entre 3 personagens prontos (Gangrel, Nosferatu, Ministério), as testemunhas (Rayo, Cão, Harumi e o fantasma do Biel, chamado pela Nonna), a acusação diante da Corte e 4 finais. As imagens ainda são provisórias.

| Pasta | O que é |
| --- | --- |
| `ink/jogo.ink` | Roteiro completo em Ink |
| `ink/rayo.ink` | A cena de teste antiga (só o Rayo), mantida para comparação com o Ren'Py |
| `web/` | Interface web que roda o roteiro |
| `dist/index.html` | Jogo web pronto, num arquivo só, com a música ao lado em `dist/musica/`. Abra no navegador (precisa de internet para o motor Ink e as fontes) |
| `art/` | Arte: `recortar_personagens.py` tira o fundo das artes do Trello, `gerar_fundos.py` gera os fundos com sdxl-turbo, `montar_cena.py` faz o recorte de revista e os fundos finais (`npm run arte`) |
| `musica/` | Trilha sonora: uma faixa por cena, todas CC0 (`CREDITOS.md` diz qual toca onde; `bash musica/preparar.sh` refaz os MP3) |
| `video/` | A abertura como vídeo MP4, feita com HyperFrames (`bash video/renderizar.sh`) |
| `renpy/game/` | A cena de teste em Ren'Py |
| `bench/` | Medição de tempo de carregamento |

## Convenções do roteiro

- `Rayo: texto` é fala; linha sem nome é narração.
- `Gatilho :: texto` é uma opção ou observação especial (clã, atributo, prova, teste, Disciplina) e aparece com uma etiqueta colorida.
- `# pista <aba>: texto` coloca a pista no caderno, na folha da aba (`dossie`, `rayo`, `cao`, `harumi`, `biel`, `bar`).
- `# fundo: nome` troca o fundo (`art/cena/fundo_<nome>.webp`); `# entra: nome` põe a testemunha em cena; `# limpa` tira todo mundo.
- `# musica: nome` troca a música (`musica/<nome>.mp3`). Sem a tag, cada fundo já tem a sua faixa (a tabela fica em `MUSICA_FUNDO`, no `web/template.html`).
- As explicações para quem não joga Vampiro (ficha de cada personagem, botão "?", dica ao passar o mouse nas etiquetas e o tutorial do começo) ficam em `web/template.html`, no bloco "Ajuda para quem não joga Vampiro". As notas da ficha repetem as do roteiro: mudou uma, mude a outra.
- `# imagem: nome` mostra uma ilustração de momento-chave por cima da cena; `# final: letra` marca o final.
- Hora falada e hora no caderno vêm do relógio do jogo: use `{hora_falada()}` ("Três e dez"), `{hora_digital()}` ("03h10") e `{tempo_falta()}` ("uma hora e vinte minutos"). Os avisos do Vincenzo entram em qualquer conversa com `-> avisos ->`.
- Palavra com gênero falando com o protagonista: `forasteir{o}` ou `{o == "a":moça|moço}`. O `test_texto.cjs` joga com a Irene e a Joana e acusa masculino solto.
- `@pistas` numa fala vira "N pistas", com o número do caderno.

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
