"""Transforma um retrato (PNG com fundo recortado) em recorte de revista com borda de papel.

Uso: python3 art/recorte.py entrada.png saida.png [LARGURA]
A borda é irregular, como cortada à tesoura, e o papel tem uma textura leve.
"""
import sys

import numpy as np
from PIL import Image, ImageChops, ImageFilter

PAPEL = (236, 228, 210)


def recorte(entrada, saida, largura=900, borda=16, seed=7):
    im = Image.open(entrada).convert("RGBA")
    im = im.resize((largura, round(im.height * largura / im.width)), Image.LANCZOS)
    pad = borda * 3
    W, H = im.width + 2 * pad, im.height + 2 * pad
    foto = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    foto.paste(im, (pad, pad))

    # A base do retrato é um corte reto: estende o alfa até a borda de baixo
    alfa = np.array(foto.getchannel("A")) >= 128
    alfa[pad + im.height - 2:, :] = alfa[pad + im.height - 3, :]
    alfa[H - pad // 2:, :] = False
    foto_a = Image.fromarray((alfa * 255).astype(np.uint8))

    # Borda de papel: o recorte engordado, com contorno irregular de tesoura
    gordo = foto_a.filter(ImageFilter.MaxFilter(borda * 2 + 1))
    rng = np.random.default_rng(seed)
    ruido = Image.fromarray((rng.random((H // 6 + 1, W // 6 + 1)) * 255).astype(np.uint8)).resize((W, H), Image.BICUBIC)
    gordo = ImageChops.multiply(gordo.filter(ImageFilter.GaussianBlur(5)), Image.eval(ruido, lambda v: 170 + v // 3))
    papel_a = gordo.point(lambda v: 255 if v > 110 else 0).filter(ImageFilter.ModeFilter(5))

    grao = Image.fromarray((rng.normal(0, 7, (H, W))).clip(-20, 20).astype(np.int16) + 0, None)
    base = np.zeros((H, W, 4), np.uint8)
    base[..., :3] = np.clip(np.array(PAPEL)[None, None, :] + np.array(grao)[..., None], 0, 255)
    base[..., 3] = np.array(papel_a)
    out = Image.fromarray(base, "RGBA")

    # Foto por cima, com a base reta e uma sombra fina de impressão na borda interna
    foto.putalpha(Image.fromarray(np.minimum(np.array(foto.getchannel("A")), np.array(papel_a))))
    foto_a2 = foto.getchannel("A").point(lambda v: 255 if v >= 128 else 0)
    linha = Image.new("RGBA", (W, H), (60, 50, 40, 0))
    linha.putalpha(ImageChops.subtract(foto_a2.filter(ImageFilter.MaxFilter(3)), foto_a2).point(lambda v: v // 3))
    out.alpha_composite(foto)
    out.alpha_composite(linha)
    out = out.crop(out.getbbox())
    if saida:
        out.save(saida)
    return out


if __name__ == "__main__":
    recorte(sys.argv[1], sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 900)
