# Interface e regras da cena de teste: HUD, caixa de diálogo, menu, dados V5 e caderno.

define config.name = "Porão do Vincenzo"
define config.version = "0.1"
define config.window_title = "Porão do Vincenzo"
define config.screen_width = 1280
define config.screen_height = 720
define config.save_directory = "PoraoDoVincenzo-poc"
define config.default_text_cps = 60
define build.name = "PoraoDoVincenzo"
define _game_menu_screen = None

define COR_PAPEL = "#efe3d2"
define COR_PAPEL_FRACO = "#b9a594"
define COR_AMBAR = "#e0a54a"
define COR_SANGUE = "#c8313f"
define COR_PAINEL = "#1a0c11f0"
define COR_BORDA = "#5a2c35"

# Pula o menu principal: o teste começa direto na cena.
label main_menu:
    return

init python:
    import random

    RESULTADOS = ["Falha", "Sucesso", "Crítico", "Crítico bagunçado", "Falha bestial"]

    def rolar(parada, fome, dificuldade):
        """Teste de V5. Resultado: 0 falha, 1 sucesso, 2 crítico, 3 crítico bagunçado, 4 falha bestial."""
        n_fome = min(fome, parada)
        dados = [(random.randint(1, 10), i < n_fome) for i in range(parada)]
        sucessos = sum(1 for v, _ in dados if v >= 6)
        dezes = [f for v, f in dados if v == 10]
        pares = len(dezes) // 2
        sucessos += pares * 2
        passou = sucessos >= dificuldade
        if passou and pares and any(dezes):
            resultado = 3
        elif passou and pares:
            resultado = 2
        elif passou:
            resultado = 1
        elif any(f and v == 1 for v, f in dados):
            resultado = 4
        else:
            resultado = 0
        store.ultimo_dado = dict(dados=dados, sucessos=sucessos, dificuldade=dificuldade, resultado=resultado)
        return resultado

    def despertar():
        if random.randint(1, 10) < 6:
            store.fome = min(5, store.fome + 1)
            renpy.notify("Teste de Despertar: a Fome subiu")
        else:
            renpy.notify("Teste de Despertar: a Fome se manteve")

    def pista(texto):
        store.pistas.append(texto)
        renpy.notify("Nova pista no caderno")

    def passar(m):
        store.minutos += m

    def hora_txt():
        h = (23 + store.minutos // 60) % 24
        return "%02dh%02d" % (h, store.minutos % 60)

    def badge_cor(gatilho):
        if gatilho.split(" ")[0] in ("Gangrel", "Ventrue", "Nosferatu", "Brujah", "Toreador", "Tremere", "Malkaviano", "Lasombra"):
            return "#4b2a6b"
        if gatilho.startswith("Prova"):
            return "#6a4a12"
        if gatilho.startswith("Teste"):
            return "#2e4a2c"
        if gatilho.startswith("Disciplina"):
            return "#6b1622"
        return "#1d3550"

default ultimo_dado = None

style padrao_texto:
    color COR_PAPEL
    size 26
style rotulo_hud:
    color COR_PAPEL_FRACO
    size 14
style valor_hud:
    color COR_AMBAR
    size 30

# HUD: hora, Fome e caderno
screen hud():
    zorder 10
    hbox:
        xpos 32 ypos 32 spacing 12
        frame:
            background COR_PAINEL padding (14, 10)
            vbox:
                text "HORA" style "rotulo_hud"
                text hora_txt() style "valor_hud"
                bar value StaticValue(max(0, limite - minutos), 100) xsize 130 ysize 4 left_bar Solid(COR_AMBAR) right_bar Solid("#3d1b24")
        frame:
            background COR_PAINEL padding (14, 10)
            vbox spacing 6:
                text "FOME" style "rotulo_hud"
                hbox spacing 4:
                    for i in range(1, 6):
                        frame:
                            xysize (16, 16) padding (0, 0)
                            background Solid(COR_SANGUE if i <= fome else "#3d1b24")
        button:
            background COR_PAINEL hover_background "#3d1b24" padding (14, 10)
            action Show("caderno")
            vbox:
                text "CADERNO" style "rotulo_hud"
                text str(len(pistas)) style "valor_hud"

# Caixa de diálogo
screen say(who, what):
    window:
        id "window"
        background COR_PAINEL
        xalign 0.5 yalign 0.97 xsize 1200 ysize 190 padding (36, 34)
        if who is not None:
            frame:
                background COR_AMBAR padding (14, 4) xpos -14 ypos -52
                text who id "who" color "#1d0e08" size 22 bold True
        text what id "what" style "padrao_texto" italic (who is None) color (COR_PAPEL_FRACO if who is None else COR_PAPEL)

# Observação passiva (atributo alto): o nome do atributo vira uma etiqueta azul
screen say_passiva(who, what):
    window:
        id "window"
        background COR_PAINEL
        xalign 0.5 yalign 0.97 xsize 1200 ysize 190 padding (36, 34)
        hbox spacing 14:
            frame:
                background "#1d3550" padding (10, 2) yalign 0.0
                text who id "who" color "#bcd9f5" size 18
            text what id "what" style "padrao_texto" italic True color COR_PAPEL_FRACO

# Menu de escolhas. "Gatilho :: texto" vira etiqueta colorida + texto.
screen choice(items):
    window:
        background COR_PAINEL
        xalign 0.5 yalign 0.97 xsize 1200 padding (30, 24)
        if nome == "":
            hbox spacing 24:
                for n, i in enumerate(items, 1):
                    $ partes = i.caption.split(". ", 1)
                    button:
                        xsize 556 padding (20, 18) background "#2a1219" hover_background "#3d1b24"
                        action i.action
                        vbox spacing 6:
                            text partes[0] color COR_AMBAR size 30 bold True
                            text partes[1] color COR_PAPEL_FRACO size 22
                    key str(n) action i.action
        else:
            vbox spacing 2:
                for n, i in enumerate(items, 1):
                    $ partes = i.caption.split(" :: ", 1)
                    button:
                        xfill True padding (12, 6) background None hover_background "#3d1b24"
                        action i.action
                        hbox spacing 14:
                            text str(n) color COR_PAPEL_FRACO size 22 min_width 20
                            if len(partes) == 2:
                                frame:
                                    background badge_cor(partes[0]) padding (8, 2) yalign 0.5
                                    text partes[0] color COR_PAPEL size 16
                                text partes[1] color COR_PAPEL size 22 hover_color COR_AMBAR
                            else:
                                text partes[0] color COR_PAPEL size 22 hover_color COR_AMBAR
                    key str(n) action i.action

# Resultado da rolagem de dados
screen dados():
    modal True
    zorder 20
    frame:
        background "#120a0ef2" xalign 0.5 yalign 0.35 padding (36, 26)
        vbox spacing 14 xalign 0.5:
            text "Parada de %d dados · dificuldade %d" % (len(ultimo_dado["dados"]), ultimo_dado["dificuldade"]) color COR_PAPEL_FRACO size 18 xalign 0.5
            hbox spacing 10 xalign 0.5:
                for valor, de_fome in ultimo_dado["dados"]:
                    frame:
                        xysize (54, 54) padding (0, 0)
                        background Solid((COR_SANGUE if de_fome else COR_PAPEL) if valor >= 6 else ("#4a1a22" if de_fome else "#2a1219"))
                        text str(valor) xalign 0.5 yalign 0.5 size 26 color ("#1d0e08" if valor >= 6 and not de_fome else COR_PAPEL)
            text "%s · %d sucessos" % (RESULTADOS[ultimo_dado["resultado"]], ultimo_dado["sucessos"]) color COR_AMBAR size 28 xalign 0.5
            text "Dados vermelhos são de Fome. Clique para continuar." color COR_PAPEL_FRACO size 16 xalign 0.5
    key "dismiss" action Return()
    button:
        xfill True yfill True background None action Return()

# Caderno de pistas
screen caderno():
    modal True
    zorder 30
    add Solid("#0c0609e6")
    frame:
        background "#e9dcc4" xalign 0.5 yalign 0.5 xsize 760 padding (40, 32)
        vbox spacing 12:
            text "Caderno do interrogatório" color "#2a1810" size 30 bold True
            if pistas:
                for n, p in enumerate(pistas, 1):
                    text "%d. %s" % (n, p) color "#2a1810" size 22
            else:
                text "Nenhuma pista ainda." color "#6d5440" size 22 italic True
            textbutton "Fechar" action Hide("caderno") text_color "#2a1810" text_hover_color "#8b2a2a"
    key "game_menu" action Hide("caderno")

screen fim_cena():
    modal True
    frame:
        background COR_PAINEL xalign 0.5 yalign 0.97 xsize 1200 padding (36, 30)
        vbox spacing 10:
            text "FIM DA CENA DE TESTE" color COR_PAPEL_FRACO size 18
            text "Você saiu com %d pista%s." % (len(pistas), "" if len(pistas) == 1 else "s") style "padrao_texto"
            hbox spacing 24:
                textbutton "Ver o caderno" action Show("caderno") text_color COR_PAPEL text_hover_color COR_AMBAR
                textbutton "Jogar de novo" action Return() text_color COR_PAPEL text_hover_color COR_AMBAR

# Aviso no canto (nova pista, teste de Despertar)
screen notify(message):
    zorder 100
    style_prefix "notify"
    frame at aviso_aparece:
        background "#6a4a12" xalign 0.97 ypos 32 padding (16, 8)
        text "[message!tq]" color "#f8dfa5" size 18
    timer 2.6 action Hide("notify")

transform aviso_aparece:
    on show:
        alpha 0 yoffset -6
        linear .25 alpha 1 yoffset 0
    on hide:
        linear .4 alpha 0
