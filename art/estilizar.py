"""Rayo estilizado: pixel art com sombreamento chapado e expressões desenhadas pixel a pixel.

Uso: python3 art/estilizar.py SAIDA_DIR
Gera rayo_<largura>_<expressao>.png para cada resolução e expressão.

Como funciona:
1. Achata a arte original (mean shift) para tirar a textura de foto.
2. Reduz para a largura alvo e troca cada pixel por um tom de uma paleta curta:
   rampa de pele dentro das regiões de pele, rampa de couro e cabelo no resto.
3. Apaga olhos, sobrancelhas e boca e redesenha cada expressão em pixels.
"""
import sys

import cv2
import numpy as np
from PIL import Image, ImageDraw

FONTE = "art/fontes/rayo_recorte.png"

# Regiões de pele, em coordenadas da arte original (1192x1372)
ROSTO = [(330, 200), (650, 170), (685, 360), (650, 430), (560, 450), (380, 455), (320, 430), (300, 360)]
BRACO = [(820, 700), (940, 680), (1060, 760), (1110, 1000), (1120, 1372), (900, 1372), (840, 1120), (820, 900)]

# Paletas: do mais escuro ao mais claro
CONTORNO = (18, 10, 14)
PELE = [(36, 32, 38), (84, 50, 36), (126, 78, 52), (170, 114, 76), (206, 152, 104)]
RESTO = [CONTORNO, (36, 32, 38), (60, 56, 64), (98, 94, 100), (150, 144, 140)]
OLHO = (238, 170, 60)
DENTE = (232, 222, 200)
GENGIVA = (120, 30, 36)

# Feições (coordenadas da arte original)
OLHOS = [(382, 352), (526, 338)]
LARG_OLHO = 46
SOBRANCELHAS = {  # (externa, interna) de cada lado
    "brava": [((332, 318), (424, 346)), ((576, 300), (474, 330))],
    "sorrindo": [((332, 312), (424, 306)), ((576, 296), (474, 292))],
    "preocupada": [((332, 330), (424, 298)), ((576, 312), (474, 282))],
}
BOCA = (470, 512)


def limiares(lum, mask, n):
    """Cortes de luminância por percentil, para cada rampa usar os tons por igual."""
    vals = lum[mask]
    return np.percentile(vals, np.linspace(0, 100, n + 1)[1:-1]) if vals.size else np.linspace(40, 200, n - 1)


def base_estilizada(largura):
    im = Image.open(FONTE).convert("RGBA")
    W, H = im.size
    alfa = np.array(im.getchannel("A"))
    rgb = cv2.pyrMeanShiftFiltering(np.array(im.convert("RGB")), 10, 28)

    altura = round(H * largura / W)
    peq = cv2.resize(rgb, (largura, altura), interpolation=cv2.INTER_AREA)
    a = cv2.resize(alfa, (largura, altura), interpolation=cv2.INTER_AREA) >= 128
    lum = cv2.cvtColor(peq, cv2.COLOR_RGB2GRAY).astype(float)

    pele = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(pele)
    d.polygon(ROSTO, fill=255); d.polygon(BRACO, fill=255)
    pele = np.array(pele.resize((largura, altura), Image.BILINEAR)) >= 128
    pele &= a

    out = np.zeros((altura, largura, 4), np.uint8)
    for mask, rampa in ((pele, PELE), (a & ~pele, RESTO)):
        idx = np.digitize(lum, limiares(lum, mask, len(rampa)))
        cores = np.array(rampa, np.uint8)[idx]
        out[mask, :3] = cores[mask]
        out[mask, 3] = 255
    return Image.fromarray(out, "RGBA"), largura / W


