"""Tira o fundo das artes do Peter (Trello) e corta na altura do peito, como o Rayo e o Vincenzo.

Uso: python3 art/recortar_personagens.py [chave ...]   (sem chave, faz todos)
ARTES=<pasta> muda a pasta das artes do Trello (padrão /mnt/project-files/trello/artes).
Sai em art/fontes/<chave>_neutro.png; depois, `npm run arte` faz o recorte de revista.
Só tratamento técnico (tirar fundo, cortar, filtro de cor): nenhuma arte é redesenhada.
"""
import os
import sys

import numpy as np
from PIL import Image, ImageOps
from scipy import ndimage
from rembg import new_session, remove

ARTES = os.environ.get("ARTES", "/mnt/project-files/trello/artes")
SAIDA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fontes")

# chave: (arquivo, corte em frações (esq, topo, dir, base), filtro)
PERSONAGENS = {
    "dante": ("dante.png", (0, .15, 1, .80), None),
    "cao": ("originais/Cao__4320b7.png", (0, .08, 1, .72), None),
    "harumi": ("originais/Harumi__88a88e.png", (.12, .04, .88, .76), None),  # a de quimono (o Peter preferiu esta)
    "nonna": ("nonna-benedetta.png", (0, .14, 1, .56), None),
    "constance": ("constance.png", (0, .10, 1, .65), None),
    "biel": ("biel.png", (.30, .10, 1, .72), "fantasma"),  # o Biel morto, no lugar do carniçal Zé Carlos
    # capítulo 2, o Elísio do MASP (provisórios até o Peter gerar as poses)
    "isadora": ("originais/Isadora__561446.png", (.10, .04, .90, .58), None),
    "arnaldo": ("originais/Dr_Arnaldo__274012.png", (.08, .08, .92, 1), None),
    "arnaldo_lamina": ("originais/Dr_Arnaldo__3bf5e7.png", (.10, .17, .90, .62), None),  # arte que já existe: a faca
    "rocha": ("originais/Agente_Rocha__2ff3b8.png", (0, 0, 1, 1), None),  # pop art; o Peter vai refazer
    "valentina": ("valentina.png", (.12, .08, .88, .60), None),
    "luciana": ("originais/Luciana__d66572.png", (.20, .06, .86, .70), None),
}


def fantasma(im):
    """Duotone azul e branco, um pouco transparente: o morto que a Nonna chama."""
    alfa = im.getchannel("A")
    cinza = ImageOps.autocontrast(im.convert("L"), cutoff=1)
    cor = ImageOps.colorize(cinza, black=(8, 22, 58), mid=(70, 130, 200), white=(240, 248, 255))
    cor.putalpha(Image.fromarray((np.array(alfa) * 0.88).astype(np.uint8)))
    return cor


def limpar(im, limiar):
    """Alfa sólido: fica só a maior mancha, sem buracos (o rembg deixa partes escuras meio transparentes)."""
    a = np.array(im.getchannel("A")) > limiar
    rot, n = ndimage.label(a)
    if n > 1:
        a = rot == (np.argmax(np.bincount(rot.ravel())[1:]) + 1)
    a = ndimage.binary_fill_holes(a)
    im.putalpha(Image.fromarray(np.where(a, np.maximum(np.array(im.getchannel("A")), 255 * a), 0).astype(np.uint8)))
    return im


sessao = new_session("isnet-general-use")
for chave in sys.argv[1:] or PERSONAGENS:
    arq, (e, t, d, b), filtro = PERSONAGENS[chave]
    im = Image.open(os.path.join(ARTES, arq)).convert("RGB")
    im.thumbnail((1400, 1400))
    W, H = im.size
    im = im.crop((round(e * W), round(t * H), round(d * W), round(b * H)))
    out = limpar(remove(im, session=sessao), 30)
    out = out.crop(out.getbbox())
    if filtro == "fantasma":
        out = fantasma(out)
    # "arnaldo_lamina" já é uma expressão; o resto é o neutro do personagem
    out.save(os.path.join(SAIDA, f"{chave}.png" if "_" in chave else f"{chave}_neutro.png"))
    print(chave, out.size)
