#!/usr/bin/env bash
# Renderiza a abertura em vídeo com o HyperFrames (github.com/heygen-com/hyperframes).
# Precisa de Node e FFmpeg. Saída: video/abertura.mp4 (34 s, 1920x1080).
set -euo pipefail
cd "$(dirname "$0")/abertura"
mkdir -p img
for f in porto serra tunel corte rua; do cp ../../art/cena/fundo_$f.webp img/; done
for k in paizao rayo cao dante; do cp ../../art/cena/${k}_neutro.webp img/; done
npx -y hyperframes@0.8.214 render -q "${QUALIDADE:-looks}" -o ../abertura.mp4