def contorno(img):
    px = img.load()
    W, H = img.size
    opaco = [[px[x, y][3] > 0 for x in range(W)] for y in range(H)]
    for y in range(H):
        for x in range(W):
            if opaco[y][x]:
                continue
            if any(0 <= x + dx < W and 0 <= y + dy < H and opaco[y + dy][x + dx] for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                px[x, y] = CONTORNO + (255,)


def rosto(img, k, nome):
    """Apaga e redesenha olhos, sobrancelhas e boca na escala k (pixels alvo por pixel da arte)."""
    d = ImageDraw.Draw(img)
    P = lambda x, y: (round(x * k), round(y * k))
    t = max(1, round(22 * k))  # espessura da sobrancelha

    # apaga olhos, sobrancelhas e boca preenchendo com o entorno, e volta para a paleta de pele
    mask = Image.new("L", img.size, 0)
    dm = ImageDraw.Draw(mask)
    dm.rectangle([P(330, 290), P(436, 370)], fill=255)
    dm.rectangle([P(466, 276), P(582, 356)], fill=255)
    boca = Image.new("L", img.size, 0)
    ImageDraw.Draw(boca).rectangle([P(418, 494), P(522, 534)], fill=255)
    arr = np.array(img)
    for mk, rampa in ((mask, PELE), (boca, RESTO)):
        rgb = cv2.inpaint(np.ascontiguousarray(arr[:, :, :3]), np.array(mk), 3, cv2.INPAINT_TELEA)
        pal = np.array(rampa, float)
        m = np.array(mk) > 0
        perto = np.argmin(((rgb[m][:, None, :].astype(float) - pal[None]) ** 2).sum(-1), axis=1)
        arr[m, :3] = np.array(rampa, np.uint8)[perto]
    img.paste(Image.fromarray(arr, "RGBA"))
    d = ImageDraw.Draw(img)

    # olhos: pálpebra escura em cima, íris âmbar
    lo = max(2, round(LARG_OLHO * k))
    for i, (ox, oy) in enumerate(OLHOS):
        x0, y = P(ox - LARG_OLHO / 2, oy)
        alto = 2 if lo >= 5 else 1
        if nome == "preocupada":  # olho mais aberto
            alto += 1
        d.rectangle([(x0, y), (x0 + lo - 1, y + alto - 1)], fill=OLHO + (255,))
        d.line([(x0 - 1, y - 1), (x0 + lo, y - 1)], fill=CONTORNO + (255,))  # pálpebra
        if lo >= 5:
            cx = x0 + lo // 2
            d.line([(cx, y), (cx, y + alto - 1)], fill=CONTORNO + (255,))  # pupila

    # sobrancelhas
    for ext, inn in SOBRANCELHAS[nome]:
        d.line([P(*ext), P(*inn)], fill=CONTORNO + (255,), width=t)

    # boca
    bx, by = P(*BOCA)
    m = max(2, round(40 * k))  # meia largura
    if nome == "brava":
        h = max(2, round(22 * k))
        d.rectangle([bx - m, by - h // 2, bx + m, by + h // 2], fill=GENGIVA + (255,))
        d.line([(bx - m, by - h // 2), (bx + m, by - h // 2)], fill=DENTE + (255,))
        for fx in (bx - m // 2, bx + m // 2):  # presas
            for j in range(max(1, h - 1)):
                d.point((fx, by - h // 2 + j), fill=DENTE + (255,))
    elif nome == "sorrindo":
        h = max(2, round(20 * k))
        d.chord([bx - m, by - h, bx + m, by + h], 0, 180, fill=DENTE + (255,))
        d.line([(bx - m - 1, by - 1), (bx - m, by)], fill=PELE[3] + (255,))
        d.line([(bx + m + 1, by - 1), (bx + m, by)], fill=PELE[3] + (255,))
    else:
        mm = max(2, round(24 * k))
        h = max(1, round(10 * k))
        d.rectangle([bx - mm // 2, by - h // 2, bx + mm // 2, by + h // 2], fill=GENGIVA + (255,))
        d.line([(bx - mm, by + h // 2 + 1), (bx - mm // 2 - 1, by + h // 2)], fill=PELE[3] + (255,))
        d.line([(bx + mm, by + h // 2 + 1), (bx + mm // 2 + 1, by + h // 2)], fill=PELE[3] + (255,))


if __name__ == "__main__":
    out = sys.argv[1]
    larguras = [int(x) for x in sys.argv[2:]] or [160, 120, 80]
    for w in larguras:
        base, k = base_estilizada(w)
        for nome in SOBRANCELHAS:
            img = base.copy()
            rosto(img, k, nome)
            contorno(img)
            img.save(f"{out}/rayo_{w}_{nome}.png")
