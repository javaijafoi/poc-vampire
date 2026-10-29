#!/usr/bin/env bash
# Renderiza a abertura em vídeo com o HyperFrames (github.com/heygen-com/hyperframes).
# Precisa de Node e FFmpeg. Saída: video/abertura.mp4 (34 s, 1920x1080, com a música da abertura).
set -euo pipefail
cd "$(dirname "$0")/abertura"
mkdir -p img
for f in porto serra tunel corte rua; do cp ../../art/cena/fundo_$f.webp img/; done
for k in harumi rayo cao dante; do cp ../../art/cena/${k}_neutro.webp img/; done
npx -y hyperframes@0.8.214 render -q "${QUALIDADE:-looks}" -o ../abertura.mp4
# põe a música da abertura (musica/abertura.mp3, CC0) no vídeo
ffmpeg -nostdin -v error -y -i ../abertura.mp4 -i ../../musica/abertura.mp3 -map 0:v -map 1:a -c:v copy -c:a aac -b:a 160k -shortest ../abertura-com-som.mp4
mv ../abertura-com-som.mp4 ../abertura.mp4
