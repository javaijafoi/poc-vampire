# Ferramenta de medição: NÃO faz parte do jogo. Os scripts bench/renpy/medir.sh
# e medir_web.sh copiam este arquivo para uma cópia temporária do projeto.
#
#   PORAO_T0=<epoch do lançamento>  mede o tempo até a primeira tela com texto
#   PORAO_AUTO=<n>                  joga n partidas com escolhas aleatórias
#   PORAO_LOG=<arquivo>             onde gravar os resultados (uma linha JSON por evento)

init 999 python:
    import os, time, json

    _bench_log = os.environ.get("PORAO_LOG")
    _bench_auto = int(os.environ.get("PORAO_AUTO", "0"))

    def _bench_write(**d):
        if _bench_log:
            with open(_bench_log, "a") as f:
                f.write(json.dumps(d, ensure_ascii=False) + "\n")

    def _bench_rss_mb():
        with open("/proc/self/status") as f:
            for l in f:
                if l.startswith("VmRSS"):
                    return int(l.split()[1]) / 1024.0

    _bench_primeira = [False]

    def _bench_interact():
        if renpy.emscripten and not _bench_primeira[0]:
            # Versão web: avisa a página, que mede o tempo pelo relógio do navegador.
            _bench_primeira[0] = True
            import emscripten
            emscripten.run_script("window.porao_primeira_tela = performance.now(); console.log('PRIMEIRA_TELA')")
        if not _bench_primeira[0] and os.environ.get("PORAO_T0"):
            _bench_primeira[0] = True
            _bench_write(evento="primeira_tela", ms=round((time.time() - float(os.environ["PORAO_T0"])) * 1000), rss_mb=round(_bench_rss_mb(), 1))

    config.start_interact_callbacks.append(_bench_interact)

    if _bench_auto:
        config.auto_choice_delay = 0.001
        _preferences.text_cps = 0
        _preferences.transitions = 0

        def _bench_label(name, abnormal):
            if not name.startswith("_"):
                store._bench_labels = getattr(store, "_bench_labels", []) + [name]
        config.label_callbacks.append(_bench_label)

        def _bench_passo():
            if renpy.get_screen("fim_cena"):
                feitas = 0
                if os.path.exists(_bench_log):
                    with open(_bench_log) as f:
                        feitas = sum(1 for l in f if '"partida"' in l)
                _bench_write(evento="partida", n=feitas + 1, cla=store.cla, labels=getattr(store, "_bench_labels", []),
                             pistas=len(store.pistas), confessou=store.confessou, quebrou_regra=store.quebrou_regra,
                             hora=store.hora_txt(), rss_mb=round(_bench_rss_mb(), 1))
                if feitas + 1 >= _bench_auto:
                    renpy.quit()
                renpy.full_restart()
            renpy.queue_event("dismiss")

        config.overlay_screens.append("_bench_driver")

screen _bench_driver():
    timer 0.01 repeat True action Function(_bench_passo, _update_screens=False)
