"""Recorta as poses das pranchas que o Peter gera no Gemini (uma prancha por personagem, várias poses).

Uso: python3 art/recortar_poses.py [prancha ...]   (sem nome, faz todas)
As pranchas ficam em art/fontes/pranchas/<nome>.jpg. Cada pose tem uma caixa em pixels na prancha
(esq, topo, dir, base), já cortada na altura da cintura, como os retratos do jogo.
Sai em art/fontes/<personagem>_<pose>.png; depois, `npm run arte` faz o recorte de revista com a bordinha.
Só tratamento técnico (tirar fundo e os textos da prancha, cortar): nada é redesenhado.
"""
import os
import sys

import numpy as np
from PIL import Image, ImageOps
from scipy import ndimage
from rembg import new_session, remove

AQUI = os.path.dirname(os.path.abspath(__file__))
PRANCHAS, SAIDA = os.path.join(AQUI, "fontes", "pranchas"), os.path.join(AQUI, "fontes")

# prancha: {arquivo de saída: caixa}. As pranchas têm 1376 x 768.
POSES = {
    "rocha": {  # o rótulo da prancha diz "ANNEX", mas é o Agente Rocha
        "rocha_neutro": (40, 40, 452, 500),
        "rocha_sorriso": (470, 40, 912, 500),
        "rocha_radio": (928, 40, 1345, 520),
    },
    "rayo": {
        "rayo_bravo": (30, 30, 470, 386),
        "rayo_medo": (470, 30, 900, 386),
        "rayo_fechado": (900, 30, 1345, 386),
        "rayo_sorriso": (30, 388, 470, 742),
        "rayo_mao": (470, 388, 900, 742),
        "rayo_olho": (900, 388, 1305, 700),
    },
    "dante": {
        "dante_pe": (40, 40, 395, 470),          # "leaving the bar"
        "dante_ordem": (370, 265, 740, 610),     # "giving an order"
        "dante_calado": (715, 45, 1000, 470),    # "silent & cold"
        "dante_pulso": (785, 225, 1345, 640),    # "the oath": a mão estendida, oferecendo o sangue
    },
    "harumi": {  # a prancha estilizada (fundo vermelho); a realista com acabamento do Rayo ficou só no teste
        "harumi_neutro": (40, 88, 340, 440),
        "harumi_taco": (366, 88, 680, 320),
        "harumi_manga": (700, 88, 1020, 375),
        "harumi_medo": (1040, 88, 1345, 460),
        "harumi_brava": (362, 432, 680, 640),
        "harumi_desdem": (700, 432, 1020, 745),
    },
    # capítulo 1 (2026-10-31): Cão de frente, Vincenzo, Constance, Biel e a Nonna (imagem avulsa, só a neutra)
    "cao": {
        "cao_neutro": (35, 50, 340, 420),
        "cao_desdem": (415, 50, 700, 376),
        "cao_pego": (738, 48, 1030, 350),
        "cao_arrebatado": (1065, 48, 1340, 332),
        "cao_encurralado": (355, 405, 598, 690),
        "cao_sorriso": (612, 415, 860, 712),
        "cao_ataque": (878, 405, 1338, 712),
    },
    "vincenzo": {
        "vincenzo_neutro": (30, 45, 672, 370),
        "vincenzo_bracos": (705, 45, 1345, 370),
        "vincenzo_copo": (30, 432, 672, 740),
        "vincenzo_aponta": (705, 432, 1345, 740),
    },
    "constance": {
        "constance_neutro": (20, 15, 452, 357),
        "constance_riso": (470, 15, 905, 357),
        "constance_seria": (922, 15, 1357, 357),
        "constance_furia": (302, 393, 678, 725),
        "constance_sussurro": (697, 393, 1357, 728),
    },
    "biel": {  # das três "confused", a 1
        "biel_neutro": (40, 76, 345, 372),
        "biel_confuso": (442, 76, 675, 372),
        "biel_chorando": (172, 395, 452, 735),
        "biel_sorriso": (592, 395, 895, 735),
        "biel_encolhido": (918, 395, 1340, 735),
    },
    "nonna": {"nonna_neutro": None},  # imagem avulsa inteira
}
# pranchas de fundo vermelho chapado: o vermelho que aparece nos vãos (entre o braço e o corpo) também sai,
# e o recorte usa o modelo de ilustração (isnet-anime), que guarda o taco e os dedos finos
FUNDO_VERMELHO = {"harumi"}
# fundo vermelho, mas com o modelo geral (o terno risca de giz sai melhor nele): só apaga o vermelho dos vãos
VERMELHO_GERAL = {"vincenzo"}
# poses em que o modelo de ilustração leva junto um objeto do cenário (a mesa de sinuca): fica só o que os dois modelos acham
INTERSECAO = {"harumi_taco"}


