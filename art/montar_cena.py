"""Gera a arte do jogo no estilo recorte de revista.

Uso: python3 art/montar_cena.py
- art/fontes/fundo_porao_<n>.jpg   -> art/cena/fundo_balcao.webp (escolha com FUNDO=fundo_porao_2.jpg)
- art/fontes/gerado/<nome>.jpg     -> art/cena/fundo_<nome>.webp (cantos do bar, abertura, momentos-chave;
                                      gerados com art/gerar_fundos.py)
- MORTOS                           -> art/cena/fundo_<chave>_morto.webp (provisórias: recorte do personagem
                                      deitado e em preto e branco por cima de um fundo; nada é redesenhado)
- moldura de pôster                -> art/cena/moldura.webp
- papel rasgado                    -> art/cena/rasgo.png
- art/fontes/<personagem>_<expr>.png -> art/cena/<personagem>_<expr>.webp
  (retrato com fundo recortado; "neutro" é obrigatório, as outras expressões são opcionais)
"""
import glob
import os
import sys

from PIL import Image, ImageDraw, ImageEnhance, ImageFont, ImageOps

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from moldura import moldura
from rasgo import rasgo
from recorte import recorte

AQUI = os.path.dirname(os.path.abspath(__file__))
FONTES, CENA = os.path.join(AQUI, "fontes"), os.path.join(AQUI, "cena")
FUNDO = os.environ.get("FUNDO", "fundo_porao_4.jpg")  # 4 opções geradas com sdxl-turbo; o Peter escolheu a 4
TAM = (1280, 720)

# imagens provisórias de morte: personagem, fundo onde cai, legenda
MORTOS = {
    "rayo": ("amanhecer", "DESTRUÍDO AO AMANHECER"),
    "cao": ("amanhecer", "O XERIFE VIROU CINZA"),
    "harumi": ("porto", "ENCONTRADA NO PORTO"),
}


def tratar_fundo(img):
    img = img.convert("RGB").resize(TAM, Image.LANCZOS)
    img = ImageEnhance.Color(img).enhance(0.85)
    return ImageEnhance.Brightness(img).enhance(1.05)


def morto(chave, fundo, legenda):
    base = Image.open(os.path.join(FONTES, "gerado", fundo + ".jpg")).convert("RGB").resize(TAM, Image.LANCZOS)
    base = ImageEnhance.Brightness(ImageOps.grayscale(base).convert("RGB")).enhance(0.55)
    corpo = recorte(os.path.join(FONTES, f"{chave}_neutro.png"), None, 520)
    alfa = corpo.getchannel("A")
    corpo = ImageOps.colorize(ImageOps.grayscale(corpo), black=(20, 16, 14), white=(214, 204, 186))
    corpo.putalpha(alfa)
    corpo = corpo.rotate(84, expand=True, resample=Image.BICUBIC)
    base.paste(corpo, ((TAM[0] - corpo.width) // 2, TAM[1] - corpo.height + 40), corpo)
    # carimbo vermelho de jornal
    d = ImageDraw.Draw(base)
    fonte = ImageFont.truetype(os.path.join(FONTES, "SpecialElite-Regular.ttf"), 46)  # fonte do tema revista (Apache 2.0)
    caixa = d.textbbox((0, 0), legenda, font=fonte)
    w, h = caixa[2] - caixa[0], caixa[3] - caixa[1]
    x, y = (TAM[0] - w) // 2, 70
    d.rectangle((x - 22, y - 16, x + w + 22, y + h + 26), fill=(143, 29, 38))
    d.text((x, y), legenda, font=fonte, fill=(244, 231, 210))
    return base


tratar_fundo(Image.open(os.path.join(FONTES, FUNDO))).save(os.path.join(CENA, "fundo_balcao.webp"), quality=72)
for f in sorted(glob.glob(os.path.join(FONTES, "gerado", "*.jpg"))):
    nome = os.path.basename(f)[:-4]
    tratar_fundo(Image.open(f)).save(os.path.join(CENA, f"fundo_{nome}.webp"), quality=72)
    print("fundo", nome)
for chave, (fundo, legenda) in MORTOS.items():
    morto(chave, fundo, legenda).save(os.path.join(CENA, f"fundo_{chave}_morto.webp"), quality=72)
    print("morto", chave)

moldura().save(os.path.join(CENA, "moldura.webp"), quality=90)
rasgo().save(os.path.join(CENA, "rasgo.png"))  # borda rasgada da caixa de texto (tema revista)

# Personagens: art/fontes/<personagem>_<expressao>.png -> art/cena/<personagem>_<expressao>.webp
for f in sorted(glob.glob(os.path.join(FONTES, "*_*.png"))):
    nome = os.path.basename(f)[:-4]
    img = recorte(f, None, 700)
    img.save(os.path.join(CENA, f"{nome}.webp"), quality=82)
    print(nome, img.size)
