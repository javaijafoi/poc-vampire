#!/bin/bash
# Mede a versão Ren'Py: lint, tempo até a primeira tela, memória e partidas automáticas.
# Uso: RENPY_SDK=/caminho/do/sdk bench/renpy/medir.sh [partidas]
# Precisa de uma tela (no Linux sem monitor: Xvfb :99 & export DISPLAY=:99).
set -e
RAIZ="$(cd "$(dirname "$0")/../.." && pwd)"
PARTIDAS="${1:-200}"
TMP="$(mktemp -d)"
cp -r "$RAIZ/renpy/." "$TMP/"
rm -rf "$TMP/game/cache" "$TMP/game/saves" "$TMP"/game/*.rpyc
cp "$RAIZ/bench/renpy/zz_bench.rpy" "$TMP/game/"
export SDL_AUDIODRIVER=dummy
LOG="$TMP/medicoes.jsonl"

"$RENPY_SDK/renpy.sh" "$TMP" lint
"$RENPY_SDK/renpy.sh" "$TMP" compile >/dev/null   # gera os .rpyc, como num jogo distribuído

for i in 1 2 3 4 5; do
  PORAO_LOG="$LOG" PORAO_T0="$(date +%s.%N)" "$RENPY_SDK/renpy.sh" "$TMP" >/dev/null 2>&1 &
  PID=$!; sleep 5; kill $PID 2>/dev/null; sleep 1; kill -9 $PID 2>/dev/null || true; wait $PID 2>/dev/null || true
done
if [ -f "$TMP/traceback.txt" ]; then echo "ERRO ao fechar:"; cat "$TMP/traceback.txt"; rm "$TMP/traceback.txt"; fi

PORAO_LOG="$LOG" PORAO_AUTO="$PARTIDAS" timeout 1800 "$RENPY_SDK/renpy.sh" "$TMP" >/dev/null 2>&1 || true
if [ -f "$TMP/traceback.txt" ]; then echo "ERRO:"; cat "$TMP/traceback.txt"; fi
python3 -I "$RAIZ/bench/renpy/resumo.py" "$LOG" "$PARTIDAS"
