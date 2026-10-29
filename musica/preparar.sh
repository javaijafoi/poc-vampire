#!/usr/bin/env bash
# Baixa as faixas (todas CC0, do OpenGameArt) e gera os MP3 do jogo em musica/.
# Cada faixa é cortada, nivelada em volume (-20 LUFS) e ganha fade-out quando é cortada.
# Precisa de curl, unzip e FFmpeg. Uso: bash musica/preparar.sh
set -euo pipefail
cd "$(dirname "$0")"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
OGA=https://opengameart.org/sites/default/files

# nome  origem  início  duração(0 = inteira)  fade-out(s)
faixa() {
  local nome=$1 url=$2 ini=$3 dur=$4 fade=$5 src="$TMP/$1.src"
  curl -sfL -o "$src" "$url"
  if [[ $url == *.zip ]]; then unzip -oqj "$src" '*.ogg' -d "$TMP/$nome"; src=$(ls "$TMP/$nome"/*.ogg | head -1); fi
  local af="loudnorm=I=-20:TP=-2:LRA=11"
  if [[ $dur != 0 ]]; then af="atrim=$ini:$((ini + dur)),asetpts=PTS-STARTPTS,afade=t=out:st=$((dur - fade)):d=$fade,$af"; fi
  ffmpeg -nostdin -v error -y -i "$src" -af "$af" -ar 44100 -ac 2 -c:a libmp3lame -b:a 96k "$nome.mp3"
  echo "$nome.mp3"
}

faixa capa         "$OGA/ambient_horror_track_01_0.zip"                    0 0 0
faixa abertura     "$OGA/echoes_of_the_past.wav"                           0 39 4
faixa rua          "$OGA/012_Sirens_in_Darkness_0.mp3"                     2 120 8
faixa salao        "$OGA/ruskerdax_-_moil.mp3"                             0 0 0
faixa balcao       "$OGA/Jazz%20Take%202.wav"                              0 0 0
faixa escada       "$OGA/CrEEP.ogg"                                        0 0 0
faixa sinuca       "$OGA/qubodup-yd-DarkShrineLoop-OpenGameArt.ogg"        0 0 0
faixa sessao       "$OGA/musicbox1_spooky_waltz.ogg"                       0 0 0
faixa corte        "$OGA/Night%20of%20the%20Streets_0.mp3"                 0 0 0
faixa final_triste "$OGA/at%20the%20end%20of%20hope_0.mp3"                 1 120 8
faixa final_verdade "$OGA/bleeding_out2_2.ogg"                             1 120 8
