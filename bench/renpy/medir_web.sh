#!/bin/bash
# Gera o build web do Ren'Py com o medidor e mede no Chromium.
# Uso: RENPY_SDK=/caminho/do/sdk bench/renpy/medir_web.sh [repetições]
# O SDK precisa do suporte web (renpy-<versão>-web.zip descompactado dentro dele).
set -e
RAIZ="$(cd "$(dirname "$0")/../.." && pwd)"
TMP="$(mktemp -d)"
mkdir "$TMP/PoraoDoVincenzo"
cp -r "$RAIZ/renpy/." "$TMP/PoraoDoVincenzo/"
rm -rf "$TMP/PoraoDoVincenzo/game/cache" "$TMP/PoraoDoVincenzo/game/saves"
cp "$RAIZ/bench/renpy/zz_bench.rpy" "$TMP/PoraoDoVincenzo/game/"
SDL_AUDIODRIVER=dummy "$RENPY_SDK/renpy.sh" "$RENPY_SDK/launcher" web_build "$TMP/PoraoDoVincenzo" --destination "$TMP/web" >/dev/null
du -sh "$TMP/web"
node "$RAIZ/bench/renpy/medir_web.cjs" "$TMP/web" "${1:-3}"
