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
from PIL import Image
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
}
# pranchas de fundo vermelho chapado: o vermelho que aparece nos vãos (entre o braço e o corpo) também sai,
# e o recorte usa o modelo de ilustração (isnet-anime), que guarda o taco e os dedos finos
FUNDO_VERMELHO = {"harumi"}
# poses em que o modelo de ilustração leva junto um objeto do cenário (a mesa de sinuca): fica só o que os dois modelos acham
INTERSECAO = {"harumi_taco"}


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
        parte = img.crop(caixa)
        parte = parte.resize((parte.width * 2, parte.height * 2), Image.LANCZOS)
        if prancha in FUNDO_VERMELHO:
            out = limpar(remove(parte, session=sessao_ilustra), 128)
            if nome in INTERSECAO:
                geral = limpar(remove(parte, session=sessao))
                out.putalpha(Image.fromarray(np.minimum(np.array(out.getchannel("A")), np.array(geral.getchannel("A")))))
            out = tirar_vermelho(out)
        else:
            out = limpar(remove(parte, session=sessao))
        out = out.crop(out.getbbox())
        out.save(os.path.join(SAIDA, nome + ".png"))
        print(nome, out.size)
