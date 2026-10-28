"""Resume o arquivo de medições gerado por medir.sh."""
import collections
import json
import statistics
import sys

linhas = [json.loads(l) for l in open(sys.argv[1])]
pedidas = int(sys.argv[2]) if len(sys.argv) > 2 else None
telas = [l for l in linhas if l["evento"] == "primeira_tela"]
partidas = [l for l in linhas if l["evento"] == "partida"]

if telas:
    ms = sorted(t["ms"] for t in telas)
    print("Primeira tela: mediana %d ms %s, memória %.0f MB" % (
        statistics.median(ms), ms, statistics.median(t["rss_mb"] for t in telas)))

if partidas:
    print("Partidas que chegaram ao fim: %d de %s" % (len(partidas), pedidas or "?"))
    print("Confessou: %d%%  Quebrou a regra: %d%%" % (
        100 * sum(p["confessou"] for p in partidas) / len(partidas),
        100 * sum(p["quebrou_regra"] for p in partidas) / len(partidas)))
    vistos = collections.Counter(l for p in partidas for l in set(p["labels"]))
    print("Cenas visitadas (partidas):", dict(sorted(vistos.items())))
    print("Memória no fim: máx %.0f MB" % max(p["rss_mb"] for p in partidas))
