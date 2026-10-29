"""Máscara de papel rasgado para a caixa de texto do tema "revista".

Uso: python3 art/rasgo.py saida.png
Branco opaco com as quatro bordas irregulares, como papel arrancado de revista.
"""
import sys

import numpy as np
from PIL import Image, ImageFilter


def rasgo(W=1600, H=360, seed=11):
    rng = np.random.default_rng(seed)

    def borda(n, amp, passos=(90, 23, 6)):
        # soma de ruídos em escalas diferentes: rasgo grosso + fibra fina
        x = np.zeros(n)
        for p, a in zip(passos, (1, .45, .25)):
            pts = rng.random(n // p + 2)
            x += np.interp(np.arange(n), np.arange(len(pts)) * p, pts) * a
        return (x / x.max() * amp).astype(int)

    a = np.full((H, W), 255, np.uint8)
    topo, base = borda(W, 18), borda(W, 12)
    esq, dir_ = borda(H, 10, (40, 11, 4)), borda(H, 10, (40, 11, 4))
    for x in range(W):
        a[:topo[x], x] = 0
        a[H - base[x]:, x] = 0
    for y in range(H):
        a[y, :esq[y]] = 0
        a[y, W - dir_[y]:] = 0
    img = Image.fromarray(a).filter(ImageFilter.GaussianBlur(.7))
    return Image.merge("LA", (img, img))


if __name__ == "__main__":
    rasgo().save(sys.argv[1])
