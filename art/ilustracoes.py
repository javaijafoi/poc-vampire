"""Ilustrações de momento-chave montadas com as artes do Peter (só recorte, borda e carimbo; nada é redesenhado).

Uso: python3 art/ilustracoes.py
- constance_chega -> art/cena/fundo_constance_chega.webp: a arte sentada da Constance (Trello, Constance__751a47),
  diferente do retrato que aparece quando ela fala, colada como recorte de revista sobre a escada do bar.
"""
import os
import sys

from PIL import Image, ImageDraw, ImageEnhance, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from recorte import recorte

AQUI = os.path.dirname(os.path.abspath(__file__))
FONTES, CENA = os.path.join(AQUI, "fontes"), os.path.join(AQUI, "cena")
TAM = (1280, 720)
FONTE = os.path.join(FONTES, "SpecialElite-Regular.ttf")


def carimbo(img, texto, x, y, tam=40, giro=-3):
    fonte = ImageFont.truetype(FONTE, tam)
    caixa = ImageDraw.Draw(img).textbbox((0, 0), texto, font=fonte)
    w, h = caixa[2] - caixa[0], caixa[3] - caixa[1]
    faixa = Image.new("RGBA", (w + 44, h + 42), (143, 29, 38, 255))
    ImageDraw.Draw(faixa).text((22, 14), texto, font=fonte, fill=(244, 231, 210))
    faixa = faixa.rotate(giro, expand=True, resample=Image.BICUBIC)
    img.paste(faixa, (x, y), faixa)


def constance_chega():
    base = Image.open(os.path.join(FONTES, "gerado", "escada.jpg")).convert("RGB").resize(TAM, Image.LANCZOS)
    base = ImageEnhance.Brightness(ImageEnhance.Color(base).enhance(0.6)).enhance(0.5).convert("RGBA")
    foto = recorte(os.path.join(FONTES, "ilustracoes", "constance_chegada.jpg"), None, 470, borda=14, seed=21)
    foto = foto.rotate(3, expand=True, resample=Image.BICUBIC)
    sombra = Image.new("RGBA", foto.size, (0, 0, 0, 150))
    sombra.putalpha(foto.getchannel("A").point(lambda v: v * 150 // 255))
    x, y = TAM[0] - foto.width - 90, 40
    base.alpha_composite(sombra, (x + 14, y + 18))
    base.alpha_composite(foto, (x, y))
    carimbo(base, "A PRIMOGÊNITA CHEGA", 70, 90)
    carimbo(base, "CONSTANCE · LASOMBRA", 110, 190, tam=30, giro=2)
    return base.convert("RGB")


if __name__ == "__main__":
    constance_chega().save(os.path.join(CENA, "fundo_constance_chega.webp"), quality=78)
    print("ilustração constance_chega")