def fantasma(im):
    """O Biel é o morto que a Nonna chama: duotone azul e branco, um pouco transparente (igual ao recortar_personagens.py)."""
    alfa = im.getchannel("A")
    cinza = ImageOps.autocontrast(im.convert("L"), cutoff=1)
    cor = ImageOps.colorize(cinza, black=(8, 22, 58), mid=(70, 130, 200), white=(240, 248, 255))
    cor.putalpha(Image.fromarray((np.array(alfa) * 0.88).astype(np.uint8)))
    return cor


def limpar(im, limiar=30):
    """Alfa sólido: fica só a maior mancha (some o texto da prancha), sem buracos."""
    a = np.array(im.getchannel("A")) > limiar
    rot, n = ndimage.label(a)
    if n > 1:
        a = rot == (np.argmax(np.bincount(rot.ravel())[1:]) + 1)
    a = ndimage.binary_fill_holes(a)
    im.putalpha(Image.fromarray(np.where(a, np.maximum(np.array(im.getchannel("A")), 255 * a), 0).astype(np.uint8)))
    return im


def tirar_vermelho(im, minimo=150):
    """Apaga manchas grandes do vermelho do fundo que ficaram dentro do recorte (o rembg preenche os vãos)."""
    a = np.array(im).astype(np.int16)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    verm = ((r > 105) & (r > 2.0 * g) & (r > 2.0 * b)) | ((r > 22) & (r > 2.8 * g) & (r > 2.8 * b))
    verm = ndimage.binary_opening(verm, iterations=2)
    rot, n = ndimage.label(verm)
    if n:
        tam = np.bincount(rot.ravel()); tam[0] = 0
        grande = tam[rot] >= minimo
        grande = ndimage.binary_dilation(grande, iterations=2)
        alfa = np.array(im.getchannel("A")); alfa[grande] = 0
        im.putalpha(Image.fromarray(alfa))
    return im


sessao = new_session("isnet-general-use")
sessao_ilustra = new_session("isnet-anime")
for prancha in sys.argv[1:] or POSES:
    img = Image.open(os.path.join(PRANCHAS, prancha + ".jpg")).convert("RGB")
    for nome, caixa in POSES[prancha].items():
        # amplia 2x antes do rembg: a prancha é pequena e o recorte fica mais limpo
        parte = img.crop(caixa) if caixa else img
        if caixa:
            parte = parte.resize((parte.width * 2, parte.height * 2), Image.LANCZOS)
        if prancha in FUNDO_VERMELHO:
            out = limpar(remove(parte, session=sessao_ilustra), 128)
            if nome in INTERSECAO:
                geral = limpar(remove(parte, session=sessao))
                out.putalpha(Image.fromarray(np.minimum(np.array(out.getchannel("A")), np.array(geral.getchannel("A")))))
            out = tirar_vermelho(out)
        else:
            out = limpar(remove(parte, session=sessao))
            if prancha in VERMELHO_GERAL:
                out = tirar_vermelho(out)
        out = out.crop(out.getbbox())
        if prancha == "biel":
            out = fantasma(out)
        out.save(os.path.join(SAIDA, nome + ".png"))
        print(nome, out.size)
