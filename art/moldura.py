"""Moldura de pôster no estilo das artes do Trello: borda creme, faixa de retícula preta,
manchas de tinta e marcas vermelhas. O miolo fica transparente para o jogo aparecer por baixo.

Uso: python3 art/moldura.py saida.webp [LARGURA ALTURA]
"""
import sys

import numpy as np
from PIL import Image

CREME = np.array([238, 228, 206])
PRETO = np.array([22, 16, 16])
VERMELHO = np.array([178, 32, 40])


def moldura(W=1600, H=900, creme=22, faixa=30, passo=7.0, seed=3):
    S = 2  # supersampling
    w, h = W * S, H * S
    rng = np.random.default_rng(seed)
    y, x = np.mgrid[0:h, 0:w].astype(np.float32)
    borda = np.minimum(np.minimum(x, w - 1 - x), np.minimum(y, h - 1 - y)) / S  # distância da borda, em px finais

    # ruído grosso para a borda interna não ficar reta
    def ruido(escala, amp):
        r = rng.random((h // escala + 2, w // escala + 2)).astype(np.float32)
        return np.array(Image.fromarray((r * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC), np.float32) / 255 * amp

    d = borda + ruido(40 * S, 10) - 5
    t = np.clip((d - creme) / faixa, 0, 1)  # 0 no creme, 1 no miolo

    # retícula girada 45°, pontos crescem em direção ao miolo
    u, v = (x + y) / (passo * S * 1.414), (x - y) / (passo * S * 1.414)
    du, dv = u - np.round(u), v - np.round(v)
    dist = np.sqrt(du * du + dv * dv)
    raio = 0.12 + 0.55 * t ** 1.4
    ponto = (dist < raio) & (t > 0.02)

    img = np.zeros((h, w, 4), np.float32)
    grao = rng.normal(0, 5, (h, w, 1)).astype(np.float32)
    img[..., :3] = CREME + grao
    img[ponto, :3] = PRETO
    # manchas de tinta preta na faixa
    mancha = ruido(14 * S, 1) > 0.80
    img[mancha & (t > 0.25), :3] = PRETO
    img[..., 3] = 255
    img[t >= 1, 3] = 0

    # marcas vermelhas: quadradinhos nas laterais, como nas artes
    for lado in (0, 1):
        for _ in range(5):
            cy = rng.integers(h // 5, h - h // 5)
            cx = (creme + faixa * 0.35) * S if lado == 0 else w - (creme + faixa * 0.35) * S
            r = rng.integers(5, 9) * S
            sel = (np.abs(x - cx) < r) & (np.abs(y - cy) < r * 1.3) & (t < 1)
            img[sel, :3] = VERMELHO

    out = Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), "RGBA")
    return out.resize((W, H), Image.LANCZOS)


if __name__ == "__main__":
    W, H = (int(sys.argv[2]), int(sys.argv[3])) if len(sys.argv) > 3 else (1600, 900)
    moldura(W, H).save(sys.argv[1], quality=90)
