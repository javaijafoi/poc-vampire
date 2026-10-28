"""Gera a arte da cena no estilo recorte de revista.

Uso: python3 art/montar_cena.py
- art/fontes/fundo_porao_<n>.jpg -> art/cena/fundo.webp (escolha com FUNDO=fundo_porao_2.jpg)
- moldura de pôster       -> art/cena/moldura.webp
- art/fontes/rayo_recorte.png  -> art/cena/rayo_neutro.webp
- art/fontes/rayo_<expr>.png   -> art/cena/rayo_<expr>.webp (expressões extras, quando existirem)
"""
import glob
import os
import sys

from PIL import Image, ImageEnhance

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from moldura import moldura
from recorte import recorte

AQUI = os.path.dirname(os.path.abspath(__file__))
FONTES, CENA = os.path.join(AQUI, "fontes"), os.path.join(AQUI, "cena")
FUNDO = os.environ.get("FUNDO", "fundo_porao_1.jpg")  # 4 opções geradas com sdxl-turbo; o Peter escolhe

fundo = Image.open(os.path.join(FONTES, FUNDO)).convert("RGB")
fundo = fundo.resize((1600, 900), Image.LANCZOS)
fundo = ImageEnhance.Color(fundo).enhance(0.85)
fundo = ImageEnhance.Brightness(fundo).enhance(1.05)
fundo.save(os.path.join(CENA, "fundo.webp"), quality=78)

moldura().save(os.path.join(CENA, "moldura.webp"), quality=90)

for f in sorted(glob.glob(os.path.join(FONTES, "rayo_*.png"))):
    nome = os.path.basename(f)[5:-4]
    nome = "neutro" if nome == "recorte" else nome
    img = recorte(f, None, 900)
    img.save(os.path.join(CENA, f"rayo_{nome}.webp"), quality=85)
    print("rayo", nome, img.size)
